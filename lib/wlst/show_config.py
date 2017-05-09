#!/usr/bin/env python
# vim: filetype=python tabstop=8 expandtab shiftwidth=4 softtabstop=4
# -*- coding: utf-8 -*-

import sys
import imp
import os
scriptpath = os.path.dirname(sys.argv[0])
pswls = imp.load_source('pswls', scriptpath + '/lib/pswls.py')

def get_running_server_names():
     domainConfig()
     return cmo.getServers()


def get_jvm_heap_size():
    serverNames = get_running_server_names()
    domainRuntime()

    print '             TotalJVM  FreeJVM   UsedJVM'
    pswls.print_double_hl()
    for name in serverNames:
        cd("/ServerRuntimes/"+name.getName()+"/JVMRuntime/"+name.getName())
        freejvm = int(get('HeapFreeCurrent'))/(1024*1024)
        totaljvm = int(get('HeapSizeCurrent'))/(1024*1024)
        usedjvm = (totaljvm - freejvm)
        print '%11s  %4d MB   %4d MB   %4d MB ' %  (name.getName(),totaljvm, freejvm, usedjvm)

def get_health_status():
    cd('/')
    server_health_state = cmo.getHealthState()
    server_status = cmo.getState()
    pswls.print_double_hl()
    print 'Server Health: %s' % (server_health_state)
    print 'Server Status: ', server_status
    pswls.print_double_hl()
    print ''
    pass

def main():
    # Get the file variables from the arguments passed to the script
    config_file = sys.argv[1]
    key_file = sys.argv[2]
    connection_url = sys.argv[3]

    connect(userConfigFile=config_file,
            userKeyFile=key_file,
            url=connection_url)

    # Change to the correct Mbean
    # serverRuntime()
    # cd('ApplicationRuntimes/peoplesoft/ComponentRuntimes/PIA_')
    get_jvm_heap_size()

    exit()
    stopRedirect()


main()
