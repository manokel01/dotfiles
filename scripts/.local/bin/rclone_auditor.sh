#!/bin/bash
# Native Void: Hardened Auditor (Text-Parsing Logic) + Fast-List

REMOTE="gdrive_manokel:"
LOCAL="$HOME/gdrive-manokel"
FLAG_ERROR="$HOME/.rclone_error"
FLAG_PENDING="$HOME/.rclone_pending_review"

# 1. READ THE OUTPUT, IGNORE EXIT CODES
CHECK_OUTPUT=$(/usr/bin/rclone check "$LOCAL" "$REMOTE" --one-way --fast-list --exclude ".logs/**" 2>&1)

# 2. TEXT-PARSING DECISION ENGINE
if echo "$CHECK_OUTPUT" | grep -q "0 differences found"; then
    rm -f "$FLAG_ERROR" "$FLAG_PENDING"
    pkill -RTMIN+10 waybar
    exit 0
elif echo "$CHECK_OUTPUT" | grep -q "differences found"; then
    touch "$FLAG_PENDING"
    notify-send -u normal "Void Sync" "Changes detected. Click icon to review/sync."
    pkill -RTMIN+10 waybar
    exit 0
else
    touch "$FLAG_ERROR"
    pkill -RTMIN+10 waybar
    exit 1
fi
