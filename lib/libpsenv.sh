#!/usr/bin/env bash
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8:
#===============================================================================
#
#          FILE: libpsadm.sh
#
#   DESCRIPTION: Library file for psenv script
#
#===============================================================================

SPLIBDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# shellcheck source=/dev/null
source "$SPLIBDIR"/libutil.sh

# TODO: change function names to be consistent with the rest of the helper
# scripts

# Help Documentation {{{1

function print_help () {
printHelpBanner "PSENV"
cat <<- EOF

  Description:
    psenv is a utility script used for sourcing Sparky
    configuration files

  Usage:
    psenv <environment settings>

    ex: "psenv hrdmo"

  Note:
    Use "pscfg list" to display a list of available environment
    settings

EOF
}

# }}}

# Utilities {{{1

function create_default_symlink () {
  if [[ $DEFAULT ]]; then
    echoInfo "Setting default environment settings to $1"
    local environment_default=$1
    ln -fs "$PS_ENV_HOME"/"$environment_default".psenv "$PS_ENV_HOME"/default.psenv
  fi
}

# }}}

# Validation {{{1

function contains_environment () {
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

function load_environment_list () {
  #ENV_FILES=( $(find "$PS_ENV_HOME" -maxdepth 1 '*.psenv' | sed -e 's/\.[a-zA-Z]*$//') )
  ENV_FILES=( $(ls "$PS_ENV_HOME" | sed -e 's/\.[a-zA-Z]*$//') )
  echoDebug "Environments found: ${ENV_FILES[*]}"
}

function check_for_environment_dir () {
  if [[ -d $PS_ENV_HOME ]]; then
    echoDebug "Loading environments"
    load_environment_list
  else
    mkdir "$PS_ENV_HOME" && cp "$SPHOME"/sample.psenv "$PS_ENV_HOME"/
    echoDebug "The $PS_ENV_HOME directory has been created and a sample file has been copied.  Please use the sample file provided to configure you environment settings"
    exit 1
  fi
}

# }}}

# Environment Variable Reset {{{1

function environment_reset () {
  echoDebug "Resetting environment variables"
  unset IS_PS_PLT
  unset PATH
  unset LD_LIBRARY_PATH
}

function restore_library_path () {
  echoDebug "Restoring LD_LIBRARY_PATH"
  export LD_LIBRARY_PATH=$ORIGINAL_LD_LIBRARY_PATH
}

function restore_path () {
  echoDebug "Restoring PATH"
  export PATH=$ORIGINAL_PATH
}

# }}}

# Environment Variable Updates {{{1

function source_env_file () {
  echoDebug "Sourcing the environment file"
  # shellcheck disable=1090
  source "$PS_ENV_HOME"/"$1".psenv
}

function source_psconfig () {
  if [[ -z "$CYGWIN" ]]; then
    echoDebug "Sourcing the psconfig.sh file"
    # shellcheck disable=1090,2164
    cd "$PS_HOME" && source "$PS_HOME"/psconfig.sh && cd - > /dev/null 2>&1
  fi
}

function set_library_path () {
  echoDebug "Updating LD_LIBRARY_PATH"
  export LD_LIBRARY_PATH=$TUXDIR/lib:$LD_LIBRARY_PATH
  [[ $JAVA_HOME ]] && export LD_LIBRARY_PATH=$JAVA_HOME/lib:$LD_LIBRARY_PATH
  [[ $COBDIR ]] && export LD_LIBRARY_PATH=$COBDIR/lib:$LD_LIBRARY_PATH
  [[ $ORACLE_HOME ]] && export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
}

function set_path () {
  echoDebug "Updating PATH"
  export PATH=$PATH:.
  export PATH=$TUXDIR/bin:$PATH
  [[ $COBDIR ]] && export PATH=$COBDIR/bin:$PATH
  [[ $ORACLE_HOME ]] && export PATH=$ORACLE_HOME/bin:$PATH
  [[ $AGENT_HOME ]] && export PATH=$AGENT_HOME/bin:$PATH
}

# }}}
