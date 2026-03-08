#!/bin/bash
cd "$HOME/dotfiles" || exit

# 1. Fetch quietly in the background, suppressing all lock errors from dual-monitor races
git fetch -q origin main > /dev/null 2>&1 &

# 2. Suppress stderr so index.lock errors don't trigger a false "dirty" state
STATUS=$(git status --porcelain 2>/dev/null)
LOCAL=$(git rev-parse @ 2>/dev/null)
REMOTE=$(git rev-parse "origin/main" 2>/dev/null)

ICON=""

sanitize() {
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g'
}

# 3. Strict condition checks to prevent empty variable misfires
if [[ -n "$STATUS" ]]; then
    DIRTY_FILES=$(echo "$STATUS" | sanitize)
    echo "{\"text\": \"$ICON\", \"tooltip\": \"󱈸 UNCOMMITTED CHANGES:\\n$DIRTY_FILES\", \"class\": \"dirty\"}"
elif [[ -n "$LOCAL" && -n "$REMOTE" && "$LOCAL" != "$REMOTE" ]]; then
    # We use @{u} as a shorthand for the upstream branch
    HISTORY=$(git log -3 --format="- %s (%ar)" @{u}..HEAD 2>/dev/null | sanitize)
    echo "{\"text\": \"$ICON\", \"tooltip\": \"󰇚 UNPUSHED COMMITS:\\n$HISTORY\", \"class\": \"unpushed\"}"
else
    # Default to clean if synced, or if a lock file forced the race to drop
    HISTORY=$(git log -3 --format="- %s (%ar)" 2>/dev/null | sanitize)
    echo "{\"text\": \"$ICON\", \"tooltip\": \"✅ SYNCED\\n$HISTORY\", \"class\": \"clean\"}"
fi