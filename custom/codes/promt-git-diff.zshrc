pgd() {
    local output_file=".temp"
    local formatted_diff="
Generate a git commit message following this structure, write it in markdown:
1. First line: conventional commit format (type: concise description) (remember to use semantic types like feat, fix, docs, style, refactor, perf, test, chore, etc.)
2. Optional bullet points if more context helps:
   - Keep the second line blank
   - Keep them short and direct
   - Focus on what changed
   - Always be terse
   - Don't overly explain
   - Drop any fluffy or formal language

Return ONLY the commit message - no introduction, no explanation, no quotes around it.

Examples:
feat: add user auth system

- Add JWT tokens for API auth
- Handle token refresh for long sessions

fix: resolve memory leak in worker pool

- Clean up idle connections
- Add timeout for stale workers

Simple change example:
fix: typo in README.md

Very important: Do not respond with any of the examples. Your message must be based off the diff that is about to be provided, with a little bit of styling informed by the recent commits you're about to see.

Use Markdown formatting.

Here's the diff:

{{code}}"

    local prompt_mode=false
    local files=()
    : > "$output_file"

    # Revisar argumentos
    for arg in "$@"; do
        if [[ "$arg" == "--prompt" ]]; then
            prompt_mode=true
        else
            files+=("$arg")
        fi
    done

    if [ ${#files[@]} -eq 0 ]; then
        echo "Usage: pgd [--prompt] file1 file2 ..."
        return 1
    fi

    local diff_content="$(git diff HEAD -- "${files[@]}")"

    if $prompt_mode; then
        formatted_diff=${formatted_diff//{{code}}/$diff_content}
        echo "$formatted_diff" > "$output_file"
    else
        echo "$diff_content" > "$output_file"
    fi

    if [[ -s "$output_file" ]]; then
        phpstorm "$output_file"
    fi
}
