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
export HOMEBREW_NO_AUTO_UPDATE=1
export M2_HOME=/usr/local/maven/apache-maven-3.9.9
export PATH=$M2_HOME/bin:$PATH


# plugin
plugins=(
    git
    zsh-autosuggestions
    zsh-fast-syntax-highlighting
)


# source
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh


# eval


# starship
eval "$(starship init zsh)"


