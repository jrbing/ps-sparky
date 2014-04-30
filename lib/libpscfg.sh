#!/usr/bin/env bash
# Library file for pscfg script

####################
# Help Documentation
####################

# Prints the help documentation
printHelp () {
cat <<- EOF

  # PSCFG #

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

# Prints the help documentation for the "show" command
printShowHelp () {
cat <<- EOF

  Usage:
  pscfg show [ vars ]

  Description:
  Returns environment information for the argument specified

EOF
}

# Prints the help documentation for the "create" command
printCreateHelp () {
cat <<- EOF

  Usage:
  pscfg create "environment"

  Description:
  Creates a new environment configuration file based on the sample file and
  opens it in the default editor

EOF
}

# Prints the help documentation for the "edit" command
printEditHelp () {
cat <<- EOF

  Usage:
  pscfg edit "environment"

  Description:
  Opens the specified configuration file in the default editor

EOF
}

# Prints the help documentation for the "delete" command
printDeleteHelp () {
cat <<- EOF

  Usage:
  pscfg delete "environment"

  Description:
  Deletes the specified configuration file

EOF
}

# Prints the help documentation for the "copy" command
printCopyHelp () {
cat <<- EOF

  Usage:
  pscfg copy "source" "target"

  Description:
  Copies the specified environment file and opens the new file 
  in the default editor

EOF
}

#########
# Utility
#########

log () {
  printf "\e[00;31m[PSCFG]: $1\e[00m\n" >&2
}

############
# Validation
############

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
  ENV_FILES=( `ls $PS_ENV_HOME | sed -e 's/\.[a-zA-Z]*$//'` )
  if [[ $VERBOSE ]]; then log "Environments found: ${ENV_FILES[@]}"; fi
}

checkForEnvironmentDir () {
  if [[ -d $PS_ENV_HOME ]]; then
    if [[ $VERBOSE ]]; then log "Loading environments"; fi
    loadEnvironmentList
  else
    mkdir $PS_ENV_HOME && cp $SPHOME/sample.psenv $PS_ENV_HOME/
    log "The $PS_ENV_HOME directory has been created and a sample file has been copied.  Please use the sample file provided to configure you environment settings"
    exit 1
  fi
}

######
# List
######

listEnvironments () {
  #TODO: clean this up so that it displays properly
  printf "\e[00;31m### Environments ###\e[00m\n" >&2
  local counter=1
  for i in "${ENV_FILES[@]}"; do
    printf "$counter) $i\n"
    counter=`expr $counter + 1`
  done
  printf "\n"
}

########
# Create
########

createEnvironment () {
  log "Creating environment file"
  if [[ $(containsEnvironment "${ENV_FILES[@]}" $1) != "y" ]]; then
      cp $BASEDIR/../sample.psenv $PS_ENV_HOME/$1.psenv
      $EDITOR $PS_ENV_HOME/$1.psenv
      #TODO:  prompt to see if the environment file should be sourced
      exit
    else
      log "Environment file for ${1} already exists"
  fi
}

######
# Edit
######

editEnvironment () {
  log "Editing environment file"
  if [[ $(containsEnvironment "${ENV_FILES[@]}" $1) == "y" ]]; then
      $EDITOR $PS_ENV_HOME/$1.psenv
      #TODO:  prompt to see if the environment file should be sourced
    else
      log "Environment file for ${1} not found"
  fi
}

########
# Delete
########

deleteEnvironment () {
  log "Deleting environment file"
  if [[ $(containsEnvironment "${ENV_FILES[@]}" $1) == "y" ]]; then
      read -p "Are you sure you want to delete the environment file: ${1}? " -n 1
      if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        printf "\n"
        exit 1
      fi
      printf "\n"
      rm -v $PS_ENV_HOME/$1.psenv
    else
      log "Environment file for ${1} not found"
  fi
}

######
# Copy
######

copyEnvironment () {
  #TODO:  test to make sure $1 and $2 are specified
  log "Copying environment file"
  if [[ $(containsEnvironment "${ENV_FILES[@]}" $1) == "y" ]]; then
      cp $PS_ENV_HOME/$1.psenv $PS_ENV_HOME/$2.psenv
      $EDITOR $PS_ENV_HOME/$2.psenv
      #TODO:  prompt to see if the environment file should be sourced
      exit
    else
      log "Environment file for ${1} not found"
  fi
}

########
# Toggle
########

######
# Show
######

# Displays PeopleSoft-specific environment variables
showPsftVars () {
  #TODO:  fix this abomination
  for i in $ENV_VARS; do
    printf $i is set to `printenv $i`
  done
}

########
# Doctor
########

validatePSHOME () {
  log "Validating PS_HOME"
  if [[ $PS_HOME ]] && [[ -d $PS_HOME ]]; then
    # Check to see if:
    #  - peopletools.properties is setup
    echo "Validate PSHOME setup"
  else
    # something
    echo "No PSHOME setup"
  fi
}

validatePSCFGHOME () {
  echo "Validate PSCFGHOME setup"
  # Check to see if:
  #  - the directory structure appears correct
}

validatePSAPPHOME () {
  echo "Validate PSAPPHOME setup"
  # Check to see if:
  #  - the directory structure appears correct
}

validatePSPIAHOME () {
  echo "Validate PSPIAHOME setup"
  # Check to see if:
  #  - a webserver directory is set
}

validatePSCUSTHOME () {
  echo "Validate PSCUSTHOME setup"
  # Check to see if:
  #  - dunnno
}

validateTUXDIR () {
  echo "Validate TUXDIR setup"
  # Check to see if:
  #  - dunnno
}

validateJAVAHOME () {
  echo "Validate PSPIAHOME setup"
  # Check to see if the java executable exists
}

validateCOBDIR () {
  echo "Validate COBDIR setup"
  # Check to see if:
  #  - COBOL binaries exist
}

validatePSAPPDOMAIN () {
  echo "Validate PSAPPDOMAIN setup"
  # Check to see if the domain folder exists
}

validatePSPRCSDOMAIN () {
  echo "Validate PSAPPDOMAIN setup"
  # Check to see if the domain folder exists
}

validatePSPIADOMAIN () {
  echo "Validate PSPIADOMAIN setup"
  # Check to see if the domain folder exists
}

validateORACLEHOME () {
  echo "Validate ORACLE_HOME setup"
  # Check to see if sqlplus is found
}

validateORACLEBASE () {
  echo "Validate ORACLE_BASE setup"
  # Check to see if...
}

validateAGENTHOME () {
  echo "Validate AGENT_HOME setup"
}

runCheckup () {
  echo "Running Checkup"
}
