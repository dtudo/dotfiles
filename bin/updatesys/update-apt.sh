#!/usr/bin/env bash
set -euo pipefail

printf '%s\n' "> Updating APT packages..."

# General update
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt autoclean -y

# Development tools update
packages=(
  zsh
  wslu
  git
  gh
  bat
  unzip
  curl
  wget
  just
)

sudo apt-get install -y "${packages[@]}"

printf '%s\n' "> APT packages update complete"
