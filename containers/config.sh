#!/bin/bash

max_runs=1000 #Number of runs default 1000
server_link="192.168.0.101" #The IP of the server

#Test scenarios
application="redis"         #redis, nginx, rabbitmq or postgres
service="docker"            #docker, podman, lxc
image_size="500"            #500, 1024, 2048, 4096

#Dont change this
image_name="$application-${image_size}mb"
mapping_port="80"           #Port to map the container

if [ "$application" == "nginx" ]; then
  mapping_port="80"
elif [ "$service" == "redis" ]; then
  mapping_port="6379"
elif [ "$service" == "rabbitmq" ]; then
  mapping_port="5672"
elif [ "$service" == "postgres" ]; then
  mapping_port="5432"
fi

mkdir -p "logs"

log_file="$service-$image_name-$(date +%Y%m%d%H%M%S).csv"

echo "download;load;start;ap_start;stop;rm_container;rm_image;image_size;application;service;date_time" >"logs/$log_file"
