#!/usr/bin/env bash
########################################################################
#            🄯 2025  Thiago Sposito — All rights reversed              #
# This script is free software: you can redistribute it and/or modify  #
# it  under   the terms  of  the   GNU General   Public License  v3.0. #
# See   https://www.gnu.org/licenses/gpl-3.0.html   for full  details. #
########################################################################

clear
if ! command -v nvidia-smi >/dev/null 2>&1; then
  echo "non compatible gpu"
  exit 1
fi

tput civis
stty -echo -icanon time 0 min 0

trap 'stty sane; tput cnorm; exit' INT TERM EXIT

while true; do
  nvidia-smi \
    --query-gpu=index,name,temperature.gpu,memory.used,memory.total,utilization.gpu \
    --format=csv,noheader,nounits |

  awk -F", " '{printf "GPU %s (%s): Temp: %s°C | Mem: %s/%s MiB | Util: %s%%\033[K\n", $1, $2, $3, $4, $5, $6}'
  echo

  read -n 1 -t 1 first
  read -n 1 -t 0.1 second
  key="${first}${second}"

  if [[ "$key" == "q" || "$key" == ":q" ]]; then
    break
  fi

  echo -en "\033[${LINES}A"
done
