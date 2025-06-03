#!/usr/bin/env bash
# setup.sh – Interactive Zsh / Oh-My-Zsh / Powerlevel10k Bootstrapper

set -euo pipefail

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MY_CUSTOM_FOLDER="$SOURCE_DIR/custom"
MY_CUSTOM_FILE="$SOURCE_DIR/custom.zshrc"
OMZ_DIR="$HOME/.oh-my-zsh"
OMZ_CUSTOM_DIR="$OMZ_DIR/custom"
ZSHRC_FILE="$HOME/.zshrc"
IMPORT_LINE='source $HOME/.oh-my-zsh/custom/custom.zshrc'

divider() {
  echo -e "\n────────────────────────────────────────────────────────────\n"
}

step() {
  echo -e "\n🔹 Step $1: $2\n"
}

confirm() {
  local prompt="$1"
  local default="${2:-Y}"
  local response
  [[ "$default" =~ ^[Yy]$ ]] && prompt="$prompt [Y/n]: " || prompt="$prompt [y/N]: "
  read -rp "$prompt" response
  response="${response:-$default}"
  [[ "$response" =~ ^[Yy]([Ee][Ss])?$ ]] && return 0 || return 1
}

install_zsh() {
  step 1 "Zsh Installation"
  if ! command -v zsh &>/dev/null; then
    if confirm "Zsh is not installed. Do you want to install it?"; then
      if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt update && sudo apt install -y zsh
      elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install zsh
      else
        echo "⚠️  Unsupported OS for automatic installation."
        exit 1
      fi
    else
      echo "❌ Skipping Zsh installation. Aborting."
      exit 1
    fi
  else
    echo "✅ Zsh is already installed."
  fi
}

install_oh_my_zsh() {
  step 2 "Oh My Zsh Installation"
  if [[ ! -d "$OMZ_DIR" ]]; then
    if confirm "Oh My Zsh is not installed. Do you want to install it?"; then
      RUNZSH=no KEEP_ZSHRC=yes sh -c \
        "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
      echo "❌ Skipping Oh My Zsh installation. Aborting."
      exit 1
    fi
  else
    echo "✅ Oh My Zsh is already installed."
  fi
}

copy_custom_folder() {
  step 3 "Copy custom/ Folder"
  if confirm "Copy the 'custom/' folder into $OMZ_CUSTOM_DIR?"; then
    cp -r "$MY_CUSTOM_FOLDER" "$OMZ_DIR/"
    echo "✅ custom/ folder copied."
  else
    echo "❌ Skipped copying custom/ folder."
  fi
}

copy_custom_zshrc() {
  step 4 "Copy custom.zshrc"
  if confirm "Copy custom.zshrc into $OMZ_CUSTOM_DIR?"; then
    cp "$MY_CUSTOM_FILE" "$OMZ_CUSTOM_DIR"
    echo "✅ custom.zshrc copied."
  else
    echo "❌ Skipped copying custom.zshrc."
  fi
}

backup_zshrc() {
  step 5 "Backup .zshrc"
  if [[ -f "$ZSHRC_FILE" ]] && confirm "Back up your current .zshrc file?"; then
    BACKUP_FILE="$ZSHRC_FILE.backup.$(date +%Y%m%d%H%M%S)"
    cp "$ZSHRC_FILE" "$BACKUP_FILE"
    echo "🗂  Backup created at $BACKUP_FILE"
  else
    echo "ℹ️  No backup created."
  fi
}

inject_custom_zshrc() {
  step 6 "Inject custom.zshrc into .zshrc"
  if confirm "Add custom.zshrc source before Oh My Zsh loads?"; then
    if grep -q 'source \$ZSH/oh-my-zsh.sh' "$ZSHRC_FILE"; then
      if ! grep -Fxq "$IMPORT_LINE" "$ZSHRC_FILE"; then
        sed -i.bak "/source \$ZSH\/oh-my-zsh.sh/i\\
$IMPORT_LINE
" "$ZSHRC_FILE"
        echo "✅ custom.zshrc import inserted."
      else
        echo "ℹ️  custom.zshrc is already imported."
      fi
    else
      echo "⚠️  Could not find 'source \$ZSH/oh-my-zsh.sh' – skipping safe insertion."
    fi
  else
    echo "❌ Skipped modifying .zshrc."
  fi
}

install_powerlevel10k() {
  step 7 "Powerlevel10k Theme Installation"
  if confirm "Install the Powerlevel10k theme?"; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
      "$OMZ_CUSTOM_DIR/themes/powerlevel10k" 2>/dev/null || true

    if ! grep -q '^ZSH_THEME=.*powerlevel10k' "$ZSHRC_FILE"; then
      if grep -q '^ZSH_THEME=' "$ZSHRC_FILE"; then
        sed -i.bak 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC_FILE"
      else
        echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$ZSHRC_FILE"
      fi
      echo "✅ ZSH_THEME set to Powerlevel10k."
    else
      echo "ℹ️  ZSH_THEME is already set to Powerlevel10k."
    fi
  else
    echo "❌ Skipped Powerlevel10k installation."
  fi
}

install_fonts() {
  step 8 "Install Meslo LGS NF Nerd Font"
  if confirm "Install the recommended Meslo LGS NF Nerd Font?"; then
    FONT_FILES=(
      "MesloLGS NF Regular.ttf"
      "MesloLGS NF Bold.ttf"
      "MesloLGS NF Italic.ttf"
      "MesloLGS NF Bold Italic.ttf"
    )

    if [[ "$OSTYPE" == "darwin"* ]]; then
      brew tap homebrew/cask-fonts
      brew install --cask font-meslo-lg-nerd-font
    else
      FONT_DIR="$HOME/.local/share/fonts"
      mkdir -p "$FONT_DIR"
      base_url="https://github.com/romkatv/dotfiles-public/raw/master/.local/share/fonts/NerdFonts"
      for font in "${FONT_FILES[@]}"; do
        curl -fLo "$FONT_DIR/$font" --create-dirs "$base_url/${font// /%20}"
      done
      fc-cache -fv "$FONT_DIR"
    fi
    echo "✅ Meslo LGS NF fonts installed."
    echo "👉  Set your terminal's font to 'Meslo LGS NF' and run:"
    echo "    p10k configure"
  else
    echo "❌ Skipped font installation."
  fi
}

main() {
  echo -e "🛠  Welcome to the interactive Zsh + Oh My Zsh + Powerlevel10k setup\n"
  divider
  install_zsh
  divider
  install_oh_my_zsh
  divider
  copy_custom_folder
  divider
  copy_custom_zshrc
  divider
  backup_zshrc
  divider
  inject_custom_zshrc
  divider
  install_powerlevel10k
  divider
  install_fonts
  divider
  echo -e "🎉 Setup complete! Restart your terminal or run:\n\n  source ~/.zshrc\n"
}

main
