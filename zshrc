#!/usr/bin/env zsh

# Start tmux automatically and close the terminal on exiting tmux

# Check tmux is installed
if command -v tmux > /dev/null 2>&1; then
  # Check we're running an interactive shell and we're not already in tmux
  if [[ $- == *i* ]] && [[ -z "$TMUX" ]]; then
    # Run tmux and when that process closes exit the terminal
    tmux && exit
  fi
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set up Antigen
source "$HOME/antigen.zsh"

antigen use oh-my-zsh

# Install plugins
antigen bundles <<EOBUNDLES
  lukechilds/zsh-nvm
  aws
  rust
  cargo
EOBUNDLES

# Install themes
antigen theme romkatv/powerlevel10k

# Apply antigen config
antigen apply

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=7

# Run Oh My ZSH
source "$ZSH/oh-my-zsh.sh"

# Set PATH
export GOPATH="$HOME/go"

path+=(
  "$HOME/.cargo/bin"
  "$HOME/.local/bin"
  "$HOME/bin"
  "$GOPATH/bin"
  "/usr/local/bin"
)

export PATH

# Import and set aliases
source "$HOME/.aliases"

# Import utility functions
source "$HOME/.functions"

# Set FPath for functions
fpath+=(
  "$HOME/.zfunc"
)

# TLDR Formatting
export TLDR_QUOTE='white italic'
export TLDR_HEADER='blue bold underline'
export TLDR_DESCRIPTION='green bold italic'
export TLDR_CODE='red bold'
export TLDR_PARAM='cyan bold'

# Completion for NVM
if [[ -r "$NVM_DIR/bash_completion" ]]; then
  source "$NVM_DIR/bash_completion"
fi

# Completion for AWS CLI
if [[ -r "$HOME/.local/bin/aws_zsh_completer.sh" ]]; then
  source "$HOME/.local/bin/aws_zsh_completer.sh"
fi

# Completions for Rust/Cargo
if ! [[ -r "$HOME/.zfunc/_rustup" ]]; then
  rustup completions zsh >"$HOME/.zfunc/_rustup"
fi

# Source Powerlevel10k config
if [[ -r "$HOME/.p10k.zsh" ]]; then
  source "$HOME/.p10k.zsh"
fi
