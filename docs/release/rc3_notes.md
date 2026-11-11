# The Wayward Path 1.0.0-rc3 (2026-11-11) - release candidate 3 for playtesters

Windows build: `builds/TheWaywardPath-v1.0.0-rc3-windows.zip` (734 MB, the same as RC2), next to the RC2 zip. Release smoke on the exported
pack passed; the exported-build checklist (fresh settings, carried settings, Low-end quality) ran with no script errors.
Unzip the whole folder somewhere you can write to (Desktop or Documents, not Program Files) and run `TheWaywardPath.exe`. If Windows says
"Windows protected your PC", click "More info", then "Run anyway". `README_PLAYTEST.txt` in the folder explains the start files. **Saves carry
over** from RC2 and every earlier build.

## What changed since RC2

- **You always know where to go.** Every step of every active quest marks everything it needs on the map (M), the minimap and the map's
  "Point me to..." list - each item to pick up, each person, each place, each enemy - and drops each marker as it is done. The tracked quest's
  markers stand in the world as chevrons and the arrow points at the nearest. The way to each main dungeon is marked through its gate: Sir
  Loin's gate in the Endless Buffet (Sir Loin and Basil now say where the sea salt and the black truffle are) and the stables and the junk
  barricade on the Verdant Dump's stairs.
- **Nobody stands behind a prop.** A probe checks every talking NPC from the default and the Low camera; Basil, Tarragon, Madame Mirepoix,
  Billie Muckfoot, Dex in the Dump, Kestrel and a Capital citizen moved, or their props did. A prop between the camera and the person you can
  talk to dissolves. With nobody in reach, E walks you to the nearest person in view and talks to them.
- **The arrows follow the road.** The goal arrow and the "Point me to..." arrow point along a walkable route - round the Gainlands' plateau
  wall, across the Gravy River only where a ferry runs, across the Dump's stream only at a bridge - and when a shut gate, an ungrown bridge or a
  barricade is the only way, they lead you to it (the sign there says what opens it). The map draws the route as a dotted line (white for
  your pick, gold for the tracked goal), and a waypoint on screen shows a small arrow of its own. Escape closes the list and the map together.
- **The map:** landmarks are named first; minor names hide on a small map and show on hover; the "Point me to..." list opens over the map,
  never over the legend, with one row per goal name ("A hidden stash (any) (one of 14)") and the area each goal stands in; the legend has one
  line per quest goal. A side quest you already hold keeps the tracker when you accept another.
- **The Dump's first crossing** is spelled out: the main line marks the Magic Bean by the stream and the West Sprout Mound until a bridge is
  grown; the Centre Bridge sign and Moss Mulligan say so too. Sir Loin tells you to report to Basil once Old Meatloaf walks.
- **No more white sheets:** steam and mist fade before they reach the camera.
- **Turns count both players.** The battle shows "Turn N" (both players have gone) with "Your turn" / "Enemy's turn" under it; the log, the
  boss "Setting Up" window ("they can attack from turn 3"), the result lines and the glossary agree. Cards say "until the end of your turn" (a
  trap that fires on the enemy's turn: "the enemy's turn"). Nothing happens at a different moment than before.
- **Hand cards show this fight's numbers:** under Primm's "every unit is a 3/3" your hand says 3/3; a cost change or a zone rule shows too,
  green when better and red when worse; the preview on the left says the printed values.
- **Defeat text:** a dungeon defeat says plainly that the dungeon starts over from its first room and that the cards and gold you won are kept.
- **Rewards:** fights inside dungeons pay 50 % more gold and XP; every dungeon's completion reward is 20 % smaller.
- **New equipment:** the Hall Pass Slippers (Boots), 500 gold at Madame Mirepoix's in the Endless Buffet - roaming troublemakers and the
  world's hazards (bumps, rifts, gravy, pits, falls) can't hurt you outside battle. "Paperwork says you're excused."

## Known issues

- **Difficulty walls for a story-only player:** a player who skips every optional fight reaches the late dungeons 2-5 levels under the expected
  level. The level hints at each door say so. Primm is the hardest fight in the game; tell us if you stall.
- **A loss in a dungeon starts it over** (Primm's Castle too). Your cards and gold are kept.
- **Battle board readability:** played infrastructure shows as small cards beside the hand, and a 10+ card hand wraps into two rows (planned).
- **The Gainlands** use a simpler 3D kit than the painted towns; a texture pass is planned.
- Escape during a conversation opens the pause menu (press Escape again).
- Nurse Hesper's cross is recoloured green in code until her art is redone.

## How to report

Press **F8** in the game (or Pause > Report a Problem): it saves a screenshot, your log and a note. Pause > Open feedback folder shows the files;
send the folder's newest report to the developer. The log is also at `%APPDATA%\Deckbuilder-RPG\logs\wayward.log`.
