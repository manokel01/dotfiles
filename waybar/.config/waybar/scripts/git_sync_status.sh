#!/bin/bash
cd "$HOME/dotfiles" || exit

# 1. Fetch from the remote in the background so it doesn't lag your bar
git fetch -q origin main &

# 2. Force git to refresh the index (clears out the [✘!] if files were just touched)
git update-index -q --refresh

# 3. Use 'origin/main' specifically for REMOTE to see what the server has
UPSTREAM='origin/main'
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "$UPSTREAM")

ICON=""

# Function to escape special characters for Pango/Waybar tooltips
# 1. Escapes &, <, and > to prevent Pango Markup errors
# 2. Escapes " to prevent JSON breakage
# 3. Replaces real newlines with \n for Waybar JSON format
sanitize() {
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g'
}

if [[ -n $(git status -s) ]]; then
    # Show dirty files in tooltip
    DIRTY_FILES=$(git status -s | sanitize)
    echo "{\"text\": \"$ICON\", \"tooltip\": \"󱈸 UNCOMMITTED CHANGES:\\n$DIRTY_FILES\", \"class\": \"dirty\"}"
elif [ "$LOCAL" != "$REMOTE" ]; then
    # Show unpushed commits in tooltip
    HISTORY=$(git log -3 --format="- %s (%ar)" | sanitize)
    echo "{\"text\": \"$ICON\", \"tooltip\": \"󰇚 UNPUSHED COMMITS:\\n$HISTORY\", \"class\": \"unpushed\"}"
else
    # Show last 3 syncs in tooltip
    HISTORY=$(git log -3 --format="- %s (%ar)" | sanitize)
    echo "{\"text\": \"$ICON\", \"tooltip\": \"✅ SYNCED\\n$HISTORY\", \"class\": \"clean\"}"
fi