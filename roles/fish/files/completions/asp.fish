if test -e ~/.aws/config
  set --local profiles (sed -nr 's/\[profile (.*)\]/\1/p' ~/.aws/config)
  complete -c asp -f -a (string join ' ' $profiles)
else
  complete -c asp -f
end
