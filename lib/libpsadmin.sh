#!/usr/bin/env bash
# Library file for psadmin commands

PSADMIN_PATH=$PS_HOME/appserv

#########
# Utility
#########

psadminEXE () {
  cd $PS_HOME/appserv
  psadmin $@
}

checkVar () {
 # Check to see if the appropriate environment variables are set
    if [[ `printenv ${1}` = '' ]]; then
      printf "[PSENV]: ${1} is not set.  You'll need to set this in your environment file\n"
      exit 1
    fi
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

#Boots an application server domain
startAppserver () {
  checkVar "PS_APP_DOMAIN"
  psadminEXE -c parallelboot -d $PS_APP_DOMAIN
}

#Reloads the domain configuration for the domain.
configAppserver () {
  checkVar "PS_APP_DOMAIN"
  psadminEXE -c configure -d $PS_APP_DOMAIN
}

#Shuts down the application server domain, by using a normal shutdown
#method. In a normal shutdown, the domain waits for users to complete
#their tasks and turns away new requests before terminating all of the
#processes in the domain.
stopAppserver () {
  checkVar "PS_APP_DOMAIN"
  psadminEXE -c shutdown -d $PS_APP_DOMAIN
}

#Shuts down the application server domain by using a forced shutdown method.
#In a forced shutdown, the domain immediately terminates all of the processes
#in the domain.
killAppserver () {
  checkVar "PS_APP_DOMAIN"
  psadminEXE -c shutdown! -d $PS_APP_DOMAIN
}

#Displays the processes that have been booted for the PSDMO domain. This
#includes the system process ID for each process.
showAppserverProcesses () {
  checkVar "PS_APP_DOMAIN"
  printBanner "Application Server Processes"
  psadminEXE -c pslist -d $PS_APP_DOMAIN
  printBlankLine
}

#Displays the Tuxedo processes and PeopleSoft server processes that are
#currently running in the PSDMO application server domain.
showAppserverServerStatus () {
  checkVar "PS_APP_DOMAIN"
  printBanner "Application Server Status"
  psadminEXE -c sstatus -d $PS_APP_DOMAIN
  printBlankLine
}

#Displays the clients connected to the application server domain.
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
  psadminEXE -c preload -d $PS_APP_DOMAIN
}

#Cleans the IPC resources for the domain.
flushAppserverIPC () {
  checkVar "PS_APP_DOMAIN"
  psadminEXE -c cleanipc -d $PS_APP_DOMAIN
}

#Purges the cache for the domain.
purgeAppserverCache () {
  checkVar "PS_APP_DOMAIN"
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

#Loops through the appserver queue status until canceled
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

###################
# Process Scheduler
###################

#Starts a Process Scheduler
startProcessScheduler () {
  checkVar "PS_PRCS_DOMAIN"
  psadminEXE -p start -d $PS_PRCS_DOMAIN
}

#Stops a Process Scheduler
stopProcessScheduler () {
  checkVar "PS_PRCS_DOMAIN"
  psadminEXE -p stop -d $PS_PRCS_DOMAIN
}

#Kills the domain (similar to forced shutdown)
killProcessScheduler () {
  checkVar "PS_PRCS_DOMAIN"
  psadminEXE -p kill -d $PS_PRCS_DOMAIN
}

#Configures a Process Scheduler
configProcessScheduler () {
  checkVar "PS_PRCS_DOMAIN"
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
###########
# Webserver
###########

# Starts the webserver process
startWebserver () {
  checkVar "PS_PIA_DOMAIN"
  if [ -f $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/bin/startPIA.sh ]; then
    $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/bin/startPIA.sh
  else
    log "The file ${PS_CFG_HOME}/webserv/${PS_PIA_DOMAIN}/bin/startPIA.sh was not found"
    exit 1
  fi
}

# Stop the webserver process
stopWebserver () {
  checkVar "PS_PIA_DOMAIN"
  if [ -f $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/bin/stopPIA.sh ]; then
    $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/bin/stopPIA.sh
  else
    log "The file ${PS_CFG_HOME}/webserv/${PS_PIA_DOMAIN}/bin/stopPIA.sh was not found"
    exit 1
  fi
}

#killWebserver () {
  # TODO
  #checkVar "PS_PIA_DOMAIN"
  # $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/servers/PIA/logs/PIA.pid
#}

# Shows the status of the webserver
showWebserverStatus () {
  checkVar "PS_PIA_DOMAIN"
  if [ -f $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/bin/singleserverStatus.sh ]; then
    printBanner "Web Server Status"
    $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/bin/singleserverStatus.sh
    printBlankLine
  else
    log "The file ${PS_CFG_HOME}/webserv/${PS_PIA_DOMAIN}/bin/singleserverStatus.sh was not found"
    exit 1
  fi
}

# Purgest the webserver cache
purgeWebserverCache () {
  checkVar "PS_PIA_DOMAIN"
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

# Start the emagent process and begin tailing the output
startEMAgent () {
  $PS_HOME/PSEMAgent/StartAgent.sh && tail -f $PS_HOME/PSEMAgent/envmetadata/logs/emf.log
}

# Start the emagent process
stopEMAgent () {
  $PS_HOME/PSEMAgent/StopAgent.sh
}

#killEMAgent () {
  # TODO
  # Look for the following process in ps and kill the associated PID
  #../jre/bin/java com.peoplesoft.pt.environmentmanagement.agent.Agent shutdown
#}

# Shows the status of the emagent
showEMAgentStatus () {
  # TODO
  $PS_HOME/PSEMViewer/GetEnvInfo.sh
}

# Purges the emagent cache
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

# Restarts the emagent
bounceEMAgent () {
  stopEMAgent
  purgeEMAgent
  startEMAgent
}

############################
# Environment Management Hub
############################

# Purges the emhub cache
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

# Restarts the emhub
bounceEMHub () {
  stopEMAgent
  stopWebserver
  purgeWebserverCache
  purgeEMHub
  purgeEMAgent
  startWebserver
  startEMAgent
}
