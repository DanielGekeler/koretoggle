#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $EUID -ne 0 ]]; then
    echo "Run with sudo: sudo ./install.sh" >&2
    exit 1
fi

install -m 0755 -o root -g root "$SCRIPT_DIR/koretoggle-helper" /usr/lib/koretoggle-helper
install -m 0644 -o root -g root "$SCRIPT_DIR/org.koretoggle.toggle.policy" /usr/share/polkit-1/actions/org.koretoggle.toggle.policy

echo "Done. Helper installed to /usr/lib/koretoggle-helper"
echo "      Policy installed to /usr/share/polkit-1/actions/org.koretoggle.toggle.policy"
