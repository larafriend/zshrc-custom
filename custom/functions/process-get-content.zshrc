# pgc – Process & concatenate files/directories into a single text file
# ----------------------------------------------------------------------
# DESCRIPTION:
#   Concatenates the contents of one or more files and/or directories into
#   a single output file. Supports filtering with include/exclude patterns,
#   appending to existing output, and opening the result in an editor.
#
# FEATURES:
#   * Efficient file handling (reuses output FD)
#   * Clean, robust option parsing using zparseopts
#   * Filtering support with --only and --exclude
#   * Optional output appending with --append
#   * GUI editor integration with --open
#   * Verbose mode with --verbose to print processed files
#
# OPTIONS:
#   --only=PAT1,PAT2,...      Include only files matching these glob patterns
#   --exclude=PAT1,PAT2,...   Exclude files matching these glob patterns
#   --output=FILE             Specify the output file (default: .temp)
#   --append                  Append to the output file instead of overwriting
#   --open                    Open the result in a GUI editor (phpstorm/code/...)
#   --verbose                 Print the list of files being processed
#
# USAGE EXAMPLES:
#   # Basic: Concatenate all *.txt files in current directory
#     pgc *.txt
#
#   # Recursively collect files from directory and concatenate
#     pgc ./docs
#
#   # Concatenate files, excluding all *.log files
#     pgc --exclude="*.log" *.txt ./logs
#
#   # Concatenate only markdown and txt files from a folder
#     pgc --only="*.md,*.txt" ./notes
#
#   # Append new content to an existing file
#     pgc --append --output=combined.txt *.md
#
#   # Open the result in your preferred GUI editor
#     pgc --open --output=all_code.txt *.py
#
#   # Combine and filter with both include and exclude
#     pgc --only="*.md" --exclude="README.md" ./docs
#
#   # Verbose: show all processed files
#     pgc --verbose --output=summary.txt *.conf
# ----------------------------------------------------------------------

function pgc() {
  emulate -L zsh -o extended_glob -o null_glob

  # Disable xtrace to suppress debug output even if globally enabled
  set +x 2>/dev/null

  #‑‑‑‑‑ helpers ‑‑‑‑‑
  warn() print -u2 -P "%F{yellow}pgc:%f $*"
  die()  { print -u2 -P "%F{red}pgc:%f $*"; return 1 }

  #‑‑‑‑‑ defaults ‑‑‑‑‑
  local output_file=.temp append=false open=false verbose=false
  local -a only_patterns exclude_patterns specs

  #‑‑‑‑‑ option parsing ‑‑‑‑‑
  local -a _only _exclude _output _append _open _verbose
  zparseopts -D -E -K \
    -only:=_only     -exclude:=_exclude \
    -output:=_output -append=_append \
    -open=_open      -verbose=_verbose || return 1

  (( $# )) || die "No paths supplied."
  specs=("$@")

  (( ${#_only}    )) && IFS=',' read -rA only_patterns    <<< "${_only[2]// /}"
  (( ${#_exclude} )) && IFS=',' read -rA exclude_patterns <<< "${_exclude[2]// /}"
  (( ${#_output}  )) && output_file=${_output[2]}
  (( ${#_append}  )) && append=true
  (( ${#_open}    )) && open=true
  (( ${#_verbose} )) && verbose=true

  #‑‑‑‑‑ collect positional specs ‑‑‑‑‑
  local -a targets
  local spec
  for spec in "${specs[@]}"; do
    local -a hits=( ${(N)~spec} )

    if [[ -e $spec ]]; then
        hits=( $spec )
    else
        hits=( ${(N)~spec} )
    fi

    (( ${#hits} )) || { warn "'$spec' did not match"; continue }
    local m

    set +x 2>/dev/null

    for m in "${hits[@]}"; do
      if [[ -d $m ]]; then
        targets+=( $m/**/*(DN.) )  # recurse: dotfiles + plain files only
      elif [[ -f $m ]]; then
        targets+=( $m )
      else
        warn "'$m' is not a file or directory"
      fi
    done
  done
  (( ${#targets} )) || die "No files collected."

  # unique while preserving original order
  typeset -aU targets=("${targets[@]}")

  #‑‑‑‑‑ filtering ‑‑‑‑‑
  local -a filtered=("${targets[@]}")
  if (( ${#only_patterns} )); then
    local pat; local -a keep
    for pat in "${only_patterns[@]}"; do
      keep+=( ${(M)filtered:#${~pat}} )
    done
    filtered=( ${(u)keep} )   # unique again
  fi
  if (( ${#exclude_patterns} )); then
    local pat
    for pat in "${exclude_patterns[@]}"; do
      filtered=( ${(R)filtered:#${~pat}} )
    done
  fi
  (( ${#filtered} )) || die "No files remain after filtering."

  #‑‑‑‑‑ emit ‑‑‑‑‑
  local redir=">"; $append && redir=">>"
  local fd; eval "exec {fd}$redir'$output_file'"

  local f
  for f in "${filtered[@]}"; do
    $verbose && print -P "%F{cyan}Processing:%f $f"
    print -u $fd -- "\"$f"
    cat -- "$f" >&$fd
    print -u $fd -- "\","  # comma separator
  done
  exec {fd}>&-

  #‑‑‑‑‑ open in editor if requested ‑‑‑‑‑
  if $open && [[ -s $output_file ]]; then
    local opener
    for opener in phpstorm code xdg-open open; do
      if command -v $opener &>/dev/null; then
        $opener "$output_file" &!
        break
      fi
    done
    [[ -z $opener ]] && warn "No GUI opener found."
  fi
}
