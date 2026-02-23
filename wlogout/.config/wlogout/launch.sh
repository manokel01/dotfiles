#!/bin/bash

# Find the resolution of the currently focused monitor
monitor_res=$(hyprctl monitors | grep -B 4 "focused: yes" | awk '/res:/ {print $2}')
width=$(echo $monitor_res | cut -d'x' -f1)
height=$(echo $monitor_res | cut -d'x' -f2 | cut -d'@' -f1)

# Fallback to 1080p if detection fails
if [ -z "$height" ]; then
    height=1080
    width=1920
fi

# Crush the container into the center
y_margin=$((height * 42 / 100))
x_margin=$((width * 32 / 100))

# Launch wlogout with calculated margins
wlogout -b 5 -T $y_margin -B $y_margin -L $x_margin -R $x_margin