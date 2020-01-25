#!/bin/bash

# Check for Oh My ZSH and install it if it isn't present
oh_my_zsh="$HOME/.oh-my-zsh"
if ! [[ -d ${oh_my_zsh} ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    upgrade_oh_my_zsh
fi

# Check for Rust and install it if it isn't present
rustup="$HOME/.rustup"
if ! [[ -d "${rustup}" ]]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
else
    rustup update
fi

chsh -s "$(which zsh)"
