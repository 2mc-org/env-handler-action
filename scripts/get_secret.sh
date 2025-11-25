#!/bin/bash

key="$1"

value=$(echo "$SECRETS_JSON" | jq -r --arg key "$key" '.[$key]')

if [[ -z "$value" || "$value" == "null" ]]; then
  # echo "get_secret: Secret $key not found" >&2
  exit 1
fi

echo "$value"