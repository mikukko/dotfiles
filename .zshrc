# alias
alias python="python3"
alias ll="ls -lahG"
alias pip="pip3"
alias ip="ipconfig getifaddr en0 && ipconfig getifaddr en1"
alias ..="cd ../"
alias ~="cd ~"


# export
export HOMEBREW_NO_AUTO_UPDATE=1


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


