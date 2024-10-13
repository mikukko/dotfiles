directories=(
  "~/Desktop"
  "~/Documents"
  "~/Downloads"
  "~/Movies"
  "~/Music"
  "~/Pictures"
  "~/Public"
  "~/Applications"
  "/Applications"
)

for dir in "${directories[@]}"; do
  [[ -f "$dir/.localized" ]] && rm -f "$dir/.localized"
  echo "removed $dir localized"
done

killall Finder

