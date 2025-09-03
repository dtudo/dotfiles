# Exports
export PATH="$HOME/.local/bin:$PATH"
export BROWSER=wslview
export EDITOR='nano'

# History settings
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
HIST_STAMPS="mm/dd/yyyy"
setopt hist_ignore_dups
setopt share_history
setopt extended_history

# Antidote
source "$HOME/.antidote/antidote.zsh"
antidote load

# Pure prompt
autoload -Uz promptinit && promptinit
prompt pure

# dotfiles
export DOT_DIR="$HOME/.dotfiles"
[ -s "$DOT_DIR/dotfiles.zsh" ] && \. "$DOT_DIR/dotfiles.zsh"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
