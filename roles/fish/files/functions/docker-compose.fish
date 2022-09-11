function docker-compose --wraps=podman-compose --description 'alias docker-compose=podman-compose'
  if type --query podman-compose
    podman-compose $argv;
  else
    docker-compose $argv;
  end
end
