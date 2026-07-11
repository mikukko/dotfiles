#!/bin/bash

set -Eeuo pipefail

source_path="$HOME/Library/Mobile Documents/com~apple~CloudDocs"
target_path="$HOME/iCloud"

if [[ ! -d "$source_path" ]]; then
    printf 'iCloud Drive does not exist: %s\n' "$source_path" >&2
    exit 1
fi

if [[ -L "$target_path" ]] && [[ "$(readlink "$target_path")" == "$source_path" ]]; then
    printf 'Already linked: %s\n' "$target_path"
    exit 0
fi

if [[ -e "$target_path" || -L "$target_path" ]]; then
    printf 'Target already exists, leaving it unchanged: %s\n' "$target_path" >&2
    exit 1
fi

ln -s "$source_path" "$target_path"
printf 'Linked %s -> %s\n' "$target_path" "$source_path"
