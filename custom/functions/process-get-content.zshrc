# ------------------------------------------------------------------------------
# pgc - Process and extract contents of files and directories into a single file
#
# Usage:
#   pgc [OPTIONS] <file_or_directory> [...]
#
# Options:
#   --only-ext <ext1,ext2,...>     Include only files with these extensions.
#   --exclude-ext <ext1,ext2,...>  Exclude files with these extensions.
#   --output <filename>            Specify output file (default: .temp).
#   --open                         Open the output file in default editor.
#
# Examples:
#   pgc src/ --only-ext "js,ts" --open
#   pgc --exclude-ext "md,txt" --output combined.txt ./docs ./src
#   pgc --open ./
# ------------------------------------------------------------------------------

pgc() {
    local output_file=".temp"
    local only_ext=""
    local exclude_ext=""
    local open_file=false

    # Parse options
    while [[ "$1" == --* ]]; do
        case "$1" in
            --only-ext)
                only_ext=",$(echo "$2" | tr -d ' ' | tr ',' ','),"
                shift 2
                ;;
            --exclude-ext)
                exclude_ext=",$(echo "$2" | tr -d ' ' | tr ',' ','),"
                shift 2
                ;;
            --output)
                output_file="$2"
                shift 2
                ;;
            --open)
                open_file=true
                shift
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

    : > "$output_file"  # Clear the output file

    for item in "$@"; do
        if [[ -f "$item" ]]; then
            local ext="${item##*.}"
            if ([[ -z "$only_ext" || "$only_ext" == *",$ext,"* ]] && [[ -z "$exclude_ext" || "$exclude_ext" != *",$ext,"* ]]); then
                echo "\"$item\n" >> "$output_file"
                awk '{print $0}' "$item" >> "$output_file"
                echo "\"," >> "$output_file"
            fi
        elif [[ -d "$item" ]]; then
            find "$item" -type f | while IFS= read -r file; do
                local ext="${file##*.}"
                if ([[ -z "$only_ext" || "$only_ext" == *",$ext,"* ]] && [[ -z "$exclude_ext" || "$exclude_ext" != *",$ext,"* ]]); then
                    echo "\"$file\n" >> "$output_file"
                    awk '{print $0}' "$file" >> "$output_file"
                    echo "\"," >> "$output_file"
                fi
            done
        else
            echo "Warning: '$item' is not a valid file or directory." >&2
        fi
    done

    # Optionally open in default editor
    if [[ -s "$output_file" && "$open_file" == true ]]; then
        if command -v phpstorm &> /dev/null; then
            phpstorm "$output_file"
        elif command -v code &> /dev/null; then
            code "$output_file"
        elif command -v xdg-open &> /dev/null; then
            xdg-open "$output_file"
        elif command -v open &> /dev/null; then
            open "$output_file"
        else
            echo "Warning: No command found to open the file automatically." >&2
        fi
    fi
}
