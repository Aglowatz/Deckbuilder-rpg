# Overnight report - Oct 18-19 2026

Start Sun Oct 18 18:28 MDT (tag `pre-overnight-oct18`), end Mon Oct 19 ~06:00 MDT (the last half hour went to the final checks and this report). Last night's report: `docs/overnight_report_oct17.md`.
Phase 1: all 8 parts done and committed. Phase 2: 34 cycles (`docs/overnight/loop_log.md`), 8 every-4-cycles / final checks.
No build exported (v0.4.0 stays with the playtesters). Old saves keep loading: the save format did not change.

## In one minute

- **Balance.** Part 1 measured every piece of equipment and every item on its own (new `--what=gear` sim mode) and the gold economy (new
  `tools/economy_audit.gd`); **each equipped item now works once per battle** (a stack of Salves could carry any fight). Part 2 measured
  all 97 fights (including the never-measured late groups), fixed a sim bug (town NPCs were simulated at the wrong HP) and iterated five
  times; ten more balance cycles followed. In band, start -> end of night: **normals 34 -> 38 of 54, elites 4 -> 11 of 21, bosses 3 -> 8
  of 19**. Starting decks closer (level-1 round robin spread 24 -> 13 points), tutorial runs 80-92% for every Path. The spells-only arena
  had become near-unwinnable after Part C (its kit held exactly 8 damage for 8 HP): 17 -> 56%.
- **Playtest support.** **Report a Problem** (F8, the pause menu, named on the title screen): screenshot, log, save + backup,
  settings.cfg, area and quest, then it opens the folder. **Crash-safe saves**: a temp file, read back, the previous save kept as `.bak`
  and loaded when the main file is missing or damaged. Autosave on area change, after battles and after quest steps.
- **Arrival cards** for every zone, Crosspath, the Capital, the forest and every dungeon: the painted banner with a Path icon and subtitle,
  full the first time, brief later, skippable, below the zone-HP plate. A one-time **warning when a zone works against your Path**.
- **Settings**: battle speed 1x / 1.5x / 2x; auto-end turn (off by default); the end-turn warning names unused energy.
- **Dialogue presentation plan** + **204 portrait expression requests** (docs only, nothing generated).
- **Looks**: the Buffet's gravy moat and the Dump's sludge pool move like liquid; the D.N.A.'s grey void is a tiled office floor; bosses
  show their dialogue portraits in the Collection Book and on the battle plate.
- **Performance**: menus open smoother (glyph warmup), without the arrival stutter the first version caused (town 60 fps, 0 spikes);
  the card vendor, Deck Station and Collection Book open in lighter frames (84 -> 37, 117 -> 85, 77 -> 17 ms); zone shops warm their art.
- **Cleanup**: the long-failing camera test was reading your saved zoom (fixed in the test); four zone walk smokes were stale since the
  dialogue pass (fixed); the forest's purple shapes are gone since the rebuild.

## Phase 1 by part

| Part | Commit | What |
|---|---|---|
| 1 - Rebalance F | dea1e329 | `--what=gear` sim mode, `tools/economy_audit.gd`; items once per battle; Rolling Pin -> Epic (+38 for Gourmand), Trash Panda Tiara -> Uncommon, Big Brain Beret -2 max HP, Cheater's Dice and Thorned Loincloth softened (both were worse than nothing), Scroll of Insight draws 2, price fixes, Alchemist needs 6 essence (was 10) |
| 2 - Rebalance G | ad4c98cb | All 97 fights, 5 iterations; town NPC HP sim bug; levers that work: foe basics (early/mid) and one-sided stat rules (late); Necrocrat and Beefcake starter swaps |
| 3 - Playtest support | 29e84c95 | Report a Problem (report.json with quest + area, save + backup copy, opens the folder); crash-safe SaveSystem; autosaves; version was already on title + pause |
| 4 - Arrival cards | 12ee6d33 | Path icon + subtitle flourish, brief on later visits, skippable, dungeon cards on their zone's banner |
| 5 - Dialogue plan | 60613118 | `docs/design/dialogue_presentation_plan.md`, `docs/art/portrait_expression_requests.md` / `.csv`, tools `dialogue_audit.js`, `portrait_expression_requests.js` |
| 6 - Quest guidance | cd840871 | Mostly there already (tracker, map marks, edge pointer); added "Go to <area>" for steps elsewhere |
| 7 - QoL settings | a2f0ed0d | 1x / 1.5x / 2x, auto-end turn, energy in the end-turn warning |
| 8 - Cleanup | 3744aa79 | Camera test fixed (stale test, see below); purple shapes gone; inbox tidied |

## Phase 2 cycles

| # | Category | Commit | Change |
|---|---|---|---|
| 1 | Balance | 5bf4a552 | Colonel Casserole 42 -> 73%, Prudence 38 -> 53%: their free starting units decided the fights |
| 2 | Balance | bc404ec1 | Stat rules: Castle and Lab elites into band; two Hall bumps overshot and were reverted |
| 3 | Performance | 44ac4b0e | Glyph warmup: town slow frames 77-82 -> 43-45 |
| 4 | Balance | 330630af | Epics for the Spotter (92 -> 79%) and Shiro (88 -> 83%) |
| 5 | Playtest readiness | 7eb5a673 | One-time warning when a zone works against your Path, naming the friendlier zone |
| 6 | Balance | 4ed2879d | Doppelganger 29 -> 63%, Honor Guard 54 -> 63% (head starts trimmed) |
| 7 | Balance | dfdfba7a | Hollow Warden lighter: tutorial runs Beefcake 82 -> 92% |
| 8 | Performance | 631ece17 | Card vendor: three ideas measured, none kept |
| 9 | Onboarding | f1f7ebdf | Necrocrat starter: a body for the second Dispenser; tutorial run 76 -> 82% |
| 10 | Balance | 639b246f | Full re-measure; spells-only arena 17 -> 56% |
| 11 | Visuals - Buffet | f0422ff0 | The gravy moat moves (toon water in gravy colours) |
| 12 | Stability | 40539516 | Four zone walk smokes kept up with the longer conversations |
| 13 | Collection | 87f19954 | Bosses show their dialogue portraits in the bestiary and on the battle plate |
| 14 | Balance | 88587de7 | Five more late fights into or near band |
| 15 | Visuals - D.N.A. | 3d30119c | Tiled office floor instead of a grey void |
| 16 | Playtest readiness | c9da3faf | "F8 to report a problem" on the title screen; reports carry settings.cfg |
| 17 | Balance | b792c2e2 | Iron Cave and Vault normals |
| 18-19 | Performance | 0b5141fb, ce2f9020 | Card vendor profiled (167 tiles; one 135 ms open frame); nothing kept |
| 20 | Performance | b5545aa3 | The glyph warmup drew a whole alphabet per frame (a 0.6 s stutter after arriving): now 12 characters per frame, town 0 spikes |
| 21 | Visuals - Dump | 2e8b7dbe | The entrance pool reads as sludge, not white paint |
| 22 | Balance | 67e23eab | Mid-game normals: Sushi Chef 71 -> 88%, Test Kitchen normals 75/79 -> 92% |
| 23 | Audio | cf73d69f | Sounds for tonight's new moments (report saved, auto-ended turn, zone warning) |
| 24 | Onboarding | 65d42696 | Gourmand tutorial swap tried, reverted |
| 25 | Balance | 7f168f4a | Arena Gladiator Rookie 75 -> 88%, Apprentice Itamae 71 -> 79% |
| 26 | UI | de98646a | Arrival banners settle below the zone-HP plate |
| 27 | Balance | eb742704 | Gainlands Golem thinner deck tried, reverted |
| 28 | Onboarding | de707533 | The tracker's area hint stays quiet when the area is unknown |
| 29 | Performance | f771d3c6 | Zone shops warm their stage art like Crosspath's |
| 30 | Stability | 90146f47 | The Capital walk smoke waits out strolling citizens (0 fails) |
| 31 | Onboarding (tooling) | 69aa33ff | The playtest smoke reports its pace (46 s end to end at bot speed) |
| 32 | Performance | 78127b01 | Card vendor opening frame 84 -> 37 ms |
| 33 | Performance | fb62f4e0 | Deck Station opening frame 117 -> 85 ms |
| 34 | Performance | 01ce882b | Collection Book opening frame 77 -> 17 ms |

## Balance: start vs end of night

Full catalog, 6 games per Path, iteration 1 (`docs/design/sim/g_iter1.md`, after Part 1) vs end of night (`docs/design/sim/g_final.md`).
Every number change is in `docs/design/balance_log.md`; the live sheet's list in `docs/design/sheet_changes.md`.

| Kind | Fights | In band start -> end | Too hard | Too easy | Mean win | Mean turns |
|---|---:|---|---|---|---|---|
| Normal | 54 | 34 -> **38** | 20 -> 16 | 0 -> 0 | 84% -> 87% | 7.7 -> 7.6 |
| Elite | 21 | 4 -> **11** | 9 -> 7 | 8 -> 3 | 66% -> 64% | 8.7 -> 8.5 |
| Boss | 19 | 3 -> **8** | 3 -> 1 | 13 -> 10 | 69% -> 63% | 8.2 -> 8.2 |
| Tutorial (single fights) | 3 | 3 -> 2 | 0 -> 1 | 0 -> 0 | 96% -> 92% | 5.2 -> 5.3 |

(The tutorial row is noise at 24 games; whole tutorial runs at 50 runs per Path are 80-92%.) Starting decks, level-1 round robin: Beefcake
61 / Gourmand 54 / Refusemancer 48 / Necrocrat 37 -> 52 / 57 / 47 / 44. What is left is mostly design calls (inbox 2-4): the Gainlands for a
Necrocrat, the Rotheart's two rules, a few bosses that numbers do not move.

## Scorecard, start of Phase 2 -> end

| Category | Start | End |
|---|---|---|
| Combat feel | 8 | 8 |
| Visuals - starting forest | 8 | 8 |
| Visuals - Crosspath | 8 | 8 |
| Visuals - Gainlands | 8 | 8 |
| Visuals - D.N.A. | 7.5 | 8 |
| Visuals - Endless Buffet | 7.5 | 8 |
| Visuals - Verdant Dump | 7.5 | 8 |
| Visuals - Capital | 8 | 8 |
| UI consistency | 8 | 8 |
| Onboarding / tutorial | 7.5 | 8 |
| Rewards & progression feel | 8.5 | 8.5 |
| Collection / bestiary | 7.5 | 8 |
| NPC life & dialogue | 8 | 8 |
| Audio mix | 7.5 | 7.5 |
| Performance | 7.5 | 9 |
| Stability | 8.5 | 8.5 |
| Balance (sim evidence, new) | 5 | 8 |
| Playtest readiness (new) | 7 | 8 |

Evidence per row: `docs/overnight/scorecard.md`.

## Screenshots worth a look (`_screenshots/`, git-ignored)

- `on18_card_gainlands2.png` - an arrival card with its flourish, below the zone-HP plate.
- `on18_buffet_before.png` / `on18_buffet_after.png` - the gravy moat.
- `on18_dna.png` / `on18_dna_after.png` - the D.N.A.'s floor.
- `on18_heap.png` / `on18_heap_after.png` - the Dump's entrance pool.
- `on18_bestiary.png` - bosses with their portraits in the Collection Book.
- `on18_forest_top.png` - the rebuilt forest: no purple shapes.

## How to test the big items

- **Report a Problem**: press F8 anywhere (or Pause > Report a Problem), type a line, Send: a folder opens with report.json (area,
  quest and step, version), screenshot.png, game.log, autosave.json (+ .bak) and settings.cfg.
- **Crash-safe saves**: play a bit, quit, damage `saves/autosave.json` in the user folder (cut it in half), start the game: it loads the
  backup (the previous save). `bash tools/gut_one.sh tests/core/data/test_save_backup.gd`.
- **Items once per battle**: equip a Healing Salve, use it in a fight: its slot greys out ("Each item works once per battle"); the next
  fight it works again.
- **Arrival cards**: walk from Crosspath into a zone (full card), out and back in (brief card), start a dungeon run (its card on the
  zone's banner). Click or press Enter to skip.
- **Path warning**: a Necrocrat hero entering the Gainlands for the first time.
- **Settings**: Settings > Battle: speed 1x / 1.5x / 2x, the end-turn warning, Auto-end turn. `AUTO_END=1 bash tools/run_first_battles_smoke.sh`.
- **Balance**: `Godot --headless --path . -s res://tools/run_balance_sim.gd -- --what=encounters --filter=<group> --games=6` (groups in
  CLAUDE.md); `--what=gear --filter=zone:gourmand:loaf --games=8`; `-s res://tools/economy_audit.gd`.
- **Checks**: `bash tools/run_tests.sh`, `bash tools/run_story_playthrough.sh`, `bash tools/run_tour_bot.sh`, `bash tools/run_playtest_smoke.sh`.

## Reverted or not kept, and why

- Cycle 2: Notary Wraith +2/+1 and Mortimer +2/+0 overshot (46% / 29%): back to +1/+1 and +1/+0.
- Cycles 8, 18, 19: three card-vendor ideas (CPU time budget, fewer tiles per frame, no 3D under opaque menus, culling off-view tiles,
  rows instead of a grid) measured no better; the real stutter was the glyph warmup (fixed in cycle 20).
- Cycle 17: the Regime Captain's rule as +0/+1 made it harder (42%); Brick and Moss at 12 HP changed nothing.
- Cycle 24: a Gourmand starter swap did not help its tutorial run and widened the round robin.
- Cycle 25: two basics changes that did not move (Sandbag Sentinel, Banner Hall Guardian).
- Cycle 27: a thinner Gainlands Golem deck (57%).
- Part 2: two numbers kept inside the tests' design bounds (Prudence 12 HP, Baron Quadzilla 16 HP).
- One check (after cycle 20) ran while an edit was half-done and failed (41 GUT failures from a name clash); fixed and re-run clean.

## The camera test (Part 8)

`tests/world/test_world_look_rig.gd` was stale, not the code: the look rig applies the player's camera angle and zoom
(`CameraRig.adjust`), and this PC's settings.cfg has zoom 2.0 (the Far preset, FOV +2), so "the approved look" checks failed here and
passed on clean machines. The test now pins angle 0 and the Normal zoom and restores your settings afterwards.

## Portrait images (Part 5)

**204 images**: High 72, Medium 87, Low 45; 29 wait for a base portrait that does not exist yet; 11 batches of 20
(`docs/art/portrait_expression_requests.md`, `.csv`). Fig Sly is left out on purpose.

## Top 10 next

From `docs/overnight/next_up.md`:

1. Early walls left: the Gainlands for a Necrocrat (17%), the Rotheart normals, the Iron Cave/Vault normals at 71-75% (inbox 2-3).
2. Late bosses numbers do not move (Shiro, Bellows, Primm phase 1) - a design call (inbox 4).
3. Necrocrat and Gourmand tutorial runs (82% / 80%), the lowest two.
4. The card vendor's open frame (~135 ms: warm the stage art, build less up front).
5. An onboarding bot timed end to end (minutes and clicks from New Game to the first deck edit).
6. Enemy pictures (90 prompts ready).
7. The character screen's first open (130-180 ms) - the same build split as the shops.
8. One tile style for the hand-styled choice tiles.
9. Townsfolk in the zone hubs (needs a lore call: who strolls in each Path's home).
10. A listen pass on tonight's sounds and last night's audio items.

## Final checks

Mon Oct 19 ~05:44 MDT, after cycle 34: **GUT 1894/1894**, **story playthrough 73/73** (New Game to the ending), **full tour bot 275 spots / 9 menus / 5 battles / 0 errors / 0 warnings**, **playtest smoke OK** (the opening hour). Earlier tonight: release, first-battles (all three speeds and AUTO_END=1), Gainlands, Buffet, D.N.A., Dump and Capital walk smokes OK.

One thing to watch: in this last full tour the town's worst frame was the character screen's first open at 345 ms (vendors 245-254 ms; earlier full runs 162-214 ms, town-only runs 130-193 ms). The full tour opens menus soon after arriving, while the glyph warmup - spread over ~9 s since cycle 20 - may still be running, so a first open can still rasterize glyphs. Next step (next_up 4): warm the sizes the first screens use first, or shorten the warmup now that it runs in small chunks.
