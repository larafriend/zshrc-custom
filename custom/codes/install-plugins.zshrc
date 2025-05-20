ZSH_PLUGIN_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

# Ensure zsh-autosuggestions is installed
if [ ! -d "$ZSH_PLUGIN_DIR/zsh-autosuggestions" ]; then
  echo "🔍 Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_PLUGIN_DIR/zsh-autosuggestions"
else
  echo "✅ zsh-autosuggestions already installed."
fi

# Ensure zsh-syntax-highlighting is installed
if [ ! -d "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting" ]; then
  echo "🔍 Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_PLUGIN_DIR/zsh-syntax-highlighting"
else
  echo "✅ zsh-syntax-highlighting already installed."
fi

# Set up plugins
plugins=(
  git
  aliases
  z
  pnpm
  command-not-found
  zsh-autosuggestions
  zsh-syntax-highlighting
)
