#!/usr/bin/env zsh

SSH_CONFIG_FILE="$HOME/.ssh/config"

ssh_config=$(jq -n '{}')


_parse_ssh_config_to_json() {
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
  _parse_ssh_config_to_json

  if [[ $# -eq 0 ]]; then
    if command -v sshpass &> /dev/null; then
      _ssh_selector
    else
      echo "It appears you've try to use ssh selector but fzf is not installed. Please install fzf to use ssh selector."
      echo "On macOS, you can install it using Homebrew: brew install fzf"
    fi

  else
    local host=$1
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
  fi
}


scp_enhance() {
  _parse_ssh_config_to_json

  local args=()
  local src=""
  local dest=""
  local src_host=""
  local dest_host=""
  local src_password=""
  local dest_password=""

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -*)
        args+=("$1")
        ;;
      *)
        if [[ -z "$src" ]]; then
          src="$1"
        elif [[ -z "$dest" ]]; then
          dest="$1"
        else
          args+=("$1")
        fi
        ;;
    esac
    shift
  done

  if [[ "$src" == *:* ]]; then
    src_host=$(echo "$src" | awk -F':' '{print $1}')
    local src_config=$(echo $ssh_config | jq -r --arg k $src_host '.[$k]')
    src_password=$(echo $src_config | jq -r '."#Password"')
  fi

  if [[ "$dest" == *:* ]]; then
    dest_host=$(echo "$dest" | awk -F':' '{print $1}')
    local dest_config=$(echo $ssh_config | jq -r --arg k $dest_host '.[$k]')
    dest_password=$(echo $dest_config | jq -r '."#Password"')
  fi

  if [[ -n "$src_password" && "$src_password" != "null" ]]; then
    if command -v sshpass &> /dev/null; then
      echo "Using sshpass for automatic password input for source."
      sshpass -p "$src_password" scp "${args[@]}" "$src" "$dest"
      return
    else
      echo "It appears you've set up #Password for the source but sshpass is not installed. Please install sshpass to use automatic password filling."
      echo "On macOS, you can install it using Homebrew: brew install hudochenkov/sshpass/sshpass"
      return 1
    fi
  fi

  if [[ -n "$dest_password" && "$dest_password" != "null" ]]; then
    if command -v sshpass &> /dev/null; then
      echo "Using sshpass for automatic password input for destination."
      sshpass -p "$dest_password" scp "${args[@]}" "$src" "$dest"
      return
    else
      echo "It appears you've set up #Password for the destination but sshpass is not installed. Please install sshpass to use automatic password filling."
      echo "On macOS, you can install it using Homebrew: brew install hudochenkov/sshpass/sshpass"
      return 1
    fi
  fi

  scp "${args[@]}" "$src" "$dest"
}


_ssh_selector() {
  local hosts=$(echo "$ssh_config" | jq -r 'keys[]')
  if [[ -z "$hosts" ]]; then
    echo "No hosts found in $SSH_CONFIG_FILE"
    return 1
  fi

  local host_list=$(echo "$ssh_config" | jq -r '
    to_entries[] |
    "\(.key)\t\(.value.HostName // "N/A")\t\(.value.User // "N/A")\t\((.value["#Password"] // "N/A") | if . != "N/A" then "******" else . end)"
  ')

  local selected=$(echo "$host_list" | fzf --prompt="Select a host (Load from ${SSH_CONFIG_FILE}): " --height=13 --reverse --header="Host|HostName|User|#Password" --with-nth=1,2,3,4)
  if [[ -z "$selected" ]]; then
    echo "No host selected."
    return 1
  fi

  local selected_host=$(echo "$selected" | awk '{print $1}')
  ssh_enhance "$selected_host"
}


zle -N ssh_enhance
alias ssh="ssh_enhance"

zle -N scp_enhance
alias scp="scp_enhance"
