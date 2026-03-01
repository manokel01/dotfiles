#!/bin/bash

# 1. If OBSBOT pump is running: acts as a KILL SWITCH
if pgrep -f "ffmpeg.*video9" > /dev/null; then
    notify-send "Webcam Control" "Killing OBSBOT Pro Feed..."
    
    # The physical hardware sleep command
    /usr/local/bin/t4l camera sleep
    
    pkill -f "ffmpeg.*video9"
    pkill -f "OBSBOT-Meeting-Terminal"
    exit 0
fi

# 2. If Internal Camera is running: acts as a REMINDER
# lsof checks if an application currently has a lock on a /dev/video file
if [ -n "$(lsof -t /dev/video* 2>/dev/null)" ]; then
    notify-send -t 3000 "Camera Locked" "Your internal camera is currently in use.\nClose the browser tab or app to turn it off."
    exit 0
fi

# 3. If nothing is running: show the Rofi menu
OPTIONS="🚀 Start OBSBOT Meeting Mode\n❌ Cancel"
CHOICE=$(echo -e "$OPTIONS" | rofi -dmenu -i -p "Webcam:" -lines 2 -hover-select -me-select-entry '' -me-accept-entry MousePrimary)

case "$CHOICE" in
    *"Start OBSBOT"*)
        hyprctl dispatch exec "kitty --hold --title \"OBSBOT-Meeting-Terminal\" $HOME/start_obsbot_meeting.sh"
        ;;
    *)
        exit 0
        ;;
esac
