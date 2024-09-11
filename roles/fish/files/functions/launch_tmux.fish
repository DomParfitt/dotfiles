function launch_tmux --description "Launch a tmux session if not already in one"
  # Don't use tmux if we've set an env var to disable it
  if set --query NO_TMUX
    echo Not running in tmux as NO_TMUX is set
    return
  end

  # Stop VSCode opening tmux as part of its shell resolution
  if set --query VSCODE_RESOLVING_ENVIRONMENT
    echo Not running in tmux as VSCODE_RESOLVING_ENVIRONMENT is set
    return
  end

  # Check tmux is installed
  if not type --query tmux
    return
  end

  # Check we're not already in a tmux session
  if set --query TMUX
    return
  end

  # Run tmux and exit once it does
  exec tmux
end
