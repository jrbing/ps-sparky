#!/usr/bin/env bash
#===============================================================================
# vim: softtabstop=2 shiftwidth=2 expandtab fenc=utf-8:
#===============================================================================
#
#          FILE: libpswls.sh
#
#   DESCRIPTION: Library file for pswls script
#
#===============================================================================

SPLIBDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# shellcheck source=/dev/null
source "$SPLIBDIR"/libutil.sh

function validatePSWLSProperties() {
  echoDebug "Validating the preconfigured environment variables necessary for pswls are set"
  checkVar "WL_BASE"
  checkVar "WL_HOST"
  checkVar "WL_PORT"
  checkVar "PS_ENV"
}

function setConfigProperties() {
  echoDebug "Setting configuration properties for pswls"
  export WLCONFIGBASE="${HOME}/.pswls"
  export WLCONFIGDIR="${WLCONFIGBASE}/${PS_ENV}"
  export WLCONFIGFILE="${WLCONFIGDIR}/wlconfigfile.secure"
  export WLKEYFILE="${WLCONFIGDIR}/wlkeyfile.secure"
  export WLCONNECTSTRING="t3://${WL_HOST}:${WL_PORT}"
  echoDebug "WLCONFIGBASE is set to ${WLCONFIGBASE}"
  echoDebug "WLCONFIGDIR is set to ${WLCONFIGDIR}"
  echoDebug "WLCONFIGFILE is set to ${WLCONFIGFILE}"
  echoDebug "WLKEYFILE is set to ${WLKEYFILE}"
  echoDebug "WLCONNECTSTRING is set to ${WLCONNECTSTRING}"
}

function setBaseProperties() {
  echoDebug "Setting base properties"
  export WL_HOME="${WL_BASE}/wlserver"
  export COMMON_COMPONENTS_HOME="${SPLIBDIR}/pswls/lib"
  export UTILS_MEM_ARGS="-Xms32m -Xmx1024m -XX:MaxPermSize=256m"
  echoDebug "WL_HOME is set to ${WL_HOME}"
  echoDebug "COMMON_COMPONENTS_HOME is set to ${COMMON_COMPONENTS_HOME}"
  echoDebug "UTILS_MEM_ARGS is set to ${UTILS_MEM_ARGS}"
}

function setWLSTProperties() {
  echoDebug "Setting WLST_PROPERTIES"
  local oracle_home="$WL_HOME"
  export WLST_PROPERTIES="-DORACLE_HOME=${oracle_home} -DCOMMON_COMPONENTS_HOME=${COMMON_COMPONENTS_HOME}"
  echoDebug "WLST_PROPERTIES is set to ${WLST_PROPERTIES}"
}

function sourceWLSEnv() {
  echoDebug "Sourcing setWLSEnv.sh script"
  export WLS_NOT_BRIEF_ENV=true
  # shellcheck disable=1090
  source "${WL_HOME}/server/bin/setWLSEnv.sh"
}

function setJVMArgs() {
  echoDebug "Setting JVM_ARGS"
  export JVM_ARGS="-Dprod.props.file=${WL_HOME}/.product.properties -Djava.security.egd=file:/dev/./urandom ${WLST_PROPERTIES} ${UTILS_MEM_ARGS}"
  echoDebug "JVM_ARGS is set to ${JVM_ARGS}"
}

# Check to see if the authentication directory is there, if not: create it
function createWLConfigDirectory() {
  if [[ ! -d $WLCONFIGDIR ]]; then
    echoInfo "Creating pswls config directory"
    mkdir -p "$WLCONFIGDIR"
    echoInfo "Setting permissions on $WLCONFIGDIR to 0700"
    chmod 0700 "$WLCONFIGDIR"
  else
    echoWarn "$WLCONFIGDIR already exists"
  fi
}

# Make sure that the permissions are set to 0700 on the directory
function validateWLConfigPermissions() {
  # shellcheck disable=2155
  local perm=$(stat -c %a "$WLCONFIGDIR")
  if [[ ${perm} != "700" ]]; then
    echoWarn "$WLCONFIGDIR permissions are incorrect"
    echoWarn "Setting permissions on $WLCONFIGDIR to 0700"
    chmod 0700 "$WLCONFIGDIR"
  fi
}

# Check to see if the authentication files exist
function checkWLConfigFilesExist() {
  if [[ ! -f $WLCONFIGFILE ]]; then
    echoError "Configuration file ${WLCONFIGFILE} does not exist"
    echoError "Please create one with 'pswls auth'"
    exit 1
  elif [[ ! -f $WLKEYFILE ]]; then
    echoError "Key file ${WLKEYFILE} does not exist"
    echoError "Please create one with 'pswls auth'"
    exit 1
  fi
}

# Make sure we're not overwriting already existing configuration files
function checkDuplicateWLConfigFiles() {
  if [[ -f $WLCONFIGFILE ]]; then
    echoError "Configuration file ${WLCONFIGFILE} already exists"
    exit 1
  elif [[ -f $WLKEYFILE ]]; then
    echoError "Key file ${WLKEYFILE} already exists"
    exit 1
  fi
}

function executeWLSTScript() {
  local script_file="${SPLIBDIR}/wlst/$1"
  local config_file="$2"
  local key_file="$3"
  local connect_string="$4"
  eval "${JAVA_HOME}/bin/java" "${JVM_ARGS}" weblogic.WLST -skipWLSModuleScanning "${script_file}" "${config_file}" "${key_file}" "${connect_string}"
}

function executeWLSTScriptConsole() {
  local script_file="${SPLIBDIR}/wlst/$1"
  local config_file="$2"
  local key_file="$3"
  local connect_string="$4"
  eval "${JAVA_HOME}/bin/java" "${JVM_ARGS}" weblogic.WLST -skipWLSModuleScanning -i "${script_file}" "${config_file}" "${key_file}" "${connect_string}"
}
