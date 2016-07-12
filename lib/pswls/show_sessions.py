#!/usr/bin/env python
# vim: filetype=python tabstop=8 expandtab shiftwidth=4 softtabstop=4
# -*- coding: utf-8 -*-

import sys
import imp
import os
scriptpath = os.path.dirname(sys.argv[0])
pswls = imp.load_source('pswls', scriptpath + '/pswls.py')


def main():
    # Get the file variables from the arguments passed to the script
    config_file = sys.argv[1]
    key_file = sys.argv[2]
    connection_url = sys.argv[3]

    connect(userConfigFile=config_file,
            userKeyFile=key_file,
            url=connection_url)

    # pswls.connect_admin(config_file, key_file, connection_url)

    # Change to the correct Mbean
    serverRuntime()
    cd('ApplicationRuntimes/peoplesoft/ComponentRuntimes/PIA_')

    # Get current sessions
    sessions = cmo.getServletSessions()
    if not sessions:
        pswls.print_info('No sessions currently connected')
    else:
        pswls.print_hl()
        for session in sessions:
            name = session.getName()
            monitoring_id = cmo.getMonitoringId(name)
            print ' ', monitoring_id
        pswls.print_hl()

    exit()
    stopRedirect()


main()
