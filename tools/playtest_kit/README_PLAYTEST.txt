THE WAYWARD PATH - PLAYTEST BUILD
=================================

Thank you for testing! Your saves from earlier versions carry over.


HOW TO START
------------
1. Unzip the whole folder somewhere you can write to (Desktop or Documents - not Program Files).
2. Double-click TheWaywardPath.exe.
   Windows may say "Windows protected your PC": click "More info", then "Run anyway".

The first start can take a little longer while the graphics card prepares its shaders.
Loading Crosspath for the first time takes several seconds behind a loading screen - that is normal.


IF IT CRASHES OR FREEZES - THE START FILES
------------------------------------------
Next to the game are five small start files. Try them in this order:

  Start (Safe Mode).bat     Low graphics with the heavy effects off. Use this first if the game
                            crashes or freezes. You can raise the graphics again in Settings.
  Start (Vulkan).bat        Uses the Vulkan renderer instead of DirectX 12. Try this if Safe Mode
                            did not help.
  Start (Compatibility).bat Last resort for older graphics chips: a simpler OpenGL renderer in
                            Safe Mode. It looks plainer and loads more slowly.
  Start (DirectX 12).bat    Uses DirectX 12 (what the normal start uses).
  Start (Verbose Log).bat   Writes a much more detailed log. Only when we ask for it.

The game also protects itself: if it did not start or load properly last time, the next start
is in Safe Mode on its own, and the title screen says so.


REPORTING A PROBLEM
-------------------
Press F8 at any time in the game (it works on every screen, even during loading or dialogue).
Write what happened, and press Send. This makes a report folder with a screenshot, your save and
the game's logs. "Open feedback folder" shows where it went.

Report folders are here:
    %APPDATA%\Deckbuilder-RPG\feedback\
(paste that into the address bar of a File Explorer window and press Enter)


IF THE GAME FROZE OR CRASHED (F8 was not possible)
--------------------------------------------------
Please send us these files - they say what the game was doing when it stopped:
    %APPDATA%\Deckbuilder-RPG\logs\wayward.log          (this run)
    %APPDATA%\Deckbuilder-RPG\logs\wayward.1.log        (the run before)
    %APPDATA%\Deckbuilder-RPG\logs\godot.log            (the engine's log)
Copy them right after the problem, before starting the game again more than once
(each start moves the old log along: wayward.1.log, wayward.2.log ... the last 5 runs are kept).


WHAT TO SEND BACK
-----------------
- The report folder(s) from F8, or the log files above.
- Your PC: laptop/desktop model and graphics card (the log has it too).
- What you did just before the problem, and which start file you used.
- A short video helps a lot if you can make one (Windows key + Alt + R records the screen).

Thank you!
