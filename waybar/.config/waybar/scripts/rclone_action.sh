#!/bin/bash

# 1. Start the log terminal FIRST in the background (&)
# This ensures you see the terminal the millisecond you click.
kitty --class floating_terminal -e journalctl --user -u rclone-sync.service -f &

# 2. Start the sync service
systemctl --user start rclone-sync.service &

# 3. Force Waybar to update the icon to Red immediately
pkill -RTMIN+10 waybar