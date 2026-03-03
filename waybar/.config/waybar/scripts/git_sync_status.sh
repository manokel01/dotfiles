#!/bin/bash

# Navigate to dotfiles
cd "$HOME/dotfiles" || exit

# Get the last commit time in a short format
LAST_SYNC=$(git log -1 --format="%ar")

# Check if there are uncommitted changes
if [[ -n $(git status -s) ]]; then
    # Dirty state: Show warning icon
    echo "{\"text\": \" Dirty\", \"tooltip\": \"Uncommitted changes in dotfiles\", \"class\": \"dirty\"}"
else
    # Clean state: Show sync time
    echo "{\"text\": \"󰊢 $LAST_SYNC\", \"tooltip\": \"Last pushed to GitHub\", \"class\": \"clean\"}"
fi