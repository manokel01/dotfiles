#!/bin/bash

# 1. Check for pending updates (Cache-only: instantly reads local DB)
UPDATES=$(dnf check-update -q -C | grep -c '^\S' | xargs)

# 2. Check if a reboot is required (Cache-only)
dnf needs-restarting -r -C > /tmp/waybar_reboot.log 2>&1
EXIT_CODE=$?

# 3. Bulletproof the exit code check
# DNF returns 1 for reboot, but ALSO 1 for network/lock errors.
# We only trigger the reboot UI if it exited 1 AND there are no errors in the log.
if [ "$EXIT_CODE" -eq 1 ] && ! grep -qi "error\|failed\|lock" /tmp/waybar_reboot.log; then
    REBOOT_NEEDED=1
else
    REBOOT_NEEDED=0
fi

# 4. Output the JSON state
if [ "$REBOOT_NEEDED" -eq 1 ]; then
    # Priority 1: A reboot is required
    echo "{\"text\": \"󰑐 REBOOT\", \"tooltip\": \"System updated. Reboot required to apply new kernel or core libraries.\", \"class\": \"reboot\"}"
elif [ "$UPDATES" -gt 0 ]; then
    # Priority 2: Updates are available
    echo "{\"text\": \"󰚰 $UPDATES\", \"tooltip\": \"$UPDATES updates available. Click to upgrade.\", \"class\": \"updates\"}"
else
    # Priority 3: System is clean
    echo "{\"text\": \"󰚰\", \"tooltip\": \"System up to date\", \"class\": \"updated\"}"
fi
