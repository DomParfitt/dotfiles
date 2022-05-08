if status is-interactive
    
    # Use prefix search on Up for history
    bind --key up history-prefix-search-backward    
    bind \e\[A history-prefix-search-backward

    # Set prompt theme
    starship init fish | source

    set fish_color_command green
    set fish_color_param white
end


