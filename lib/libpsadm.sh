#!/usr/bin/env bash
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8
#===============================================================================
#
#          FILE: libpsadm.sh
#
#   DESCRIPTION: Library file for psadm script
#
#===============================================================================

# shellcheck disable=SC2034
PSADMIN_PATH="$PS_HOME/bin"
# shellcheck disable=SC2086
BASEDIR="$(dirname $0)"

# Help Documentation {{{1

#TODO: add color support to documentation
function printHelp () {
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
    kill        Force shutdown of a server process
    purge       Delete cached files for a server process
    watch       Monitor the status of a server process
    tail        Tail the logfile of a server process
    compile     Run the pscbl.mak script to compile cobol
    link        Run the psrun.mak script to link cobol
    preload     Preload the appserver cache
    edit        Edit a server config file
    help        Displays the help menu

EOF
}

# Prints the help documentation for the "status" command
function printStatusHelp () {
cat <<- EOF

  Usage:
  psadm status [ app web prcs agent all ]

  Description:
  Shows the status of the server process specified in the argument

EOF
}

# Prints the help documentation for the "start" command
function printStartHelp () {
cat <<- EOF

  Usage:
  psadm start [ app web prcs agent all ]

  Description:
  Starts the server process specified in the argument

EOF
}

# Prints the help documentation for the "stop" command
function printStopHelp () {
cat <<- EOF

  Usage:
  psadm stop [ app web prcs agent all ]

  Description:
  Stops the server process specified in the argument

EOF
}

# Prints the help documentation for the "kill" command
function printKillHelp () {
cat <<- EOF

  Usage:
  psadm kill [ app prcs ]

  Description:
  Force shutdown of the server process specified in the argument

EOF
}

# Prints the help documentation for the "bounce" command
function printBounceHelp () {
cat <<- EOF

  Usage:
  psadm bounce [ app web prcs agent hub all ]

  Description:
  Restarts the server process specified in the argument

EOF
}

# Prints the help documentation for the "purge" command
function printPurgeHelp () {
cat <<- EOF

  Usage:
  psadm purge [ app agent hub web prcs ]

  Description:
  Purges all cache and log files for the specified target

EOF
}

# Prints the help documentation for the "watch" command
function printWatchHelp () {
cat <<- EOF

  Usage:
  psadm watch [ app prcs ]

  Description:
  Shows server process information until canceled

EOF
}

# Prints the help documentation for the "watch app" command
function printWatchAppHelp () {
cat <<- EOF

  Usage:
  psadm watch app [ proc srvr client queue ]

  Description:
  Shows appserver status information until canceled

EOF
}

# Prints the help documentation for the "tail" command
function printTailHelp () {
cat <<- EOF

  Usage:
  psadm tail [ app prcs web agent ]

  Description:
  Runs "tail -f" against the logfile(s) of the specified process

EOF
}

# Prints the help documentation for the "edit" command
function printEditHelp () {
cat <<- EOF

  Usage:
  psadm edit [ app prcs web agent ig ]

  Description:
  Opens the configuration file for the specified service in the default editor

EOF
}

# }}}

# Utility Functions {{{1

function psadminEXE () {
  echoDebug "Arguments to psadminEXE are: ${*}"
  cd "$PS_HOME/bin" || (echoError "Could not change directory to $PS_HOME/bin"; exit 1)
  psadmin "$@"
}

function psadminExecute () {
  echoDebug "Arguments to psadminExecute are: ${*}"

  local server_type=$1
  local command=$2
  local server_domain=$3

  # TODO: figure out why the script isn't returning control after being
  #       executed under CYGWIN
  case $(uname -s) in
    (CYGWIN*)
      $BASEDIR/../lib/nt/psadmin.cmd $PS_HOME $PS_CFG_HOME $PS_APP_HOME $server_type $command $server_domain
    ;;
    (*)
      cd "$PS_HOME/bin" || (echoError "Could not change directory to $PS_HOME/bin"; exit 1)
      "$PS_HOME"/bin/psadmin -"$server_type" "$command" -d "$server_domain"
    ;;
  esac
}

function bouncePrompt () {
  read -p "Restart the service (y/n)? " choice
  case "$choice" in
    y|Y ) return 0;;
    n|N ) return 1;;
    * ) return 1;;
  esac
}

# }}}

# Appserver {{{1

#Boots an application server domain
function startAppserver () {
  checkVar "PS_APP_DOMAIN"
  echoInfo "Starting application domain $PS_APP_DOMAIN"
  psadminEXE -c boot -d "$PS_APP_DOMAIN"
}

#Reloads the domain configuration for the domain.
function configAppserver () {
  checkVar "PS_APP_DOMAIN"
  echoInfo "Reloading configuration for $PS_APP_DOMAIN"
  psadminEXE -c configure -d "$PS_APP_DOMAIN"
}

#Shuts down the application server domain, by using a normal shutdown method
function stopAppserver () {
  checkVar "PS_APP_DOMAIN"
  echoInfo "Stopping application domain $PS_APP_DOMAIN"
  psadminEXE -c shutdown -d "$PS_APP_DOMAIN"
  printBlankLine
}

#Shuts down the application server domain by using the forced shutdown method
function killAppserver () {
  checkVar "PS_APP_DOMAIN"
  echoInfo "Killing application domain $PS_APP_DOMAIN"
  psadminEXE -c shutdown! -d "$PS_APP_DOMAIN"
  printBlankLine
}

#Displays the processes that have been booted for the PSDMO domain
function showAppserverProcesses () {
  checkVar "PS_APP_DOMAIN"
  printBanner "Application Server Processes"
  psadminEXE -c pslist -d "$PS_APP_DOMAIN"
  printBlankLine
}

#Displays the Tuxedo processes and PeopleSoft server processes
function showAppserverServerStatus () {
  checkVar "PS_APP_DOMAIN"
  printBanner "Application Server Status"
  psadminEXE -c sstatus -d "$PS_APP_DOMAIN"
  printBlankLine
}

#Displays the clients connected to the application server domain
function showAppserverClientStatus () {
  checkVar "PS_APP_DOMAIN"
  printBanner "Client Status"
  psadminEXE -c cstatus -d "$PS_APP_DOMAIN"
  printBlankLine
}

#Displays status information about the individual queues for each
#server process in the application server domain.
function showAppserverQueueStatus () {
  checkVar "PS_APP_DOMAIN"
  printBanner "Queue Status"
  psadminEXE -c qstatus -d "$PS_APP_DOMAIN"
  printBlankLine
}

#Preloads the server cache for the domain.
function preloadAppserverCache () {
  checkVar "PS_APP_DOMAIN"
  log "INFO - Preloading appserver cache for domain $PS_APP_DOMAIN"
  psadminEXE -c preload -d "$PS_APP_DOMAIN"
}

#Cleans the IPC resources for the domain.
function flushAppserverIPC () {
  checkVar "PS_APP_DOMAIN"
  echoInfo "Flushing appserver IPC resources for domain $PS_APP_DOMAIN"
  psadminEXE -c cleanipc -d "$PS_APP_DOMAIN"
}

#Purges the cache for the domain.
function purgeAppserverCache () {
  checkVar "PS_APP_DOMAIN"
  echoInfo "Clearing appserver cache for domain $PS_APP_DOMAIN"
  psadminEXE -c purge -d "$PS_APP_DOMAIN"
}

#Stops, purges, reconfigures, and restarts the application server
function bounceAppserver () {
  stopAppserver
  flushAppserverIPC
  purgeAppserverCache
  configAppserver
  startAppserver
}

#Loops through the appserver process status until canceled
function watchAppserverProcesses () {
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
function watchAppserverServerStatus () {
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
function watchAppserverClientStatus () {
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
function watchAppserverQueueStatus () {
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
function tailAppserver () {
  checkVar "PS_HOME"
  checkVar "PS_APP_DOMAIN"
  local app_log_file=$PS_CFG_HOME/appserv/$PS_APP_DOMAIN/LOGS/APPSRV_`date +%m%d`.LOG
  local tux_log_file=$PS_CFG_HOME/appserv/$PS_APP_DOMAIN/LOGS/TUXLOG.`date +%m%d%y`
  local ren_log_file=$PS_CFG_HOME/appserv/$PS_APP_DOMAIN/LOGS/PSRENSRV_`date +%m%d`.LOG
  local watch_log_file=$PS_CFG_HOME/appserv/$PS_APP_DOMAIN/LOGS/WATCHSRV_`date +%m%d`.LOG
  local monitor_log_file=$PS_CFG_HOME/appserv/$PS_APP_DOMAIN/LOGS/MONITORSRV_`date +%m%d`.LOG
  local analytic_log_file=$PS_CFG_HOME/appserv/$PS_APP_DOMAIN/LOGS/ANALYTICSRV_`date +%m%d`.LOG
  local stderr_log_file=$PS_CFG_HOME/appserv/$PS_APP_DOMAIN/LOGS/stderr
  multiTail $app_log_file $tux_log_file $ren_log_file $watch_log_file $monitor_log_file $analytic_log_file $stderr_log_file
}

#Open the appserver configuration file in the default editor
function editAppserver () {
  checkVar "PS_CFG_HOME"
  checkVar "PS_APP_DOMAIN"
  checkVar "EDITOR"
  local app_config_file=$PS_CFG_HOME/appserv/$PS_APP_DOMAIN/psappsrv.cfg
  echoInfo "Opening ${app_config_file}"
  $EDITOR "$app_config_file" && bouncePrompt && bounceAppserver
}

# }}}

# Process Scheduler {{{1

#Starts a Process Scheduler
function startProcessScheduler () {
  checkVar "PS_PRCS_DOMAIN"
  echoInfo "Starting process scheduler domain $PS_PRCS_DOMAIN"
  psadminExecute p start ${PS_PRCS_DOMAIN}
  printBlankLine
}

#Stops a Process Scheduler
function stopProcessScheduler () {
  checkVar "PS_PRCS_DOMAIN"
  echoInfo "Stopping process scheduler domain $PS_PRCS_DOMAIN"
  psadminExecute p stop ${PS_PRCS_DOMAIN}
  printBlankLine
}

#Kills the domain (similar to forced shutdown)
function killProcessScheduler () {
  checkVar "PS_PRCS_DOMAIN"
  echoInfo "Killing process scheduler domain $PS_PRCS_DOMAIN"
  psadminExecute p kill ${PS_PRCS_DOMAIN}
  printBlankLine
}

#Configures a Process Scheduler
function configProcessScheduler () {
  checkVar "PS_PRCS_DOMAIN"
  echoInfo "Reloading configuration for $PS_PRCS_DOMAIN"
  psadminExecute p configure ${PS_PRCS_DOMAIN}
  printBlankLine
}

#Displays the status of a Process Scheduler
function showProcessSchedulerStatus () {
  #TODO: this gives a return code of 5
  checkVar "PS_PRCS_DOMAIN"
  printBanner "Process Scheduler Status"
  psadminExecute p status "${PS_PRCS_DOMAIN}"
  printBlankLine
  printBlankLine
}

#Cleans the IPC resources for specified domain
function flushProcessSchedulerIPC () {
  checkVar "PS_PRCS_DOMAIN"
  echoInfo "Flushing process scheduler IPC resources for domain $PS_PRCS_DOMAIN"
  psadminExecute p cleanipc ${PS_PRCS_DOMAIN}
}

# Purge the process scheduler cache
function purgeProcessSchedulerCache () {
  checkVar "PS_PRCS_DOMAIN"
  echoInfo "Purging process scheduler logs for domain $PS_PRCS_DOMAIN"
  deleteDirContents "$PS_CFG_HOME/appserv/prcs/$PS_PRCS_DOMAIN/LOGS"
  deleteDirContents "$PS_CFG_HOME/appserv/prcs/$PS_PRCS_DOMAIN/log_output"
  deleteFile $PS_CFG_HOME/appserv/prcs/$PS_PRCS_DOMAIN/ULOG.*
  echoInfo "Purging process scheduler cache for domain $PS_PRCS_DOMAIN"
  deleteDirContents $PS_CFG_HOME/appserv/prcs/$PS_PRCS_DOMAIN/CACHE
}

#Stops, purges, reconfigures, and restarts the process scheduler server
function bounceProcessScheduler () {
  stopProcessScheduler
  flushProcessSchedulerIPC
  purgeProcessSchedulerCache
  configProcessScheduler
  startProcessScheduler
}

#Loops through the process scheduler status until canceled
function watchProcessSchedulerStatus () {
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
function tailProcessScheduler () {
  checkVar "PS_HOME"
  checkVar "PS_PRCS_DOMAIN"
  local prcs_log_file=$PS_CFG_HOME/appserv/prcs/$PS_PRCS_DOMAIN/LOGS/SCHDLR_`date +%m%d`.LOG
  local tux_log_file=$PS_CFG_HOME/appserv/prcs/$PS_PRCS_DOMAIN/LOGS/TUXLOG.`date +%m%d%y`
  multiTail $prcs_log_file $tux_log_file
}

#Open the process scheduler configuration file in the default editor
function editProcessScheduler () {
  checkVar "PS_CFG_HOME"
  checkVar "PS_PRCS_DOMAIN"
  checkVar "EDITOR"
  local prcs_config_file=$PS_CFG_HOME/appserv/prcs/$PS_PRCS_DOMAIN/psprcs.cfg
  echoInfo "Opening ${prcs_config_file}"
  $EDITOR "$prcs_config_file" && bouncePrompt && bounceProcessScheduler
}

# }}}

# Webserver {{{1

# Starts the webserver process
function startWebserver () {
  checkVar "PS_PIA_DOMAIN"
  psadminExecute w start ${PS_PIA_DOMAIN}
}

# Stop the webserver process
function stopWebserver () {
  checkVar "PS_PIA_DOMAIN"
  psadminExecute w shutdown ${PS_PIA_DOMAIN}
}

# Shows the status of the webserver
function showWebserverStatus () {
  checkVar "PS_PIA_DOMAIN"
  psadminExecute w status ${PS_PIA_DOMAIN}
}

# Purge the webserver cache
function purgeWebserverCache () {
  checkVar "PS_PIA_DOMAIN"
  echoInfo "Purging webserver cache for domain $PS_PIA_DOMAIN"
  deleteDirContents $PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PORTAL*/*/cache
}

# Stop, clear the cache, and start the webserver
function bounceWebserver () {
  stopWebserver
  purgeWebserverCache
  startWebserver
}

#Tail the webserver logs
function tailWebserver () {
  checkVar "PS_PIA_DOMAIN"
  local pia_stdout_log=$PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/servers/PIA/logs/PIA_stdout.log
  local pia_stderr_log=$PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/servers/PIA/logs/PIA_stderr.log
  local pia_weblogic_log=$PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/servers/PIA/logs/PIA_weblogic.log
  multiTail $pia_stdout_log $pia_stderr_log $pia_weblogic_log
}

#Open the webserver configuration file in the default editor
function editWebserver () {
  checkVar "PS_PIA_HOME"
  checkVar "PS_PIA_DOMAIN"
  checkVar "PS_PIA_SITE"
  checkVar "EDITOR"
  local pia_config_file=$PS_PIA_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PORTAL.war/WEB-INF/psftdocs/$PS_PIA_SITE/configuration.properties
  echoInfo "Opening ${pia_config_file}"
  $EDITOR $pia_config_file && bouncePrompt && bounceWebserver
}

#Open the integrationGateway.properties configuration file in the default editor
function editIntegrationGateway () {
  checkVar "PS_PIA_HOME"
  checkVar "PS_PIA_DOMAIN"
  checkVar "EDITOR"
  local ig_config_file=$PS_PIA_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSIGW.war/WEB-INF/integrationGateway.properties
  echoInfo "Opening ${ig_config_file}"
  $EDITOR "$ig_config_file"
}

# }}}

# Environment Management Agent {{{1

# Start the emagent process and begin tailing the output
function startEMAgent () {
  checkVar "PS_HOME"
  assignScriptExtension
  "$PS_HOME/PSEMAgent/StartAgent$SCRIPT_EXT"
}

# Start the emagent process
function stopEMAgent () {
  checkVar "PS_HOME"
  assignScriptExtension
  "$PS_HOME/PSEMAgent/StopAgent$SCRIPT_EXT"
}

# Shows the status of the emagent
function showEMAgentStatus () {
  checkVar "PS_HOME"
  (cd "$PS_HOME/PSEMViewer" && ./GetEnvInfo.sh)
}

# Purges the emagent cache
function purgeEMAgent () {
  checkVar "PS_HOME"
  echoInfo "Purging EMAgent cache"
  assignScriptExtension
  deleteFile "$PS_HOME/PSEMAgent/APPSRV.LOG"
  deleteFile "$PS_HOME/PSEMAgent/nodeid"
  deleteFile "$PS_HOME/PSEMAgent/nohup.out"
  deleteFile "$PS_HOME/PSEMAgent/ULOG.*"
  deleteFile "$PS_HOME/PSEMAgent/envmetadata/data/emf_psae*$SCRIPT_EXT"
  deleteFile "$PS_HOME/PSEMAgent/envmetadata/data/emf_psreleaseinfo$SCRIPT_EXT"
  deleteFile "$PS_HOME/PSEMAgent/envmetadata/data/search-results.xml"
  deleteDir "$PS_HOME/PSEMAgent/envmetadata/data/ids"
  deleteDirContents "$PS_HOME/PSEMAgent/envmetadata/logs"
  deleteDirContents "$PS_HOME/PSEMAgent/envmetadata/PersistentStorage"
  deleteDirContents "$PS_HOME/PSEMAgent/envmetadata/scratchpad"
  deleteDirContents "$PS_HOME/PSEMAgent/envmetadata/transactions"
}

# Restarts the emagent
function bounceEMAgent () {
  stopEMAgent
  purgeEMAgent
  startEMAgent
}

#Tail the environment management agent log
function tailEMAgent () {
  checkVar "PS_HOME"
  local agent_log="$PS_HOME/PSEMAgent/envmetadata/logs/emf.log"
  multiTail "$agent_log"
}

#Open the process scheduler configuration file in the default editor
function editEMAgent () {
  checkVar "PS_HOME"
  checkVar "EDITOR"
  local agent_config_file=$PS_HOME/PSEMAgent/envmetadata/config/configuration.properties
  echoInfo "Opening ${agent_config_file}"
  $EDITOR "$agent_config_file" && bouncePrompt && bounceEMAgent
}

# }}}

# Environment Management Hub {{{1

# Purges the emhub cache
function purgeEMHub () {
  checkVar "PS_HOME"
  log "INFO - Purging EMHub cache"
  deleteFile "$PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB.war/envmetadata/data/state.dat"
  deleteFile "$PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB.war/envmetadata/data/transhash.dat"
  deleteDir "$PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB.war/envmetadata/data/proxies"
  deleteDir "$PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB.war/envmetadata/data/environment"
  deleteDirContents "$PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB.war/envmetadata/logs"
  deleteDirContents "$PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB.war/envmetadata/PersistentStorage"
  deleteDirContents "$PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB.war/envmetadata/scratchpad"
  deleteDirContents "$PS_CFG_HOME/webserv/$PS_PIA_DOMAIN/applications/peoplesoft/PSEMHUB.war/envmetadata/transactions"
}

# Restarts the emhub and purges the cache
function bounceEMHub () {
  stopWebserver
  purgeWebserverCache
  purgeEMHub
  startWebserver
}

# }}}

# COBOL {{{1

# Compile COBOL
function compileCobol () {
  checkVar "PS_HOME"
  if [[ -f $PS_HOME/setup/pscbl.mak ]]; then
    echoInfo "Recompiling COBOL"
    cd "$PS_HOME/setup" && ./pscbl.mak
    printBlankLine
  else
    echoError "Could not find the file $PS_HOME/setup/pscbl.mak"
    exit 1
  fi
}

# Link COBOL
function linkCobol () {
  checkVar "PS_HOME"
  if [[ -f $PS_HOME/setup/psrun.mak ]]; then
    echoInfo "Linking COBOL"
    cd "$PS_HOME/setup" && ./psrun.mak
    printBlankLine
  else
    echoError "Could not find the file $PS_HOME/setup/psrun.mak"
    exit 1
  fi
}

# }}}
