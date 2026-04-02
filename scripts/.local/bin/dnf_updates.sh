#!/bin/bash
export PATH="/usr/bin:/usr/local/bin:/bin:$PATH"

# 1. Standalone Reboot Check (High Priority)
# dnf needs-restarting -r returns 1 if a reboot IS needed
REBOOT_NEEDED=0
if ! dnf needs-restarting -r >/dev/null 2>&1; then
    REBOOT_NEEDED=1
fi

# 2. Standalone Update Count
UPDATES=$(dnf check-update -q | grep -cE '^\S+\s+\S+\s+\S+')

# 3. Output JSON with priority logic
if [ "$REBOOT_NEEDED" -eq 1 ]; then
    echo "{\"text\": \"󰑐 REBOOT NOW!\", \"tooltip\": \"Kernel or core libraries updated. Restart required.\", \"class\": \"reboot\"}"
elif [ "$UPDATES" -gt 0 ]; then
    echo "{\"text\": \"󰚰 $UPDATES\", \"tooltip\": \"$UPDATES updates available.\", \"class\": \"updates\"}"
else
    echo "{\"text\": \"󰚰 0\", \"tooltip\": \"System up to date\", \"class\": \"updated\"}"
fi
