# The Wayward Path 1.0.0-rc2 (2026-11-10) - release candidate 2 for playtesters

Windows build: `builds/TheWaywardPath-v1.0.0-rc2-windows.zip` (734 MB zipped, about 950 MB unpacked), next to the RC1 zip. Unzip the whole
folder somewhere you can write to (Desktop or Documents, not Program Files) and run `TheWaywardPath.exe`. If Windows says "Windows protected
your PC", click "More info", then "Run anyway". `README_PLAYTEST.txt` in the folder explains the start files. **Saves carry over** from RC1
and every earlier build.

Checked on the exported build itself: the release smoke (17/17: title and version, New Game, F8 report, pause menu, no Dev Menu, save to slot
2 and load), a play-through of the title, Credits, Crosspath, a shop, the Deck Station, the Wardrobe, the Card Packs page, a battle, the pause
menu, Reduce motion and Copy log, and the Low-end preset in Crosspath, the Capital and a battle (30 fps, the Low-end cap, everywhere).

## What changed since RC1

Three fresh-eyes reviews of the exported build (the first hour, the midgame, the late game) found these, and they are fixed:

- **Looks:** the opening forest is about a third brighter with half the blur; the Crosspath fountain is painted stone instead of flat white;
  no speaker cut-out is pasted over a painted story still any more (the painting already shows them).
- **The first fights:** in the Forgotten Cave your draws skip extra infrastructure once you hold five, so you are not stuck with a hand of
  Powerhouses.
- **Clarity:** "End your turn?" asks about the attack when attackers are picked; the map's place list is called "Point me to..." (it points,
  it does not travel); the Path choice keeps your pick described and shows its Resource on hover; the quest tracker says "1 earlier step done"
  instead of "1 done"; the forest hint line mentions M for the map; the skip prompt no longer repeats itself.
- **The final boss:** Primm's first phase opens with 3 Militia (was 4; every tester and bot lost there), and the "Setting Up" countdown now
  matches its rule (it said 3 rounds for a 2-round window). Primm's castle node describes the three duels instead of a gold line.
- **The Endless Buffet:** Basil stepped out from behind the soup fountain and answers from a little further away; the Meatloaf favour says
  where the black truffle and the sea salt are.
- **Settings > Text:** one "Text size" switch (Normal / Large / Larger) for dialogue, cards and tooltips; the separate sizes are still there.
- **Controls:** rebinding can never leave moving, Interact or Pause without a key, and the pause menu always keeps Esc. Every menu and all
  ten minigame screens were walked with a controller only.
- **Title screen:** Enter and the arrow keys work without a mouse (fixed after RC1).

## Known issues

- **Difficulty walls for a story-only player:** a player who skips every optional fight reaches the late dungeons 2-5 levels under the expected
  level. The level hints at each door say so. Primm is easier than in RC1, but still the hardest fight in the game; tell us if you stall.
- **A loss in a dungeon starts it over** (Primm's Castle too). Your cards and gold are kept.
- **Battle board readability:** played infrastructure shows as small cards beside the hand, and a 10+ card hand wraps into two rows (planned).
- **The Gainlands** use a simpler 3D kit than the painted towns; a texture pass is planned.
- Nurse Hesper's cross is recoloured green in code until her art is redone.
- After a lost zone fight, a reviewer saw Old Hob's portrait stay on screen without his dialogue box (not reproduced yet). If it happens to
  you, press F8 right then so the report catches it.

## How to report

Press **F8** in the game (or Pause > Report a Problem): it saves a screenshot, your log and a note. Pause > Open feedback folder shows the files;
send the folder's newest report to the developer. The log is also at `%APPDATA%\Deckbuilder-RPG\logs\wayward.log`.
