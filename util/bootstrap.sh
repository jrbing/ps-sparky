#!/usr/bin/env bash
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8
#===============================================================================
#
#          FILE: bootstrap.sh
#
#   DESCRIPTION: Bootstrap script for ps-sparky
#
#===============================================================================

set -e          # Exit immediately on error
set -u          # Treat unset variables as an error
set -o pipefail # Prevent errors in a pipeline from being masked
IFS=$'\n\t'     # Set the internal field separator to a tab and newline

PS_ENV_HOME=$HOME/.environments
INSTALL_DIR=$HOME/.ps-sparky
LINKED_FILES=( "profile" "bash_profile" "bashrc" "vimrc" )

function echoInfo() {
  local GC="\033[1;32m"
  local EC="\033[0m"
  printf "${GC} ☆  INFO${EC}: %s\n" "$@"
}

function createSymlinks () {
  local dateTime=$(date "+%Y%m%d_%H%M%S")
  for file in "${LINKED_FILES[@]}"; do
    if [[ -f ~/.${file} ]] || [[ -h ~/.${file} ]]; then
      echoInfo "Found ~/.${file}"
      echoInfo "Backing up to ~/.${file}.${dateTime}"
      cp "$HOME/.${file}" "$HOME/.${file}.${dateTime}"
      rm "$HOME/.${file}"
    fi
    echoInfo "Creating symlink for ${file}"
    ln -s "${INSTALL_DIR}/etc/${file}" "$HOME/.${file}"
  done
}

function copySparkyRC () {
  if [[ -f $HOME/.sparkyrc ]] || [[ -h $HOME/.sparkyrc ]]; then
    echoInfo "Found preexisting ~/.sparkyrc"
    echoInfo "Skipping creation of sparkyrc"
  else
    echoinfo "Copying sparkyrc"
    cp "${INSTALL_DIR}/examples/sparkyrc" "$HOME/.sparkyrc"
  fi
}

function createEnvironmentsDirectory () {
  if [[ -d $HOME/.environments ]] || [[ -h $HOME/.environments ]]; then
    echoInfo "Found preexisting ~/.environments directory"
    echoInfo "Skipping creation of environments directory"
  else
    echoInfo "Creating environments directory"
    mkdir "$PS_ENV_HOME"
  fi

}

createSymlinks
copySparkyRC
createEnvironmentsDirectory
