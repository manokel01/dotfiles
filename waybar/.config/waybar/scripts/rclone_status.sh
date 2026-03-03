#!/bin/bash

FLAG_FILE="$HOME/.rclone_error"
INTERVAL=60 # Your sync interval in minutes

# Get the exact time the service last finished
LAST_SYNC=$(systemctl --user show rclone-sync.service --property=StateChangeTimestamp --value)
NOW_SEC=$(date +%s)

if [ -n "$LAST_SYNC" ] && [ "$LAST_SYNC" != "[not set]" ]; then
    LAST_SEC=$(date -d "$LAST_SYNC" +%s)
    
    # How many minutes ago was the last sync? (Manual or Automatic)
    DIFF=$(( (NOW_SEC - LAST_SEC) / 60 ))
    
    # How many minutes until the next one?
    NEXT_SYNC=$(( INTERVAL - DIFF ))
    
    # Catch any negative numbers in case the timer is a few seconds late
    [ "$NEXT_SYNC" -lt 0 ] && NEXT_SYNC=0
else
    DIFF="?"
    NEXT_SYNC="?"
fi

# --- STATE OUTPUTS ---

# Active Syncing State
if pgrep -x "rclone" > /dev/null; then
    echo "{\"text\": \"󰊭\", \"class\": \"syncing\", \"tooltip\": \"Syncing now...\"}"
    exit 0
fi

# Error State
if [ -f "$FLAG_FILE" ]; then
    echo "{\"text\": \"󰊭\", \"class\": \"error\", \"tooltip\": \"Sync failed $DIFF min ago. Next sync in $NEXT_SYNC min.\"}"
    exit 0
fi

# Success/Idle State
echo "{\"text\": \"󰊭\", \"class\": \"idle\", \"tooltip\": \"Synced $DIFF min ago. Next sync in $NEXT_SYNC min.\"}"