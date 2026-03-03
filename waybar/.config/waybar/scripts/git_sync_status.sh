#!/bin/bash
cd "$HOME/dotfiles" || exit
git update-index -q --refresh

UPSTREAM=${1:-'@{u}'}
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "$UPSTREAM")

# Get the last 3 commit messages for the tooltip
HISTORY=$(git log -3 --format="- %s (%ar)" | sed ':a;N;$!ba;s/\n/\\n/g')
ICON=""

if [[ -n $(git status -s) ]]; then
    # Show which files are actually dirty in the tooltip
    DIRTY_FILES=$(git status -s | sed ':a;N;$!ba;s/\n/\\n/g')
    echo "{\"text\": \"$ICON\", \"tooltip\": \"󱈸 UNCOMMITTED CHANGES:\\n$DIRTY_FILES\", \"class\": \"dirty\"}"
elif [ "$LOCAL" != "$REMOTE" ]; then
    echo "{\"text\": \"$ICON\", \"tooltip\": \"󰇚 UNPUSHED COMMITS:\\n$HISTORY\", \"class\": \"unpushed\"}"
else
    echo "{\"text\": \"$ICON\", \"tooltip\": \"✅ SYNCED\\n$HISTORY\", \"class\": \"clean\"}"
fi