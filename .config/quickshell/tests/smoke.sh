#!/bin/sh
# Launch the shell for a few seconds; fail on any warning/error or if config never loads.
dir="$(cd "$(dirname "$0")/.." && pwd)"
out="$(timeout 6 qs -p "$dir" --no-color 2>&1)"
# quickshell.dbus.properties: external D-Bus services (e.g. playerctld with no player) — not our code
# quickshell.dbus.objectmanager org.bluez: bluetoothd not running — external, not our code
# quickshell.service.notifications register/retry warnings: the running main instance already owns org.freedesktop.Notifications
if echo "$out" | grep -E 'WARN|ERROR' | grep -v 'quickshell.dbus.properties' | grep -v 'DBusObjectManagerInterface for "org.bluez"' \
   | grep -v -E 'Could not register notification server at org.freedesktop.Notifications|Registration will be attempted again if the active service is unregistered'; then
  echo "smoke FAILED"
  exit 1
fi
echo "$out" | grep -q 'Configuration Loaded' || { echo "$out"; echo "smoke FAILED"; exit 1; }
echo "smoke ok"
