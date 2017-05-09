_pswls() {
  local word="${COMP_WORDS[COMP_CWORD]}"

  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "$(pswls commands)" -- "$word") )
  else
    local completions="$(pswls completions "${COMP_WORDS[@]:1}")"
    COMPREPLY=( $(compgen -W "$completions" -- "$word") )
  fi
}

complete -o default -F _pswls pswls
