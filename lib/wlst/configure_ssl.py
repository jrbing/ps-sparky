#!/usr/bin/env python
# vim: filetype=python tabstop=8 expandtab shiftwidth=4 softtabstop=4
# -*- coding: utf-8 -*-

import sys
import imp
import os
scriptpath = os.path.dirname(sys.argv[0])
pswls = imp.load_source('pswls', scriptpath + '/lib/pswls.py')

# Servers/PIA/SSL/PIA:
    # ServerPrivateKeyAlias:              psadminio-2016
    # ServerPrivateKeyPassPhrase:         Passw0rd

def get_running_server_names():
    domainConfig()
    return cmo.getServers()


def configure_ssl():
    serverNames = get_running_server_names()
    domainRuntime()
    for name in serverNames:
        try:
            cd("/Servers/"+name.getName()+"/WebServer/"+name.getName()+"/WebServerLog")
            cmo.setLogTimeInGMT(false)
            cmo.setLogFileFormat('extended')
            cmo.setELFFields('date time cs-method cs-uri sc-status cs(X-Forwarded-For)')
            activate()
            print ' '
        except java.lang.Exception, ex:
            print 'Failed to configure logging: ' + ex.toString()


def main():
    # Get the file variables from the arguments passed to the script
    config_file = sys.argv[1]
    key_file = sys.argv[2]
    connection_url = sys.argv[3]

    connect(userConfigFile=config_file,
            userKeyFile=key_file,
            url=connection_url)

    enable_extended_logging()

    exit()
    stopRedirect()


main()
