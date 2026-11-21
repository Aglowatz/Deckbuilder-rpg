THE WAYWARD PATH  -  version 1.0
================================

A single-player deckbuilding role-playing game by Alex Glowatz.
Free to play. Thank you for downloading it!


HOW TO START
------------
1. Unzip the whole folder somewhere you can write to (Desktop or Documents, not Program Files).
   Do not run the game from inside the zip.
2. Double-click TheWaywardPath.exe.
   Windows may say "Windows protected your PC": click "More info", then "Run anyway".
   (The game is not signed with a paid certificate; that is all the message means.)

The first start takes a little longer while your graphics card prepares its shaders.
Loading a big place for the first time takes several seconds behind a loading screen. That is normal.

You need: Windows 10 or 11 (64-bit), 4 GB of RAM (8 GB is better), about 1 GB of free disk space,
and graphics that can do DirectX 12 or Vulkan (integrated graphics from 2017 or later are fine).


CONTROLS
--------
Everything can be played with the mouse and keyboard or with a controller.
Every key can be changed in Settings > Controls.

                                Keyboard / mouse                 Controller
  Move                          WASD or arrow keys               left stick
  Sprint                        Shift                            click the left stick
  Talk / use / enter            E or Space (or click)            A
  Map                           M                                View / Back
  Quest log                     J                                D-pad
  Deck / Character / Packs      B / C / P                        X / Y / D-pad
  Wardrobe                      T                                D-pad
  Camera: next preset           V                                click the right stick
  Camera: zoom                  F                                -
  Pause menu and settings       Escape                           Start
  In a battle: play a card      drag it onto the board,          choose it and press A
                                or click it and then its target
  In a battle: look at a card   right-click (or hover)           Y
  In a battle: next / end turn  Space                            X
  In a dungeon: its rules       R                                Y

The pause menu has the Glossary (every keyword and rule), the quest log, Feats and the settings.
Settings > Text has a Text size switch (Normal, Large, Larger) for dialogue, cards, tooltips and menus.
Settings > Accessibility has Reduce motion, Reduce screen shake, Reduce flashing and Path symbols for
colour-blind players (on by default).


YOUR SAVES
----------
The game saves by itself (a quill appears bottom right) after battles, when you change places and when a
quest moves on. You can also save by hand in one of five slots from the pause menu. There are three
separate campaigns.

Your saves are here (paste this into the address bar of a File Explorer window and press Enter):

    %APPDATA%\Deckbuilder-RPG\saves\

To back them up, copy that folder. To move to another PC, copy it to the same place there.
Saves from earlier test versions carry over.
If you quit in the middle of a dungeon, that dungeon starts again from its entrance.


IF THE GAME WILL NOT START, CRASHES OR FREEZES
----------------------------------------------
Next to the game are five small start files. Try them in this order:

  Start (Safe Mode).bat      Low graphics with the heavy effects off. Try this first.
                             You can raise the graphics again in Settings.
  Start (Vulkan).bat         Uses the Vulkan renderer instead of DirectX 12.
  Start (Compatibility).bat  For older graphics chips: a simpler OpenGL renderer in Safe Mode.
                             It looks plainer and loads more slowly.
  Start (DirectX 12).bat     Uses DirectX 12 (what the normal start uses).
  Start (Verbose Log).bat    Writes a much more detailed log. Only if you are asked for one.

The game also protects itself: if it did not start or load properly last time, the next start is in
Safe Mode on its own, and the title screen says so.

If the game is slow: Settings > Display > Graphics quality > Low-end (weak PCs choose it by themselves
on the first start).


HOW TO REPORT A BUG
-------------------
Press F8 at any time in the game (it works on every screen, even during loading or dialogue).
Write what happened and press Send. That makes a report folder with a screenshot, your save and the
game's logs. "Open feedback folder" shows where it went:

    %APPDATA%\Deckbuilder-RPG\feedback\

Zip that report folder and send it through the game's page on itch.io (the comments, or the contact
named there).

If the game froze or crashed and F8 was not possible, send these files instead, copied right after the
problem (each start of the game moves the old log along; the last five runs are kept):

    %APPDATA%\Deckbuilder-RPG\logs\wayward.log      (this run)
    %APPDATA%\Deckbuilder-RPG\logs\wayward.1.log    (the run before)
    %APPDATA%\Deckbuilder-RPG\logs\godot.log        (the engine's log)

It helps to say: your PC (model, graphics card), what you did just before the problem, and which start
file you used.


ABOUT THE ART, MUSIC AND WRITING
--------------------------------
The Wayward Path was made by one person with AI tools. The art and the music were made with AI tools,
directed and curated by the creator. The game's design and writing are the creator's, with AI assistance.
The full credits and licences are in the game: title menu > Credits.

Thank you for playing!
