#!/bin/bash
# Check if ffmpeg is currently outputting to our virtual device
if pgrep -f "ffmpeg.*video9" > /dev/null; then
    echo '{"class": "active", "tooltip": "OBSBOT Live"}'
else
    echo '{"class": "inactive", "tooltip": "Camera Off"}'
fi