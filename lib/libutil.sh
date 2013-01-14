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
  local dir_paths=$@
  for dir in $dir_paths; do
    if [ -d ${dir} ]; then
      log "INFO - Deleting directory ${dir}"
      rm -rfv $dir
    else
      log "INFO - $dir not found"
    fi
  done
}

# Delete the content of the specified directories
deleteDirContents () {
  local dir_paths=$@
  for dir in $dir_paths; do
    if [ -d ${dir} ]; then
      log "INFO - Deleting contents of ${dir}"
      rm -rfv $dir/*
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
  trap 'kill $(jobs -p)' EXIT
  for file in "$@"
  do
    log "INFO - Beginning tail of $file"
    tail -n 50 -f $file &
  done
  wait
}

function _spinner() {

  # $1 start/stop
  #
  # on start: $2 display message
  # on stop : $2 process exit status
  #           $3 spinner function pid (supplied from stop_spinner)

  local on_success="DONE"
  local on_fail="FAIL"
  local white="\e[1;37m"
  local green="\e[1;32m"
  local red="\e[1;31m"
  local nc="\e[0m"

  case $1 in

    (start)
      # Calculate the column where spinner and status msg will be displayed
      let column=$(tput cols)-${#2}-8
      # Display message and position the cursor in $column column
      echo -ne ${2}
      printf "%${column}s"

      # Start spinner
      i=1
      sp='\|/-'
      delay=0.15

      while :
      do
        printf "\b${sp:i++%${#sp}:1}"
        sleep $delay
      done
      ;;

    (stop)
      if [[ -z ${3} ]]; then
        printf "Spinner is not running.."
        exit 1
      fi

      kill $3 > /dev/null 2>&1

      # Inform the user upon success or failure
      echo -en "\b["
      if [[ $2 -eq 0 ]]; then
        echo -en "${green}${on_success}${nc}"
      else
        echo -en "${red}${on_fail}${nc}"
      fi
      echo -e "]"
      ;;

    (*)
      printf "Invalid argument, try {start/stop}\n"
      exit 1
      ;;

  esac
}

function start_spinner {
  # $1 : msg to display
  _spinner "start" "${1}" &
  # set global spinner pid
  _sp_pid=$!
  disown
}

function stop_spinner {
  # $1 : command exit status
  _spinner "stop" $1 $_sp_pid
  unset _sp_pid
}
