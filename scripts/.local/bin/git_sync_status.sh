#!/bin/bash
# Master Path: ~/dotfiles/scripts/.local/bin/git_sync_status.sh

DOTFILES_DIR="$HOME/dotfiles"
cd "$DOTFILES_DIR" || exit

# 1. Background fetch - keep it, but don't let it hang our check
git fetch -q origin main > /dev/null 2>&1 &

# 2. Wait for locks (up to 1 second)
# This prevents the "Fake Green" if git_sync_status runs while 'void' is still finishing
LOCK_TIMEOUT=0
while [ -f .git/index.lock ] && [ $LOCK_TIMEOUT -lt 5 ]; do
    sleep 0.2
    ((LOCK_TIMEOUT++))
done

# 3. Comprehensive Status Check
STATUS=$(git status --porcelain)
LOCAL=$(git rev-parse @ 2>/dev/null)
REMOTE=$(git rev-parse "origin/main" 2>/dev/null)

ICON=""

sanitize() {
    sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\\"/g' | sed ':a;N;$!ba;s/\n/\\n/g'
}

# 4. Logical Priority: Uncommitted -> Unpushed -> Synced
if [[ -n "$STATUS" ]]; then
    DIRTY_FILES=$(echo "$STATUS" | sanitize)
    echo "{\"text\": \"$ICON\", \"tooltip\": \"󱈸 UNCOMMITTED CHANGES:\\n$DIRTY_FILES\", \"class\": \"dirty\"}"
elif [[ -n "$LOCAL" && -n "$REMOTE" && "$LOCAL" != "$REMOTE" ]]; then
    # We have commits but they aren't on GitHub yet
    HISTORY=$(git log -3 --format="- %s (%ar)" origin/main..HEAD 2>/dev/null | sanitize)
    echo "{\"text\": \"$ICON\", \"tooltip\": \"󰇚 UNPUSHED COMMITS:\\n$HISTORY\", \"class\": \"unpushed\"}"
else
    # Everything is perfectly in sync
    HISTORY=$(git log -3 --format="- %s (%ar)" 2>/dev/null | sanitize)
    echo "{\"text\": \"$ICON\", \"tooltip\": \"✅ SYNCED\\n$HISTORY\", \"class\": \"clean\"}"
fi