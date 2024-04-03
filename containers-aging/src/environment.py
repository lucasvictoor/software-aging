import os
import subprocess
import sys
import threading
import time
from datetime import datetime, timedelta
from random import random
import yaml
import random


def write_to_file(filename, header, content):
    with open(filename, "a+") as arquivo:
        arquivo.seek(0, os.SEEK_END)
        tamanho_arquivo = arquivo.tell()
        if tamanho_arquivo == 0:
            arquivo.write(f"{header}\n")
        arquivo.write(f"{content}\n")


def execute_command(command) -> str:
    processo = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
    output, error = processo.communicate()
    returncode = processo.wait()  # Get return code

    if returncode != 0:
        raise subprocess.CalledProcessError(returncode, command, output.decode("utf-8"), error.decode("utf-8"))
    else:
        return output.decode("utf-8").strip()


def get_time(command) -> float:
    time_started = time.time()
    execute_command(command)
    time_finished = time.time()
    return time_finished - time_started


class Environment:
    def __init__(
            self,
            logs_dir: str,
            containers_dir: str,
            containers: list,
            max_container_wait_time: int,
            sleep_time: int,
            lifecycle_runs: int,
            software: str,
            images_server_folder: str,
            max_stress_time: int,
            wait_after_stress: int,
            runs: int
    ):
        caminho_script = sys.argv[0]
        pasta = os.path.dirname(caminho_script)
        self.logs_dir = logs_dir
        self.containers_dir = containers_dir
        self.containers = containers
        self.max_container_wait_time = max_container_wait_time
        self.path = os.path.dirname(pasta)
        self.sleep_time = sleep_time
        self.lifecycle_runs = lifecycle_runs
        self.software = software
        self.images_server_folder = images_server_folder
        self.max_stress_time = max_stress_time
        self.wait_after_stress = wait_after_stress
        self.runs = runs

    def clean(self):
        execute_command(f"rm -rf {self.path}/{self.logs_dir}")
        execute_command(f"mkdir {self.path}/{self.logs_dir}")

    def run(self):
        self.clean()
        self.start_teastore()
        self.start_monitoring()
        for _ in range(self.runs):
            self.stressload(self.max_stress_time)
            time.sleep(self.wait_after_stress)

    def start_teastore(self):
        command = f"{self.software}-compose -f {self.path}/docker-compose.yaml up"
        monitoring_thread = threading.Thread(target=execute_command, name="tea-store", args=command)
        monitoring_thread.daemon = True
        monitoring_thread.start()

    def systemtap(self):
        command = f"stap -o {self.path}/{self.logs_dir}/fragmentation.csv {self.path}/fragmentation.stp"
        monitoring_thread = threading.Thread(target=execute_command, name="systemtap", args=command)
        monitoring_thread.daemon = True
        monitoring_thread.start()

    def start_monitoring(self):
        self.systemtap()
        monitoring_thread = threading.Thread(target=self.machine_resources, name="monitoring")
        monitoring_thread.daemon = True
        monitoring_thread.start()

    def machine_resources(self):
        while True:
            now = datetime.now()
            date_time = now.strftime("%Y-%m-%d %H:%M:%S")
            self.cpu_monitoring(date_time)
            self.disk_monitoring(date_time)
            self.memory_monitoring(date_time)
            self.process_monitoring(date_time)
            time.sleep(self.sleep_time)

    def container_lifecycle(self, sleep_time, container):
        for _ in range(self.lifecycle_runs):
            time.sleep(sleep_time)

            execute_command(f"scp root@{self.images_server_folder}/{container.name}.tar {self.path}/{container.name}.tar")

            load_image_time = get_time(f"{self.software} load q -i {self.path}/{container.image}.tar")

            start_time = get_time(f"{self.software} run --name {container.name} -td -p {container.host_port}:{container.port} --init localhost/{container.image}")

            up_time = get_time(f"{self.software} exec -it {container.name} sh -c \"test -e /root/log.txt && cat /root/log.txt\"")

            stop_time = get_time(f"{self.software} stop {container.name}")

            remove_container_time = get_time(f"{self.software} rm {container.name}")

            remove_image_time = get_time(f"{self.software} rmi localhost/{container.image}")

            write_to_file(
                f"{self.path}/{self.logs_dir}/{container.name}-{container.name}.csv",
                "load_image;start;up;stop;remove_container;remove_image",
                f"{load_image_time};{start_time};{up_time};{stop_time};{remove_container_time};{remove_image_time}"
            )

    def stressload(self, max_stress_time):
        bag = self.containers.copy()
        random.shuffle(bag)

        now = datetime.now()
        max_stress_time = now + timedelta(seconds=max_stress_time)

        threads = []
        while now < max_stress_time:
            if len(bag) == 0:
                for thread in threads:
                    if thread.is_alive():
                        thread.join()
                bag = self.containers.copy()
                random.shuffle(bag)

            container = bag.pop()

            sleep_time = random.randint(1, self.max_container_wait_time)

            container_thread = threading.Thread(
                target=self.container_lifecycle,
                name=container,
                args=(sleep_time, container)
            )

            container_thread.daemon = True
            container_thread.start()
            threads.append(container_thread)

    def disk_monitoring(self, date_time):
        comando = "df | grep '/$' | awk '{print $3}'"
        mem = execute_command(comando)

        write_to_file(
            f"{self.path}/{self.logs_dir}/disk.csv",
            "used;time",
            f"{mem};{date_time}"
        )

    def cpu_monitoring(self, time):
        cpu_info = execute_command("mpstat | grep all").split()
        usr = cpu_info[2]
        nice = cpu_info[3]
        sys = cpu_info[4]
        iowait = cpu_info[5]
        soft = cpu_info[7]

        write_to_file(
            f"{self.path}/{self.logs_dir}/cpu.csv",
            "usr;nice;sys;iowait;soft;time",
            f"{usr};{nice};{sys};{iowait};{soft};{time}"
        )

    def memory_monitoring(self, date_time):
        used = execute_command("free | grep Mem | awk '{print $3}'")
        cached = execute_command("cat /proc/meminfo | grep -i Cached | sed -n '1p' | awk '{print $2}'")
        buffers = execute_command("cat /proc/meminfo | grep -i Buffers | sed -n '1p' | awk '{print $2}'")
        swap = execute_command("cat /proc/meminfo | grep -i Swap | grep -i Free | awk '{print $2}'")

        write_to_file(
            f"{self.path}/{self.logs_dir}/memory.csv",
            "used;cached;buffers;swap;time",
            f"{used};{cached};{buffers};{swap};{date_time}"
        )

    def process_monitoring(self, date_time):
        zombies = execute_command("ps aux | awk '{if ($8 ~ \"Z\") {print $0}}' | wc -l")

        write_to_file(
            f"{self.path}/{self.logs_dir}/process.csv",
            "zombies;time",
            f"{zombies};{date_time}"
        )



class EnvironmentConfig:
    def __init__(self):
        with open("config.yaml", "r") as yml_file:
            config = yaml.load(yml_file, Loader=yaml.FullLoader)

        print(config)

        framework = Environment(
            **config["general"], **config["monitoring"], **config["stressload"], containers=config["containers"]
        )

        framework.run()
