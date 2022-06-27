if status is-interactive
    set fish_greeting
    launch_tmux

    # Use prefix search on Up for history
    bind --key up history-prefix-search-backward    
    bind \e\[A history-prefix-search-backward

    # Set prompt theme
    starship init fish | source

    # Set colors
    set fish_color_command green
    set fish_color_param white
    set fish_color_search_match --background=normal

    # Set PATH
    fish_add_path \
      ~/.cargo/bin \
      ~/.local/bin \
      ~/bin \
      ~/go/bin \
      /usr/local/bin \
      /usr/local/go/bin
end

