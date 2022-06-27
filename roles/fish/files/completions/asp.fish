set profiles (sed -nr 's/\[profile (.*)\]/\1/p' ~/.aws/config)
#echo $profiles
complete -c asp -f -a (string join ' ' $profiles)
