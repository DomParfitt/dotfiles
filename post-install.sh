#!/bin/bash

# Check for Rust and install it if it isn't present
rustup="$HOME/.rustup"
if ! [[ -d "${rustup}" ]]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
else
    rustup update
fi

if command -v code > /dev/null 2>&1; then
    xargs -L 1 code --install-extension < vscode/extensions.txt
fi
