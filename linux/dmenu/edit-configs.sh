#!/bin/bash

# Script to edit configuration files via dmenu

# Define configuration files with their paths
declare -A configs=(
    ["kitty"]="$HOME/.config/kitty/kitty.conf"
    ["bash"]="$HOME/.bashrc"
    ["dunst"]="$HOME/.config/dunst/dunstrc"
    ["neovim"]="$HOME/.config/nvim/init.vim"
    ["qtile"]="$HOME/.config/qtile/config.py"
    ["qutebrowser"]="$HOME/.config/qutebrowser/autoconfig.yml"
    ["sxhkd"]="$HOME/.config/sxhkd/sxhkdrc"
    ["zsh"]="$HOME/.zshrc"
)

# Create menu options
options=("${!configs[@]}" "quit")

# Show dmenu and get user choice
choice=$(printf '%s\n' "${options[@]}" | dmenu -p 'Edit config file: ')

# Exit if user chose quit or an invalid option
if [[ "$choice" == "quit" || -z "$choice" || -z "${configs[$choice]}" ]]; then
    echo "Program terminated."
    exit 0
fi

# Open the selected config file with nvim in kitty
kitty -e --title virtual-shell nvim "${configs[$choice]}"

