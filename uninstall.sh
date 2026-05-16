#!/bin/bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Run with sudo: sudo ./uninstall.sh" >&2
    exit 1
fi

rm -f /usr/lib/koretoggle-helper
rm -f /usr/share/polkit-1/actions/org.koretoggle.toggle.policy
rm -rf /usr/lib/qt6/qml/org/koretoggle

echo "Removed /usr/lib/koretoggle-helper"
echo "Removed /usr/share/polkit-1/actions/org.koretoggle.toggle.policy"
echo "Removed /usr/lib/qt6/qml/org/koretoggle/"
