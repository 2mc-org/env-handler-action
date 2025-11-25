#!/bin/bash

variable_name="$1"
token="$2"

# Check if GITHUB_TOKEN is set in token
if [[ -z "$token" ]]; then
  token="$GITHUB_TOKEN"
fi

if [[ -z "$token" ]]; then
  echo "get_variable: GITHUB_TOKEN is not set" >&2
  exit 1
fi

# Request to GitHub API
url="https://api.github.com/repos/${GITHUB_REPOSITORY}/actions/variables/$variable_name"

response=$(curl -s -H "Authorization: Bearer $token" -H "Accept: application/vnd.github+json" "$url")

if [[ "$(echo "$response" | jq -r '.message')" == "Not Found" ]]; then
  echo "get_variable: Failed to fetch $variable_name" >&2
  exit 1
fi

value=$(echo "$response" | jq -r '.value')

if [[ -z "$value" ]]; then
  echo "get_variable: $variable_name variable is empty" >&2
  exit 1
fi

echo "$value"