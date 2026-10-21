@echo off
rem The Wayward Path with a detailed engine log (bigger log file - only when asked to).
cd /d "%~dp0"
start "" "TheWaywardPath.exe" --verbose
