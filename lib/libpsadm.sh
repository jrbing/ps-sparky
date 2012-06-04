#!/usr/bin/env bash
# Library file for psadm script

ENV_VARS=( HOME PS_HOME PS_CFG_HOME PS_APP_HOME TUXDIR )

####################
# Help Documentation
####################

# Prints the help documentation
printHelp () {
cat <<- EOF

  # PSADM #

  Description:
    psadm is a Utility script that acts as a wrapper for PeopleSoft
    executables and shell scripts

  Commands:
    start       Start a server process
    stop        Stop a server process
    status      Show the status of a server process
    bounce      Restart a server process
    show        Show environment information
    watch       Monitor the status of a server process
    help        Displays the help menu

EOF
}

# Prints the help documentation for the "status" command
printStatusHelp () {
cat <<- EOF

  Usage:
  psadm status [ app web prcs agent all ]

  Description:
  Shows the status of the server process specified in the argument

EOF
}

# Prints the help documentation for the "start" command
printStartHelp () {
cat <<- EOF

  Usage:
  psadm start [ app web prcs agent all ]

  Description:
  Starts the server process specified in the argument

EOF
}

# Prints the help documentation for the "stop" command
printStopHelp () {
cat <<- EOF

  Usage:
  psadm stop [ app web prcs agent all ]

  Description:
  Stops the server process specified in the argument

EOF
}

# Prints the help documentation for the "bounce" command
printBounceHelp () {
cat <<- EOF

  Usage:
  psadm bounce [ app web prcs agent hub all ]

  Description:
  Restarts the server process specified in the argument

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

# Prints the help documentation for the "watch" command
printWatchHelp () {
cat <<- EOF

  Usage:
  psadm watch [ app prcs ]

  Description:
  Shows server process information until canceled

EOF
}

# Prints the help documentation for the "watch" command
printWatchAppHelp () {
cat <<- EOF

  Usage:
  psadm watch app [ proc srvr client queue ]

  Description:
  Shows appserver status information until canceled

EOF
}

#################################
# Environment Variable Validation
#################################

# Displays PeopleSoft-specific environment variables
showPsftVars () {
  for i in $ENV_VARS; do
    printf $i is set to `printenv $i`
  done
}

# Check to see if the appropriate environment variables are set
checkPsftVars () {
  for i in $ENV_VARS; do
    if [[ `printenv ${i}` = '' ]]; then
      printf "${i} is not set.  Please make sure this is set before continuing.\n"
      exit 1
    fi
  done
}

###############
# Miscellaneous
###############

#spinner ()
#{
  #local pid=$1
  #local delay=0.75
  #local spinstr='|/-\'
  #while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
    #local temp=${spinstr#?}
    #printf " [%c]  " "$spinstr"
    #local spinstr=$temp${spinstr%"$temp"}
    #sleep $delay
    #printf "\b\b\b\b\b\b"
  #done
  #printf "    \b\b\b\b"
#}

#multiTail () {
  ## When this exits, exit all back ground process also.
  #trap 'kill $(jobs -p)' EXIT
  ## iterate through the each given file names,
  #for file in "$@"
  #do
    ## show tails of each in background.
    #tail -f $file &
  #done
  ## wait .. until CTRL+C
  #wait
#}
