#!/usr/bin/env bash
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8
#===============================================================================
#
#          FILE: libutil.sh
#
#   DESCRIPTION: Library file for shared utility functions
#
#===============================================================================

ENV_VARS=( HOME PS_HOME PS_CFG_HOME PS_APP_HOME PS_PIA_HOME )
COLORS=$(tput colors 2>/dev/null || echo 0)

function __detect_color_support() {
  if [[ $? -eq 0 ]] && [[ "$COLORS" -gt 2 ]]; then
    RC="\033[1;31m"
    GC="\033[1;32m"
    YC="\033[1;33m"
    BC="\033[1;34m"
    EC="\033[0m"
  else
    RC=""
    GC=""
    YC=""
    BC=""
    EC=""
  fi
}
__detect_color_support

function echoError() {
  printf "${RC} *  ERROR${EC}: %s\n" "$@" 1>&2;
}

function echoInfo() {
  printf "${GC} *  INFO${EC}: %s\n" "$@";
}

function echoWarn() {
  printf "${YC} *  WARN${EC}: %s\n" "$@";
}

function echoDebug() {
  if [[ $DEBUG ]]; then
    printf "${BC} *  DEBUG${EC}: %s\n" "$@";
  fi
}

function printHL () {
  printf "\n${YC}----------------------------------------${EC}\n"
}

function printBanner () {
  printHL
  printf "${BC}####  %s  ####${EC}" "$@";
  printHL
}

function printBlankLine () {
  printf "\n"
}

function checkPsftVars () {
  for var in "${ENV_VARS[@]}"; do
    echoDebug "Checking ${var}"
    if [[ "$(printenv ${var})" = '' ]]; then
      echoError "${var} is not set.  Please make sure this is set before continuing."
      exit 1
    fi
  done

  if [[ ! -n "$TUXDIR" ]] && [[ ! -n "$CYGWIN" ]]; then
    echoError "TUXDIR is not set.  Please make sure this is set before continuing."
    exit 1
  fi
}

function checkVar () {
  echoDebug "Checking ${*}"
  if [[ $(printenv ${1}) = '' ]]; then
    log "ERROR - ${1} is not set.  You'll need to set this in your environment file."
    exit 1
  fi
}

function deleteFile () {
  echoDebug "Arguments to deleteFile are: ${*}"
  for dir in "$@"; do
    local file_path=$1
    if [ -f "${file_path}" ]; then
      echoInfo "Deleting file ${file_path}"
      rm -v "$file_path"
    else
      echoWarn "$file_path not found"
    fi
  done
}

function deleteDir () {
  echoDebug "Arguments to deleteDir are: ${*}"
  for dir in "$@"; do
    if [[ -d ${dir} ]]; then
      echoInfo "Deleting directory ${dir}"
      rm -rfv "$dir"
    else
      echoWarn "$dir not found"
    fi
  done
}

function deleteDirContents () {
  echoDebug "Arguments to deleteDirContents are: ${*}"
  for dir in "$@"; do
    if [[ -d ${dir} ]]; then
      echoInfo "Deleting contents of ${dir}"
      rm -rfv "${dir:?}"/*
    else
      echoWarn "$dir not found"
    fi
  done
}

function assignScriptExtension () {
  case $(uname -s) in
    (Linux*)
      echoDebug "OS is Linux"
      SCRIPT_EXT=".sh"
    ;;
    (SunOS*)
      echoDebug "OS is Solaris"
      SCRIPT_EXT=".sh"
    ;;
    (CYGWIN*)
      echoDebug "OS is Windows (via Cygwin)"
      SCRIPT_EXT=".bat"
    ;;
    (*)
      echoDebug "Could not determine OS...defaulting script extension to .sh"
      SCRIPT_EXT=".sh"
    ;;
  esac
}

function multiTail () {
  echoDebug "Arguments to multiTail: ${*}"
  trap 'kill $(jobs -p)' EXIT
  for file in "$@"; do
    if [[ -e $file ]]; then
      echoInfo "Beginning tail of $file"
      tail -n 50 -f "$file" | awk '{"date \"+%Y%m%d_%H%M%S\"" | getline now} {close("date")} {print now ": " $0}' &
    fi
  done
  wait
}

function binCheck() {
  echoDebug "Arguments to binCheck: ${*}"
  for p in ${1}; do
    hash "$p" 2>&- || \
    { echoError "Required program \"$p\" not available in PATH"; exit 1; }
  done
}

function fileExists {
  echoDebug "Arguments to fileExists: ${*}"
  if [[ -f "$1" ]]; then
      return 0
  fi
  return 1
}

function tolower {
  echoDebug "Arguments to toLower: ${*}"
  echo "$1" | tr '[:upper:]' '[:lower:]'
}

function toupper {
  echoDebug "Arguments to toUpper: ${*}"
  echo "$1" | tr '[:lower:]' '[:upper:]'
}

function trim {
  echoDebug "Arguments to trim: ${*}"
  echo "$1"
}

function optionEnabled () {
  echoDebug "Arguments to optionEnabled: ${*}"
  local var="$1"
  local var_value=$(eval echo \$$var)
  if [[ "$var_value" == "y" ]] || [[ "$var_value" == "yes" ]]
  then
      return 0
  else
      return 1
  fi
}

function pause () {
  echoDebug "Called the pause function"
  sleep 2
}

