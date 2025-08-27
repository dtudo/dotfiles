# Exports
export BROWSER=wslview
export EDITOR='nano'

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
HIST_STAMPS="mm/dd/yyyy"
setopt hist_ignore_dups
setopt share_history
setopt extended_history

# Antidote
zstyle ':antidote:bundle' lazy true
source "$HOME/.antidote/antidote.zsh"
antidote load

# mise
eval "$(~/.local/bin/mise activate zsh)"

# Enable smart completions
autoload -Uz compinit && compinit -C
zstyle ':completion:*' rehash true

# Pure prompt
autoload -Uz promptinit && promptinit
prompt pure

# dotfiles
export DOT_DIR="$HOME/.dotfiles"
[ -s "$DOT_DIR/dotfiles.zsh" ] && \. "$DOT_DIR/dotfiles.zsh"
