#!/bin/bash

# --- 默认配置 ---
# 应用名，用于 AppleScript (如 "Visual Studio Code", "Visual Studio Code - Insiders")
APP_NAME_FOR_AS="Visual Studio Code"
# 进程名，用于 pgrep/killall 及部分路径 (如 "Code", "Code - Insiders")
PROCESS_NAME_FOR_KILL="Code"
# --------------------

# 定义 VS Code 相关的缓存和数据目录
VSCODE_APP_SUPPORT="$HOME/Library/Application Support/$PROCESS_NAME_FOR_KILL"
VSCODE_CACHED_DATA="$VSCODE_APP_SUPPORT/CachedData"
VSCODE_CACHED_EXTENSIONS="$VSCODE_APP_SUPPORT/CachedExtensionVSIXs"
VSCODE_INTERNAL_CACHE="$VSCODE_APP_SUPPORT/Cache"
VSCODE_CODE_CACHE="$VSCODE_APP_SUPPORT/Code Cache"
VSCODE_GPU_CACHE="$VSCODE_APP_SUPPORT/GPUCache"
VSCODE_LOGS="$VSCODE_APP_SUPPORT/logs"
VSCODE_BACKUPS="$VSCODE_APP_SUPPORT/Backups"
# 系统级缓存目录
VSCODE_SYSTEM_CACHE="$HOME/Library/Caches/com.microsoft.VSCode"
VSCODE_SHIPIT_CACHE="$HOME/Library/Caches/com.microsoft.VSCode.ShipIt"
VSCODE_PROCESS_CACHE="$HOME/Library/Caches/$PROCESS_NAME_FOR_KILL"
# 用户数据和工作区
VSCODE_USER_DATA="$VSCODE_APP_SUPPORT/User"
VSCODE_WORKSPACE_STORAGE="$VSCODE_APP_SUPPORT/User/workspaceStorage"

# 提示用户即将开始清理
echo "准备清理 VS Code ($APP_NAME_FOR_AS) 缓存和相关文件..."
echo "将使用的进程名/路径标识: '$PROCESS_NAME_FOR_KILL'" # 保留此信息，以防用户有多个版本时混淆

# 检查 VS Code 是否正在运行 (使用 AppleScript)
echo ""
echo "正在检查 '$APP_NAME_FOR_AS' 是否正在运行..."
IS_RUNNING=$(osascript -e "application \"$APP_NAME_FOR_AS\" is running" 2>/dev/null)

if [[ "$IS_RUNNING" == "true" ]]; then
  echo "信息: '$APP_NAME_FOR_AS' 正在运行。"
  read -p "脚本需要关闭 '$APP_NAME_FOR_AS' 后才能进行清理。是否允许脚本尝试关闭并继续清理？(y/N): " confirm_close_continue
  if [[ ! "$confirm_close_continue" == [Yy] ]]; then
    echo "清理已取消。"
    exit 1
  fi

  # 阶段1: 尝试优雅关闭 (AppleScript)
  echo "正在尝试优雅地关闭 '$APP_NAME_FOR_AS' (使用 AppleScript)..."
  osascript -e "tell application \"$APP_NAME_FOR_AS\" to quit"
  
  echo "等待 '$APP_NAME_FOR_AS' 关闭 (最多 15 秒)..."
  CLOSED_GRACEFULLY=false
  for i in {1..5}; do 
    sleep 3
    if ! osascript -e "application \"$APP_NAME_FOR_AS\" is running" | grep -q "true"; then
      echo "'$APP_NAME_FOR_AS' 已通过 AppleScript 成功关闭。"
      CLOSED_GRACEFULLY=true
      break
    else
      echo "'$APP_NAME_FOR_AS' 仍在运行 (AppleScript 后尝试次数: $i/5)..."
    fi
  done

  if ! $CLOSED_GRACEFULLY; then
    echo "'$APP_NAME_FOR_AS' 未能通过 AppleScript 优雅关闭。"
    echo "将尝试通过进程名 '$PROCESS_NAME_FOR_KILL' 进行强制关闭。"
    
    if pgrep -x "$PROCESS_NAME_FOR_KILL" > /dev/null; then
        echo "信息: 找到名为 '$PROCESS_NAME_FOR_KILL' 的进程。"
        # 阶段2: 尝试发送 SIGTERM 信号 (killall)
        echo "尝试发送 SIGTERM 信号强制关闭 (killall '$PROCESS_NAME_FOR_KILL')..."
        killall "$PROCESS_NAME_FOR_KILL" &> /dev/null 
        
        echo "等待进程 '$PROCESS_NAME_FOR_KILL' 关闭 (最多 10 秒)..."
        CLOSED_SIGTERM=false
        for i in {1..5}; do 
            sleep 2
            if ! pgrep -x "$PROCESS_NAME_FOR_KILL" > /dev/null; then
                echo "进程 '$PROCESS_NAME_FOR_KILL' 已通过 SIGTERM 成功关闭。"
                CLOSED_SIGTERM=true
                break
            else
                echo "进程 '$PROCESS_NAME_FOR_KILL' 仍在运行 (SIGTERM 后尝试次数: $i/5)..."
            fi
        done

        if ! $CLOSED_SIGTERM; then
            echo "进程 '$PROCESS_NAME_FOR_KILL' 仍未能通过 SIGTERM 关闭。"
            
            # 阶段3: 尝试发送 SIGKILL 信号 (killall -9)，需用户确认
            echo "警告: 将尝试发送 SIGKILL 信号 (killall -9 '$PROCESS_NAME_FOR_KILL')."
            read -p "是否继续使用 SIGKILL 强制关闭？(y/N): " confirm_sigkill
            if [[ "$confirm_sigkill" == [Yy] ]]; then
                echo "发送 SIGKILL 信号..."
                killall -9 "$PROCESS_NAME_FOR_KILL" &> /dev/null
                sleep 3 

                if ! pgrep -x "$PROCESS_NAME_FOR_KILL" > /dev/null; then
                    echo "进程 '$PROCESS_NAME_FOR_KILL' 已通过 SIGKILL 强制关闭。"
                else
                    echo "错误：无法通过 SIGKILL 关闭进程 '$PROCESS_NAME_FOR_KILL'。"
                    echo "请手动关闭 '$APP_NAME_FOR_AS'。"
                    echo "相关进程信息:"
                    pgrep -lf "$PROCESS_NAME_FOR_KILL" 
                    ps aux | grep -i "[${PROCESS_NAME_FOR_KILL:0:1}]${PROCESS_NAME_FOR_KILL:1}"
                    echo "清理已取消。"
                    exit 1
                fi
            else
                echo "用户选择不使用 SIGKILL。清理已取消。"
                exit 1
            fi
        fi
    else
        echo "信息: AppleScript 优雅关闭失败后，未找到名为 '$PROCESS_NAME_FOR_KILL' 的特定进程。"
        echo "这可能意味着它已经关闭，或者脚本中配置的 PROCESS_NAME_FOR_KILL ('$PROCESS_NAME_FOR_KILL') 不正确。"
    fi
  fi
else
  echo "信息: '$APP_NAME_FOR_AS' 当前未运行 (根据 AppleScript 判断)。"
fi

echo "" 
echo "开始清理文件..."

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

# 清理内部缓存
if [ -d "$VSCODE_INTERNAL_CACHE" ]; then
  echo "清理内部缓存: $VSCODE_INTERNAL_CACHE"
  rm -rf "$VSCODE_INTERNAL_CACHE"
else
  echo "内部缓存目录不存在或已清理: $VSCODE_INTERNAL_CACHE"
fi

# 清理代码缓存
if [ -d "$VSCODE_CODE_CACHE" ]; then
  echo "清理代码缓存: $VSCODE_CODE_CACHE"
  rm -rf "$VSCODE_CODE_CACHE"
else
  echo "代码缓存目录不存在或已清理: $VSCODE_CODE_CACHE"
fi

# 清理 GPU 缓存
if [ -d "$VSCODE_GPU_CACHE" ]; then
  echo "清理 GPU 缓存: $VSCODE_GPU_CACHE"
  rm -rf "$VSCODE_GPU_CACHE"
else
  echo "GPU 缓存目录不存在或已清理: $VSCODE_GPU_CACHE"
fi

# 清理日志文件
if [ -d "$VSCODE_LOGS" ]; then
  echo "清理日志文件: $VSCODE_LOGS"
  rm -rf "$VSCODE_LOGS"
else
  echo "日志目录不存在或已清理: $VSCODE_LOGS"
fi

# 清理系统级缓存目录
if [ -d "$VSCODE_SYSTEM_CACHE" ]; then
  echo "清理系统缓存: $VSCODE_SYSTEM_CACHE"
  rm -rf "$VSCODE_SYSTEM_CACHE"
else
  echo "系统缓存目录不存在或已清理: $VSCODE_SYSTEM_CACHE"
fi

# 清理 ShipIt 缓存（更新相关）
if [ -d "$VSCODE_SHIPIT_CACHE" ]; then
  echo "清理更新缓存: $VSCODE_SHIPIT_CACHE"
  rm -rf "$VSCODE_SHIPIT_CACHE"
else
  echo "更新缓存目录不存在或已清理: $VSCODE_SHIPIT_CACHE"
fi

# 清理进程名缓存目录（如果存在且不同于系统缓存）
if [ -d "$VSCODE_PROCESS_CACHE" ] && [ "$VSCODE_PROCESS_CACHE" != "$VSCODE_SYSTEM_CACHE" ]; then
  echo "清理进程缓存: $VSCODE_PROCESS_CACHE"
  rm -rf "$VSCODE_PROCESS_CACHE"
else
  echo "进程缓存目录不存在或已清理: $VSCODE_PROCESS_CACHE"
fi

# 清理备份文件（可选）
if [ -d "$VSCODE_BACKUPS" ]; then
  read -p "是否要清理备份文件（包括未保存文件的自动备份）？(y/N): " answer
  if [[ "$answer" == [Yy] ]]; then
    echo "清理备份文件: $VSCODE_BACKUPS"
    rm -rf "$VSCODE_BACKUPS"
  else
    echo "跳过备份文件清理。"
  fi
else
  echo "备份文件目录不存在或已清理: $VSCODE_BACKUPS"
fi

# 清理用户数据（可选）
if [ -d "$VSCODE_USER_DATA" ]; then
  read -p "是否要清理用户数据（包括设置、键盘快捷键、用户片段、扩展等）？这将重置你的VS Code配置！(y/N): " answer
  if [[ "$answer" == [Yy] ]]; then
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
  if [[ "$answer" == [Yy] ]]; then
    echo "清理工作区存储: $VSCODE_WORKSPACE_STORAGE"
    rm -rf "$VSCODE_WORKSPACE_STORAGE"
  else
    echo "跳过工作区存储清理。"
  fi
else
  echo "工作区存储目录不存在或已清理: $VSCODE_WORKSPACE_STORAGE"
fi

echo ""
echo "清理完成！"
echo ""
echo "已清理的缓存类型："
echo "✓ 缓存数据 (CachedData)"
echo "✓ 扩展缓存 (CachedExtensionVSIXs)"
echo "✓ 内部缓存 (Cache)"
echo "✓ 代码缓存 (Code Cache)"
echo "✓ GPU 缓存 (GPUCache)"
echo "✓ 日志文件 (logs)"
echo "✓ 系统缓存 (com.microsoft.VSCode)"
echo "✓ 更新缓存 (ShipIt)"
echo ""
echo "注意：如果清理了用户数据或工作区存储，VS Code 将重置相关设置。"
echo "建议重启 VS Code 以确保清理生效。"
