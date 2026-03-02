#!/bin/bash
if pgrep -f "ffmpeg.*video9" > /dev/null; then
    echo '{"class": "active", "tooltip": "OBSBOT Live"}'
else
    echo '{"class": "inactive", "tooltip": "Camera Off"}'
fi