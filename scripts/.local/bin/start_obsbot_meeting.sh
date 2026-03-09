#!/bin/bash

# To tell it like it is: This script finds your OBSBOT no matter what number it gets
SOURCE_DEV=$(v4l2-ctl --list-devices | grep -A 1 "OBSBOT Tiny 2" | grep "/dev/video" | awk '{print $1}' | head -n 1)

# CLEANUP TRAP: If this script is closed, killed, or interrupted, kill the ffmpeg pump
trap 'echo "Cleaning up..."; pkill -9 -f "ffmpeg.*video9"; exit' SIGINT SIGTERM EXIT

if [ -z "$SOURCE_DEV" ]; then
    echo "ERROR: OBSBOT Tiny 2 not found!"
    echo "Check the USB connection and try again."
    read -p "Press enter to close..."
    exit 1
fi

echo "Starting Meeting Mode..."
echo "Source: $SOURCE_DEV"
echo "Target: /dev/video9 (OBSBOT Pro Feed)"
echo "-------------------------------------------"

# Ensure loopback module is loaded
sudo modprobe v4l2loopback video_nr=9 card_label="OBSBOT Pro Feed" exclusive_caps=1 2>/dev/null

# The FFmpeg Pump
ffmpeg -f v4l2 -input_format mjpeg -video_size 1920x1080 -i "$SOURCE_DEV" \
       -vcodec rawvideo -pix_fmt yuv420p -f v4l2 /dev/video9