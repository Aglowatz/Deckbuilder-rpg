# Morning report - overnight Oct 27-28 (Necrocrat units, art direction + catalogue, feats)

Started Tue Oct 27 20:47 MDT (Fable), tag `pre-overnight-oct27` (= a5807ea1). Brief copy `docs/overnight/oct27/brief.md`; state file
`docs/overnight/loop_state.md`; questions `docs/overnight_inbox.md` (section "Overnight Oct 27-28", items 1-9); the dialogue freeze was
respected (no existing line or key changed; the one suggested rewrite is in `docs/dialogue/lines_to_update_oct28.csv`). No build was
exported and no version was bumped (by rule). No art was generated: every picture is a description.

## Read this first

- **Necrocrat is playable in the mirror now**: five Common / Uncommon bodies up one point and a new Common, **N-38 Hazmat Intern, 2(N) 1/3
  Toxic**; the level-12 round robin reads 45% (was 20-33). Two cells sit outside your lines on every seed (vs Gourmand 23%, vs Refusemancer 65%), and **Refusemancer is the weakest Path now (27%, was 33-43)**; inbox 1.
- **The art review** (`docs/art/art_direction_oct28.md`) and **the catalogue** (`docs/art/art_batch_oct28.csv`, 164 rows, 56 High; the
  locks, batch order and import lines in `art_batch_oct28.md`). The headline: the painted parts already read as one world; the seams are the
  3D roaming enemies, the hero landmarks that are still blocks, the skies, and the story beats with no picture.
- **Every roaming enemy becomes a painted sprite** the moment its `SPR-FOE-*` set is imported (code done; 21 sets in the catalogue), **every
  boss entrance is a cut-out character now** (the dialogue portrait slides in over the letterbox; a `CUT-*` file replaces it when made; shot
  `docs/overnight/oct27/intro_warden_cutout.png`), and **Maren goes back to a tortoise** (portrait + expressions + sprites, same IDs).
- **Feats shipped** (Part 3): 40 feats, Menu > Feats, per-slot + account record, retroactive on load, one-per-account rewards (gold and
  essence; no dye / title system exists - inbox 9).

## By part

| Part | Commits | What |
|---|---|---|
| 1 Necrocrat | a5c59207 | N-03 3/4, N-04 2/3, N-05 2/4, N-07 3/4, N-23 3/5, new N-38 Hazmat Intern; sim packages; `sheet_changes_oct28.csv`; balance_log; tests |
| 2 Art direction + catalogue | d05586d9 | `art_direction_oct28.md`, `enemy_roster_oct28.md`, `art_batch_oct28.csv/.md`, `lines_to_update_oct28.csv`; code: enemy sprite swap-in, 5 renames with aliases, 3 town roamers in the Bestiary, boss intro cut-outs, `CUT-*` ids in the portrait importer; `test_enemy_art_oct28.gd` |
| 3 Feats | 93ab2b47 | `data/feats/feats.json`, `core/feats/*`, `ui/screens/feats_panel.gd`, Session hooks, pause menu entry, `docs/design/feats.md`, `test_feats.gd` |
| Phase 2 | f2c0c34c, 94aef8a4, 18c54dcd, 7a8d4910 + the final commit | 11 cycles (`docs/overnight/loop_log.md`): stability sweep, the intro halo, feat toasts that wait for the battle, the Menu > Feats hint, the Feats page shots, a third balance seed |

## The Necrocrat result (Part 1)

Level-12 round robin (`--what=decks --level=12 --games=20`, both seats the planning AI, no gear), two seeds:

| | Beefcake | Gourmand | Refusemancer | Necrocrat | N vs B / G / R |
|---|---:|---:|---:|---:|---|
| before (Cards Oct 27, 7000 / 8100) | 63 / 60 | 73 / 73 | 43 / 33 | 20 / 33 | 20-40 / 10 / 30-50 |
| after (7000 / 8100) | 60 / 55 | 65 / 72 | 35 / 23 | **40 / 50** | 30-55 / 35-15 / 55-80 |
| after, seed 9200 (Phase 2) | 58 | 73 | 22 | **47** | 60 / 20 / 60 |
| three-seed mean after | 59 | 70 | **27** | **46** | 48 / 23 / 65 |

The cave is unchanged (B 88 / G 92 / R 78 / N 96 on seed 7000, identical to Oct 27: the cave foes run no Necrocrat cards); the D.N.A.
roamers (88 / 100%) and the Hall (every node "ok", Mortimer 58%) read as in the Oct 27 sweep with the buffed zombie archetype. Reports
`docs/design/sim/oct28_*.md`; the log entry "Overnight Oct 27-28, Part 1" in `docs/design/balance_log.md` has the per-set numbers (set A,
bodies only, moved Necrocrat 33 -> 35; the Intern and the shelf Commons in the sim's package did the rest).

## The art catalogue headline (Part 2)

| Category | High | Medium | Low | Total |
|---|---:|---:|---:|---:|
| Enemy sprite sets | 21 | 0 | 0 | 21 |
| Cut-outs (entrances) | 15 | 9 | 2 | 26 |
| Bestiary squares | 4 | 19 | 0 | 23 |
| Story stills | 5 | 10 | 0 | 15 |
| Cards | 5 | 10 | 1 | 16 |
| Portraits (Maren) + expressions | 3 | 12 | 0 | 15 |
| NPC sprites (Maren, Primm, farmhand) | 1 | 2 | 0 | 3 |
| Backdrops / props / sheets / trees / zone kit | 1 | 13 | 7 | 21 |
| Icons (4 relics, 8 feat groups) | 0 | 4 | 8 | 12 |
| Cosmetic (Leaf Crown redo) | 0 | 1 | 0 | 1 |
| **Total** | **56** | **89** | **19** | **164** |

By zone: Global 40, Crosspath 25, Capital 26, Verdant Dump 17, Gainlands 14, D.N.A. 13, Endless Buffet 13, Castle 7, Opening Forest 6,
Lab 3. **The High list**: Maren's three portraits and her sprite set; the 21 roaming-enemy sprite sets; the four new / redone Bestiary
squares (Pantry Hound, Lost Junior Clerk, Bin Raccoon, Quota Spotter); cut-outs for the Hollow Warden, the four gatekeepers, Clench, Quota,
the Doppelganger, Crumb, Mortimer, Plume, the Rotheart, Clipwell, Spotless and Primm; the stills STORY-CAPTURE, STORY-THRONE, STORY-WONDER,
STORY-MEMORY-3 and -4; the starter cards' art (Protein Shake, Pending Approval, Amuse-Bouche, Curb Alert, Hazmat Intern); the forest's
painted cave mouth; the Rotheart backdrop with a transparent sky. Nothing is missing among maps (15/15), battleboards (25/25), vendor
screens, key art, UI kit, item and cosmetic icons; the unused approved art is tabled in `art_batch_oct28.md`.

## Enemy renames (data only; no frozen line names them)

| Old | New | Zone | Look in one line |
|---|---|---|---|
| Stray Gym Hound | **Pantry Hound** | Crosspath | a sauce-drunk spaniel in an apron with a ladle |
| Flexing Brute | **Quota Spotter** | Gainlands | a billy goat sergeant with a stopwatch and clipboard who counts your reps for Clench |
| Zombie Intern | **Unpaid Intern** | D.N.A. | a zombie under a tower of forms |
| Possessed Scarecrow Druid | **Hungry Scarecrow** | Verdant Dump | a druid's scarecrow that has started to grow |
| Compliance Officer | **Correction Officer** | Capital | a mirror-visored enforcer of the Ministry of Correction |

Old saves keep their Collection Book counts and the old pictures (`Bestiary.RENAMED`, `legacy_art_ids`). The whole roster, sizes and
behaviours: `docs/design/enemy_roster_oct28.md`.

## NPCs and enemies going painted

- **Enemies**: all 21 roamers and road guards (3 Crosspath, 3 Gainlands, 3 D.N.A., 4 Buffet, 3 Dump, 5 Capital). `ZoneEnemy` draws the
  sprite set `FOE-<slug>` instead of its model as soon as "import npc sprites" brings it in; nothing else to wire.
- **NPCs still 3D**: Primm at work (the postgame Crease; SPR-PRIMM row), the three nameless Dump farmhands (one SPR-DUMPWORKER set, tinted),
  the gold Primm statue (a prop row). Every list NPC with lines is a painted sprite already.
- **Maren**: the current portrait and sprites are a human grandmother with a shell; the rows describe an old tortoise proper (beak,
  spectacles, mossy shell, the four-colour shawl and the carved stick kept) for the base portrait, HAPPY, WORRIED and the four sprites.

## Story-scene illustrations planned (15)

STORY-CAPTURE (Elowen taken at the gate), STORY-THRONE (ending beat 8), STORY-WONDER (the true Chef's dish), STORY-MEMORY-1..4, STORY-VACANCY
(Agnes takes the office), STORY-SEVER (the seed dies), STORY-MODEL-ROOM, STORY-KEPT-FACE, STORY-FACADE-FALLS, STORY-CELL-4, STORY-FUNERAL,
STORY-HOME. Composition, cast (by portrait ID), light and mood per row; the seven existing stills stay. Wiring is one line per still.

## Boss-intro change

`ui/battle/boss_intro.gd`: the figure slides in from the left over the letterbox bars (0.45 s, feet in the lower bar, no box) beside the
name card; the picture is the `CUT-<key>` cut-out if imported, else the transparent dialogue portrait (every boss, lieutenant and gatekeeper
tonight), else the old Bestiary square pushing in (the four nameless entrances). `Bestiary.cutout_ids()` lists the 24 cut-outs; the portrait
importer accepts them. Needing a cut-out (all 24 are catalogue rows, optional since the portraits work): Warden, Bronson, Pallor, Gravois,
Mulligan, Shiro, the Four-Seal Warden, Clench, Quota, the Spotter, the Doppelganger, the Itamae, Crumb, Mortimer, Betty, Plume, the Rotheart,
Clipwell, the Raccoon, Spotless, Primm (+2 phase variants), the Automaton, Siphon, Bellows.

## Dialogue lines to update

`docs/dialogue/lines_to_update_oct28.csv`: **1 row** (optional): Maren's `town.elder.idle.4` line 2 speaks of tortoises as "them". No
rename touches a frozen file; Maren's other species lines already say tortoise.

## Feats (Part 3)

40 feats in ten groups (`docs/design/feats.md`): story milestones, one per zone, eight side dungeons, challenges (Gold Sand, Shiro, the
Four Seals, the Old Well, Flawless, By a Thread), collection (25 / 50 / 100%, a craft, ten packs), a card moment per Path (10-attack unit,
three Golems, five Red Tape, four garbage in a turn, a four-kill card) and two for mixed decks; 11 hidden. Tracked through the session's
real hooks (flags, counters, zones, cards, won battles, a live-battle watcher on the rules engine's events), saved per slot under
`"feats"` plus `user://feats_account.json` for the account, retroactive on load (one quiet toast), unlock toast + STG-SECRET sting,
rewards paid once per account (gold / essence; only in a saving game). Menu > Feats (pause menu, pad B steps back). Tests
`tests/core/feats/test_feats.gd` (9).

## Checks

- GUT per part: Part 1 root 276 / core 1465 / ui 234 / world 418; Part 2 root 276 / core 1479 (+ the two not-yet-wired feats tests) /
  ui 234 / world 418; Part 3 feats 9/9, root 276, ui 234, core 1481 (+1 known pending), world 418 (rerun in the foreground after the harness stopped the first run for low memory).
- Walk smokes after Part 2: Crosspath, Gainlands, D.N.A., Buffet, Dump, Capital all OK. `perf_budget.sh structure`: all budgets met (Part 1).
- Sims: Part 1's round robin on two seeds, the cave (seed 7000), `zone:necrocrat`, `dungeon:D-HFA`.
- Screenshots: `docs/overnight/oct27/intro_warden_cutout.png` (the new entrance). The Feats page has no screenshot (no pause-menu hook in
  the shot tool); it is built from the Glossary page's layout.

## Phase 2 (22:55-23:45, 11 cycles)

- **Stability**: world GUT 418 (rerun in the foreground after the harness reaped the first run for memory), first-battles smoke, the
  opening-hour playtest smoke, story playthrough bot 90 / 90, tour bot 281 spots / 0 errors / 0 warnings, gamepad smoke (506 pad events, the
  pause menu included), boss-rules smoke: all OK on the final tree. `perf_budget.sh structure` OK; the frame budget was not rerun (memory).
- **Polish**: a soft halo behind the boss intro's cut-out (`docs/overnight/oct27/c2_intro_halo.png`); feat toasts queue while a battle is
  pending and flush when it ends (a shot had caught them over the Warden's entrance); the first feat toast of a session ends with
  "Menu > Feats"; a dev scene and a town hook photograph the Feats page (`docs/overnight/oct27/c8_feats_page.png`).
- **Balance evidence**: a third round-robin seed (above). Scorecard: `docs/overnight/oct27/scorecard.md` (no category moved down).
- Not done: the Dump's two blue entrance flags were not found in the zone's code (a catalogue row covers them).

## Inbox (yours to decide; the safest choice was taken)

See `docs/overnight_inbox.md`, "Overnight Oct 27-28": 1 Necrocrat cells, 2 the Hall for Refusemancers, 3 the renames, 4 foes not in the
Bestiary, 5 the gate guards' floating text, 6 cut-outs optional, 7 Maren's line, 8 unused art, 9 feats rewards.
