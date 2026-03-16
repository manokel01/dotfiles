#!/bin/bash
# Native Void: Silent Auditor & Auto-Committer

REMOTE="gdrive_manokel:"
LOCAL="$HOME/gdrive-manokel"
T7_PATH="/run/media/manokel/t7_ext4/gdrive-manokel"
LOG_DIR="$LOCAL/.logs"
LOG_FILE="$LOG_DIR/sync_$(date +%Y%m%d_%H%M%S).log"
DRY_RUN_LOG="/tmp/rclone_auditor_dry_run.log"
FLAG_ERROR="$HOME/.rclone_error"
FLAG_PENDING="$HOME/.rclone_pending_review"

mkdir -p "$LOG_DIR"

# 1. THE SILENT DRY RUN
/usr/bin/rclone bisync "$REMOTE" "$LOCAL" \
    --dry-run --resilient --drive-acknowledge-abuse \
    --drive-export-formats docx,xlsx,pptx --drive-import-formats docx,xlsx,pptx \
    --fix-case --compare size,modtime,checksum --exclude ".logs/**" \
    --verbose > "$DRY_RUN_LOG" 2>&1

# 2. THE DESTRUCTIVE CHECK (Gatekeeper)
# Look for "delete" or "update" in the queue
if grep -i -q -E "Queue (delete|update)" "$DRY_RUN_LOG"; then
    touch "$FLAG_PENDING"
    notify-send -u normal "Void Sync" "Manual review required. Destructive changes pending."
    pkill -RTMIN+10 waybar
    exit 0
fi

# 3. THE SAFE AUTO-COMMIT (Only Adds/Copies)
# If we see a "Queue copy", we proceed with the background sync
if ! grep -i -q "Queue copy" "$DRY_RUN_LOG"; then
    exit 0 # Nothing changed, exit silently
fi

# Execute silent sync
if /usr/bin/rclone bisync "$REMOTE" "$LOCAL" \
    --resilient --drive-acknowledge-abuse \
    --drive-export-formats docx,xlsx,pptx --drive-import-formats docx,xlsx,pptx \
    --fix-case --compare size,modtime,checksum --exclude ".logs/**" \
    --verbose >> "$LOG_FILE" 2>&1; then
    
    rm -f "$FLAG_ERROR" "$FLAG_PENDING"
    
    # Hardware mirror
    if mountpoint -q /run/media/manokel/t7_ext4; then
        /usr/bin/rclone sync "$LOCAL" "$T7_PATH" --exclude ".logs/**" --verbose >> "$LOG_FILE" 2>&1
    fi
else
    touch "$FLAG_ERROR"
    notify-send -u critical "Void Sync" "Background sync failed. Check logs."
fi

pkill -RTMIN+10 waybar
