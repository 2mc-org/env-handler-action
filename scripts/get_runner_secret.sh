#!/bin/bash

filename="$1"
file_path="/org-secrets/$filename"

if [[ ! -f "$file_path" ]]; then
  echo "get_runner_secret: File $file_path does not exist" >&2
  exit 1
fi

content=$(<"$file_path" tr -d '\r')

echo "$content"