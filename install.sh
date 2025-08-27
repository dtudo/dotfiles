#!/usr/bin/env bash
set -euo pipefail

dot_has() {
  command -v "$1" >/dev/null 2>&1
}

dot_log() {
  printf '%s\n' "$*"
}

dot_error() {
  dot_log "$1" >&2
  exit 1
}

dot_default_DOT_DIR() {
  printf %s "${HOME}/.dotfiles"
}

dot_DOT_DIR() {
  if [ -n "${DOT_DIR:-}" ]; then
    printf %s "${DOT_DIR}"
  else
    dot_default_DOT_DIR
  fi
}

dot_github_repo() {
  printf %s "https://github.com/dtudo/dotfiles.git"
}

dot_repo_branch() {
  local ref
  ref="$(git ls-remote --symref "$(dot_github_repo)" HEAD 2>/dev/null | awk '/^ref:/ {sub("refs/heads/","",$2); print $2; exit}')"
  printf %s "${ref:-main}"
}

dot_link() {
  # Backup and symlink
  local source_path="$1"
  local target_path="$2"
  local datetime
  datetime="$(date +%Y-%m-%d_%H-%M-%S)"

  # Create empty dotfile if none exists
  [[ -f $source_path ]] || : >"$source_path"

  # Do checks
  local is_linked
  is_linked=false=false
  if [[ -L $target_path && "$(readlink -- "$target_path")" == "$source_path" ]]; then
    is_linked=true
  fi

  local target_exists
  target_exists=false
  if [[ -e $target_path || -L $target_path ]]; then
    target_exists=true
  fi

  # Backup
  if [[ "$is_linked" == false && "$target_exists" == true ]]; then
    # If it's the first time linking, save a pre-dot-backup
    cp -aL -- "$target_path" "${target_path}.pre-dot-backup"
    rm -rf -- "$target_path"
    dot_log "> Created pre-dot-backup: ${target_path}.pre-dot-backup"
  elif [[ "$is_linked" == true && "$target_exists" == true ]]; then
    # Backup existing dot file
    cp -aL -- "$target_path" "${target_path}.dot-backup-$datetime"
    dot_log "> Created dot-backup: ${target_path}.dot-backup-$datetime"
  fi

  # Link
  ln -sfn -- "$source_path" "$target_path"
  dot_log "> Linked $target_path → $source_path"
}

dot_install() {
  local INSTALL_DIR
  INSTALL_DIR="$(dot_DOT_DIR)"

  local REPO
  REPO="$(dot_github_repo)"

  local BRANCH
  BRANCH="$(dot_repo_branch)"

  # Check if git is installed
  if ! dot_has git; then
    dot_error "Error: git is required"
  fi

  # Check install dir
  if [ -e "$INSTALL_DIR" ] && [ ! -d "$INSTALL_DIR" ]; then
    dot_error "Error: $INSTALL_DIR exists but is not a directory"
  fi

  if [ -d "$INSTALL_DIR/.git" ]; then
    local url
    url="$(git -C "$INSTALL_DIR" config --get remote.origin.url || true)"
    if [ "$url" != "$REPO" ]; then
      dot_error "Error: $INSTALL_DIR exists but points to a different repo ($url)"
    fi

    local branch
    branch="$(git -C "$INSTALL_DIR" rev-parse --abbrev-ref HEAD)"
    if [ "$branch" != "$BRANCH" ] && ! git -C "$INSTALL_DIR" checkout -f --quiet "$BRANCH"; then
      dot_error "Error: failed to switch branch to $BRANCH in $INSTALL_DIR"
    fi
  elif [ -n "$(ls -A "$INSTALL_DIR" 2>/dev/null)" ]; then
    dot_error "Error: $INSTALL_DIR is not empty. Move it or set DOT_DIR to another path"
  fi

  # Sync repo
  if [ -d "$INSTALL_DIR/.git" ]; then
    echo "> Updating dotfiles in $INSTALL_DIR (branch: $BRANCH)..."
    git -C "$INSTALL_DIR" fetch --depth=1 origin "$BRANCH"
    git -C "$INSTALL_DIR" checkout -f "$BRANCH"
    git -C "$INSTALL_DIR" reset --hard "origin/$BRANCH"
  else
    echo "=> Cloning dotfiles into $INSTALL_DIR (branch: $BRANCH)..."
    mkdir -p "$INSTALL_DIR"
    rm -rf "$INSTALL_DIR/.git" 2>/dev/null || true
    git clone --depth=1 --branch "$BRANCH" "$REPO" "$INSTALL_DIR"
  fi

  # Link dotfiles
  # shellcheck disable=SC1091 # source not resolved
  source "$INSTALL_DIR/dotfiles.config" "$INSTALL_DIR"
  # shellcheck disable=SC2154 # var is referenced but not assigned
  for entry in "${dot_files_mapping[@]}"; do
    src="${entry%%:*}"
    dest="${entry##*:}"
    dot_link "$src" "$dest"
  done

  # Update .zshrc
  local SOURCE_STR
  SOURCE_STR="\n# dotfiles\nexport DOT_DIR=\"${INSTALL_DIR}\"\n[ -s \"\$DOT_DIR/dotfiles.zsh\" ] && \. \"\$DOT_DIR/dotfiles.zsh\""

  local ZSHRC_PATH
  ZSHRC_PATH="$HOME/.zshrc"

  if ! grep -q '/dotfiles.zsh' "$ZSHRC_PATH"; then
    dot_log "> Appending dotfiles source string to $ZSHRC_PATH"
    printf "%b\n" "$SOURCE_STR" >>"$ZSHRC_PATH"
  else
    dot_log "> dotfiles source string already in $ZSHRC_PATH"
  fi

  dot_log "> Close and reopen your terminal to start using dotfiles or run the following to use it now:"
  printf "%b\n" "${SOURCE_STR}"
}

dot_install
