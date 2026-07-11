# Fish shell configuration

if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
else if test -x /usr/local/bin/brew
    eval (/usr/local/bin/brew shellenv)
end

set -gx HOMEBREW_NO_AUTO_UPDATE 1
set -gx PYENV_ROOT "$HOME/.pyenv"
set -gx PNPM_HOME "$HOME/.pnpm-global"
set -gx EDITOR vim
set -gx VISUAL $EDITOR
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

fish_add_path "$PYENV_ROOT/bin"
fish_add_path "$PNPM_HOME"
fish_add_path "$HOME/.antigravity/antigravity/bin"

if test -x /usr/libexec/java_home
    set -l java_home (/usr/libexec/java_home 2>/dev/null)
    if test $status -eq 0
        set -gx JAVA_HOME $java_home
        fish_add_path "$JAVA_HOME/bin"
    end
end

alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -lahG'
alias python='python3'
alias pip='pip3'
alias ga='git add'
alias gaa='git add -A'
alias gs='git status'
alias gcm='git commit -m'
alias gcv='git commit -av'
alias gp='git push'
alias gl='git pull'
alias gd='git diff'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gpl='git pull --rebase'
alias ports='lsof -i -P -n | grep LISTEN'

function mcd
    mkdir -p "$argv[1]"; and cd "$argv[1]"
end

function pfd
    osascript -e 'tell application "Finder" to POSIX path of (target of front window as alias)'
end

function cdf
    set -l finder_dir (pfd); and cd "$finder_dir"
end

function copypath
    set -l file $argv[1]
    test -n "$file"; or set file .
    set -l resolved (path resolve "$file")
    printf %s "$resolved" | pbcopy; and echo "$resolved copied to clipboard."
end

if type -q pyenv
    pyenv init - | source
end

if type -q starship
    starship init fish | source
end
