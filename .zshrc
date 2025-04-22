# Created by Zap installer
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

# Exports
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share

# PATH updates
export PATH="/home/$USER/.local/bin:/home/$USER/.local/share/fnm:/usr/local/go/bin:$HOME/go/bin:$PATH"

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

# aliases
alias c="clear"
alias touchpad="sudo kcmshell6 kcm_touchpad"
alias plasmarestart="systemctl --user restart plasma-plasmashell"
alias lg="lazygit"

# pnpm
export PNPM_HOME="/home/$USER/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
if [ -x "$(command -v pyenv)" ]; then
    [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi

# start tmux on startup
if [ -x "$(command -v tmux)" ] && [ -n "${DISPLAY}" ] && [ -z "${TMUX}" ] && [ "$TERM_PROGRAM" != "vscode" ]; then
    tmux attach || tmux
fi
