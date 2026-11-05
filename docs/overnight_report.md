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

## Part 3 - early-game fun check, every Path

Full write-up: `docs/balance/early_game_nov5.md` (tool `tools/early_game_study.gd`: a new save of each Path walked through the economy
timeline as a no-grind player, then its first main dungeon simulated with the starter deck + two Commons, 10 runs per Path).

**Gold:** 520 at the first shop (5 Commons, 7 items or 3 General Packs; goal 2-3), ~800-870 at the own gatekeeper, 1,530-1,890 on reaching
the first main dungeon. Affordability is fine for every Path.

| Path | First dungeon | Level | Before | **After** | HP left |
|---|---|---:|---:|---:|---:|
| Beefcake | The House of Gains | 9 | 50% | **70%** | 17.6 |
| Necrocrat | The Hall of Final Approvals | 8 | (30% with HP-only ease) | **90%** | 18.6 |
| Gourmand | The Test Kitchen | 9 | 40% | **90%** | 16.1 |
| Refusemancer | The Rotheart | 9 | 10% | **70%** | 15.1 |

Goal 65-80%. The cause was zone order: the four zones are tuned for Gainlands -> D.N.A. -> Buffet -> Dump, but every Path starts in its own,
so a Refusemancer met the Rotheart (tuned for level 17) at level 9. **Fix:** `ZoneOrderEase` (`core/zone/zone_order_ease.gd`) - a zone
played earlier than its designed place gets easier foes (HP x1.0 / 0.95 / 0.85 / 0.42 by places early, x0.85 more for the very first zone,
units -1 attack); a freed zone, the Capital and a zone in or after its designed place are untouched. Decks, prices and rewards unchanged.
Necrocrat and Gourmand sit slightly above the band (inbox 9). Tests: `tests/core/test_overnight_nov5_part3.gd`.

## Part 4 - dialogue rewrite

Full write-up: `docs/dialogue/rewrite_nov5.md`; style guide `docs/dialogue/story_voice_nov5.md`; review sheet **`docs/dialogue/edit_nov5.csv`**.

- 1,178 lines rewritten in 15 story-order chunks (main quests first, then primary characters, side quests, barks), applied as a revertible
  pass; the 15 lines a blind critic preferred in their old form were put back and 4 weak ones fixed.
- Blind critic (100 random changed lines, versions unlabelled): main story new 49 / old 5 (6 ties), side content new 29 / old 10. Averages
  new vs old - main: voice 7.5 vs 6.3, clarity 8.0 vs 7.3, emotion 7.0 vs 6.0, humour 7.2 vs 6.3; side: voice 7.4 vs 6.6, clarity 8.1 vs
  7.3, humour 7.2 vs 6.7.
- Before / after (seven of the ten in `docs/dialogue/rewrite_nov5.md`):

| Speaker | Before | After |
|---|---|---|
| The Wanderer, waking | I search for my name. For how I got here. But I find nothing. | I keep reaching for my name, or for how I got here, and there's nothing there at all. |
| Elder Maren, memory 1 | I sense something within you that wasn't there before. I trust the Paths to guide you. | That tune's stayed with you, hasn't it? I can see it on your face. Good. Keep it somewhere safe, dearie, even when it hurts. |
| Agnes Overdue, the vacancy | Even the dead deserve humanity. Our job is to help the lost souls. Following orders be damned: we treat everyone with respect. | Everyone in that queue was somebody, dear, and the dead deserve to be treated as people. No order outranks that, not his and not anyone's. |
| Elowen, Cell 4 | They put me in your cell. My father thinks that's educational. With him it is hard to tell. | They put me in your cell. My father calls it educational, and the worst of it is that he means it. |
| Widow Pell | I cannot bury him. Form 27-B needs Form 27-C, and 27-C needs 27-B. He has waited in his chair for three years. | And I can't bury him. Form 27-B needs a 27-C, and the 27-C needs a 27-B, so he's still in his chair, waiting, the way he always used to wait for me. |
| Chef Gravois, freed | The simmer let go. The sauce let go. Plain bread. No sauce. I could weep. I am weeping. | The sauce has let go of me. Is that plain bread, with no sauce on it at all? I could weep. In fact, I am weeping. |
| A freed citizen | He was not kind. He was afraid. I think both can be true. | He wasn't kind, he was afraid, and for ten years none of us could tell the difference. |


## Part 5 - The Shattered Gallery (postgame dungeon)

Design and sim: `docs/design/shattered_gallery.md`; code `core/dungeon/shattered_gallery.gd`; tests `tests/core/dungeon/test_shattered_gallery.gd`.

- **Entry:** after Primm, a cracked mirror by the castle door (primitives, cold light) and Wren's side quest "Cracks in the Glass". Looking
  into it unlocks the dungeon; it runs on the Capital's HP with **Silver Reserve** (+40 max life inside) and returns to the Capital.
- **13 nodes, three wings:** seven **Echoes** of beaten bosses (Quota, Clench, Plume, Mortimer, the Doppelganger, Clipwell, the Rotheart -
  their own decks, 18-26 HP and one twisted rule each), three costly events, one optional paid rest, and **The Perfect Copy**: your current
  deck, your max HP + 20, one extra card a turn, your own face through a silver shader.
- **Stacking wing rules:** Silvered (enemy units +1/+0, from node 2), Reflected Order (your first card each turn costs 1 more, from node 5),
  Perfect Form (your first unit each turn is copied for the enemy, nodes 9-12; new modifier `MIRROR_FIRST_UNIT`).
- **Look and sound with no new assets:** Echo plates are their originals' Bestiary pictures through `mirror_tint.gdshader`; the castle map
  and board stand in until MAP-S-GALLERY exists; the castle and Primm cues play through a detuned mirror chorus on the Music bus.
- **Rewards:** first clear 1,500 gold, 6 essence of every Path, hidden feat **Through the Glass**, and the **Mirrored card finish** (a
  silver sheen you toggle per card in the Collection Book). Repeats: side-dungeon gold, a Prismatic Pack, the clear bonus.

**Sim** (reference deck of each Path at level 26 with gear and items; target: a strong late deck beats the boss 20-35%):

| What | Setting | Player wins |
|---|---|---:|
| The Perfect Copy alone, full HP | all three wing rules, +15 HP | 3% |
| | Silvered + Reflected Order, +20 HP (**kept**) | **51%** (Beefcake 40, Gourmand 45, Necrocrat 55, Refusemancer 65) |
| Whole run, one HP pool (events skipped) | first draft | 0% |
| | Echo HP 18-26, Silver Reserve +20, two Echoes eased | 0% (one run reached the Copy) |
| | Silver Reserve +40 (**kept**) | not measured: the host stopped the sim for low memory |

Each Echo alone is beatable (Quota and Clench 100%, Mortimer 94%, Plume 84%, the Rotheart 56%), but each costs a strong deck about 10 HP.
The whole run is a wall by design, maybe too much of one (inbox 8). Knobs: `SILVER_RESERVE`, `PERFECT_COPY_HP_BONUS`, the `WING_*_ON` lists,
the Echo HP in `dungeon_content.json`.

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

### Art import checklist (importer dry run)

Every importer was run once on placeholder PNGs with the exact names of `docs/art/import_nov5_ready.md`, through its `*_SOURCE_DIR`
override (the Drive was never touched). Each run's outputs and manifest changes were removed afterwards, along with the placeholders.

| Importer | Placeholders | Result | Fix made tonight |
|---|---|---|---|
| Portraits (`import_portraits.sh`) | 10 (NPC-FLEX_REVEAL, CUT-FLEX, NPC-TOWNSFOLK, -A/-B/-C, GYM-ATTENDANT, BRISKET, SIR-LOIN, CAPITAL-GUARD) | all 10 picked up | `Portraits.EXTRA_PORTRAITS` lists the new ids |
| NPC sprites (`world_test_import.gd --npcs`) | 38 (FLEX-FREED, ROLLO, TOWNSFOLK-A/B/C) | all cut and scaled; townsfolk 21 frames, walks FRONT/FRONTSIDE/SIDE/BACK | the 8 FLEX-FREED and ROLLO files matched no batch row: rows **NS-FLEX-FREED** and **NS-ROLLO** added to `npc_sprite_batch.csv` |
| Key art (`import_key_art.sh`) | STORY-CLENCH-THRONE | matched no ID at first | row added to `logo_title_art.csv`; wired behind the flex cutscene's beats 1-2 (`StoryStills.CLENCH_THRONE`, icon stage until the file exists) |
| Bestiary (`import_bestiary.sh`) | 5 BST ids | all 5 picked up; 99 of 99 Bestiary ids would have a picture | - |
| Maps (`import_maps.sh`) | MAP-S-GALLERY | picked up | - (the castle stand-in drops out when the real file exists) |
| Opening Forest kit (`import_zone_kit.sh openingforest --only=`) | OF-PROP-BRAMBLES | matched no row at first | row added to `openingforest_kit.csv`; `StartingAreaBuilder._build_brambles` now puts two painted cards in the gap once it exists (the walls stay the same; tests pass both ways) |
| Gainlands kit (`import_zone_kit.sh gainlands --only=`) | GAIN-HERO-IRON-CRAG | matched no row at first | row added to `gainlands_kit.csv`. It is a CONCEPT row, so it lands in `docs/art/zone_kits/gainlands/concepts/` as the reference for the crag model; the target path in the art list was corrected |
| UI art | UI-BG-DECKBUILDER | not run: the id already exists in the game and the run would overwrite it | - |

Gotcha: the key art, bestiary and map importers rewrite their manifest CSV from the source folder alone, so a run on a partial folder
empties those manifests. Restore them after any test run.

## Part 8 - fresh critic playthrough

A no-context critic played a new save from a hard-linked HEAD worktree (`/c/Dev/wp_critic`), with no dev wins, levels or gold. Report:
**`docs/review/fresh_eyes_early_nov5.md`**, with 17 screenshots in `docs/review/fresh_eyes_early_nov5/`. It picked **Necrocrat** and
**never got out of the tutorial cave** in about 80 minutes:
- it lost twice (to Hollow Stalker and to the Hollow Warden), and each loss sent it back to the bedroll with the cave reset;
- two more runs stalled on input: the Shrine popup ignored E/Space, and the boss node seemed to need a second click.

So Tilly, Meet the Merchants, the shops, the road, the D.N.A. and its first dungeon went unreviewed. Gold reached 240 with no shop in
reach. No SCRIPT ERROR in any run.

**Scores:** fun 5, clarity 5, difficulty 4 (too hard for a tutorial), text 7 ("Even in death, he files."). The art and the defeat recap
("What beat you") were its highlights.

| # | Critic's issue | Done tonight |
|---|---|---|
| 1 | The cave is too hard, and a loss restarts it from the bedroll | **Fixed:** a lost fight in the intro trial no longer ends the run. You come round at full HP on the map, the fight stays open, and the defeat panel says "Try this fight again - the cards and gold you won are kept" (`Session.tutorial_retry_on_loss`). The decks are not softened (inbox 10). |
| 2 | Popups ignore E/Space; the Shrine has no exit; E at the Well gambles a card | **Fixed:** the Shrine's Rest / Continue take E / Enter / Space / pad A and the focus. At the Well, a confirm press now means "Leave it" until the test is taken; Reveal needs a click or the pad's focus. |
| 3 | E at the cave arch needs 2-3 presses | **Fixed (cause found):** the arch is at the floor's edge, so the treeline self-talk fired there, and its nudge "back toward the cave" pushed the hero out of the arch's reach. The E then only replayed the bubble. No self-talk within 3.2 m of the arch now. |
| 4 | Enemy HP "3" next to a bar a fifth full | **Fixed:** the cave's 3-HP foes have a max HP of 3 (`PlayerSetup.max_hp_cap`), so the bar starts full (and they cannot heal past 3). |
| 5 | Path choice cards are too small to read | logged (inbox 11) |
| 6 | The boss node "needs two clicks" | One click always went; the hover hint said "Click again or press E to go", which reads as two clicks. It now says "Click it or press E to go." A swallowed first click was not reproduced (inbox 11). |
| 7 | Grey untextured rocks in front of the bedroll | logged (inbox 11) |
| 8 | The turn counter counts both sides | **Fixed:** the battle shows rounds ("Round 2" on your second turn), and so do the banners and the victory/defeat lines (`BattleHud.round_of`). |
| 9 | The tutorial foes play Gourmand and Refusemancer basics | logged (inbox 11): changing their decks moves the cave's tuned win rate |
| 10 | Long name plates overflow; hand cards cut off; a tip overlaps the phase panel | logged (inbox 11) |

Tests: `tests/core/test_overnight_nov5_part8.gd`.

## Open questions (details in `docs/overnight_inbox.md`, "Overnight Nov 4-5")

1. **Primm's real fight through the driver** stalled in the Model Room staging. Verified through code instead; one manual castle run is
   worth doing (inbox 1).
2. **A dark round object by the D.N.A. lobby's west passage**: unidentified. Keep it or remove it? (inbox 3)
3. **Clear bonus vs node gold:** the nodes pay half and the bonus doubles them back (21,189 earned, 6 gear pieces). Would you rather keep
   the full node gold (~9 pieces) or a 50 % bonus? (inbox 4)
4. **The Shattered Gallery's whole run** is a wall (0 % clears in every measured setting; Silver Reserve +40 is unmeasured). How hard
   should the full run be? (inbox 8)
5. **ZoneOrderEase:** Necrocrat and Gourmand sim at 90 % for their first dungeon, a little over the 65-80 % goal (inbox 9).
6. **The tutorial cave:** losses now retry at full HP. Should the cave decks also be softened? A second critic run starting past the
   cave is needed to review Crosspath through the first dungeon (inbox 10).
7. **The critic's remaining items:** Path choice readability, grey forest rocks, other Paths' basics in the cave, battle layout
   clipping (inbox 11).
8. **Art:** STORY-CLENCH-THRONE, OF-PROP-BRAMBLES and GAIN-HERO-IRON-CRAG were wired or listed tonight. Their sheet rows say
   "Needed" / "Requested" until the art arrives (`docs/art/import_nov5_ready.md`).

## Tests (Finish)

Full sharded GUT (`tools/run_tests.sh --only=tests --size=12`, 341 scripts in 29 shards). **Shards 1-12 ran** (the audio, AI, data,
dungeon, game and quest scripts): 1,448 tests and 3 failures, all from tonight's changes and all fixed and re-run green:
- the feat count is now 41 (Through the Glass);
- Rip's forest tip was reworded by the rewrite;
- the rewrite had dropped Primm's "No order outranks treating people with respect." from `cutscene.primm_p2.2`, so that zone lesson is
  back in the new line (`edit_nov5.csv` updated to match).

**Shards 13-29 did not run.** Claude Code stopped the run for low system memory during shard 13, and its rule is not to restart a
stopped run on my own. Those shards cover the rest of `tests/core` (quests to zone), `tests/ui`, `tests/world` and the root tests. Tonight's
targeted runs covered the scripts touched in those folders (opening forest, story backdrops, the oct31n UX, the part 1-8 test files),
all green. So the brief's "every shard passed once tonight" is **not met**. To finish:
`bash tools/run_tests.sh --only=tests --size=12 --from=13` with nothing else open.
