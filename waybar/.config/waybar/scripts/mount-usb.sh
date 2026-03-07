#!/bin/bash
# Identifies physical USB drives and mounts their child partitions safely

USB_DRIVES=$(lsblk -d -n -o NAME,TRAN | awk '$2=="usb" {print $1}')

for drive in $USB_DRIVES; do
    # Extract absolute paths of partitions, ignoring the parent disk
    for part in $(lsblk -n -l -o NAME -p "/dev/$drive" | awk 'NR>1'); do
        udisksctl mount -b "$part" 2>/dev/null
    done
done
