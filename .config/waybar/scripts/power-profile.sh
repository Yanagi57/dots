#!/bin/bash
# Waybar power-profiles-daemon module
# Usage: power-profile.sh          -> JSON output for waybar
#        power-profile.sh --pick   -> wofi picker, then set profile

PROFILES=("power-saver" "balanced" "performance")

get_icon() {
  case "$1" in
    power-saver) echo "󰾆" ;;
    balanced)    echo "󰾅" ;;
    performance) echo "󱐋" ;;
    *)           echo "?" ;;
  esac
}

if [[ "$1" == "--pick" ]]; then
  MENU=$(for p in "${PROFILES[@]}"; do
    icon=$(get_icon "$p")
    echo "$icon  $p"
  done)

  CHOICE=$(echo "$MENU" | wofi --dmenu --prompt "Power Profile" --width 360 --height 280 --lines 4)
  [[ -z "$CHOICE" ]] && exit 0

  PROFILE=$(echo "$CHOICE" | awk '{print $NF}')
  powerprofilesctl set "$PROFILE"
else
  CURRENT=$(powerprofilesctl get)
  ICON=$(get_icon "$CURRENT")
  printf '{"text":"%s","alt":"%s","tooltip":"Power profile: %s","class":"%s"}\n' \
    "$ICON  $CURRENT" "$CURRENT" "$CURRENT" "$CURRENT"
fi
