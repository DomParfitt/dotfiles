#!/bin/bash

source "$HOME/.zshrc"

# Check for Rust and install it if it isn't present
rustup="$HOME/.rustup"
if ! [[ -d "${rustup}" ]]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    rustup completions zsh > ~/.zfunc/_rustup
else
    rustup update
fi
