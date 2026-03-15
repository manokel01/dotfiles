#!/bin/bash

FLAG_ERROR="$HOME/.rclone_error"
FLAG_PENDING="$HOME/.rclone_pending_review"
LOG_DIR="$HOME/gdrive-manokel/.logs"
NOW_SEC=$(date +%s)

LATEST_LOG=$(ls -t "$LOG_DIR"/sync_*.log 2>/dev/null | head -n 1)

if [ -n "$LATEST_LOG" ]; then
    LAST_SEC=$(stat -c %Y "$LATEST_LOG")
    DIFF=$(( (NOW_SEC - LAST_SEC) / 60 ))
else
    DIFF="?"
fi

# Active Syncing State
if pgrep -x "rclone" > /dev/null; then
    echo "{\"text\": \"󰊭\", \"class\": \"syncing\", \"tooltip\": \"Syncing now...\"}"
    exit 0
fi

# Error State
if [ -f "$FLAG_ERROR" ]; then
    echo "{\"text\": \"󰊭\", \"class\": \"error\", \"tooltip\": \"Sync FAILED $DIFF min ago. Check logs!\"}"
    exit 0
fi

# Pending Review State (The Guarded Interrupt)
if [ -f "$FLAG_PENDING" ]; then
    echo "{\"text\": \"󰊭\", \"class\": \"pending\", \"tooltip\": \"Action Required: Pending Deletions/Updates! Click to review.\"}"
    exit 0
fi

# Success/Idle State
echo "{\"text\": \"󰊭\", \"class\": \"idle\", \"tooltip\": \"Synced $DIFF min ago. Auto-audit active.\"}"
