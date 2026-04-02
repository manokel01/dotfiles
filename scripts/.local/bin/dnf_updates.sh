#!/bin/bash
export PATH="/usr/bin:/usr/local/bin:/bin:$PATH"

# 1. Quick count (Quiet mode, no metadata refresh)
UPDATES=$(dnf check-update -q | grep -cE '^\S+\s+\S+\s+\S+')

# 2. Reboot check (Only run if updates exist to save battery)
REBOOT_NEEDED=0
if [ "$UPDATES" -gt 0 ]; then
    # dnf needs-restarting -r returns 1 if a reboot IS needed
    if ! dnf needs-restarting -r >/dev/null 2>&1; then
        REBOOT_NEEDED=1
    fi
fi

# 3. Output JSON
if [ "$REBOOT_NEEDED" -eq 1 ]; then
    echo "{\"text\": \"󰑐 REBOOT\", \"tooltip\": \"System updated. Reboot required.\", \"class\": \"reboot\"}"
elif [ "$UPDATES" -gt 0 ]; then
    echo "{\"text\": \"󰚰 $UPDATES\", \"tooltip\": \"$UPDATES updates available.\", \"class\": \"updates\"}"
else
    echo "{\"text\": \"󰚰 0\", \"tooltip\": \"System up to date\", \"class\": \"updated\"}"
fi
