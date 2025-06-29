#!/bin/bash

# Script to launch system monitoring tools via dmenu

# Define monitoring tools
declare -a options=(
    "bashtop"
    "glances"
    "gtop"
    "htop"
    "iftop"
    "iotop"
    "iptraf-ng"
    "nmon"
    "s-tui"
    "quit"
)

# Show dmenu and get user choice
choice=$(printf '%s\n' "${options[@]}" | dmenu -i -p 'System monitors: ')

# Handle user choice
case $choice in
    quit)
        echo "Program terminated."
        exit 0
        ;;
    bashtop|glances|gtop|htop|nmon|s-tui)
        # Launch normal tools with kitty
        exec kitty -e --title virtual-shell "$choice"
        ;;
    iftop|iotop|iptraf-ng)
        # Launch tools requiring elevated privileges
        exec kitty -e --title virtual-shell sudo "$choice"
        ;;
    *)
        # Exit if invalid choice
        exit 1
        ;;
esac