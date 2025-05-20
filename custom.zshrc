ZSH_CODES_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/codes"

if [ -d "$ZSH_CODES_DIR" ]; then
    for config_file in "$ZSH_CODES_DIR"/*.zshrc; do
        [ -f "$config_file" ] && source "$config_file"
    done
fi
