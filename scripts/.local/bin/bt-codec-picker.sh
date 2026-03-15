#!/bin/bash
# Native Void Codec Picker v4 (Tagged & Mapped)

CARD=$(pactl list cards short | grep bluez | awk '{print $2}' | head -n 1)

if [ -z "$CARD" ]; then
    notify-send "Bluetooth" "No active Bluetooth device found."
    exit 1
fi

# 1. Get the currently active profile exactly as Pipewire sees it
ACTIVE=$(pactl list cards | grep -A 40 "$CARD" | grep "Active Profile:" | awk '{print $3}')

# 2. Extract raw profiles (filtering out the "Active Profile" text line itself)
RAW_PROFILES=$(pactl list cards | grep -A 40 "$CARD" | grep -E "a2dp-sink|headset-head-unit" | grep -v "available: no" | grep -v "Active Profile" | awk -F: '{print $1}' | sed 's/^[ \t]*//' | sort -u)

# 3. Build the Rofi menu dynamically
MENU=""
for p in $RAW_PROFILES; do
    display_name="$p"
    
    # Map the raw aptX HD profile for better readability
    if [ "$p" == "a2dp-sink" ]; then
        display_name="a2dp-sink-aptx-hd"
    fi

    # Tag the active profile
    if [ "$p" == "$ACTIVE" ]; then
        MENU="$MENU\n[Active] $display_name"
    else
        MENU="$MENU\n$display_name"
    fi
done

# Clean up leading empty lines
MENU=$(echo -e "$MENU" | sed '/^$/d')

# 4. Prompt Rofi
SELECTED=$(echo -e "$MENU" | rofi -dmenu -i -p "󰡁 Codec")
[ -z "$SELECTED" ] && exit

# 5. Clean the selection and map it back for Pipewire
CLEAN_SEL=$(echo "$SELECTED" | sed 's/\[Active\] //')

if [ "$CLEAN_SEL" == "a2dp-sink-aptx-hd" ]; then
    TARGET_PROFILE="a2dp-sink"
else
    TARGET_PROFILE="$CLEAN_SEL"
fi

# 6. Apply
pactl set-card-profile "$CARD" "$TARGET_PROFILE"
notify-send "Bluetooth" "Switched to: $CLEAN_SEL"
