#!/usr/bin/env bash
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8
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
  printf "\e[00;31m[SPARKY]: \e[00m$1\n" >&2
}

updateSparky () {
  set -e
  log "Updating Sparky"

  # Fix for invalid certificates
  # Remove the temporary curl cert bundle if it exists
  if [[ -f /tmp/curl-ca-bundle-new.crt  ]]; then
    log "Removing old temporary certificate file"
    rm -v /tmp/curl-ca-bundle-new.crt
  fi

  log "Downloading temporary root certificate from DigiCert"
  /usr/bin/env curl -sSfL https://www.digicert.com/testroot/DigiCertHighAssuranceEVRootCA.crt >> /tmp/curl-ca-bundle-new.crt
  /usr/bin/env curl -sSfL https://www.digicert.com/CACerts/DigiCertHighAssuranceEVCA-1.crt >> /tmp/curl-ca-bundle-new.crt

  # Pull down files from github
  #cd "$HOME" && \
  if [[ -f /tmp/ps-sparky.tar.gz  ]] || [[ -f /tmp/ps-sparky.tar  ]]; then
    log "Removing temporary file from prior update"
    /usr/bin/env rm -rfv /tmp/ps-sparky.*
  fi

  log "Downloading newest version from GitHub"
  /usr/bin/env curl --cacert /tmp/curl-ca-bundle-new.crt -SL https://github.com/jrbing/ps-sparky/tarball/master -o /tmp/ps-sparky.tar.gz

  log "Extracting downloaded archive"
  (cd /tmp && /usr/bin/env gunzip -f /tmp/ps-sparky.tar.gz)
  (cd /tmp && /usr/bin/env tar -xf /tmp/ps-sparky.tar)

  log "Copying new version to destination"
  /usr/bin/env cp -rf /tmp/jrbing-ps-sparky-???????/* "$HOME/.ps-sparky/"

  log "Removing temporary files"
  /usr/bin/env rm -rf /tmp/ps-admin-ps-sparky-???????/

  log "Update complete"
}
