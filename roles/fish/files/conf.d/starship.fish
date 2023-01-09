if type --query starship
  set -Ux STARSHIP_LOG error
  starship init fish | source
end
