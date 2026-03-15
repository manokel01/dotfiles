#!/bin/bash

FLAG_FILE="$HOME/.rclone_error"
LOG_DIR="$HOME/gdrive-manokel/.logs"
INTERVAL=60 # Your desired manual sync interval in minutes
NOW_SEC=$(date +%s)

# Get the exact time of the most recent log file
LATEST_LOG=$(ls -t "$LOG_DIR"/sync_*.log 2>/dev/null | head -n 1)

if [ -n "$LATEST_LOG" ]; then
    LAST_SEC=$(stat -c %Y "$LATEST_LOG")
    DIFF=$(( (NOW_SEC - LAST_SEC) / 60 ))
    NEXT_SYNC=$(( INTERVAL - DIFF ))
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
    echo "{\"text\": \"󰊭\", \"class\": \"error\", \"tooltip\": \"Sync FAILED $DIFF min ago. Check logs!\"}"
    exit 0
fi

# Success/Idle State
echo "{\"text\": \"󰊭\", \"class\": \"idle\", \"tooltip\": \"Synced $DIFF min ago. Next sync in $NEXT_SYNC min.\"}"
