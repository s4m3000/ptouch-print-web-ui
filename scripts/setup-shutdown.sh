#!/bin/bash

# CONFIGURATION
HOST_NAME="your-host-name"
SUDOERS_FILE="/etc/sudoers.d/shutdown-direct"
SHUTDOWN_CMD="/sbin/shutdown"

# Get the script directory
cd "$(dirname "$0")"
SCRIPT_DIR="$(pwd)"

echo "🔧 Configuring sudoers for user '$HOST_NAME' to allow passwordless shutdown..."

# Check if the shutdown command exists
if [ ! -x "$SHUTDOWN_CMD" ]; then
  echo "❌ Error: '$SHUTDOWN_CMD' not found. Is it installed?"
  exit 1
fi

# Create the sudoers rule if it doesn't already exist
if [ ! -f "$SUDOERS_FILE" ]; then
  echo "$HOST_NAME ALL=(ALL) NOPASSWD: $SHUTDOWN_CMD" | sudo tee "$SUDOERS_FILE" > /dev/null
  sudo chmod 440 "$SUDOERS_FILE"
  echo "✅ Sudoers rule created at $SUDOERS_FILE"
else
  echo "⚠️ Sudoers rule already exists at $SUDOERS_FILE, skipping."
fi

# Generate ssh keys
echo "🔧 Installing openssh-client..."
if command -v ssh-keygen >/dev/null 2>&1
then
    echo "⚠️ ssh-keygen already installed, skipping."
else
    sudo apt install openssh-client -y
fi
echo "🔧 Generating ssh keys..."
ssh-keygen -t ed25519 -f ~/.ssh/container_shutdown_key -N ""

# Add public key to auth. keys
cat ~/.ssh/container_shutdown_key.pub >> ~/.ssh/authorized_keys

# Move the key here
KEY_DIR="$SCRIPT_DIR/../config/ssh-key/"
mkdir -p $KEY_DIR
mv ~/.ssh/container_shutdown_key $KEY_DIR
chmod 600 $KEY_DIR/container_shutdown_key 2>/dev/null || true
