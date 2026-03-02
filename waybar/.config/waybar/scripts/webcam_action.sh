#!/bin/bash
if pgrep -f "ffmpeg.*video9" > /dev/null; then
    notify-send "Webcam" "Shutting down..."
    /usr/local/bin/t4l camera sleep || /usr/local/bin/t4l sleep
    pkill -f "ffmpeg.*video9"
    pkill -f "OBSBOT-Meeting-Terminal"
    exit 0
fi
CHOICE=$(echo -e "🚀 Start OBSBOT\n❌ Cancel" | rofi -dmenu -i -p "Webcam:")
if [[ "$CHOICE" == *"Start OBSBOT"* ]]; then
    hyprctl dispatch exec "kitty --hold --title \"OBSBOT-Meeting-Terminal\" $HOME/start_obsbot_meeting.sh"
fi