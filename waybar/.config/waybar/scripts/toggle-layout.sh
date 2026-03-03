#!/bin/bash
if [ "$1" == "next" ]; then
    hyprctl switchxkblayout all next > /dev/null
    pkill -RTMIN+1 waybar # This forces Waybar to refresh immediately
fi

LAYOUT=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap')

case "$LAYOUT" in
    "English (US)") echo "US" ;;
    "Greek")        echo "EL" ;;
    *)              echo "EL" ;; # Fallback for any Greek variation
esac