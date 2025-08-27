#!/usr/bin/env bash

set -euo pipefail

IGNORE_PATHS=(.git)
SHEBANG_REGEX='^#!.*\b(bash|sh|dash|ksh|zsh)\b'

if ! command -v shellcheck &>/dev/null; then
  echo "ShellCheck is not installed ❌"
  exit 1
fi

# Build a dynamic 'find' expression that prunes IGNORE_PATHS
find_expr=()
for p in "${IGNORE_PATHS[@]}"; do
  find_expr+=(-path "./$p" -prune -o)
done
find_expr+=(-type f -print0)

mapfile -d '' -t candidates < <(find . "${find_expr[@]}")

# Keep the shell scripts (either having .sh extension or containing a shebang)
files=()
for f in "${candidates[@]}"; do
  if [[ $f == *.sh ]]; then
    files+=("$f")
  elif head -n 1 "$f" | grep -Eq "$SHEBANG_REGEX"; then
    files+=("$f")
  fi
done

# Run ShellCheck
if ((${#files[@]})); then
  printf 'Linting %d shell script(s) ⏳\n' "${#files[@]}"
  printf '> %s\n' "${files[@]}"
  shellcheck "${files[@]}"
else
  echo "No shell scripts found ℹ️"
fi

echo "ShellCheck is done linting ✅"
