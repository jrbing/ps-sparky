#!/usr/bin/env bash
# Library file for psadmin commands

PSADMIN_PATH=$PS_HOME/appserv

#######
# Admin
#######

psadminEXE () {
  cd $PS_HOME/appserv
  psadmin $@
}

########
# Output
########

printHL () {
  printf "\n----------------------------------------\n"
}

printBanner () {
  printHL
  printf "####  $1  ####"
  printHL
}

printBlankLine () {
  printf "\n"
}

pause () {
  sleep 5
}

log () {
  printf "[PSADM]: $1\n" >&2
}

###########
# Appserver
###########

startAppserver () {
  #Boots an application server domain
  psadminEXE -c parallelboot -d $PS_APP_DOMAIN
}

configAppserver () {
  #Reloads the domain configuration for the domain.
  psadminEXE -c configure -d $PS_APP_DOMAIN
}

stopAppserver () {
  #Shuts down the application server domain, by using a normal shutdown method.
  #In a normal shutdown, the domain waits for users to complete their tasks and turns away new requests before terminating all of the processes in the domain.
  psadminEXE -c shutdown -d $PS_APP_DOMAIN
}

killAppserver () {
  #Shuts down the application server domain by using a forced shutdown method.
  #In a forced shutdown, the domain immediately terminates all of the processes in the domain.
  psadminEXE -c shutdown! -d $PS_APP_DOMAIN
}

showAppserverProcesses () {
  #Displays the processes that have been booted for the PSDMO domain. This includes the system process ID for each process.
  printBanner "Application Server Processes"
  psadminEXE -c pslist -d $PS_APP_DOMAIN
  printBlankLine
}

showAppserverServerStatus () {
  #Displays the Tuxedo processes and PeopleSoft server processes that are currently running in the PSDMO application server domain.
  printBanner "Application Server Status"
  psadminEXE -c sstatus -d $PS_APP_DOMAIN
  printBlankLine
}

showAppserverClientStatus () {
  #Displays the currently connected users in the application server domain.
  printBanner "Client Status"
  psadminEXE -c cstatus -d $PS_APP_DOMAIN
  printBlankLine
}

showAppserverQueueStatus () {
  #Displays status information about the individual queues for each server process in the application server domain.
  printBanner "Queue Status"
  psadminEXE -c qstatus -d $PS_APP_DOMAIN
  printBlankLine
}

preloadAppserverCache () {
  #Preloads the server cache for the domain.
  psadminEXE -c preload -d $PS_APP_DOMAIN
}

flushAppserverIPC () {
  #Cleans the IPC resources for the domain.
  psadminEXE -c cleanipc -d $PS_APP_DOMAIN
}

purgeAppserverCache () {
  #Purges the cache for the domain.
  psadminEXE -c purge -d $PS_APP_DOMAIN
}

bounceAppserver () {
  #Stops, purges, reconfigures, and restarts the application server
  stopAppserver
  flushAppserverIPC
  purgeAppserverCache
  configAppserver
  startAppserver
}

watchAppserverProcesses () {
  #Loops through the appserver process status until canceled
  while true
  do
    clear
    showAppserverProcesses
    printBlankLine
    printf "Press [CTRL+C] to stop..\n"
    sleep 5
  done
}

watchAppserverServerStatus () {
  #Loops through the appserver process status until canceled
  while true
  do
    clear
    showAppserverServerStatus
    printBlankLine
    printf "Press [CTRL+C] to stop..\n"
    sleep 5
  done
}

watchAppserverClientStatus () {
  #Loops through the appserver queue status until canceled
  while true
  do
    clear
    showAppserverClientStatus
    printBlankLine
    printf "Press [CTRL+C] to stop..\n"
    sleep 5
  done
}

watchAppserverQueueStatus () {
  #Loops through the appserver queue status until canceled
  while true
  do
    clear
    showAppserverQueueStatus
    printBlankLine
    printf "Press [CTRL+C] to stop..\n"
    sleep 5
  done
}

###################
# Process Scheduler
###################

startProcessScheduler () {
  #Starts a Process Scheduler
  psadminEXE -p start -d $PS_PRCS_DOMAIN
}

stopProcessScheduler () {
  #Stops a Process Scheduler
  psadminEXE -p stop -d $PS_PRCS_DOMAIN
}

killProcessScheduler () {
  #Kills the domain (similar to forced shutdown)
  psadminEXE -p kill -d $PS_PRCS_DOMAIN
}

configProcessScheduler () {
  #Configures a Process Scheduler
  psadminEXE -p configure -d $PS_PRCS_DOMAIN
}

showProcessSchedulerStatus () {
  #Displays the status of a Process Scheduler
  printBanner "Process Scheduler Status"
  psadminEXE -p status -d $PS_PRCS_DOMAIN
  printBlankLine
}

flushProcessSchedulerIPC () {
  #Cleans the IPC resources for specified domain
  psadminEXE -p cleanipc -d $PS_PRCS_DOMAIN
}

bounceProcessScheduler () {
  #Stops, purges, reconfigures, and restarts the process scheduler server
  stopProcessScheduler
  flushProcessSchedulerIPC
  configProcessScheduler
  startProcessScheduler
}

watchProcessSchedulerStatus () {
  #Loops through the process scheduler status until canceled
  while true
  do
    clear
    showProcessSchedulerStatus
    printBlankLine
    printf "Press [CTRL+C] to stop..\n"
    sleep 5
  done
}
###########
# Webserver
###########

startWebserver () {
  # Starts the webserver process
  if [ -f $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/bin/startPIA.sh ]; then
    $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/bin/startPIA.sh
  else
    log "The file ${PS_CFG_HOME}/webserv/${PS_PIA_DOMAIN}/bin/startPIA.sh was not found"
    exit 1
  fi
}

stopWebserver () {
  # Stop the webserver process
  if [ -f $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/bin/stopPIA.sh ]; then
    $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/bin/stopPIA.sh
  else
    log "The file ${PS_CFG_HOME}/webserv/${PS_PIA_DOMAIN}/bin/stopPIA.sh was not found"
    exit 1
  fi
}

#killWebserver () {
  # TODO
  # $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/servers/PIA/logs/PIA.pid
#}

showWebserverStatus () {
  # TODO:  fix to work with 8.49
  if [ -f $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/bin/singleserverStatus.sh ]; then
    printBanner "Web Server Status"
    $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/bin/singleserverStatus.sh
    printBlankLine
  else
    log "The file ${PS_CFG_HOME}/webserv/${PS_PIA_DOMAIN}/bin/singleserverStatus.sh was not found"
    exit 1
  fi
}

purgeWebserverCache () {
  # Purgest the webserver cache
  printf "\n"
  printf "Purging Webserver Cache Files\n"
  printf "\n"
  set -x
  rm -r $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PORTAL.WAR/$PS_PIA_DOMAIN/cache/*
  set +x
  printf "\n"
  printf "Cache Cleared"
  printf "\n"
}

bounceWebserver () {
  stopWebserver
  purgeWebserverCache
  startWebserver
}

##############################
# Environment Management Agent
##############################

startEMAgent () {
  # Start the emagent process and begin tailing the output
  $PS_HOME/PSEMAgent/StartAgent.sh && tail -f $PS_HOME/PSEMAgent/envmetadata/logs/emf.log
}

stopEMAgent () {
  # Start the emagent process
  $PS_HOME/PSEMAgent/StopAgent.sh
}

#killEMAgent () {
  # TODO
  # Look for the following process in ps and kill the associated PID
  #../jre/bin/java com.peoplesoft.pt.environmentmanagement.agent.Agent shutdown
#}

showEMAgentStatus () {
  # TODO
  $PS_HOME/PSEMViewer/GetEnvInfo.sh
}

purgeEMAgent () {
  # TODO:  cleanup
  printf " \n"
  printf "Purging Environment Management Agent Cache Files\n"
  printf " \n"
  set -x
  rm     $PS_HOME/PSEMAgent/APPSRV.LOG
  rm     $PS_HOME/PSEMAgent/nohup.out
  rm     $PS_HOME/PSEMAgent/ULOG.*
  rm     $PS_HOME/PSEMAgent/envmetadata/data/emf_psae*.sh
  rm     $PS_HOME/PSEMAgent/envmetadata/data/emf_psreleaseinfo.sh
  rm     $PS_HOME/PSEMAgent/envmetadata/data/search-results.xml
  rm -rf $PS_HOME/PSEMAgent/envmetadata/data/ids
  rm     $PS_HOME/PSEMAgent/envmetadata/logs/*
  rm -rf $PS_HOME/PSEMAgent/envmetadata/PersistentStorage/*
  rm -rf $PS_HOME/PSEMAgent/envmetadata/scratchpad/*
  #rm -rf $PS_HOME/PSEMAgent/envmetadata/transactions/*
  set +x
  printf " \n"
  printf "Files Cleared\n"
  printf " \n"
}

bounceEMAgent () {
  stopEMAgent
  purgeEMAgent
  startEMAgent
}

############################
# Environment Management Hub
############################

purgeEMHub () {
  # TODO:  test
  printf " \n"
  printf "Purging Environment Management Hub Cache Files\n"
  printf " \n"
  set -x
  rm -rf $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB.war/envmetadata/data/environment
  rm -rf $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB.war/envmetadata/data/proxies
  rm     $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB.war/envmetadata/data/state.dat
  rm     $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB.war/envmetadata/data/transhash.dat
  rm     $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB.war/envmetadata/logs/*
  rm -rf $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB.war/envmetadata/PersistentStorage/*
  rm -rf $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB.war/envmetadata/scratchpad/*
  rm -rf $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB.war/envmetadata/transactions/*
  set +x
  printf " \n"
  printf "Files Cleared\n"
  printf " \n"
}

bounceEMHub () {
  stopEMAgent
  stopWebserver
  purgeWebserverCache
  purgeEMHub
  purgeEMAgent
  startWebserver
  startEMAgent
}
