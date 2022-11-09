function myip --description "Returns the current public IP address of the machine"
  argparse (fish_opt -s f -l force) -- $argv
  if set --query _flag_force
    _store_my_ip
    return $status
  end

  if not set --query MY_IP; or not set --query MY_IP_SET_AT 
    _store_my_ip
    return $status
  end

  set --local age $(math $(date +%s) - $MY_IP_SET_AT)
  if test $age -ge 900
    set -e MY_IP_SET_AT
    _store_my_ip
    return $status
  end

  echo $MY_IP
end

function _get_my_ip
  dig +short myip.opendns.com @resolver1.opendns.com
end

function _store_my_ip
    set -Ux MY_IP $(_get_my_ip)
    set -Ux MY_IP_SET_AT $(date +%s)
    echo $MY_IP 
end
