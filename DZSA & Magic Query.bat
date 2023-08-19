@ECHO OFF
REM ***********************************************************************
REM Description: This script prevents DZSA and Magic Launcher from removing servers by querying the server list every 10 minutes and sending a message to a Discord webhook with the time and date.
REM Note: Due to JSON formatting limitations in Batch scripting, %API_RESPONSE% cannot be sent to Discord. Therefore, while a message is sent to Discord, it does not guarantee a successful API response.
REM Copyright: Copyright (C) 2023 Nick Shepherd
REM License: General Public License v3.0
REM Version: 1.0
REM ***********************************************************************

REM Make sure to set the SERVERIP, QUERYPORT & WEBHOOK_URL
SET SERVERIP=
SET QUERYPORT=
SET WEBHOOK_URL=

:START
REM Query DZSA API
FOR /F "tokens=*" %%i IN ('powershell.exe -Command "(new-object System.Net.WebClient).DownloadString('http://dayzsalauncher.com/api/v1/query/%SERVERIP%/%QUERYPORT%')"') DO (
    SET "API_RESPONSE=%%i"
)
FOR /F "tokens=1-3 delims= " %%a IN ('powershell.exe -Command "Get-Date -Format 'yyyy-MM-dd HH:mm:ss'"') DO (
    SET "DATETIME=%%a %%b %%c"
)
REM Send DZSA API Alert to Discord Webhook
SET "JSON={\"content\":\"DZSA API queried at %DATETIME%\"}"
curl -H "Content-Type: application/json" -d "%JSON%" %WEBHOOK_URL%

ECHO Querying Server %SERVERIP%:%QUERYPORT%
ECHO API Response: %API_RESPONSE%
ECHO Query DateTime: %DATETIME%

REM Query Magic Launcher API
FOR /F "tokens=*" %%j IN ('powershell.exe -Command "(new-object System.Net.WebClient).DownloadString('https://api.dayzmagiclauncher.com/servers/%SERVERIP%:%QUERYPORT%')"') DO (
    SET "MAGIC_API_RESPONSE=%%j"
)
SET "JSON={\"content\":\"Magic Launcher API queried at %DATETIME%\"}"

REM Send Magic Launcher API Alert to Discord Webhook
curl -H "Content-Type: application/json" -d "%JSON%" %WEBHOOK_URL%
ECHO Magic Launcher API Response: %MAGIC_API_RESPONSE%

REM Clear console, query again in 10 minutes.
TIMEOUT 600
cls
GOTO START
