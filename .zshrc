# alias
alias python="python3"
alias ll="ls -lahG"
alias pip="pip3"
alias ip="ipconfig getifaddr en0 && ipconfig getifaddr en1"
alias grep="grep --color=auto"
alias ..="cd .."
alias ...="cd ../.."
alias ~="cd ~"


# export
export HOMEBREW_PREFIX=$(brew --prefix)
export HOMEBREW_NO_AUTO_UPDATE=1

export JAVA_HOME=/opt/homebrew/opt/openjdk
export PATH=$JAVA_HOME/bin:$PATH

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"


# completions
FPATH="$HOME/.docker/completions:$FPATH"
autoload -Uz compinit
compinit


# source
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOMEBREW_PREFIX/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source $HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh


# pyenv
eval "$(pyenv init --path)"
eval "$(pyenv init - zsh)"


# starship
eval "$(starship init zsh)"


