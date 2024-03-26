set --local roles (./setup -l)
complete -c setup -f -a (string join ' ' $roles)

set --local opts (./setup -h | \
   # Get the flag info from the usage message
   sed '1,/option/d' | \
   # Replace any sequence of spaces with a single space
   string replace -ar '\s+' ' ' | \
   # Remove newlines to get rid of extras
   tr -d \n | \
   # Reinsert newlines between flags
   string replace -ar ' (-\w)' '\n$1' | \
   # Split each line into required sections
   # Should be: -<short-flag> --<long-flag> description
   string replace -afr '\\-([a-z]+),? (--([a-z]+[a-z\\-]*))?\s?(.*)' '$1,$3,$4')

for option in $opts
  set --local opt (echo $option | string split ,)
  if test -n $opt[2]
     complete -c setup -s $opt[1] -l $opt[2] -d $opt[3]
  else
     complete -c setup -s $opt[1] -d $opt[3]
  end
end
