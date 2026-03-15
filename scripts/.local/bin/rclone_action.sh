#!/bin/bash
# Native Void: Interactive Sync Trigger

# Run the sync script inside a floating kitty window
kitty --class sync_floats -e /home/manokel/.local/bin/rclone_sync.sh

# Force Waybar refresh after terminal closes
pkill -RTMIN+10 waybar
