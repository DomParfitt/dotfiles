if type --query bat
  set -Ux MANPAGER "sh -c 'col -bx | bat -l man -p'"
  set -Ux MANROFFOPT "-c"
end
