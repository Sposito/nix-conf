#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root." >&2
  exit 1
fi

MACHINE_ID=$(
  cat /sys/class/dmi/id/product_uuid \
      /sys/class/dmi/id/board_serial \
      /sys/class/dmi/id/product_serial \
      /proc/cpuinfo \
    | sha256sum | cut -d' ' -f1
)

echo -n "$MACHINE_ID" | openssl dgst -sha256 -binary | head -c 32 > "$1"

echo "Generated machine-specific key:"
openssl dgst -sha256 "$1"
