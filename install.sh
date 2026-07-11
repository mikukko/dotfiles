#!/bin/bash

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
ASSUME_YES=false
WITH_ICLOUD=false
WITH_OBSIDIAN=false
TEMP_DIR=""
CREATED_LOG=""
STAGED_LOG=""

if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

info() { printf "%b[INFO]%b %s\n" "$BLUE" "$NC" "$*"; }
success() { printf "%b[OK]%b %s\n" "$GREEN" "$NC" "$*"; }
warn() { printf "%b[WARN]%b %s\n" "$YELLOW" "$NC" "$*"; }
error() { printf "%b[ERROR]%b %s\n" "$RED" "$NC" "$*" >&2; }

usage() {
    cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --dry-run        Show actions without changing files
  --yes            Do not ask interactive questions
  --with-icloud    Create the ~/iCloud link
  --with-obsidian  Create the ~/Obsidian link
  --all             Enable all optional links
  -h, --help       Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=true ;;
        --yes) ASSUME_YES=true ;;
        --with-icloud) WITH_ICLOUD=true ;;
        --with-obsidian) WITH_OBSIDIAN=true ;;
        --all)
            WITH_ICLOUD=true
            WITH_OBSIDIAN=true
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            error "Unknown option: $1"
            usage >&2
            exit 2
            ;;
    esac
    shift
done

run() {
    if "$DRY_RUN"; then
        printf '  [dry-run]'
        printf ' %q' "$@"
        printf '\n'
    else
        "$@"
    fi
}

begin_transaction() {
    "$DRY_RUN" && return 0

    local temp_root="${TMPDIR:-/tmp}"
    TEMP_DIR="$(mktemp -d "${temp_root%/}/dotfiles-install.XXXXXX")"
    CREATED_LOG="$TEMP_DIR/created"
    STAGED_LOG="$TEMP_DIR/staged"
    touch "$CREATED_LOG" "$STAGED_LOG"
}

rollback() {
    [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]] || return 0
    warn "Installation failed; restoring previous configuration"

    local target_path staged_path
    while IFS= read -r target_path; do
        if [[ -e "$target_path" || -L "$target_path" ]]; then
            rm -f "$target_path"
        fi
    done < "$CREATED_LOG"

    while IFS='|' read -r target_path staged_path; do
        [[ -n "$target_path" && -e "$staged_path" ]] || continue
        mkdir -p "$(dirname "$target_path")"
        mv "$staged_path" "$target_path"
    done < "$STAGED_LOG"
}

finish() {
    local exit_code=$?
    trap - EXIT

    if [[ $exit_code -ne 0 ]]; then
        rollback
    fi
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
    exit "$exit_code"
}

trap finish EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

ask_optional_links() {
    "$ASSUME_YES" && return 0
    [[ -t 0 ]] || return 0

    local answer
    read -r -p "设置 iCloud 快捷链接？(y/N): " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then WITH_ICLOUD=true; fi
    read -r -p "设置 Obsidian 快捷链接？(y/N): " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then WITH_OBSIDIAN=true; fi
}

link_config() {
    local source_relative="$1"
    local target_relative="$2"
    local source_path="$SCRIPT_DIR/$source_relative"
    local target_path="$HOME/$target_relative"

    if [[ ! -e "$source_path" ]]; then
        error "Source does not exist: $source_path"
        return 1
    fi

    if [[ -L "$target_path" ]] && [[ "$(readlink "$target_path")" == "$source_path" ]]; then
        success "$target_path is already linked"
        return
    fi

    if [[ -e "$target_path" || -L "$target_path" ]]; then
        if [[ -d "$target_path" && ! -L "$target_path" ]]; then
            error "Target is a directory, leaving it unchanged: $target_path"
            return 1
        fi
        if "$DRY_RUN"; then
            warn "Would temporarily stage existing target: $target_path"
            run rm -f "$target_path"
        else
            local staged_path="$TEMP_DIR/original/$target_relative"
            info "Temporarily staging $target_path"
            mkdir -p "$(dirname "$staged_path")"
            mv "$target_path" "$staged_path"
            printf '%s|%s\n' "$target_path" "$staged_path" >> "$STAGED_LOG"
        fi
    fi

    run mkdir -p "$(dirname "$target_path")"
    run ln -s "$source_path" "$target_path"
    if ! "$DRY_RUN"; then
        printf '%s\n' "$target_path" >> "$CREATED_LOG"
    fi
    if "$DRY_RUN"; then
        info "Would link $target_path"
    else
        success "Linked $target_path"
    fi
}

run_optional() {
    local enabled="$1"
    local script="$2"
    "$enabled" || return 0

    if "$DRY_RUN"; then
        info "Would run scripts/$script"
    else
        "$SCRIPT_DIR/scripts/$script"
    fi
}

if [[ "$(uname -s)" != "Darwin" ]]; then
    error "This repository currently supports macOS only."
    exit 1
fi

info "Installing dotfiles from $SCRIPT_DIR"
ask_optional_links
begin_transaction

link_config "configs/.zshrc" ".zshrc"
link_config "configs/.zprofile" ".zprofile"
link_config "configs/.zsh_scripts" ".zsh_scripts"
link_config "configs/config.fish" ".config/fish/config.fish"
link_config "configs/.vimrc" ".vimrc"
link_config "configs/.condarc" ".condarc"
link_config "configs/.gitconfig" ".gitconfig"
link_config "configs/.gitignore_global" ".gitignore_global"

run_optional "$WITH_ICLOUD" "link_icloud.sh"
run_optional "$WITH_OBSIDIAN" "link_obsidian.sh"

if ! command -v brew >/dev/null 2>&1; then
    warn "Homebrew is not installed; optional shell tools will be skipped by the configs."
elif [[ -f "$SCRIPT_DIR/Brewfile" ]]; then
    info "Optional dependencies can be installed with: brew bundle --file '$SCRIPT_DIR/Brewfile'"
fi

success "Dotfiles installation completed"
