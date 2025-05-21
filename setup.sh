#!/bin/bash

set -e

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MY_CUSTOM_FOLDER="$SOURCE_DIR/custom"
MY_CUSTOM_FILE="$SOURCE_DIR/custom.zshrc"

OMZ_DIR="$HOME/.oh-my-zsh"
OMZ_CUSTOM_DIR="$OMZ_DIR/custom"
ZSHRC_FILE="$HOME/.zshrc"

IMPORT_LINE='source $HOME/.oh-my-zsh/custom/custom.zshrc'

# Helper: confirm with user
confirm() {
  read -p "$1 [y/N]: " response
  case "$response" in
    [yY][eE][sS]|[yY]) return 0 ;;
    *) return 1 ;;
  esac
}

echo "🛠 Starting interactive Zsh setup..."

# Step 1: Zsh installation
if ! command -v zsh >/dev/null 2>&1; then
  if confirm "Zsh is not installed. Do you want to install it?"; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      sudo apt update && sudo apt install -y zsh
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      brew install zsh
    else
      echo "⚠️ Unsupported OS for automatic Zsh installation."
      exit 1
    fi
  else
    echo "❌ Skipping Zsh installation. Exiting..."
    exit 1
  fi
else
  echo "✅ Zsh is already installed."
fi

# Step 2: Oh My Zsh installation
if [ ! -d "$OMZ_DIR" ]; then
  if confirm "Oh-My-Zsh is not installed. Do you want to install it?"; then
    RUNZSH=no KEEP_ZSHRC=yes sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    echo "❌ Skipping Oh My Zsh installation. Exiting..."
    exit 1
  fi
else
  echo "✅ Oh My Zsh is already installed."
fi

# Step 3: Copy custom folder
if confirm "Do you want to copy your 'custom/' folder into $OMZ_CUSTOM_DIR?"; then
  cp -r "$MY_CUSTOM_FOLDER" "$OMZ_DIR/"
  echo "✅ Copied custom/"
else
  echo "❌ Skipped copying custom/"
fi

# Step 4: Copy custom.zshrc
if confirm "Do you want to copy your 'custom.zshrc' into $OMZ_CUSTOM_DIR?"; then
  cp "$MY_CUSTOM_FILE" "$OMZ_CUSTOM_DIR"
  echo "✅ Copied custom.zshrc to $OMZ_CUSTOM_DIR"
else
  echo "❌ Skipped copying custom.zshrc"
fi

# Step 5: Update .zshrc
if confirm "Do you want to modify your .zshrc to include custom.zshrc before Oh My Zsh loads?"; then
  if grep -q 'source \$ZSH/oh-my-zsh.sh' "$ZSHRC_FILE"; then
    if ! grep -Fxq "$IMPORT_LINE" "$ZSHRC_FILE"; then
      # Insert IMPORT_LINE before Oh My Zsh sourcing
      sed -i.bak "/source \$ZSH\/oh-my-zsh.sh/i\\
$IMPORT_LINE
" "$ZSHRC_FILE"
      echo "✅ Inserted custom.zshrc before oh-my-zsh.sh"
    else
      echo "ℹ️ .zshrc already includes custom.zshrc"
    fi
  else
    echo "⚠️ Couldn't find 'source \$ZSH/oh-my-zsh.sh' in .zshrc. Skipping safe insert."
  fi
else
  echo "❌ Skipped modifying .zshrc"
fi


echo "🎉 Setup finished! You can now restart your terminal or run: source ~/.zshrc"
