function emacs --wraps='emacsclient -c &' --description 'alias emacs=emacsclient -c &'
  emacsclient -c -e "(raise-frame)" $argv &     
end
