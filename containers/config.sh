#!/bin/bash

image="pedrmelo/software-aging"         #WARNING: Used by docker and Podman
max_runs=1000                           #Number of runs default 1000
remove_image=1                          #1 to remove image, 0 to keep it
local="local"                           #local or remote
image_tag="debian500mb"                 #debian500mb, debian1gb, debian2gb, debian3gb, debian4gb
download_link="192.168.0.101"           #When local, the IP of the server. When remote, the link to download the image

#Not important, just to control the file name
service="1"                   #1 for docker, 2 for podman, 3 for lxc
image_size="500"              #500, 1024, 2048, 3072, 4096

mkdir -p "logs"

service_display_name=""
if [ $service -eq "1" ]; then
  service_display_name="docker"
elif [ $service -eq "2" ]; then
  service_display_name="podman"
elif [ $service -eq "3" ]; then
  service_display_name="lxc"
fi

if [ $remove_image -eq 1 ]; then
  if [ "$local" == "local" ]; then
    log_file="$service_display_name-$image_tag-rmi-local-$(date +%Y%m%d%H%M%S).csv"
    test_type=3
  else
    log_file="$service_display_name-$image_tag-rmi-$(date +%Y%m%d%H%M%S).csv"
    test_type=2
  fi
else
  log_file="$service_display_name-$image_tag-normal-$(date +%Y%m%d%H%M%S).csv"
  test_type=1
fi

echo "download;load;start;stop;rm_container;rm_image;image_size;test_type;service;time" > "logs/$log_file"