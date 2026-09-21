#!/bin/bash
#
# 安装常驻守护：macOS 只要把 .localized 标记写回来（系统更新、安装器等），
# 守护进程立刻删掉，Finder 里的文件夹名就一直是英文。
#
# 组成：
#   scripts/delocalize-guard.c  编译成 scripts/bin/delocalize-guard
#   ~/Library/LaunchAgents/com.miku.delocalize-folders.plist
#
# 为什么用编译出来的二进制而不是 shell 脚本：~/Desktop、~/Documents、
# ~/Downloads 受 TCC 保护，launchd 里的进程没有“完全磁盘访问”授权时删除会
# 被拒绝（rm: Operation not permitted），而 TCC 授权只能加在可执行文件上，
# 加不到 shell 脚本上。所以在 macOS 27 上这三个目录需要手工授权一次，
# 安装结束时的自检会明确告诉你哪些目录还缺授权。
#
# 用法：
#   ./localized_guard.sh            # 编译 + 安装 + 自检（幂等）
#   ./localized_guard.sh --check    # 只跑自检
#   ./localized_guard.sh --status
#   ./localized_guard.sh --uninstall

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLEANER="$SCRIPT_DIR/remove_localized.sh"
SOURCE="$SCRIPT_DIR/delocalize-guard.c"
BIN_DIR="$SCRIPT_DIR/bin"
BIN="$BIN_DIR/delocalize-guard"
LABEL="com.miku.delocalize-folders"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
DOMAIN="gui/$(id -u)"
LOG_DIR="$HOME/Library/Logs"

if [[ -t 1 ]]; then
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; BLUE=''; NC=''
fi
info() { printf "%b[INFO]%b %s\n" "$BLUE" "$NC" "$*"; }
ok() { printf "%b[OK]%b %s\n" "$GREEN" "$NC" "$*"; }
warn() { printf "%b[WARN]%b %s\n" "$YELLOW" "$NC" "$*"; }
err() { printf "%b[ERROR]%b %s\n" "$RED" "$NC" "$*" >&2; }

usage() {
    cat <<'EOF'
Usage: localized_guard.sh [--check | --status | --uninstall]

无参数时：编译 delocalize-guard、安装 LaunchAgent、跑一次自检。
EOF
}

all_paths() {
    "$CLEANER" --paths
}

build() {
    if [[ ! -f "$SOURCE" ]]; then
        err "缺少源码: $SOURCE"
        exit 1
    fi
    if ! command -v cc >/dev/null 2>&1; then
        err "找不到 cc，需要先安装 Xcode Command Line Tools：xcode-select --install"
        exit 1
    fi
    mkdir -p "$BIN_DIR"
    if [[ -f "$BIN" && "$BIN" -nt "$SOURCE" ]]; then
        return 0
    fi
    info "编译 delocalize-guard"
    cc -Wall -Wextra -O2 -o "$BIN" "$SOURCE"
    # Apple Silicon 上二进制必须签名才能运行；ad-hoc 签名同时给 TCC 一个稳定身份。
    codesign --force --sign - "$BIN" >/dev/null 2>&1 || true
}

write_plist() {
    local args_xml="" watch_xml="" path
    while IFS= read -r path; do
        [[ -n "$path" ]] || continue
        args_xml+="        <string>$path</string>"$'\n'
        watch_xml+="        <string>$path</string>"$'\n'
    done < <(all_paths)

    if [[ -z "$watch_xml" ]]; then
        err "没有拿到需要监控的路径（$CLEANER --paths 输出为空）"
        exit 1
    fi

    mkdir -p "$(dirname "$PLIST")" "$LOG_DIR"
    cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>$BIN</string>
        <string>--quiet</string>
$args_xml    </array>
    <key>WatchPaths</key>
    <array>
$watch_xml    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>StartInterval</key>
    <integer>300</integer>
    <key>ThrottleInterval</key>
    <integer>10</integer>
    <key>ProcessType</key>
    <string>Background</string>
    <key>StandardErrorPath</key>
    <string>$LOG_DIR/remove-localized.launchd.log</string>
</dict>
</plist>
EOF
    plutil -lint "$PLIST" >/dev/null
}

install_guard() {
    build
    write_plist

    launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true
    launchctl bootstrap "$DOMAIN" "$PLIST"
    launchctl kickstart "$DOMAIN/$LABEL" 2>/dev/null || true

    ok "已安装 $LABEL"
    echo "   watcher: $BIN --quiet"
    echo "   plist:   $PLIST"
    echo "   log:     $LOG_DIR/remove-localized.log"

    check_coverage
}

# 自检：从当前上下文播下标记（当前终端有写入权限），看守护进程能不能清掉。
# 必须这样测——才能验证真实场景：守护进程去删一个不是它创建的文件。
#
# 注意：launchctl bootstrap 之后 launchd 的 ThrottleInterval 会让第一次
# WatchPaths 触发延迟几十秒，所以这里要轮询等待，别急着下结论。
check_coverage() {
    local markers=() marker dir
    while IFS= read -r marker; do
        [[ -n "$marker" ]] && markers+=("$marker")
    done < <(all_paths)

    local planted=()
    for marker in "${markers[@]}"; do
        dir="$(dirname "$marker")"
        [[ -d "$dir" ]] || continue
        if touch "$marker" 2>/dev/null; then
            planted+=("$marker")
        fi
    done

    if (( ${#planted[@]} == 0 )); then
        warn "无法写入测试标记，跳过自检"
        return 0
    fi

    info "自检：放入 ${#planted[@]} 个测试标记，等待守护进程处理（最多 90 秒）…"

    local waited=0 kicked=false pending
    while true; do
        pending=0
        for marker in "${planted[@]}"; do
            [[ -e "$marker" ]] && pending=$((pending + 1))
        done
        (( pending == 0 )) && break
        if (( waited >= 20 )) && ! "$kicked"; then
            # 区分“watch 没触发”和“删不掉”：手工触发一次
            launchctl kickstart "$DOMAIN/$LABEL" >/dev/null 2>&1 || true
            kicked=true
        fi
        (( waited >= 90 )) && break
        sleep 2
        waited=$((waited + 2))
    done

    local cleared=() blocked=()
    for marker in "${planted[@]}"; do
        if [[ -e "$marker" ]]; then
            blocked+=("$(dirname "$marker")")
        else
            cleared+=("$(dirname "$marker")")
        fi
    done

    # 清掉本次自检残留（当前上下文有权限），别让文件夹真的变中文。
    for marker in "${planted[@]}"; do
        [[ -e "$marker" ]] && rm -f "$marker" 2>/dev/null || true
    done

    if (( ${#blocked[@]} == 0 )); then
        ok "自检通过：${#cleared[@]} 个目录里的标记都在 ${waited} 秒内被自动清掉"
        return 0
    fi

    local summary
    if (( ${#cleared[@]} > 0 )); then
        summary="${#cleared[@]} 个目录正常，${#blocked[@]} 个目录的标记没能被自动清掉："
    else
        summary="${#blocked[@]} 个目录的标记都没能被自动清掉："
    fi
    warn "$summary"
    printf '       %s\n' "${blocked[@]}"
    echo
    echo "   通常是 TCC 权限问题。一次性授权即可："
    echo "   1) 打开 系统设置 → 隐私与安全性 → 完全磁盘访问"
    echo "   2) 点 ＋，按 ⌘⇧G 粘贴并选中：$BIN"
    echo "   3) 打开开关，然后重新运行：./scripts/localized_guard.sh --check"
    echo
    echo "   也可以像以前一样手工跑一次（终端本身有权限）："
    echo "       $CLEANER"
}

status() {
    if launchctl print "$DOMAIN/$LABEL" >/dev/null 2>&1; then
        ok "已加载: $LABEL"
        launchctl print "$DOMAIN/$LABEL" | grep -E '^\s+(state|path|program) =' || true
    else
        warn "未加载: $LABEL"
    fi
    [[ -x "$BIN" ]] && echo "binary: $BIN" || echo "binary: 未编译"
    [[ -f "$PLIST" ]] && echo "plist:  $PLIST"
    if [[ -f "$LOG_DIR/remove-localized.log" ]]; then
        echo "最近的清理记录："
        tail -n 5 "$LOG_DIR/remove-localized.log"
    fi
}

uninstall() {
    launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true
    rm -f "$PLIST"
    ok "已卸载 ${LABEL}（bin/ 和日志保留）"
}

case "${1:-}" in
    "") install_guard ;;
    --check) check_coverage ;;
    --status) status ;;
    --uninstall) uninstall ;;
    -h|--help) usage ;;
    *) err "未知参数: $1"; usage >&2; exit 2 ;;
esac
