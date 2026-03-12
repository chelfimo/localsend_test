#!/bin/bash
set -e

# TestBot Setup Script for LocalSend
# Builds and starts the LocalSend HTTP server for API testing

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$SCRIPT_DIR/.."
APP_DIR="$REPO_DIR/app"
FLUTTER_VERSION="3.38.10"

echo "=== LocalSend TestBot Setup ==="

# Install system dependencies
echo "Installing system dependencies..."
sudo apt-get update -q
sudo apt-get install -y -q \
  clang cmake ninja-build \
  libgtk-3-dev libayatana-appindicator3-dev \
  xvfb curl

# Install Flutter if not already available
if ! command -v flutter &> /dev/null; then
  echo "Downloading Flutter $FLUTTER_VERSION..."
  wget -q \
    "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    -O /tmp/flutter.tar.xz
  tar xf /tmp/flutter.tar.xz -C "$HOME"
  export PATH="$PATH:$HOME/flutter/bin"
fi

echo "Flutter: $(flutter --version --no-version-check 2>&1 | head -1)"

# Install Rust (required by flutter_rust_bridge)
if ! command -v cargo &> /dev/null; then
  echo "Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
fi
source "$HOME/.cargo/env"
echo "Cargo: $(cargo --version)"

# Install dependencies and run code generation
echo "Installing dependencies..."
cd "$APP_DIR"
flutter pub get
dart run build_runner build -d

# Build LocalSend for Linux
echo "Building LocalSend..."
flutter build linux --release

# Start a virtual display (required for GTK)
echo "Starting virtual display..."
Xvfb :99 -screen 0 1280x720x24 &
export DISPLAY=:99
sleep 1

# Launch LocalSend minimized to tray in the background
BINARY="$APP_DIR/build/linux/x64/release/bundle/localsend_app"
echo "Starting LocalSend ($BINARY)..."
"$BINARY" --hidden &

echo "LocalSend HTTP server starting on port 53317..."
