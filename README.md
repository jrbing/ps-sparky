PS-SPARKY
===========

_**CAUTION:** this is a work in process, and is not yet intended to be
used in a production environment_

About
-----
Sparky is a set of preferences and scripts that are intended to help
with the setup and management of PeopleSoft servers under Unix/Linux.

Features
--------

### Default Bash Preferences
Sparky comes with the following default settings:

- Custom prompt for displaying current environment
- Bash Aliases
    - **psa** → starts the psadmin program

### Scripts
Additionally, Sparky comes with a few helper scripts that are automatically added to the PATH.

- **psenv** → Script to toggle PeopleSoft environment variable settings.  This is extremely useful if you're working with multiple PeopleSoft environments on a single machine. 
- **psadm** → Wrapper script for the psadmin and various other scripts in the PeopleSoft home


Requirements
------------
To work properly, Sparky requires the following:

- Unix or Linux environment →  Sparky is currently developed and tested under Solaris 10 and RHEL 5
- bash →  The default shell for the PeopleSoft service account user needs to be set to bash
- curl →  Necessary for installing and updating


Installation
------------

First, login as the PeopleSoft installation account user (ex: psoft) and run the following from the terminal. 

    curl -kL http://git.io/install-ps-sparky | bash

The script will attempt to - 

- Download preference files and scripts into the ~/.ps-sparky directory
- Backup any existing .profile, .bash_profile, and .bashrc files
- Create symlinks to the profile, bash_profile, and bashrc files in ~/.ps-sparky
- Copy the sample localrc file to ~/.localrc
- Create the ~/environments folder and add a sample environment configuration file


<!--Usage-->
<!--------->


<!--Customization-->
<!----------------->



Contributing
------------
If you'd like to contribute, simply fork the repository and create a pull request.


License
-------
(The MIT License)

Copyright (c) 2012 JR Bing

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

