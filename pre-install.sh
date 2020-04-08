#!/bin/bash

# Check if curl is installed and exit with message if not
if ! command -v curl > /dev/null 2>&1; then
  echo "curl is not installed. You must install it before continuing."
  exit 1
fi 

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
