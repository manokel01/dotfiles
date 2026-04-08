#!/bin/bash
export PATH="/usr/bin:/usr/local/bin:/bin:$PATH"

# 1. Standalone Reboot Check (High Priority)
# Explicitly grepping for the required string prevents false positives when DNF is locked.
REBOOT_NEEDED=0
if dnf needs-restarting -r 2>/dev/null | grep -qi "Reboot is required"; then
    REBOOT_NEEDED=1
fi

# 2. Standalone Update Count
# Silencing stderr prevents background dnf-makecache locks from generating ghost output.
UPDATES=$(dnf check-update -q 2>/dev/null | grep -cE '^\S+\s+\S+\s+\S+')

# 3. Output JSON with priority logic
if [ "$REBOOT_NEEDED" -eq 1 ]; then
    echo "{\"text\": \"󰑐 REBOOT NOW!\", \"tooltip\": \"Kernel or core libraries updated. Restart required.\", \"class\": \"reboot\"}"
elif [ "$UPDATES" -gt 0 ]; then
    echo "{\"text\": \"󰚰 $UPDATES\", \"tooltip\": \"$UPDATES updates available.\", \"class\": \"updates\"}"
else
    echo "{\"text\": \"󰚰 0\", \"tooltip\": \"System up to date\", \"class\": \"updated\"}"
fi
