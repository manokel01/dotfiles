#!/bin/bash

# Check if wireplumber is in the versionlock list
if ! dnf versionlock list | grep -q "wireplumber"; then
    echo ''
    echo -e '\e[1;31m[!] CRITICAL WARNING: wireplumber versionlock is MISSING!\e[0m'
    echo -e '\e[1;31mRun: sudo dnf versionlock add wireplumber\e[0m'
    echo ''
fi
