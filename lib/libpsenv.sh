#!/usr/bin/env bash
# Library file for psenv

####################
# Help Documentation
####################

print_help () {
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

###########
# Utilities
###########

log () {
  if [[ $VERBOSE ]]; then
    printf "[PSENV]: $1\n" >&2
  fi
}

create_default_symlink () {
  if [[ $DEFAULT ]]; then
    printf "[PSENV]: Setting default environment settings to $1 \n" >&2
    ln -fs $PS_ENV_HOME/$1.psenv $PS_ENV_HOME/default.psenv
  fi
}

############
# Validation
############

contains_environment () {
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

load_environment_list () {
  ENV_FILES=( `ls $PS_ENV_HOME | sed -e 's/\.[a-zA-Z]*$//'` )
  log "Environments found: ${ENV_FILES[@]}"
}

check_for_environment_dir () {
  if [ -d $PS_ENV_HOME ]; then
    log "Loading environments"
    load_environment_list
  else
    mkdir $PS_ENV_HOME && cp $SPHOME/sample.psenv $PS_ENV_HOME/
    log "The $PS_ENV_HOME directory has been created and a sample file has been copied.  Please use the sample file provided to configure you environment settings"
    exit 1
  fi
}

#############################
# Reset environment variables
#############################

environment_reset () {
  log "Resetting environment variables"
  unset IS_PS_PLT
  unset PATH
  unset LD_LIBRARY_PATH
}

restore_library_path () {
  log "Restoring LD_LIBRARY_PATH"
  export LD_LIBRARY_PATH=$ORIGINAL_LD_LIBRARY_PATH
}

restore_path () {
  log "Restoring PATH"
  export PATH=$ORIGINAL_PATH
}

##############################
# Update environment variables
##############################

source_env_file () {
  log "Sourcing the environment file"
  source $PS_ENV_HOME/$1.psenv
}

source_psconfig () {
  log "Sourcing the psconfig.sh file"
  [[ $CYGWIN ]] || source $PS_HOME/psconfig.sh # Source psconfig.sh
}

set_library_path () {
  log "Updating LD_LIBRARY_PATH"
  export LD_LIBRARY_PATH=$TUXDIR/lib:$LD_LIBRARY_PATH
  [[ $JAVA_HOME ]] && export LD_LIBRARY_PATH=$JAVA_HOME/lib:$LD_LIBRARY_PATH
  [[ $COBDIR ]] && export LD_LIBRARY_PATH=$COBDIR/lib:$LD_LIBRARY_PATH
  [[ $ORACLE_HOME ]] && export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
}

set_path () {
  log "Updating PATH"
  export PATH=$PATH:.
  export PATH=$TUXDIR/bin:$PATH
  [[ $COBDIR ]] && export PATH=$COBDIR/bin:$PATH
  [[ $ORACLE_HOME ]] && export PATH=$ORACLE_HOME/bin:$PATH
  [[ $AGENT_HOME ]] && export PATH=$AGENT_HOME/bin:$PATH
}
