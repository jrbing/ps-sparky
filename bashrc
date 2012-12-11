#!/usr/bin/env bash
# ps-sparky bash preferences file
# --DO NOT MODIFY--
# This file is overwritten whenever an update is applied
# Please update the ~/.localrc file instead

###############
# Initial Setup
###############
export PS1='\e[0;34m[${PS_ENV:-"NOENV"} | \u@\h \W]\$ \e[m' # Set the prompt
export SPHOME="$HOME/.ps-sparky"                            # Set the SPHOME
export PATH=$PATH:$SPHOME/bin

#######
# Fixes
#######
export PMID=$(hostname) # Export the PMID in order to resolve an issue that Tuxedo has with long hostnames

#########
# Aliases
#########
alias psa='(cd $PS_HOME/appserv && ./psadmin)'   # Alias for the psadmin executable
alias update-sparky='($HOME/.ps-sparky/util/update.sh)'   # Update sparky from github
alias psenv='source psenv'

######################
# OS Specific Settings
######################
case $(uname -s) in
  (Linux*)
    # TBD: Linux specific settings
  ;;
  (SunOS*)
    # TBD: Solaris specific settings
  ;;
  (CYGWIN*)
    # TBD: Cygwin specific settings
  ;;
esac

#################
# Source .localrc
#################
if [ -f ~/.localrc ]; then
  . ~/.localrc
else
  printf ".localrc file not found in home directory\n"
fi
