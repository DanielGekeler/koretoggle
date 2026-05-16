#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $EUID -ne 0 ]]; then
    echo "Run with sudo: sudo ./install.sh" >&2
    exit 1
fi

# Build and install the QML plugin
BUILD_DIR="$SCRIPT_DIR/plugin/build"
mkdir -p "$BUILD_DIR"
cmake -S "$SCRIPT_DIR/plugin" -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Release
cmake --build "$BUILD_DIR"
cmake --install "$BUILD_DIR"

# Install helper
install -m 0755 -o root -g root "$SCRIPT_DIR/koretoggle-helper" /usr/lib/koretoggle-helper

# Install polkit policy
install -m 0644 -o root -g root "$SCRIPT_DIR/org.koretoggle.toggle.policy" /usr/share/polkit-1/actions/org.koretoggle.toggle.policy

echo "Done. QML plugin installed to /usr/lib/qt6/qml/org/koretoggle/runner/"
echo "      Helper installed to /usr/lib/koretoggle-helper"
echo "      Policy installed to /usr/share/polkit-1/actions/org.koretoggle.toggle.policy"
