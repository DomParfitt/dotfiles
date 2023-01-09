function myip --description "Returns the current public IP address of the machine"
  argparse (fish_opt -s f -l force) -- $argv
  if set --query _flag_force
    _store_my_ip
    return $status
  end

  if test -z "$MY_IP"; or test -z "$MY_IP_SET_AT"
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
    set --local ip $(_get_my_ip)
    if test -n "$ip"
      set -e MY_IP
      set -e MY_IP_SET_AT

      set -Ux MY_IP $ip
      set -Ux MY_IP_SET_AT $(date +%s)
    end
    echo $MY_IP 
end
