#!/usr/bin/env bash
set -euo pipefail

if [[ ! -t 1 ]]; then # stdout is not a TTY, disable colours
  YELLOW=''
  NC='' # No Color
else
  YELLOW="\033[1;33m"
  NC="\033[0m" # No Color
fi

DOT_REMINDER_DAYS=7
DOT_LOCAL_METADATA="$DOT_DIR/.local"
DOT_UPDATESYS_LAST_RUN="$DOT_LOCAL_METADATA/updatesys-last-run"

# Skip non-interactive shells
[[ ! -t 1 ]] && exit 0

# Compute days since last run
last_epoch=0
[[ -s $DOT_UPDATESYS_LAST_RUN ]] && read -r last_epoch <"$DOT_UPDATESYS_LAST_RUN"
now_epoch=$(date +%s)
delta_days=$(((now_epoch - last_epoch) / 86400))

if ((delta_days >= DOT_REMINDER_DAYS)); then
  printf "${YELLOW}[dot]${NC} It's been %s days since the last update — run ${YELLOW}dot updatesys${NC}${NC}.\n" "$delta_days"
fi
