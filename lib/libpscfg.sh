#!/usr/bin/env bash
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8:
#===============================================================================
#
#          FILE: libpsadm.sh
#
#   DESCRIPTION: Library file for pscfg script
#
#===============================================================================

# shellcheck disable=SC2034
SPLIBDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# shellcheck source=/dev/null
source "$SPLIBDIR"/libutil.sh

# Help Documentation {{{1

# Prints the help documentation
printHelp () {
printHelpBanner "PSCFG"
cat <<- EOF

  Description:
    pscfg is a utility script for managing Sparky configuration files

  Commands:
    list        List environment configuration files
    create      Create environment configuration file
    edit        Edit specified environment configuration file
    delete      Delete specified environment configuration file
    copy        Copies the specified environment configuration file
    help        Displays the help menu

EOF
}

# TODO: implement the show command
# Prints the help documentation for the "show" command
printShowHelp () {
cat <<- EOF

  Usage:
    pscfg show <environment>

  Description:
    Returns environment information for the argument specified

EOF
}

# Prints the help documentation for the "create" command
printCreateHelp () {
cat <<- EOF

  Usage:
    pscfg create <environment>

  Description:
    Creates a new environment configuration file based on the sample file and
    opens it in the default editor

EOF
}

# Prints the help documentation for the "edit" command
printEditHelp () {
cat <<- EOF

  Usage:
    pscfg edit <environment>

  Description:
    Opens the specified configuration file in the default editor

EOF
}

# Prints the help documentation for the "delete" command
printDeleteHelp () {
cat <<- EOF

  Usage:
    pscfg delete <environment>

  Description:
    Deletes the specified configuration file

EOF
}

# Prints the help documentation for the "copy" command
printCopyHelp () {
cat <<- EOF

  Usage:
    pscfg copy <source> <target>

  Description:
    Copies the specified environment file and opens the new file
    in the default editor

EOF
}

# }}}

# Utility {{{1

containsEnvironment () {
  local n=$#
  local value=${!n}
  for ((i=1; i < $#; i++)) {
    if [[ "${!i}" == "${value}" ]]; then
      echo "y"
      return 0
    fi
  }
  echo "n"
  return 1
}

loadEnvironmentList () {
  echoDebug "Loading list of environments"
  ENV_FILES=( $(ls "$PS_ENV_HOME" | sed -e 's/\.[a-zA-Z]*$//') )
  echoDebug "Environments found: ${ENV_FILES[*]}"
}

checkForEnvironmentDir () {
  if [[ -d $PS_ENV_HOME ]]; then
    loadEnvironmentList
  else
    mkdir "$PS_ENV_HOME" && cp "$SPHOME"/examples/sample.psenv "$PS_ENV_HOME"/
    echoInfo "The $PS_ENV_HOME directory has been created and a sample file has been copied.  Please use the sample file provided to configure you environment settings"
    exit 1
  fi
}

# }}}


# List {{{1

listEnvironments () {
  printBanner "Environments"
  echo
  local counter=1
  for i in "${ENV_FILES[@]}"; do
    printf "$counter) $i\n"
    counter=$(expr $counter + 1)
  done
  printf "\n"
}

# }}}

# Create {{{1

createEnvironment () {
  echoInfo "Creating environment file"
  if [[ $(containsEnvironment "${ENV_FILES[@]}" $1) != "y" ]]; then
      cp $BASEDIR/../sample.psenv $PS_ENV_HOME/$1.psenv
      $EDITOR $PS_ENV_HOME/$1.psenv
      exit
    else
      echoError "Environment file for ${1} already exists"
  fi
}

# }}}

# Edit {{{1

editEnvironment () {
  echoInfo "Editing environment file"
  if [[ $(containsEnvironment "${ENV_FILES[@]}" $1) == "y" ]]; then
      $EDITOR $PS_ENV_HOME/$1.psenv
    else
      echoError "Environment file for ${1} not found"
  fi
}
# }}}

# Delete {{{1

deleteEnvironment () {
  echoInfo "Deleting environment file"
  if [[ $(containsEnvironment "${ENV_FILES[@]}" $1) == "y" ]]; then
      read -p "Are you sure you want to delete the environment file: ${1}? " -n 1
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        printf "\n"
        exit 1
      fi
      printf "\n"
      rm -v $PS_ENV_HOME/$1.psenv
    else
      echoError "Environment file for ${1} not found"
  fi
}

# }}}

# Copy {{{1

copyEnvironment () {
  #TODO:  test to make sure $1 and $2 are specified
  echoInfo "Copying environment file"
  if [[ $(containsEnvironment "${ENV_FILES[@]}" $1) == "y" ]]; then
      cp $PS_ENV_HOME/$1.psenv $PS_ENV_HOME/$2.psenv
      $EDITOR $PS_ENV_HOME/$2.psenv
      exit
    else
      echoError "Environment file for ${1} not found"
  fi
}

# }}}
