if [[ ! -o interactive ]]; then
    return
fi

compctl -K _pswls pswls

_pswls() {
  local word words completions
  read -cA words
  word="${words[2]}"

  if [ "${#words}" -eq 2 ]; then
    completions="$(pswls commands)"
  else
    completions="$(pswls completions "${word}")"
  fi

  reply=("${(ps:\n:)completions}")
}
