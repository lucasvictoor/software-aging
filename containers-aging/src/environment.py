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
    with open(filename, "a+") as file:
        file.seek(0, os.SEEK_END)
        file_size = file.tell()
        if file_size == 0:
            file.write(f"{header}\n")
        file.write(f"{content}\n")


def execute_command(command, informative=False, continue_if_error=False, error_informative=True) -> str:
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output, error = process.communicate()
    return_code = process.wait()

    if return_code != 0:
        if error_informative:
            print(f'ERROR: {error.decode("utf-8").strip()}\n COMMAND: ${command}')
        if not continue_if_error:
            exit(return_code)
    else:
        if informative:
            print(output.decode("utf-8").strip())

        return output.decode("utf-8").strip().replace("\n", "")


def get_time(command) -> int:
    start_time = time.perf_counter_ns()
    execute_command(command)
    end_time = time.perf_counter_ns()
    return end_time - start_time


class Environment:
    def __init__(
            self,
            containers: list,
            max_container_wait_time: int,
            sleep_time: int,
            lifecycle_runs: int,
            software: str,
            images_server_folder: str,
            max_stress_time: int,
            wait_after_stress: int,
            runs: int,
            old_software: bool,
            system: str,
            old_system: bool,
            run_only_monitoring: bool
    ):
        script_path = sys.argv[0]
        pasta = os.path.dirname(script_path)
        log_dir = software
        if old_software:
            log_dir = log_dir + "_old_"
        else:
            log_dir = log_dir + "_new_"

        log_dir = log_dir + system
        if old_system:
            log_dir = log_dir + "_old"
        else:
            log_dir = log_dir + "_new"

        self.logs_dir = log_dir
        self.containers = containers
        self.max_container_wait_time = max_container_wait_time
        self.path = os.path.dirname(pasta) + "/containers-aging"
        self.sleep_time = sleep_time
        self.lifecycle_runs = lifecycle_runs
        self.software = software
        self.images_server_folder = images_server_folder
        self.max_stress_time = max_stress_time
        self.wait_after_stress = wait_after_stress
        self.runs = runs
        self.run_only_monitoring = run_only_monitoring

    def clean(self):
        print("Cleaning old logs and containers")
        execute_command(f"rm -rf {self.path}/{self.logs_dir}", continue_if_error=True)
        execute_command(f"mkdir {self.path}/{self.logs_dir}", continue_if_error=True)
        self.clear_containers_and_images()

    def clear_containers_and_images(self):
        for container in self.containers:
            execute_command(f"rm -f {self.path}/{container}", continue_if_error=True)
        execute_command(f"{self.software} stop $({self.software} ps -aq)", continue_if_error=True)
        execute_command(f"{self.software} rm $({self.software} ps -aq)", continue_if_error=True)
        execute_command(f"{self.software} rmi $({self.software} image ls -aq)", continue_if_error=True)

    def run(self):
        self.clean()
        #self.start_teastore()
        self.start_monitoring()

        now = datetime.now()
        end = datetime.now() + timedelta(seconds=(self.max_stress_time * self.runs + self.wait_after_stress * self.runs))
        seconds = (end - now).total_seconds()
        print(f"Script should end at around {end}")

        if self.run_only_monitoring:
            print(f"Waiting {seconds} seconds")
            time.sleep(seconds)
            print(f"Ended at {datetime.now()}")
            return

        for current_run in range(self.runs):
            self.__print_progress_bar(current_run, "Progress")
            self.stressload(self.max_stress_time)
            time.sleep(self.wait_after_stress)

        self.__print_progress_bar(self.runs, "Progress")
        print(f"Ended at {datetime.now()}")

    def start_teastore(self):
        print("Starting teastore")

        def run_tea_store():
            if self.software == "docker":
                command = f"docker compose -f {self.path}/docker-compose.yaml up -d --quiet-pull"
            else:
                command = f"podman-compose -f {self.path}/docker-compose.yaml up -d --quiet-pull"
            execute_command(command, informative=True)

        monitoring_thread = threading.Thread(target=run_tea_store, name="tea-store")
        monitoring_thread.daemon = True
        monitoring_thread.start()
        monitoring_thread.join()

    def systemtap(self):
        def run_systemtap():
            command = f"stap -o {self.path}/{self.logs_dir}/fragmentation.csv {self.path}/fragmentation.stp"
            execute_command(command)

        monitoring_thread = threading.Thread(target=run_systemtap, name="systemtap")
        monitoring_thread.daemon = True
        monitoring_thread.start()

    def start_monitoring(self):
        print("Starting monitoring scripts")
        # self.systemtap()
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
        container_name = container["name"]
        host_port = container["host_port"]
        container_port = container["port"]
        for _ in range(self.lifecycle_runs):
            time.sleep(sleep_time)

            execute_command(
                f"scp root@{self.images_server_folder}/{container_name}.tar {self.path}/{container_name}.tar")

            load_image_time = get_time(f"{self.software} load -i {self.path}/{container_name}.tar -q")

            execute_command(f"rm -f {self.path}/{container_name}.tar")

            start_time = get_time(
                f"{self.software} run --name {container_name} -td -p {host_port}:{container_port} --init {container_name}")

            up_time = execute_command(
                f"{self.software} exec -i {container_name} sh -c \"test -e /root/log.txt && cat /root/log.txt\"",
                continue_if_error=True, error_informative=False)

            while up_time is None:
                up_time = execute_command(
                    f"{self.software} exec -i {container_name} sh -c \"test -e /root/log.txt && cat /root/log.txt\"",
                    continue_if_error=True, error_informative=False)

            stop_time = get_time(f"{self.software} stop {container_name}")

            remove_container_time = get_time(f"{self.software} rm {container_name}")

            remove_image_time = get_time(f"{self.software} rmi {container_name}")
            write_to_file(
                f"{self.path}/{self.logs_dir}/{container_name}.csv",
                "load_image;start;up;stop;remove_container;remove_image",
                f"{load_image_time};{start_time};{up_time};{stop_time};{remove_container_time};{remove_image_time}"
            )

    def __print_progress_bar(self, current_run, text):
        progress_bar_size = 50
        current_progress = current_run / self.runs
        sys.stdout.write(
            f"\r{text}: [{'=' * int(progress_bar_size * current_progress):{progress_bar_size}s}] "
            f"{round(current_progress, 2) * 100}%"
        )
        sys.stdout.flush()

    def stressload(self, max_stress_time):
        bag = self.containers.copy()
        random.shuffle(bag)

        now = datetime.now()
        max_date = now + timedelta(seconds=max_stress_time)

        while datetime.now() < max_date:
            threads = []
            for container in bag:
                sleep_time = random.randint(1, self.max_container_wait_time)

                container_thread = threading.Thread(
                    target=self.container_lifecycle,
                    name=container,
                    args=(sleep_time, container)
                )

                container_thread.daemon = True
                container_thread.start()
                threads.append(container_thread)

            random.shuffle(bag)

            for thread in threads:
                thread.join()

    def disk_monitoring(self, date_time):
        comando = "df | grep '/$' | awk '{print $3}'"
        mem = execute_command(comando)

        write_to_file(
            f"{self.path}/{self.logs_dir}/disk.csv",
            "used;time",
            f"{mem};{date_time}"
        )

    def cpu_monitoring(self, date_time):
        cpu_info = execute_command("mpstat | grep all").split()
        usr = cpu_info[2]
        nice = cpu_info[3]
        sys_used = cpu_info[4]
        iowait = cpu_info[5]
        soft = cpu_info[7]

        write_to_file(
            f"{self.path}/{self.logs_dir}/cpu.csv",
            "usr;nice;sys;iowait;soft;time",
            f"{usr};{nice};{sys_used};{iowait};{soft};{date_time}"
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

        framework = Environment(
            **config["general"], **config["monitoring"], **config["stressload"], containers=config["containers"]
        )

        framework.run()
