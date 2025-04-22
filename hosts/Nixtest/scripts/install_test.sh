#!/usr/bin/env bash

set -euo pipefail

### Configuration ###

# Find virtual images at: https://alpinelinux.org/downloads/ -> Virtual
ALPINE_VERSION="3.19.1"
ALPINE_ARCH="x86_64"
ALPINE_IMAGE_FILENAME="alpine-virt-${ALPINE_VERSION}-${ALPINE_ARCH}.iso"
ALPINE_IMAGE_URL="https://dl-cdn.alpinelinux.org/alpine/v$(echo $ALPINE_VERSION | cut -d. -f1-2)/releases/${ALPINE_ARCH}/${ALPINE_IMAGE_FILENAME}"

QEMU_MEM="2048"
QEMU_CPUS="2"
QEMU_SSH_HOST_PORT="2222"
QEMU_PID_FILE="qemu_test.pid"

TARGET_IP="127.0.0.1"
TARGET_PORT="${QEMU_SSH_HOST_PORT}"
TARGET_USER="root"
SSH_KEY_PUB="$HOME/.ssh/id_rsa.pub"
SSH_KEY_PRIV="$HOME/.ssh/id_rsa"

FLAKE_PATH="./#Nixtest"

### Helper Functions ###
cleanup_qemu() {
  if [ -f "$QEMU_PID_FILE" ]; then
    echo "🧹 Cleaning up previous QEMU instance..."
    kill -- "-$(cat $QEMU_PID_FILE)" 2>/dev/null || kill "$(cat $QEMU_PID_FILE)" 2>/dev/null || true
    rm -f "$QEMU_PID_FILE"
    sleep 2
    echo "🧹 Cleanup complete."
  fi
}

launch_qemu_alpine() {
  echo "🚀 Launching QEMU with Alpine Linux (${ALPINE_IMAGE_FILENAME})..."
  qemu-system-x86_64 \
    -m "${QEMU_MEM}" \
    -smp "${QEMU_CPUS}" \
    -enable-kvm \
    -nic user,model=virtio-net-pci,hostfwd=tcp::${TARGET_PORT}-:22 \
    -drive file="${ALPINE_IMAGE_FILENAME}",media=cdrom,readonly=on \
    -boot d \
    -display none \
    -daemonize \
    -pidfile "$QEMU_PID_FILE"

  echo "⏳ Waiting for QEMU to boot and SSH to become available on port ${TARGET_PORT}..."
  local max_wait=90
  local waited=0
  while ! ssh -p "${TARGET_PORT}" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=2 -o ConnectionAttempts=3 "${TARGET_USER}@${TARGET_IP}" exit >/dev/null 2>&1; do
    sleep 3
    waited=$((waited + 3))
    if [ "$waited" -ge "$max_wait" ]; then
      echo "❌ Timed out waiting for SSH on port ${TARGET_PORT}."
      cat "$QEMU_PID_FILE"
      cleanup_qemu
      exit 1
    fi
    echo -n "."
  done
  echo
  echo "✅ QEMU Alpine VM is up and SSH is ready on port ${TARGET_PORT}."
}

### Main Script ###

trap cleanup_qemu EXIT SIGINT SIGTERM

if [ ! -f "$ALPINE_IMAGE_FILENAME" ]; then
  echo "⏬ Downloading Alpine image: ${ALPINE_IMAGE_FILENAME}..."
  wget --progress=bar:force -O "$ALPINE_IMAGE_FILENAME" "$ALPINE_IMAGE_URL"
else
  echo "✅ Alpine image found locally: ${ALPINE_IMAGE_FILENAME}"
fi

if [ ! -f "$SSH_KEY_PUB" ] || [ ! -f "$SSH_KEY_PRIV" ]; then
  echo "❌ SSH key not found at $SSH_KEY_PRIV or $SSH_KEY_PUB"
  echo "   Please generate one using 'ssh-keygen' or specify the correct path."
  exit 1
fi
echo "✅ Using SSH key: ${SSH_KEY_PRIV}"

cleanup_qemu
launch_qemu_alpine

# --- Installation logic will go here ---

echo "🏁 Test script placeholder finished. VM is running."
echo "   PID: $(cat $QEMU_PID_FILE)"
echo "   To connect: ssh -p ${TARGET_PORT} ${TARGET_USER}@${TARGET_IP}"
