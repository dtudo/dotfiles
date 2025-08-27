#!/usr/bin/env bash
set -euo pipefail

dot_log() {
  printf '%s\n' "$*"
}

dot_error() {
  dot_log "$1" >&2
  exit 1
}

dot_confirm() {
  local prompt=${1:-"Continue?"}
  read -r -p "$prompt [y/N] " ans
  [[ $ans =~ ^[Yy]$ ]]
}

dot_restore_pre_backup() {
  # Restore and unlink
  local target_path="$1"
  local pre_backup="${target_path}.pre-dot-backup"

  if [[ -f "$pre_backup" ]]; then
    cp -a -- "$pre_backup" "$target_path"
    dot_log "> Restored .pre-dot-backup for $target_path"
  else
    dot_log "> No .pre-dot-backup found for $target_path (skipped)"
  fi
}

dot_delete_backups() {
  local target_path="$1"

  [[ -z "$target_path" ]] && dot_error 'invalid path'

  rm -rf -- "${target_path}.pre-dot-backup"
  rm -rf -- "${target_path}".dot-backup-*
}

dot_unlink() {
  local source_path
  source_path="$1"

  local target_path
  target_path="$2"

  # Do checks
  local is_linked=false
  if [[ -L $target_path && "$(readlink -- "$target_path")" == "$source_path" ]]; then
    is_linked=true
  fi

  # Unlink
  if [[ "$is_linked" == true ]]; then
    unlink "$target_path"
    dot_log "> Unlinked $target_path → $source_path"
  else
    dot_log "> Link not found $target_path → $source_path"
  fi

  # Restore
  dot_restore_pre_backup "$target_path"
}

dot_uninstall() {
  dot_confirm 'This will uninstall everything. Continue?' || {
    dot_log "aborted."
    exit 0
  }

  # Unlink dotfiles
  # shellcheck disable=SC1091 # source not resolved
  source "$DOT_DIR/dotfiles.config" "$DOT_DIR"
  # shellcheck disable=SC2154 # var is referenced but not assigned
  for entry in "${dot_files_mapping[@]}"; do
    src="${entry%%:*}"
    dest="${entry##*:}"
    dot_unlink "$src" "$dest"
    dot_delete_backups "$dest"
  done

  dot_log "> Close and reopen your terminal or run 'source ~/.zshrc'"
}

dot_uninstall
