#!/bin/bash

# 1. Check if our specific OBSBOT pump is running
if pgrep -f "ffmpeg.*video9" > /dev/null; then
    # Return JSON telling Waybar the OBSBOT is active
    echo '{"text": "OBSBOT Pro", "class": "active-obsbot", "tooltip": "Click to KILL OBSBOT feed"}'
    exit 0
fi

# 2. Check if any other camera is being used (e.g., Brave using the ThinkPad camera)
# lsof checks if any application currently has a lock on a /dev/video file
if [ -n "$(lsof -t /dev/video* 2>/dev/null)" ]; then
    # Return JSON telling Waybar the Internal Camera is active
    echo '{"text": "Internal Cam", "class": "active-internal", "tooltip": "Camera is currently in use"}'
    exit 0
fi

# 3. If nothing is running, return the idle state
echo '{"text": "", "class": "inactive", "tooltip": "Cameras off. Click to launch menu."}'