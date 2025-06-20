# ============================================================================
# Zsh Configuration File (.zshrc)
# ============================================================================
#
# 配置加载顺序说明：
# 1. Zsh 选项设置 (options) - Shell 行为配置
# 2. 历史记录配置 (history) - 命令历史设置
# 3. 别名定义 (aliases) - 基础别名（不依赖环境变量的）
# 4. 环境变量 (exports) - 系统路径和环境配置
# 5. 依赖别名 (dependent aliases) - 依赖环境变量的别名
# 6. 补全系统 (completions) - 智能补全配置
# 7. Zsh 插件 (plugins) - 核心插件加载
# 8. 工具初始化 (tools) - pyenv 和 starship 初始化
#
# 重要提示：
# - compinit 必须在语法高亮插件之前执行
# - fast-syntax-highlighting 要在compinit之后加载
# - starship 提示符初始化放在最后
# ============================================================================

# ============================================================================
# 1. Zsh 选项设置 (Zsh Options)
# ============================================================================

# 自动切换目录
setopt AUTO_CD
# 自动推送目录到目录栈
setopt AUTO_PUSHD
# 避免目录栈中的重复
setopt PUSHD_IGNORE_DUPS
# 扩展通配符
setopt EXTENDED_GLOB
# 不匹配时不报错
setopt NO_NOMATCH
# 共享历史记录
setopt SHARE_HISTORY
# 增量搜索历史
setopt INC_APPEND_HISTORY
# 忽略重复的历史记录
setopt HIST_IGNORE_DUPS
# 忽略以空格开头的命令
setopt HIST_IGNORE_SPACE

# ============================================================================
# 2. 历史记录配置 (History Configuration)
# ============================================================================

HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000

# ============================================================================
# 3. 别名定义 (Aliases)
# ============================================================================

# 目录导航别名
alias ..="cd .."
alias ...="cd ../.."
alias ~="cd ~"

# 文件操作别名
alias ll="ls -lahG"
alias mkdir="mkdir -p"

# 搜索相关别名
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"

# Python 相关别名
alias python="python3"
alias pip="pip3"

# Git 相关别名
alias ga="git add "
alias gaa="git add -A"
alias gs="git status"
alias gcm="git commit -m"
alias gcv="git commit -av"
alias gp="git push"
alias gl="git pull"
alias gd="git diff"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gpl="git pull --rebase"

# 网络相关别名
alias ip="ipconfig getifaddr en0 && ipconfig getifaddr en1"
alias ports="lsof -i -P -n | grep LISTEN"

# ============================================================================
# 4. 环境变量 (Environment Variables)
# ============================================================================

# Homebrew 配置 - 缓存路径以提高性能
if [[ -z "$HOMEBREW_PREFIX" ]]; then
    export HOMEBREW_PREFIX=$(brew --prefix)
fi
export HOMEBREW_NO_AUTO_UPDATE=1

# Java 环境配置
export JAVA_HOME=/opt/homebrew/opt/openjdk
export PATH=$JAVA_HOME/bin:$PATH

# Python 环境配置
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# 编辑器设置
export EDITOR="vim"
export VISUAL="$EDITOR"

# 语言和编码设置
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# ============================================================================
# 5. 补全系统 (Completion System)
# ============================================================================

# 添加补全路径
FPATH="$HOMEBREW_PREFIX/share/zsh-completions:${FPATH}"
FPATH="$HOME/.docker/completions:${FPATH}"
autoload -Uz compinit
compinit -C

# 补全样式设置
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ============================================================================
# 6. Zsh 插件 (Zsh Plugins)
# ============================================================================
# 注意：语法高亮插件必须最后加载，以避免与补全系统冲突

# 自定义函数和脚本
source $HOME/.zsh_scripts

# 自动建议插件 - 提供命令建议
source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# 历史搜索插件 - 支持历史子字符串搜索
source $HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# 语法高亮插件 - 在compinit之后加载
source $HOMEBREW_PREFIX/share/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

# ============================================================================
# 7. 工具初始化 (Tools Initialization)
# ============================================================================

if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init - zsh)"
fi

# 提示符主题 - 放在最后初始化
eval "$(starship init zsh)"


# ============================================================================
# 配置文件结束
# ============================================================================

