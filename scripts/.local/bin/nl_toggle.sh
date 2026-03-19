#!/bin/bash
# Native Void: GPU Shader Toggle

# Check if the shader is currently active
if hyprctl getoption decoration:screen_shader | grep -q "nightlight.frag"; then
    # Turn OFF (Reset to default)
    hyprctl keyword decoration:screen_shader "[[EMPTY]]"
else
    # Turn ON (Absolute path per rules)
    hyprctl keyword decoration:screen_shader "/home/manokel/.config/hypr/shaders/nightlight.frag"
fi

# Flip the Waybar icon instantly
pkill -RTMIN+8 waybar
