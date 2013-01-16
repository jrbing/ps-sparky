#!/usr/bin/env bash
# Library file for psadm script

PSADMIN_PATH=$PS_HOME/appserv
BASEDIR=$(dirname $0)

####################
# Help Documentation
####################

# Prints the help documentation
printHelp () {
cat <<- EOF

  # PSADM #

  Description:
    psadm is a utility script that acts as a wrapper for PeopleSoft
    executables and shell scripts

  Commands:
    start       Start a server process
    stop        Stop a server process
    status      Show the status of a server process
    bounce      Restart a server process
    show        Show environment variable information
    purge       Delete cached files for a server process
    watch       Monitor the status of a server process
    tail        Tail the logfile of a server process
    compile     Run the pscbl.mak script to compile cobol
    link        Run the psrun.mak script to link cobol
    preload     Preload the appserver cache
    help        Displays the help menu

EOF
}

# Prints the help documentation for the "status" command
printStatusHelp () {
cat <<- EOF

  Usage:
  psadm status [ app web prcs agent all ]

  Description:
  Shows the status of the server process specified in the argument

EOF
}

# Prints the help documentation for the "start" command
printStartHelp () {
cat <<- EOF

  Usage:
  psadm start [ app web prcs agent all ]

  Description:
  Starts the server process specified in the argument

EOF
}

# Prints the help documentation for the "stop" command
printStopHelp () {
cat <<- EOF

  Usage:
  psadm stop [ app web prcs agent all ]

  Description:
  Stops the server process specified in the argument

EOF
}

# Prints the help documentation for the "bounce" command
printBounceHelp () {
cat <<- EOF

  Usage:
  psadm bounce [ app web prcs agent hub all ]

  Description:
  Restarts the server process specified in the argument

EOF
}

# Prints the help documentation for the "purge" command
printPurgeHelp () {
cat <<- EOF

  Usage:
  psadm purge [ agent hub web ]

  Description:
  Purges all cached files for the specified target

EOF
}

# Prints the help documentation for the "watch" command
printWatchHelp () {
cat <<- EOF

  Usage:
  psadm watch [ app prcs ]

  Description:
  Shows server process information until canceled

EOF
}

# Prints the help documentation for the "watch app" command
printWatchAppHelp () {
cat <<- EOF

  Usage:
  psadm watch app [ proc srvr client queue ]

  Description:
  Shows appserver status information until canceled

EOF
}

# Prints the help documentation for the "tail" command
printTailHelp () {
cat <<- EOF

  Usage:
  psadm tail [ app prcs web agent ]

  Description:
  Runs "tail -f" against the logfile(s) of the specified process

EOF
}

#########
# Utility
#########

log () {
  printf "\e[00;31m[PSADM]: $1\e[00m\n" >&2
}

psadminEXE () {
  cd $PS_HOME/appserv
  psadmin $@
}

psadminEXEcute () {
  local server_type=$1
  local command=$2
  local server_domain=$3

  # TODO: figure out why the script isn't returning control after being
  #       executed under windows
  case $(uname -s) in
    (CYGWIN*)
      $BASEDIR/../lib/nt/psadmin.cmd $PS_HOME $PS_CFG_HOME $PS_APP_HOME $server_type $command $server_domain
    ;;
    (*)
      cd $PS_HOME/appserv
      psadmin -$server_type $command -d $server_domain
    ;;
  esac
}

###########
# Appserver
###########

#Boots an application server domain
startAppserver () {
  checkVar "PS_APP_DOMAIN"
  log "INFO - Starting application domain $PS_APP_DOMAIN"
  psadminEXE -c parallelboot -d $PS_APP_DOMAIN
}

#Reloads the domain configuration for the domain.
configAppserver () {
  checkVar "PS_APP_DOMAIN"
  log "INFO - Reloading configuration for $PS_APP_DOMAIN"
  psadminEXE -c configure -d $PS_APP_DOMAIN
}

#Shuts down the application server domain, by using a normal shutdown method
stopAppserver () {
  checkVar "PS_APP_DOMAIN"
  log "INFO - Stopping application domain $PS_APP_DOMAIN"
  psadminEXE -c shutdown -d $PS_APP_DOMAIN
  printBlankLine
}

#Shuts down the application server domain by using a forced shutdown method
killAppserver () {
  checkVar "PS_APP_DOMAIN"
  log "INFO - Killing application domain $PS_APP_DOMAIN"
  psadminEXE -c shutdown! -d $PS_APP_DOMAIN
  printBlankLine
}

#Displays the processes that have been booted for the PSDMO domain
showAppserverProcesses () {
  checkVar "PS_APP_DOMAIN"
  printBanner "Application Server Processes"
  psadminEXE -c pslist -d $PS_APP_DOMAIN
  printBlankLine
}

#Displays the Tuxedo processes and PeopleSoft server processes
showAppserverServerStatus () {
  checkVar "PS_APP_DOMAIN"
  printBanner "Application Server Status"
  psadminEXE -c sstatus -d $PS_APP_DOMAIN
  printBlankLine
}

#Displays the clients connected to the application server domain
showAppserverClientStatus () {
  checkVar "PS_APP_DOMAIN"
  printBanner "Client Status"
  psadminEXE -c cstatus -d $PS_APP_DOMAIN
  printBlankLine
}

#Displays status information about the individual queues for each
#server process in the application server domain.
showAppserverQueueStatus () {
  checkVar "PS_APP_DOMAIN"
  printBanner "Queue Status"
  psadminEXE -c qstatus -d $PS_APP_DOMAIN
  printBlankLine
}

#Preloads the server cache for the domain.
preloadAppserverCache () {
  checkVar "PS_APP_DOMAIN"
  log "INFO - Preloading appserver cache for domain $PS_APP_DOMAIN"
  psadminEXE -c preload -d $PS_APP_DOMAIN
}

#Cleans the IPC resources for the domain.
flushAppserverIPC () {
  checkVar "PS_APP_DOMAIN"
  log "INFO - Flushing appserver IPC resources for domain $PS_APP_DOMAIN"
  psadminEXE -c cleanipc -d $PS_APP_DOMAIN
}

#Purges the cache for the domain.
purgeAppserverCache () {
  checkVar "PS_APP_DOMAIN"
  log "INFO - Clearing appserver cache for domain $PS_APP_DOMAIN"
  psadminEXE -c purge -d $PS_APP_DOMAIN
}

#Stops, purges, reconfigures, and restarts the application server
bounceAppserver () {
  stopAppserver
  flushAppserverIPC
  purgeAppserverCache
  configAppserver
  startAppserver
}

#Loops through the appserver process status until canceled
watchAppserverProcesses () {
  while true
  do
    clear
    showAppserverProcesses
    printBlankLine
    printf "Press [CTRL+C] to stop..\n"
    sleep 5
  done
}

#Loops through the appserver process status until canceled
watchAppserverServerStatus () {
  while true
  do
    clear
    showAppserverServerStatus
    printBlankLine
    printf "Press [CTRL+C] to stop..\n"
    sleep 5
  done
}

#Loops through the appserver client status until canceled
watchAppserverClientStatus () {
  while true
  do
    clear
    showAppserverClientStatus
    printBlankLine
    printf "Press [CTRL+C] to stop..\n"
    sleep 5
  done
}

#Loops through the appserver queue status until canceled
watchAppserverQueueStatus () {
  while true
  do
    clear
    showAppserverQueueStatus
    printBlankLine
    printf "Press [CTRL+C] to stop..\n"
    sleep 5
  done
}

#Tails the appserver logs
tailAppserver () {
  checkVar "PS_HOME"
  checkVar "PS_APP_DOMAIN"
  local app_log_file=$PS_CFG_HOME/appserv/$PS_APP_DOMAIN/LOGS/APPSRV_`date +%m%d`.LOG
  local tux_log_file=$PS_CFG_HOME/appserv/$PS_APP_DOMAIN/LOGS/TUXLOG.`date +%m%d%y`
  multiTail $app_log_file $tux_log_file
}

###################
# Process Scheduler
###################

#Starts a Process Scheduler
startProcessScheduler () {
  checkVar "PS_PRCS_DOMAIN"
  log "INFO - Starting process scheduler domain $PS_PRCS_DOMAIN"
  psadminEXEcute p start ${PS_PRCS_DOMAIN}
  printBlankLine
}

#Stops a Process Scheduler
stopProcessScheduler () {
  checkVar "PS_PRCS_DOMAIN"
  log "INFO - Stopping process scheduler domain $PS_PRCS_DOMAIN"
  psadminEXEcute p stop ${PS_PRCS_DOMAIN}
  printBlankLine
}

#Kills the domain (similar to forced shutdown)
killProcessScheduler () {
  checkVar "PS_PRCS_DOMAIN"
  log "INFO - Killing process scheduler domain $PS_PRCS_DOMAIN"
  psadminEXEcute p kill ${PS_PRCS_DOMAIN}
  printBlankLine
}

#Configures a Process Scheduler
configProcessScheduler () {
  checkVar "PS_PRCS_DOMAIN"
  log "INFO - Reloading configuration for $PS_PRCS_DOMAIN"
  psadminEXEcute p configure ${PS_PRCS_DOMAIN}
  printBlankLine
}

#Displays the status of a Process Scheduler
showProcessSchedulerStatus () {
  checkVar "PS_PRCS_DOMAIN"
  printBanner "Process Scheduler Status"
  psadminEXEcute p status ${PS_PRCS_DOMAIN}
  printBlankLine
}

#Cleans the IPC resources for specified domain
flushProcessSchedulerIPC () {
  checkVar "PS_PRCS_DOMAIN"
  log "INFO - Flushing process scheduler IPC resources for domain $PS_PRCS_DOMAIN"
  psadminEXEcute p cleanipc ${PS_PRCS_DOMAIN}
}

#Stops, purges, reconfigures, and restarts the process scheduler server
bounceProcessScheduler () {
  stopProcessScheduler
  flushProcessSchedulerIPC
  configProcessScheduler
  startProcessScheduler
}

#Loops through the process scheduler status until canceled
watchProcessSchedulerStatus () {
  while true
  do
    clear
    showProcessSchedulerStatus
    printBlankLine
    printf "Press [CTRL+C] to stop..\n"
    sleep 5
  done
}

#Tail the process scheduler logs
tailProcessScheduler () {
  checkVar "PS_HOME"
  checkVar "PS_APP_DOMAIN"
  local prcs_log_file=$PS_CFG_HOME/appserv/prcs/$PS_PRCS_DOMAIN/LOGS/SCHDLR_`date +%m%d`.LOG
  local tux_log_file=$PS_CFG_HOME/appserv/prcs/$PS_PRCS_DOMAIN/LOGS/TUXLOG.`date +%m%d%y`
  multiTail $prcs_log_file $tux_log_file
}

###########
# Webserver
###########

# Starts the webserver process
startWebserver () {
  checkVar "PS_PIA_DOMAIN"
  if [ -f $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/bin/startPIA.sh ]; then
    log "INFO - Starting webserver for domain $PS_PIA_DOMAIN"
    $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/bin/startPIA.sh
  else
    log "ERROR - The file ${PS_CFG_HOME}/webserv/${PS_PIA_DOMAIN}/bin/startPIA.sh was not found"
    exit 1
  fi
}

# Stop the webserver process
stopWebserver () {
  checkVar "PS_PIA_DOMAIN"
  if [ -f $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/bin/stopPIA.sh ]; then
    log "INFO - Stopping webserver for domain $PS_PIA_DOMAIN"
    $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/bin/stopPIA.sh
  else
    log "ERROR - The file ${PS_CFG_HOME}/webserv/${PS_PIA_DOMAIN}/bin/stopPIA.sh was not found"
    exit 1
  fi
}

# Shows the status of the webserver
showWebserverStatus () {
  checkVar "PS_PIA_DOMAIN"
  if [ -f $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/bin/singleserverStatus.sh ]; then
    printBanner "Web Server Status"
    $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/bin/singleserverStatus.sh
    printBlankLine
  else
    log "ERROR - The file ${PS_CFG_HOME}/webserv/${PS_PIA_DOMAIN}/bin/singleserverStatus.sh was not found"
    exit 1
  fi
}

# Purge the webserver cache
purgeWebserverCache () {
  checkVar "PS_PIA_DOMAIN"
  log "INFO - Purging webserver cache for domain $PS_PIA_DOMAIN"
  deleteDirContents $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PORTAL*/*/cache
}

# Stop, clear the cache, and start the webserver
bounceWebserver () {
  stopWebserver
  purgeWebserverCache
  startWebserver
}

#Tail the webserver logs
tailWebserver () {
  checkVar "PS_PIA_DOMAIN"
  local pia_stdout_log=$PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/servers/PIA/logs/PIA_stdout.log
  local pia_stderr_log=$PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/servers/PIA/logs/PIA_stderr.log
  local pia_weblogic_log=$PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/servers/PIA/logs/PIA_weblogic.log
  multiTail $pia_stdout_log $pia_stderr_log $pia_weblogic_log
}

##############################
# Environment Management Agent
##############################

# Start the emagent process and begin tailing the output
startEMAgent () {
  checkVar "PS_HOME"
  assignScriptExtension
  $PS_HOME/PSEMAgent/StartAgent$SCRIPT_EXT
}

# Start the emagent process
stopEMAgent () {
  checkVar "PS_HOME"
  assignScriptExtension
  $PS_HOME/PSEMAgent/StopAgent$SCRIPT_EXT
}

# Shows the status of the emagent
showEMAgentStatus () {
  # TODO
  checkVar "PS_HOME"
  (cd $PS_HOME/PSEMViewer && ./GetEnvInfo.sh)
}

# Purges the emagent cache
purgeEMAgent () {
  checkVar "PS_HOME"
  log "INFO - Purging EMAgent cache"
  assignScriptExtension
  deleteFile $PS_HOME/PSEMAgent/APPSRV.LOG
  deleteFile $PS_HOME/PSEMAgent/nodeid
  deleteFile $PS_HOME/PSEMAgent/nohup.out
  deleteFile $PS_HOME/PSEMAgent/ULOG.*
  deleteFile $PS_HOME/PSEMAgent/envmetadata/data/emf_psae*$SCRIPT_EXT
  deleteFile $PS_HOME/PSEMAgent/envmetadata/data/emf_psreleaseinfo$SCRIPT_EXT
  deleteFile $PS_HOME/PSEMAgent/envmetadata/data/search-results.xml
  deleteDir $PS_HOME/PSEMAgent/envmetadata/data/ids
  deleteDirContents $PS_HOME/PSEMAgent/envmetadata/logs
  deleteDirContents $PS_HOME/PSEMAgent/envmetadata/PersistentStorage
  deleteDirContents $PS_HOME/PSEMAgent/envmetadata/scratchpad
  deleteDirContents $PS_HOME/PSEMAgent/envmetadata/transactions
}

# Restarts the emagent
bounceEMAgent () {
  stopEMAgent
  purgeEMAgent
  startEMAgent
}

#Tail the environment management agent log
tailEMAgent () {
  checkVar "PS_HOME"
  local agent_log=$PS_HOME/PSEMAgent/envmetadata/logs/emf.log
  multiTail $agent_log
}


############################
# Environment Management Hub
############################

# Purges the emhub cache
purgeEMHub () {
  checkVar "PS_HOME"
  log "INFO - Purging EMHub cache"
  deleteFile $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB*/envmetadata/data/state.dat
  deleteFile $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB*/envmetadata/data/transhash.dat
  deleteDir $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB*/envmetadata/data/proxies
  deleteDir $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB*/envmetadata/data/environment
  deleteDirContents $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB*/envmetadata/logs
  deleteDirContents $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB*/envmetadata/PersistentStorage
  deleteDirContents $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB*/envmetadata/scratchpad
  deleteDirContents $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB*/envmetadata/transactions
}

# Restarts the emhub and purges the cache
bounceEMHub () {
  stopWebserver
  purgeWebserverCache
  purgeEMHub
  startWebserver
}

#######
# COBOL
#######

# Compile COBOL
compileCobol () {
  checkVar "PS_HOME"
  if [[ -f $PS_HOME/setup/pscbl.mak ]]; then
    log "INFO - Recompiling COBOL"
    cd $PS_HOME/setup && ./pscbl.mak
    printBlankLine
  else
    log "ERROR - Could not find the file $PS_HOME/setup/pscbl.mak"
    exit 1
  fi
}

# Link COBOL
linkCobol () {
  checkVar "PS_HOME"
  if [[ -f $PS_HOME/setup/psrun.mak ]]; then
    log "INFO - Linking COBOL"
    cd $PS_HOME/setup && ./psrun.mak
    printBlankLine
  else
    log "ERROR - Could not find the file $PS_HOME/setup/psrun.mak"
    exit 1
  fi
}
