#!/bin/bash
# Native Void: Split-Brain Sync UI (Cloud Bisync + T7 Absolute Mirror)

REMOTE="gdrive_manokel:"
LOCAL="$HOME/gdrive-manokel"
T7_MOUNT="/run/media/manokel/t7_ext4"
T7_DEST="$T7_MOUNT/gdrive-manokel"
DRY_LOG="/tmp/rclone_sync_dry.log"
T7_DRY_LOG="/tmp/rclone_t7_dry.log"
FLAG_PENDING="$HOME/.rclone_pending_review"
FLAG_ERROR="$HOME/.rclone_error"
LOG_FILE="$LOCAL/.logs/sync_$(date +%Y%m%d_%H%M%S).log"

echo "VOID: Performing Cloud (Two-Way) dry-run..."
/usr/bin/rclone bisync "$REMOTE" "$LOCAL" \
    --dry-run --resilient --fast-list --drive-acknowledge-abuse \
    --exclude ".logs/**" --exclude ".venv/**" --exclude "*/__pycache__/**" --exclude "*.pyc" \
    --verbose > "$DRY_LOG" 2>&1

T7_CONNECTED=false
if mountpoint -q "$T7_MOUNT"; then
    T7_CONNECTED=true
    echo "VOID: Performing T7 (Absolute Mirror) dry-run..."
    /usr/bin/rclone sync "$LOCAL" "$T7_DEST" \
        --dry-run --fast-list \
        --exclude ".logs/**" --exclude ".venv/**" --exclude "*/__pycache__/**" --exclude "*.pyc" \
        --verbose > "$T7_DRY_LOG" 2>&1
fi

echo "------------------------------------------------"
echo -e "\e[31m🔴 CLOUD DELETIONS PENDING:\e[0m"
grep -a -i "Queue delete" "$DRY_LOG" | sed -E 's/.*(gdrive_manokel.*)/  [Laptop -> Cloud] Queued to delete: \1/; s/.*(\/home\/.*)/  [Cloud -> Laptop] Queued to delete: \1/' || echo "  None"
echo ""

echo -e "\e[32m🟢 CLOUD COPIES/ADDITIONS PENDING:\e[0m"
grep -a -i "Queue copy" "$DRY_LOG" | sed -E 's/.*(gdrive_manokel.*)/  [Laptop -> Cloud] Queued to copy: \1/; s/.*(\/home\/.*)/  [Cloud -> Laptop] Queued to copy: \1/' || echo "  None"
echo ""

echo -e "\e[33m🟡 CLOUD UPDATES PENDING:\e[0m"
grep -a -i "Queue update" "$DRY_LOG" | sed -E 's/.*(gdrive_manokel.*)/  [Laptop -> Cloud] Queued to update: \1/; s/.*(\/home\/.*)/  [Cloud -> Laptop] Queued to update: \1/' || echo "  None"

if [ "$T7_CONNECTED" = true ]; then
    echo "------------------------------------------------"
    echo -e "\e[34m🔵 T7 ABSOLUTE MIRROR PENDING (Laptop -> T7):\e[0m"
    # rclone sync dry-run uses "Not deleting" and "Not copying" syntax
    grep -a -i "Not deleting" "$T7_DRY_LOG" | sed -E 's/.*: (.*): Not deleting.*/  [Mirror] Queued to delete: \1/' || echo "  None"
    grep -a -i "Not copying" "$T7_DRY_LOG" | sed -E 's/.*: (.*): Not copying.*/  [Mirror] Queued to copy\/update: \1/' || echo "  None"
else
    echo "------------------------------------------------"
    echo -e "\e[33m⚠️ T7_EXT4 DISCONNECTED\e[0m (Mirror will be skipped)"
fi
echo "------------------------------------------------"

# Ghost Flag Trap (Counts both Cloud and T7 changes)
CLOUD_CHANGES=$(grep -a -iE "Queue copy|Queue delete|Queue update" "$DRY_LOG" | wc -l)
T7_CHANGES=0
if [ "$T7_CONNECTED" = true ]; then
    T7_CHANGES=$(grep -a -iE "Not copying|Not deleting" "$T7_DRY_LOG" | wc -l)
fi
TOTAL_CHANGES=$((CLOUD_CHANGES + T7_CHANGES))

if [ "$TOTAL_CHANGES" -eq 0 ]; then
    echo -e "\nVOID: Audit confirmed zero changes. Clearing ghost flag..."
    rm -f "$FLAG_PENDING" "$FLAG_ERROR"
    pkill -RTMIN+10 waybar
    sleep 1.5
    exit 0
fi

read -t 60 -p "VOID: Approve these changes? (y/N) [60s timeout]: " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "VOID: Executing Cloud Two-Way Sync..."
    if /usr/bin/rclone bisync "$REMOTE" "$LOCAL" \
        --resilient --fast-list \
        --exclude ".logs/**" --exclude ".venv/**" --exclude "*/__pycache__/**" --exclude "*.pyc" \
        --verbose >> "$LOG_FILE" 2>&1; then
        
        if [ "$T7_CONNECTED" = true ]; then
            echo "VOID: Executing T7 Absolute Mirror..."
            if /usr/bin/rclone sync "$LOCAL" "$T7_DEST" \
                --fast-list \
                --exclude ".logs/**" --exclude ".venv/**" --exclude "*/__pycache__/**" --exclude "*.pyc" \
                --verbose >> "$LOG_FILE" 2>&1; then
                echo -e "\e[32mSTATUS: T7 Mirror Complete.\e[0m"
            else
                echo -e "\e[31mError: T7 Mirror failed. Check logs.\e[0m"
                touch "$FLAG_ERROR"
            fi
        fi

        # Clean flags if successful
        rm -f "$FLAG_PENDING"
        if [ ! -f "$FLAG_ERROR" ]; then
            rm -f "$FLAG_ERROR"
        fi
        pkill -RTMIN+10 waybar
        sleep 1
    else
        touch "$FLAG_ERROR"
        pkill -RTMIN+10 waybar
        echo -e "\e[31mError: Cloud Sync failed. Check logs.\e[0m"
        sleep 3
    fi
else
    echo "Aborted."
    sleep 1
fi
