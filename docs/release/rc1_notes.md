# The Wayward Path 1.0.0-rc1 (2026-11-09) - release candidate for playtesters

Windows build: `builds/TheWaywardPath-v1.0.0-rc1-windows.zip` (736 MB zipped, about 950 MB unpacked). Unzip the whole folder somewhere you
can write to (Desktop or Documents, not Program Files) and run `TheWaywardPath.exe`. If Windows says "Windows protected your PC", click
"More info", then "Run anyway". `README_PLAYTEST.txt` in the folder explains the five start files (Safe Mode, Vulkan, Compatibility...).

This is the candidate for the free itch.io 1.0 release. It was checked on the exported build itself (not the editor): a first launch with no
settings or save, a new game through the opening to the Path choice, Crosspath, a shop, the Deck Station, the Wardrobe, the Card Packs page,
the quiz, a battle, a settings change that survived two restarts, Reduce motion, the Low-end preset, a manual save and Continue, the log
file and Copy log, the Credits page with the AI disclosure, and the (hidden) donation button. **Your saves carry over** from every earlier build.

## What is in it (since v0.5.2, the last build testers had)

- **The whole story plays through on every Path** with real fights (a bot played all four start to postgame on Nov 9). A ship-blocker in
  Primm's Castle, where nested side rooms could strand the party with nothing to click, is fixed.
- **Level hints at every dungeon door and on the map:** "Travellers here are usually around level N", amber when you are two or more levels
  under. Optional fights (roamers, side dungeons, the arena, favours) are where the extra levels come from; nothing in the balance changed.
- **Balance and economy:** max HP 15 -> 30 over the game, bosses open with a two-turn setup window, dungeon first clears pay an XP bonus,
  the no-grind gold curve lands at about 21,000 gold by the end, cheaper crafting, items are single-use in four slots, the Extra Pocket.
- **New content:** the Shattered Gallery (a postgame dungeon behind the cracked mirror), Dex's Cardsharp's Circuit (five matching tables, fair
  targets, a painted felt table) with the Matching Pair prize, Mount Swolympus and the Iron Cave, the Path-ology Lab's south wing, the
  Undercroft arena, the four-lever vault, hidden traits, a Glossary and a Collection Book with a Bestiary.
- **Art:** Batches 11-14 (about 170 images): painted portraits for the last 3D NPCs, every story beat's still, the vendor stalls, zone kit
  pieces, the Capital's statues and levers, the quiz classroom, Dex's table; Sable's redesign; the species-flip portrait variants redone
  (Sable, Tonic, Fenwick, Pip, Brannoch); the Primm phase and Test Kitchen stills at true scale; a new Iron, Feastforge and Hulking Hauler.
- **Music:** the full orchestral score (zone themes, stingers, shop themes, Gainlands hard rock), at the designer's chosen quality.
- **Dialogue:** the main-story read (quotes, continuity, repetition), the designer's edit sheets applied, roamer and vendor barks.
- **Quality of life:** an autosave quill, colour-blind Path symbols on by default, Reduce motion (Settings > Accessibility), Peek before a
  fight, camera angle "Low", Report a Problem (F8), Copy log, a Credits page with every licence and the AI disclosure, "Support the game"
  buttons that stay hidden until a donation link is set.

## Known issues

- **Difficulty walls for a story-only player:** a player who skips every optional fight reaches Primm's Castle and the Shattered Gallery
  2-5 levels under the expected level and will lose there (the bot did, on every Path). The new level hints say so at the door; the fix is
  to take the side content. Tell us if the hint was not enough.
- **Keyboard only at the title screen:** Enter does nothing until a button has the focus (click, or use a controller). In the game itself
  the keyboard works everywhere.
- Nurse Hesper's cap and armband in her portrait and in the epilogue still carry a recoloured (green) cross until the art is redone.
- A cutscene or story still you have seen before is skipped with Esc; on a first viewing Esc asks first.
- The Capital takes 6-9 s to load on an integrated GPU (a loading screen covers it).
- On this 7.4 GB laptop with an integrated GPU the game picks the **Low-end preset** by itself on the first start (30 fps cap, render scale
  0.5). Settings > Display raises it; Medium is recommended for this GPU class.
- The zip is 736 MB (the budget was 750 MB for the pack; the pack is 847 MB because the music is kept at its full quality).

## How to report a bug

1. **In the game: press F8** (Report a Problem) on any screen. Write what happened and press Send: it writes a folder with a screenshot, your
   save and the logs under `%APPDATA%\Deckbuilder-RPG\feedback\` ("Open feedback folder" shows it).
2. **Or copy the log:** pause menu > Settings > Accessibility > **Copy log** puts the last part of the game log on the clipboard; paste it
   into your message. **Open log folder** opens `%APPDATA%\Deckbuilder-RPG\logs\` (`wayward.log` is this run, `wayward.1.log` the one before).
3. Say which start file you used, what you did just before, and your PC (laptop/desktop and graphics card; the log has them too).
4. Send the report folder or the log plus a sentence to the developer (itch.io page comments, or the contact on the page).
