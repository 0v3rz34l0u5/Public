@echo off
setlocal
COLOR 0c
echo This was writted on a computer running Windows 10 2003 preview with a dual side-by-side monitor configuration.  
echo After this has run, the taskbar will only be available on the left hand monitor.
:PROMPT
SET /P AREYOUSURE=Do you want to continue? (Y/[N])?
IF /I "%AREYOUSURE%" NEQ "Y" GOTO END
rem This batch file should only change the taskbar to appear on the left of the desktop and then hide itself in desktop mode. This does this by:
rem IF YOU HAVE DUAL MONITORS, THE TASKBAR WILL ONLY BE AVAILABLE ON THE LEFT MONITOR. 
rem Queries the registry HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3 REG_BINARY value of "Settings" and converts it into a variable "settingsHEX".
rem e.g. 30000000FEFFFFFF03040000030000008C0000002800000000000000000000008C000000380400006000000001000000
for /f "tokens=2*" %%a in ('REG QUERY "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" /v Settings' ) do set "settingsHEX=%%~b"
rem Chops off the left 2 bytes (e.g. 30000000FEFFFFFF) and loads it into a new variable "settingsHEXPart1".
set settingsHEXPart1=%settingsHEX:~0,16%
rem Changes the next 2 bits from 02 to 03 which will hide the task bar when in desktop mode and loads it into a new variable "settingsHEXPart2".
set settingsHEXPart2=03
rem Chops off the next the next 6 bits (e.g. 040000) and loads it into a new variable "settingsHEXPart3".
set settingsHEXPart3=%settingsHEX:~16,6%
rem Changes the next 2 bits from [00-left, 01-top, 02-right and 03-bottom (default)] to 00 which will move the task bar to the left of the desktop and loads it into a new variable "settingsHEXPart4".
set settingsHEXPart4=00
rem Chops off the remaining bits (e.g. 0000008C0000002800000000000000000000008C000000380400006000000001000000) from the end and loads it into a new variable "settingsHEXPart5".
set settingsHEXPart5=%settingsHEX:~26%
rem Sticks the all the parts back together with selotape and loads it into a new variable "newSettingsHEX"
rem e.g. 30000000FEFFFFFF02040000000000008C0000002800000000000000000000008C000000380400006000000001000000
set newSettingsHEX=%settingsHEXPart1%%settingsHEXPart2%%settingsHEXPart3%%settingsHEXPart4%%settingsHEXPart5%
rem Re-inserts the code back into the registry
REG ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3 /v Settings /t REG_BINARY /d %newSettingsHEX% /F
rem Shows the taskbar on both monitors
REG ADD HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v MMTaskbarEnabled /t REG_DWORD /d 0 /F
rem Kills the desktop shell
taskkill /f /im explorer.exe
rem Restarts the desktop shell
start explorer.exe
end
