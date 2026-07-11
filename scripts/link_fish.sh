#!/bin/bash

set -Eeuo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_path="$(cd "$script_dir/.." && pwd)/configs/config.fish"
target_path="$HOME/.config/fish/config.fish"
dry_run=false
temp_dir=""
staged_path=""
link_created=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) dry_run=true ;;
        *)
            printf 'Unknown option: %s\n' "$1" >&2
            exit 2
            ;;
    esac
    shift
done

run() {
    if "$dry_run"; then
        printf '  [dry-run]'
        printf ' %q' "$@"
        printf '\n'
    else
        "$@"
    fi
}

finish() {
    local exit_code=$?
    trap - EXIT

    if [[ $exit_code -ne 0 && -n "$temp_dir" ]]; then
        if "$link_created" && [[ -e "$target_path" || -L "$target_path" ]]; then
            rm -f "$target_path"
        fi
        if [[ -n "$staged_path" && -e "$staged_path" ]]; then
            mkdir -p "$(dirname "$target_path")"
            mv "$staged_path" "$target_path"
        fi
    fi
    if [[ -n "$temp_dir" && -d "$temp_dir" ]]; then
        rm -rf "$temp_dir"
    fi
    exit "$exit_code"
}

trap finish EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

if [[ ! -f "$source_path" ]]; then
    printf 'Fish config does not exist: %s\n' "$source_path" >&2
    exit 1
fi

if [[ -L "$target_path" ]] && [[ "$(readlink "$target_path")" == "$source_path" ]]; then
    printf 'Already linked: %s\n' "$target_path"
    exit 0
fi

if ! "$dry_run"; then
    temp_root="${TMPDIR:-/tmp}"
    temp_dir="$(mktemp -d "${temp_root%/}/dotfiles-fish.XXXXXX")"
fi

if [[ -e "$target_path" || -L "$target_path" ]]; then
    if [[ -d "$target_path" && ! -L "$target_path" ]]; then
        printf 'Target is a directory, leaving it unchanged: %s\n' "$target_path" >&2
        exit 1
    fi

    if "$dry_run"; then
        printf 'Would temporarily stage existing target: %s\n' "$target_path"
        run rm -f "$target_path"
    else
        staged_path="$temp_dir/config.fish"
        printf 'Temporarily staging %s\n' "$target_path"
        mv "$target_path" "$staged_path"
    fi
fi

run mkdir -p "$(dirname "$target_path")"
run ln -s "$source_path" "$target_path"
if ! "$dry_run"; then link_created=true; fi

if "$dry_run"; then
    printf 'Would link %s -> %s\n' "$target_path" "$source_path"
else
    printf 'Linked %s -> %s\n' "$target_path" "$source_path"
fi
