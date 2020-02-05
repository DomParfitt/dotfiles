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
# antigen theme robbyrussell

# Apply antigen config
antigen apply

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=7

source "$ZSH/oh-my-zsh.sh"

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Import and set aliases
source "$HOME/.aliases"

# Set PAGER
if which most > /dev/null 2>&1; then
  export PAGER='most'
fi

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
