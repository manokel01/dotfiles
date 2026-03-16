#!/bin/bash
# Native Void: Guarded Two-Way Sync (Bisync)
# Logic: Audit -> User Review -> Two-Way Sync -> T7 Mirror

REMOTE="gdrive_manokel:"
LOCAL="$HOME/gdrive-manokel"
T7_PATH="/run/media/manokel/t7_ext4/gdrive-manokel"
LOG_DIR="$LOCAL/.logs"
LOG_FILE="$LOG_DIR/sync_$(date +%Y%m%d_%H%M%S).log"
DRY_RUN_LOG="/tmp/rclone_dry_run.log"
FLAG_FILE="$HOME/.rclone_error"

mkdir -p "$LOG_DIR"
rm -f "$FLAG_FILE" # Clear error flag at start

echo "VOID: Performing dry-run audit..."

# --- 1. THE DRY RUN ---
rclone bisync "$REMOTE" "$LOCAL" \
    --dry-run \
    --resilient \
    --drive-acknowledge-abuse \
    --drive-export-formats docx,xlsx,pptx \
    --drive-import-formats docx,xlsx,pptx \
    --fix-case \
    --compare size,modtime,checksum \
    --exclude ".logs/**" \
    --verbose > "$DRY_RUN_LOG" 2>&1

# --- 2. THE REVIEW ---
echo -e "------------------------------------------"
echo -e "🔴 TO DELETE:"
grep -E -i 'Not deleting|would delete' "$DRY_RUN_LOG" || echo "None"
echo -e "\n🟢 TO ADD/COPY:"
grep -E -i 'Not copying|would copy' "$DRY_RUN_LOG" || echo "None"
echo -e "\n🟡 TO UPDATE:"
grep -E -i 'Not updating|would update' "$DRY_RUN_LOG" || echo "None"
echo -e "------------------------------------------"

# --- 3. HARDWARE PRE-CHECK ---
if mountpoint -q /run/media/manokel/t7_ext4; then
    T7_STATUS="✅ T7_EXT4 CONNECTED"
else
    T7_STATUS="⚠️  T7_EXT4 DISCONNECTED (Mirror will be skipped)"
fi

# --- 4. THE CONFIRMATION (60s Timeout) ---
echo -e "\nSTATUS: $T7_STATUS"
echo -n "VOID: Approve these changes? (y/N) [60s timeout]: "
if read -r -t 60 user_input; then
    if [[ ! "$user_input" =~ ^[Yy]$ ]]; then
        echo "VOID: Sync aborted by user."
        exit 1
    fi
else
    echo -e "\nVOID: Timeout. Sync aborted."
    exit 1
fi

# --- 5. THE ACTUAL SYNC ---
rm -f "$HOME/.rclone_pending_review"

echo "VOID: Executing Two-Way Sync..."
if rclone bisync "$REMOTE" "$LOCAL" \
    --resilient \
    --drive-acknowledge-abuse \
    --drive-export-formats docx,xlsx,pptx \
    --drive-import-formats docx,xlsx,pptx \
    --fix-case \
    --compare size,modtime,checksum \
    --exclude ".logs/**" \
    --verbose >> "$LOG_FILE" 2>&1; then
    
    # --- 6. THE HARDWARE MIRROR ---
    if mountpoint -q /run/media/manokel/t7_ext4; then
        echo "VOID: Mirroring to T7..."
        rclone sync "$LOCAL" "$T7_PATH" --exclude ".logs/**" --verbose >> "$LOG_FILE" 2>&1
        notify-send "Void Sync" "Cloud and T7 updated successfully."
    else
        notify-send "Void Sync" "Cloud updated. T7 missing."
    fi
else
    echo "ERROR" > "$FLAG_FILE"
    notify-send "Void Sync" "FAILED. Check logs."
    exit 1
fi

pkill -RTMIN+10 waybar # Refresh icon
