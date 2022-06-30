function close --argument-names pane_id --description "Closes all tmux panes"
  if set --query pane_id
    tmux kill-pane -t $pane_id
  else
    tmux kill-session -t $(tmux display-message -p '#S')
  end
end
