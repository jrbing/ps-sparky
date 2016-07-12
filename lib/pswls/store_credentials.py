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

    # Prompt for the username and password
    username = pswls.get_username()
    password = pswls.get_password()

    connect(userConfigFile=config_file,
            userKeyFile=key_file,
            url=connection_url)

    storeUserConfig(config_file, key_file)

main()
