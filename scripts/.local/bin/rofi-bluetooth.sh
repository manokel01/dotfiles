#!/bin/bash
# Native Void Rofi Bluetooth Manager v2

# 1. Check if Bluetooth is powered on
power_status=$(bluetoothctl show | grep "Powered: yes")

if [ -z "$power_status" ]; then
    menu="󰂯 Power On"
else
    menu="󰂲 Power Off\n󰂰 Scan / Pair New\n------------------------"
    
    # 2. Build the device list dynamically
    while read -r line; do
        mac=$(echo "$line" | awk '{print $2}')
        name=$(echo "$line" | cut -d ' ' -f 3-)
        
        # Check if the device is currently connected
        connected=$(bluetoothctl info "$mac" | grep "Connected: yes")
        if [ -n "$connected" ]; then
            menu="$menu\n[Connected] $name"
        else
            menu="$menu\n$name"
        fi
    done < <(bluetoothctl devices Paired)
fi

# 3. Show Rofi menu
selection=$(echo -e "$menu" | walker --dmenu)

[ -z "$selection" ] && exit

# 4. Handle the user's selection
if [[ "$selection" == "󰂯 Power On" ]]; then
    bluetoothctl power on
    notify-send "Bluetooth" "Powered On"
elif [[ "$selection" == "󰂲 Power Off" ]]; then
    bluetoothctl power off
    notify-send "Bluetooth" "Powered Off"
elif [[ "$selection" == "󰂰 Scan / Pair New" ]]; then
    # Opens Kitty with the interactive bluetoothctl prompt for pairing
    kitty --class floating_terminal -e sh -c 'echo "Type: scan on, then pair MAC, then trust MAC"; bluetoothctl; exec bash'
elif [[ "$selection" == "------------------------" ]]; then
    exit
else
    # Extract the clean name and find its MAC address
    name=$(echo "$selection" | sed 's/\[Connected\] //')
    mac=$(bluetoothctl devices Paired | grep -F "$name" | awk '{print $2}' | head -n 1)
    
    # Toggle connection state
    if [[ "$selection" == *"[Connected]"* ]]; then
        bluetoothctl disconnect "$mac"
        notify-send "Bluetooth" "Disconnected from $name"
    else
        bluetoothctl connect "$mac"
        notify-send "Bluetooth" "Connected to $name"
    fi
fi
