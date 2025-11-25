#!/bin/bash

# Change directory to scripts
cd scripts

# Create bin directory if it doesn't exist
mkdir -p bin

# Add bin directory to PATH
export PATH="$PATH:$(pwd)/bin"

# Create links for all scripts
for script in ./*.sh; do
  script_basename=$(basename "${script}" .sh)
  script_path="$(pwd)/${script}"
  script_link="$(pwd)/bin/${script_basename}"

  ln -sf $script_path $script_link
  chmod +x $script_link
done