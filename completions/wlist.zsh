if [[ ! -o interactive ]]; then
    return
fi

compctl -K _wlist wlist

_wlist() {
  local word words completions
  read -cA words
  word="${words[2]}"

  if [ "${#words}" -eq 2 ]; then
    completions="$(wlist commands)"
  else
    completions="$(wlist completions "${word}")"
  fi

  reply=("${(ps:\n:)completions}")
}
