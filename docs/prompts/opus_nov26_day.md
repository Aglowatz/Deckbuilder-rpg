# Nov 26 day: straight map lines, items twice, a rule set for every zone dungeon fight

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path"). This run is on Opus. Work without stopping to ask. Log questions under "Nov 26 day" in `docs/overnight_inbox.md` and take the safest choice.

Read first:
- the top of `docs/overnight_report.md` ("Fable Nov 25 + Nov 25 night");
- `docs/design/encounter_upgrades.md`, `docs/design/encounter_library.md`, `docs/design/postgame_rules.md`.

Run `git status`; commit or discard (say which) anything left over. Tag `pre-nov26`.

## House rules (as before)
- STOP_OVERNIGHT check before each part.
- **One Godot process at a time.** No sub-agents while Godot runs. Use `--min-free=1200` and run test shards in small groups. Run the story bots one after another.
- **Sims** in batches of at most 30 variants, each in a fresh process, with a 20-minute limit per batch.
- **If the owner's Godot editor or game is open** (he may playtest today), run only what fits, or wait.
- Commit and push after each part. No public upload.
- **Shots** go in `docs/overnight_shots/nov26/`. New lines go in `docs/dialogue/nov26_lines.csv` plus `_ids.txt`. New art needs go in `docs/art/batch22.csv`.
- **Owner constraints:**
  - no difficulty setting;
  - the battle board layout stays;
  - no enemy intent shown;
  - no combat pacing changes;
  - each zone keeps its own colour grade;
  - family friendly.
- Every rule, card or quest change gets a test.

## The owner's answers to the Nov 25 inbox
1. **Postgame difficulty: do not change the postgame** (no numbers, rules, hands or heals in the Lab, Gallery, Swolympus or the Warden). Players use equipment and items far better than the sim's player does.
2. The Corrupted Pantry as the room 7 stew (5 HP): **keep**.
3. The castle's stair lines: superseded by Part A (straight lines everywhere).
4. The card art shift: **keep**.
5. The two D.N.A. signs: **leave**.
6. The Cracked Mirror at the top of Grave Row: **keep**.

Also decided: the side dungeons (the three-fight caves and Swolympus) **don't get event rooms**; they stay as encounters. **Batch 22 waits** for more rows.

## Part A — Map lines: back to straight lines (the owner's screenshot of the Forgotten Vault shows bent lines wandering off the walkways)
- **Every dungeon map** draws each link as a **straight line from node to node**. This covers every zone dungeon, mini dungeon, postgame dungeon, Primm's Castle, the Shuffled Halls and the draft maps.
- **Turn off the path-curve system** for drawing (the per-map curves, the stair lines and the fitted walkways), but keep its data files in the repo in case it returns.
- Fog, question marks, the route highlight and controller focus work as before.
- Tests: every link draws as one straight segment between its two nodes, and no curve data is read when drawing.
- Shots of several maps before and after, including the Forgotten Vault, the castle and the Shuffled Halls.

## Part B — Equipment that lets you use items twice
- **The bug:** in drafts, with the equipment that lets items be used twice, the player still has only one copy of each item, so it can be used once per fight.
- **The fix:** while that equipment is worn, **each item can be used twice per fight**. That's two uses of the same item, whether the player owns one copy or more, in drafts and in the main game alike.
  - Show the uses left on the item button (for example "2" then "1").
  - Check every other effect that counts or consumes items still behaves correctly.
- Find every piece of equipment or effect that works this way, and fix them all.
- Tests in a draft fight and a main-game fight. Update the item and equipment text if it's unclear.

## Part C — Every zone dungeon fight gets its own rule set
- **The scope:** every zone dungeon's fights (the four zones' main dungeons and Primm's Castle; not the postgame, which stays as it is), the bosses and mini-bosses included.
- **Each fight gets its own identity:** a fight rule or two, a scripted beat, starting board, extra resources, phases or a twist that suits the room and its zone. Show them in the "Before the fight" panel.
- **Variety:** some nodes may share an effect, but never most of a dungeon. No dungeon should have the same opponent archetype and rule more than twice. Break up the repeats, starting with the House of Gains' three `beefcake_bruisers`.
- **Make the rules challenge how the player built their deck,** using the encounter library's ideas where they fit (curses that can be played around, rewards for certain card types, rules that punish one plan and reward another).
- **Difficulty:** these are main-game fights, so **keep each dungeon's overall difficulty about where it is now.** A rule that makes a fight harder is balanced by something the player can use. Sim each dungeon's whole run before and after (reference decks at the right level for that zone), and keep the clear rates within about 10 points of today. List every fight with its rules and its before/after win rate in `docs/design/zone_fight_rules.md`.
- Spoken lines for new scripted beats go in the dialogue CSV.
- The story bots must stay green: they play these dungeons.
- Shots: the "Before the fight" panel for one fight in each dungeon, plus any new scripted moment.

## Part D — Smaller fixes
1. **Long event-choice hints** run past the panel's edge (for example the Test Kitchen's "Compare the handwriting" and the castle's "Count the reflections"). Shorten every one that overflows, using a `hint:` token or wrapping, and add a test that no choice hint overflows its panel.
2. Anything else in the Nov 25 report's "What's left" that needs no owner decision and no new art.

## Part E — If there's time: a better sim player (no game changes)
The owner says players use equipment and items much better than the sim does. Improve the sim's player only, not the game:
- use items at sensible moments;
- choose equipment that suits its deck;
- use the Silver Reserve and event boons.

Then re-measure the postgame runs (Gallery, Lab, Swolympus, Warden), for information only, and put the before/after in the report. **Change nothing in the postgame.**

## Part F — Checks, build, report
1. All test shards green (small groups); the draft smoke; the walk smokes; the probes; the four story bots one after another.
2. **Scripted plays:**
   - a draft fight using the item-twice equipment;
   - one fight in each zone dungeon showing its new rules;
   - the castle map with straight lines.
3. **Export 1.0.0:** close any other Godot first, then run `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0`, then the exported smoke and the three `play_exported.sh` checks.
4. **`docs/overnight_report.md`,** at the top, under "Nov 26 day":
   - each part done or not, with shots;
   - the zone fight rules table;
   - Part E's numbers;
   - what's left;
   - the zip;
   - the dialogue revert command;
   - the owner's decisions needed (at most 6, each with a recommendation).
5. Commit and push. No public upload.
