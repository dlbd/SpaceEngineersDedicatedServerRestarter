@echo off

rem Important: never edit this file while the script is running.

rem -----------------------------------
rem SETTINGS START HERE
rem -----------------------------------

rem Save file date check frequency in seconds.
rem Should be at least a few minutes more than the autosave interval.
set SAVE_CHECK_FREQ=420

rem Dedicated server start command.
set SERVER_COMMAND="C:\Program Files (x86)\Steam\steamapps\common\SpaceEngineers\Tools\DedicatedServer\DedicatedServer64\SpaceEngineersDedicated.exe" -console

rem Dedicated server starting directory.
set SERVER_START_IN="C:\Program Files (x86)\Steam\steamapps\common\SpaceEngineers\Tools\DedicatedServer\DedicatedServer64\"

rem Delay after the server is started in seconds.
set DELAY_AFTER_START=120

rem Delay after the server is killed in seconds.
set DELAY_AFTER_KILL=10

rem Server executable (just the .exe file).
set SERVER_EXE=SpaceEngineersDedicated.exe

rem Save file directory.
set SAVE_DIR="%APPDATA%\SpaceEngineersDedicated\Saves\Created 2015-12-01 1258"

rem -----------------------------------
rem SETTINGS END HERE
rem -----------------------------------

:loop

:get_mtime
if defined CUR_MTIME set PREV_MTIME=%CUR_MTIME%

for %%a in (%SAVE_DIR%) do set CUR_MTIME=%%~ta
if not defined CUR_MTIME echo Failed to get save directory modification time. Does it exist? & goto :error

:check_if_is_running
tasklist /fo csv | findstr /i %SERVER_EXE% > nul
if %ERRORLEVEL% == 0 goto :is_running

:is_not_running
echo %DATE% %TIME% -- The server is not running!
call :start_server || goto :error

:is_running
echo %DATE% %TIME% -- Cur mtime: %CUR_MTIME%, prev: %PREV_MTIME%
if defined JUST_STARTED goto :skip_mtime_comparison

:compare_mtimes
if "%CUR_MTIME%" neq "%PREV_MTIME%" goto :mtimes_ok

:mtimes_not_ok
echo %DATE% %TIME% -- The server appears to have frozen!
call :kill_server
goto :check_if_is_running

:mtimes_ok
:skip_mtime_comparison
set JUST_STARTED=

timeout /t %SAVE_CHECK_FREQ% /nobreak > nul
goto :loop

:error
echo Something went wrong :(
pause
exit /b 1

:start_server
echo Starting the server...
start "" /d %SERVER_START_IN% %SERVER_COMMAND% || exit /b 1
set JUST_STARTED=1
echo Waiting for the server to load...
timeout /t %DELAY_AFTER_START% /nobreak > nul
echo The server is probably running by now.
exit /b 0

:kill_server
echo Killing the server...
taskkill /f /im "%SERVER_EXE%" || (echo Failed to kill the server. & exit /b 1)
echo Waiting for the server to get killed...
timeout /t %DELAY_AFTER_KILL% /nobreak > nul
echo The server is probably killed by now.
exit /b 0
