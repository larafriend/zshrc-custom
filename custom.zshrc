# Define the directory containing custom scripts
ZSH_CODES_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/codes"

# Load all *.zshrc files from the custom codes directory
if [[ -d "$ZSH_CODES_DIR" ]]; then
  for config_file in "$ZSH_CODES_DIR"/*.zshrc; do
    # Ensure the file exists and is a regular file before sourcing
    [[ -f "$config_file" ]] && source "$config_file"
  done
fi
