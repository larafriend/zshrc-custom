#!/bin/bash

set -e

# Directory where this script is located
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Target locations
ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM_DIR="$ZSH_DIR/custom"
ZSHRC_FILE="$HOME/.zshrc"
CUSTOM_FILE="$HOME/custom.zshrc"
IMPORT_LINE='source $HOME/custom.zshrc'

echo "🔍 Checking if Zsh is installed..."

# Install Zsh if missing
if ! command -v zsh >/dev/null 2>&1; then
    echo "⏬ Zsh is not installed. Installing..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt update && sudo apt install -y zsh
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install zsh
    else
        echo "⚠️ Unsupported OS for automatic Zsh installation."
        exit 1
    fi
else
    echo "✅ Zsh is already installed."
fi

echo "🔍 Checking if Oh My Zsh is installed..."

# Install Oh My Zsh if missing
if [ ! -d "$ZSH_DIR" ]; then
    echo "⏬ Installing Oh My Zsh..."
    RUNZSH=no KEEP_ZSHRC=yes sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "✅ Oh My Zsh is already installed."
fi

# Copy your custom folder to ~/.oh-my-zsh/custom/
echo "📂 Copying your 'custom/' folder to $ZSH_CUSTOM_DIR..."
cp -r "$SOURCE_DIR/custom" "$ZSH_CUSTOM_DIR/"

# Copy custom.zshrc to $HOME
echo "📄 Copying custom.zshrc to $CUSTOM_FILE..."
cp "$SOURCE_DIR/custom.zshrc" "$CUSTOM_FILE"

# Add import line to .zshrc if not present
if ! grep -Fxq "$IMPORT_LINE" "$ZSHRC_FILE"; then
    echo "🔗 Adding source line to .zshrc..."
    echo "" >> "$ZSHRC_FILE"
    echo "# Load custom configuration" >> "$ZSHRC_FILE"
    echo "$IMPORT_LINE" >> "$ZSHRC_FILE"
else
    echo "✅ .zshrc already includes custom.zshrc"
fi

echo "✅ All done! Restart your terminal or run: source ~/.zshrc"
