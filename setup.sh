#!/bin/bash

# =========================================
# setup.sh for .utilc
# default: use only（remove .git）
# --dev  : developer mode (preserved .git）
# =========================================

REPO_URL="https://github.com/AsahiAGM/.utilc.git"
UTILC_DIR="$HOME/.utilc"
DEV_MODE=false

if [[ $# -eq 1 && $1 == "--dev" ]]; then
    DEV_MODE=true
fi

if [ ! -d "$UTILC_DIR" ]; then
    echo "Cloning .utilc repository..."
    git clone "$REPO_URL" "$UTILC_DIR" || { echo "Clone failed"; exit 1; }
else
    echo ".utilc already exists. Pulling latest version..."
    git -C "$UTILC_DIR" pull || { echo "Pull failed"; exit 1; }
fi

# use only
if [ "$DEV_MODE" = false ]; then
    if [ -d "$UTILC_DIR/.git" ]; then
        echo "Removing .git to make this installation read-only..."
        echo -e "\e[33mIf you want to participate in development and add new features, run setup.sh with --dev :)\e[0m"
        rm -rf "$UTILC_DIR/.git"
    fi
fi

# add .bashrc
if ! grep -Fxq "source \$Home/.utilc/util.sh" "$HOME/.bashrc"; then
    echo "Adding source line to ~/.bashrc"
    echo "source \$HOME/.utilc/util.sh" >> "$HOME/.bashrc"
fi

source "$UTILC_DIR/util.sh"

echo
echo "setup .utilc complete!"
if [ "$DEV_MODE" = true ]; then
    echo "Development mode enabled: .git directory preserved."
else
    echo "Read-only mode enabled: .git directory removed."
fi