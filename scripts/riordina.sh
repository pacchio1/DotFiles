#!/bin/bash
directory=$(pwd)
files=(*)
for file in "${files[@]}"; do
  if [ "$file" != "." ] && [ "$file" != ".." ]; then
    extension="${file##*.}"
    source="$directory/$file"
    destination=""

    case "$extension" in
    png | jpg | webp | svg) destination="/home/mark/Pictures/$file" ;;
    zip | tar | rar | 7z | gz | tar | tar.xz | tgz | xz) destination="/home/mark/Downloads/Ark/$file" ;;
    pdf | txt | doc | docx | pptx | ppt | odt | odp) destination="/home/mark/Documents/$file" ;;
    mp4 | mkv | webm | avi | mov | flv) destination="/home/mark/Videos/$file" ;;
    mp3 | wav | ogg) destination="/home/mark/Music/$file" ;;
    rpm | AppImage) destination="/home/mark/appimage-rpm-build/$file" ;;
    jar | war) destination="/home/mark/java/$file" ;;
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
