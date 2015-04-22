#!/usr/bin/env bash
# Library file for shared utility functions

ENV_VARS=( HOME PS_HOME PS_CFG_HOME PS_APP_HOME PS_PIA_HOME )

########
# Output
########

printHL () {
  printf "\n----------------------------------------\n"
}

printBanner () {
  printHL
  printf "\e[00;31m####  $1  ####\e[00m\n"
  printHL
}

printBlankLine () {
  printf "\n"
}

pause () {
  sleep 2
}

#################################
# Environment Variable Validation
#################################

# Check to see if the appropriate environment variables are set
checkPsftVars () {
  for i in $ENV_VARS; do
    if [[ `printenv ${i}` = '' ]]; then
      printf "${i} is not set.  Please make sure this is set before continuing.\n"
      exit 1
    fi
  done

  if [[ ! -n "$TUXDIR" ]] && [[ ! -n "$CYGWIN" ]]; then
    printf "TUXDIR is not set.  Please make sure this is set before continuing.\n"
    exit 1
  fi
}

# Check to see if the appropriate environment variable is set
checkVar () {
  if [[ $(printenv ${1}) = '' ]]; then
    log "ERROR - ${1} is not set.  You'll need to set this in your environment file."
    exit 1
  fi
}

##########
# Deletion
##########

# Delete the specified file
deleteFile () {
  local file_path=$1
  if [ -f ${file_path} ]; then
    log "INFO - Deleting file ${file_path}"
    rm $file_path
  else
    log "INFO - $file_path not found"
  fi
}

# Delete the specified directory recursively
deleteDir () {
  for dir in "$@"; do
    if [[ -d ${dir} ]]; then
      log "INFO - Deleting directory ${dir}"
      rm -rf "$dir"
    else
      log "INFO - $dir not found"
    fi
  done
}

# Delete the content of the specified directories
deleteDirContents () {
  for dir in "$@"; do
    if [[ -d ${dir} ]]; then
      log "INFO - Deleting contents of ${dir}"
      rm -rf "$dir:?"/*
    else
      log "INFO - $dir not found"
    fi
  done
}

###############
# Miscellaneous
###############

assignScriptExtension () {
  case $(uname -s) in
    (Linux*)
      SCRIPT_EXT=".sh"
    ;;
    (SunOS*)
      SCRIPT_EXT=".sh"
    ;;
    (CYGWIN*)
      SCRIPT_EXT=".bat"
    ;;
    (*)
      SCRIPT_EXT=".sh"
    ;;
  esac
}

multiTail () {
  if (hash lnav 2>/dev/null); then
    lnav "$@"
  else
    trap 'kill $(jobs -p)' EXIT
    for file in "$@"; do
      if [[ -e $file ]]; then
        log "INFO - Beginning tail of $file"
        tail -n 50 -f "$file" | awk '{"date \"+%Y%m%d_%H%M%S\"" | getline now} {close("date")} {print now ": " $0}' &
      fi
    done
    wait
  fi

}

bincheck() {
  for p in ${1}; do
    hash "$p" 2>&- || \
    { log "ERROR - Required program \"$p\" not available in PATH"; exit 1; }
  done
}


