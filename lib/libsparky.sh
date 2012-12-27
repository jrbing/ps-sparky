#!/usr/bin/env bash
# Library file for sparky script

####################
# Help Documentation
####################

# Prints the help documentation
printHelp () {
cat <<- EOF

  # SPARKY #

  Description:
    sparky is a utility script that acts as a cli front end for configuration
    executables and files

  Commands:
    help        Displays the help menu

EOF
}

# Prints the help documentation for the "status" command
printUpdateHelp () {
cat <<- EOF

  Usage:
  sparky status [ app web prcs agent all ]

  Description:
  Shows the status of the server process specified in the argument

EOF
}

