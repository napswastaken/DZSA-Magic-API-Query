@ECHO OFF
REM ***********************************************************************
REM Description: This script prevents DZSA and Magic Launcher from removing servers by querying the server list every 10 minutes.
REM Copyright: Copyright (C) 2023 Nick Shepherd
REM License: General Public License v3.0
REM Version: 1.0
REM ***********************************************************************

REM Make sure to set the SERVERIP, QUERYPORT & WEBHOOK_URL
SET SERVERIP=
SET QUERYPORT=

:START
REM Query DZSA API
FOR /F "tokens=*" %%i IN ('powershell.exe -Command "(new-object System.Net.WebClient).DownloadString('http://dayzsalauncher.com/api/v1/query/%SERVERIP%/%QUERYPORT%')"') DO (
    SET "API_RESPONSE=%%i"
)
FOR /F "tokens=1-3 delims= " %%a IN ('powershell.exe -Command "Get-Date -Format 'yyyy-MM-dd HH:mm:ss'"') DO (
    SET "DATETIME=%%a %%b %%c"
)

ECHO Querying Server %SERVERIP%:%QUERYPORT%
ECHO API Response: %API_RESPONSE%
ECHO Query DateTime: %DATETIME%

REM Query Magic Launcher API
FOR /F "tokens=*" %%j IN ('powershell.exe -Command "(new-object System.Net.WebClient).DownloadString('https://api.dayzmagiclauncher.com/servers/%SERVERIP%:%QUERYPORT%')"') DO (
    SET "MAGIC_API_RESPONSE=%%j"
)
SET "JSON={\"content\":\"[Development] Magic Launcher API queried at %DATETIME%\"}"


REM Clear console, query again in 10 minutes.
TIMEOUT 3600
cls
GOTO START
