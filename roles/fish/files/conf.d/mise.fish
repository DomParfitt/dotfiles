mise activate fish | source

if not test -f ~/.config/fish/completions/mise.fish
  mise completion fish > ~/.config/fish/completions/mise.fish
end

