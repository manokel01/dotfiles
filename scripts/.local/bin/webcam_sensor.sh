#!/bin/bash

# Get the PID of the FFmpeg pump
FFMPEG_PID=$(pgrep -f "[f]fmpeg.*video9")

# Get all PIDs currently accessing the video device
FUSER_OUT=$(fuser /dev/video9 2>/dev/null)

# Check if there are any PIDs touching the device that are NOT FFmpeg
IS_STREAMING=false
if [ -n "$FUSER_OUT" ]; then
    for pid in $FUSER_OUT; do
        if [ "$pid" != "$FFMPEG_PID" ]; then
            IS_STREAMING=true
            break
        fi
    done
fi

if $IS_STREAMING; then
    echo '{"class": "active", "tooltip": "OBSBOT Streaming"}'
elif [ -n "$FFMPEG_PID" ]; then
    echo '{"class": "active-internal", "tooltip": "OBSBOT Idle (Process Running)"}'
else
    echo '{"class": "inactive", "tooltip": "Camera Off"}'
fi