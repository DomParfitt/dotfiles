function pc --wraps=podman-compose --description 'alias pc=podman-compose'
  podman-compose $argv; 
end
