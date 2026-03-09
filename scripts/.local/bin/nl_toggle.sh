#!/bin/bash

if pgrep -x gammastep > /dev/null; then
    # If it's running, kill it
    pkill -x gammastep
else
    # If it's not running, start it and completely detach it from Waybar
    gammastep -O 3500 > /dev/null 2>&1 & disown
fi
