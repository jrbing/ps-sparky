#!/usr/bin/env bash
# ps-sparky bash preferences file
# --DO NOT MODIFY--
# This file is overwritten whenever an update is applied
# Please make changes to the ~/.sparkyrc file instead

###############
# Initial Setup
###############
#TODO: determine whether or not to use utf-8 characters in the prompt
#export PS1=$'\e[0;34m[${PS_ENV:-"NOENV"} \xe2\x8c\xb8  \u@\h \W]\$ \e[m'
export PS1=$'\\[\e[0;34m[${PS_ENV:-"NOENV"} \xe2\x9d\xaf \u@\h \W]\$ \e[m\\]'
export SPHOME="$HOME/.ps-sparky"
export PATH=$SPHOME/bin:$PATH
export PS_ENV_HOME=$HOME/.environments

#######
# Fixes
#######

# Export the PMID in order to resolve an issue that Tuxedo has with long hostnames
PMID=$(hostname)
export PMID

#########
# Aliases
#########
alias psa='(cd $PS_HOME/appserv && ./psadmin)'   # Alias for the psadmin executable
alias psenv='source psenv'
alias pscipher='$PS_PIA_HOME/webserv/$PS_PIA_DOMAIN/piabin/PSCipher.sh'

##################
# Source .sparkyrc
##################
[[ -f $HOME/.sparkyrc ]] && source $HOME/.sparkyrc

#########################################
# Source the default environment settings
#########################################
[[ -f $HOME/.environments/default.psenv ]] && psenv default
