#!/bin/bash

file=""
name=""
key=""
mask=false

# Handle arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --file=*) file="${1#*=}" ;;
    --name=*) name="${1#*=}" ;;
    --key=*) key="${1#*=}" ;;
    --mask) mask=true ;;
    *) echo "Unknown parameter passed in save_env_from_file: $1"; exit 1 ;;
  esac
  shift
done

# Check required parameters
if [[ -z "$file" || -z "$name" || -z "$key" ]]; then
  echo "save_env_from_file: --file, --name, and --key are required." >&2
  exit 1
fi

file_path="${GITHUB_WORKSPACE}/${file}"

# Find the value by key in the file
value=$(grep "^$key=" "$file_path" | cut -d'=' -f2-)

# Check the existence of value
if [[ -z "$value" ]]; then
  echo "save_env_from_file: Key $key not found in file $file." >&2
  exit 1
fi

set_env --name="$name" --value="$value" --mask=$mask