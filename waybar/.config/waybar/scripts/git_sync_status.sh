#!/bin/bash
cd "$HOME/dotfiles" || exit

# Force git to update its view of the filesystem
git update-index -q --refresh

# Corrected: no space in @{u}
UPSTREAM=${1:-'@{u}'}
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "$UPSTREAM")

ICON=""

if [[ -n $(git status -s) ]]; then
    # Uncommitted changes
    echo "{\"text\": \"$ICON\", \"tooltip\": \"Uncommitted changes\", \"class\": \"dirty\"}"
elif [ "$LOCAL" != "$REMOTE" ]; then
    # Commits waiting to be pushed
    echo "{\"text\": \"$ICON\", \"tooltip\": \"Unpushed commits\", \"class\": \"unpushed\"}"
else
    # Everything is synced
    LAST_SYNC=$(git log -1 --format="%ar")
    echo "{\"text\": \"$ICON\", \"tooltip\": \"Last synced: $LAST_SYNC\", \"class\": \"clean\"}"
fi