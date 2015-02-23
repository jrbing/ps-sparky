#!/usr/bin/env bash
#===============================================================================
# vim: softtabstop=4 shiftwidth=4 expandtab fenc=utf-8 spell spelllang=en
#===============================================================================
#
#          FILE: libsparky.sh
#
#   DESCRIPTION: Library file for sparky script
#
#===============================================================================

#####################
# Version Information
#####################

printSparkyVersion () {
  cat "$BASEDIR"/../VERSION
}

####################
# Help Documentation
####################

# Prints the help documentation
printHelp () {
cat <<- EOF

  # SPARKY #

  Description:
    The sparky script provides commands for displaying information about and
    managing your ps-sparky installation

  Commands:
    version     Displays the current version of Sparky
    update      Downloads and installs the most recent version of Sparky
    help        Displays the help menu

EOF
}

#########
# Utility
#########

log () {
  printf "\n\e[00;31m[SPARKY]: $1\e[00m\n" >&2
}

updateSparky () {
  log "Updating Sparky"

  # Fix for invalid certificates
  # Remove the temporary curl cert bundle if it exists
  if [[ -f /tmp/curl-ca-bundle-new.crt  ]]; then
    rm /tmp/curl-ca-bundle-new.crt
  fi

  # Download the appropriate root certificates from Digicert
  /usr/bin/env curl -sSfL https://www.digicert.com/testroot/DigiCertHighAssuranceEVRootCA.crt >> /tmp/curl-ca-bundle-new.crt
  /usr/bin/env curl -sSfL https://www.digicert.com/CACerts/DigiCertHighAssuranceEVCA-1.crt >> /tmp/curl-ca-bundle-new.crt

  # Pull down files from github
  log "Downloading newest version from Github"
  cd $HOME && \
  /usr/bin/env rm -rf /tmp/ps-sparky* && \
  /usr/bin/env curl --cacert /tmp/curl-ca-bundle-new.crt -SL https://github.com/jrbing/ps-sparky/tarball/master -o /tmp/ps-sparky.tar.gz && \
  /usr/bin/env gunzip -vf /tmp/ps-sparky.tar.gz && \
  /usr/bin/env tar -xvf /tmp/ps-sparky.tar && \
  /usr/bin/env cp -rf jrbing-ps-sparky-???????/* .ps-sparky/

  # Remove temporary files
  log "Cleaning up"
  /usr/bin/env rm -rf ps-admin-ps-sparky-???????/
}
