directories=(
  "/Users/miku/Desktop"
  "/Users/miku/Documents"
  "/Users/miku/Downloads"
  "/Users/miku/Movies"
  "/Users/miku/Music"
  "/Users/miku/Pictures"
  "/Users/miku/Public"
  "/Applications"
)

for dir in "${directories[@]}"; do
  [[ -f "$dir/.localized" ]] && rm -f "$dir/.localized"
  echo "removed $dir localized"
done

