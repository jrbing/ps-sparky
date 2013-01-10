#!/usr/bin/env bash
# ps-sparky bash preferences file
# --DO NOT MODIFY--
# This file is overwritten whenever an update is applied
# Please make changes to the ~/.sparkyrc file instead

###############
# Initial Setup
###############
export PS1='\e[0;34m[${PS_ENV:-"NOENV"} | \u@\h \W]\$ \e[m' # Set the prompt
export SPHOME="$HOME/.ps-sparky"                            # Set the SPHOME
export PATH=$SPHOME/bin:$PATH
export PS_ENV_HOME=$HOME/.environments

#######
# Fixes
#######
export PMID=$(hostname) # Export the PMID in order to resolve an issue that Tuxedo has with long hostnames

#########
# Aliases
#########
alias psa='(cd $PS_HOME/appserv && ./psadmin)'   # Alias for the psadmin executable
alias psenv='source psenv'

##################
# Source .sparkyrc
##################
[[ -f $HOME/.sparkyrc ]] && source $HOME/.sparkyrc
