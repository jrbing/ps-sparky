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
  sleep 5
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
  if [[ `printenv ${1}` = '' ]]; then
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
  local dir_path=$1
  if [ -d ${dir_path} ]; then
    log "INFO - Deleting directory ${dir_path}"
    rm -rf $dir_path
  else
    log "INFO - $dir_path not found"
  fi
}

# Delete the specified directory's contents
deleteDirContents () {
  local dir_path=$1
  if [ -d ${dir_path} ]; then
    log "INFO - Deleting contents of ${dir_path}"
    rm -rf $dir_path/*
  else
    log "INFO - $dir_path not found"
  fi
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
  trap 'kill $(jobs -p)' EXIT
  for file in "$@"
  do
    log "INFO - Beginning tail of $file"
    tail -n 50 -f $file &
  done
  wait
}

spinner () {
  local pid=$1
  local delay=0.75
  local spinstr='|/-\'
  while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
    local temp=${spinstr#?}
    printf " [%c]  " "$spinstr"
    local spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b\b\b\b\b\b"
  done
  printf "    \b\b\b\b"
}

