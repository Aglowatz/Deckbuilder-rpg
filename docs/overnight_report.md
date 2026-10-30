# Report - XP pass Oct 30: XP curve, difficulty recheck, v0.4.8 candidate (Opus)

Fri Oct 30, ~07:30 -> 11:50 MDT. Tag `pre-xp-oct30` (start) and `v0.4.8` (the candidate). State `docs/overnight/loop_state.md`; questions
`docs/overnight_inbox.md` ("XP pass Oct 30", items 1-9). Last run's report: `docs/overnight/oct29/overnight_report_econ_oct29.md`. Dialogue
freeze respected (in `dungeon_content.json` only `hp` / `infra` numbers changed; no dialogue line, key, quest or script text); no art
generated; the black market untouched; no enemy intent. Old saves load and never lose a level.

## Read this first

- **The XP curve is re-based** on the XP the story really pays. The expected player is now L5 at the Gainlands, L8 in the House of Gains,
  L14 at the Test Kitchen boss, L18-19 when the Dump is freed and L22 at Primm (was L8 / L12 / L18 / L25 / L29); 23-30 is a postgame
  climb, every level dearer than the last.
- **Every fight was re-simmed at those levels** with the expected player's real gear; 15 groups were out of band and were tuned (table
  below). **Primm's three phases: 78 -> 68 %** - the Path spread (Necrocrat ~98, Beefcake ~32) is beyond Path-neutral levers (inbox 4).
  **The Doppelganger sits ~35 %**: its "+1/+1" is pinned by its frozen mask script (inbox 8).
- **v0.4.8 candidate**: `builds/TheWaywardPath-v0.4.8-windows.zip`, **762 MB** (798,323,052 bytes; under the 850 MB flag; the v0.4.7 zip
  is still beside it). Exported release smoke PASSED on D3D12 Medium and Low. Notes: `docs/release/v0.4.8_notes.md`. Not shared.

## By part

| Part | Commit | What |
|---|---|---|
| 1 XP curve | fa9a9db0 | `ProgressionTable` step table; `ProgressionModel.LEVELS` = the real levels (dungeon elites / bosses at the dungeon's level, Primm +1); economy model "Level timeline" (old vs current curve); character-screen XP bar safe for old saves; tests |
| 2 Recheck | 906743ad | 40+ sim runs (`docs/design/sim/oct30_*.md`); 15 encounter groups tuned; `balance_log.md`, `sheet_changes_oct30.csv` |
| 3 Small calls | 906743ad | reroll + price kept, Belt / Barbell Beefcake-only kept, Binding Chains left; Captain Spotless's enemy figure on his SPOTLESS NPC set |
| 4 v0.4.8 | (final commit, tag `v0.4.8`) | tour bot, story playthrough, memory round trip, bump, guarded export, exported smokes, zip, notes |

## Part 1 - the curve

XP to reach a level (`ProgressionTable.xp_to_reach`; steps `EARLY_STEPS` 50 / 70 / 80 / 100 / 280 / 300 / 340 / 380 to L9, then
325 + 10 L to L20, then 500 + 35 (L - 20)):

| Level | 5 | 6 | 8 | 10 | 14 | 19 | 20 | 22 | 25 | 30 |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Old | 300 | 450 | 840 | 1,350 | 2,730 | 5,130 | 5,700 | 5,862 | 6,510 | 8,670 |
| New | 300 | 580 | 1,220 | 2,025 | 3,825 | 6,300 | 6,825 | 7,930 | 9,850 | 13,750 |

L5 stays at 300 (the store room ghosts' hand-in sends the hero to the armory). The old postgame segment (27 x (L-20)(L-19)) made levels
21-30 together cheaper than 17-20.

Level timelines (level on arrival - on leaving; `docs/design/sim/economy_model.md` has every stop, `economy_model_xp_before.md` the old run):

| Stop | Model | Rusher before -> now | Expected before -> now | Thorough before -> now |
|---|---:|---|---|---|
| Gainlands arrival | 5 | 5-5 -> 5-5 | 6-8 -> **5-6** | 7-9 -> 6-7 |
| House of Gains | 7-9 -> 8 | 5-9 -> 5-7 | 9-12 -> **8-10** | 10-12 -> 8-10 |
| Test Kitchen | 14 | 12-14 -> 10-12 | 16-18 -> **14-16** | 18-20 -> 16-17 |
| Dump freed | 19 | 16 -> 14 | 23-25 -> **18-19** | 27-28 -> 21-22 |
| Primm's Castle | 20-22 -> 21-22 | 17-18 -> 14-15 | 28-29 -> **21-22** | 30 -> 24-25 |
| After the postgame | 24 | 18 -> 16 | 30 -> **23-25** | 30 -> 26-28 |

Track and caps at the new pace: deck slots at 7 (Gainlands / Iron Cave), 14 (Test Kitchen), 21 (the Capital); Uncommon copies 3 at L9
(the House of Gains' end), Epic copies 2 at L12 (the Hall), Epic gear cap 2 at L13 (Buffet arrival), Legendary gear at L22 (Primm). The
economy targets still hold: the expected profile spends 98 % of its income (was 98), no droughts, no hoarding; it now collects 2,340 of
the track's 3,090 gold (L26-30 are the thorough player's; inbox 2). The rusher is further behind than before (L14 at the castle) by choice.

## Part 2 - sims at the real levels (expected player, real gear)

| Group | Before (this morning) | After | Change |
|---|---|---|---|
| The cave, 30 runs per Path | B 90 / G 92 / R 80 / N 97 | same | - |
| Gainlands roamers L5 (16 + 30 + 10 games) | 81 / 91 / 73 overall | same | Refusemancer ~71 % vs the Quota Spotter pooled (inbox 5); a basics change was mixed and reverted |
| Later zones' roamers L10-20 | 85-100 | same | - |
| Colonel Casserole L13 | 68 | same | - |
| Captain Spotless (gate) L20 | 98 | **75 / 71** | HP 36 -> 46, drill +2/+1 -> +4/+3 |
| House of Gains L8 | Honor Guard 47, Clench 34 | **65 / 63, 41 / 40** | Honor Guard HP 12 -> 9, basics 13 -> 15; Clench 2 Iron (was 3), reinforcements every 5th turn |
| Hall of Final Approvals L11 | elites 66-75, Mortimer 53 | same | - |
| Test Kitchen L14 | the Doppelganger 31 | **43 / 27** | HP 21 -> 16, 1 Ingredient; normals' HP 17 -> 15 (boss > normals); inbox 8 |
| Rotheart L17 | Compostella 78, the Hive 81 / 88 | **67 / 48, 71 / 81** | Compostella +2/+2; the Hive HP 18, basics 15 |
| Primm's Castle L21 | elites 88-91 | **65, 55 / 77, 78, 78** | Mirror Knight +3/+2, Staircase 3 Militia, Plume +1/+1, Clocktower +3/+3 |
| Primm's sequence L22 | 78 (B 50 / G 79 / R 83 / N 100) | **66 / 70** (B 35 / 30, G 60 / 70, R 75 / 80, N 95 / 100) | phase HP 44 / 42 / 42, phase 3 +2/+2 (inbox 4) |
| Iron Cave L6 | 69 / 75, Quadzilla 25 | **83 / 83, 44** | normals HP 4 / 5, Quadzilla HP 13 and "Max Pump" removed |
| Forgotten Vault L7 | 53 / 63, Automaton 47 | **81 / 81, 50** | HP 5 / 7, basics 18 |
| Waiting Room / Omakase / Trash Panda Throne / Tunnels | Betty 47, Itamae 47, Raccoon 56, Spotless 66 | same | - |
| Swolympus / Paste Works L23 | Ancient Spotter 72, Crumb 75 | **69 / 67, 52** | +4/+3; +2/+2 |
| Path-ology Lab L25 | - | elites 75, Siphon with Elowen 79 | Siphon HP 44 -> 48 (stays above Primm's first phase) |

Every change with its evidence: `docs/design/balance_log.md` ("XP pass Oct 30, Part 2"); sheet rows: `docs/design/sheet_changes_oct30.csv`.

## Part 3

The reroll and its price, the Belt / Barbell as Beefcake-only and Binding Chains stand. Captain Spotless: his enemy entry now draws the
SPOTLESS NPC set (idle-only, so he hops like the other idle sets). Finding: he never roams (the Capital spawns no Spotless), and at the gate
he was already the painted sprite (`_screenshots/oct30/spotless_gate.png`); the 3D knights beside the gate are the unnamed gate guards
(inbox 9).

## Part 4 - v0.4.8

- Tour bot: OK, 281 spots, 9 menus, 5 battles, 0 errors. Story playthrough: 90 / 90. Memory round trip: 10 trips, static +0.8 MB, video
  -0.1 MB, objects +30 - OK.
- Version 0.4.8 (`project.godot`, `export_presets.cfg`). Guarded export: EXPORT OK, pck 851.5 MB (13,408 files, 77 baked shaders, every
  MD5), zip **builds/TheWaywardPath-v0.4.8-windows.zip, 762 MB** (CRCs checked); peak memory import 1,042 MB, export 1,300 MB (1.7 GB was
  free). The pack is over the 800 MB budget, as in v0.4.7 (same art).
- Exported release smoke, D3D12: Medium PASSED, Low PASSED.
- Notes since v0.4.6: `docs/release/v0.4.8_notes.md`. Disk: about 3 GB free on C: after the export.

## Checks run

GUT root 286, core 1496 + 1 pending, ui 242, world 422 (after each part); card import 0 problems; first-battles smoke (twice); hub,
Crosspath, Capital and Gainlands walk smokes; structure budget OK (twice); tour bot, story playthrough, memory round trip; exported release
smoke x2. Screenshots: 1 (Part 3) plus the smokes' own.

## Inbox (XP pass Oct 30)

1 the curve as a step table (L30 needs grinding). 2 the track's L26-30 gold. 3 no in-dungeon level offsets. 4 Primm's Path spread.
5 Refusemancer vs the Quota Spotter. 6 Path matchups at bosses. 7 left a little over band. 8 the Doppelganger and its mask script.
9 Spotless's figure and the gate guards.
