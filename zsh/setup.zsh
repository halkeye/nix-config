if [[ -n ${commands[lsd]} ]]; then
  if [ -n "${commands[vivid]}" ]; then
    export LS_COLORS="$(vivid generate molokai)"
  fi
  alias lsd="lsd --classify --date=relative"
fi

## From: https://unix.stackexchange.com/questions/258656/how-can-i-delete-to-a-slash-or-a-word-in-zsh
# This way you can use ctrl+w for deleting a Word (in vim lingo) and alt+bkspc to delete a word
backward-kill-dir () {
    local WORDCHARS=${WORDCHARS/\/}
    zle backward-kill-word
}
zle -N backward-kill-dir
bindkey '^[^?' backward-kill-dir

# mkcd is equivalent to takedir
function mkcd takedir() {
  mkdir -p $@ && cd ''${@:$#}
}

function takeurl() {
  local data thedir
  data="$(mktemp)"
  curl -L "$1" > "$data"
  tar xf "$data"
  thedir="$(tar tf "$data" | head -n 1)"
  rm "$data"
  cd "$thedir"
}

function takegit() {
  git clone "$1"
  cd "$(basename ''${1%%.git})"
}

function take() {
  if [[ $1 =~ ^(https?|ftp).*\.(tar\.(gz|bz2|xz)|tgz)$ ]]; then
    takeurl "$1"
  elif [[ $1 =~ ^([A-Za-z0-9]\+@|https?|git|ssh|ftps?|rsync).*\.git/?$ ]]; then
    takegit "$1"
  else
    takedir "$@"
  fi
}

string_hash() {
  local hashstr=$1
  local hashsize=$2
  local hashval=52

  for i in {1..${#hashstr}}; do
    local thischar=$hashstr[$i]
    hashval=$(( $hashval + $((#thischar)) ))
  done

  # Avoid 0 as that's black
  hashsize=$(( $hashsize - 1 ))
  hashval=$(( $hashval % $hashsize ))
  hashval=$(( $hashval + 1 ))

  echo $hashval
}

wttr() {
  local request="wttr.in/${1-Vancouver}"
  [ "$COLUMNS" -lt 125 ] && request+='?n'
  curl -H "Accept-Language: ${LANG%_*}" --compressed "$request"
}

passgen() {
  local pass
  pass=$(nix run nixpkgs#xkcdpass -- -d '-' -n 3 -C capitalize "$@")
  echo "${pass}$((RANDOM % 10))"
}

fixssh() {
  for key in SSH_AUTH_SOCK SSH_CONNECTION SSH_CLIENT; do
    if (tmux show-environment | grep "^${key}" > /dev/null); then
      value=$(tmux show-environment | grep "^${key}" | sed -e "s/^[A-Z_]*=//")
      export ${key}="${value}"
    fi
  done
}

tmux-upterm() {
  if [ -z "$1" ]; then
    echo "Usage: tmux-upterm <github-username>"
    return 1
  fi
  upterm host --github-user "$1" --server ssh://upterm.thalheim.io:2323 \
    --force-command 'tmux attach -t pair-programming' \
    -- tmux new -t pair-programming
}

if [[ -n $HOST && "$__host__" != "$HOST" ]]; then
  tmux set -g status-bg "colour$(string_hash "$HOST" 255)"
  export __host__=$HOST
fi

