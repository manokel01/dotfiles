#!/bin/bash
# Unmounts all partitions and cuts hardware power to all USB drives

USB_DRIVES=$(lsblk -d -n -o NAME,TRAN | awk '$2=="usb" {print $1}')

for drive in $USB_DRIVES; do
    # Unmount partitions first
    for part in $(lsblk -n -l -o NAME -p "/dev/$drive" | awk 'NR>1'); do
        udisksctl unmount -b "$part" 2>/dev/null
    done
    # Flush cache and power down physical hardware
    udisksctl power-off -b "/dev/$drive" 2>/dev/null
done
