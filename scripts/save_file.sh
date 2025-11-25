#!/bin/bash

name=""
file=""
content=""
mask=false

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --file=*) file="${1#*=}" ;;
    --content=*) content="${1#*=}" ;;
    --mask) mask=true ;;
    *) echo "Unknown parameter passed in save_file: $1"; exit 1 ;;
  esac
  shift
done

# Check required parameters
if [[ -z "$file" || -z "$content" ]]; then
  echo "save_file: --name, --file, and --content are required." >&2
  exit 1
fi

file_path="${GITHUB_WORKSPACE}/${file}"

# Remove unwanted characters
content=$(echo "$content" | tr -d '\r')

# Write content to file
echo "$content" > "$file_path"

# Mask the value
if [[ "$mask" == true ]]; then
  echo "$content" | while IFS= read -r line; do
    if [[ -n "$line" ]]; then  # Перевірка, чи рядок не є порожнім
      echo "::add-mask::$line"
    fi
  done
fi

echo "File ${file} has been saved"