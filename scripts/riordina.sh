#!/bin/bash
set -euo pipefail
directory=$(pwd)
files=(*)
for file in "${files[@]}"; do
  if [ "$file" != "." ] && [ "$file" != ".." ]; then
    extension="${file##*.}"
    source="$directory/$file"
    destination=""

    case "$extension" in
    png | jpg | webp | svg) destination="$HOME/Pictures/$file" ;;
    zip | tar | rar | 7z | gz | tar.xz | tgz | xz) destination="$HOME/Downloads/Ark/$file" ;;
    pdf | txt | doc | docx | pptx | ppt | odt | odp) destination="$HOME/Documents/$file" ;;
    mp4 | mkv | webm | avi | mov | flv) destination="$HOME/Videos/$file" ;;
    mp3 | wav | ogg) destination="$HOME/Music/$file" ;;
    rpm | AppImage) destination="$HOME/appimage-rpm-build/$file" ;;
    jar | war) destination="$HOME/java/$file" ;;
    esac

    if [ -n "$destination" ]; then
      if mv -v "$source" "$destination"; then
        echo "File $file spostato con successo in $destination"
      else
        echo "Errore nello spostamento del file $file"
      fi
    fi
  fi
done
