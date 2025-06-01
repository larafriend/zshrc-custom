# ------------------------------------------------------------------------------
# pgc - Process and extract contents of files and directories into a single file
#
# Usage:
#   pgc [OPTIONS] <path> [...]
#
# Options:
#   --only <pattern1,pattern2,...>     Include only files matching these glob patterns.
#   --exclude <pattern1,pattern2,...>  Exclude files matching these glob patterns.
#   --output <filename>                Specify output file (default: .temp).
#   --open                             Open the output file in your editor.
#
# Glob pattern cheatsheet (comma‑separated, no spaces):
#   folder              # whole directory
#   file.ext            # single file
#   *.ext               # any file with ext
#   file.*              # any extension
#   folder/*.ext        # one level deep
#   folder/img*.ext     # starting with img
#   folder/img/*.ext    # in img subdir
#   folder/**/*.ext     # any depth under folder
#   folder/**/img/*.ext # img dirs at any depth
#   **/*.ext            # anywhere under current dir
#
# Examples:
#   # Only JS/TS files inside src
#   pgc src --only "src/**/*.js,src/**/*.ts" --open
#
#   # Combine everything except markdown or txt under docs and src
#   pgc ./docs ./src --exclude "**/*.md,**/*.txt" --output combined.txt
#
#   # Dump all PHP files except tests directory
#   pgc project --only "**/*.php" --exclude "**/tests/**"
#
#   # Include images but skip thumbnails
#   pgc assets --only "**/*.png,**/*.jpg" --exclude "**/*thumb*.*"
#
# Notes:
#   * Patterns are resolved with zsh's extended globbing (set -o extended_glob).
#   * A file is included only if it matches at least one --only pattern (when --only
#     is given) and none of the --exclude patterns.
# ------------------------------------------------------------------------------

pgc() {
    emulate -L zsh
    set -o extended_glob

    local output_file=".temp"
    local -a only_patterns=()
    local -a exclude_patterns=()
    local open_file=false

    # Parse options
    while [[ $# -gt 0 && "$1" == --* ]]; do
        case "$1" in
            --only)
                IFS=',' read -rA only_patterns <<< "${2// /}"
                shift 2
                ;;
            --exclude)
                IFS=',' read -rA exclude_patterns <<< "${2// /}"
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

    if (( $# == 0 )); then
        echo "Error: No files or directories provided." >&2
        return 1
    fi

    : > "$output_file"  # Truncate output file

    local item file rel include pat
    for item in "$@"; do
        if [[ -f $item ]]; then
            rel=${item#./}
            include=1

            if (( ${#only_patterns[@]} )); then
                include=0
                for pat in "${only_patterns[@]}"; do
                    if [[ $rel == ${~pat} ]]; then
                        include=1
                        break
                    fi
                done
            fi

            if (( include && ${#exclude_patterns[@]} )); then
                for pat in "${exclude_patterns[@]}"; do
                    if [[ $rel == ${~pat} ]]; then
                        include=0
                        break
                    fi
                done
            fi

            (( include )) && {
                printf '"%s\n' "$item" >> "$output_file"
                cat -- "$item" >> "$output_file"
                printf '\",\n' >> "$output_file"
            }
        elif [[ -d $item ]]; then
            find "$item" -type f | while IFS= read -r file; do
                rel=${file#./}
                include=1

                if (( ${#only_patterns[@]} )); then
                    include=0
                    for pat in "${only_patterns[@]}"; do
                        if [[ $rel == ${~pat} ]]; then
                            include=1
                            break
                        fi
                    done
                fi

                if (( include && ${#exclude_patterns[@]} )); then
                    for pat in "${exclude_patterns[@]}"; do
                        if [[ $rel == ${~pat} ]]; then
                            include=0
                            break
                        fi
                    done
                fi

                (( include )) && {
                    printf '"%s\n' "$file" >> "$output_file"
                    cat -- "$file" >> "$output_file"
                    printf '\",\n' >> "$output_file"
                }
            done
        else
            echo "Warning: '$item' is not a valid file or directory." >&2
        fi
    done

    # Optionally open in default editor
    if [[ -s "$output_file" && $open_file == true ]]; then
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
