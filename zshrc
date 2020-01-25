# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
 ZSH_THEME="robbyrussell"
# ZSH_THEME=powerlevel10k/powerlevel10k

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=7

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  zsh-nvm
  git
  aws
  rust
  cargo
)

source $ZSH/oh-my-zsh.sh

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
alias ts="yo simple-ts"
alias quad="terminator -l quad"

# Set PATH
export GOPATH=$HOME/go
# export PATH="$PATH:~/bin:$GOPATH/bin"
# export PATH="$HOME/.cargo/bin:$PATH"
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

# Change prompt to show full path
PROMPT='${ret_status} %{$fg[cyan]%}%~%{$reset_color%} $(git_prompt_info)'

# Completion for NVM
if [[ -r "$NVM_DIR/bash_completion" ]]; then
  source "$NVM_DIR/bash_completion"
fi

# Completion for AWS CLI
if [[ -f "$HOME/.local/bin/aws_zsh_completer.sh" ]] ; then
  source "$HOME/.local/bin/aws_zsh_completer.sh"
fi

# Purepower config for Powerlevel10k
if [[ -f "$HOME/.purepower" ]]; then
  source "$HOME/.purepower"
fi

# Custom config for Powerlevel10k
export POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir_writable dir vcs)
export POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(public_ip aws)
# export POWERLEVEL9K_PROMPT_ON_NEWLINE=false
export POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="%(?.%F{002}\u03BB%f.%F{009}\u03BB%f) "
export POWERLEVEL9K_PUBLIC_IP_BACKGROUND='026'
export POWERLEVEL9K_AWS_BACKGROUND='208'
export POWERLEVEL9K_AWS_FOREGROUND='239'
export POWERLEVEL9K_MODE='nerdfont-complete'
