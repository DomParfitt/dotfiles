#!/bin/bash

# Check for Antigen and install it if it isn't present
antigen="$HOME/antigen.zsh"
if ! [[ -r "$antigen" ]]; then
    curl -L git.io/antigen > $HOME/antigen.zsh
fi

# Check for Oh My ZSH and install it if it isn't present
oh_my_zsh="$HOME/.oh-my-zsh"
if ! [[ -d "$oh_my_zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    upgrade_oh_my_zsh
fi

# chsh -s "$(which zsh)"
