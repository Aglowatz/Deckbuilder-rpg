@echo off
rem The Wayward Path with the Vulkan renderer (try this if the game freezes or crashes with the normal start).
cd /d "%~dp0"
start "" "TheWaywardPath.exe" --rendering-driver vulkan
