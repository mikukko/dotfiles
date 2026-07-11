#!/bin/bash

directories=(
  "$HOME/Desktop"
  "$HOME/Documents"
  "$HOME/Downloads"
  "$HOME/Movies"
  "$HOME/Music"
  "$HOME/Pictures"
  "$HOME/Public"
  "$HOME/Applications"
  "/Applications"
)

for dir in "${directories[@]}"; do
  if [[ -f "${dir}/.localized" ]]; then
    if rm -f "${dir}/.localized"; then
      echo "Successfully removed ${dir}/.localized"
    else
      echo "Failed to remove ${dir}/.localized (permission issue?)" >&2
    fi
  else
    echo "No .localized file found in ${dir}"
  fi
done

killall Finder

