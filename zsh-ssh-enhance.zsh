#!/usr/bin/env zsh

SSH_CONFIG_FILE="$HOME/.ssh/config"

ssh_config=$(jq -n '{}')


parse_ssh_config_to_json() {
  local host_config=$(jq -n '{}')
  local current_hostname=""

  while IFS= read -r line; do
    line=$(echo "$line" | sed 's/[[:space:]]*$//')
    # If line start with Host, extract the host name
    if [[ $line =~ ^Host[[:space:]]+(.+) ]]; then
      current_hostname=${match[1]}
      host_config=$(jq -n '{}')

    elif [[ -n $current_hostname ]]; then
      # If line starts with a space, it's a property of the current host
      if [[ $line =~ ^[[:space:]]+(.+)[[:space:]]+(.+) ]]; then
        host_config=$(echo $host_config | jq --arg k ${match[1]} --arg v ${match[2]} '.[$k] = $v')
        ssh_config=$(echo $ssh_config | jq --arg k $current_hostname --argjson v $host_config '.[$k] = $v')
      fi
    fi

  done < "$SSH_CONFIG_FILE"
}

ssh_enhance() {
  local host=$1

  parse_ssh_config_to_json
  local host_config=$(echo $ssh_config | jq -r --arg k $host '.[$k]')
  local password=$(echo $host_config | jq -r '."#Password"')

  if [[ "$password" == "null" ]]; then
    ssh $@
  else
    if command -v sshpass &> /dev/null; then
      echo "Using sshpass for automatic password input."
      sshpass -p $password ssh $@
    else
      echo "It appears you've set up #Password but sshpass is not installed. Please install sshpass to use automatic password filling."
      echo "On macOS, you can install it using Homebrew: brew install hudochenkov/sshpass/sshpass"
    fi
  fi
}


zle -N ssh_enhance

alias ssh="ssh_enhance"
