#!/bin/sh
# Launch the shell for a few seconds; fail on any warning/error or if config never loads.
dir="$(cd "$(dirname "$0")/.." && pwd)"
out="$(timeout 6 qs -p "$dir" --no-color 2>&1)"
if echo "$out" | grep -E 'WARN|ERROR'; then
  echo "smoke FAILED"
  exit 1
fi
echo "$out" | grep -q 'Configuration Loaded' || { echo "$out"; echo "smoke FAILED"; exit 1; }
echo "smoke ok"
