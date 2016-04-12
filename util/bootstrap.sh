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

PS_ENV_HOME=$HOME/.environments
INSTALL_DIR=$HOME/.ps-sparky
LINKED_FILES=( "profile" "bash_profile" "bashrc" "vimrc" )

function echoinfo() {
  local GC="\033[1;32m"
  local EC="\033[0m"
  printf "${GC} ☆  INFO${EC}: %s\n" "$@";
}

function createSymlinks () {
  for i in ${LINKED_FILES[@]}
  do
    if [[ -f ~/.${i} ]] || [[ -h ~/.${i} ]]; then
      printf "[INFO] Found ~/.${i}... Backing up to ~/.${i}.old \n";
      cp $HOME/.${i} $HOME/.${i}.old;
      rm $HOME/.${i};
    fi

    printf "Creating alias for ${i} \n"
    ln -s ${INSTALL_DIR}/${i} $HOME/.${i}
  done
}

function copySparkyRC () {
  if [[ -f $HOME/.sparkyrc ]] || [[ -h $HOME/.sparkyrc ]]; then
    printf "[INFO] Found directory ~/.sparkyrc \n"
    printf "[INFO] Backing up to ~/.sparkyrc.old \n"
    cp $HOME/.sparkyrc $HOME/.sparkyrc.old
    rm $HOME/.sparkyrc
  fi

  printf "[INFO] Copying sparkyrc \n"
  cp ${INSTALL_DIR}/examples/sparkyrc $HOME/.sparkyrc
}

function createEnvironmentsDirectory () {
  if [[ -d $HOME/.environments ]] || [[ -h $HOME/.environments ]]; then
    echoInfo "Found ~/.environments folder \n"
    echoInfo "Backing up to ~/.environments-old \n"
    cp $HOME/.environments $HOME/.environments-old
    rm -rf $HOME/.environments;
  fi

  printf "[INFO] Creating environments folder \n"
  mkdir $PS_ENV_HOME
}

createSymlinks
copySparkyRC
createEnvironmentsDirectory
