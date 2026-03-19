#!/bin/bash
# Native Void: Pure Bash Bitwarden Picker (Rofi)

# 1. Get list (stripping potential 'syncing' noise)
# We use 'name' and 'user' for the menu.
SELECTION=$(rbw list --fields name,user | rofi -dmenu -i -p "Vault")

# 2. Exit if user hits Escape
[ -z "$SELECTION" ] && exit 0

# 3. Extract the account name (first column)
ACCOUNT=$(echo "$SELECTION" | awk '{print $1}')

# 4. Fetch and copy (this triggers the fingerprint sensor)
rbw get "$ACCOUNT" | wl-copy

# 5. Notify
notify-send "Bitwarden" "Password for $ACCOUNT copied to clipboard." -i security-high
