#!/bin/bash
# Native Void: Interactive Sync UI + Fast-List (Human Readable V2)

REMOTE="gdrive_manokel:"
LOCAL="$HOME/gdrive-manokel"
DRY_LOG="/tmp/rclone_sync_dry.log"
FLAG_PENDING="$HOME/.rclone_pending_review"
FLAG_ERROR="$HOME/.rclone_error"
LOG_FILE="$LOCAL/.logs/sync_$(date +%Y%m%d_%H%M%S).log"

echo "VOID: Performing dry-run audit..."
echo "------------------------------------------------"

# 1. Run the Dry-Run and save to temp log
/usr/bin/rclone bisync "$REMOTE" "$LOCAL" \
    --dry-run --resilient --fast-list --drive-acknowledge-abuse \
    --exclude ".logs/**" --exclude ".venv/**" --exclude "*/__pycache__/**" --exclude "*.pyc" \
    --verbose > "$DRY_LOG" 2>&1

# 2. Parse paths using bulletproof regex (ignores spaces/hyphens)
echo -e "\e[31m🔴 DELETIONS PENDING:\e[0m"
grep -a -i "Queue delete" "$DRY_LOG" | sed -E 's/.*(gdrive_manokel.*)/  [Laptop -> Cloud] Queued to delete: \1/; s/.*(\/home\/.*)/  [Cloud -> Laptop] Queued to delete: \1/' || echo "  None"
echo ""

echo -e "\e[32m🟢 COPIES/ADDITIONS PENDING:\e[0m"
grep -a -i "Queue copy" "$DRY_LOG" | sed -E 's/.*(gdrive_manokel.*)/  [Laptop -> Cloud] Queued to copy: \1/; s/.*(\/home\/.*)/  [Cloud -> Laptop] Queued to copy: \1/' || echo "  None"
echo ""

echo -e "\e[33m🟡 UPDATES PENDING:\e[0m"
grep -a -i "Queue update" "$DRY_LOG" | sed -E 's/.*(gdrive_manokel.*)/  [Laptop -> Cloud] Queued to update: \1/; s/.*(\/home\/.*)/  [Cloud -> Laptop] Queued to update: \1/' || echo "  None"
echo "------------------------------------------------"

# 3. The Ghost Flag Trap
CHANGE_COUNT=$(grep -a -iE "Queue copy|Queue delete|Queue update" "$DRY_LOG" | wc -l)

if [ "$CHANGE_COUNT" -eq 0 ]; then
    echo -e "\nVOID: Audit confirmed zero changes. Clearing ghost flag..."
    rm -f "$FLAG_PENDING" "$FLAG_ERROR"
    pkill -RTMIN+10 waybar
    sleep 1.5
    exit 0
fi

if mountpoint -q /run/media/manokel/t7_ext4; then
    echo -e "STATUS: \e[32m✓ T7_EXT4 CONNECTED\e[0m"
else
    echo -e "STATUS: \e[33m⚠️ T7_EXT4 DISCONNECTED\e[0m (Mirror will be skipped)"
fi

read -t 60 -p "VOID: Approve these changes? (y/N) [60s timeout]: " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "VOID: Executing Two-Way Sync..."
    if /usr/bin/rclone bisync "$REMOTE" "$LOCAL" \
        --resilient --fast-list \
        --exclude ".logs/**" --exclude ".venv/**" --exclude "*/__pycache__/**" --exclude "*.pyc" \
        --verbose >> "$LOG_FILE" 2>&1; then
        rm -f "$FLAG_PENDING" "$FLAG_ERROR"
        pkill -RTMIN+10 waybar
    else
        touch "$FLAG_ERROR"
        pkill -RTMIN+10 waybar
        echo "Error: Sync failed. Check logs."
        sleep 3
    fi
else
    echo "Aborted."
    sleep 1
fi
