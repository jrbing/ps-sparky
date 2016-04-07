#!/usr/bin/env bash
# Install script for ps-sparky

##############################
# Fix for invalid certificates
##############################
# Remove the temporary curl cert bundle if it exists
if [[ -f /tmp/curl-ca-bundle-new.crt  ]]; then
  rm /tmp/curl-ca-bundle-new.crt
fi

# Download the appropriate root certificates from Digicert
/usr/bin/env curl -sSfL https://www.digicert.com/testroot/DigiCertHighAssuranceEVRootCA.crt >> /tmp/curl-ca-bundle-new.crt
/usr/bin/env curl -sSfL https://www.digicert.com/CACerts/DigiCertHighAssuranceEVCA-1.crt >> /tmp/curl-ca-bundle-new.crt

################
# Install Sparky
################

printf "[INFO] Downloading ps-sparky from github\n"
cd ~ && \
mkdir ~/.ps-sparky && \
/usr/bin/env rm -rf /tmp/ps-sparky* && \
/usr/bin/env curl --cacert /tmp/curl-ca-bundle-new.crt -SL https://github.com/jrbing/ps-sparky/tarball/master -o /tmp/ps-sparky.tar.gz && \
/usr/bin/env gunzip -vf /tmp/ps-sparky.tar.gz && \
/usr/bin/env tar -xvf /tmp/ps-sparky.tar && \
/usr/bin/env cp -rf jrbing-ps-sparky-???????/* .ps-sparky/

printf "[INFO] Cleaning up temporary files\n"
cd ~
rm -rf jrbing-ps-sparky-???????/

printf "[INFO] Running installation bootstrap script\n"
./.ps-sparky/util/bootstrap.sh
