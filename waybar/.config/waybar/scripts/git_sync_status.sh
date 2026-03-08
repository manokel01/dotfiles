#!/bin/bash
cd "$HOME/dotfiles" || exit

# 1. Fetch from the remote (quietly)
git fetch -q origin main &

# 2. Check for changes using porcelain (designed for scripts)
# This ignores 'ghost' index refreshes
STATUS=$(git status --porcelain)
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "origin/main")

ICON=""

sanitize() {
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g'
}

if [[ -n "$STATUS" ]]; then
    DIRTY_FILES=$(echo "$STATUS" | sanitize)
    echo "{\"text\": \"$ICON\", \"tooltip\": \"󱈸 UNCOMMITTED CHANGES:\\n$DIRTY_FILES\", \"class\": \"dirty\"}"
elif [ "$LOCAL" != "$REMOTE" ]; then
    # We use @{u} as a shorthand for the upstream branch
    HISTORY=$(git log -3 --format="- %s (%ar)" @{u}..HEAD | sanitize)
    echo "{\"text\": \"$ICON\", \"tooltip\": \"󰇚 UNPUSHED COMMITS:\\n$HISTORY\", \"class\": \"unpushed\"}"
else
    HISTORY=$(git log -3 --format="- %s (%ar)" | sanitize)
    echo "{\"text\": \"$ICON\", \"tooltip\": \"✅ SYNCED\\n$HISTORY\", \"class\": \"clean\"}"
fi
