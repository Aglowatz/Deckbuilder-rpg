@echo off
rem The Wayward Path with the DirectX 12 renderer (the normal start uses it too; this one ignores any renderer the game switched to).
cd /d "%~dp0"
start "" "TheWaywardPath.exe" --rendering-driver d3d12
