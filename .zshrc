# Created by Zap installer
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

# PATH updates
export PATH="/home/parker/.local/bin:/home/parker/.local/share/fnm:$PATH"
export PATH=$PATH:$HOME/go/bin

# plugins
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zap-zsh/zap-prompt"
plug "zsh-users/zsh-syntax-highlighting"
plug "dominik-schwabe/zsh-fnm"
plug "zap-zsh/fnm"

# Load and initialise completion system
autoload -Uz compinit
compinit

# pnpm
export PNPM_HOME="/home/parker/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Aliases
alias dotfiles='/usr/bin/git --git-dir=/home/parker/.dotfiles/ --work-tree=/home/parker'
