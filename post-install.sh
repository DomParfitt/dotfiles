#!/bin/bash

# Check for Rust and install it if it isn't present
rustup="$HOME/.rustup"
if ! [[ -d "${rustup}" ]]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
else
    rustup update
fi
