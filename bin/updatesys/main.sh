#!/usr/bin/env bash
set -euo pipefail

# APT update
"$DOT_DIR/bin/updatesys/update-apt.sh"

# antidote update
zsh -i -c "antidote update"

# mise update
zsh -i -c "mise self-update -y"

# AWS CLI update
"$DOT_DIR/bin/updatesys/update-aws-cli.sh"
