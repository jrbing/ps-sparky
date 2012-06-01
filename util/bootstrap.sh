#!/bin/env bash

INSTALL_DIR=$HOME/.ps-sparky
LINKED_FILES=( "profile" "bash_profile" "bashrc" )

createSymlinks () {

  for i in ${LINKED_FILES[@]}
  do

    if [ -f ~/.${i} ] || [ -h ~/.${i} ]
      then
        echo "Found ~/.${i}... Backing up to ~/.${i}.old";
        cp ~/.${i} ~/.${i}.old;
        rm ~/.${i};
    fi

    echo "Creating alias for ${i}"
    ln -s ${INSTALL_DIR}/${i} ~/.${i}

  done
}

copyLocalrc () {

  if [ -f ~/.localrc ] || [ -h ~/.localrc ]
  then
    echo "Found ~/.localrc... Backing up to ~/.localrc.old";
    cp ~/.localrc ~/.localrc.old;
    rm ~/.localrc;
  fi

  echo "Copying localrc"
  cp ${INSTALL_DIR}/localrc ~/.localrc

}

createEnvironmentsDirectory () {

  if [ -d ~/environments ] || [ -h ~/environments ]
  then
    echo "Found ~/environments folder >>> Backing up to ~/environments-old";
    cp ~/environments ~/environments-old;
    rm -rf ~/environments;
  fi

  echo "Creating environments folder"
  mkdir $HOME/environments
  cp ${INSTALL_DIR}/sample.psenv ~/environments/

}

createSymlinks
copyLocalrc
createEnvironmentsDirectory

