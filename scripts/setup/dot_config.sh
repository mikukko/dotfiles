#!/bin/bash

# 获取脚本所在的目录，然后获取 dotfiles 仓库的根目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# 定义要链接的文件列表，格式为 "相对路径 目标路径"
declare -a DOTFILES_TO_LINK=(
    "configs/.zshrc ~/.zshrc"
    "configs/.zprofile ~/.zprofile"
    "configs/.vimrc ~/.vimrc"
    "configs/.condarc ~/.condarc"
    "configs/.gitconfig ~/.gitconfig"
    "configs/.gitignore_global ~/.gitignore_global"
    "configs/.zsh_scripts ~/.zsh_scripts"
)

echo "开始链接 dotfiles (无备份模式)..."

for item in "${DOTFILES_TO_LINK[@]}"; do
    # 将字符串分割为源文件相对路径和目标路径
    src_relative_path=$(echo "$item" | awk '{print $1}')
    target_path_raw=$(echo "$item" | awk '{print $2}')

    # 源文件的绝对路径
    src_path="${REPO_ROOT}/${src_relative_path}"
    # 目标文件的绝对路径 (解析 ~)
    target_path="${target_path_raw/\~/$HOME}" # 使用参数替换来扩展 ~

    echo "" # 换行以提高可读性
    echo "正在处理: ${src_relative_path} -> ${target_path}"

    # 1. 检查源文件是否存在
    if [ ! -e "${src_path}" ]; then
        echo "  错误: 源文件 ${src_path} 不存在。跳过。"
        continue
    fi

    # 2. 创建符号链接 (使用 -f 强制覆盖)
    #    -s: 创建符号链接
    #    -f: 如果目标文件已存在，则强制执行 (删除已存在的目标)
    ln -sf "${src_path}" "${target_path}"
    if [ $? -eq 0 ]; then
        echo "  成功: 已链接 ${src_path} 到 ${target_path}"
    else
        echo "  错误: 链接 ${src_path} 到 ${target_path} 失败。"
    fi
done

echo ""
echo "Dotfiles 链接处理完成 (无备份)。"

if [[ " ${DOTFILES_TO_LINK[*]} " == *" configs/.gitignore_global ~/.gitignore_global "* ]]; then
    echo ""
    echo "提示: 脚本已将仓库中的 '.gitignore_global' 链接到了 '~/.gitignore_global'。"
    echo "如果你希望将其用作 Git 的全局忽略文件，请确保通过以下命令配置 Git："
    echo "  git config --global core.excludesFile ~/.gitignore_global"
fi
