# The Wayward Path 1.0.0-rc4 (2026-11-11) - release candidate 4 for playtesters

Windows build: `builds/TheWaywardPath-v1.0.0-rc4-windows.zip` (size: see the overnight report), next to the RC3 zip. Release smoke on the
exported pack and the exported-build checklist (fresh settings, carried settings, Low-end quality): see the overnight report's Part 6.
Unzip the whole folder somewhere you can write to (Desktop or Documents, not Program Files) and run `TheWaywardPath.exe`. If Windows says
"Windows protected your PC", click "More info", then "Run anyway". `README_PLAYTEST.txt` in the folder explains the start files. **Saves carry
over** from RC3 and every earlier build.

## What changed since RC3

- **The main quest says what opens the way.** Each zone's dungeon step names the gate on the road and what opens it in its "Where to go"
  line (J): "Sir Loin's gate on the way wants Old Meatloaf mended - see Basil"; the Dump's stream and barricade; the Gainlands' and the
  D.N.A.'s open roads. Once the gate is open the line says so. In the D.N.A. the Hall's door is marked from arrival: the favour is
  recommended, not required. Mend the Meatloaf says it is needed for the gate.
- **No roamer camps a door.** Every wandering enemy keeps at least 10 m (plus its patrol) from every dungeon door, gate and zone exit, in
  every zone; the Gelatin Sentinel that sat on the Test Kitchen's door moved.
- **Token swarms stack.** Identical tokens on the battlefield (a boss's seven Sashimi Weenies) share one card with an "x7" count; an
  attacker, a blocker or a hurt one steps out on its own. Nothing else on the board moved.
- **"Setting Up" has words during the fight:** "Setting Up - attacks start Turn 3" beside the hourglass in the rules row, and the turn panel
  keeps its countdown.
- **Toasts** last at most 6 s and a click dismisses them; the "has a favour to ask" hint goes once you accept the favour.
- **E prefers the person with a quest** over a plaque, a sign or a prop in reach (never over a door or an exit).
- **"Point me to..."** lists the goals first, then the places in alphabetical order, the same every time.
- **Escape** closes the top pop-up (a reward or quest-complete box: Continue) or advances the conversation first; the pause menu opens only
  when nothing else is open.
- **The Verdant Dump's arrow** follows its route about a second after a pick (it was up to five).
- Fight pacing, the late game and the release checks: see the overnight report (Parts 3, 4 and 6).

## Known issues

- **Difficulty walls for a story-only player:** a player who skips every optional fight reaches the late dungeons 2-5 levels under the expected
  level. The level hints at each door say so. Primm is the hardest fight in the game; tell us if you stall.
- **A loss in a dungeon starts it over** (Primm's Castle too). Your cards and gold are kept.
- **Battle board readability:** played infrastructure shows as small cards beside the hand, and a 10+ card hand wraps into two rows (planned).
- **The Gainlands** use a simpler 3D kit than the painted towns; a texture pass is planned.
- Nurse Hesper's cross is recoloured green in code until her art is redone.

## How to report

Press **F8** in the game (or Pause > Report a Problem): it saves a screenshot, your log and a note. Pause > Open feedback folder shows the files;
send the folder's newest report to the developer. The log is also at `%APPDATA%\Deckbuilder-RPG\logs\wayward.log`.
