# Fable Nov 12d - report (2-hour pass: the broken checks, a fresh playtest, the ghost building, edges, RC6)

Brief: `docs/prompts/fable_nov12_2h.md`. Start tag `pre-fable-nov12d`. Questions: `docs/overnight_inbox.md`, "Fable Nov 12d" (7 items).
Shots: `docs/overnight_shots/nov12d/`. One Godot at a time; the one sub-agent (the critic) ran the game itself and nothing of mine ran
beside it. Owner constraints kept: no difficulty setting, the battle board and the menus keep their layout, no new art, Primm's fight
unchanged, nothing uploaded. Ran on Fable 5.2. The Fable Nov 12c report follows below.

## RC6

**RC6 is not built.** Free RAM stayed between 2.07 and 2.15 GB through the ten-minute wait (20:50 to 20:59, nothing of mine running);
the rule was 2.2 GB, so the export was not started. No exported smoke and no `play_exported.sh` check ran. The source is at
`1.0.0-rc6`, tested and pushed. To build it, close Chrome, ChatGPT and anything else heavy, then in Git Bash from
`C:\Dev\Deckbuilder-rpg`, in the foreground:

```
EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0-rc6
bash tools/run_release_smoke_exported.sh
bash tools/export_test_pack.sh
bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_a.txt r1a 480
SUITE_SETTINGS_FILE=_screenshots/exported/settings_play_r1a.cfg bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_b.txt r1b 480
bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_c.txt r1c 480
grep -c "SCRIPT ERROR" _screenshots/exported/play_r1*.log
```

The export takes 4 to 10 minutes ("EXPORT STOPPED" means nothing was replaced); the smoke must print `PASSED`; the last line must print 0
three times.

## One thing to know first: tests were overwriting your campaign-1 autosave

`%APPDATA%\Deckbuilder-RPG\savesutosave.json` (and its `.bak`) was rewritten by test runs today, at 19:59, 20:25 and 20:44, with
test state (level 3, 450 gold, a Crease flag). Twelve test files switch saving back on at the real path. **I cannot tell what was in
that slot before today and cannot recover it**; campaigns 2 and 3 are untouched (Oct 24, Oct 31). I do not think this pass introduced it
(those tests date from Nov 7 on, and every full test run would have done the same), but that is not verified. Fixed from here on: under
a GUT run the default save path is a scratch file. Checked: the twelve files plus the Crease test pass (94 tests) and the autosave's
timestamp did not move. The last full test run was before this guard; the twelve files were re-run after it.

## At a glance

- **The three failing checks all pass.** One real game bug was behind them (Maren's Path talk); the rest was the smokes being out of date.
- **The critic scored clarity 6, fun 6, polish 6, but its report is partial**: it used 9 runs and reached neither the cave's pop-ups nor
  the Black Market screen. Five of its findings are fixed; the rest are in the inbox.
- **The Transit Yards ghost building is gone.** It was a townhouse standing in the draw-distance dissolve.
- **Zone edges: six zones shot, none fixed.** Three have something left (the Dump's two south corners, Crosspath's south band, the
  D.N.A.'s bare apron).
- **Motion: pickups bob.** Chests and per-zone ambient effects already existed.
- **Tests: 3070 / 3072 passed, 0 failing, 2 pending (40 shards, 24 minutes).**

## Part 1 - the three checks

| Check | Result | Game or smoke? |
|---|---|---|
| Opening-hour smoke (`run_playtest_smoke.sh`) | **Passes** | Both, see below |
| Controller smoke, "Y hides the card details" | **Passes** | Smoke (timing) |
| NPC visibility probe, Corwin Bale | **50 / 50** | Game |

**The opening-hour smoke, check by check:**

| Check that failed | Which was wrong | What changed |
|---|---|---|
| "the only active quest is Meet the Merchants" | Smoke | It expects Meet the Merchants and Fragments (Fragments starts at `trial_cleared` since Nov 7). |
| "every merchant met: hand it to Maren" and the seven after it (Maren takes it back, Make It Yours, its banner, the pack, the Packs screen, opening the pack, Make It Yours back, the store room) | Smoke | One cause: since Nov 3-4 the quest has a step "Equip Tilly's Power Wraps", which the smoke never did. It equips them now. |
| "Bertram says enemies roam the edges of town" | Smoke | His line says "the lanes round the edge of town" since the dialogue rewrite. |
| "the Starter Blade and every equipment slot" | Smoke | Since Nov 3-4 the quest ends on equipping the blade. The smoke equips it. |
| The four "main line appears after the armory quest" checks and "the own Path's quest is tracked" | Smoke | Since Nov 7-8 the zone lines start with Maren's Path talk, not with the armory. The smoke checks they wait, then start with the talk. |
| "Maren has the Path talk ready" / "Maren sends the hero to their own Path's zone" | **Game** | Her cave-mouth welcome never set `elder_greeted`. So the report after the armory quest played her first-meeting speech ("Up and walking. Good. I am Elder Maren...", "buy a few cards from Sable"), hours late, and the Path talk needed a second conversation. The welcome sets the flag now; saves made in between are healed when she is next talked to. Inbox 3. |

Also fixed in the game on the way: the opponent's turn logged "AI produced no legal action" when a duel ended while its move was being
announced (harmless, but an error line).

**The controller check** passed on the first run I made and had failed before: the smoke pressed Y while the last card was still
resolving or a once-ever tip held the pad, when the battle cursor rightly ignores it. The smoke waits for the cursor now. The game is
unchanged. The smoke also puts your zoom and camera angle back when it ends.

**Corwin Bale** stood at x 73.5, straight behind the townhouse at x 72 to 77 from both cameras. He stands in the open alley at x 68.5
now (the mirror of Nell Hargreave's spot) and strolls 2 m instead of 3.2 m, so he cannot reach the house.

## Part 2 - the no-context playtest

Report: `docs/review/critic_nov12d/report.md`. Brief: `docs/review/critic_nov12d_brief.md`. Dev build, the play-script driver, 9 runs,
about 22 minutes, 0 script errors in every run.

**Scores: clarity 6, fun 6, polish 6.** The first hour looked finished to it (about 7 for polish); the Capital rougher (about 5).

**What it did not reach** (it lost three runs to the New Game flow and two to its own cave scripts): the shrine, the Hollow Well, the
"Before the fight" panel, the Cave Warden and his closing words, Crosspath, Maren, the Black Market screen, the Transit Yards. **So the
new pop-ups and the Warden's closing words have still not been seen by fresh eyes.**

| # | Its finding | Size | Done? |
|---|---|---|---|
| 1 | "Back out into the wastes." shows on arriving in the Crease | S | **Fixed**: the Crease has its own line (inbox 2) |
| 2 | The Black Market is easy to miss: no name, an identical stall beside it, a small reach | S | **Fixed**: a "Fig Sly - Black Market" label, reach 1.8 m to 2.6 m (inbox 1) |
| 3 | The Crease's east wall fills half the frame; flat cream rectangles hang in the air | M | **Half**: the rectangles were lantern glass, now small amber lanterns. The wall is unchanged |
| 4 | New Game is three decisions before any story | M | Not changed (inbox 5) |
| 5 | Tidy-Bots knock you flat with no warning | M | Not changed (both hits followed debug jumps) |
| 6 | The Capital map is hard to read | M | Not changed |
| 7 | The minimap is a blurry blob | M | Not changed |
| 8 | The wall's faces are plain slabs | L | Not changed (art) |
| 9 | The enemy's name crowds its plate | S | **Fixed**: the name starts 6 px clear of the portrait ring |
| 10 | The Path choice interrupts the Rescuer; the Wanderer's portrait has a hard edge | S | Not changed: the edge is art, the order is the design |
| note | A room out of reach says "Step on it to find out" | S | **Fixed**: "You can't reach it yet: clear a room that leads to it." |

Three of the five S items are fixed, plus the S note and half of one M. Shots: `crease_arrival.jpg`, `crease_fig_label.jpg`,
`crease_black_market.jpg`.

## Part 3 - the visual leftovers

**The Transit Yards ghost building: fixed.** It was the townhouse at x 72 to 77, z 33 to 45, about 48 m from that camera: exactly where
the zone's draw distance ends, so it stood half dissolved for as long as the hero stood there. Pieces 7 m tall or more now draw 1.3
times further and switch without a dissolve. Before: `docs/overnight_shots/nov12c/partc/capital_before_transit_yards_default.jpg`.
After, same camera: `docs/overnight_shots/nov12d/capital_after_transit_yards_default.jpg` and `_low.jpg`.

**Edges of the other zones: shot, not fixed.** A new driver command, `edgeshots <prefix>`, stands the hero near the eight outermost
walkable points of a place and shoots each at the default and the Low camera. Sheets: `docs/overnight_shots/nov12d/edges/<zone>_edges_default.jpg`
and `_low.jpg`, with every single shot beside them. I looked at the default sheets only; the Low sheets are shot but not reviewed.

| Zone | Default camera | Left to do |
|---|---|---|
| The Dump | **A pale wedge at the south-east and south-west corners**: the camera sits inside the ravine's rim and sees the fog through its back | Close the rim from behind or hold the camera in. Worst of the six |
| Crosspath | A violet mist band along the bottom of the frame at the south edge | Rough but reads as a boundary |
| The D.N.A. | Flat grey apron to the horizon outside the offices | Bare, no void |
| The Gainlands | Sea and painted backdrop at all eight points | Nothing (a blank pale board stands on the west islet; not checked what it is) |
| The Buffet | Gravy sea and backdrop at all eight points | Nothing |
| The forest | Closed by trees and rock at all eight points | Nothing |

## Part 4 - motion

- **Pickups bob** (the Buffet's ingredients, the Dump's beans and crates, the Capital's compost, recipe cards and seed jars): a 9 cm
  bob, a slow turn for a single model, a breathing ground ring. Off on Low-end and under Reduce motion. Tested in a unit test; **I did
  not look at one in the game.**
- **Chests already animate open** (the lid swings, a flash of light; `ChestKit.open_animated`, since Oct). Nothing added.
- **Every zone already has an ambient effect** (`AmbientFx`, since Oct 17: dust in the Gainlands, steam in the Buffet, gnats and fluff
  in the Dump, motes and the paper drift in the D.N.A.). Nothing added.

**FPS on Medium after the pass** (this PC, 1600x900; measured with the tall-piece range at 1.45 times, shipped at 1.3 times):

| Place | Medium | Before (Nov 12c) |
|---|---:|---|
| Crosspath | 75.6 | 70.1 |
| The Capital, `perf_run capital_in` | 63.7 | 57.0 |
| The Capital, Transit Yards camera | 60.6 | 65.8 to 69.1 across the cameras |
| The Capital, Gate Plaza / Hungry Quarter / Palace Approach cameras | 64.5 / 62.8 / 66.4 | same range |
| The Buffet / the Dump / the Gainlands | 81.9 / 71.7 / 83.3 | 82.7 / - / - |

Medium holds 60 everywhere measured, but the Capital's cameras lost about 3 to 5 fps to the ghost-building fix (inbox 4).

## Part 5

- **Tests:** 3070 / 3072 passed, 0 failing, 2 pending (40 shards, 24 minutes).
- **Settings on this PC:** Camera angle is 0 (Cinematic, the default) and zoom is 1.5 in `%APPDATA%\Deckbuilder-RPG\settings.cfg`; they already read so when I checked, and I changed nothing by hand. Scripted runs no longer write the camera angle or zoom into your settings (that is how it got
  left on "Low").

## What's left before 1.0.0

1. **RC6 or 1.0.0 itself** (see the top).
2. **Ten minutes of your own play**: a new game through the cave (the pop-ups, the well, the Warden), then the Capital (the manhole,
   the Crease, Fig Sly). The critic did not get there.
3. **Inbox "Fable Nov 12d"**, items 1 to 4: Fig Sly's label, the Crease line, Maren's speech, the tall-piece range.
4. **Fig Sly's portrait** (`V-FIGSLY.png`) and the rest of Batch 15, still not delivered.
5. **The Dump's two south corners** (the pale wedge), if you want it closed before release.
6. The final checklist of the Nov 12c report below still applies.

---

# Fable Nov 12c - report (the owner's fix list, the pop-ups, the Crease, the world pass, RC6)

Brief: `docs/prompts/fable_nov12_fixes.md` (it replaced `fable_nov12_final.md`). Start tag `pre-fable-nov12c`. Questions:
`docs/overnight_inbox.md`, "Fable Nov 12c" (17 items). Shots: `docs/overnight_shots/nov12c/`. One Godot at a time; no sub-agent ran.
Owner constraints kept: no difficulty setting; the battle board and the other menus keep their layout (only the non-combat dungeon
pop-ups and the pre-fight rules panel were redesigned, as opened up); no new art; nothing uploaded. Ran on Fable 5.2. The Fable pass
Nov 11-12 report follows below.

## At a glance

- **Part A (the fix list): all ten items done**, each with tests and shots (table below). A7.1, Fig Sly's portrait, waits for your image.
- **Part B (the pop-ups): done.** Every non-combat room and the "Before the fight" panel are one illustrated card. Gallery below.
- **Part C (the 3D world): about a third done.** Done: contact shadows, the water, the Capital's and the Crease's edges, the marker
  size at the Low camera. **Not done: eight of the twelve items in whole or in part** - see "What was not done".
- **Part D (Batch 15): nothing to import.** `G:/My Drive/Card Game Art/Pending Review/Batch 15/` did not exist at any check (start of
  every part, last at the end). Two rows were added to `docs/art/batch15_nov12.csv` (V-FIGSLY, UI-NODE-BANNER); all 23 stay "To make".
- **Tests: 3065 / 3067 passed, 0 failing, 2 pending** (39 shards, 24 minutes, after Part C).
- **RC6: **not built.** The export needs 3 GB of free RAM by the house rule; this PC had 1.8 to 2.0 GB free through a 15-minute wait (nothing of mine was running), so it was not started. The source is at version 1.0.0-rc6, tested and pushed. The command is under Part E.****
- **Three things found on the way that were not on the list:** the Capital's grey rectangles were a cache bug (not missing art); the
  occlusion fader could leave a wall or a building invisible for the rest of a visit; the east wall and the front wall faded away
  whenever the hero walked beside them. All three are fixed.

## What was not done (read this before the rest)

- **Part C, item 2 (blended ground, less tiling, edge foliage):** not done.
- **Item 4 (map edges and voids):** done for the Capital and the Crease only. The four Path zones, Crosspath and the forest were not
  scanned.
- **Item 5 (stray quads, foreground obstructions):** only the quest markers' size near the lens. No zone-by-zone scan.
- **Item 6 (duplicate and broken sprites):** not done.
- **Item 7 (the Transit Yards ghost buildings):** the fader bug that could leave pieces transparent is fixed, **but the pale building at
  the top left of the Transit Yards view is still there** (`docs/overnight_shots/nov12c/partc/capital_before_transit_yards_default.jpg`).
  The fader is not fading anything at that camera, so it is something else; I did not find what.
- **Item 8 (faceted props), item 9 (the measured scale table), item 10 (hub storytelling clutter):** not done.
- **Item 11 (light):** every zone already had a grade (Crosspath, the forest and the Dump included), so nothing was added there. New
  light sources only in the Crease (nine lantern lights, five crystal glows).
- **Item 12 (the world motion list):** only the Crease's dripping stalactites. No pickup bob, door or chest animation, ambient life or
  castle music escalation.
- **Part E.1, the no-context playtest:** not run as a no-context critic. I drove the real flow with the play-script driver and the
  smokes instead (the well, the Warden's closing line, the first exit, the Crease, a Primm loss and retry) and looked at the shots
  myself. A fresh pair of eyes has not seen this build.
- **Fig Sly's portrait** is unchanged (as instructed, until the image lands).
- **Three checks fail that this pass did not cause and did not fix** (details under Part E): the opening-hour smoke's quest check, the
  controller smoke's "Y hides the card details", and one strolling citizen in the NPC visibility probe.

## Part A - the fix list

| | What | Done | Shots (`docs/overnight_shots/nov12c/`) | Tests |
|---|---|---|---|---|
| A1 | The Hollow Well: "Sacrifice a random card from your deck for the rest of this dungeon: heal 4 HP." | Random pick from the whole dungeon deck; heal 4 capped at max; the card is back after clearing, losing or leaving (`DungeonRun.deck_after_run`); "Leave it"; at full HP the button reads "You're at full HP" and is disabled; at the minimum deck size it says why; once per run; a save taken mid-dungeon holds the whole deck (a run is never saved, so the cave restarts from its mouth). The sacrificed card shows face up with "The well takes **Card Name**. It returns when you leave the cave." | `a1/`, `popups_after/well*` | `tests/core/dungeon/test_hollow_well_offer.gd` (16) |
| A2 | The Cave Warden's closing words show his picture | In the dialogue box with NPC-WARDEN (they were plain text in the "Through the Forgotten Cave" panel); the line that describes him is narration. Audit of every dungeon boss: all others had a speaker and portrait. The four gatekeepers' post-fight lines had the same gap: fixed. Baron Quadzilla, the Restless Cairn and the Store Room Ghosts have no portrait art (inbox 2). | `a2/` | `tests/ui/test_boss_closing_portraits.gd` (4) |
| A3 | Deck copies text | The only player-facing "4 copies" were two loading tips; fixed, plus the progression and essence docs, the designer guidance sheet and code comments. The in-game tooltips already named 3 and the per-level caps (Common 3; Uncommon 2, 3 from level 9; Epic 1, 2 from 12, 3 from 22; Legendary 1, 2 from 18, 3 at 30). The Glossary's Terms tab gained "Copies of a card" with the caps at your level. No itch page text mentioned copies. | - | `tests/core/data/test_copy_rule_text.gd` (3) |
| A4 | First exit from the cave | The hero stands 1.4 m to Maren's left (west), facing the square, and keeps facing it through her welcome. The old spot stood under her eave, so the fader hid her whole house. | `a4/` before and after at the default and Low cameras | `tests/world/test_cave_arrival.gd` (+1: position, facing, no building under either camera's sight line) |
| A5 | Chef Fennel Gravois's Snack | The token's data was already 1/1. It stood as 0/1 because the "zone met early" ease takes 1 attack off his units. Tokens whose numbers a rule or a boss event states now enter with those numbers (`GameState.create_stated_token`). All 44 texts that state a token's numbers match the token. | - | `tests/core/game/test_token_text_stats.gd` (4) |
| A6 | The Capital's floating grey rectangles | A cache bug: the rim's dead trees and rubble are painted cards that came back from the build cache with no material. Fixed at the root. Also fixed: wall sections left invisible by the fader; the east and front walls fading when the hero walks beside them. Added from the kit, on the ridges outside the wall: ruined houses, ash walls, toppled statues, rubble mounds, crystals (`CapitalRimRuins`), and ash ground under the walls. `matscan`: 2 groups before and after (the far apron and one tunnel arch); `groundscan`: 0 offenders before and after. | `a6/before/`, `a6/after/` (17 edge spots x 2 cameras) | `tests/world/test_capital_rim_ruins.gd` (7), `tests/world/test_occlusion_ground.gd` (+2) |
| A7 | Fig Sly's art; the dual-colour dots | The dots are gone from the card face every view draws (hand, board, full size, shops, the Deck Station, the collection, rewards, packs). The Path cost icons stay. **The portrait: nothing changed, no file landed.** | `a7/` (before, after, one card in each view) | `tests/ui/test_multipath_dots.gd` (3) |
| A8 | The Crease | An enclosed cavern (`CapitalCrease`): rock walls on three sides running on past the camera, a 7.6 m rock ceiling, about 100 stalactites (five drip), stalagmites, ten puddles, nine lantern lights, five crystal glows, a second stall and five stacks of painted crates. No sky, no castle. The six black doorways are floor hatches with a lit marker (same shafts); the tunnel is a timbered mouth in the east wall; the ladder stands against the west wall. **Quest:** a new main quest, "Under the Capital", starts and takes the tracker on first arrival in the Capital (inbox 6). **One "Services restored" bar.** NPC visibility probe: Wren, Fig Sly, Hesper and Kestrel pass at both cameras. | `a8/before/`, `a8/after/` (10 spots x 2 cameras + HUD) | `tests/world/test_crease_cavern.gd` (8) |
| A9 | Losing to Primm | "Fight Primm again" (Phase 1, full HP, the leaders' boons given once, earlier rooms kept) or "Leave the castle". Driven for real: a Phase 2 loss, Fight again (Phase 1 at 23 / 23 HP), a loss, Leave (back in the Capital). | `a9/` | `tests/core/dungeon/test_primm_retry.gd` (5) |
| A10 | Inbox 11 (a) and (b) | (a) the castle map shows a room's type once a room leading to it can be reached; (b) every castle fight's three reward cards include an Uncommon or better, the paid reroll too. | `a10/` | `tests/core/dungeon/test_inbox11_nov12.gd` (6) |

## Part B - the pop-ups

One card for every non-combat room and for "Before the fight" (`ui/dungeon/node_card.gd`):

- **Banner:** the dungeon's own painted map, cropped round the room and blurred, under a colour wash per kind and a vignette; the room
  kind's large icon in the middle with a glow and a bob; particles per kind (motes for a shrine, mist for the well, sparkles for
  treasure, embers before a fight). `UI-NODE-BANNER` becomes the base by itself when it lands.
- **Body:** vellum with dark ink inside the gold frame; the kind in small caps over the name; the flavour line in italics, wrapped into
  even lines; what it does as icon rows; "HP 9 → 15" with the heal as a ghost segment on the bar ("already full" at full HP); the cost
  as a chip; a primary and a secondary button with icons. Esc and the pad's B press "Leave it" where leaving is allowed.
- **Motion and sound:** the card scales and fades in over 0.25 s, the banner a beat later; a shimmer crosses the HP bar as it fills; the
  well shows the card it took; existing sounds on open, confirm and close. Still under Reduce motion.
- **Pre-fight panel:** the foe's cut-out (head and shoulders) or Bestiary picture in the banner; a row per rule (icon, name, one line); a
  hidden trait as a "?" row; two columns and a lower banner past five rules. A card taller than the screen gives up banner height.

**Gallery:** `docs/overnight_shots/nov12c/popups_gallery_before_after.jpg` (before and after, side by side);
`popups_before/` and `popups_after/` (the well open, at full HP and after the card is given; the shrine; an event; a rescue; treasure;
the pre-fight panel with 3 rules and with 9) at 1280x720 and 1920x1080; `popups_after_large_text/` at the largest text size.
**Controller:** the buttons take the pad's focus and B leaves (tests in `tests/ui/test_node_card.gd`, 14). I did not take a screenshot
with a controller prompt showing, and the controller smoke does not walk the cave's rooms.

## Part C - the 3D world

| Item | Done? |
|---|---|
| 1 Contact shadows | **Done.** Characters' blobs are darker with a dense core (0.42 -> 0.52 on Low, 0.70 on Medium and High) and a little bigger; every ground prop gets a soft base shade from one MultiMesh per scene (`PropShade`; none on Low-end). |
| 2 Blended ground | Not done. |
| 3 Water | **Done in part.** The shared toon water and the sea plane lean to the sky at a grazing view and the sea has slow ripples; the Capital's fountains use the shared water. The Dump's stream already used it. The town fountain keeps its own shader. |
| 4 Map edges and voids | The Capital (A6) and the Crease (A8) only. |
| 5 Stray quads | Quest markers shrink near the lens. No scan. |
| 6 Sprites | Not done. |
| 7 Ghost buildings | The fader's stuck-transparent bug fixed; the Transit Yards' pale building is still there. |
| 8, 9, 10 | Not done. |
| 11 Light | Grades already existed in every zone; new lights only in the Crease. |
| 12 Motion | The Crease's drips only. |

**FPS after items 1, 3 and the Capital work** (this PC, 1600x900; `docs/perf/runs/n12c_partc.md`, `n12c_partc_cap.md`):

| Place | Medium | Low | Nov 12 before |
|---|---:|---:|---|
| Crosspath | 70.1 | 91.3 | 69 / 91 |
| The Buffet hub | 82.7 | 101.8 | 80 / 99 |
| A battle | 352 | 371 | 354 / 350 |
| The Capital, four paint-over cameras (`tools/capital_fps.sh`) | 65.8 to 69.1 | 82.2 to 84.5 | 64 / 85 |
| The Capital, `tools/perf_run.sh capital_in` | **57.0** | 75.8 | this probe read 58.3 to 61.2 on Nov 3 |

Medium holds 60 at the Capital's paint-over cameras. **The other Capital probe reads 57**, and it read under 60 before this pass on
two of three earlier runs; I could not move it (restricting, merging and unshadowing the new rim ruins changed nothing: 57.0 both times).

## Part D - Batch 15

| File | Status |
|---|---|
| The 21 rows of Nov 12 | To make (the folder never appeared) |
| `V-FIGSLY.png` | To make (row added) |
| `UI-NODE-BANNER.png` | To make, optional (row added) |

## Part E - verify and build

- **Tests:** 3065 / 3067, 0 failing, 2 pending.
- **Driven for real:** the well offer, taken and at full HP; the Warden's closing line; the first exit; the Capital's edges on foot;
  the Crease at ten spots; a Primm loss, retry and leave. 0 script errors in the play runs I checked (the Capital edges and scans, the Crease, the Primm retry, the water shots).
- **Opening-hour smoke (`run_playtest_smoke.sh`): FAILED, not from this pass.** The cave, the arrival 1.4 m from Maren and her welcome
  pass. It then fails "the only active quest is Meet the Merchants" because Fragments is active too; Fragments has started at
  `trial_cleared` since Nov 7 (`QuestDefinitions.story_gate`). Eleven later checks fail after it. I did not fix the smoke or look at
  the later ones one by one.
- **Controller smoke: one check fails** ("Y hides the card details" in the ghost duel); the other pad checks pass.
- **NPC visibility probe (the Capital): 48 of 50 pass**; the two failures are one strolling citizen (Corwin Bale) at both cameras.
- **RC6:** **not built** (free RAM 1.8 to 2.0 GB for 15 minutes; the rule is 3 GB). No exported smoke and no `play_exported.sh`
  check was run on RC6. `project.godot` is at `1.0.0-rc6`, `CHANGELOG.md` and `docs/release/rc6_notes.md` are written. To build it:
  close Chrome, ChatGPT and anything else heavy, then in Git Bash from `C:\Dev\Deckbuilder-rpg`, in the foreground:
  1. `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0-rc6` (4 to 10 minutes; "EXPORT STOPPED" means nothing was replaced);
  2. `bash tools/run_release_smoke_exported.sh` (look for `PASSED`);
  3. `bash tools/export_test_pack.sh`, then
     `bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_a.txt r1a 480`,
     `SUITE_SETTINGS_FILE=_screenshots/exported/settings_play_r1a.cfg bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_b.txt r1b 480`,
     `bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_c.txt r1c 480`;
     `grep -c "SCRIPT ERROR" _screenshots/exported/play_r1*.log` must print 0 three times.
  The zip should come out near RC5's 734 MB: this pass added code and shaders only, no art.

## One thing to check on your PC

The play-script shot runs save the camera angle into your settings: **Settings > Display > Camera angle is on "Low"** now (the shot
scripts end on it; I do not know what it was before this session). The controller smoke had also changed the zoom to 1.3; I set it back to
the default 1.5.

## The final 1.0.0 release checklist

As Nov 11's (in the Overnight Nov 10-11 report below: donation link, version, export, smoke, the three exported checks, the real exe
once, tag, the itch upload, download it back, flip to Public), with these changes:

0. **Read inbox "Fable Nov 12c" first.** Items 5 and 6 (the shafts as floor hatches; the new quest), 13 (the pop-ups' light vellum
   body) and 14 (the shrine can be left) change what players see and were my choices.
1. **Play ten minutes before anything else:** a new game through the cave (the well, the Warden, the first step into Crosspath), then
   a late save in the Capital (the edges outside the wall, the manhole, the Crease, Fig Sly). Nobody but me has looked at this build.
2. **Fig Sly:** when `V-FIGSLY.png` is in Pending Review / Batch 15, say "import portraits" (or run `bash tools/import_portraits.sh`),
   check him in the Crease, commit. Then export.
3. **Export RC6 (or go straight to 1.0.0):** the three numbered commands under Part E above. No RC6 zip exists yet.
4. Set the camera angle back if "Low" is not what you want players' default screenshots to show (it is a per-PC setting, not in the build).
5. Then steps 1 to 10 of Nov 11's list with `1.0.0`.

---

# Fable pass Nov 11-12 - report (visual quality, world consistency, late game)

Brief: `docs/prompts/fable_nov12_visuals.md`. Start tag `pre-fable-nov12`. Questions: `docs/overnight_inbox.md`, "Fable Nov 12" (12 items).
Shots: `docs/overnight_shots/nov12/` (`before/`, `after/`, `part4/`). Gallery: `docs/review/visual_nov12/index.html`. Style bible:
`docs/art/style_bible.md`. One Godot at a time; the three critics (art director before and after, late game) were no-context agents and no
Godot of mine ran while the late-game critic played. Owner constraints kept: no difficulty setting; the battle board and every menu layout
untouched (effects, shaders and colour inside existing elements only); no approved painting repainted or replaced. Ran on Fable 5.2 (the
launch line was pasted into a running session). The Overnight Nov 10-11 report follows below.

## At a glance

- **The art-director score did not move: 6.3 before, 6.2 after** (113 shots each, the same cameras, a fresh no-context critic each time).
  The second critic scored content this pass never touched about half a point lower (dungeon maps 8.2 -> 7.6, Crosspath 7.5 -> 6.9, the
  forest 6.2 -> 5.7), so the two numbers are not on one scale; against that drift the zones that were worked on gained (table below), but
  **the honest reading is: this pass fixed specific named faults, it did not lift the 3D world to the level of the painted layers.** The
  3D world scores 5.4-5.6 in both reports; the painted screens 7.4-7.6. What closes that gap is painted art (Batch 15) and material
  work on a scale this pass did not reach.

  | Group | Before | After | Change | Worked on? |
  |---|---:|---:|---:|---|
  | The D.N.A. | 4.4 | 4.7 | +0.3 | yes (lighting 3.6 -> 4.7) |
  | The Capital after Primm | 5.6 | 5.8 | +0.2 | yes (lighting 4.3 -> 6.8) |
  | The Gainlands | 5.5 | 5.7 | +0.2 | yes |
  | Battles | 7.4 | 7.6 | +0.2 | the tutorial board fix (4.8 -> 7.8) |
  | The Endless Buffet | 5.5 | 5.5 | 0.0 | yes |
  | Screens (UI) | 6.8 | 6.8 | 0.0 | no (layouts are fixed) |
  | The Capital before Primm | 5.8 | 5.4 | -0.4 | a little (wall, camera) |
  | The Verdant Dump | 5.8 | 5.3 | -0.5 | a little (ghost glasshouse) |
  | The Opening Forest | 6.2 | 5.7 | -0.5 | no |
  | Dungeon maps | 8.2 | 7.6 | -0.6 | no |
  | Crosspath | 7.5 | 6.9 | -0.7 | no |
  | **All 113** | **6.3** | **6.2** | -0.1 | |

  (Means of the six criteria per shot, from `docs/review/visual_nov12/scores_before.csv` / `scores_after.csv`.)
- **RC5 is built:** `builds/TheWaywardPath-v1.0.0-rc5-windows.zip`, **734 MB** (RC4: 734 MB; pack 845 MB, 14104 files, every MD5 matches).
  The release smoke on the exported pack **PASSED**; the three exported-build checks ran with **0 SCRIPT ERROR**. Full GUT before the
  export: **2984 / 2987 passed, 1 failing** (a test that pinned the old 97 % fade; fixed after), 2 pending. Not uploaded anywhere.
- **Performance held** (Medium, this PC): Crosspath 72 -> 69 fps, the Buffet hub 85 -> 80, the Capital 63 -> 64 (65 in the freed state),
  a battle 344 -> 354; Low unchanged (91 / 99 / 85 / 350). All inside this laptop's 10 % run-to-run drift; the Capital keeps about 4 fps
  over 60.
- **Late-game critic on RC5: clarity 6, fun 4, polish 6 (old build 5 / 4 / 5; target 7 / 6 / 7) - the target was missed.** It never beat
  Primm's Phase 2 or 3, so it did not see the ending. Part of that was the test driver skipping its turns (fixed; see Part 4.4). Four of
  its small items are fixed **in the source but not in the RC5 zip**: the re-export was stopped by the machine's low-memory guard and
  was not started again. **The zip on disk is the build from 07:59, before those four fixes.** No second critic was run.
- **Owner decisions applied:** max hand size 10 (inbox 1 says what replaced the three things that raised it); inbox 12 no change (a test
  pins the Armory's order); inbox 13 no change to Primm, and `dev primm N` grants the four boons (verified: 31 HP at the Phase 2
  checkpoint); Escape in a conversation kept.

## What was not done (read this before the rest)

The brief was a 24-hour pass; these parts were not done or only partly done:

- **Part 1:** no SSAO / SSIL / SDFGI (SSAO measured +2.3 ms on Medium in October and the Capital has 4 fps of headroom); no new sky or LUT
  per zone; no new light sources placed; sprites' contact shadows unchanged (both critics still call them faint). Per-zone grades were
  changed only in the D.N.A., the Gainlands, the Buffet and the freed Capital. FPS was measured in four places, not every zone.
- **Part 2.1:** the Gainlands got smooth cliffs and a calmer palette, **not** blended ground textures or edge foliage; its fortress brick
  still tiles (after-critic #6) and its shadows are still hard (#7).
- **Part 2.4, the scale audit:** the ratios are in the style bible; no zone-by-zone measurement was made and no outlier fixed.
- **Part 2.6, hub storytelling clutter:** none added (only the freed Capital's dressing).
- **Part 3:** only the gaps found were filled (buff shimmer, the result banner, zone-coloured fades). The battle list's other items
  already existed (lift / land, hit-stop, shake with its Settings toggle, floating numbers, death dissolve, the turn sweep) and were not
  re-tuned; the world list (pickup bob, door and chest animations, more ambient life) and the UI list (reward sequencing, a click-sound
  audit) were not worked on.
- **Part 4.2:** castle rooms do not escalate in music (the look does, through the vignette).
- **Top 25:** see the table - 7 done, 7 partly, 1 kept by design, 10 not (most need painting: Batch 15).
- **Part 4.4:** the late-game target (7 / 6 / 7) was missed (6 / 4 / 6); no re-score after the fixes; six of the critic's top 10 are
  not fixed or only half.
- **Part 6:** the RC5 zip does not contain the last four fixes (commit 86de96a4). The re-export was stopped by the low-memory guard
  before it wrote anything; the smoke and the three exported checks were therefore run on the 07:59 build only.
- **Memory before/after:** only "after" was read (below); no baseline was taken at the start.

## Part 0 - the audit and the style bible

- **The fixed shot set:** 113 shots through the play-script driver (`bash tools/nov12_shots.sh <tag> [set ...]`, scripts in
  `docs/review/play_scripts/nov12/shots_*.txt`): each zone's arrival, hub, main dungeon door and two mid-zone views at the default and
  the Low camera angle; the Capital before (9 places) and after Primm (5); 16 dungeon maps; 7 battles; 9 screens. New driver commands:
  `hud off|on`, `cam N`, `calm`, `spots`, `at <anchor>`, `matscan [m]`, `groundscan`.
- **The art-director critic** (brief `docs/review/critic_art_nov12_brief.md`; reports `docs/review/critic_art_nov12/report_before.md`,
  `report_after.md`): images only, six scores per shot, a ranked top 25.
- **`docs/art/style_bible.md`:** reference shots, a palette per zone, the lighting model, material rules (no pure-white, pure-black or
  untextured large surface), outlines and edges, a scale table (hero 1.70 m), foliage and ground, VFX.

## Parts 1-2 - the top 25 (the before report's ranking) and what was done

| # | Problem | Done |
|---|---|---|
| 1 | D.N.A. buildings are unlit black boxes | **Done, partly effective.** Ambient 0.4 -> 0.95 (#6f8a80), the key from the side (yaw 118), exposure 1.06, lighter wallpaper with a faint self-light, a brass picture rail; the wall at the lens cuts away on floor outside every room (`DnaRoomCut` - the giant chest's alcove was 40 % wall). Lighting 3.6 -> 4.7; the after critic still calls the zone a grey box (its floor and repeats). |
| 2 | The Capital after Primm is blown out | **Done.** `CAPITAL_FREED` is the inside's AgX grade turned to a golden afternoon (it was an old ACES preset). Lighting 4.3 -> 6.8. |
| 3 | Ghost buildings mid-fade | **Done for the Dump** (the glasshouse's glass stayed when its frame dissolved) and in general (`OcclusionFader.FADED` 1.0). **Not gone in the Capital's Transit Yards** (still in the after report). |
| 4 | Flat single-colour blocks | **Partly.** Every untextured flat colour gets a painted wash in the toon shader (`flat_wash`) and is never pure white or black. The critic still names the same blocks (Grave Row's box, the camp's slabs, the stalls, the mats): a wash is not a texture. Batch 15 rows. |
| 5 | Main dungeon doors do not read as doors | **Done for two:** the kit's painted oven-brick door in the Test Kitchen's arch and the studded door behind the House of Gains' portcullis. The D.N.A.'s Hall already had its kit door; not changed. |
| 6 | Faceted low-poly props | **Partly:** smoother Capital lamp globes. Hedges, statues, the D.N.A. sphere: not done (Batch 15 rows for the statue and the orb). |
| 7 | Smiley portraits and emblem | **Kept** (Primm's emblem; inbox 7). Batch 15 asks for painted easel portraits. |
| 8 | Windows are flat colour cut-outs | **Done in the Buffet** (glazing bars, oven grates). **Not in the Capital** (hundreds of panes: Batch 15's first row). |
| 9 | Broken Low camera at the Resistance Camp | **Done.** The lens rides 1.1 m over the ground under it and the Capital counts its rim hills. |
| 10 | Flat city wall and grey gate road | **Partly:** dust over the plinth and streaks under the cornice. Still "no surface detail" for the after critic. |
| 11 | Navy rectangle on the palace | **Done:** five cloths in the Paths' colours (painted banners: Batch 15). |
| 12 | Stray giant quads and billboards | Not done (quest markers and paper at the Low camera). |
| 13 | Tutorial battle has no board art | **A dev-tool artefact, fixed:** `dev encounter` now uses the cave's board (4.8 -> 7.8). Players always had it. |
| 14 | Map edges show voids and strips | Not done (Batch 15: a rubble row). |
| 15 | Gainlands materials tile and stretch | **Partly:** smooth-shaded cliffs and rocks, saturation 1.26 -> 1.12, a calmer sea. The brick and the mats: not done. |
| 16 | Buffet is an orange monochrome with haloed sharpening | **Partly:** a lavender fill light; the default sharpening 0.8 -> 0.4 for every zone (new installs; a saved setting is kept). |
| 17 | World map looks like a debug view | Not done (painting: Batch 15). |
| 18 | Flat-colour windmill blades and bunting | Not done (Batch 15). |
| 19 | Fountain water flat blue with scribble | Not done. |
| 20 | Flat bridge deck and grey water at the Dump | Not done. |
| 21 | Foreground obstructions | Not done. |
| 22 | Duplicate and broken sprites | Not done. |
| 23 | Battle item slots and plain overlays | **Partly:** VICTORY / DEFEAT stand on a band with an outline. The slots: Batch 15. |
| 24 | Dungeon maps hide their own art | Not done (UI layout). |
| 25 | Shop screens clipped and empty | Not done (UI layout: owner constraint). |

**The known ones from the brief:**
- **2.2 the material scan** (`matscan`): lists every untextured surface of 2.5 m or more per zone; the wash above is the blanket answer.
- **2.3 the Capital after Primm celebrates** (`CapitalCelebration`): the golden light, the fountains running again, a crowd of townsfolk
  in the Gate Plaza and on the avenue with six new passing lines, bunting from the fountain to the plaza's lamps and across the avenue,
  confetti on the paving, the Path-coloured cloths. One mesh for the decor; Low-end halves the crowd and drops the confetti. Medium 65 fps
  freed against 69 before at the gate. **The after critic's verdict: "a nicer time of day, not a celebration"** - it wants several times
  the crowd, banners on the houses, stalls and a changed sky. The crowd is 18 people; this is the place to add more if you want it.
- **2.5 the prop-ground check** (`PropGroundCheck`, `groundscan`, 5 tests): all five zones scan clean apart from by-design pieces.
- **2.7 the leftovers:** the cracked mirror is nine dark shards on a backing (was one pale pane); **Old Hob's stuck portrait reproduced
  and fixed** (the listener portrait stood alone for 0.7 s after a scene's last line - the midgame critic's route, before and after
  shots in `_screenshots/play/n12_repro_hob/`); the entrance roamer stays beaten per save; the Rift pop-up was already once ever; the
  "milky" fades were the 3 % residue and the glasshouse glass.

## Lighting changes per zone

| Zone | Changed |
|---|---|
| The D.N.A. | ambient 0.4 -> 0.95 and greener, key yaw 140 -> 118, exposure 0.98 -> 1.06, wallpaper tint and self-light |
| The Gainlands | saturation 1.26 -> 1.12, post saturation 1.22 -> 1.08, look saturation 1.16 -> 1.04, shadow opacity 0.7 -> 0.62, sea tint, smooth cliff normals |
| The Endless Buffet | ambient #e8c2a4 -> #c9b4d2 (a lavender fill) at 0.56, shadow tint to match |
| The Capital, freed | a new preset on the inside's grade: sun pitch -34, warm key, violet ambient 0.42, shadow opacity 0.62, exposure 0.46 |
| Everywhere | default sharpening 0.8 -> 0.4; scene fades in the zone's colour; untextured flats washed |
| Crosspath, the forest, the Dump, the Capital before | unchanged |

## Part 3 - the motion list

Added: a band of light crossing a card when its numbers rise (`card_shimmer.gdshader`); the result word on a band with an outline and a
swell; scene fades through the zone's colour (`SceneManager.fade_colour`). All hurried by the battle speed and off or still under Reduce
motion. Already in the game and left as they were: card lift and land, attack recoil, hit-stop and the final blow's slow motion, screen
shake with "Reduce screen shake", floating damage and heal numbers, the death dissolve, the turn ribbon, button hover and press easing,
click sounds everywhere (`UiSounds`), footstep puffs and per-zone ambient particles. Not done: see "What was not done".

## Part 4 - the late game

- **4.0 max hand size 10:** `GameState.MAX_HAND_CAP`; levels 14 / 28, the Lanyard, Quota's Stopwatch and the Weighing Scale no longer
  raise it (inbox 1).
- **4.1 owner decisions:** inbox 12 and 13 no change; `dev primm N` grants the four boons.
- **4.2 the turn panel** follows the turn the board has played back to (it flipped to "Your turn" in the middle of the foe's attacks).
  **The mirror phase:** Primm's copies of your cards wear a constant silver sheen and the rule says "His copies sit on his side of the
  table and shine silver, like a mirror; the plain ones are yours." **The build-up:** castle fights wear a rift-violet vignette that
  deepens with the rooms cleared; the three phases have their own (gold, cold silver, pulsing violet with cracks of light).
- **4.3 the ending:** each still drifts slowly (`StillBackdrop.drift`), a 2.4 s crossfade into the credits, a "Thank you for playing" card
  naming the Lab and the Gallery, then the postgame announcement. Music cues unchanged (the three beat cues and the credits cue existed).
- **4.4 the late-game critic on RC5:** `docs/review/critic_late_nov12/report.md` (30 scripts, 34 runs on the exported pack, 0 SCRIPT ERROR). Scores
  6 / 4 / 6. Phase 1 won in 8 turns; Phase 2 lost four times, Phase 3 lost once and one unfinished. Its built-in player stalled 2-6
  times a fight there: in a ten-card hand it clicked the covered centre of a card, nothing happened and the driver passed the turn.
  `tools/battle_pilot.gd` now clicks the card's uncovered strip. After that, on the dev build at level 20: Phase 2 **won** (1 try, no
  stalls), Phase 3 **lost 3 of 3** (turns 6, 7, 7, no stalls). Primm was not tuned (owner decision); inbox 10 asks the owner to play
  Phase 3 once. Fixed from its top 10: #4 the turn panel left the screen during Setting Up (the line is set smaller and can no longer
  widen the panel), #5 the funeral is on the map and in "Point me to...", #7 the Phase 3 hint, #10 the reward line's wording, #3 the
  driver. Not done: #1 and #2 (Primm's difficulty, retry a phase), #6 (room fog), #8 (needs painting), #9 (not reproduced), the
  smaller notes. All four game fixes were checked on screen in the dev build (`docs/review/play_scripts/nov12/late_fix_*.txt`).

## Part 5 - Batch 15

`docs/art/batch15_nov12.csv`: 21 rows in the earlier batches' columns, ranked. The top: the Capital's windows (2), six painted area maps,
the battle item slots, ICON-EQ-HALLPASSSLIPPERS, ICON-GEAR-EARNEDBLADE, Dex's table and card back, Primm's easel portraits (3), the freed
banners (4), NPC-HESPER and STORY-EPI-WRINKLES (REDOs), the Gallery's eight bestiary pictures and its map, prop cards for the things both
critics called stand-ins (the Dump's statue and sails, the Buffet's stalls, the D.N.A.'s orb, a rubble row), locked packs, a credits
panorama, lanterns and fireworks for the freed sky. The after critic adds candidates not yet in the list: the Gainlands' fortress brick,
the Dump's heart door, painted hedges.

## Part 6 - verify and RC5

- **Tests:** `tests/test_fable_nov12.gd` (20: Primm's phase restart and the boons, the Armory's order, the freed preset, the cloths, the
  celebration and its Low-end cut, the hand cap, the finale vignette, the wash range, the fade colour, the mirror sheen) and
  `tests/world/test_prop_ground_nov12.gd` (5). Full GUT, 38 shards, 24 min: 2984 / 2987, 1 failing (fixed), 2 pending. After that run
  only the default sharpening and its test changed (those files re-run green). **After the late critic's fixes (3 new tests): full GUT
  again, 38 shards, 24 min: 2988 / 2990 passed, 0 failing, 2 pending.**
- **Performance** (`docs/art/graphics_tier1/fps_n12_before.md` / `fps_n12_after.md`, 5 s each, vsync off):

  | Area | Low before | Low after | Medium before | Medium after |
  |---|---:|---:|---:|---:|
  | Crosspath square | 92.3 | 91.1 | 71.9 | 69.3 |
  | The Buffet hub | 99.8 | 99.4 | 84.9 | 80.3 |
  | The Capital, inside | 85.8 | 85.1 | 63.2 | 64.2 |
  | A battle | 353.5 | 350.1 | 343.8 | 354.0 |

  The battle is an ordinary fight, not a boss (the finale vignette is one full-screen pass on a 350 fps screen). Memory after, one
  session walking Crosspath -> the Capital -> the Buffet: working set 1.80 GB / 0.96 GB / 0.91 GB, video memory 1026 / 930 / 700 MB. No
  before reading was taken.
- **Export:** `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0-rc5` -> EXPORT OK, zip 734 MB, export peak 1.83 GB working set.
  The "over the 750 MB budget" warning is the same as RC3's and RC4's. The RC4 zip is kept.
- **Checks:** `run_release_smoke_exported.sh` PASSED (1.0.0-rc5). `play_exported.sh` A, B (A's settings), C (Low-end): 0 SCRIPT ERROR in
  all six logs. Three `button Continue: NOT FOUND` lines (A twice, B once) are the scripts pressing a box the Enter key had already
  closed; the shots show the game back in Crosspath.
- **Not re-exported:** the four late fixes (turn panel, funeral map entry, Phase 3 hint, reward line) are in the source after the zip
  was built. A second `export_windows.sh 1.0.0-rc5` started with 2.1 GB free and was stopped by the session's low-memory guard during
  the import step; the zip from 07:59 is untouched (MD5s as checked then). To get them into a build: close other programs, run the
  export line above, then `run_release_smoke_exported.sh` and the three `play_exported.sh` checks.
- **Docs:** `CHANGELOG.md`, `docs/release/rc5_notes.md` (both list the four late fixes; the notes say they need the re-export).

## Release-day checklist (the owner)

As Nov 11's (below, in the Overnight Nov 10-11 report), with these changes:

0. **Re-export RC5 (or go straight to 1.0.0) before giving it to anyone**: the zip on disk lacks the last four fixes.
1. Read inbox "Fable Nov 12" first - items 1 (hand-size replacements), 5 (six new crowd lines) and 6 (fountains running) change what
   players see and were my choices.
2. Decide whether RC5 or RC4 is the base for 1.0: RC5 changes the look of every zone a little (the wash, the sharpening) and of three
   zones a lot. If in doubt, play the D.N.A., the Gainlands and the freed Capital for five minutes each on your own screen.
3. Then steps 1-10 as before, with `1.0.0` in place of the RC name; the three exported checks may print the harmless `NOT FOUND` lines
   above.
4. After release: Batch 15 is the next visible gain; the after critic's top 25 (`report_after.md`) is the list to work from.

---

# Overnight Nov 10-11 - report

Brief: `docs/prompts/overnight_nov10.md`. Start tag `pre-overnight-nov10`. Questions: `docs/overnight_inbox.md`, "Overnight Nov 10-11".
Shots: `docs/overnight_shots/nov11/`. One Godot at a time; the critics (the wayfinding critic, the late-game critic) were the only Godot while
they played, and no sub-agent ran while a Godot of mine did. Owner constraints kept: no difficulty setting; the battle board and the UI
layout untouched (Part 1's token stacks and the Setting Up words live inside the existing row and rule row); Primm as he was. Owner
decisions applied: stashes stay marked while a step wants one (1); the Dump's herd grazes on the Commons (2); the D.N.A.'s Hall door marked from arrival
(3); the Capital's secret wall hole kept (4). The Fable pass Nov 10 report follows below.

## At a glance

(Resumed Nov 11 after a PC reset cut the run after Part 5.)

- **RC4 is built:** `builds/TheWaywardPath-v1.0.0-rc4-windows.zip`, 734 MB (pack 845 MB, 14098 files, MD5s match). The release smoke on
  the exported pack **PASSED**; the three exported-build checks (fresh settings, carried settings, Low-end) ran with **0 SCRIPT ERROR**.
  Full GUT before the export: **2965 / 2967 passed, 0 failing** (2 pending), 38 shards. Not uploaded anywhere.
- **The exported-build critic's top 10 (Part 1):** all ten done - gates named in the main quest's "Where to go", roamers 10 m clear of every
  door, token swarms stacked "xN", "Setting Up" in words, 6 s toasts, E prefers the quest NPC, alphabetical "Point me to...", Esc order.
- **Wayfinding, minutes to the main dungeon door** (no-context critic, exported pack, guidance only):

  | Zone | Nov 10 | Run 1 | Run 2 |
  |---|---|---|---|
  | The Gainlands | not reached, 23.5 | reached, 21.2 | **reached, 18.6** |
  | The Verdant Dump | not reached, 19.1 | not reached, 24.0 | not reached, 24.1 (traversal, not direction; fixed after) |
  | The D.N.A. | reached, 18.3 | **reached, 5.8** | - |

- **Fight pacing (Part 3):** the expected player now plays the midgame's 27 ordinary fights in **5.6 turns** (5.8), 98 % wins, **none over 7**
  (2 before), after about -20 % HP on the L10-14 band's ordinary foes. The real cause of the critics' 9-11 turns is **gear**: a bare hero still
  runs 9-10 turns - **inbox 12 is your call** (accept / a stall breaker / steer damage gear).
- **Late-game critic (Part 4): clarity 5, fun 4, polish 5 - no change from 5/4/5.** Its top 10: Primm's Phase 2-3 HP wall (**inbox 13**, Primm
  untouched), "Every unit is a 3/3" vs 7/4 (reworded), the 10+ card hand (logged: board layout), turn label / Setting Up countdown (countdown
  fixed, ribbon lag logged), Tidy-Bot drain (fixed: 10 s retreat), stale battle hints (fixed), dialogue over the node panel (fixed), mirror-phase
  ownership / the cracked-mirror quad / the unchanged Capital (logged). **A blocker it led to was fixed first:** after "Skip card" on a boss's
  reward, E never advanced the boss's closing words - Primm's included, so the ending could not be reached that way.
- **The release-day checklist** is at the end of the Finish below.

## Part 1 - the exported-build critic's top 10 (inbox 14)

| # | Problem (critic) | Done |
|---|---|---|
| 1 | The main quest's dungeon step never names the gate | Every zone's dungeon step "Where to go" line names the gate and what opens it, and a second line once it is open (`QuestObjective.hint_open` / `way_open`): the Buffet "Sir Loin's gate on the way wants Old Meatloaf mended - see Basil (the favour Mend the Meatloaf)" -> "Sir Loin's gate is open: north over the Gravy River on the Lazy Susan"; the Dump "Two things bar the way: the stream (plant the Magic Bean from the stream bank at the West Sprout Mound...) and the junk barricade on the stairs (charge it on a mount from the stables)" -> "The way is clear"; the Gainlands "Nothing is locked on the way: the middle road climbs straight to it from the bridge, past three road guards"; the D.N.A. "Its door is open: no permit, no favour, nothing locked on the way". Mend the Meatloaf's summary ends "Needed for the gate: Sir Loin opens the way to Layer-Cake Town and the Test Kitchen for a mended loaf." Owner decision 3: the D.N.A.'s favour step carries a part that marks the Hall's door from arrival (its hint: "...or go straight up to the Hall of Final Approvals: its door is open, no favour needed"). |
| 2 | A roamer camps the Test Kitchen door | `ZoneScene.ROAMER_DOOR_CLEARANCE` 10 m: `tests/world/test_roamer_doors_nov11.gd` builds every zone headless and fails on any roamer whose home +/- patrol comes within 10 m of a dungeon door, a gate or the exit (and on a home a roamer may not walk); it prints the nearest fitting home for an offender. Eleven moves (inbox 1): the Buffet's jelly (50, 20) -> (36, 32) - the Gelatin Sentinel - its loaf and the hub meatball, the Dump's gulls, the Capital's two castle-approach roamers, its tunnel-mouth inspector and a Tidy-Bot; the scene's exit roamer stands 14-17 m out. Road guards are the obstacle on their road by design and are exempt. |
| 3 | 9-11-turn fights | Part 3 below. |
| 4 | The boss's token swarm overlaps | Identical tokens on the battlefield (same card, same live numbers and state; not attacking, blocking or blocked) share one slot with an "xN" badge (`BattleBoard._field_stacks`, `FieldStack<owner>_<n>`), both sides, from two copies up; the row's spacing counts slots, so seven Sashimi Weenies take one card's width. Real cards never stack; the pad skips the cards under a stack's top. |
| 5 | "Setting Up" is an unlabelled hourglass in the fight | "Setting Up - attacks start Turn 3" stands beside the hourglass in the rules row (`RuleIconRow.set_note`, `BattleHud._refresh_setup_note`) until the window is over; the turn panel's countdown now survives every refresh (a sync wiped it). |
| 6 | Toasts stay 20-30 s | The HUD toast is capped at 6 s plus the fade on the wall clock (`TownHud.TOAST_MAX_HOLD`; `_process` enforces the deadline whatever the tween does) and a click dismisses it. |
| 7 | E prefers plaques to the quest NPC | A person with a quest to give or hand in wins the E prompt over a plaque, a sign or a prop in reach, and reaches 0.8 m further (`ZoneScene.QUEST_NPC_BEATS`); never over a door, an exit or a station. |
| 8 | "Point me to..." reorders | Goals first (the tracked quest's first), then the places in alphabetical order (`FullMapScreen.where_to_places`). |
| 9 | The favour toast survives accepting | `TownHud.clear_toast("has a favour to ask")` when the offer is taken. |
| 10 | Escape opens the pause menu over pop-ups | `SceneManager.close_top_popup`: Esc presses Continue on a visible reward / quest-complete / level-up box, else advances the open conversation; the pause menu only when nothing else is open (inbox 8). |

Tests: `tests/ui/test_part1_fixes_nov11.gd` (10: the four zones' hints, the Buffet's line before and after the gate, the Dump's open line,
the D.N.A.'s door on the favour step, seven tokens -> one slot with "x7", a hurt / attacking token leaves the stack, real cards never stack,
the Setting Up note and its end, the alphabetical list, the toast cap and clear) and `tests/world/test_roamer_doors_nov11.gd` (6: the five
zones, the exit roamer). The quest, wayfinding, route, board token, rule badge, hand number and turn counting suites green after the change.

## Part 2 - wayfinding in every zone, proven

### 2.1 The Dump's arrow (inbox 11)

`RouteGuide` plans on a per-zone grid and frame budget (`setup(..., grid, budget)`; `ZoneScene._route_grid` / `_route_budget_usec`,
`QuestMarkerLayer.set_routing`): the Dump uses a 1 m grid and 12 ms a frame (`HeapScene.ROUTE_GRID` / `ROUTE_BUDGET_USEC`), the other zones
keep 0.75 m and 5 ms. `tests/world/test_route_grid_nov11.gd`: the Commons -> Rotheart plan (the failing strict search plus the gated one)
takes 0.8 s of search in 67 slices (1.4 s in 273 slices before), so the arrow follows the route about 1.1 s after a pick instead of ~4.6 s;
the gated route still crosses the stream on a vine bridge's line and the grown-bridge strict route still exists.

### 2.2 The no-context wayfinding critic on the exported build

A fresh critic (brief `docs/review/critic_wayfinding_nov11_brief.md`, report `docs/review/critic_wayfinding_nov11/report.md`, 46 runs on
the RC4-tree test pack after Part 1 and 2.1, fights auto-won, no dev travel) arrived in each zone and had to reach the main dungeon's door
with the game's guidance only:

| Zone | Nov 10 (before any fix) | Nov 11 run 1 (after Part 1, 2.1) | Clarity | What stopped or slowed it |
|---|---|---|---|---|
| The Gainlands | not reached, 23.5 min, 17 runs | **reached, 21.2 min, 20 runs** | 2 -> 5 | the gym hall north of the Station dissolved (the occlusion fader's 6.5 m "clutter" rule) so the road looked open and it walked into an "invisible wall" for 5.4 min; the legend's "Goal:" rows were not buttons; the Flex Mirror's 1.5 m reach |
| The Verdant Dump | not reached, 19.1 min, 14 runs | **not reached, 24.0 min, 21 runs** (stopped at the junk barricade, 40 m from the door, with the bean planted and the bridge grown) | 3 -> 3 | "finish a favour" did not accept Brother Bramble's side-dungeon quest, so it never saw the dungeon step and its text about the stables; planting the bean and growing the bridge changed nothing visible in the tracker |
| The D.N.A. | reached, 18.3 min, 11 runs | **reached, 5.8 min, 5 runs** | 5 -> 8 | the front desk (no routing); the arrival pop-up |

Fixed from its report (run 2 follows below):
- **The gym hall never dissolves as clutter** (`occlusion_near` 2.0 on its meshes, as the other landmarks): the critic's four lost runs
  (`g14_n1.png`, `g17_gap.png`: an open plaza where a two-storey brick hall stands) were the fader hiding the building the arrow routes round.
- **"Finish a favour" accepts the zone's side-dungeon quest** (`QuestDefinitions.ZONE_SIDE_QUEST`), and the favour hints say "any quest one of
  them gives you counts" (inbox 7).
- **A part done is announced**: "Quest updated / Root Cause / Done: A Magic Bean (by the stream...)" when a part of the current step completes
  without the step moving (`Session._note_step_moves`, inbox 8).
- **The legend's "Goal:" rows are buttons** (a click points the arrow at that quest's nearest place, inbox 10); **the Flex Mirrors answer E from
  2.4 m**; **the herd's two far animals graze on the Commons** (owner decision 2, inbox 11).
- Logged, not changed: the entrance ambush and the Rift Station pop-up repeat on every entry (a `dev save` resumes at the entrance: a human
  enters a zone a few times, not twenty); the Commons' counters; the junk gull's -2 HP (the zone's hazard).

**Run 2** (resumed Nov 11 after the PC reset; same no-context critic brief, `docs/review/critic_wayfinding_nov11_brief_run2.md`, on a test
pack exported after Parts 2.2 and 3; report `docs/review/critic_wayfinding_nov11/report_run2.md`, saved by me from its final message as its
own write was refused; scripts `wy_*`, shots `_screenshots/exported/wy2_*.png`):

| Zone | Nov 10 | Run 1 | **Run 2** | Clarity | What slowed it |
|---|---|---|---|---|---|
| The Gainlands | not reached, 23.5 min | reached, 21.2 min | **reached, 18.6 min, 24 runs** | 2 -> 5 -> 6 | the "middle road climbs straight" line (the road jogs west round the gym hall; it took the far west road and its stone bridge, ~120 s + 4 runs on the bridge's sticky west end); a road guard fight on every arrival; the door dialog said "???" |
| The Verdant Dump | not reached, 19.1 min | not reached, 24.0 min | **not reached, 24.1 min, 39 runs** (bean planted, bridge crossed, mount taken; stopped wedged in town) | 3 -> 3 -> 5 | traversal, not direction: wedged between the barn and a crate / planter on the town -> bean line, the golem fight beside the bean on nearly every pass, stair edges; the line still named the bean after it was planted and did not say which stables |
| The D.N.A. | reached, 18.3 min | reached, 5.8 min | (not re-run) | 5 -> 8 | - |

The Dump's 24 minutes went on walking, not on finding the way: its report says the text "said exactly what bars the Rotheart", and every
resumed run re-walks from the entrance (39 resumes x 25-60 s). Fixed from run 2:
- **The Gainlands' line describes the real road**: "take the middle road - it leaves the plaza west round the gym hall, turns back east behind
  it, then runs straight north along the ridge past three road guards to the fortress stairs (the far west road and its stone bridge are the
  long way round)".
- **The Dump's line follows the way**: once the stream is crossed it stops naming the bean and says "one thing left: the junk barricade on the
  stairs north of the Farm Terrace - borrow a mount at the Farm Terrace stables (across the stream, not the town's)"
  (`QuestObjective.step_hint` / `current_hint`); the stables marker says "The Farm Terrace stables, across the stream".
- **The town wedge**: the crate (40, 112.5) and the planter (41.5, 112.5) beside the barn are gone; **the Mossy Trash Golem** roams at
  (28, 118) r 2.5, 11 m clear of the bean and the mound (was (30, 109) r 3.5, between them); a test keeps every roamer 6 m clear of both.
- **The main dungeon's door dialog** carries the dungeon's name (the prompt over the door already said it; "???" stays on maps before a visit).
- Logged, not changed: the world arrow's floating label shows the tracked quest's name, not the "Point me to..." pick (the arrow itself
  follows the pick); the mount is not kept by a `dev save` resume; the Gainlands' stone bridge's west end is sticky (a 1 m step needed); the
  road guard 8 m in fights on every arrival (by design: the guards are the middle road's obstacle; a player arrives a few times, not 24).
  **The Dump was not re-run a third time** (it would take another ~70 minutes of the morning, and run 2's cap came from traversal the fixes
  above address); worth one run after release if you want the number.

## Part 3 - fight pacing (ordinary fights)

**Cause.** Not enemy HP alone: **the player's gear.** The balance sim's expected player (the `ProgressionModel` deck, gear and items
for the level) already finished the midgame's 27 ordinary fights in 5.8 turns on average (2 over 7). The critics' 9-11 came from a hero
without that gear. A hand-played sample (resumed Nov 11, `docs/review/play_scripts/n11_pace_sample_a.txt` / `_b.txt`: the exported-build
critic's own level-14 hero `bot_refusemancer_enter_gourmand`, the built-in pilot, after the first HP trim) took **10 turns** (Gelatin
Sentinel), **11** (Frozen Line Cook), **13** (Meatloaf Golem) and **lost in 8** (Prep Station Sous-Chef). The sim's gear lift on the
Gelatin Sentinel (`--what=gear`, `_logs/sim_gear_probe.md`) shows why: bare (no gear, no items) **9.2 turns, 72 %**; the model's L13 gear
**6.3 turns, 94 %**; gear + items 6.6, 100 %. The bot's five pieces (Clipwell's Shears, Mystery Stain Bib, Raccoon Crown, Gotta-Go Galoshes,
Quota's Stopwatch) each move it by under half a turn, and it had no items slotted (the pilot never uses items anyway). The fights are not
energy-flooded; a player who has not geared for damage cannot break the enemy's board and chips.

**Fix (smallest that works, ordinary fights at levels 10-14 only; bosses, elites, gatekeepers, Primm and the Gallery unchanged).** The band
that ran long is the D.N.A., the Endless Buffet and their side dungeons (levels 10-14); the Dump, the Alley and the final stretch (levels
16-20) already ran 4.5-5.2 turns. Their ordinary foes' HP down by about 20 % from what they were: Gelatin Sentinel 16 -> 13, Shambling
Middle Manager 14 -> 11, the D.N.A.'s rooms 18/18/19/20 -> 14/14/15/16, the Test Kitchen's rooms 14/15/15/15 -> 12/12/12/12, the Apprentice
Itamae 13 -> 11, the Conveyor Belt Sushi Chef and the Receptionist of Number One 18 -> 14, the Eternal Queue 19 -> 15. The Meatloaf Golem
(12) and the Unpaid Intern (10) were already short.

| Expected player (sim, 8 games per Path and fight, seed 7100) | Fights | Turns | Beefcake | Necrocrat | Gourmand | Refusemancer | All | Over 7 turns |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| Before (Nov 10) | 27 | 5.8 | 93 % | 100 % | 99 % | 98 % | 98 % | 2 |
| After | 27 | **5.6** | 94 % | 100 % | 99 % | 99 % | **98 %** | **0** |

Per group (before -> after, mean turns): the D.N.A.'s rooms 6.8 -> 6.3, the Test Kitchen's 6.2 -> 5.7, S-GOUR 6.5 -> 6.1, S-NECRO 6.5 -> 6.0,
the Buffet's roamers 6.3 -> 6.1, the D.N.A.'s 6.4 -> 6.1; the others unchanged. Tables: `docs/design/sim/nov11/before_*.md` / `after2_*.md`
(`python -I tools/pace_table_nov11.py before after2`).

**What the trim does not fix (inbox 12, your call).** A hero without the model gear still runs long after the trim: the sim's bare player
(`--nogear`, `docs/design/sim/nov11/after2_bare_*.md`, partial) takes 9.1 turns on both Buffet roamers (69-72 %) and 8.9-10.2 in the Test
Kitchen's rooms; the Sentinel's 14 -> 13 HP moved it 9.2 -> 9.1. For that player the board stalls and HP is not the lever. Not changed
tonight (it is a rules change, not a number): the options are in the inbox.

## Part 4 - the late game on the exported build

**A blocker found on the way: after "Skip card" on a boss's reward, E never advanced the boss's closing words.** Re-saving the
snapshots (`docs/review/play_scripts/n11_resave_end_1.txt`, `_2.txt`, editor build, fights auto-won) stalled on Primm's first closing line
("The model lies in pieces...") for 200 s and 80 taps of E. The Rewards screen's keyboard handler (`RewardsScreen._input`: 1-3 choose, E
takes) stayed live after the pick was skipped - the cards and the Take button were still alive - so every E went to "E never takes a card you
did not choose" (an error blip, the key swallowed) and the dialogue on top never saw it. Taking a card freed the button, which is why bots and
critics who took a card got through. Fixed: the handler stands down once the pick is confirmed or skipped (`_confirmed`) or the panel is
hidden. Re-run (`resave3`): the closing words, the fall still, the ending, the credits and the postgame announcement went through in 59 s of
taps, back in the Capital at level 21. Any main dungeon's boss epilogue had the same trap after a skipped card.

**The snapshots:** `c13end` and `c13post` now both hold that run's state - Primm defeated, the postgame unlocked, the hero in the Capital
(`user://dev_saves`, the old ones in `dev_saves/_backup_nov11/`). The ending itself only plays by beating Primm, so a snapshot cannot sit
"inside" it; `c13castle` + `dev travel dungeon D-PC -2` is the way to see it.

**The no-context late-game critic** (a test pack rebuilt with the Rewards fix; 34 runs, about 49 minutes of game time; report
`docs/review/critic_late_nov11/report.md`, saved by me from its final message as its own write was refused; scripts `critic_late_n11_*`,
shots `_screenshots/exported/l*_*.png`) walked the Capital to the castle, played the Courtyard, read Primm's intro, fought Primm for real from
the phase checkpoints and toured the postgame from `c13end` / `c13post`. **Scores: clarity 5, fun 4, polish 5 - no change from 5/4/5.** It
beat Phase 1 on its second try (16 of 31 HP left), lost Phase 2 twice (once at level 24) and Phase 3 once, so it did not see the ending; the
re-save run above did (auto-won). No `SCRIPT ERROR` in any of its 34 logs.

| # | Its top 10 | Done |
|---|---|---|
| 1 | HP wall in Primm's Phases 2 and 3; a loss restarts the castle | **Logged** (owner: Primm stays as is). Note: its Phase 2/3 tries started from `dev primm 2/3`, which drops the four leaders' boons (23 HP instead of 31, 3 rule icons instead of 9) - a dev-checkpoint gap, not what a player gets; still, 16 HP carried into a 52-HP mirror is steep. Inbox. |
| 2 | "Every unit is a 3/3" while its units showed 7/4 | **Reworded** (the rule sets every unit's BASE to 3/3 and boons and buffs add on top - working as built): "Every unit starts as a 3/3, so cheap units are as good as big ones; boons and buffs still add on top. You may play two cards a turn." |
| 3 | 10+ card hand wraps into two rows; ENEMY TURN ribbon over the Toss prompt | **Logged** (battle board layout: owner constraint; the two-row hand is already a known issue in the RC notes). |
| 4 | Turn label and Setting Up countdown out of sync | **Countdown fixed**: it counted the boss's own turns taken, so with the hero first it read 2, 2, 1 on Turns 1-3; it now follows the Turn shown (`GameState.setup_turns_left_shown`): 2, 1, then gone on Turn 3 when attacks start; the engine's rule is unchanged. **The ribbon / panel lag logged**: the board plays events back behind the game state ("YOUR TURN" over the enemy's turn, "Turn 1" while Primm attacks), a playback-timing change too risky for an RC. |
| 5 | Tidy-Bots drain about 1 HP a second on a Capital walk | **Fixed**: a damaging roamer that knocks you flat goes home and leaves you be for 10 s (`ZoneEnemies.DAMAGE_RETREAT_TIME`; was 2.2 s, then it re-chased at 5 m/s), and does not re-aggro while it cools down. Same 2 damage per knock. |
| 6 | Stale "Needs 2 energy; you have 0" hints, even over Victory | **Fixed**: the battle toast clears at the result screen and its fade runs under a pause too (it froze there); it already cleared at every turn and phase change. |
| 7 | Dialogue box over the boss node's info panel | **Fixed**: the dungeon map hides the node info panel when a scene opens. |
| 8 | Mirror phase: whose units are whose | Logged (board look: owner constraint). |
| 9 | The cracked mirror is a white quad | Logged (art; no art replaced tonight). |
| 10 | The Capital barely changes after Primm falls | Logged (postgame content). |

Also fixed: the 8 engine errors `!is_inside_tree()` from `HoverTip._show` while clicking hand cards (no tip for a control that has left the
tree). Logged from its smaller notes: the Freed Leaders' game-term brackets inside quotes, the 11-line pre-fight box, the castle gate still
(the hooded woman held by guards), the HUD goal title "Free the Four Zones" when only the castle is left, the Shattered Gallery's unexplained
63 max HP, the castle guard and Primm fielding "Resistance Scout", the white lamp globe and stair bands near the castle. `pilot` stalls in
Primm's fights (a test-tool gap, not the game).

## Part 5 - the test runner's memory guard (inbox 13)

`bash tools/run_tests.sh --min-free=MB` (default 900) `--wait-max=SEC` (default 600): before each shard the runner reads the free RAM
(PowerShell's CIM on Windows, `/proc/meminfo` elsewhere) and waits, polling every 10 s, until it is above the floor; a shard it cannot start
in time is skipped and listed under "Crashed shards" with the `--from=N` to rerun it. `--min-free=0` turns the wait off. Documented in
`docs/HANDOFF.md` section 2.

## Part 6 - RC4

- **Version** `1.0.0-rc4` in `project.godot`; `CHANGELOG.md` has the RC4 entry; `docs/release/rc4_notes.md` is the playtester page.
- **Export:** `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0-rc4` -> **EXPORT OK**,
  `builds/TheWaywardPath-v1.0.0-rc4-windows.zip` **734 MB** (RC3: 734 MB), pack 845 MB, 14098 files, 89 baked shaders, every MD5 matches;
  zip CRCs checked. Export peak 1851 MB working set (2.7 min). The "over the 750 MB budget" warning is the same as RC3's. The RC3 zip is kept.
- **Release smoke on the exported pack** (`bash tools/run_release_smoke_exported.sh`): **PASSED** (title and pause version, New Game, F8 form +
  report files, pause menu buttons, no Dev Menu in release, save/load slot 2). It first failed 2 checks: the smoke pressed Esc once for the
  pause menu, and since Part 1 Esc advances the opening conversation first, so the menu stayed shut. The smoke now taps Esc until the
  menu shows (6 taps from the opening scene - each advances one line) and checks the menu is really visible.
- **Exported-build checklist** (test pack rebuilt; `play_exported.sh` runs A, B with A's settings, C on Low-end): **0 `SCRIPT ERROR`** in all
  three game logs, every scripted button found. Three script updates for the new Esc order (no game change): A closes the "New Gear!" box with
  its Continue before Esc; B saves to **slot 3** (slot 2 holds the Nov 10 run's 10-second test save and asked "Overwrite this save?" - never
  overwritten; slot 3 now holds a 10-second test save too - both deletable from Load Game) and leaves the slot screen with Back; C waits
  out the way back and sends Enter before Esc.
- **Logged from the checks, not changed:** (1) an Esc pressed during a load is remembered, but dropped if the scene arrives with the hero
  locked for its title (`SceneManager._end_transition` needs `pause_allowed`); (2) after the dev-only fight in run C (`dev encounter quota`
  from the Gainlands) the way back lands in the town scene with the hero locked and no box visible until a key (Enter / Esc) - a real
  return (run A, Crosspath) shows the "New Gear!" box. Worth a look after release if a tester reports a frozen hero after a fight.

## Finish

- **Tests:** full GUT in 38 shards before the export (`bash tools/run_tests.sh --min-free=800`, 24 min): **2965 / 2967 passed, 0 failing**, 2
  pending. Since then only the release smoke and the three play scripts changed (tools / docs, no game code).
- **Commits** (all pushed; nothing uploaded): `c70394ba` Part 1, `97120a7a` Part 2.1, `cb64b5c1` Part 5, `559ad36a` Parts 2.2 + 3 (resumed),
  `a0ec9de7` Part 3, `25b5d32e` Part 2.2 run 2, `1ec6857f` Part 4 (the Skip-card blocker, snapshots), `8678b445` Part 4 (late critic fixes),
  and the Part 6 commit with RC4's version, changelog, smoke and scripts.
- **Your inbox:** items 12 (fight pacing for an ungeared hero) and 13 (Primm's Phases 2-3) need a decision; the rest are notes.

### Release-day checklist for Nov 11 (the owner)

Everything below is from `docs/HANDOFF.md` section 2 and `docs/release/itch_upload.md`; about 90 minutes end to end, most of it the upload.

1. **Decide the donation link first** (it is baked into the build): in `data/credits/credits.cfg` set `[support] url="..."` to your itch
   page's pay-what-you-want address (`https://<your-itch-name>.itch.io/the-wayward-path/purchase`) or a Ko-fi / PayPal link. While it is
   empty every "Support the game" button stays hidden - that is also fine for 1.0.
2. **Version:** `project.godot` -> `config/version="1.0.0"`. Add the 1.0.0 entry at the top of `CHANGELOG.md` (the RC4 notes list what
   changed since RC3). Commit.
3. **Export:** close Godot, free RAM (close Chrome / ChatGPT), then in Git Bash from `C:\Dev\Deckbuilder-rpg`:
   `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0` (4-10 minutes; "EXPORT STOPPED" means nothing was replaced). The zip lands at
   `builds/TheWaywardPath-v1.0.0-windows.zip`.
4. **Smoke:** `bash tools/run_release_smoke_exported.sh` (about a minute; look for `PASSED`). Then the three exported-build checks:
   `bash tools/export_test_pack.sh` (2 minutes), then `bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_a.txt r1a 480`,
   `SUITE_SETTINGS_FILE=_screenshots/exported/settings_play_r1a.cfg bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_b.txt r1b 480`,
   `bash tools/play_exported.sh docs/review/play_scripts/exported_rc1_c.txt r1c 480`; `grep -c "SCRIPT ERROR" _screenshots/exported/play_r1*.log`
   must print 0 three times. (Run B saves to slot 3 of this PC's own saves; the 10-second test saves in slots 2 and 3 can be deleted from
   Load Game first, or B just meets "Overwrite this save?", backs out and goes on.)
5. **The real exe once:** unzip the 1.0.0 zip into a fresh folder, run `TheWaywardPath.exe`, start a new game to the Path choice, Esc,
   Settings, quit; launch again and Continue. (Or the scripted version: HANDOFF section 2, step 3.)
6. **Tag:** `git add -A && git commit -m "1.0.0" && git tag v1.0.0 && git push && git push --tags`.
7. **itch upload** (`docs/release/itch_upload.md`): Dashboard -> the project -> Edit -> Uploads -> Upload files -> the 1.0.0 zip (about
   740 MB: 5-15 minutes; leave the tab open), tick Windows, label "Windows 64-bit (zip)"; delete or untick the RC file so players get one
   file. Pricing "$0 or donate" with a suggested 3-5 USD (or "No payments"). Check the page text, the eight screenshots and the cover, the AI
   disclosure (Yes: Graphics, Sound/Music, Text/Dialogue). Save.
8. **Download it back once** as a player (View page -> Download), unzip in a fresh folder, run the exe to the title screen.
9. **Flip:** Visibility & access -> **Public** -> Save. Optional devlog post "1.0 is out". Send the playtesters the public link.
10. After the flip: `docs/release/post_1_0_backlog.md` holds what is known and not done; F8 reports arrive in `%APPDATA%\Deckbuilder-RPG\feedback`.

---

# Fable pass Nov 10 - report

Brief: `docs/prompts/fable_nov10.md`. Start tag `pre-fable-nov10`. Questions: `docs/overnight_inbox.md`, "Fable Nov 10" (items 1-14).
Shots: `docs/overnight_shots/nov10b/`. One Godot at a time; the two critics (the wayfinding critic, the exported-build critic) were the only
Godot while they played, and no sub-agent ran while a Godot of mine did. Owner decisions kept: no difficulty setting; the battle board and the
UI layout untouched (Part 3 is numbers only); Primm as the last pass left him. Last night's report (Overnight Nov 9-10) follows below.

## At a glance

- **RC3:** `C:\Dev\Deckbuilder-rpg\builds\TheWaywardPath-v1.0.0-rc3-windows.zip` (**734 MB; RC2 was 734 MB too**; re-exported after the last two fixes so it matches `main`, smoked again: PASSED), release smoke on the exported pack
  ****PASSED** (`_screenshots/release_smoke_exported.log`)**, the short exported-build checklist ****done, 0 SCRIPT ERRORs**: the three RC1 scripts on the RC3 test pack - A (fresh settings: title, Credits, a new game through the intro, Crosspath, a shop, the Deck Station, the Wardrobe, the packs page, a battle, the pause menu, a setting, Copy log, a manual save, quit, load; 16 shots), B (seeded with A's settings: Settings, save and Continue, the Gainlands quiz; 8 shots), C (quality 0: a zone, the town, a battle; 4 shots) - `_screenshots/exported/x*.png`, `y*.png`, `z*.png`**. Notes for testers: `docs/release/rc3_notes.md`.
- **Part 1 (finding things):** every step of every active quest marks every part; the audit fails on a marker-less step; the gates on the way to
  the Buffet's and the Dump's main dungeons are marked; the NPC visibility probe passes; "Point me to..." opens over the map with one row per
  goal; the white sheets were steam puffs at the lens. **The wayfinding critic reached 1 of 4 main dungeons (Gainlands 2, D.N.A. 5, Buffet 4,
  Dump 3 /10)** - its first fix, a route-following arrow, is in (Part 1.6 below), with the dotted route on the map.
- **Part 2 (turns):** Turn N = both players' turns everywhere a player reads a number; no moment moved (table below).
- **Part 3 (hand numbers):** hand cards and the raised hover card show this fight's power, toughness and cost in green / red; the right-click
  preview says the printed values ("In this fight: 7/4 (printed 3/3)").
- **Part 4 (rewards):** no "losing costs nothing"; dungeon fights +50 %; completion -20 %; the gold study says 22.8k no-grind (+7 % on the
  21.2k target, inside the band, not re-tuned).
- **Part 5:** the Hall Pass Slippers (Boots, 500 gold at Mirepoix's): no HP from the world's hazards outside battle.
- **Tests:** **2942 tests in 31 shards: 2940 passing, 0 failing, 2 risky** (the same two no-assert tests as before). The parts had broken six test expectations, all fixed and re-run green: R-08's card script hash (the "your turn" wording; `import_cards.sh --stamp`), the Old Well's steps now marked like every step, Setting Up said in turns, 26 pieces and 4 on Mirepoix's shelf, the defeat line's new words. The sharded run was stopped once by the memory guard (free RAM under 800 MB with Chrome and Defender busy); the rest ran one shard at a time with a check before each. **The exported-build critic (the Buffet, arrival to the Test Kitchen):** clarity **7**, fun **6**
  (was 5 / 4). Polish 7. Its top three: the main quest's own step never names Sir Loin's gate or the side quest that opens it; a roaming Gelatin Sentinel camps the Test Kitchen door; every fight runs 9-11 turns. Report: `docs/review/critic_exported_midgame_nov10/report.md`.

## Part 1 - finding things

### 1.1 Markers for every part of every step

- `QuestObjective.parts`: a step can name several targets, each with its own "done" condition; `targets()` lists the undone ones. Mend the
  Meatloaf marks the salt, the truffle and Old Meatloaf; the Pantry Run its six pickups; the roamer-count favours every live roamer of the
  zone (`QuestMarkers.SPOT_ROAMERS`); the stash hunts every unopened stash; the Dump's herd each animal, the Capital's wheels each wheel. A
  part drops the moment it is done (the pickup taken, the animal home, the wheel freed).
- The world: up to 10 chevrons per step, the gold arrow at the nearest; the map and the minimap carry every active quest's goals (the tracked
  quest's pin to the minimap's rim); the menu steps ("Open a pack") carry no marker and say so (`menu_step`).
- `tools/quest_audit.gd` fails on a step with no marker target (and checks every part's area and spot). It found the Old Well's hum steps,
  Loose Ends, the giant chests, the vault levers and the favour steps - all marked now. Shots: `p1_point_me_list_buffet_quests.png`,
  `p1_map_goals_buffet.png`.

### 1.2 The route to each main dungeon

`tools/dungeon_route_audit.gd` plans a route from the arrival point to the main dungeon's door over each zone's real walkability, fresh (nothing
opened) and open (every gate granted), and names the gates on the open route:

| Zone | Fresh | Open | Gate on the way | What the player is told |
|---|---|---|---|---|
| The Gainlands | route | route | none | - |
| The D.N.A. | route | route | none | - |
| The Endless Buffet | no route | route | Sir Loin's golem gate | Sir Loin: "speak to Basil, east of the Soup Fountain"; Basil's offer and the gate's "active" line name the Salt Flats and the Broccoli Forest; the main line's dungeon step marks the gate until it opens |
| The Verdant Dump | no route | route (142 m) | the vine bridges, the junk barricade on the stairs | the main line marks the Magic Bean + the West Sprout Mound (Part 1.6), the stables and the barricade; the bridge sign and Moss Mulligan name the bean |
| The Capital | "narrow" route | route | the city gate | inbox 7: a fresh hero can slip through the hidden west hole; kept |

Sir Loin's stale "speak to Basil" is gone (his need line now says where Basil stands); a mended loaf not yet reported gets its own line
("Tell Basil yourself... His word opens this gate").

### 1.3 Nobody behind a prop

`tools/npc_visibility_probe.gd` stands the hero on every talk point and casts sight lines from the default and the Low camera to each NPC's
feet, chest, head and name plate (a mesh between the lens and the hero is ignored, it fades). The first full run: 78 checks, nine real hides.
Moved: Basil and Tarragon (clear of the Buffet's bridge gate; Tarragon again 3 m west of Rip at the Rift station after the Nov 10 critic
run), Madame Mirepoix's awning, sign, pudding and cupcake, Billie Muckfoot (off the Rift station's line, then off the greenhouse's corner),
Dex in the Dump (out of the appliance grove), Kestrel, a Capital ward patient. The brightened card copies now fade for the hero too. A prop
between the camera and the person you can talk to dissolves (`OcclusionFader.talk_focus`); with nobody in reach, E walks to the nearest
person in view (E's reach = the click's). Last run: every check ok; two "partly" rows remain (Mirepoix's head behind a cupcake at the default
camera - the cupcake is smaller and further back now; Dex's feet behind the stream fence at the Low camera, plate and prompt clear).

### 1.4 Map labels

Landmarks are named first and win the room; minor names hide below map scale 5.5 and show on hover; "Point me to..." is an in-screen list
over the map's right edge (a Window popup sat over the legend whatever it was told); the legend has one line per quest goal. Nov 10 critic
run: one row per goal name ("A hidden stash (any) (one of 14)" instead of fourteen rows that buried the Meatloaf's three), the area each
goal stands in ("An escaped animal (the Compost Commons)"), "via" rows for roads out ("Root Cause: via Back to Town"), and Escape closes the
list and the map together. Shots: `p1_point_me_list_gainlands.png`, `p1_point_me_list_dump.png`.

### 1.5 White sheets

Not the occlusion fader: the milky sheets north of the hub were the steam and mist puff billboards reaching the lens at the Low camera.
`ParticleLook.near_fade` fades every puff material between 9 m and 2.5 m of the camera (the Buffet's steam, the Gainlands' and the Dump's
mist). The fade walk (`docs/review/play_scripts/fade_walk_gourmand_nov10.txt`) shows no sheets; the Low shots at the Salt Flats only carry the
fall-in-the-gravy tint.

### 1.6 The wayfinding critic (and what it changed)

A no-context critic (brief `docs/review/critic_wayfinding_nov10_brief.md`, report `docs/review/critic_wayfinding_nov10/report.md`, 57 runs,
84 minutes of game time) arrived fresh in each Path zone and had to reach the main dungeon's door with the game's guidance only:

| Zone | Door reached | Game time | Runs | Clarity /10 | What stopped it |
|---|---|---|---|---|---|
| The Gainlands | no | 23.5 min | 17 | 2 | the straight arrow over the plateau wall; a pocket beside the House of Gains' stairs where it stood wedged |
| The D.N.A. | yes | 18.3 min | 11 | 5 | the front desk and the mail-room terminal on the arrow's line |
| The Endless Buffet | no (Meatloaf mended, not reported) | 22.9 min | 15 | 4 | the arrow across the Gravy River (two falls); the truffle pocket; Sir Loin's unchanged line |
| The Verdant Dump | no | 19.1 min | 14 | 3 | the arrow across the stream; no bean, no mound found; two herd animals across the water |

Its three fixes, and what was done:

1. **A route-aware pointer, or the route on the map** (35 of its 84 minutes went into the straight arrow). Done: `RouteGuide`
   (`world/route_guide.gd`) plans an A* route over the zone's own walkability (a 0.75 m grid, 8 neighbours, the midpoint between cells tested
   so a thin wall is never stepped over), sliced at 5 ms a frame so nothing hitches. The gold arrow and the "Point me to..." arrow point
   9 m along the route; the full map draws the route dotted (white for the pick, gold for the tracked goal); a waypoint that is on screen
   gets a small arrow of its own (the critic's "dead end" at (49, 55) now shows the arrow at the road's foot to the east:
   `p1_route_arrow_critic_dead_end.png`, `p1_route_arrow_middle_road.png`, `p1_map_route_gainlands.png`). Two walkability tests per zone: strict
   (what the hero can walk now - the Buffet's river only on a ferry's line, the Dump's stream only on a grown bridge) and through-gates (a
   shut golem gate, an ungrown vine bridge, a barricade count as open), so where a gate shuts the road the arrow leads to the gate, where
   the sign says what opens it (`p1_map_route_buffet_ferry.png`: the route crosses the Gravy River on the Lazy Susan; `p1_route_arrow_dump_arrival.png`).
   Search cost (tests): the Gainlands 45 ms, the Buffet 360 ms, the Dump 1.5 s (inbox 11).
2. **The gate and its requirement in the main quest and on the map.** The Buffet's dungeon step already marked Sir Loin's gate (Part 1.2);
   Sir Loin now acknowledges a mended loaf ("Tell Basil"). The Dump's main line marks the Magic Bean by the stream and the West Sprout Mound
   from the favour step on, until a bridge is grown; the Centre Bridge sign and Moss Mulligan's refusal name the bean. (Two of Billie's three
   animals graze across the water: inbox 10 asks whether to move one.)
3. **Keep the main quest in the HUD; a place name on every row.** A side quest in hand keeps the tracker when the next side quest is accepted
   (a favour still takes it from the main quest's "finish a favour" step; a main quest still takes it from a side quest). Every "Point me
   to..." row names its area; goals of one name make one row. Plus the two physical blockers: the forecourt strip beside the House of Gains'
   stairs is rubble now (the hero cannot squeeze in past the cheek wall), and the Steps banner sits on the stairs, not 14 m round them.

Not changed: Old Man Mountain in front of the gym hall and Brother Bramble at the greenhouse door stay (the route arrow walks round them);
the D.N.A.'s "finish a favour" step before an open door is the design (inbox 12); the Delt ripper out of order is a world feature.

Tests: `tests/world/test_route_guide_nov10.gd` (5: the gap, the gate, no route, a moved target), `tests/world/test_route_guide_zones_nov10.gd`
(3: the real Gainlands, Buffet and Dump routes), `tests/core/quests/test_wayfinding_nov10.gd` (5: the tracker rule, the list rows, the Dump's
parts, the story lines, the pocket). The quest audit, the zone and quest suites green after the change.

## Part 2 - a turn is both players' turns

`GameState.turn_number_of(half) = max(1, floor((half + 1) / 2))`: the engine's own counter still advances once per side (every internal
threshold keyed on it - the AI's stall rule, the item policy, Processing X, "until the start of its controller's next turn" - is untouched,
so nothing happens at a different moment). What the player reads:

| Where | Before | Now |
|---|---|---|
| Battle HUD turn panel | "Round N" / "Your turn" - "Enemy turn" | "Turn N" / "Your turn" - "Enemy's turn" |
| Board ribbons | "Round N" | "Turn N" |
| Battle log header | "-- Your turn --" / "-- Primm's turn --" | "-- Turn 1: your turn --" / "-- Turn 1: Primm's turn --" |
| Boss Setting Up (pre-fight panel, rules panel) | "Its units do not attack in rounds 1-2; they can attack from round 3" | "...in turns 1-2; they can attack from turn 3" (same window: the boss takes its N-th turn inside Turn N whichever side goes first) |
| Setting Up countdown under the turn label | "Setting Up: 2 rounds left" | "Setting Up: 2 turns left" - `setup_turns_left = clamp(window - turns_taken + 1, 0, window)`; countdown and panel agree (test: 2, 2, 1, 0 for turns taken 0..3) |
| Result lines | "in N rounds" | "in N turns" (`p1`... the Victory panel: "You defeated Quota Spotter in 1 turn") |
| Card text (34 cards + 1 token) | "until end of turn" | "until the end of your turn"; the traps that fire on the enemy's turn (BR-07, C-16, GB-04, GRB-01): "until the end of the enemy's turn" |
| Glossary / keyword info | "Round" | "Turn" (one turn = both players' turns; "your turn" and "the enemy's turn" are its halves) |
| Tutorials, status info, campaign start, pre-fight texts | rounds | turns |
| Sims and tools (`record.turns`, `turns_played`, `node_turns`, the "turns avg" print) | half-turns | turns (inbox 6: their numbers are half what they were) |
| `docs/design/combat_rules.md` Turn Structure | - | the paragraph above |

Energy: the end-turn question and the hand tooltips count the same pool (`GameState.energy_available`: ready infrastructure + the pool), so
the two contradictory messages are one. Shots: `p2_before_the_fight_setting_up_turns.png`, `p2_hud_turn1_your_turn.png`,
`p2_battle_log_turn_header.png`. Test: `tests/core/test_turn_counting_nov10.gd` (6).

## Part 3 - hand cards show this fight's numbers

`CardView.apply_instance` already drew a unit's live attack and toughness; now a shrunk attack reads red (Primm's 3/3, Red Tape) as a shrunk
toughness did, and the cost is live too: `game.generic_cost_for` + `pips_for` against the printed `energy_value()`, green when cheaper, red
when dearer, on the framed socket's number and on the plain face's pip row (`PipRow.generic_override`). `BattleBoard.sync_state` re-applies
every live view each sync (a view was asked once, when it was made - a rule that arrived after the draw never reached the hand). The
right-click preview adds `BattleHud.now_line`: "In this fight: 7/4 (printed 3/3); costs 2 (printed 3)." - only the parts that differ. No
layout changed. Under Primm's Standardization a postgame hero's Carpool (printed 3/3) reads 7/4 in green: 3/3 plus the hero's boons and gear
(`p3_primm_hand_live_numbers.png`, `p3_primm_hover_carpool.png`; the right-click preview of the Overclocked Mill Worker: "In this fight: 7/4 (printed 2/4)." in gold under its text, `p3_primm_peek_in_this_fight.png`). The House of Gains' Home Gym (+1 attack for Beefcake units) shows the
same way; a Colorless hand (Courier Pigeons, Village Militia) keeps its print. Tests: `tests/ui/test_hand_numbers_nov10.gd` (3: Primm's 3/3 in
red with the printed values in the preview line, a cost reducer in green and a tax in red on both faces, a zone rule's pump in green kept
through a rebuild).

## Part 4 - rewards and the defeat text

- "Losing costs nothing" and its cousins are gone from the defeat panels, the Old Well's confirm and the level hints; a dungeon defeat says the
  dungeon starts over from its first room and that the cards and gold you won are kept.
- Rewards (`docs/design/balance_log.md`, "Fable pass Nov 10, Part 4"):

| What | Before | Now |
|---|---|---|
| Every fight inside a dungeon (normal, elite, boss; main and side) | gold x1, XP x1 | gold x1.5 (rounded to 5), XP x1.5 (`Economy.DUNGEON_FIGHT_BONUS`); picks and packs unchanged; the tutorial cave is not a dungeon run |
| Clear bonus at the boss | the run's gold once more | 0.8 of it (`CLEAR_BONUS_SHARE`) |
| Main dungeon first clear | 200 gold, XP 0.5 of a level step, pack bonus 150 gold / 100 XP | 160, 0.4, 120 / 80 |
| Side dungeon first clear | 100 gold, XP 0.15 of a step | 80, 0.12 |
| Primm's Castle, the Lab, the Shattered Gallery | 400 XP; 400/400; 1500 gold | 320; 320/320; 1200 |
| Repeat clears | 300 main / 200 side | unchanged (not a completion reward) |

- Gold study (`docs/design/sim/nov10/gold_study_nov10.md`, the economy model paying the +50 % the game pays): **22,771 gold no-grind** against
  the ~21.2k target (+7 %, inside +/-10 %, so no re-tune); 12,971 left after the shopping list; a completionist needs about 135 extra fights
  (9.0 h) at the best grind.

## Part 5 - the Hall Pass Slippers

Boots: the slot with the fewest pieces (7 boots against 9 helms, 11 armours, 15 weapons, 19 relics). Uncommon, tier 2, **500 gold on Madame
Mirepoix's gear shelf** in the Endless Buffet (a mid-game shop at the gear price formula) - picked over a side-quest reward so a player who
hates the gravy can buy their way out. "Outside battle, roaming troublemakers and hazards can't hurt you: no HP lost to bumps, rifts, pits,
gravy or falls." Flavour: "Paperwork says you're excused. The paperwork is laminated." `Modifier.Kind.WORLD_IMMUNITY`, `ZoneRun.world_damage`:
every zone-HP hit outside battle (roamer bumps, the Buffet's gravy and rift stations, the Dump's falls and pits, the Gainlands' hazards) goes
through it and shows "Hall Pass Slippers: no harm done. The paperwork says you're excused." Battles and story damage are untouched. Icon: the
Traveler's Boots stand in; `ICON-EQ-HALLPASSSLIPPERS` is on `docs/art/art_needed_nov2.csv` with an image description. Test:
`tests/core/test_hall_pass_slippers_nov10.gd` (3).

## Finish

- **Tests:** **2942 tests in 31 shards: 2940 passing, 0 failing, 2 risky** (the same two no-assert tests as before). The parts had broken six test expectations, all fixed and re-run green: R-08's card script hash (the "your turn" wording; `import_cards.sh --stamp`), the Old Well's steps now marked like every step, Setting Up said in turns, 26 pieces and 4 on Mirepoix's shelf, the defeat line's new words. The sharded run was stopped once by the memory guard (free RAM under 800 MB with Chrome and Defender busy); the rest ran one shard at a time with a check before each.
- **RC3:** `builds/TheWaywardPath-v1.0.0-rc3-windows.zip` (734 MB; RC2 was 734 MB too); `builds/_export/` holds the unzipped build. Release smoke on the exported
  pack: **PASSED** (`_screenshots/release_smoke_exported.log`). The short exported-build checklist (runs A-C of the RC1 scripts on the test pack): **done, 0 SCRIPT ERRORs**: the three RC1 scripts on the RC3 test pack - A (fresh settings: title, Credits, a new game through the intro, Crosspath, a shop, the Deck Station, the Wardrobe, the packs page, a battle, the pause menu, a setting, Copy log, a manual save, quit, load; 16 shots), B (seeded with A's settings: Settings, save and Continue, the Gainlands quiz; 8 shots), C (quality 0: a zone, the town, a battle; 4 shots) - `_screenshots/exported/x*.png`, `y*.png`, `z*.png`.
- **The exported-build critic:** a no-context critic (brief `docs/review/critic_exported_midgame_nov10_brief.md`, report `docs/review/critic_exported_midgame_nov10/report.md`; 33 runs, 40.8 min of game time on the RC3 test pack, no `dev autowin`, no SCRIPT ERROR) replayed the Buffet from arrival to the Test Kitchen's boss: **clarity 7 (was 5), fun 6 (was 4), polish 7**. It stood 8 m from the door after 18.3 min on foot, guided by the tracker, the map's blue circles, the dotted route, the gate's sign and Basil; it used `dev travel` into the dungeon only after a roamer beside the door ate two approaches. What it credits: the gate sign and Basil's hand-in line, the dotted route and the labelled arrow, the Defeat card's recap, the right-click preview's "In this fight: 2/3 (printed 1/1)", "Turn 1 / Your turn". Its top 10 (verbatim in the report): (1) the main quest's dungeon step should say "Sir Loin's gate wants Old Meatloaf mended - see Basil" (the step marks the gate on the map, but its "Where to go" text does not say it: a one-line text fix for the next pass); (2) a roaming Gelatin Sentinel camps the Test Kitchen door; (3) 9-11-turn fights; (4) the boss's token swarm overlaps; (5) Setting Up is an unlabelled hourglass during the fight; (6) toasts stay 20-30 s; (7) the E prompt prefers plaques to the quest NPC; (8) walking costs HP (bumps, the gravy); (9) the "Point me to..." list reorders between opens; (10) a stale favour toast and Escape over pop-ups. Fixed tonight from its notes: the respawn toast still said "Losing costs nothing" (gone), and the dotted route grazed the Soup Fountain (routes now keep a 0.6 m body clear of props). The rest is logged for the owner (inbox 14).
- No public upload. Commits: Part 1 (`170722b5`, `731e720c`), Part 2 (`26847a85`), Part 4 (`a305b9df`, `4b9e85f4`), Part 5 (`d3b775cf`),
  Part 1.6 + Part 3 (`ebcbdad3`), Finish (the Finish commits that follow `ea2a6377`).

### Screenshots (`docs/overnight_shots/nov10b/`)

| File | What |
|---|---|
| `p1_point_me_list_buffet_quests.png` | the Buffet map with Mend the Meatloaf and the Pantry Run active: every part a goal, the list open over the map |
| `p1_map_goals_buffet.png` | the legend's one line per quest goal |
| `p1_point_me_list_gainlands.png`, `p1_point_me_list_dump.png` | one row per goal name, the area in brackets, "via" rows; the Dump's bean and mound rows |
| `p1_map_route_gainlands.png` | the dotted route from the bridge up the middle road to the House of Gains |
| `p1_route_arrow_critic_dead_end.png` | at (49, 55), where the critic gave up: the waypoint arrow at the road's foot to the east |
| `p1_route_arrow_middle_road.png` | the waypoint arrow up the Gauntlet |
| `p1_map_route_buffet_ferry.png` | the Buffet's route crossing the Gravy River on the Lazy Susan |
| `p1_route_arrow_dump_arrival.png` | the Dump: "The Rotheart" arrow north toward the Centre Bridge's foot |
| `p2_before_the_fight_setting_up_turns.png` | Primm's pre-fight panel: "Setting Up: ...in turns 1-2; they can attack from turn 3" |
| `p2_hud_turn1_your_turn.png` | the HUD: "Turn 1 / Your turn" |
| `p2_battle_log_turn_header.png` | the log: "-- Turn 1: your turn --" |
| `p3_primm_hand_live_numbers.png` | Primm's fight: the Militia 3/3, the hand's live numbers |
| `p3_primm_hover_carpool.png` | the raised Carpool: 7/4 (printed 3/3) |
| `p3_primm_peek_in_this_fight.png` | the right-click preview: "In this fight: 7/4 (printed 2/4)." |

---

# Overnight Nov 9-10 (Opus) - report

Brief: `docs/prompts/overnight_nov9_opus.md`. Start tag `pre-overnight-nov9b`. Questions: `docs/overnight_inbox.md`, "Overnight Nov 9-10".
Shots: `docs/overnight_shots/nov10/`. One Godot at a time; no sub-agent ran while a Godot of mine did (the two critics were the only Godot
while they played). The Fable Nov 9 report follows below.

## At a glance

- **RC2 is built:** `C:\Dev\Deckbuilder-rpg\builds\TheWaywardPath-v1.0.0-rc2-windows.zip` (**734 MB**, next to RC1's 736 MB). Release smoke on
  the exported pack **PASSED 17/17**; the exported-build checklist (runs A and B) and a Low-end walk all fine, 0 SCRIPT ERRORs. Notes for
  testers: `docs/release/rc2_notes.md`.
- **Fixed tonight (with shots below):** 17 critic findings across the three reviews - the bright forest, the textured fountain, the cave flood
  guard, the attack-aware end-turn question, "Point me to...", the Path choice strip, Primm's opening army (4 -> 3 Militia) and countdown,
  no cut-outs over stills, Basil, the Buffet hints, and smaller text fixes. Plus the Text size switch and the key-rebinding guard.
- **The critics' top 10s:** Part 2 below (midgame: clarity 5, fun 4, polish 6; late game: clarity 5, fun 4, polish 5). Both lost the hard
  fights they met at the recommended level; the late critic could not beat Primm in six tries, which is why his first phase is easier now.
- **The dialogue tool:** Part 3 below, in plain steps (three commands; tested on ten fake edits, then the test files were deleted).
- **Accessibility and controller:** a single Text size switch, Large checked at 1280x720; every menu and all ten minigame screens walk with a
  pad only (tests + the gamepad smoke, 540 pad events, 0 key/mouse); rebinding can no longer leave Move / Interact / Pause without a key.
- **Size and performance:** Low-end on the exported build runs at its 30 fps cap in Crosspath, the Capital and a battle (memory below). The
  pack has almost nothing unused left (0.8 MB found; the macOS icon and four orphan pictures removed, ~2 MB). The Capital's later visit is
  **6.1 s** (was 6.2 s): the remaining pieces were not cached tonight (reason and plan in Part 5).
- **Tests:** full suite in shards **2907 / 2909 passed, 0 failing, 2 risky** (the same two no-assert tests as before). New tests: flood guard,
  text size switch, key-rebind essentials, pad walks for the Wardrobe / Tailor / pack shop / nine minigames; the boss tempo test updated.
- **Before the public release, the owner should:** (1) play the RC2 zip once; (2) decide on Primm (inbox 4: 3 Militia, re-run the sim when the
  PC is free); (3) send `rc2_notes.md` + the Restricted itch link to playtesters; (4) when their workbooks come back, run the three dialogue
  commands (Part 3); (5) on release day: `config/version` to `1.0.0`, export, smoke, upload, flip to Public (`docs/release/itch_upload.md`).
  Decide later: the Capital caching (inbox 5), the battle board's infrastructure row and two-row hands (both critics), the Gainlands kit.

## Part 0 - the Fable pass

Nothing left: its report marks the import, RC1, the exported-build checks, the critic's quick fixes, the itch kit, the trailer and the
handover as done.

## Part 1 - the RC1 critic's findings (first hour)

| # | Finding | Effort | Done |
|---|---|---|---|
| 1 | Cave entrance trigger missable | S | fixed on Nov 9 (whole doorway answers E); the chest beside it can no longer steal the press (the gate wins inside 3 m) |
| 2 | First fights drag (8-11 rounds) | M | **Cave flood guard:** in the Forgotten Cave only, once you hold 5 infrastructure (play + hand) an infrastructure draw is swapped for the next non-infrastructure card (`GameOptions.flood_guard`, `FirstDuel.CAVE_FLOOD_GUARD`, test). Sims (60 runs per Path): the AI player clears the Scavenger in 2.9-4.1 rounds with or without it, so the critic's long fights were human floods; the guard caps them. The sim tool now prints rounds per node. |
| 3 | White fountain / plinth blocks in Crosspath | S | the fountain carries the painted stone-wall texture, tinted sandstone. Before `p1_fountain_before_rc1.jpg`, after `p1_fountain_after.jpg` |
| 4 | Near-black forest, heavy blur | S | `starting_forest.json`: key 0.42 -> 0.62, ambient 0.62 -> 0.92, exposure 1.05 -> 1.32, vignette 0.5 -> 0.36; tilt-shift halved. Mean brightness 26 -> 35 (+33 %). `p1_forest_before.jpg` / `p1_forest_after.jpg`. Camera zoom not changed (shared by every area). |
| 5 | Gainlands low-poly kit; fight starts with a toast | L | **L** - plan: run the painted-texture presets (as Crosspath) over the Gainlands ground and walls, and give roamers a first-meeting line. |
| 6 | "End your turn?" while picking attackers | S | asks "End the turn without attacking? You have N attackers selected..." instead |
| 7 | Esc does not close a shop | - | not a bug (Nov 9) |
| 8 | "Where to?" sets a goal | S | renamed "Point me to..." with a tooltip saying the arrow leads there after the map closes |
| 9 | Bark bubbles over name plates | S | fixed on Nov 9 |
| 10 | Path cards unreadable until More | M | the strip keeps the picked Path described after the pointer leaves, and shows its Resource on hover |
| notes | forest hint line lacked M: map | S | added |
| notes | stray glyph label in the dump | - | the font warm-up: a 3 x 3 px clipped label at 2 % opacity - invisible |
| notes | first-duel popups stack; level-up over the card reward; Esc during talk opens pause | M | kept: the tip already sits clear of the mulligan panel; the other two are in the backlog |

## Part 2 - exported-build checks of the mid and late game

Two fresh critics with no context, each given only its brief (`docs/review/critic_mid_brief.md`, `critic_late_brief.md`), played the
exported RC1 pack with snapshots to jump ahead. Reports: `docs/review/critic_mid_nov10/report.md` (42 shots) and
`docs/review/critic_late_nov10/report.md` (41 shots; saved by me - the harness would not let the agent write it).

**Midgame** (level-14 snapshot, the Endless Buffet and the Test Kitchen; ~30 min of game time, 16 runs): **clarity 5, fun 4, polish 6**. No SCRIPT ERROR.

| # | Problem (critic) | Sev. | Done |
|---|---|---|---|
| 1 | The Test Kitchen beat it three times at level 14; a loss restarts the dungeon | major | not changed (the pilot played; the level hints cover it); the defeat text no longer says "losing costs nothing" in a dungeon |
| 2 | Sir Loin's gate ingredients have no marker | major | the favour's hint names where the truffle and the salt are |
| 3 | Basil hidden behind the soup fountain; E at 2.3 m did nothing | major | Basil 3 m east, talk reach 1.8 -> 2.4 m |
| 4 | Huge milky fade polygons | major | not reproduced tonight (inbox 7) |
| 5 | Played infrastructure tiny; unit rows touch | major | L (battle board layout) - backlog |
| 6 | Old Hob's portrait stuck after a defeat | major | not reproduced tonight (inbox 7; in the RC2 known issues) |
| 7 | Zone counters disagree (4 of 4 after one boss) | major | likely the bot snapshot's flags + `dev win`; logged (inbox 7) |
| 8 | Meatballs knock 2 HP off on arrival | minor | the meatballs live far from the bridge; it was the snapshot's arrival spot. Kept |
| 9 | Map labels pile up; "The Beefcake Rift Express" in the Buffet | minor | the map now says "Rift Express station" |
| 10 | Small UI collisions (popups over the HP panel, clipped Open, tooltips) | minor | backlog |

**Late game** (level 20-24 snapshots, the Capital, Primm's Castle, six real Primm fights, the Lab; ~50 min, 25 runs): **clarity 5, fun 4, polish 5**. No SCRIPT ERROR.

| # | Problem (critic) | Sev. | Done |
|---|---|---|---|
| 1 | Primm is a wall: six phase-1 losses by round 4-5 (L20 and L24), "Militia dealt 36 of 39" | blocker | **Standing Army 4 -> 3 Militia** (inbox 4); the countdown fix below |
| 2 | `c13end` / `c13post` snapshots load before Primm | blocker (review only) | tooling: re-save them (inbox 6) |
| 3 | Speaker cut-outs pasted into stills that already show them | major | no cut-out over a painted still any more (the name plate stays) |
| 4 | Primm on "a sunny village" board | major | it is the Model Room's miniature kingdom (`BB-PC-BOSS`); kept, art question (inbox 8) |
| 5 | Rules contradict the screen (3/3 vs 7/4 hand cards; "Setting Up: 3 rounds" for a 2-round window) | major | the countdown never exceeds its window now (test); hand cards showing standardized stats is M - backlog |
| 6 | Invisible infrastructure, two-row hands | major | L - backlog (same as mid #5) |
| 7 | Tracker "1 done" | minor | "1 earlier step done (J: the full list)" |
| 8 | Template boss reward line | minor | Primm's node: "three duels in a row (56, 52 and 50 HP), your HP carried between them. At stake: the kingdom." |
| 9 | Dialogue: skip prompt repeats its title; two box styles; Esc opens pause on first lines | minor | the prompt reads "Skip this scene? / You haven't seen it yet."; the rest backlog |
| 10 | Outer Capital: flat white wall backdrop, unseen Tidy-Bot hits | minor | backlog |

## Part 3 - the playtesters' dialogue tool (plain steps)

`tools/import_playtester_dialogue.py` (standard library only - no packages to install). When the testers send their workbooks back:

1. Put the returned `.xlsx` files in one folder, e.g. `docs/dialogue/returned/`.
2. `python tools/import_playtester_dialogue.py docs/dialogue/returned/*.xlsx` - reads each file's "Dialogue" tab (ID in B, New line in H,
   Notes in M, Reviewer in N), skips empty New lines, and checks every rewrite against the game's current text: the ID exists, every
   `{token}` / `[tag]` / `%s` is kept, one line, at most 240 characters (90 for barks). Rows added, deleted or sorted are reported (matching is by
   ID). Two testers rewriting the same line differently is a **conflict**: both are listed, neither is taken.
3. Read `docs/dialogue/playtesters_nov9_merged_report.md` (accepted / rejected with the reason / conflicts / sheet structure).
4. `node tools/apply_dialogue_pass.js --csv=docs/dialogue/playtesters_nov9_merged.csv` - the usual dry run (also checks every line fits its box).
5. The same with `--apply`. Undo with `--revert`. Settle a conflict by putting the chosen line in a CSV (`id,new_text`) and running
   `... --merge=<file> --apply`. Run the tests.

**Tested** on a copy of the workbook with ten fake edits by two fake testers: 4 accepted (one identical rewrite from both counted once),
4 rejected (a dropped `{town}`, a 326-character line, a 101-character bark, an unknown ID on an added row), 1 conflict listed, the sorted rows
reported; the importer's dry run took all 4 ("4 would apply, 0 conflicts"). The test files were deleted. HANDOFF section 5 has the workflow.

## Part 4 - accessibility and controls

- **Text size:** Settings > Text > "Text size (dialogue, cards, tooltips)": Normal / Large / Larger (sets the three per-kind sizes, which stay
  below it; "Custom" when they differ). Saved. At 1280x720 on Large: the dialogue box and the battle fit (`p4_large_text_dialogue_1280.jpg`,
  `p4_large_text_battle_1280.jpg`; the UI is one 1920 canvas scaled to the window, so the layout is the same at every size). Test:
  `tests/ui/test_text_size_master_nov10.gd`.
- **Controller pass:** the gamepad smoke (title, Path choice, gate, Crosspath, Sable's shop, a pack, the Deck Station, a duel turn, level-up,
  the menus, the map, the pause menu and Settings > Controls) **OK, 540 pad events, 0 key or mouse events**. The pad-walk test now also walks
  the **Wardrobe, the Tailor, the pack shop and nine minigame screens** (quiz, Dex's table, growth grid, match, order, recipe, reps, sort, tubes):
  every button reachable with the D-pad, no dead ends (19/19). The Gainlands wheel panel needs a zone run; the smoke covers zone screens.
- **Key rebinding:** works and is saved (existing tests + new `tests/test_keybind_essentials_nov10.gd`). New guard: moving, Interact and Pause
  can never be left with no key (clearing the last key, or taking it for another action, is refused with a message), and Pause keeps Esc in
  its first slot. Esc, Enter and Tab stay reserved for menus.

## Part 5 - performance and size

**5.1 The Capital's later visit** (`bash tools/run_loading_timing.sh <run> final`, LOAD_TIMING=1): **before 6.2 s, after 6.1 s** (noise).
Warm breakdown: the builder 3.1 s (buildings other than the houses 0.8, props 0.6, landmarks 0.45, merge 0.3, signs 0.1, rifts 0.16),
the Capital's dressing 0.39 s, the first settled frames 0.54 s, fades 0.7 s; the painted ground is already cached (new detail marks in
`painted_terrain.gd` show its splat at 4-18 ms warm). Every remaining piece registers walk blockers as it builds, which is exactly what made
the cached Crosspath buildings break the walk smoke in October. Not done on release eve. **Plan (M-L):** cache each piece's meshes *and* its
blocker list together (`BuildCache.fetch` of {scene, blockers}), one piece at a time, with the Capital walk smoke run cold and warm after each.

**5.2 Low-end on the exported build** (rc2 test pack, settings low_end / quality 0 / 30 fps cap / 75 % scale; `p5_le01_crosspath.jpg`,
`p5_le03_capital.jpg`, `p5_le05_battle_mid.jpg`):

| Place | FPS | Frame (process) | Working set | Video memory |
|---|---:|---:|---:|---:|
| Crosspath | 30 (cap) | 7-10 ms | 1.48-1.52 GB | 946-950 MB |
| The Capital | 30 (cap) | 10-24 ms | 0.99 GB | 870 MB |
| A battle | 30 (cap) | 8-17 ms | 0.92 GB | 590-614 MB |

**5.3 Download size:** RC2 zip **734 MB** (RC1 736), pack 844.8 MB, 14,092 files. The 20 largest entries are all music (MUS-CREDITS 6.1 MB,
then the boss and battle themes at 3-3.7 MB each, Vorbis q6 by design) and the Capital rim's baked geometry (4.2 MB). By folder: music 306 MB,
textures 441 MB (the zone kits 30-54 MB each, the world sprites 36 MB). `node tools/reference_graph.js --list` finds only **0.8 MB** of exported
files nothing references (cosmetic icon sizes the game builds by name - kept); removed from the export: the macOS app icon (1.9 MB, the
Windows build embeds the .ico) and four bestiary pictures with no entry. No superseded art or test files are packed. Against
`docs/build_size_policy.md`: over the 750 MB pack warning only because of the music, as decided. New: `node tools/verify_pck.js <pck> --largest=20`.
The export now ignores `_movie/` (the 931 MB trailer capture made the size guard expect a 1.5 GB pack and stop the first RC2 export).

## Part 6 - RC2

- `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0-rc2`: the first try stopped at the guard (the `_movie` estimate above; nothing
  replaced); the second (`EXPORT_SKIP_BAKE=1`, keeping the bake the first run had just made) **EXPORT OK**: every MD5, 89 baked shaders, zip CRCs.
- **Release smoke on the exported pack: PASSED 17/17** (title shows v1.0.0-rc2).
- **Short exported-build checklist** on the rc2 test pack: run A (title, Credits, a new game, Crosspath with the new fountain, Sable's shop, the
  Deck Station, the Wardrobe, the Card Packs page, a battle, the pause menu, Reduce motion, Copy log, the save slots), run B (Reduce motion still
  ticked after a restart), the Low-end walk. 0 SCRIPT ERRORs. The real-exe fresh-install runs (`exe_drive.ps1`) were not repeated (the exe is
  the same stock binary; only the pack changed).
- Notes: `docs/release/rc2_notes.md`. Zip: `C:\Dev\Deckbuilder-rpg\builds\TheWaywardPath-v1.0.0-rc2-windows.zip`. CHANGELOG entry added.

## Commits (all pushed)

`99df27fd` Part 1, `b9ac7b83` Part 3 + briefs, `3917e1e6` Parts 2 + 4 (first half), `74f728dd` Part 2 fixes, version bump, `d9e66405` RC2,
then this report.

# Fable Nov 9 - report

Brief: `docs/prompts/fable_nov9.md` (with the day pass `docs/prompts/day_nov9.md` as Part 0). Questions: `docs/overnight_inbox.md`,
"Fable Nov 9". Shots: `docs/overnight_shots/nov9c/`. Run on Fable 5.1, one Godot at a time, no sub-agent while a Godot of mine ran; the
critic (a sub-agent) was the only Godot while it played. Last night's report follows below under "Overnight Nov 9 - report".

## At a glance

- **Import table with screenshots:** Part 1 below (23 images, all in the game). **The Pip pick:** `V-THREADWELL_DELIGHTED` (not the -ALT).
  **Other Sable images found:** none beyond her portraits, sprites and the figure-less shop background; nothing to redo.
- **Exported-build issues found and fixed:** the title screen ignored Enter from the keyboard (fixed); everything else matched the editor. Part 2.
- **The critic's top 10:** Part 2.3 below (first impressions 8, clarity 6, fun 6, polish 6; two of the ten fixed tonight, one was the critic's own script, the rest in the backlog).
- **Where the RC1 zip is:** `C:\Dev\Deckbuilder-rpguilds\TheWaywardPath-v1.0.0-rc1-windows.zip` (736 MB). Notes for testers: `docs/release/rc1_notes.md`.
- **Trailer:** done, 44 s, `C:\Dev\Deckbuilder-rpguilds	railer_rc1.mp4` (+ poster frame). Part 3.
- **What the owner does next:** (1) play the exported zip once yourself (unzip, run `TheWaywardPath.exe`); (2) create the itch page from
  `docs/release/itch_upload.md` and `docs/release/itch_page/` (text, tags, the AI disclosure field, "$0 or donate", the 8 screenshots, the cover),
  upload the zip, keep it **Restricted**; (3) upload the trailer to YouTube and link it on the page; (4) send the Restricted link + `rc1_notes.md`
  to playtesters; (5) collect their F8 reports / logs (`post_1_0_backlog.md`, section 1); (6) on release day set `config/version` to 1.0.0, export,
  smoke, replace the upload, flip to Public (`itch_upload.md`, step 9). Decide later: the first-fight length, the fountain blocks, the forest light and
  the Gainlands kit (the critic's majors 2-5), and whether to soften Primm / the Gallery if story-only testers stall despite the level hints.
- **Tests:** full suite in shards after every change: **2890 / 2892 passed, 0 failing, 2 risky** (pre-existing tests with no assertion). New tests:
  `tests/core/sim/test_level_hints.gd`, `tests/core/data/test_art_patches.gd`, the title focus test in `tests/test_title_art.gd`, the credits and
  un-held variants in `tests/ui/test_release_basics_nov9.gd`.
- **Commits (all pushed):** Part 0 `d1025a81`, Part 1 `0981a1af`, Part 2 `8653663d`, Finish (this commit).

## Part 1 - Batch 14 + Sable (23 images, all in the game)

Filed with `node tools/batch14_move.js --apply` (Pending Review/Batch 14 -> Approved_*; every replaced file to Drive `Superseded/` and a local copy in
`_art_source/superseded_batch14/`; Sable's old world sprites moved out of Approved_WorldTest). Importers run one Godot at a time: portraits, NPC sprites
(+ `sprite_normals.gd --only=SABLE --force`), card art, key art, bestiary, icons. Rows in `docs/art/batch14_nov9.csv` say "In game (Fable Nov 9)".

| Image | Replaces | Where it shows | Screenshot (`docs/overnight_shots/nov9c/`) |
|---|---|---|---|
| V-SABLE, V-SABLE_PLEASED, V-SABLE_SCHEMING | her three portraits (the redesign: fox, high jabot, no cleavage) | Sable's talks and shop | `b14_sable_talk.jpg` (real talk), `b14_v-sable_*_talkbox.jpg` (base, pleased, scheming) |
| SPR-SABLE-FRONT_IDLE / SIDE_IDLE / BACK_IDLE / FRONT_TALK (+ REF) | her four world sprites, `_n` normal maps regenerated | her stall in Crosspath | `b14_sable_stall_sprite.jpg` |
| V-TONIC_EXCITED, V-TONIC_OOPS | the human-woman variants (now the frog) | Tilly Tonic | `b14_tonic_talk.jpg`, `b14_v-tonic_excited_talkbox.jpg`, `b14_v-tonic_oops_talkbox.jpg` |
| NPC-GATEKEEPER_HAPPY, NPC-GATEKEEPER_STERN | the bearded-human variants (now the bear) | Brannoch | `b14_brannoch_talk.jpg`, `b14_npc-gatekeeper_happy_talkbox.jpg`, `..._stern_talkbox.jpg` |
| V-FENWICK_EXCITED | the human variant (now the magpie) | Fenwick | `b14_fenwick_talk.jpg`, `b14_v-fenwick_excited_talkbox.jpg` |
| V-THREADWELL_DELIGHTED | the human variant (now the mouse) | Pip | `b14_pip_talk.jpg`, `b14_v-threadwell_delighted_talkbox.jpg` |
| RES-IRON, BAS-G, B-13 | the glossy 3D plate, the cobalt vector Feastforge, the B-26 twin | hand and full size | `b14_hand.jpg` (all three in hand), `b14_cards_full.jpg` |
| STORY-PRIMM-P1, STORY-PRIMM-P2, STORY-REVEAL-KITCHEN | the giant-scale stills | the castle's phase cutscenes, the Test Kitchen reveal | `b14_primm_p1.jpg`, `b14_primm_p2.jpg`, `b14_reveal_kitchen.jpg` (real cutscene screen) |
| BST-ANTECHAMBER-SENTRY | the Windows-logo visor | the Collection Book's Bestiary, the Lab fight | `b14_bestiary_sentry.jpg` |
| ICON-ITEM-FIELDBANDAGE | the red-cross icon (now a leaf) | Tilly Tonic's shelf, the bag | `b14_item_vendor.jpg` |

- **The Pip pick:** `V-THREADWELL_DELIGHTED` (the first try). Against the base V-THREADWELL it keeps the hat's angle and bands, the patchwork coat
  with the same diamond patches and shoulder strap, the ears and the red neck ribbon. The `-ALT` has a steeper hat, much bigger ears and a pink
  sash; it is in Drive `Superseded/` (and `_art_inbox/batch14/`).
- **Held expressions:** `Portraits.HELD_EXPRESSIONS` is empty now (all five sets repainted on-species); the mood portraits show again. The release-basics
  test asserts the eight variants are offered and that Sable's pleased face is its own picture.
- **Other Sable images in the game:** searched every asset, data file and art sheet for her. Found only her three portraits, her four world sprites
  (both replaced) and her shop background `VS-SABLE` (the velvet salon: cards, curtains and shelves, **no figure** - nothing to redo). No card, still,
  loading painting or title art shows her. Nothing added to the art list for Sable.
- **The Red Cross emblem:** still on NPC-HESPER's cap and armband and on Hesper in STORY-EPI-WRINKLES. Fixed in code: `core/data/art_patches.gd`
  recolours red-dominant pixels inside two small normalised boxes per picture to a muted leaf green as the picture loads (Portraits and KeyArt call it;
  test `tests/core/data/test_art_patches.gd`). Seen in `b14_npc-hesper_talkbox.jpg` and `b14_epi_wrinkles_green_cross.jpg`. Two **REDO** rows added to
  `docs/art/art_audit_nov9.csv` (a leaf or heart instead of the cross). The new bandage icon has no cross.
- **Size and memory** (`docs/build_size_policy.md`): the 23 replaced files total 4.28 -> 4.66 MB in the repo (**+0.38 MB**; the portraits and cards are a
  little richer, the sentry doubled at 60 -> 91 KB, two stills shrank). Same count and import rules as before, so the pack moves by well under 1 MB
  against the 750 MB budget (the export in Part 2 gives the exact number). Memory: the same textures at the same sizes; the two patched pictures are
  rebuilt as ImageTextures once when loaded (the same VRAM as before; the CPU-side copy is transient) and sit in the bounded ArtCache like the rest.
- **Tools:** `tools/batch14_move.js`; `tools/story_still_shots.sh --ids=A,B`; `tools/shot.sh res://scenes/town.tscn x --open=bestiary:<Name_with_underscores>`;
  the card gallery's `--ids` now finds resources and infrastructure; the battle `--hand=` flag loads tokens (RES-*) too.
- **Gotchas met:** the portrait importer re-added the opaque NPC-PLAYER (reverted, as before); the NPC sprite importer rewrote the whole manifest
  (spliced only SABLE's entry: canvas 320x504 -> 304x512, `cloak_hue`/`head` kept); the importers' status writer dropped the "UI art kit" and
  "Dungeon maps" sections of `docs/art/art_status.md` (restored from HEAD); `core/zone/zone_defs.gd:46` references Session, which prints a compile
  error in every headless `-s` importer run (harmless: the import still completes).

## Part 2 - RC1 build and the real-build check

**Export:** `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0-rc1` (1.4 GB free RAM; the export's own guard wants 2 GB, its hard stop is
1.2 GB; peak Godot working set 1.3 GB, 14 MB free at the worst moment, every check passed). **Zip:** `builds/TheWaywardPath-v1.0.0-rc1-windows.zip`
= **736 MB** (pack 847 MB, 14,101 files, 89 baked shaders, every MD5 and CRC checked; build folder 952 MB). The pack is over the 750 MB budget
warning because the music is at Vorbis q6 by the designer's decision (`docs/build_size_policy.md` has the new row). Release smoke on the
exported pack: **PASSED, 17/17** (title + version, New Game to the starting area, F8 report + screenshot + log copy, pause menu, no Dev Menu,
save to slot 2 and load back).

**Exported-build test, two layers** (shots `docs/overnight_shots/nov9c/rc1_pack_*.jpg` and `rc1_exe_*.jpg`):

| Check | On the real `.exe` (fresh user folder, real clicks and keys: `tools/exe_drive.ps1`) | On the exported pack (stock binary + test pack, play driver: `tools/play_exported.sh`) |
|---|---|---|
| First launch, no settings or save | ok: title with New Game / Settings / Credits / Quit, v1.0.0-rc1; the Low-end preset picked itself on this iGPU (log: "first launch: Low-end preset") | - |
| New game through the intro to Crosspath | ok: slot chooser, the wake-up still, the forest, the Rescuer, the Path choice (Beefcake), the forest free; Crosspath reached via the driver's jump in the pack run | ok (`x04`-`x05`) |
| Save, quit, reload | ok: autosave after the Path choice; a manual save to slot 1 ("Saved to Slot 1"); Quit Game; Continue on the next launch landed in the forest; Load Game lists the autosave and Slot 1 | - |
| A battle, a shop, the Deck Station, the Wardrobe, the Card Packs page, a minigame | - | ok: Quota's duel played by the pilot then won (`x10`-`x12`), Sable's stall (`x06`), Deck Station (`x07`), Wardrobe (`x08`), Card Packs (`x09`), the Gainlands quiz (`y07`-`y08`) |
| Settings that survive a restart | ok: Reduce motion ticked on launch 2, still ticked on launch 3 (`settings.cfg`: `reduce_motion=true`) | ok: run B seeded with run A's settings shows the tick (`y01`) |
| Low-end mode | ok: auto on first start (quality Low, 30 fps cap, render scale 0.5) | ok: forced quality 0 - town, the Gainlands, a battle (`z01`-`z03`) |
| The log file and Copy log | ok: `%APPDATA%\Deckbuilder-RPG\logs\wayward.log` (+ `.1`, `.2`), boot lines with OS/GPU/driver | ok: "Copied" toast (`x15`) |
| Credits and the AI disclosure | ok: "A game by Alex Glowatz", the licences, the AI section (launch 3) | ok (`x02`) |
| The hidden donation button | ok: no Support button on the title or the Credits head | ok |

**Differences from the editor found and fixed:** none in the game itself. Two things the real exe showed that the editor runs hid:
1. **Keyboard only at the title: Enter did nothing** (no button holds the focus until a pad or the mouse gives it). Fixed: the first keyboard
   Enter or arrow focuses the top menu button (`TitleScreen.keyboard_focus_menu`, test in `tests/test_title_art.gd`). Not re-exported for this
   (an rc1b export is not needed for a focus fix; it is in the next build).
2. The exported build's Escape is matched by physical key: a synthetic Escape without a scan code is ignored (a tooling fact, not a player issue).

**Tools made for this:** `tools/exe_drive.ps1` (drives the exported exe: `wait`, `key`, `press` with scan codes, `hold`, `click`, `shot`; never
touches the player's files - move `%APPDATA%\Deckbuilder-RPG` aside by hand), `tools/play_exported.sh` + a `play` mode and settings seeding in
`tools/run_exported_suite.sh`, the scripts `docs/review/play_scripts/exported_rc1_{a,b,c}.txt` and `exe_{a,b,c,d}.txt`.

**Fresh-eyes critic of the exported build (Part 2.3):** a fresh `general-purpose` agent given only `docs/review/critic_rc1_brief.md` played the
exported pack for about 80 minutes of game wall clock over 34 runs (r1-r33 the straight first hour with no jumps: title, Settings, Credits,
the opening line by line, Beefcake via "More", the forest, all five cave nodes and the Hollow Warden, Crosspath, Maren, every menu, Fenwick,
Tilly, the Power Wraps errand; r34 the only jump: the Gainlands and the House of Gains). Report: `docs/review/critic_rc1/report.md`
(63 shots in `docs/review/critic_rc1/shots/`). It was interrupted once by the account's usage limit and resumed.

| Score | /10 | Why (the critic's words, shortened) |
|---|---|---|
| First impressions | 8 | title, stills and portraits superb; the real 3D forest dark and blurry with a tiny hero; Path cards unreadable until "More" |
| Clarity | 6 | menus and rules panels good; the cave trigger is missable, the end-turn nag fires while picking attackers, "Where to?" sets a goal, Esc does not close Tilly's shop |
| Fun | 6 | the card game is sound, boss / level-up cadence good; the first fights last 8-11 rounds against a 3-HP enemy (infrastructure flood) |
| Polish | 6 | 2D screens about 9/10; white untextured blocks in the Crosspath square, the dark forest, low-poly Gainlands kit, bark bubbles over name labels |
| Unfinished / AI-made | - | most visible: the white 3D fountain and plinth blocks in the square and the low-poly Gainlands; the painted art is openly AI (Credits) but consistent; no template text, no overflowing boxes, no SCRIPT ERROR in 34 logs |

**The critic's top 10** (severity for a new player) and what was done tonight:
1. **Major - the cave entrance trigger** only fired on a small ring beside the stairs; under the arch there was no prompt, every other way an "I'll head back" line; five runs to get in. **Fixed:** the arch answers E from the whole doorway and the bottom step (`StartingAreaScene.GATE_RADIUS` 3.0, was the 1.7 interact radius).
2. **Major - the first fights are too long:** a 3-HP Cave Scavenger lasted 8-11 rounds in four attempts, both decks flooding with infrastructure; 11 of 15 HP lost once. Backlog (balance; the Nov 1 teaching hand helps the very first duel only).
3. **Major - white untextured fountain / plinth blocks** in the Crosspath square beside painted houses. Backlog (the painted fountain and statues are the known art item).
4. **Major - the 3D forest is near-black** with heavy tilt-shift, the hero about 60 px tall. Backlog (known from N8; a light pass).
5. **Major - the Gainlands' flat low-poly kit** clashes with the painted art; the gatekeeper fight starts two steps in with only a toast. Backlog (zone kit texture pass).
6. **Minor - "End your turn? You can still play 1 card"** appears while choosing attackers with one selected. Backlog (suppress during attacker selection).
7. **Minor - Escape does not close Tilly's shop**, only the X. **Not a bug:** reproduced in the editor build (`docs/review/play_scripts/esc_shop_probe.txt`): one Escape closes the shop, tip or no tip (`_screenshots/play/esc_shop_probe/esc_02_after_escape.png`). The critic's script pressed E again beside Tilly two lines later, which re-opened it.
8. **Minor - "Where to?"** sets a goal marker rather than travelling or closing the map. Kept (by design: the arrow leads there after the map closes); the label could say so. Backlog.
9. **Minor - townsfolk bark bubbles drawn over their own name label.** **Fixed:** the bubble sits 30 px above the plate (`NpcBarks.LABEL_CLEARANCE`).
10. **Minor - Path choice thumbnails unreadable** until click + More. Backlog (show "how it plays" and the Resource on hover).

What worked for the critic: the opening and the portraits, the cave node map and the Hollow Warden reveal, the Deck Station and Character
pages, battle readability (hover zoom, the "-1 HP if unblocked" arrow, the Just Arrived tooltip, Speed), the shopkeepers' voices.

**RC1 notes:** `docs/release/rc1_notes.md` (what is in it, known issues, how to report). **The zip:** `C:\Dev\Deckbuilder-rpguilds\TheWaywardPath-v1.0.0-rc1-windows.zip`
(no Drive `Releases` folder exists; `docs/release/itch_upload.md` names the file).

## Part 3 - itch.io page kit, final

- **Re-checked against 1.0.0-rc1** (`docs/release/itch_page/page.md`): the descriptions, the features (deck slots "four to start, more as you
  level" instead of "ten"; the minigames and the postgame named; the comfort options updated: Path symbols on by default, Reduce motion, the
  autosave indicator, level hints), the controls table against `app/keybinds.gd` (tracked-quest keys, dungeon rules R / Y, right-click inspect
  added), the measured requirements (the exported build's own boot log: Ryzen 5 4500U iGPU, 7.4 GB, Low-end auto-picked, 278-370 MB video
  memory in the forest; download about 740 MB, about 950 MB unpacked), the tags (unchanged), the AI disclosure (page text + itch's own
  disclosure field in `itch_upload.md`), and "free, donations welcome" in the pricing note and the long description.
- **The eight screenshots** (`docs/release/itch_page/screenshots/`, 1920x1080, README lists the order): a Buffet-board battle, the wake-up still,
  the Shattered Gallery map, the classroom quiz, the Wardrobe, the Card Packs shelf, Dex's table, the Capital's Gate Plaza. The Nov 8 set is kept in
  `old_nov8/`. (The Capital shot is the Gate Plaza from a postgame save; `dev travel capital` lands inside the dark Crease, and the broken-state plaza
  carries a "Tidy-Bot knocks you flat" toast - neither suits a store page.)
- **Trailer: done, 44 s** - `builds/trailer_rc1.mp4` (11.9 MB, h264 1280x720 30 fps, AAC) + `builds/trailer_rc1_poster.jpg`. Made with
  `bash tools/make_trailer.sh capture` (the play script `docs/review/play_scripts/trailer_rc1.txt` under Godot's movie writer, `--write-movie`
  `--fixed-fps 30`, MJPEG AVI 931 MB in `_movie/`) and `bash tools/make_trailer.sh cut` (ffmpeg: clips at the script's CUT marks, 0.4 s fades, three
  title cards in Cinzel on the game's ink colour, the title theme `MUS-TITLE.ogg` as the only sound, faded out). Clips: the title, Crosspath, the
  Deck Station, the Endless Buffet, a battle (12 s), the Shattered Gallery map. Two captured clips were left out: the Gainlands walk ran into the
  gatekeeper's duel and the Capital clip was the Crease interior. Honest and simple, as asked; itch takes a YouTube/Vimeo link, so the owner uploads
  the mp4 there (or attaches it to the devlog). Gotcha: the play log counts wall-clock seconds while the movie counts frames at 30 fps (the capture
  renders slower than real time), so the cut script scales the marks by movie length / last mark.
- `docs/release/itch_upload.md` names the exact files (zip 736 MB, cover, the 8 screenshots, the trailer).

## Part 4 - handover and the post-1.0 plan

- **`docs/HANDOFF.md` finalised:** section 2 is the exact sequence run today (tests, export with the low-memory switch, release smoke, the test pack
  and `play_exported.sh` runs, the real-exe driver, the critic brief, the upload guide); section 3 the art pipeline with the Batch 14 filing tool,
  the importer quirks met today and the shot commands per kind; sections 4-5 music and dialogue; section 6 the six small-prompt templates;
  section 7 points at the backlog; section 8 the one-line Drive backup (`git archive ... HEAD` into `Card Game Art/Backups/`).
- **`docs/release/post_1_0_backlog.md`:** playtester feedback intake (collect, triage, reproduce, fix and ship, watch the walls), the known issues
  at rc1 (title keyboard focus - fixed tonight -, the walls, the Red Cross stopgap, the Capital load, the pack size, Credits scroll keys, Esc on a first
  viewing, the headless Session error, exit-time leak noise), the remaining art REDOs (Hesper x2, NPC-GUS, 8 bestiary pictures, one gear icon, 8
  unmatched bestiary files), nice-to-haves (the critic's list) and Steam readiness (Steamworks, achievements from feats, cloud saves, store assets,
  Steam Input, Deck, build pipeline).
- Everything is pushed to GitHub after each part (see the commit list at the end).

## Part 0 - the day pass

| Item | Done | Where |
|---|---|---|
| Credits: Alex Glowatz as creator | yes | `data/credits/credits.cfg`; "A game by Alex Glowatz" + "Game design, direction and production: Alex Glowatz" on the Credits page (`01_credits_creator.jpg`), and under the title card in the end credits. Donation link empty: Support stays hidden. |
| Colour-blind symbols on, Dex stays | yes | both already in the game; inbox items 1 and 3 closed |
| Level hints at the walls | yes | every dungeon door (zone side and main dungeons, Swolympus, the Vault hatch, the Lab hatch, the castle, the Gallery, the Paste Works) says "Travellers here are usually around level N" under its prompt, **amber when 2+ levels under** (`02_hall_prompt_level9_amber.jpg` vs `03_..._level12_muted.jpg`); the full map's "Where to?" list says "(Dungeon entrance, usually level 11)" and the dungeon icon has the same line as a tooltip (`06_map_where_to.jpg`). `core/sim/level_hints.gd` reads `ProgressionModel.LEVELS`; test `tests/core/sim/test_level_hints.gd` (every dungeon but the level-1 cave has one). Balance unchanged. |
| Dark battle backdrop | dev-only, fixed | the UI sweep's shot 16 was `dev encounter quota`: its sim group "capital:lieutenant" is not a battle-context key, so the board fell back to the placeholder slate. The real Quota duel always had the Transit Yards board. The sim group is mapped now (`data/battleboards.json`), `07_dev_quota_board.jpg`. |
| itch upload guide | yes | `docs/release/itch_upload.md` (page, "$0 or donate", text, AI disclosure field, zip, screenshots, Draft/Restricted, Support link, playtesters, public flip, butler). |

# Overnight Nov 9 - report

Brief: `docs/prompts/overnight_nov9.md`. Tag `pre-overnight-nov9` marks the start. Questions: `docs/overnight_inbox.md`, "Overnight Nov 9".
**No export.** Last night's report is archived at `docs/overnight/nov8b/overnight_report_nov8.md`. Run on Opus 5.5 (not Fable); Claude
Code's low-memory reaper was *on* for this session, so every long Godot job was started detached and watched from the foreground.

## 1. The four real-fight playthroughs

Every Path played from a new save to the credits and through the postgame (the Lab, the Shattered Gallery, Swolympus, Loose Ends) with
**every fight real**: every node of every dungeon (the tutorial cave, all side dungeons, all four main dungeons, the castle, the postgame),
every gatekeeper, every boss phase. No decreed or auto wins - except after a **wall** (4 losses on the same dungeon), which is logged, then
decreed so the run can go on. Save and load at each zone change (state digest checked), plus one mid-dungeon save/load. A loss plays out
as a loss: the hero wakes at the respawn point, the dungeon starts over, and the bot walks back in.

| Path | Completed | Steps | Game time (bot) | Fights won / lost | Walls | Gold earned (target 21.3k) | Final level |
|---|---|---|---|---|---|---|---|
| Beefcake | **yes** | 119 / 119 | 1.08 h | 93 / 30 | 6 | 15,750 (74 %) | 24 |
| Necrocrat | **yes** | 119 / 119 | 1.03 h | 82 / 20 | 4 | 17,035 (80 %) | 23 |
| Gourmand | **yes** | 119 / 119 | 0.95 h | 82 / 16 | 3 | 16,510 (77 %) | 23 |
| Refusemancer | **yes** | 119 / 119 | 1.19 h | 100 / 15 | 2 | 19,155 (90 %) | 26 |

**How to read it.** The player is the game's own planning AI (ELITE, the same player as the balance sims) sitting in the hero's seat on the
real battle screen at battle speed x4 - so "game time" is bot time, several times shorter than a human's. Between fights it opens every
pack, wears its best gear, buys the best cards Sable has for its Paths (keeping a third of the purse), and rebuilds its deck with the Deck
Station's own "Suggest a deck" (two Paths once the game allows). It plays **no optional content**: no roamers, arena bouts, quiz, Dex or
favours beyond the one each zone needs (those are set by flag) - so it arrives everywhere **3-5 levels under** `ProgressionModel`'s
expected player, and its gold is short of the 21.3k no-grind target for the same reason (the target counts the optional fights).

**Losses by encounter** (level at the time): full lists in `docs/playthroughs/full_real_<path>_nov9.log` ("FULL loss" lines).
- **Primm (all four Paths, a wall in all four):** levels 16-20. Expected player: 21.
- **The Shattered Gallery (all four, a wall in all four):** levels 22-25. Expected: 26.
- **The fourth zone's main dungeon** (the Rotheart for Beefcake and Gourmand, a wall for both): levels 14-15. Expected: 17.
- **The second zone's main dungeon** (the Hall of Final Approvals for Beefcake, the House of Gains for Necrocrat; both walls): level 9. Expected: 11.
- **S-NECRO, the D.N.A. side dungeon** (a wall for Beefcake and Necrocrat): levels 5-9. Expected: 10. It opens with the D.N.A. favour,
  so a player who takes it as soon as it opens meets it about 4 levels early.
- Lighter: the Lab (L19-21, one wall), Swolympus (L23-25), the House of Gains boss for its own Path (L5, beaten on the 2nd-3rd try).

**Difficulty walls a normal deck can't pass:** none that stay walls once the hero is at the expected level - every wall above sits 2-5
levels under it. But a **story-only player will stall at Primm and at the Gallery** on every Path, and at the second and fourth main
dungeons on some. Recommendation (owner's call, not changed tonight): say it in the game - e.g. Maren or the dungeon entrance noting
"most travellers are level N before this" - or soften those four by one step. The balance sims are the tool to pick which.

**Dev help used:** walking (teleports to spots, the zone road walk, the Lab hatch, the Rift Express, Swolympus travel), favour steps and
Maren's early chain set by flag, Old Man Mountain's errand by its counter, and the decree after each wall. Nothing else.

## 2. Blockers found and fixed

| # | Found | State |
|---|---|---|
| 1 | **Primm's Castle could strand the player** (ship blocker). Its side branches nest (courtyard -> Grand Foyer -> Portrait Gallery -> two wings); after the wings the map sent the party back one level only, onto the Gallery, with nothing left open. Nothing to click; only Retreat (which resets the final dungeon). The Beefcake run hit it 18 times (the bot jumped ahead, logged). | **fixed**: `DungeonMap.complete` keeps doubling back the way the party came until a node has an open path. New test walks every dungeon as a completionist and with 20 random walkers each (fails on the old code, passes now). The three later runs met it 0 times. |
| 2 | **Rewards screen: a second Take/Skip press** (double click, or E right after a click) applied the rewards again, stacked a second level-up panel and ran the after-rewards step twice (the tutorial's completion twice). | **fixed**: one confirm per screen. |
| 3 | **Dungeon map: choosing a node while its cutscene played** started it again on top (stacked cutscenes). | **fixed**: picks are ignored while a node cutscene is up. |
| 4 | **The Credits page showed its own editing notes** as its first heading. | **fixed** (+ test). |
| - | **Still open:** none found that blocks finishing the game. Watch item: the walls in section 1. | - |

## 3. Game feel and polish (Part 2)

Most of the battle-impact list was already in the game (Battle feel, Oct 28-29: card lift and land with dust, wind-up lunge, hit-stop,
shake scaled to damage, floating damage numbers, the dissolve shader, buff numbers). Tonight filled what was missing and checked the rest.

**Battle impact (new tonight)**
- **Reduce motion** (Settings > Accessibility, saved): no screen shake, no hit-stop, no final-blow slow motion; lunges, recoils, pops and the
  turn-banner sweep at 30 %; half the particles. A superset of "Reduce screen shake".
- **Buffs** pop: the unit grows and settles with a green glow ring (the +x/+y number was already there).
- **Healing**: a green glow ring on the healed portrait, under the burst and the "+N HP".
- **Unit death**: the burst is now in the unit's Path colour (it was a fixed peach), matching the dissolve edge.
- **Turn banner**: 0.62 s instead of 0.75 s (both sides).
- Before/after: `docs/overnight_shots/nov9b/` (Dex, UI sweep); battle feel is motion, so it is described rather than shot.

**Sound coverage:** `docs/audio/sound_coverage_nov9.md` lists every common action. Gaps filled:
1. the world purse: gold rising now chinks softly (at most every 0.5 s) and the HUD number pops;
2. Settings, Glossary, Feats, Credits and the save slots: open with a page sound, close with a soft back sound (they closed silently);
3. opening a town or zone screen no longer plays the close sound first (it "closed" nothing);
4. a miss at Dex's table has a sound.
Loudness re-measured with both tools: nothing sits more than 3 dB over its role; no change needed. Ducking verified in code: music -4.5 dB
under any dialogue box, -9 dB (story -13) under stings, eased. Default mix unchanged (music about 2 dB under effects).

**Transitions:** every scene change already goes through SceneManager's fade (no direct scene switches anywhere in the code). New: the full
loading screen only shows when it is needed - a destination that loaded in under 0.9 s earlier this session gets the plain fade (the
"still loading" card still appears if a load runs long). First visits keep the loading screen.

**UI consistency sweep:** 23 screens shot before and after (`docs/overnight_shots/nov9b/ui_before/` and `ui_after/`, script `docs/review/play_scripts/ui_sweep_nov9.txt`).
The frames, headers, buttons and focus rings already match the Deck Station across title, Settings, Character, Deck Station, Packs, Quest
Log, Map, Wardrobe, Pause, zone HUD, dungeon map and Dex. Strays found and fixed:
1. **the Credits page printed its own editing notes** ("The Credits screen's text... '#' lines are headings...") as its first heading - the
   file's header used heading marks; now comments, with a test;
2. the D.N.A. Rec Room memory cards could not take keyboard/pad focus (Dex's table could): now focusable with the shared focus ring.

## 4. Dex's Cardsharp's Circuit (Part 3): **finished - keep it in 1.0**

- **Played through end to end** by a new smoke (`tools/dex_circuit_smoke.tscn`): Dex's talk spot in all four zones (lines, quest offer,
  table), each table won, the final table opening after four, the turn-in, and the Matching Pair granted and worn: **46 / 46 steps**.
- **Scoring was unfair:** "12 moves or fewer" (11 at the final) out of 14. Simulated: a *perfect* memory beat that only 55 % / 9 % of the
  time. Now 15 / 14 out of 20 - a careful player wins a zone table 82-97 % and the final 61-87 % (`docs/minigames/dex_odds_nov9.md`).
- **Rules:** one line under the score: "Flip two cards: that is one move. Find all eight pairs in 15 moves or fewer to beat Dex (the table
  allows 20)."
- **Polish to the Deck Station bar:** a green felt table with a gold rim, the Path's own card backs (the final table: the neutral back)
  instead of a "?", Dex's portrait at the head of the table with his name and a line after every move (pair, miss, win, close, out of moves;
  in `dungeon_content.json`, `cardsharp.quip.*`), "A pair! 3 of 8 found", and a miss that says to remember where the cards were.
- The prize's effect (draw a copy of your first spell each turn) was already tested.
- Shots: `docs/overnight_shots/nov9b/dex_*`.

## 5. Release basics (Part 4)

- **Autosave indicator:** a small quill turning in a gold ring with "Saving..." in the bottom-right corner on every autosave (it holds 0.9 s
  after the last save, then fades; slower under Reduce motion). `ui/widgets/save_indicator.gd`, `EventBus.game_saved`.
- **Colour-blind Path symbols ON by default** (`Settings.DEFAULT_COLORBLIND_SYMBOLS`; inbox item 1 says how to flip it).
- **Version 1.0.0-rc1**: title screen, log header, Credits page (all read `config/version`), Windows file/product version 1.0.0.0.
- **itch screenshots:** left as last night's - this screen cannot open a true 1920x1080 window (max about 1886x1061).
- **credits.cfg:** creator and donation link left empty, with `>>> OWNER` comments showing exactly where they go.

## 6. Final read of the main story (Part 5)

All 1,484 main-quest lines read in game order (prologue, Crosspath, the four gatekeepers, dungeons and freed-zone talks, Maren's four
memories, the cave-mouth scenes, the Capital's main beats, the castle, Primm, the ending and the post-ending scenes). The Nov 5 rewrite holds
up: voices match `docs/dialogue/story_voice_nov5.md`, clipped "short statements" are gone from the main line, and the jokes sit on side
characters. Fixed: 11 hand edits and 88 quote repairs (revertible: `node tools/apply_dialogue_pass.js --csv=docs/dialogue/edit_nov9.csv --revert`; the filled sheet is
`docs/dialogue/edit_nov9/story_read_applied.csv`):
- **69 lines of speech split across boxes** (a quote opened in one box and closed two boxes later: Agnes in the queue, Mortimer, Vellum,
  the notary, the whistleblower, Old Man Mountain, the throwers...) - every box now opens and closes its own quotes; plus 19 of Primm's
  lab notes and journals split the same way with single quotes.
- **Continuity:** Primm "in his pressed grey coat" after the fight (he wears white and gold); Primm "removed two people so that eleven
  thousand could be safe" (eleven thousand is the number he *corrected*) - now "a whole kingdom".
- **Repetition:** the blueprint vault and the early journals both used "They are good. They are so good." (Flex's repeated "it was not the
  part that matters" is a deliberate beat the Wanderer throws back at Primm - a story test caught my edit, so it stays.)
- **Clunky lines:** Clench's boss intro told you to get "off the wheel" inside his gym;
  Compostella's muddled "don't shut it away in a jar... Death is not the end of them".
- Kept on purpose: the Rescuer's "Tell me: which Path resonates within you?" is pinned word for word by a test (an earlier owner call).
- Fig Sly's black-market lines are locked by the tool and were not touched.
- Nothing contradicts the current quest steps, names or tutorials. Re-exported: `docs/dialogue/edit_nov9.csv` (4,357 rows, story order).

## 7. Plan for Nov 9-11 (updated)

- **Nov 9, day (owner):** answer the inbox (colour-blind default, Dex kept, the walls). Fill `data/credits/credits.cfg` (name, donation
  link). Generate Batch 14 (`docs/art/batch14_nov9.csv`, the five mood-variant sets first). Play Dex's table once - it should now feel winnable.
- **Nov 9, day (Claude):** import Batch 14 and un-hold the portrait variants. Decide the four walls with the balance sims (Primm, the
  Gallery, the 2nd/4th main dungeons, S-NECRO's opening point) or add "travellers are usually level N" hints - whichever you choose.
- **Nov 9, night run:** the S items left from the cut-or-finish list (quiz feedback, packs shelf scroll, Alembic bars, Wardrobe tint, Gallery
  tooltip), the forest light and the tutorial-cave restart; re-run one Path with `bash tools/run_full_real.sh <path>` after any balance change.
- **Nov 10, day:** play the first hour yourself on a clean save; one fresh-eyes critic (first hour).
- **Nov 10, night run:** Crosspath roof fade, the battle infrastructure row and hand cap, the full suite, an exported-build smoke.
- **Nov 11, day:** set `config/version` to 1.0.0 (the presets already say 1.0.0), export, test the zip on a second PC, set up the itch page
  from `docs/release/itch_page/`, upload, finalise `docs/HANDOFF.md`.

## Tests

Full suite in memory-safe shards (`bash tools/run_tests.sh --only=tests --size=12`): **2,878 / 2,882** on the full pass; the 2 failures
were tonight's (the version-preset test now compares the numeric part of "1.0.0-rc1"; the word-for-word Path question was restored) and
pass on re-run; 2 risky (pre-existing tests with no assertion). New tests: `tests/core/dungeon/test_map_never_strands.gd`, the Credits
notes test. New tools: `tools/run_full_real.sh <path>` (with a memory watchdog), `tools/story_playthrough.gd --full=1`,
`tools/dex_circuit_smoke.tscn`.
