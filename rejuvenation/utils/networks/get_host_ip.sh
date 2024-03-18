#!/usr/bin/env bash

# shellcheck disable=SC2034

GET_HOST_IP="$(hostname -I | awk '{print $1}')"
