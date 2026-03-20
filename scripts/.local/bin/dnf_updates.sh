#!/bin/bash
# Force systemd to see standard binary paths
export PATH="/usr/bin:/usr/local/bin:/bin:$PATH"

# 1. Count updates. No --refresh (prevents sudo hangs). Broad match for DNF5.
UPDATES=$(dnf check-update -q | grep -cE '(x86_64|noarch|i686|aarch64)')

# 2. Check if a reboot is required
dnf needs-restarting -r > /tmp/waybar_reboot.log 2>&1
EXIT_CODE=$?

# 3. Guard against missing commands
if [ "$EXIT_CODE" -eq 1 ] && ! grep -qi "error\|failed\|lock\|not found" /tmp/waybar_reboot.log; then
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
    echo "{\"text\": \"󰚰 0\", \"tooltip\": \"System up to date\", \"class\": \"updated\"}"
fi
