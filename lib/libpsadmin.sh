#!/usr/bin/env bash
# Library file for psadmin commands

PSADMIN_PATH=$PS_HOME/appserv

########
# Output
########

printHL () {
  printf "\n----------------------------------------\n"
}

printBanner () {
  printHL
  printf "\e[00;31m####  $1  ####\e[00m\n"
  printHL
}

printBlankLine () {
  printf "\n"
}

pause () {
  sleep 5
}

log () {
  printf "\e[00;31m[PSADM]: $1\e[00m\n" >&2
}

#########
# Utility
#########

psadminEXE () {
  cd $PS_HOME/appserv
  psadmin $@
}

# Check to see if the appropriate environment variables are set
checkVar () {
  if [[ `printenv ${1}` = '' ]]; then
    log "ERROR - ${1} is not set.  You'll need to set this in your environment file."
    exit 1
  fi
}

# Delete the specified file
deleteFile () {
  local file_path=$1
  if [ -f ${file_path} ]; then
    log "INFO - Deleting file ${file_path}"
    rm $file_path
  else
    log "INFO - $file_path not found"
  fi
}

# Delete the specified directory recursively
deleteDir () {
  local dir_path=$1
  if [ -d ${dir_path} ]; then
    log "INFO - Deleting directory ${dir_path}"
    rm -rf $dir_path
  else
    log "INFO - $dir_path not found"
  fi
}

# Delete the specified directory's contents
deleteDirContents () {
  local dir_path=$1
  if [ -d ${dir_path} ]; then
    log "INFO - Deleting contents of ${dir_path}"
    rm -rf $dir_path/*
  else
    log "INFO - $dir_path not found"
  fi
}

assignScriptExtension () {
  case $(uname -s) in
    (Linux*)
      SCRIPT_EXT=".sh"
    ;;
    (SunOS*)
      SCRIPT_EXT=".sh"
    ;;
    (CYGWIN*)
      SCRIPT_EXT=".bat"
    ;;
    (*)
      SCRIPT_EXT=".sh"
    ;;
  esac
}

multiTail () {
  trap 'kill $(jobs -p)' EXIT
  for file in "$@"
  do
    log "INFO - Beginning tail of $file"
    tail -n 50 -f $file &
  done
  wait
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
}

#Shuts down the application server domain by using a forced shutdown method
killAppserver () {
  checkVar "PS_APP_DOMAIN"
  log "INFO - Killing application domain $PS_APP_DOMAIN"
  psadminEXE -c shutdown! -d $PS_APP_DOMAIN
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
  psadminEXE -p start -d $PS_PRCS_DOMAIN
}

#Stops a Process Scheduler
stopProcessScheduler () {
  checkVar "PS_PRCS_DOMAIN"
  log "INFO - Stopping process scheduler domain $PS_PRCS_DOMAIN"
  psadminEXE -p stop -d $PS_PRCS_DOMAIN
}

#Kills the domain (similar to forced shutdown)
killProcessScheduler () {
  checkVar "PS_PRCS_DOMAIN"
  log "INFO - Killing process scheduler domain $PS_PRCS_DOMAIN"
  psadminEXE -p kill -d $PS_PRCS_DOMAIN
}

#Configures a Process Scheduler
configProcessScheduler () {
  checkVar "PS_PRCS_DOMAIN"
  log "INFO - Reloading configuration for $PS_PRCS_DOMAIN"
  psadminEXE -p configure -d $PS_PRCS_DOMAIN
}

#Displays the status of a Process Scheduler
showProcessSchedulerStatus () {
  checkVar "PS_PRCS_DOMAIN"
  printBanner "Process Scheduler Status"
  psadminEXE -p status -d $PS_PRCS_DOMAIN
  printBlankLine
}

#Cleans the IPC resources for specified domain
flushProcessSchedulerIPC () {
  checkVar "PS_PRCS_DOMAIN"
  log "INFO - Flushing process scheduler IPC resources for domain $PS_PRCS_DOMAIN"
  psadminEXE -p cleanipc -d $PS_PRCS_DOMAIN
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

# Purgest the webserver cache
purgeWebserverCache () {
  checkVar "PS_PIA_DOMAIN"
  log "INFO - Purging webserver cache for domain $PS_PIA_DOMAIN"
  deleteDirContents $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PORTAL.war/$PS_PIA_DOMAIN/cache
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
  deleteFile $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB.war/envmetadata/data/state.dat
  deleteFile $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB.war/envmetadata/data/transhash.dat
  deleteDir $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB.war/envmetadata/data/proxies
  deleteDir $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB.war/envmetadata/data/environment
  deleteDirContents $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB.war/envmetadata/logs
  deleteDirContents $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB.war/envmetadata/PersistentStorage
  deleteDirContents $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB.war/envmetadata/scratchpad
  deleteDirContents $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB.war/envmetadata/transactions
}

# Restarts the emhub and purges the cache
bounceEMHub () {
  stopWebserver
  purgeWebserverCache
  purgeEMHub
  startWebserver
}

#######
# Cobol
#######

# Start the emagent process and begin tailing the output
compileCobol () {
  checkVar "PS_HOME"
  if [ -f $PS_HOME/setup/pscbl.mak ]; then
    log "INFO - Recompiling Cobol"
    $PS_HOME/setup/pscbl.mak
    printBlankLine
  else
    log "ERROR - Could not find the file $PS_HOME/setup/pscbl.mak"
    exit 1
  fi
}

# Start the emagent process
linkCobol () {
  checkVar "PS_HOME"
  if [ -f $PS_HOME/setup/psrun.mak ]; then
    log "INFO - Linking COBOL"
    $PS_HOME/setup/psrun.mak
    printBlankLine
  else
    log "ERROR - Could not find the file $PS_HOME/setup/psrun.mak"
    exit 1
  fi
}
