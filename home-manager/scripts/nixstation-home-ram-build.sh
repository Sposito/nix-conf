#!/usr/bin/env bash

set -e

RAMDISK_PATH="/mnt/ramdisk"
SIZE="48G"
FLAKE_NAME=".#thiago@Nixstation"

echo "[+] Creating RAM disk at $RAMDISK_PATH ($SIZE)"
sudo mkdir -p "$RAMDISK_PATH"
sudo mount -t tmpfs -o size=$SIZE tmpfs "$RAMDISK_PATH"

echo "[+] Running home-manager switch with TMPDIR=$RAMDISK_PATH"
TMPDIR="$RAMDISK_PATH" home-manager switch --flake "$FLAKE_NAME"

echo "[+] Cleaning up RAM disk"
sudo umount "$RAMDISK_PATH"
