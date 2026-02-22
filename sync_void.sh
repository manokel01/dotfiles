#!/bin/bash

# --- CONFIGURATION ---
DOTFILES_DIR="$HOME/dotfiles"
read -p "Enter change description (or Enter for generic): " user_msg
if [ -z "$user_msg" ]; then COMMIT_MSG="Void Hardening: $(date +"%Y-%m-%d %H:%M:%S")"; else COMMIT_MSG="Void: $user_msg"; fi

# Ensure we are in the correct directory
cd "$DOTFILES_DIR" || exit

echo "--- [1/4] Creating Safety Snapshot (Snapper) ---"
sudo snapper create --description "Pre-Void-Sync: Hardening UI"

echo "--- [2/4] Refreshing GNU Stow Symlinks ---"
for dir in */; do
    # Skip the .git directory and the script itself
    [[ "$dir" == ".git/" ]] && continue
    stow -R "${dir%/}"
done

echo "--- [3/4] Validating Scaling & Audio Locks ---"
if grep -q "exclude=wireplumber" /etc/dnf/dnf.conf; then
    echo "Audio Lock: VERIFIED (0.5.11 protected)"
else
    echo "WARNING: Audio Lock missing. Re-applying..."
    sudo sed -i '/\[main\]/a exclude=wireplumber' /etc/dnf/dnf.conf
fi

echo "--- [4/4] Pushing to GitHub ---"
git add .
git commit -m "$COMMIT_MSG"
git push origin main

echo "--- VOID SYNC COMPLETE ---"
