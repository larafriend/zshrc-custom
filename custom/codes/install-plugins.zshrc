ZSH_PLUGIN_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"

# Function to ensure a plugin is installed
_plugin_installed() {
  local name="$1"
  local repo_url="$2"
  local target_dir="${3:-$name}"

  if [ ! -d "$ZSH_PLUGIN_DIR/$target_dir" ]; then
    echo "🔍 Installing $name..."
    git clone --depth=1 "$repo_url" "$ZSH_PLUGIN_DIR/$target_dir"
  fi
}

# Install plugins using the helper function
_plugin_installed "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
_plugin_installed "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"
_plugin_installed "pnpm" "https://github.com/ntnyq/omz-plugin-pnpm.git"

# Configure plugins
plugins+=(
  git
  aliases
  z
  pnpm
  command-not-found
  zsh-autosuggestions
  zsh-syntax-highlighting
)
