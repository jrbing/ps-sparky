ps-sparky
=========

Sparky is a collection of tools to help bootstrap and manage a PeopleSoft Web, App, or Process Scheduler server running on Unix or Linux. In a nutshell, it serves two main functions:

* Environment Management
* Administration Scripts

Features
--------
Here’s a quick overview of what’s included:

* Updated shell prompt for displaying information about the current environment
* Aliases to common PeopleTools executables
* Helper scripts:
    * psenv → Script to toggle PeopleSoft environment variables
    * psadm → Wrapper for the psadmin and various other scripts in the PeopleSoft home.
* Automated updates

### Environment Management

TODO: brief overview of how environment management works

### Helper scripts

TODO: brief overview of helper scripts

Installation
------------

Before you get started, make sure your system has the following:

* Unix or Linux environment → Sparky is currently developed and tested under RHEL 6, but should work under other unix-like environments
* bash → the default shell for the PeopleSoft service account user should be set to bash
* curl → necessary for automated installation and updates
* PeopleTools 8.52 or above → earlier versions may work, but are untested

### Automated Installation

The quickest way to install Sparky is to login to your server as the PeopleSoft installation account user (ex: psoft) and run the following from the terminal.

    curl -kL http://git.io/7dpE1g | bash

The script will attempt to…

* Download the necessary Sparky scripts into the ~/.ps-sparky directory
* Backup any existing .profile, .bash_profile, and .bashrc files
* Create symlinks to the profile, bash_profile, and bashrc files in ~/.ps-sparky
* Copy the sample localrc file to ~/.localrc
* Create an environments folder in the HOME directory and add a sample environment configuration file

### Manual Installation

In case you don’t have direct access to the internet from your systems (or have security concerns), Sparky can be installed manually. 

```bash
# Download tar.gz archive
curl ???

# Unzip & extract the tar file
* tar -xvf ??? && rename .ps-sparky

# execute the bootstrap script provided with Sparky to backup your current .profile, .bash_profile, and .bashrc files and create symlinks to the ones in the .ps-sparky directory.
~/.ps-sparky/util/bootstrap.sh
```

Configuration
-------------

Rename/edit the sample.psenv file:


Usage
-----

TODO: psenv

TODO: psadm

Contributing
------------
If you'd like to contribute, simply fork the repository and create a
pull request.

License
-------
(The MIT License)

Copyright (c) 2015 JR Bing

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

