#!/bin/bash
# Native Void: DNF5 Update Checker

# 1. Count updates. Matches "Arch + Space + Version Number" to completely ignore repo headers.
UPDATES=$(dnf check-update -q | grep -cE '\s(x86_64|noarch|i686|aarch64)\s+[0-9]')

# 2. Check if a reboot is required
dnf needs-restarting -r > /tmp/waybar_reboot.log 2>&1
EXIT_CODE=$?

# 3. Bulletproof the exit code check
if [ "$EXIT_CODE" -eq 1 ] && ! grep -qi "error\|failed\|lock" /tmp/waybar_reboot.log; then
    REBOOT_NEEDED=1
else
    REBOOT_NEEDED=0
fi

# 4. Output the JSON state
if [ "$REBOOT_NEEDED" -eq 1 ]; then
    echo "{\"text\": \"󰑐 REBOOT\", \"tooltip\": \"System updated. Reboot required.\", \"class\": \"reboot\"}"
elif [ "$UPDATES" -gt 0 ]; then
    echo "{\"text\": \"󰚰 $UPDATES\", \"tooltip\": \"$UPDATES updates available.\", \"class\": \"updates\"}"
else
    echo "{\"text\": \"󰚰\", \"tooltip\": \"System up to date\", \"class\": \"updated\"}"
fi
