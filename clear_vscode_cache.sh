#!/bin/bash

# 定义 VS Code 相关的缓存和数据目录
VSCODE_CACHED_DATA="~/Library/Application Support/Code/CachedData"
VSCODE_CACHED_EXTENSIONS="~/Library/Application Support/Code/CachedExtensionVSIXs"
VSCODE_CACHE="~/Library/Caches/Code"
VSCODE_USER_DATA="~/Library/Application Support/Code/User"
VSCODE_WORKSPACE_STORAGE="~/Library/Application Support/Code/User/workspaceStorage"

# 提示用户即将开始清理
echo "准备清理 VS Code 缓存和相关文件..."

# 清理缓存数据
if [ -d "$VSCODE_CACHED_DATA" ]; then
  echo "清理缓存数据: $VSCODE_CACHED_DATA"
  rm -rf "$VSCODE_CACHED_DATA"
fi

# 清理扩展缓存
if [ -d "$VSCODE_CACHED_EXTENSIONS" ]; then
  echo "清理扩展缓存: $VSCODE_CACHED_EXTENSIONS"
  rm -rf "$VSCODE_CACHED_EXTENSIONS"
fi

# 清理缓存
if [ -d "$VSCODE_CACHE" ]; then
  echo "清理缓存: $VSCODE_CACHE"
  rm -rf "$VSCODE_CACHE"
fi

# 清理用户数据（可选）
if [ -d "$VSCODE_USER_DATA" ]; then
  read -p "是否要清理用户数据（包括设置、扩展等）？(y/N): " answer
  if [[ $answer == [Yy] ]]; then
    echo "清理用户数据: $VSCODE_USER_DATA"
    rm -rf "$VSCODE_USER_DATA"
  fi
fi

# 清理工作区存储（可选）
if [ -d "$VSCODE_WORKSPACE_STORAGE" ]; then
  read -p "是否要清理工作区存储？(y/N): " answer
  if [[ $answer == [Yy] ]]; then
    echo "清理工作区存储: $VSCODE_WORKSPACE_STORAGE"
    rm -rf "$VSCODE_WORKSPACE_STORAGE"
  fi
fi

# 完成提示
echo "清理完成！"
