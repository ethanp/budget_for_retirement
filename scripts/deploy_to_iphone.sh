#!/bin/bash
# Builds and installs Budget for Retirement to connected physical iPhone
# Usage: ./scripts/deploy_to_iphone.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

# Find physical iOS device (excludes simulators)
DEVICE_LINE=$(flutter devices | grep -i "ios" | grep -v "simulator" | head -1)

if [ -z "$DEVICE_LINE" ]; then
  echo "Error: No physical iPhone connected"
  exit 1
fi

# Extract device ID (the part between • markers)
DEVICE_ID=$(echo "$DEVICE_LINE" | awk -F'•' '{print $2}' | xargs)

if [ -z "$DEVICE_ID" ]; then
  echo "Error: Could not parse device ID from: $DEVICE_LINE"
  exit 1
fi

echo "Found device: $DEVICE_ID"
echo "Building for iOS..."
flutter build ios --release

echo "Installing to iPhone..."
flutter install -d "$DEVICE_ID"

echo "✓ Deployed to iPhone"
