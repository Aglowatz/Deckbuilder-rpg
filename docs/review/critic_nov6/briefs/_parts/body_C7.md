
## Your brief: UI, UX and visual consistency (a screenshot tour)

You are a seasoned UI/UX designer and visual-design reviewer. **You do not need to play for fun or progress: this is a screenshot tour.**
Load the snapshots below and open every screen and menu, at **two window sizes** and in **Low-end mode**:

- `SHOT_RES=1280x720 bash tools/play.sh <script> <run> 480` and `SHOT_RES=1920x1080 bash tools/play.sh <script> <run> 480` (the env
  variable sets the window size; screenshot pixel coordinates then scale with it: at 1280x720 multiply the 1600x900 positions by 0.8, at
  1920x1080 by 1.2 - always check positions with `dump`).
- **Low-end mode**: open Settings (Esc -> Settings, or the town Menu -> Settings), find the graphics preset and choose its Low-end option,
  screenshot the town, a zone and a battle, then set it back to its previous value in the same run (the setting is saved).

Snapshots (start every script with `wait 2`, `dev load <name>`, `wait 8`): `n6_ref_postcave` (early game in the town, level 3),
`n6_midgame` (level 13, two zones freed), `n6_postgame` (after the story: everything unlocked). You may use any `dev` command to reach a
screen quickly (`dev travel`, `dev encounter <name>` to open a battle, `dev travel dungeon <id>` to open a dungeon map, `dev packs <id> <n>`
to have packs to open). Say in the report which screens you could not reach.

Cover, at both sizes: **battle** (hand, board, tooltips, the end screen), **the deck station** (B), **the collection**, **shops** (a
vendor, the pack shop), **the character page** (C), **the map** (M), **the quest log** (J), **dialogue** (a portrait conversation),
**settings** (every tab), **pack opening** (P), **a dungeon map** (with fog), **the bestiary** (Menu - Collection Book or Glossary), and
the title screen, pause menu, wardrobe (T), Glossary and Feats.

Look for: text clipping or overflow, unreadable text (size, contrast), inconsistent styles (fonts, buttons, panels, colours that differ
between screens), layouts that break at one size, art that does not match its character (a portrait vs the sprite vs the name), leftover
placeholders (grey boxes, debug text, missing icons, stand-in art), and **keyboard/controller gaps** (a screen you cannot close with Esc,
a button you can only reach with the mouse - try Tab / arrows / Enter on each screen and say what happens).

Budget about 90 minutes of wall clock (hard stop at 110). Plan each run as a script of 30-80 lines; read the screenshots and `play.log`
after every run. If a run goes wrong (a NOT FOUND button, a stuck state), that is itself a finding.
