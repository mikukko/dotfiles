#!/bin/bash
#
# 让 Finder 用英文显示系统自带的文件夹名（Desktop / Documents / Downloads ...）。
#
# 原理：/System/Library/CoreServices/SystemFolderLocalizations/<语言>.lproj/
# 里存着文件夹名的翻译表（Desktop -> 桌面）。Finder 只有在文件夹内存在一个空的
# 隐藏标记文件 .localized 时才会套用这张表；只要这个标记不存在，Finder 就显示
# 文件系统里的真实英文名。所以「变成英文」= 删掉标记，而不是改什么偏好设置。
#
# 但这不是一个偏好设置：macOS 在系统更新/安装时会把这些标记重新写回去
# （实测本机 /Applications、/Library、/Users、/System 下的标记时间戳与系统
# 安装时间完全一致）。所以本脚本要配合常驻的 LaunchAgent 使用，见
# localized_guard.sh：标记一出现就立刻被删掉。
#
# 注意：删掉标记后 Finder 会立即生效，不需要重启 Finder（-r 只是保留旧行为）。
#
# 用法：
#   ./remove_localized.sh            # 清理一次
#   ./remove_localized.sh -q         # 静默（LaunchAgent 用）
#   ./remove_localized.sh --paths    # 只列出会被监控的标记路径

set -Eeuo pipefail

LOG_FILE="${HOME}/Library/Logs/remove-localized.log"
LOG_MAX_LINES=2000
QUIET=false
RESTART_FINDER=false
PATHS_ONLY=false
INCLUDE_SYSTEM=false

usage() {
    cat <<'EOF'
Usage: remove_localized.sh [options]

  -q, --quiet           只在有删除或出错时输出
  -r, --restart-finder  清理后重启 Finder（通常不需要，Finder 会立即生效）
  -p, --paths           只打印会被清理/监控的 .localized 路径
  -s, --system          额外清理需要 root 的目录（/Applications/Utilities、/Library、/Users），
                        需要 sudo 运行；/System 受 SIP 保护，删不掉
  -h, --help            显示帮助
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -q|--quiet) QUIET=true ;;
        -r|--restart-finder) RESTART_FINDER=true ;;
        -p|--paths) PATHS_ONLY=true ;;
        -s|--system) INCLUDE_SYSTEM=true ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
    shift
done

# 需要以英文显示、且当前用户有权限删除标记的目录。
# 需要 root 的（/Applications/Utilities、/Library、/Users）和 SIP 保护的
# （/System）不在列表里，见 README。
directories=(
    "$HOME/Desktop"
    "$HOME/Documents"
    "$HOME/Downloads"
    "$HOME/Movies"
    "$HOME/Music"
    "$HOME/Pictures"
    "$HOME/Public"
    "$HOME/Applications"
    "$HOME/Library"
    "/Applications"
)

if "$PATHS_ONLY"; then
    for dir in "${directories[@]}"; do
        printf '%s/.localized\n' "$dir"
    done
    exit 0
fi

# 只保留日志最近 LOG_MAX_LINES 行，避免无限增长。
trim_log() {
    [[ -f "$LOG_FILE" ]] || return 0
    local lines
    lines=$(wc -l < "$LOG_FILE" | tr -d ' ')
    if (( lines > LOG_MAX_LINES )); then
        tail -n "$LOG_MAX_LINES" "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
    fi
}

remove_marker() {
    local marker="$1"
    local birth mtime
    birth=$(stat -f '%SB' -t '%F %T' "$marker" 2>/dev/null || echo unknown)
    mtime=$(stat -f '%Sm' -t '%F %T' "$marker" 2>/dev/null || echo unknown)

    if rm -f "$marker" 2>/dev/null; then
        mkdir -p "$(dirname "$LOG_FILE")"
        printf '%s removed %s (created %s, modified %s)\n' \
            "$(date '+%F %T')" "$marker" "$birth" "$mtime" >> "$LOG_FILE"
        trim_log
        finder_stale=true
        if ! "$QUIET"; then
            printf 'removed %s\n' "$marker"
        fi
    else
        mkdir -p "$(dirname "$LOG_FILE")"
        printf '%s FAILED to remove %s (permission issue? 见 README 的完全磁盘访问说明)\n' \
            "$(date '+%F %T')" "$marker" >> "$LOG_FILE"
        trim_log
        printf 'failed to remove %s (permission issue?)\n' "$marker" >&2
    fi
}

finder_stale=false
for dir in "${directories[@]}"; do
    marker="$dir/.localized"
    if [[ -e "$marker" || -L "$marker" ]]; then
        remove_marker "$marker"
    elif ! "$QUIET"; then
        printf 'ok       %s\n' "$marker"
    fi
done

# 需要 root 的目录：只有显式 --system 且用 sudo 运行时才处理。
# （/System 受 SIP 保护，无论怎样都删不掉，见 README。）
if "$INCLUDE_SYSTEM" && (( EUID != 0 )); then
    printf '错误：--system 需要 root 权限，请改用: sudo %s --system\n' "$0" >&2
elif "$INCLUDE_SYSTEM"; then
    for dir in "/Applications/Utilities" "/Library" "/Users"; do
        marker="$dir/.localized"
        if [[ -e "$marker" || -L "$marker" ]]; then
            remove_marker "$marker"
        elif ! "$QUIET"; then
            printf 'ok       %s\n' "$marker"
        fi
    done
fi

if "$RESTART_FINDER" && "$finder_stale"; then
    killall Finder 2>/dev/null || true
fi

exit 0
