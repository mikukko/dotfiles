#!/bin/bash

# 源目录：iCloud Drive 中的 Rime 配置文件夹
SOURCE_RIME_CONFIG_DIR="/Users/miku/Library/Mobile Documents/com~apple~CloudDocs/Rime"

# 目标父目录，我们将在其中创建符号链接
TARGET_PARENT_DIR="${HOME}/Library"

# 从源目录名确定符号链接的名称 (在这个例子中是 "Rime")
LINK_NAME="$(basename "$SOURCE_RIME_CONFIG_DIR")"

# 最终符号链接的完整路径
EFFECTIVE_TARGET_SYMLINK_PATH="${TARGET_PARENT_DIR}/${LINK_NAME}" # 即 "${HOME}/Library/Rime"

echo "准备创建符号链接: ${EFFECTIVE_TARGET_SYMLINK_PATH} -> ${SOURCE_RIME_CONFIG_DIR}"

# 1. 检查源目录是否存在
if [ ! -d "$SOURCE_RIME_CONFIG_DIR" ]; then
    echo "错误: 源目录 \"$SOURCE_RIME_CONFIG_DIR\" 不存在。"
    echo "请确认 Rime 在 iCloud Drive 中的路径是否正确。"
    exit 1 # 退出脚本，因为源不存在无法继续
fi

# 2. 检查目标父目录是否存在 (通常 ~/Library 总是存在的)
if [ ! -d "$TARGET_PARENT_DIR" ]; then
    echo "错误: 目标父目录 \"$TARGET_PARENT_DIR\" 不存在。这是一个异常情况，请检查。"
    exit 1
fi

# 3. 检查最终的符号链接路径 (~/Library/Rime) 是否已存在
if [ -e "$EFFECTIVE_TARGET_SYMLINK_PATH" ]; then # -e 检查文件或目录或符号链接是否存在
    echo "提示: 目标路径 \"$EFFECTIVE_TARGET_SYMLINK_PATH\" 已经存在。"
    
    # 进一步检查它是不是一个符号链接，并且是不是已经指向了正确的源
    if [ -L "$EFFECTIVE_TARGET_SYMLINK_PATH" ]; then # -L 检查是否为符号链接
        current_link_target=$(readlink "$EFFECTIVE_TARGET_SYMLINK_PATH")
        # 为了更可靠地比较，特别是当路径包含 '..' 或符号链接时，可以解析为真实路径
        # resolved_current_link_target=$(realpath "$EFFECTIVE_TARGET_SYMLINK_PATH" 2>/dev/null || readlink "$EFFECTIVE_TARGET_SYMLINK_PATH")
        # resolved_source_dir=$(realpath "$SOURCE_RIME_CONFIG_DIR" 2>/dev/null)
        # if [ "$resolved_current_link_target" == "$resolved_source_dir" ]; then
        # 简单情况下，直接比较 readlink 的输出通常也可以
        if [ "$current_link_target" == "$SOURCE_RIME_CONFIG_DIR" ]; then
            echo "并且它已经正确地指向了 \"$SOURCE_RIME_CONFIG_DIR\"。"
            echo "无需执行任何操作。"
        else
            echo "它是一个符号链接，但指向了其他位置: \"$current_link_target\"。"
            echo "如果你想重新链接到 \"$SOURCE_RIME_CONFIG_DIR\"，请先手动删除现有的 \"$EFFECTIVE_TARGET_SYMLINK_PATH\" (例如: rm \"$EFFECTIVE_TARGET_SYMLINK_PATH\")。"
        fi
    else # 存在但不是符号链接 (例如是一个真实的目录或文件)
        echo "它不是一个符号链接（可能是一个普通文件或目录）。"
        echo "请先手动备份并移除或重命名现有的 \"$EFFECTIVE_TARGET_SYMLINK_PATH\"，然后再运行此脚本。"
    fi
else
    # 4. 如果目标不存在，则创建符号链接
    echo "目标路径 \"$EFFECTIVE_TARGET_SYMLINK_PATH\" 不存在，正在创建符号链接..."
    # 我们直接指定完整的源路径和完整的目标符号链接路径
    ln -s "$SOURCE_RIME_CONFIG_DIR" "$EFFECTIVE_TARGET_SYMLINK_PATH"
    
    # 检查链接是否成功创建
    if [ $? -eq 0 ]; then
        echo "成功: 已将 \"$SOURCE_RIME_CONFIG_DIR\" 链接到 \"$EFFECTIVE_TARGET_SYMLINK_PATH\"。"
    else
        echo "错误: 创建符号链接 \"$EFFECTIVE_TARGET_SYMLINK_PATH\" 失败。请检查权限或路径问题。"
    fi
fi

exit 0
