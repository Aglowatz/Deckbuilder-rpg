@echo off
rem The Wayward Path - Safe Mode: Low graphics, fog/bloom/depth of field off, no background loading threads.
cd /d "%~dp0"
start "" "TheWaywardPath.exe" --rendering-driver d3d12 -- --safe-mode
