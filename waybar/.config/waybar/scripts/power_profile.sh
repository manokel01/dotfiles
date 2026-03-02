#!/bin/bash
CURRENT=$(powerprofilesctl get | xargs)

case $CURRENT in
    performance)
        powerprofilesctl set balanced
        notify-send "Power Profile" "Balanced" -i battery-good
        ;;
    balanced)
        powerprofilesctl set power-saver
        notify-send "Power Profile" "Saver" -i battery-low
        ;;
    power-saver)
        powerprofilesctl set performance
        notify-send "Power Profile" "Performance" -i battery-full
        ;;
esac

# Force Waybar to update the module text immediately after the click
pkill -RTMIN+1 waybar