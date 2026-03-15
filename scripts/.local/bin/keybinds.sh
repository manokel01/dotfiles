#!/bin/bash

(
echo -e "  HYPRLAND SHORTCUTS CHEAT SHEET"
echo -e "==================================\n"

echo -e "󰣆  SYSTEM & APPS"
echo -e "----------------"
echo -e "SUPER + RETURN           󰁔  Open Terminal (Kitty)"
echo -e "SUPER + Q                󰁔  Close Window (Smart Viber Kill)"
echo -e "SUPER + D / 󰍉           󰁔  App Launcher (Rofi)"
echo -e "SUPER + Space            󰁔  Toggle Language (US/GR)"
echo -e "SUPER + E                󰁔  File Manager (Nautilus)"
echo -e "SUPER + SHIFT + E        󰁔  Terminal File Manager (Yazi)"
echo -e "SUPER + SHIFT + V                󰁔  Clipboard History (Cliphist)"
echo -e "SUPER + N                󰁔  Toggle Notification Center"
echo -e "SUPER + SHIFT + W        󰁔  Reload Waybar (Void Sync)"
echo -e "SUPER + M                󰁔  Exit Hyprland (Logout)\n"

echo -e "󰹑  SCREENSHOTS"
echo -e "--------------"
echo -e "SUPER + S                󰁔  Capture Selection to File"
echo -e "SUPER + SHIFT + S        󰁔  Capture Selection to Clipboard"
echo -e "PrtSc (ThinkPad)         󰁔  Trigger screenshot.sh"
echo -e "F13 / Tools (NuPhy)      󰁔  Trigger screenshot.sh\n"

echo -e "󰌌  NUPHY AIR75 V3 SPECIAL"
echo -e "--------------------------"
echo -e "F3                       󰁔  Search Open Windows"
echo -e "Media Keys (  )       󰁔  Player Controls"
echo -e "Right OPT (Alt Gr)       󰁔  Greek Accents (Firmware Level)"
echo -e "Top-Right FN5 + 1/2/3    󰁔  Switch Bluetooth Slots\n"

echo -e "  WORKSPACES & WINDOWS"
echo -e "-----------------------"
echo -e "SUPER + [1-4]            󰁔  Switch to Workspace"
echo -e "SUPER + SHIFT + [1-4]    󰁔  Move Window + Follow"
echo -e "SUPER + ALT + [1-4]      󰁔  Move Window Silently"
echo -e "SUPER + Arrows           󰁔  Move Focus"
echo -e "SUPER + SHIFT + Arrows   󰁔  Move Window Position"
echo -e "SUPER + Left Click       󰁔  Drag/Move Window"
echo -e "SUPER + Right Click      󰁔  Resize Window"
echo -e "SUPER + F                󰁔  Resize Window"
echo -e "SUPER + V                󰁔  Toggle Floating\n"

echo -e "󰄀  MULTI-MONITOR"
echo -e "----------------"
echo -e "SUPER + . / ,            󰁔  Focus Next/Prev Monitor"
echo -e "SUPER + SHIFT + . / ,    󰁔  Move Window to Next/Prev Monitor\n"

echo -e "󰃠  HARDWARE"
echo -e "-----------"
echo -e "Brightness Keys          󰁔  Adjust Screen & DDC/CI Monitor"
echo -e "Volume Keys / Knob       󰁔  Adjust/Mute Audio (SwayOSD)"
echo -e "Sleep Key                󰁔  System Suspend"
) > /tmp/hypr_keys

kitty --class floating_terminal sh -c "cat /tmp/hypr_keys; echo ''; echo '----------------------------------'; read -n 1 -s -r -p 'Press any key to close...'"
