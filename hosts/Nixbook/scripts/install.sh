#!/usr/bin/env bash

set -euo pipefail

### CONFIGURATION ###
TARGET_IP="192.168.1.65"
INSTALL_USER="nixos"
INSTALL_PASS="123456"
SSH_KEY="$HOME/.ssh/id_rsa.pub"
FLAKE_PATH="./#Nixbook"

### 1. Ensure SSH key is available ###
if [ ! -f "$SSH_KEY" ]; then
  echo "❌ SSH key not found at $SSH_KEY"
  exit 1
fi

### 2. Add SSH key to remote temporary user ###
echo "🔐 Copying SSH key to $INSTALL_USER@$TARGET_IP..."
ssh-copy-id -i "$SSH_KEY" "$INSTALL_USER@$TARGET_IP"

### 3. Grant temporary user passwordless sudo on target machine ###
echo "🔧 Configuring sudo access for $INSTALL_USER on target..."
ssh "$INSTALL_USER@$TARGET_IP" <<'EOF'
echo "$INSTALL_USER ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/90-$INSTALL_USER
sudo chmod 0440 /etc/sudoers.d/90-$INSTALL_USER
EOF

### 4. Run nixos-anywhere from nix-shell ###
echo "🚀 Starting nixos-anywhere install to $TARGET_IP..."
nix-shell -p nixos-anywhere --run "
  nixos-anywhere \
    -i ~/.ssh/id_rsa \
    --ssh-option User=root \
    --flake $FLAKE_PATH \
    --build-on-remote $TARGET_IP
"

echo "✅ Installation complete!"
