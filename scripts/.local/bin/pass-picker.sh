#!/bin/bash
# Native Void: The fzf Vault Dashboard (Offline-Ready Auto-Sync)

# 1. Background Sync (Fails silently if offline, zero UI delay)
rbw sync &>/dev/null &

# 2. Fuzzy find the account
ACCOUNT=$(rbw list | fzf --prompt="Vault ❯ " --info=hidden --layout=reverse --color="bg:#000000,fg:#ffffff,hl:#555555,prompt:#ffffff,pointer:#ffffff" --border=none)

# Exit if Escape is pressed
[ -z "$ACCOUNT" ] && exit 0

# 3. Select the Action
ACTION=$(printf "Password\nUsername\nTOTP (2FA)\nNotes" | fzf --prompt="$ACCOUNT ❯ " --info=hidden --layout=reverse --color="bg:#000000,fg:#ffffff,hl:#555555,prompt:#ffffff,pointer:#ffffff" --border=none)

# 4. Execute and Copy (Triggers fprintd automatically)
case "$ACTION" in
    "Password")   rbw get "$ACCOUNT" | wl-copy ;;
    "Username")   rbw get --fields user "$ACCOUNT" | wl-copy ;;
    "TOTP (2FA)") rbw code "$ACCOUNT" | wl-copy ;;
    "Notes")      rbw get --fields notes "$ACCOUNT" | wl-copy ;;
    *) exit 0 ;;
esac

# 5. Success Notification
notify-send "Bitwarden" "$ACTION for $ACCOUNT copied to clipboard." -i security-high
