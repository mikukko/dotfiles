#!/bin/bash

# 源目录：iCloud Drive 的实际位置
# 注意：路径中的空格需要正确处理，如果直接在命令中使用，需要转义空格 `\`
# 或者将整个路径用引号括起来。在变量中赋值时，引号内的空格不需要额外转义。
SOURCE_ICLOUD_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs"

# 目标符号链接的路径 (~ 会被 shell 自动扩展为当前用户的主目录)
TARGET_SYMLINK="${HOME}/iCloud" # 使用 ${HOME} 更明确

echo "准备创建符号链接: ${TARGET_SYMLINK} -> ${SOURCE_ICLOUD_DIR}"

# 1. 检查源目录是否存在 (这是一个好习惯)
if [ ! -d "$SOURCE_ICLOUD_DIR" ]; then
    echo "错误: 源目录 \"$SOURCE_ICLOUD_DIR\" 不存在。"
    echo "请确认 iCloud Drive 的路径是否正确。"
    exit 1 # 退出脚本，因为源不存在无法继续
fi

# 2. 检查目标符号链接 (~/iCloud) 是否已存在
if [ -e "$TARGET_SYMLINK" ]; then # -e 检查文件或目录或符号链接是否存在
    echo "提示: 目标路径 \"$TARGET_SYMLINK\" 已经存在。"
    
    # 进一步检查它是不是一个符号链接，并且是不是已经指向了正确的源
    if [ -L "$TARGET_SYMLINK" ]; then # -L 检查是否为符号链接
        current_link_target=$(readlink "$TARGET_SYMLINK")
        if [ "$current_link_target" == "$SOURCE_ICLOUD_DIR" ]; then
            echo "并且它已经正确地指向了 \"$SOURCE_ICLOUD_DIR\"。"
            echo "无需执行任何操作。"
        else
            echo "它是一个符号链接，但指向了其他位置: \"$current_link_target\"。"
            echo "如果你想重新链接到 \"$SOURCE_ICLOUD_DIR\"，请先手动删除现有的 \"$TARGET_SYMLINK\" (例如: rm \"$TARGET_SYMLINK\")。"
        fi
    else # 存在但不是符号链接 (例如是一个真实的目录或文件)
        echo "它不是一个符号链接（可能是一个普通文件或目录）。"
        echo "请先手动备份并移除或重命名现有的 \"$TARGET_SYMLINK\"，然后再运行此脚本。"
    fi
else
    # 3. 如果目标不存在，则创建符号链接
    echo "目标路径 \"$TARGET_SYMLINK\" 不存在，正在创建符号链接..."
    ln -s "$SOURCE_ICLOUD_DIR" "$TARGET_SYMLINK"
    
    # 检查链接是否成功创建
    if [ $? -eq 0 ]; then
        echo "成功: 已将 \"$SOURCE_ICLOUD_DIR\" 链接到 \"$TARGET_SYMLINK\"。"
    else
        echo "错误: 创建符号链接 \"$TARGET_SYMLINK\" 失败。请检查权限或路径问题。"
    fi
fi

exit 0
