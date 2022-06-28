function asp --argument-names profile --description "Sets and clears the AWS_PROFILE"
  if not type --query aws
    return 0
  end

  if not set --query profile
    set -e AWS_PROFILE
  else
    set -gx AWS_PROFILE $profile
  end
  return 0
end
