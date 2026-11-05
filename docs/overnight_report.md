# Overnight Nov 4-5 - report

Brief: `docs/prompts/overnight_nov4.md` (Parts 1-8 + Finish). Tag `pre-overnight-nov4`. Decisions: `docs/overnight_inbox.md` ("Overnight Nov 4-5").
Shots: `docs/overnight_shots/nov5/`. Previous report: `docs/overnight/nov4b/overnight_report_fixes_nov4b.md`. No export.

## Part 1 - the critic's list (docs/review/critic_nov4b.md)

| # | Item | Result | Evidence |
|---|---|---|---|
| 1 | Old Man Mountain | His first talk now says the gate hint himself (4th box: "that gate up on the overlook... opens when the kingdom is whole again"). Any NPC speaks to the NEWEST active quest of theirs first (`Session.quests_active_for`, zone NPCs and Maren), so after "Only the Worthy..." he talks about the shake, not "Spot Gary". | `tests/core/test_overnight_nov5_part1.gd` |
| 2 | Alchemist screen | Chosen jars get a gold border, a fill and "✓ Selected"; the Craft button always reads "Craft — 100 gold, 6 + 6" and, when it can't be pressed, says why on a second line ("Pick two Paths", "Need 4 more Necrocrat essence", "Need 100 gold"). A jar short of essence can be picked so the reason shows. The 16 possible cards now sit in two rows of 8 (one row pushed the whole screen past the right edge). Real craft in play with 18 + 18 essence: both jars show 12 after. | `p1_2_01/03/04_*.png`, `docs/review/play_scripts/nov5_alchemist.txt` |
| 3 | Quest log after Primm | Primm's fall closes every unfinished zone line quietly (no "0/4" left) and starts + tracks "Under the Forest" at once (`Session.settle_postgame_quests`; old saves are settled on the next town visit). A freed zone also finishes its own line without the favour step. Verified through the code a real castle win runs (`resolve_main_dungeon`); the play driver could not get through the Model Room staging into Primm's duel (inbox 1). | `test_beating_primm_in_the_castle_settles_the_quest_log` |
| 4 | Forest hatch | The hatch is at z 34, about 29 m below the clearing's south rim (was ~10 m). The trail is painted dirt with a stone kerb, flagstones, glowing blue mushroom clumps every 3-4 m, two lanterns on posts and a cool fill light; the hatch has a brighter light and a pale beacon shaft. Brambles still block it at the start. | `p1_4_closed/open/trail/hatch.png` |
| 5 | Iron Cave | The Enter popup uses the real name at the entrance. The canyon pylon that stood in front of the crag moved 10 m south. The crag has two ragged tiers, a leaning spire and stepped lumps on its corners instead of one straight block; chalk bucket, plate stack and kettlebell rack at the mouth (the torches, arch and dark recess were already there). | `p1_5_iron_cave.png` |
| 6 | First-duel tip | Sits above the Opening-hand panel, clear of Keep Hand / Mulligan. | `p1_6_first_duel_tip.png` |
| 7 | Rule text | Pump Iron -> **Home Gym** ("yours only"); zone stat rules say "on both sides"; Smuggled Weights no longer repeats the Iron line. Audit of every dungeon fight's pre-fight list (`tools/rules_audit.gd`, 71 fights): renamed the Gainlands debuff Processing Time -> Out of Breath (the D.N.A. dungeon has its own Processing Time), Mortimer's duplicate Red Tape Everywhere -> Paper Mountain, Primm's Royal Guard -> Standing Army, the Doppelganger's Perfect Copy -> Plated Just So, Specimen Conditions (enemies) -> Enhanced Specimens, Drained Strength -> Borrowed Strength; Prize Topiary says it stacks. No contradictions found. | inbox 2 |
| 8 | Nameplates | The plate measures names in capitals, shrinks the font to 20 px, then widens (up to 560 px) before shrinking further. "RIP TEARSON, RIFT TECHNICIAN" shows in full. | `p1_8_rip_nameplate.png`, test |
| 9 | Item slots | A used-up item stays in its slot greyed with a "Used" badge (battle bar and Character page) until something else is equipped there (`PlayerProfile.spent_item_slots`, saved). | test |
| 10 | Never seen in game | Rescue choice + result (button text no longer repeats the boon's description: "Flex's Promise"); a real craft (item 2); Shiro's 3 Gilded packs in the pack inventory; the D.N.A. elevators and lobby with no dialogue. Critic scripts fixed (HOG node 6 + double-click, Craft click, Shiro Continue). Cut-in hints say "E / Click" and the driver's skip handles cut-ins. | `p1_10_*.png` |

## Part 2 - economy and dungeon rules

- **Packs:** General 150, Path 200, Gilded 800 (4x Path, as before), General II 300, Prismatic 1200.
- **Repeat fights** pay the same as the first win.
- **Dungeon clear bonus:** beating a dungeon's boss pays the run's gold again, shown on the boss's Victory screen ("Clear bonus: +X gold").
  To keep the no-grind target, dungeon nodes now pay half (a finished run pays exactly the old amount, an abandoned one half).
- **Quests:** main x1.75, side quests of 3+ steps x1.6, shorter x1.5 (milestones too).
- **No deck changes inside a dungeon:** the Deck button, B on the map and the in-dungeon Deck Station are gone. Cards won go to the
  collection (the tutorial cave still adds its picks to the deck); a card lost in the Descent stays lost.
- **Tri-Path recipes:** 35 tri-Path cards exist and every trio of Paths has some; the "(no tri-Path recipes exist yet)" line was already gone.

Gold study (`docs/balance/gold_economy_nov3.md`, "Overnight Nov 4-5"). The study had never loaded the quests (they counted as 0), so the
"before" column is the Nov 4 economy re-measured with them.

| | Before | After |
|---|---:|---:|
| Earned (no grinding) | 19,159 | **21,189** |
| Items, hats, fees | -1,325 | -1,325 |
| 20 cards | -4,700 | -4,700 |
| Left for gear | 13,134 (5 pieces) | **15,164 (6 pieces)** |

By source after: main 6,415, side quests 2,180, clear bonus 2,165, side-dungeon nodes 1,140, postgame nodes 980, the rest unchanged.

## Part 4 - dialogue rewrite

Full write-up: `docs/dialogue/rewrite_nov5.md`; style guide `docs/dialogue/story_voice_nov5.md`; review sheet **`docs/dialogue/edit_nov5.csv`**.

- 1,178 lines rewritten in 15 story-order chunks (main quests first, then primary characters, side quests, barks), applied as a revertible
  pass; the 15 lines a blind critic preferred in their old form were put back and 4 weak ones fixed.
- Blind critic (100 random changed lines, versions unlabelled): main story new 49 / old 5 (6 ties), side content new 29 / old 10. Averages
  new vs old - main: voice 7.5 vs 6.3, clarity 8.0 vs 7.3, emotion 7.0 vs 6.0, humour 7.2 vs 6.3; side: voice 7.4 vs 6.6, clarity 8.1 vs
  7.3, humour 7.2 vs 6.7.
- Best before/after examples: the table in `docs/dialogue/rewrite_nov5.md`.

## Part 6 - music: the Gainlands quotes

| Cue | What quoted the old march | Now |
|---|---|---|
| MUS-CREDITS | the Gainlands section (bars 22-39, trumpets + horns) | the rock riff and answer, same bars and orchestration |
| MUS-PRIMM-02 | the Gainlands section of the medley (trumpet + horn, violins) | rock riff / answer |
| MUS-PRIMM-03 | the Gainlands head in D | rock riff head |
| MUS-PRIMM-DEFEAT | the Gainlands head on horn | rock riff head |
| MUS-QUEST-ROLLO | the whole theme (horn, then violins) | rock riff / answer |
| MUS-REUNION | a horn call from the theme's head | rock riff head |
| MUS-THRONE | the head on trumpet | rock riff head |
| MUS-CAP-RESTORED | the head in D | rock riff head |
| MUS-CAP-RIFT | its own copy of the march, bent to D minor | rock riff / answer, bent the same way |

Method: the march melody (`scores/_fork_b.py` GAIN_THEME, CAP-RIFT's BEEF) was replaced by 16 bars of the rock material (`lib/rock.py`
MOTIF_RESOLVED / ANSWER_MAJOR, up a tritone into the march's Bb major and harmony), so each cue keeps its own instruments, key and length.
All nine re-rendered at q6 one at a time, every check OK (-20.0 LUFS), delivered (`deliver_part.sh`), music smoke OK. FOREST, DECK and
TUT-EXP already quote the rock riff's melody (it is the Crossroads motif) and were left alone (inbox 6).

## Part 7 - art list and import prep

- `docs/art/art_needed_nov4.csv`: every row now has its target id(s), game file, size and format (38 rows). New rows: SPR-TOWNSFOLK-A/B/C
  (a human market regular, a badger labourer, an old hare; idle + walk in FRONT / FRONTSIDE / SIDE / BACK, talk, REF) with a portrait each
  (NPC-TOWNSFOLK-A/B/C), and MAP-S-GALLERY with a full map description. Sprite batch rows NT-TOWNSFOLK-A/B/C give the importer their height.
- `docs/art/import_nov5_ready.md`: for each id, the Approved_* folder and filename, and the command.
- Node guide for the map: `docs/art/paintover_inputs/gallery_map_guide.png` (1536 x 1024, `tools/art/gallery_map_guide.py`).
