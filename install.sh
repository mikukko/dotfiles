#!/bin/bash

# dotfiles 一键安装脚本
# 这个脚本会自动执行所有必要的设置步骤

set -e  # 遇到错误时退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

print_info "开始 dotfiles 安装过程..."
echo ""

# 1. 检查必要的工具
print_info "检查必要的工具..."

if ! command -v git &> /dev/null; then
    print_error "Git 未安装，请先安装 Git"
    exit 1
fi

if ! command -v brew &> /dev/null; then
    print_warning "Homebrew 未安装，建议安装 Homebrew 以获得最佳体验"
    echo "安装命令: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
else
    print_success "Homebrew 已安装"
fi

# 2. 设置 dotfiles 符号链接
print_info "设置 dotfiles 符号链接..."
if [ -x "$SCRIPT_DIR/scripts/setup/dot_config.sh" ]; then
    "$SCRIPT_DIR/scripts/setup/dot_config.sh"
    print_success "dotfiles 符号链接设置完成"
else
    print_error "找不到 dot_config.sh 脚本"
    exit 1
fi

echo ""

# 3. 询问是否设置 iCloud Drive 链接
read -p "是否要设置 iCloud Drive 快捷访问链接？(y/N): " setup_icloud
if [[ "$setup_icloud" == [Yy] ]]; then
    print_info "设置 iCloud Drive 链接..."
    if [ -x "$SCRIPT_DIR/scripts/setup/icloud_ln.sh" ]; then
        "$SCRIPT_DIR/scripts/setup/icloud_ln.sh"
        print_success "iCloud Drive 链接设置完成"
    else
        print_error "找不到 icloud_ln.sh 脚本"
    fi
fi

echo ""

# 4. 询问是否设置 Rime 配置链接
read -p "是否要设置 Rime 输入法配置链接？(y/N): " setup_rime
if [[ "$setup_rime" == [Yy] ]]; then
    print_info "设置 Rime 配置链接..."
    if [ -x "$SCRIPT_DIR/scripts/setup/rime_ln.sh" ]; then
        "$SCRIPT_DIR/scripts/setup/rime_ln.sh"
        print_success "Rime 配置链接设置完成"
    else
        print_error "找不到 rime_ln.sh 脚本"
    fi
fi

echo ""

# 5. 提供后续建议
print_info "安装完成！后续建议："
echo ""
echo "1. 重启终端或执行以下命令使配置生效："
echo "   source ~/.zshrc"
echo ""
echo "2. 如果使用 Homebrew，建议安装以下 Zsh 插件："
echo "   brew install zsh-autosuggestions"
echo "   brew install zsh-fast-syntax-highlighting"
echo "   brew install zsh-history-substring-search"
echo "   brew install starship"
echo ""
echo "3. 设置 Git 用户信息："
echo "   git config --global user.name \"Your Name\""
echo "   git config --global user.email \"your.email@example.com\""
echo ""
echo "4. 如果需要安装 Python 环境管理工具："
echo "   brew install pyenv"
echo ""

print_success "dotfiles 安装完成！享受你的新环境吧！"
