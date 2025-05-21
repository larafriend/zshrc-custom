# ------------------------------------------------------------------------------
# pgd - Generate Git diff output or an AI prompt for commit message generation
#
# Usage:
#   pgd [OPTIONS] <file1> <file2> ...
#
# Options:
#   --prompt                Format the diff as a prompt for AI-based commit message generation.
#   --output <filename>     Specify the output file (default: .temp).
#   --open                  Open the output file with the default system editor.
#
# Examples:
#   pgd file1.js file2.ts               # Save raw diff to .temp
#   pgd --prompt src/                   # Save prompt-formatted diff for AI input
#   pgd --prompt --output diff.txt src/ --open
# ------------------------------------------------------------------------------

pgd() {
    local output_file=".temp"
    local prompt_mode=false
    local open_file=false
    local files=()

    local formatted_diff_template="
Generate a git commit message following this structure, write it in markdown:
1. First line: conventional commit format (type: concise description) (use semantic types: feat, fix, docs, style, refactor, perf, test, chore, etc.)
2. Optional bullet points if more context helps:
   - Keep the second line blank
   - Keep them short and direct
   - Focus on what changed
   - Always be terse
   - Don't overly explain
   - Drop any fluffy or formal language

Return ONLY the commit message - no introduction, no explanation, no quotes around it.

Very important: Do not respond with any of the examples. Your message must be based off the diff that is about to be provided, with a little bit of styling informed by the recent commits you're about to see.

Use Markdown formatting.

Here's the diff:

{{code}}"

    # Parse options
    while [[ "$1" == --* ]]; do
        case "$1" in
            --prompt)
                prompt_mode=true
                shift
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

    # Collect file arguments
    if [[ $# -eq 0 ]]; then
        echo "Usage: pgd [--prompt] [--output FILE] [--open] file1 file2 ..." >&2
        return 1
    fi
    files=("$@")

    # Get diff from git
    local diff_content
    diff_content="$(git diff HEAD -- "${files[@]}")"

    # Format output
    if $prompt_mode; then
        local formatted_prompt="${formatted_diff_template//{{code}}/$diff_content}"
        echo "$formatted_prompt" > "$output_file"
    else
        echo "$diff_content" > "$output_file"
    fi

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
