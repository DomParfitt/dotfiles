function docker --wraps=podman --description 'alias docker=podman'
  if type --query podman
    podman $argv;
  else
    command docker $argv;
  end
end
