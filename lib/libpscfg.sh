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
    pscfg is a utility script that acts as a cli front end for Sparky
    configuration files

  Commands:
    list        List environment configuration files
    show        Show environment information
    create      Create environment configuration file
    edit        Edit specified environment configuration file
    delete      Delete specified environment configuration file
    copy        Copies the specified environment configuration file
    toggle      Toggle specified environment setting
    help        Displays the help menu

EOF
}

# Prints the help documentation for the "edit" command
printEditHelp () {
cat <<- EOF

  Usage:
  pscfg edit [ app web prcs agent all ]

  Description:
  Opens the specified configuration file in the default editor

EOF
}

# Prints the help documentation for the "show" command
printShowHelp () {
cat <<- EOF

  Usage:
  psadm show [ vars ]

  Description:
  Returns environment information for the argument specified

EOF
}

#########
# Utility
#########

log () {
  printf "\n\e[00;31m[PSCFG]: $1\e[00m\n" >&2
}

######
# List
######

listEnvironments () {
  echo "Environment listings..."
}

######
# Show
######

# Displays PeopleSoft-specific environment variables
showPsftVars () {
  for i in $ENV_VARS; do
    printf $i is set to `printenv $i`
  done
}

########
# Create
########

createEnvironment () {
  echo "Creating environment file"
}

######
# Edit
######

editEnvironment () {
  echo "Editing environment file"
}


########
# Delete
########

deleteEnvironment () {
  echo "Deleting environment file"
}

######
# Copy
######

copyEnvironment () {
  echo "Copying environment file"
}

########
# Toggle
########

########
# Doctor
########
runHealthCheck () {
  echo "Running doctor..."
}
