#!/usr/bin/env bash

# Check if required packages are installed and exit with message if not
prerequisites=(curl python zsh)
for package in "${prerequisites[@]}"; do
  if ! command -v "${package}" > /dev/null 2>&1; then
    echo "${package} is not installed. You must install it before continuing."
    exit 1
  fi
done

# Check for Antigen and install it if it isn't present
antigen="$HOME/antigen.zsh"
if ! [[ -r "$antigen" ]]; then
    curl -L git.io/antigen > "$antigen"
fi

# Check for Oh My ZSH and install it if it isn't present
oh_my_zsh="$HOME/.oh-my-zsh"
if ! [[ -d "$oh_my_zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
