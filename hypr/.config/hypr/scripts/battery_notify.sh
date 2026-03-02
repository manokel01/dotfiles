#!/bin/bash
while true; do
    # Check if the battery directory exists (usually BAT0 or BAT1 on ThinkPads)
    BAT_PATH="/sys/class/power_supply/BAT0"
    [ ! -d "$BAT_PATH" ] && BAT_PATH="/sys/class/power_supply/BAT1"

    if [ -d "$BAT_PATH" ]; then
        bat_level=$(cat "$BAT_PATH/capacity")
        bat_status=$(cat "$BAT_PATH/status")

        if [ "$bat_level" -le 15 ] && [ "$bat_status" != "Charging" ]; then
            notify-send -u critical "BATTERY CRITICAL" "Plug in your ThinkPad! ($bat_level%)"
            sleep 300 # Wait 5 mins before nagging again
        fi
    fi
    sleep 60
done
