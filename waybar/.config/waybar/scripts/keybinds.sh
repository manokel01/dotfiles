#!/bin/bash

(
echo -e "  HYPRLAND SHORTCUTS CHEAT SHEET"
echo -e "==================================\n"

echo -e "󰣆  SYSTEM & APPS"
echo -e "----------------"
echo -e "SUPER + RETURN           󰁔  Open Terminal (Kitty)"
echo -e "SUPER + Q                󰁔  Close Active Window"
echo -e "SUPER + D                󰁔  App Launcher (Rofi)"
echo -e "SUPER + Space            󰁔  Toggle Language (US/EL)"
echo -e "SUPER + E                󰁔  File Manager (Thunar)"
echo -e "SUPER + SHIFT + E        󰁔  Floating File Manager (Yazi)"
echo -e "SUPER + V                󰁔  Clipboard History"
echo -e "SUPER + M                󰁔  Exit Hyprland (Logout)\n"

echo -e "󰹑  SCREENSHOTS"
echo -e "--------------"
echo -e "SUPER + S                󰁔  Capture Selection to File"
echo -e "SUPER + SHIFT + S        󰁔  Capture Selection to Clipboard\n"

echo -e "󱂬  WORKSPACES & WINDOWS"
echo -e "-----------------------"
echo -e "SUPER + [1-4]            󰁔  Switch to Workspace"
echo -e "SUPER + SHIFT + [1-4]    󰁔  Move Window + Follow"
echo -e "SUPER + ALT + [1-4]      󰁔  Move Window Silently"
echo -e "SUPER + Arrows           󰁔  Move Focus (Up/Down/Left/Right)"
echo -e "SUPER + SHIFT + Arrows   󰁔  Move Window Position"
echo -e "SUPER + Left Click       󰁔  Drag/Move Window"
echo -e "SUPER + Right Click      󰁔  Resize Window\n"

echo -e "󰄀  MULTI-MONITOR"
echo -e "----------------"
echo -e "SUPER + . / ,            󰁔  Switch Focus to Next/Prev Monitor"
echo -e "SUPER + SHIFT + . / ,    󰁔  Move Window to Next/Prev Monitor"
echo -e "Lid Close/Open           󰁔  Disable/Enable Laptop Screen\n"

echo -e "󰃠  HARDWARE"
echo -e "-----------"
echo -e "Brightness Keys          󰁔  Adjust Screen Brightness"
echo -e "Volume Keys              󰁔  Adjust/Mute Audio"
echo -e "SUPER + ALT + C          󰁔  Fix/Reset Webcam (OBSBOT)"
) > /tmp/hypr_keys

kitty --class floating_terminal sh -c "cat /tmp/hypr_keys; echo ''; echo '----------------------------------'; read -n 1 -s -r -p 'Press any key to close...'"