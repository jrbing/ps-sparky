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
    pscfg is a utility script that acts as a cli front end for configuration
    executables and files

  Commands:
    help        Displays the help menu

EOF
}

# Prints the help documentation for the "status" command
printEditHelp () {
cat <<- EOF

  Usage:
  psadm status [ app web prcs agent all ]

  Description:
  Shows the status of the server process specified in the argument

EOF
}

