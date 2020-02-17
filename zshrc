# Start tmux automatically and close the terminal on exiting tmux
# Check we're on a graphical shell
if [[ "$DISPLAY" ]]; then

  # Check tmux is installed
  if command -v tmux > /dev/null 2>&1; then

    # Check we're running an interactive shell and we're not already in tmux
    if [[ $- == *i* ]] && [[ -z "$TMUX" ]]; then
      
      # Run tmux and when that process closes exit the terminal
      tmux && (tmux kill-server || true) && exit
    fi
  fi
fi

# Required for `tmuxp`
export DISABLE_AUTO_TITLE='true'

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block, everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
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

# Import and set aliases
source "$HOME/.aliases"

# Set PATH
export GOPATH="$HOME/go"

path+=(
  "$HOME/bin"
  "/usr/local/bin"
  "$GOPATH/bin"
  "$HOME/.cargo/bin"
)

export PATH

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
