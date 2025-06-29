#!/bin/bash

# Script to launch trading and finance applications via dmenu

# Define trading/finance applications and commands
declare -a options=(
    "cointop"
    "tastyworks"
    "tastytrade"
    "thinkorswim"
    "quit"
)

# Show dmenu and get user choice
choice=$(printf '%s\n' "${options[@]}" | dmenu -i -p 'Trading & Finance: ')

# Handle user choice
case $choice in
    quit)
        echo "Program terminated."
        exit 0
        ;;
    cointop)
        if [ -x "$HOME/go/bin/cointop" ]; then
            exec kitty -e --title virtual-shell "$HOME/go/bin/cointop"
        else
            notify-send "Error" "Cointop not found at $HOME/go/bin/cointop"
            exit 1
        fi
        ;;
    tastyworks)
        if [ -x "/opt/tastyworks/tastyworks" ]; then
            exec /opt/tastyworks/tastyworks
        else
            notify-send "Error" "Tastyworks not found at /opt/tastyworks/tastyworks"
            exit 1
        fi
        ;;
    tastytrade)
        exec brave-browser "https://tastytrade.com"
        ;;
    thinkorswim)
        if [ -x "$HOME/thinkorswim/thinkorswim" ]; then
            exec "$HOME/thinkorswim/thinkorswim"
        else
            notify-send "Error" "Thinkorswim not found at $HOME/thinkorswim/thinkorswim"
            exit 1
        fi
        ;;
    *)
        exit 1
        ;;
esac