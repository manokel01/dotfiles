#!/bin/bash

# Assume we start in DAY mode to force a check immediately
LAST_PHASE="DAY"

while true; do
    current_hour=$(date +%H)
    
    # Determine what phase of the day we are currently in
    if [ "$current_hour" -ge 21 ] || [ "$current_hour" -lt 7 ]; then
        CURRENT_PHASE="NIGHT"
    else
        CURRENT_PHASE="DAY"
    fi
    
    # ONLY take action if we just crossed the 9 PM or 7 AM threshold
    if [ "$CURRENT_PHASE" != "$LAST_PHASE" ]; then
        if [ "$CURRENT_PHASE" == "NIGHT" ]; then
            gammastep -O 3500 > /dev/null 2>&1 &
        else
            pkill gammastep
        fi
        # Update the memory state
        LAST_PHASE="$CURRENT_PHASE"
    fi
    
    # Sleep for 60 seconds
    sleep 60
done
