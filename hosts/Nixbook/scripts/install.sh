#!/usr/bin/env bash

set -euo pipefail

### CONFIGURATION ###
TARGET_IP="192.168.1.65"
INSTALL_USER="nixos"
INSTALL_PASS="123456"
SSH_KEY="$HOME/.ssh/id_rsa.pub"
FLAKE_PATH="./#Nixbook"

# Export variables needed inside nix-shell
export TARGET_IP INSTALL_USER INSTALL_PASS SSH_KEY FLAKE_PATH HOME

### Prerequisites Check ###
# Removed check, sshpass will be provided by nix-shell

### 0. Ensure SSH key is available ###
if [ ! -f "$SSH_KEY" ]; then
  echo "❌ SSH key not found at $SSH_KEY"
  exit 1
fi

### 1. Remove existing SSH known_hosts entry if it exists ###
echo "🧹 Checking for existing SSH known_hosts entry for $TARGET_IP..."
if grep -q "$TARGET_IP" ~/.ssh/known_hosts; then
  echo "🔄 Removing existing SSH known_hosts entry for $TARGET_IP..."
  ssh-keygen -R "$TARGET_IP"
else
  echo "✅ No existing SSH known_hosts entry found for $TARGET_IP."
fi

### 2, 3, 4: Run commands requiring Nix-provided packages ###
# Use a single nix-shell environment for sshpass, openssh, and nixos-anywhere
nix-shell -p nixos-anywhere sshpass openssh --run '
  # Re-set options for this subshell
  set -euo pipefail

  ### 2. Add SSH key to remote temporary user ###
  echo "🔐 Copying SSH key to $INSTALL_USER@$TARGET_IP..."
  # sshpass and ssh-copy-id are from nix-shell environment
  sshpass -p "$INSTALL_PASS" ssh-copy-id -i "$SSH_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$INSTALL_USER@$TARGET_IP"

  ### 3. Grant temporary user passwordless sudo on target machine ###
  echo "🔧 Configuring sudo access for $INSTALL_USER on target..."
  # ssh is from nix-shell environment
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$INSTALL_USER@$TARGET_IP" <<EOF
# Ensure the sudoers.d directory exists
sudo mkdir -p /etc/sudoers.d
# Write the sudo rule
echo "$INSTALL_USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/90-$INSTALL_USER
sudo chmod 0440 /etc/sudoers.d/90-$INSTALL_USER
EOF

  ### 4. Run nixos-anywhere ###
  echo "🚀 Starting nixos-anywhere install to $TARGET_IP..."
  # nixos-anywhere is from nix-shell environment
  nixos-anywhere \
    -i ~/.ssh/id_rsa \
    --ssh-option User=$INSTALL_USER \
    --ssh-option StrictHostKeyChecking=no \
    --ssh-option UserKnownHostsFile=/dev/null \
    --flake $FLAKE_PATH \
    --build-on-remote \
    $TARGET_IP
'

echo "✅ Installation complete!"
