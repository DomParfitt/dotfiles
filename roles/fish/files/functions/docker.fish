function docker --wraps=podman --description 'alias docker=podman'
  if type --query podman
    podman $argv;
  else
    docker $argv;
  end
end
