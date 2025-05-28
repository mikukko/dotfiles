#!/bin/bash

# 定义 VS Code 相关的缓存和数据目录
# 使用 $HOME 环境变量来确保路径正确展开
VSCODE_CACHED_DATA="$HOME/Library/Application Support/Code/CachedData"
VSCODE_CACHED_EXTENSIONS="$HOME/Library/Application Support/Code/CachedExtensionVSIXs"
VSCODE_CACHE="$HOME/Library/Caches/Code"
VSCODE_USER_DATA="$HOME/Library/Application Support/Code/User"
VSCODE_WORKSPACE_STORAGE="$HOME/Library/Application Support/Code/User/workspaceStorage"

# 提示用户即将开始清理
echo "准备清理 VS Code 缓存和相关文件..."

# 检查 VS Code 是否正在运行，如果运行则建议退出
if pgrep -x "Code" > /dev/null; then
  echo "警告: VS Code 正在运行。建议在清理前退出 VS Code，以确保所有文件都能被正确删除。"
  read -p "是否继续？(y/N): " continue_answer
  if [[ ! $continue_answer == [Yy] ]]; then
    echo "清理已取消。"
    exit 1
  fi
fi


# 清理缓存数据
if [ -d "$VSCODE_CACHED_DATA" ]; then
  echo "清理缓存数据: $VSCODE_CACHED_DATA"
  rm -rf "$VSCODE_CACHED_DATA"
else
  echo "缓存数据目录不存在或已清理: $VSCODE_CACHED_DATA"
fi

# 清理扩展缓存
if [ -d "$VSCODE_CACHED_EXTENSIONS" ]; then
  echo "清理扩展缓存: $VSCODE_CACHED_EXTENSIONS"
  rm -rf "$VSCODE_CACHED_EXTENSIONS"
else
  echo "扩展缓存目录不存在或已清理: $VSCODE_CACHED_EXTENSIONS"
fi

# 清理缓存
if [ -d "$VSCODE_CACHE" ]; then
  echo "清理缓存: $VSCODE_CACHE"
  rm -rf "$VSCODE_CACHE"
else
  echo "缓存目录不存在或已清理: $VSCODE_CACHE"
fi

# 清理用户数据（可选）
if [ -d "$VSCODE_USER_DATA" ]; then
  read -p "是否要清理用户数据（包括设置、键盘快捷键、用户片段、扩展等）？这将重置你的VS Code配置！(y/N): " answer
  if [[ $answer == [Yy] ]]; then
    echo "清理用户数据: $VSCODE_USER_DATA"
    rm -rf "$VSCODE_USER_DATA"
  else
    echo "跳过用户数据清理。"
  fi
else
  echo "用户数据目录不存在或已清理: $VSCODE_USER_DATA"
fi

# 清理工作区存储（可选）
if [ -d "$VSCODE_WORKSPACE_STORAGE" ]; then
  read -p "是否要清理工作区存储（存储了每个工作区的一些状态信息，如打开的文件历史等）？(y/N): " answer
  if [[ $answer == [Yy] ]]; then
    echo "清理工作区存储: $VSCODE_WORKSPACE_STORAGE"
    rm -rf "$VSCODE_WORKSPACE_STORAGE"
  else
    echo "跳过工作区存储清理。"
  fi
else
  echo "工作区存储目录不存在或已清理: $VSCODE_WORKSPACE_STORAGE"
fi

# 完成提示
echo "清理完成！"

