#!/bin/bash

# 1. Run dnf check-update and count the lines
# dnf check-update returns 100 if updates are available, 0 if not.
# We grep for actual package lines and count them.
UPDATES=$(dnf check-update -q | grep -c '^\S' | xargs)

# 2. Check if updates exist
if [ "$UPDATES" -gt 0 ]; then
    # Output JSON for Waybar
    # Icon: 󰚰 (Update icon)
    echo "{\"text\": \"󰚰 $UPDATES\", \"tooltip\": \"$UPDATES updates available. Click to upgrade.\", \"class\": \"updates\"}"
else
    # Output nothing if system is clean to keep the bar minimal
    echo "{\"text\": \"\", \"tooltip\": \"System up to date\", \"class\": \"clean\"}"
fi
