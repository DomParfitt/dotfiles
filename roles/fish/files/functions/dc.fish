function dc --wraps=docker-compose --description 'alias dc=docker-compose'
  if type --query docker-compose
    docker-compose $argv; 
  end

  docker compose $argv
end
