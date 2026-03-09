#!/bin/bash

# --- 1. HANDLE THE CLICK ACTION ---
if [ "$1" == "next" ]; then
    hyprctl switchxkblayout all next > /dev/null 2>&1
    pkill -RTMIN+1 waybar
    exit 0
fi

# --- 2. FETCH THE ACTIVE KEYMAP ---
# We query Hyprland for the 'main' keyboard's current layout string
ACTIVE_KEYMAP=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap')

# --- 3. ROBUST WILDCARD MATCHING ---
# We only care if the word 'English' or 'Greek' exists in the string
if [[ "$ACTIVE_KEYMAP" == *"English"* ]]; then
    echo "EN"
elif [[ "$ACTIVE_KEYMAP" == *"Greek"* ]]; then
    echo "EL"
else
    # Fallback if something goes wrong
    echo "??"
fi
