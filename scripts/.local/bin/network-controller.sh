#!/bin/bash
# Native Void: Network Controller (Walker + NMTUI)

case "$1" in
    "--menu")
        # Quick Picker via Walker
        wifi_list=$(nmcli --fields "SECURITY,SSID" device wifi list | sed 1d | sed 's/^--/󰤪 /g' | sed 's/^[* ]/󰤨 /g' | awk -F'  +' '{if (!seen[$2]++) print $1 " " $2}')
        selected=$(echo -e "$wifi_list" | walker --dmenu --placeholder "Connect to Wi-Fi...")
        
        [ -z "$selected" ] && exit 0
        ssid=$(echo "$selected" | sed 's/^[󰤪󰤨] //')
        
        if nmcli connection show "$ssid" > /dev/null 2>&1; then
            nmcli connection up "$ssid"
        else
            pass=$(walker --dmenu --placeholder "Enter Password for $ssid...")
            [ -z "$pass" ] && exit 0
            nmcli device wifi connect "$ssid" password "$pass"
        fi
        ;;

    "--manage")
        # The Power User interface (NMTUI)
        nmtui
        ;;
    *)
        echo "Usage: $0 [--menu|--manage]"
        ;;
esac
