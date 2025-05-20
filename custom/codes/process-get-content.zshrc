pgc() {
    local output_file=".temp"
    local only_ext=""
    local exclude_ext=""
    : > "$output_file"

    while [[ "$1" == -* ]]; do
        case "$1" in
            --only-ext)
                only_ext="$2"
                shift 2
                ;;
            --exclude-ext)
                exclude_ext="$2"
                shift 2
                ;;
            *)
                echo "Unknown option: $1" >&2
                return 1
                ;;
        esac
    done

    if [[ $# -eq 0 ]]; then
        echo "Error: No files or directories provided." >&2
        return 1
    fi

    for item in "$@"; do
        if [[ -f "$item" ]]; then
            ext="${item##*.}"
            if ([[ -n "$only_ext" && ",$only_ext," == *",$ext,"* ]] || [[ -z "$only_ext" ]]) && [[ ",$exclude_ext," != *",$ext,"* ]]; then
                echo "\"$item\n" >> "$output_file"
                awk '{print $0}' "$item" >> "$output_file"
                echo "\"," >> "$output_file"
            fi
        elif [[ -d "$item" ]]; then
            find "$item" -type f | while IFS= read -r file; do
                ext="${file##*.}"
                if ([[ -n "$only_ext" && ",$only_ext," == *",$ext,"* ]] || [[ -z "$only_ext" ]]) && [[ ",$exclude_ext," != *",$ext,"* ]]; then
                    echo "\"$file\n" >> "$output_file"
                    awk '{print $0}' "$file" >> "$output_file"
                    echo "\"," >> "$output_file"
                fi
            done
        else
            echo "Warning: '$item' is not a valid file or directory." >&2
        fi
    done

    if [[ -s "$output_file" ]]; then
        phpstorm "$output_file"
    fi
}
