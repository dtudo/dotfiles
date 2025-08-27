function dot() {
  local cmd="${1:-}"
  if [[ $# -gt 0 ]]; then
    shift
  fi

  if [[ -z "$cmd" ]]; then
    dot::help
    return 1
  fi

  case "$cmd" in
  update) dot::update ;;
  updatesys) dot::updatesys ;;
  uninstall) dot::uninstall ;;
  help) dot::help ;;
  *)
    printf '%s\n' "unknown command: $cmd" >&2
    return 1
    ;;
  esac
}

function dot::update() {
  "$DOT_DIR/install.sh"
}

function dot::updatesys() {
  DOT_LOCAL_METADATA="$DOT_DIR/.local"
  DOT_UPDATESYS_LAST_RUN="$DOT_LOCAL_METADATA/updatesys-last-run"

  # Mark timestamp of successful run (epoch seconds)
  mkdir -p "$DOT_LOCAL_METADATA"
  date +%s >"$DOT_UPDATESYS_LAST_RUN"

  "$DOT_DIR/bin/updatesys/main.sh"
}

function dot::uninstall() {
  "$DOT_DIR/uninstall.sh"
}

function dot::help() {
  cat <<EOF
dot - dotfiles CLI

Usage:  dot <command>

Commands:
  update                     update dotfiles
  updatesys                  update system
  uninstall                  uninstall dotfiles
  help                       show this help
EOF
}
