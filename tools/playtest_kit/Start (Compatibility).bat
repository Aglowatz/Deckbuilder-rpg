@echo off
rem The Wayward Path with the Compatibility (OpenGL) renderer and Safe Mode - a last resort for older graphics chips when Safe Mode
rem and Vulkan both failed. It looks simpler and loads more slowly.
cd /d "%~dp0"
start "" "TheWaywardPath.exe" --rendering-method gl_compatibility --rendering-driver opengl3 -- --safe-mode
