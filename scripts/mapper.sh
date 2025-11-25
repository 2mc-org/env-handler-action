#!/bin/bash

name=""
criteria=""
mask=false
logLines="all"
declare -A params

# Process arguments
while [[ "$#" -gt 0 ]]; do
  case $1 in
    --name=*) name="${1#*=}" ;;
    --criteria=*) criteria="${1#*=}" ;;
    --mask) mask=true ;;
    --logLines=*) logLines="${1#*=}" ;;
    *)
      # Extract parameter as key=value
      key=${1%%=*}
      value=${1#*=}
      params[$key]="$value"
      ;;
  esac
  shift
done

# Check if all required parameters are set
if [[ -z "$name" || -z "$criteria" ]]; then
  echo "mapper: Both --name and --criteria parameters are required." >&2
  exit 1
fi

# Select the value by criteria
result="${params[$criteria]}"

if [[ -z "$result" ]]; then
  echo "mapper: No matching value found for criteria $criteria" >&2
  exit 1
fi

set_env --name="$name" --value="$result" --mask=$mask --logLines=$logLines