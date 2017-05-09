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
function printHelp () {
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
function printShowHelp () {
cat <<- EOF

  Usage:
    pscfg show <environment>

  Description:
    Returns environment information for the argument specified

EOF
}

# Prints the help documentation for the "create" command
function printCreateHelp () {
cat <<- EOF

  Usage:
    pscfg create <environment>

  Description:
    Creates a new environment configuration file based on the sample file and
    opens it in the default editor

EOF
}

# Prints the help documentation for the "edit" command
function printEditHelp () {
cat <<- EOF

  Usage:
    pscfg edit <environment>

  Description:
    Opens the specified configuration file in the default editor

EOF
}

# Prints the help documentation for the "delete" command
function printDeleteHelp () {
cat <<- EOF

  Usage:
    pscfg delete <environment>

  Description:
    Deletes the specified configuration file

EOF
}

# Prints the help documentation for the "copy" command
function printCopyHelp () {
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

function containsEnvironment () {
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

function loadEnvironmentList () {
  echoDebug "Loading list of environments"
  ENV_FILES=( $(find "$PS_ENV_HOME" -type f -name "*.psenv" -print0 | xargs -0 -n1 basename | sed -e 's/\.[a-zA-Z]*$//') )
  echoDebug "Environments found: ${ENV_FILES[*]}"
}

function checkForEnvironmentDir () {
  echoDebug "Checking for environments directory"
  if [[ -d $PS_ENV_HOME ]]; then
    echoDebug "Environment directory found"
    loadEnvironmentList
  else
    echoDebug "Environment directory missing"
    mkdir "$PS_ENV_HOME"
    echoInfo "The $PS_ENV_HOME directory has been created"
    exit 1
  fi
}

# }}}


# List {{{1

function listEnvironments () {
  # TODO: show an error message if no environments are found
  printBanner "Environments"
  echo
  local counter=1
  local envpath
  for environment in "${ENV_FILES[@]}"; do
    envpath="${PS_ENV_HOME}/${environment}.psenv"
    if [[ "$(readlink ${PS_ENV_HOME}/default.psenv)" = "$envpath" ]]; then
      printf "  %s) %s (default)\n" "$counter" "$environment"
    else
      printf "  %s) %s\n" "$counter" "$environment"
    fi
    counter=$((counter + 1))
  done
  printf "\n"
}

# }}}

# Create {{{1

function createEnvironment () {
  echoInfo "Creating environment file"
  echoDebug "Arguments to createEnvironment are: ${*}"
  local envname=$1
  if [[ $(containsEnvironment "${ENV_FILES[@]}" "$envname") != "y" ]]; then
      cp "$BASEDIR"/../examples/sample.psenv "$PS_ENV_HOME"/"$envname".psenv
      "$EDITOR" "$PS_ENV_HOME"/"$envname".psenv
      exit
    else
      echoError "Environment file for ${envname} already exists"
  fi
}

# }}}

# Edit {{{1

function editEnvironment () {
  echoInfo "Editing environment file"
  echoDebug "Arguments to editEnvironment are: ${*}"
  local envname=$1
  if [[ $(containsEnvironment "${ENV_FILES[@]}" "$envname") == "y" ]]; then
      "$EDITOR" "$PS_ENV_HOME/$envname.psenv"
    else
      echoError "Environment file for ${envname} not found"
  fi
}
# }}}

# Delete {{{1

function deleteEnvironment () {
  echoInfo "Deleting environment file"
  echoDebug "Arguments to deleteEnvironment are: ${*}"
  local envname=$1
  if [[ $(containsEnvironment "${ENV_FILES[@]}" "$envname") == "y" ]]; then
      read -p "Are you sure you want to delete the environment file: ${envname}? " -n 1
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        printf "\n"
        exit 1
      fi
      printf "\n"
      rm -v "$PS_ENV_HOME/${envname}.psenv"
    else
      echoError "Environment file for ${envname} not found"
  fi
}

# }}}

# Copy {{{1

function copyEnvironment () {
  #TODO:  test to make sure $1 and $2 are specified
  echoInfo "Copying environment file"
  echoDebug "Arguments to copyEnvironment are: ${*}"
  local sourceenv=$1
  local targetenv=$2
  if [[ $(containsEnvironment "${ENV_FILES[@]}" "$1") == "y" ]]; then
      cp "$PS_ENV_HOME/$1.psenv" "$PS_ENV_HOME/$2.psenv"
      "$EDITOR" "$PS_ENV_HOME/$2.psenv"
      exit
    else
      echoError "Environment file for ${1} not found"
  fi
}

# }}}
