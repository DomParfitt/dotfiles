function ll --wraps=ls --wraps='ls -ahl' --description 'alias ll=ls -ahl'
  ls -ahl $argv; 
end
