set -U fisher_path ~/.config/fisher

set -a fish_function_path $fisher_path/functions
set -a fish_complete_path $fisher_path/completions

for file in $fisher_path/conf.d/*.fish
  source $file
end
