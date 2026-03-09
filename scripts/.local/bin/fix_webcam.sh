#!/bin/bash
# Wait for drivers to initialize
sleep 2

# Force 5MP resolution and MJPG format
v4l2-ctl -d /dev/video0 --set-fmt-video=width=2592,height=1944,pixelformat=MJPG

# Apply the exact "Golden Settings" from your screenshot
v4l2-ctl -d /dev/video0 -c brightness=96
v4l2-ctl -d /dev/video0 -c contrast=33
v4l2-ctl -d /dev/video0 -c saturation=63
v4l2-ctl -d /dev/video0 -c white_balance_temperature_auto=0
v4l2-ctl -d /dev/video0 -c white_balance_temperature=4370
v4l2-ctl -d /dev/video0 -c sharpness=4
v4l2-ctl -d /dev/video0 -c backlight_compensation=1

notify-send "Webcam Optimized" "5MP Golden Settings Applied" -i camera-web
