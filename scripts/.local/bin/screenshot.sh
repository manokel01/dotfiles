#!/bin/bash

# --- CONFIGURATION ---
# The folder where your permanent archives live
SAVE_DIR="$HOME/Pictures/Screenshots"
# The filename format (Year-Month-Day_Hour-Minute-Second)
FILENAME="Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"
FULL_PATH="$SAVE_DIR/$FILENAME"

# Ensure the directory exists
mkdir -p "$SAVE_DIR"

# --- THE COUNTDOWN ---
# Send a temporary notification so you know the timer started
notify-send -t 1000 "Screenshot" "Starting in 3 seconds... Get your menu ready!"
sleep 3

# --- THE CAPTURE ENGINE ---
# 1. slurp: Get the coordinates
# 2. grim: Grab the pixels
# 3. tee: Split the data stream to a file AND the clipboard
# 4. wl-copy: Receive the stream into RAM
GEOM=$(slurp -d)

# Check if user cancelled slurp (by pressing Esc)
if [ -z "$GEOM" ]; then
    notify-send "Screenshot" "Captured cancelled."
    exit 0
fi

grim -g "$GEOM" - | tee "$FULL_PATH" | wl-copy

# --- THE FINAL CONFIRMATION ---
notify-send -i "$FULL_PATH" "Screenshot Captured" "Saved to: $FILENAME\n& Copied to Clipboard"
