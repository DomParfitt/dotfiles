#!/usr/bin/env bash

# Load zsh plugins
(zsh)

# Install Vim plugins
vim +'PlugInstall --sync' +qa

# Install VS Code extensions
if command -v code > /dev/null 2>&1; then
    xargs -L 1 code --install-extension < vscode/extensions.txt
fi

# Check for Rust and install it if it isn't present
rustup="$HOME/.rustup"
if ! [[ -d "${rustup}" ]]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
else
    rustup update
fi

# Manually add cargo to the path
export PATH="$PATH:$HOME/.cargo/bin"

# Install useful Rust binaries
cargo install bat
cargo install exa
cargo install ripgrep