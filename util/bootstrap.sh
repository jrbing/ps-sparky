#!/usr/bin/env bash
# Bootstrap script for ps-sparky

PS_ENV_HOME=$HOME/.environments
INSTALL_DIR=$HOME/.ps-sparky
LINKED_FILES=( "profile" "bash_profile" "bashrc" )

createSymlinks () {
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

copySparkyRC () {
  if [[ -f $HOME/.sparkyrc ]] || [[ -h $HOME/.sparkyrc ]]; then
    printf "[INFO] Found directory ~/.sparkyrc \n"
    printf "[INFO] Backing up to ~/.sparkyrc.old \n"
    cp $HOME/.sparkyrc $HOME/.sparkyrc.old
    rm $HOME/.sparkyrc
  fi

  printf "[INFO] Copying sparkyrc \n"
  cp ${INSTALL_DIR}/sparkyrc $HOME/.sparkyrc
}

createEnvironmentsDirectory () {
  if [[ -d $HOME/.environments ]] || [[ -h $HOME/.environments ]]; then
    printf "[INFO] Found ~/.environments folder \n"
    printf "[INFO] Backing up to ~/.environments-old \n"
    cp $HOME/.environments $HOME/.environments-old
    rm -rf $HOME/.environments;
  fi

  printf "[INFO] Creating environments folder \n"
  mkdir $PS_ENV_HOME
}

createSymlinks
copySparkyRC
createEnvironmentsDirectory

