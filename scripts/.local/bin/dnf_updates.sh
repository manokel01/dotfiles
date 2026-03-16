#!/bin/bash

# 1. Check for pending updates
UPDATES=$(dnf check-update -q | grep -c '^\S' | xargs)

# 2. Check if a reboot is required
# 'needs-restarting -r' returns exit code 1 if a reboot is needed, 0 if not.
dnf needs-restarting -r > /tmp/waybar_reboot.log 2>&1
REBOOT_NEEDED=$?

# 3. Output the JSON state
if [ "$REBOOT_NEEDED" -eq 1 ]; then
    # Priority 1: A reboot is required (takes over the icon)
    echo "{\"text\": \"󰑐 REBOOT\", \"tooltip\": \"System updated. Reboot required to apply new kernel or core libraries.\", \"class\": \"reboot\"}"
elif [ "$UPDATES" -gt 0 ]; then
    # Priority 2: Updates are available
    echo "{\"text\": \"󰚰 $UPDATES\", \"tooltip\": \"$UPDATES updates available. Click to upgrade.\", \"class\": \"updates\"}"
else
    # Priority 3: System is clean (Class changed to bypass CSS invisibility trap)
    echo "{\"text\": \"󰚰\", \"tooltip\": \"System up to date\", \"class\": \"updated\"}"
fi
