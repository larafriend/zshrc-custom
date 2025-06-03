#!/usr/bin/env bash
# setup.sh – Interactive Zsh / Oh-My-Zsh / Powerlevel10k bootstrapper
# -------------------------------------------------------------------
set -e

SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MY_CUSTOM_FOLDER="$SOURCE_DIR/custom"
MY_CUSTOM_FILE="$SOURCE_DIR/custom.zshrc"

OMZ_DIR="$HOME/.oh-my-zsh"
OMZ_CUSTOM_DIR="$OMZ_DIR/custom"
ZSHRC_FILE="$HOME/.zshrc"

IMPORT_LINE='source $HOME/.oh-my-zsh/custom/custom.zshrc'

# ────────────────────────────────────────────────────────────────────
# Helper: confirm with optional default (Y/N)
confirm() {
  local prompt="$1"
  local default="${2:-Y}"
  local response

  [[ "$default" =~ ^[Yy]$ ]] && prompt="$prompt [Y/n]: " || prompt="$prompt [y/N]: "
  read -p "$prompt" response
  response="${response:-$default}"

  case "$response" in
    [yY][eE][sS]|[yY]) return 0 ;;
    *)                 return 1 ;;
  esac
}

echo "🛠  Starting interactive Zsh setup..."
echo

# ────────────────────────────────────────────────────────────────────
# 1. Install Zsh (if missing)
if ! command -v zsh &>/dev/null; then
  if confirm "Zsh is not installed. Install it?"; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      sudo apt update && sudo apt install -y zsh
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      brew install zsh
    else
      echo "⚠️  Unsupported OS for automatic Zsh installation."
      exit 1
    fi
  else
    echo "❌  Zsh installation skipped. Exiting."
    exit 1
  fi
else
  echo "✅  Zsh is already installed."
fi
echo

# ────────────────────────────────────────────────────────────────────
# 2. Install Oh My Zsh
if [[ ! -d "$OMZ_DIR" ]]; then
  if confirm "Oh My Zsh is not installed. Install it?"; then
    RUNZSH=no KEEP_ZSHRC=yes sh -c \
      "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
    echo "❌  Oh My Zsh installation skipped. Exiting."
    exit 1
  fi
else
  echo "✅  Oh My Zsh is already installed."
fi
echo

# ────────────────────────────────────────────────────────────────────
# 3. Copy custom/ folder
if confirm "Copy your 'custom/' folder into $OMZ_CUSTOM_DIR?"; then
  cp -r "$MY_CUSTOM_FOLDER" "$OMZ_DIR/"
  echo "✅  custom/ copied."
else
  echo "❌  Skipped copying custom/."
fi
echo

# ────────────────────────────────────────────────────────────────────
# 4. Copy custom.zshrc
if confirm "Copy custom.zshrc into $OMZ_CUSTOM_DIR?"; then
  cp "$MY_CUSTOM_FILE" "$OMZ_CUSTOM_DIR"
  echo "✅  custom.zshrc copied."
else
  echo "❌  Skipped copying custom.zshrc."
fi
echo

# ────────────────────────────────────────────────────────────────────
# 5. Backup existing .zshrc (if any)
if [[ -f "$ZSHRC_FILE" ]] && confirm "Back up your existing .zshrc?"; then
  BACKUP_FILE="$ZSHRC_FILE.backup.$(date +%Y%m%d%H%M%S)"
  cp "$ZSHRC_FILE" "$BACKUP_FILE"
  echo "🗂  Backup created at $BACKUP_FILE"
else
  echo "ℹ️  No .zshrc backup made."
fi
echo

# ────────────────────────────────────────────────────────────────────
# 6. Inject custom.zshrc import
if confirm "Add custom.zshrc to .zshrc (before Oh My Zsh loads)?"; then
  if grep -q 'source \$ZSH/oh-my-zsh.sh' "$ZSHRC_FILE"; then
    if ! grep -Fxq "$IMPORT_LINE" "$ZSHRC_FILE"; then
      sed -i.bak "/source \$ZSH\/oh-my-zsh.sh/i\\
$IMPORT_LINE
" "$ZSHRC_FILE"
      echo "✅  custom.zshrc import inserted."
    else
      echo "ℹ️  custom.zshrc already imported."
    fi
  else
    echo "⚠️  Couldn't find 'source \$ZSH/oh-my-zsh.sh' in .zshrc – skipped safe insert."
  fi
else
  echo "❌  Skipped modifying .zshrc."
fi
echo

# ────────────────────────────────────────────────────────────────────
# 7. Install Powerlevel10k theme
if confirm "Install the Powerlevel10k theme?"; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
    "$OMZ_CUSTOM_DIR/themes/powerlevel10k" 2>/dev/null || true

  # Switch ZSH_THEME to p10k if not already set
  if ! grep -q '^ZSH_THEME=.*powerlevel10k' "$ZSHRC_FILE"; then
    if grep -q '^ZSH_THEME=' "$ZSHRC_FILE"; then
      sed -i.bak 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$ZSHRC_FILE"
    else
      echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "$ZSHRC_FILE"
    fi
    echo "✅  ZSH_THEME set to powerlevel10k/powerlevel10k."
  else
    echo "ℹ️  ZSH_THEME already points to Powerlevel10k."
  fi
else
  echo "❌  Skipped Powerlevel10k installation."
fi
echo

# ────────────────────────────────────────────────────────────────────
# 8. Install Meslo LGS NF Nerd Font
if confirm "Install Meslo LGS NF Nerd Font (recommended for Powerlevel10k)?"; then
  FONT_FILES=(
    "MesloLGS NF Regular.ttf"
    "MesloLGS NF Bold.ttf"
    "MesloLGS NF Italic.ttf"
    "MesloLGS NF Bold Italic.ttf"
  )

  if [[ "$OSTYPE" == "darwin"* ]]; then
    FONT_PATH="/Library/Fonts"
    ALL_FONTS_PRESENT=true
    for font in "${FONT_FILES[@]}"; do
      if [[ ! -f "$FONT_PATH/$font" ]]; then
        ALL_FONTS_PRESENT=false
        break
      fi
    done

    if $ALL_FONTS_PRESENT; then
      echo "ℹ️  Meslo LGS NF fonts already installed."
    else
      brew tap homebrew/cask-fonts
      brew install --cask font-meslo-lg-nerd-font
      echo "✅  Meslo LGS NF fonts installed."
    fi

  else
    FONT_DIR="$HOME/.local/share/fonts"
    ALL_FONTS_PRESENT=true
    for font in "${FONT_FILES[@]}"; do
      if [[ ! -f "$FONT_DIR/$font" ]]; then
        ALL_FONTS_PRESENT=false
        break
      fi
    done

    if $ALL_FONTS_PRESENT; then
      echo "ℹ️  Meslo LGS NF fonts already installed."
    else
      mkdir -p "$FONT_DIR"
      base_url="https://github.com/romkatv/dotfiles-public/raw/master/.local/share/fonts/NerdFonts"
      for font in "${FONT_FILES[@]}"; do
        curl -fLo "$FONT_DIR/$font" --create-dirs "$base_url/${font// /%20}"
      done
      fc-cache -fv "$FONT_DIR"
      echo "✅  Meslo LGS NF fonts installed."
    fi
  fi

  echo "👉  Select 'Meslo LGS NF' in your terminal’s font settings, then run:"
  echo "    p10k configure"
else
  echo "❌  Skipped font installation."
fi


echo "🎉  Setup complete! Restart your terminal or run:  source ~/.zshrc"
