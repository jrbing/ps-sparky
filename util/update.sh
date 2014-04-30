#!/usr/bin/env bash
# Update script for ps-sparky

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

#############################
# Pull down files from github
#############################
printf "[INFO] Updating ps-sparky\n"
cd ~ && \
/usr/bin/env rm -rf /tmp/ps-sparky* && \
/usr/bin/env curl --cacert /tmp/curl-ca-bundle-new.crt -SL https://github.com/ps-admin/ps-sparky/tarball/master -o /tmp/ps-sparky.tar.gz && \
/usr/bin/env gunzip -vf /tmp/ps-sparky.tar.gz && \
/usr/bin/env tar -xvf /tmp/ps-sparky.tar && \
/usr/bin/env cp -rf ps-admin-ps-sparky-???????/* .ps-sparky/

########################
# Remove temporary files
########################
printf "[INFO] Cleaning up temporary files\n"
/usr/bin/env rm -rf ps-admin-ps-sparky-???????/
