#!/bin/bash
# Builds and installs Budget for Retirement to Applications folder
# Usage: ./scripts/deploy.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="Budget for Retirement"

cd "$PROJECT_DIR"

echo "Building $APP_NAME..."
flutter build macos --release

echo "Installing to /Applications..."
rm -rf "/Applications/$APP_NAME.app"
cp -R "build/macos/Build/Products/Release/budget_for_retirement.app" "/Applications/$APP_NAME.app"

echo "✓ Installed to /Applications/$APP_NAME.app"

