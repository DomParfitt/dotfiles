function launch_tmux --description "Launch a tmux session if not already in one"
  # Check tmux is installed
  if not type --query tmux
    return
  end

  # Check we're not already in a tmux session
  if set --query TMUX
    return
  end

  # Run tmux and exit once it does
#  tmux; and exit 
  exec tmux
end
