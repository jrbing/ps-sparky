@echo off

set PS_HOME=%1
set PS_CFG_HOME=%2
set PS_APP_HOME=%3
set SERVER_TYPE=%4
set COMMAND=%5
set SERVER_DOMAIN=%6

cd %PS_HOME%\appserv
psadmin -%SERVER_TYPE% %COMMAND% -d %SERVER_DOMAIN%
