#!/usr/bin/env bash
# Bootstrap script for ps-sparky

PS_ENV_HOME=$HOME/.environments
INSTALL_DIR=$HOME/.ps-sparky
LINKED_FILES=( "profile" "bash_profile" "bashrc" )

createSymlinks () {
  for i in ${LINKED_FILES[@]}
  do
    if [[ -f ~/.${i} ]] || [[ -h ~/.${i} ]]; then
      echo "Found ~/.${i}... Backing up to ~/.${i}.old";
      cp $HOME/.${i} $HOME/.${i}.old;
      rm $HOME/.${i};
    fi

    echo "Creating alias for ${i}"
    ln -s ${INSTALL_DIR}/${i} $HOME/.${i}
  done
}

copySparkyRC () {
  if [[ -f $HOME/.sparkyrc ]] || [[ -h $HOME/.sparkyrc ]]; then
    echo "Found directory ~/.sparkyrc" 
    echo "Backing up to ~/.sparkyrc.old";
    cp $HOME/.sparkyrc $HOME/.sparkyrc.old;
    rm $HOME/.sparkyrc;
  fi

  echo "Copying sparkyrc"
  cp ${INSTALL_DIR}/sparky $HOME/.sparkyrc
}

createEnvironmentsDirectory () {
  if [[ -d $HOME/.environments ]] || [[ -h $HOME/.environments ]]; then
    echo "Found ~/.environments folder"
    echo "Backing up to ~/.environments-old";
    cp $HOME/.environments $HOME/.environments-old;
    rm -rf $HOME/.environments;
  fi

  echo "Creating environments folder"
  mkdir $PS_ENV_HOME
  #cp ${INSTALL_DIR}/sample.psenv $PS_ENV_HOME/
}

createSymlinks
copySparkyRC
createEnvironmentsDirectory

