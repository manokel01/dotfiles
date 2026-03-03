#!/bin/bash
cd "$HOME/dotfiles" || exit

# Force git to update its view of the filesystem
git update-index -q --refresh

LAST_SYNC=$(git log -1 --format="%ar")

# Check if there are changes compared to the remote
UPSTREAM=${1:-'@{u}'}
LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse "$UPSTREAM")

if [[ -n $(git status -s) ]]; then
    echo "{\"text\": \" Dirty\", \"tooltip\": \"Uncommitted changes\", \"class\": \"dirty\"}"
elif [ "$LOCAL" != "$REMOTE" ]; then
    echo "{\"text\": \"󰇚 Unpushed\", \"tooltip\": \"Local commits not on GitHub\", \"class\": \"dirty\"}"
else
    echo "{\"text\": \"󰊢 $LAST_SYNC\", \"tooltip\": \"Synced with GitHub\", \"class\": \"clean\"}"
fi