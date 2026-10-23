# Morning report - overnight Oct 22-23 (balance, dialogue features, Path choice, names, exported build, v0.4.5)

Started Thu Oct 22 20:59 MDT, tag `pre-overnight-oct22`. Last report: `docs/overnight/oct22/prev_overnight_report.md`. Brief copy:
`docs/overnight/oct22/brief.md`; state file `docs/overnight/loop_state.md`; questions `docs/overnight_inbox.md` (section "Overnight
Oct 22-23", items 0-10); next steps `docs/overnight/next_up.md`.

## New names - please veto if you don't like them (inbox item 0)

- **Wren Muckfoot** (the Verdant Dump's animal handler, Round Up the Herd) is now **Billie Muckfoot** - "Billie Muckfoot, animal handler.
  Like the goat. I speak fluent goat."
- **Rhonda, Portal Ripper** (the Gainlands, Calf Cove) is now **Shredna, Portal Ripper** (gym slang: shredded).
- Wren of the Crease and Recycle Rhonda (the design-sheet characters) keep theirs. Internal ids are unchanged, so saves load as before.
  A different name is a one-line rename (`core/zone/heap_zone.gd` NPC_WREN, `core/zone/gainlands_travel.gd`, the story lines).

## The release candidate

**`builds/TheWaywardPath-v0.4.5-windows.zip` - 687 MB** (656 MiB), tag `v0.4.5`, notes `docs/release/v0.4.5_notes.md`. Not shared.
Release smoke on the exported build: PASSED (0.4.5). Built at commit 3d5e7a95 content (the Part 6 commit only adds the version bump,
notes and docs); nothing in the game changed after it, so it was not rebuilt.

## By part

| Part | Commit | What |
|---|---|---|
| 0 | 1728a641 | Yesterday's vendor-stock work (Sable's sample, zone shelves gated by bosses) had been left uncommitted: tests 15/15, stock tables filled in `docs/design/vendors.md`, committed first. |
| 1 Balance | ed7d7889 | The sim's reference decks now hold only cards a player can own at that level under the new shops (audit tool: 82/82; 40 cards were not on sale yet). Whole catalog re-measured, six outliers fixed on two seeds, tutorial 50 runs x 2 seeds per Path. |
| 2 Dialogue | b6cc48e6 | Long first talks split; Maren's progress greetings; Agnes's "met" line in the Hall; Primm quotes only freed leaders; freed barks in the Capital; story bot fixed to 90/90; an error spam fix. |
| 3 Path choice | a32b0b8b | Tiles: name, icon, three cards, a one-line plan; full text on hover/focus or More. Before/after shots in `docs/ui/path_choice_oct22/`. |
| 4 Names | f12d3fe4 | Billie Muckfoot, Shredna - text, code, tests, story bible, voice bible, canon (old names now banned), sheet_changes. |
| 5 Exported build | 3d5e7a95 | Bots on an exported pack, D3D12 + Vulkan, Medium / Low / Safe Mode; five props missing from the export fixed; feature shots. |
| 6 v0.4.5 | 46a45de8 | Version 0.4.5, export (shader baker, launchers, README), release smoke, zip, notes, tag. |
| Phase 2 | 8ba2fab1 + final | 4 cycles: Performance (probe), Balance (Beefcake vs Rot: no change), Performance (the per-visit video memory growth found and narrowed down, `tools/memory_probe.gd`), Balance (six remaining outliers re-measured on two seeds: three confirmed - proposals in balance_log.md, not applied so the zip stays current; next_up 4), then a Primm sequence run that did not finish in time. |

## Part 1 - balance, before / after

Re-measure (6 games per Path, seed 7000, with the new reference decks; reports `docs/design/sim/oct22n/m1_*.md`):

| Kind | Fights | In band | Too hard | Too easy | Mean win |
|---|---:|---:|---:|---:|---:|
| Tutorial (whole run, 50 x 2 seeds per Path) | 3 | 3 | 0 | 0 | B 91/92, G 89/88, R 87/91, N 94/93% cleared |
| Normal | 58 | 48 | 10 | 0 | 90% |
| Elite | 22 | 11 | 5 | 6 | 67% |
| Boss | 22 | 10 | 2 | 10 | 59% (three of the "too easy" are Primm's phases alone; they are judged as one sequence) |

Fixed (16 games per Path, seeds 7000 / 8100; encounter changes only, no cards touched):

| Encounter | Target | Before | After | Change |
|---|---|---|---|---|
| Prudence Pallor (gatekeeper) | 60-75% | 47 / 39% | **56 / 56%** | 16 -> 20 basics, no Red Tape head start |
| Moss Mulligan (gatekeeper) | 60-75% | 50 / 56% | **55 / 59%** | 17 -> 19 basics |
| Baron Quadzilla (Iron Cave boss) | 40-60% | 78 / 84% | **45 / 52%** | "Max Pump": his units +1/+1 |
| The Drain Warden (Lab elite) | 60-75% | 45 / 59% | **69 / 72%** | +2/+2 -> +1/+1 |
| Calf Raise Crusher (Iron Cave) | 80-100% | 73 / 67% | **69 / 80%** | 14 -> 16 basics, 8 -> 6 HP |
| Squat Rack Squatter (Iron Cave) | 80-100% | 78 / 69% | **77 / 75%** | 14 -> 16 basics |

The two gatekeepers are now a few points under their band (within the noise of 16 games); I stopped after three iterations for time.
Not changed: Beefcake in the Rotheart (44-63%, the Rot rule vs x/1 units - inbox 7), Siphon alone 0% (by design, 58% with Elowen -
inbox 8), and six fights 3-10 points out on 6-game numbers (next_up 4). Details: `docs/design/balance_log.md` (last two sections),
`docs/design/sheet_changes.md` (regenerated, plus a hand-written names section).

## Part 5 - the exported build (details: `docs/playtest/exported_oct22.md`)

| Check | Result |
|---|---|
| Opening hour (forest -> Path choice -> cave -> Maren -> shops -> Deck Station -> ghosts -> level 5 -> Bertram) | OK on D3D12 Medium, Vulkan Medium, D3D12 Low, D3D12 Safe Mode, Vulkan Safe Mode |
| Story playthrough (New Game -> Primm -> funeral, Isla, Maren's news) | 90/90 on D3D12 Medium and Vulkan Low (and 90/90 on the project) |
| Tour bot (281 spots, 9 menus, 5 battles) | 5 errors = five models missing from the export - **fixed** (see below) |
| Stalls after a fade-in (limit 200 ms) | worst: Crosspath 119 ms, Capital 96, battles <= 31 |
| Memory after the full tour | RAM 499 MB, video 1.41 GB. Phase 2 probe: textures level off (~600 MB, bounded caches) but ~33 MB of other video memory and ~530 objects stay behind per Crosspath visit - not fixed (inbox 10, next_up 2) |
| Crashes / softlocks | none |

**Fixed: five props were missing from the exported game** (a cup, a pie and an egg in the Buffet, a van and a box in the Dump): the
loaders build model paths from a name, so the export filter thought those models were unused. `tools/update_export_excludes.js` now
keeps models named in the scripts; the v0.4.5 pack has all five.

## How to test the big items

1. **v0.4.5**: unzip `builds/TheWaywardPath-v0.4.5-windows.zip`, run `TheWaywardPath.exe`. Your v0.4.4 save carries over.
2. **Path choice** (New Game): four tiles with a one-line plan each; move the mouse over a tile (or Tab/arrows) for the full text in the
   strip below; press More to keep it open.
3. **Split first talks**: in the D.N.A., talk to Agnes or Gerald the first time - just the introduction and a gold toast "... has a
   favour to ask. Talk again."; the next talk gives the quest. Same for Chet and Chef Flambe (the minigame opens on the next talk).
4. **Maren**: after her speech, each further visit is one short line; it changes once you free a zone.
5. **Agnes in the Hall** (D.N.A. main dungeon, "Take a Number"): after meeting her at the front desk she greets you as an old friend.
6. **Primm with fewer than four zones freed**: phase 2's line keeps only the freed leader's lesson (Grand Chef or Agnes).
7. **The names**: the Dump's animal handler (Billie) and the Calf Cove ripper in the Gainlands (Shredna).
8. **Balance**: Prudence and Moss in Crosspath should feel fairer; the Iron Cave's Baron Quadzilla is tougher.
9. **Exported checks yourself**: `bash tools/run_exported_suite.sh <pck> d3d12 1 playtest` (also `tour`, `story`, `shot`), shots with
   `bash tools/exported_feature_shots.sh`.

## Also worth knowing

- **The PC's disk is full** (~630 MB free, inbox 9): the first rebuilt test pack was cut short by it. Please free some space.
- The story bot had 21 failing quest-chain steps since Oct 20 (it skipped Maren's early chain); it now does the chain: 90/90.
- An error ran every frame after the Rescuer left the cave mouth (`NpcHp` casting a freed node); fixed, also in `NpcBarks`.
- GUT: 2168/2169 passing + 1 pending (the chef-hat art test), 0 failing, after Parts 2-4 and again after Parts 5-6.
- The 499 `.import` quality tweaks the export applies were reverted afterwards (as after every export).

## Inbox (Overnight Oct 22-23 section)

0 the new names; 1 first-talk split at 3 boxes; 2 what was already built on Oct 19; 3 Agnes's met variant; 4 Primm's lesson lines;
5 Capital freed barks (Isla already post-freed); Part 3 note; 6 the six balance changes; 7 Beefcake vs Rot; 8 Siphon alone; 9 disk;
10 video memory creep.
