# Copyright (c) 2025 Chiba University, Taiki Matsumura

please() {
  if [ "$#" -gt 0 ]; then
    sudo "$@"
    return
  fi

  local last
  last=$(fc -ln -1)
  if [ -z "$last" ]; then
    echo "No previous command." >&2
    return 1
  fi
  echo "sudo $last"
  sudo $last
}

cdf() {
  local file dir
  file=$(find . -maxdepth 5 -type f 2>/dev/null | fzf) || return 1
  dir=$(dirname "$file")
  cd "$dir" || return 1
  echo "cd $dir"
}

mkcdtmp() {
  local dir
  dir=$(mktemp -d "${TMPDIR:-/tmp}/tmpdir.XXXXXX")
  cd "$dir" || return 1
  echo "cd $dir"
}

histgrep() {
  if [ $# -eq 0 ]; then
    echo "Usage: histgrep PATTERN" >&2
    return 1
  fi
  history | grep --color=auto "$@"
}

