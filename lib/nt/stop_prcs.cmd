@echo off

set PS_HOME=%1
set PS_CFG_HOME=%2
set PS_APP_HOME=%3
set PS_PRCS_DOMAIN=%4

cd %PS_HOME%\appserv
psadmin -p stop -d %PS_PRCS_DOMAIN%
