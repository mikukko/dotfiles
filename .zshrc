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
export M2_HOME=/usr/local/maven/apache-maven-3.9.9
export PATH=$M2_HOME/bin:$PATH


# plugin
plugins=(
    zsh-autosuggestions
    zsh-fast-syntax-highlighting
    zsh-history-substring-search
)


# source
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $HOMEBREW_PREFIX/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
source $HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh


# eval
eval "$(/opt/miniconda3/bin/conda shell.zsh hook)"


# starship
eval "$(starship init zsh)"


