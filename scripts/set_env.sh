#!/bin/bash

mask=false
logLines="all"

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --name=*) name="${1#*=}" ;;
    --name) name="$2"; shift ;;
    --value=*) value="${1#*=}" ;;
    --value) value="$2"; shift ;;
    --valueToLowerCase) valueToLowerCase="true" ;;
    --mask) mask=true ;;
    --mask=*) mask="${1#*=}" ;;
    --logLines=*) logLines="${1#*=}" ;;
    *) echo "Unknown parameter passed in set_env: $1"; exit 1 ;;
  esac
  shift
done

# Check if all required parameters are set
if [[ -z "$name" || -z "$value" ]]; then
  echo "set_env: Both --name and --value parameters are required." >&2
  exit 1
fi

# Check if value should be converted to lowercase
if [[ "$valueToLowerCase" == "true" ]]; then
  value=${value,,}
fi

# Mask the value
if [[ "$mask" == true ]]; then
  echo "$value" | while IFS= read -r line; do
    if [[ -n "$line" ]]; then
      echo "::add-mask::$line"
    fi
  done
fi

{
  echo "$name<<EOF"
  echo "$value"
  echo "EOF"
} >> "$GITHUB_ENV"

line_count=$(echo "$value" | wc -l)
if [[ "$line_count" -eq 1 ]]; then
  echo "Environment variable $name set to: $value"
else
  echo "Environment variable $name set to:"
  if [[ "$logLines" == "all" ]]; then
    echo "$value"
  else
    echo "$value" | head -n "$logLines" | while IFS= read -r line; do
      echo "$line"
    done
  fi
fi