#!/bin/bash
# Native Void: Absolute Final Hardened Sync

REMOTE="gdrive_manokel:"
LOCAL="$HOME/gdrive-manokel"
LOG_DIR="$LOCAL/.logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/sync_$(date +%Y%m%d_%H%M%S).log"
DRY_LOG="/tmp/rclone_cloud_dry.log"
FLAG_PENDING="$HOME/.rclone_pending_review"
FLAG_ERROR="$HOME/.rclone_error"

TARGETS=(
    "t7_ext4|/run/media/manokel/t7_ext4|ext4"
    "t7_exfat|/run/media/manokel/t7_exfat|exfat"
    "exfat_M3|/run/media/manokel/exfat_M3|exfat"
)

# --- PHASE 1: CLOUD ---
echo "VOID: Performing Cloud (Two-Way) dry-run..."
/usr/bin/rclone bisync "$REMOTE" "$LOCAL" \
    --dry-run --resilient --fast-list --drive-acknowledge-abuse \
    --exclude ".logs/**" --exclude "**/.venv/**" --exclude "*/__pycache__/**" --exclude "*.pyc" \
    --verbose > "$DRY_LOG" 2>&1

echo "------------------------------------------------"
echo -e "\e[31m🔴 CLOUD DELETIONS PENDING:\e[0m"
grep -a -i "Queue delete" "$DRY_LOG" | sed -E 's/.*(gdrive_manokel.*)/  [Laptop -> Cloud] Queued to delete: \1/; s/.*(\/home\/.*)/  [Cloud -> Laptop] Queued to delete: \1/' || echo "  None"
echo ""
echo -e "\e[32m🟢 CLOUD COPIES/ADDITIONS PENDING:\e[0m"
grep -a -i "Queue copy" "$DRY_LOG" | sed -E 's/.*(gdrive_manokel.*)/  [Laptop -> Cloud] Queued to copy: \1/; s/.*(\/home\/.*)/  [Cloud -> Laptop] Queued to copy: \1/' || echo "  None"
echo ""
echo -e "\e[33m🟡 CLOUD UPDATES PENDING:\e[0m"
grep -a -i "Queue update" "$DRY_LOG" | sed -E 's/.*(gdrive_manokel.*)/  [Laptop -> Cloud] Queued to update: \1/; s/.*(\/home\/.*)/  [Cloud -> Laptop] Queued to update: \1/' || echo "  None"
echo "------------------------------------------------"

CLOUD_CHANGES=$(grep -a -iE "Queue copy|Queue delete|Queue update" "$DRY_LOG" | wc -l)

if [ "$CLOUD_CHANGES" -gt 0 ]; then
    read -t 60 -p "VOID: Execute Cloud Sync? (y/N) [60s timeout]: " cloud_confirm
    if [[ "$cloud_confirm" =~ ^[Yy]$ ]]; then
        echo "VOID: Syncing Cloud..."
        if /usr/bin/rclone bisync "$REMOTE" "$LOCAL" \
            --resilient --fast-list \
            --exclude ".logs/**" --exclude "**/.venv/**" --exclude "*/__pycache__/**" --exclude "*.pyc" \
            --verbose --log-file="$LOG_FILE"; then
            rm -f "$FLAG_PENDING" "$FLAG_ERROR"
        else
            touch "$FLAG_ERROR"
        fi
    fi
else
    echo -e "\nVOID: No Cloud changes. Clearing ghost flag..."
    rm -f "$FLAG_PENDING" "$FLAG_ERROR"
fi

# --- PHASE 2: DETECT MIRROR TARGETS ---
echo -e "\n------------------------------------------------"
echo "VOID: Detecting Mirror Targets..."
AVAILABLE=()
for t in "${TARGETS[@]}"; do
    IFS='|' read -r label path type <<< "$t"
    mountpoint -q "$path" && AVAILABLE+=("$t")
done

if [ ${#AVAILABLE[@]} -eq 0 ]; then
    echo -e "\e[33mNo target drives connected. Exiting.\e[0m"
    pkill -RTMIN+10 waybar && sleep 1.5 && exit 0
fi

echo "Connected Targets:"
for i in "${!AVAILABLE[@]}"; do
    IFS='|' read -r label path type <<< "${AVAILABLE[$i]}"
    echo "$((i+1))) $label ($type) -> $path"
done
echo "a) All of them | s) Skip"

read -p "Select Target(s) (e.g. '1 2'): " -a choices
TARGET_QUEUE=()
if [[ "${choices[0]}" == "a" ]]; then
    TARGET_QUEUE=("${AVAILABLE[@]}")
elif [[ "${choices[0]}" == "s" || -z "${choices[0]}" ]]; then
    pkill -RTMIN+10 waybar && exit 0
else
    for choice in "${choices[@]}"; do
        [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -le "${#AVAILABLE[@]}" ] && TARGET_QUEUE+=("${AVAILABLE[choice-1]}")
    done
fi

# --- PHASE 3: EXECUTE MIRRORS ---
for t in "${TARGET_QUEUE[@]}"; do
    IFS='|' read -r label path type <<< "$t"
    DEST_PATH="$path/gdrive-manokel"
    mkdir -p "$DEST_PATH"
    
    # Base flags - Remove --local-encoding from here
    # Added --skip-links because exFAT cannot store them and you manage them via GitHub
    FLAGS="--fast-list --progress --skip-links --exclude .logs/** --exclude **/.venv/** --exclude */__pycache__/** --exclude *.pyc --verbose --log-file=$LOG_FILE"
    
    FINAL_DEST="$DEST_PATH"

    if [ "$type" == "exfat" ]; then
        # Use only valid Rclone keywords (Removed DotDot/LessThan/etc based on your terminal help output)
        ENCODING="Slash,Dot,Ctl,Colon,Question,Asterisk,Pipe,BackSlash,LtGt,DoubleQuote"
        
        # Attach the encoding surgically to the destination ONLY
        FINAL_DEST=":local,encoding='$ENCODING':$DEST_PATH"
        FLAGS="$FLAGS --modify-window 1s"
    fi

    echo -e "\n\e[34m🔵 VOID: Mirroring Laptop -> $label...\e[0m"
    if /usr/bin/rclone sync "$LOCAL" "$FINAL_DEST" $FLAGS; then
         echo -e "\e[32mSTATUS: $label Mirror Complete.\e[0m"
    else
         echo -e "\e[31mError: $label Mirror failed. Check logs.\e[0m"
         touch "$FLAG_ERROR"
    fi
done

# --- PHASE 4: THE PERSISTENT HOLD ---
pkill -RTMIN+10 waybar
if [ -f "$FLAG_ERROR" ]; then
    echo -e "\n\e[41m\e[37m ⚠️ ERROR DETECTED \e[0m"
    echo "Check log: $LOG_FILE"
    read -p "Press any key to close..." -n 1 -s
else
    echo -e "\n\e[32m✔ All operations finished successfully.\e[0m"
    sleep 2
fi
