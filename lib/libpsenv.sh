#!/usr/bin/env bash
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8
#===============================================================================
#
#          FILE: libpsadm.sh
#
#   DESCRIPTION: Library file for psenv script
#
#===============================================================================

#TODO: convert this over to use camel case for functions

# Help Documentation {{{1

function print_help () {
# Prints the help documentation
cat <<- EOF

  # PSENV #

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

function log () {
  if [[ $DEBUG ]]; then
    printf "[PSENV]: $1\n" >&2
  fi
}

function create_default_symlink () {
  if [[ $DEFAULT ]]; then
    printf "[PSENV]: Setting default environment settings to $1 \n" >&2
    ln -fs $PS_ENV_HOME/$1.psenv $PS_ENV_HOME/default.psenv
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
  ENV_FILES=( `ls $PS_ENV_HOME | sed -e 's/\.[a-zA-Z]*$//'` )
  log "Environments found: ${ENV_FILES[@]}"
}

function check_for_environment_dir () {
  if [ -d $PS_ENV_HOME ]; then
    log "Loading environments"
    load_environment_list
  else
    mkdir $PS_ENV_HOME && cp $SPHOME/sample.psenv $PS_ENV_HOME/
    log "The $PS_ENV_HOME directory has been created and a sample file has been copied.  Please use the sample file provided to configure you environment settings"
    exit 1
  fi
}

# }}}

# Environment Variable Reset {{{1

function environment_reset () {
  log "Resetting environment variables"
  unset IS_PS_PLT
  unset PATH
  unset LD_LIBRARY_PATH
}

function restore_library_path () {
  log "Restoring LD_LIBRARY_PATH"
  export LD_LIBRARY_PATH=$ORIGINAL_LD_LIBRARY_PATH
}

function restore_path () {
  log "Restoring PATH"
  export PATH=$ORIGINAL_PATH
}

# }}}

# Environment Variable Updates {{{1

function source_env_file () {
  log "Sourcing the environment file"
  source "$PS_ENV_HOME"/"$1".psenv
}

function source_psconfig () {
  log "Sourcing the psconfig.sh file"
  [[ $CYGWIN ]] || cd "$PS_HOME" && source "$PS_HOME"/psconfig.sh && cd - > /dev/null 2>&1 # Source psconfig.sh
}

function set_library_path () {
  log "Updating LD_LIBRARY_PATH"
  export LD_LIBRARY_PATH=$TUXDIR/lib:$LD_LIBRARY_PATH
  [[ $JAVA_HOME ]] && export LD_LIBRARY_PATH=$JAVA_HOME/lib:$LD_LIBRARY_PATH
  [[ $COBDIR ]] && export LD_LIBRARY_PATH=$COBDIR/lib:$LD_LIBRARY_PATH
  [[ $ORACLE_HOME ]] && export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
}

function set_path () {
  log "Updating PATH"
  export PATH=$PATH:.
  export PATH=$TUXDIR/bin:$PATH
  [[ $COBDIR ]] && export PATH=$COBDIR/bin:$PATH
  [[ $ORACLE_HOME ]] && export PATH=$ORACLE_HOME/bin:$PATH
  [[ $AGENT_HOME ]] && export PATH=$AGENT_HOME/bin:$PATH
}

# }}}
