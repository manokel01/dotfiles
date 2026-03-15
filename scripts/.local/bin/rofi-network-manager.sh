#!/bin/bash

# Get a list of available wifi networks
wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list | sed 1d | sed 's/^--/󰤪 /g' | sed 's/^[* ]/󰤨 /g' | awk -F'  +' '{if (!seen[$2]++) print $1 " " $2}')

# Use Rofi to select a network
selected_network=$(echo -e "$wifi_list" | rofi -dmenu -i -p "󰖩 Wi-Fi")

# Exit if nothing selected
[ -z "$selected_network" ] && exit

# Extract SSID
ssid=$(echo "$selected_network" | sed 's/^[󰤪󰤨] //')

# Attempt to connect
if nmcli connection show "$ssid" > /dev/null 2>&1; then
    nmcli connection up "$ssid"
else
    password=$(rofi -dmenu -p "󰷦 Password" -password)
    [ -z "$password" ] && exit
    nmcli device wifi connect "$ssid" password "$password"
fi
