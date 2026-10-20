# Daytime report - Mon Oct 19 2026

Start 07:06 MDT (tag `pre-daytime-oct19`), all seven parts done by ~10:00, then loop cycles. Last night's report: `docs/overnight_report_oct18.md`.
Old saves keep loading (the save format did not change). Questions for you: `docs/overnight_inbox.md` ("Daytime Oct 19", two items).

## In one minute

- **Your inbox decisions are in.** Items kept as they were; **Processing Time** now exhausts only the first Necrocrat unit each turn
  (tooltip, zone panel, rule badge and arrival warning follow). The **late bosses got one-sided rules** with icons. The big find: Shiro's
  rules had never applied, in the game or in the sim, and the arena's only in the sim. With his existing rules actually in play,
  **Shiro is 48%**; **Grand Bellows 77 -> 56%** with Heckling Crowd. **Primm phase 1** got Royal Guard but stays easy alone, and the
  three phases in a row look *too hard*, not ~50% (see below).
- **Tutorial runs**: Gourmand **~76 -> ~87%** (holds on two seeds). Necrocrat: Part 2's 82 -> 92% **did not hold** on a second seed (cycle
  11 caught it: ~79% either way); a new Necrocrat deck judged on two seeds x 100 runs reaches **~87%** (on main, not in the v0.4.1 zip).
  Beefcake ~95, Refusemancer ~87 (100 runs).
- **Onboarding**: New Game -> first saved deck edit takes **~10.6 min** for a person (97 clicks/keys, 31 dialogue lines), the same for
  every Path. Fixed the worst spot: **the first deck save was impossible without a pointless change** (Save sat greyed out while the
  quest needed a save), and the quest text no longer says to add cards that are already in.
- **First opens**: every first menu open in the full tour is now **<= 128 ms** (character screen was 345, vendors 245-254).
- **One tile style** from the UI kit for the choice tiles; **feedback log + tool**; **v0.4.1 built**: `builds/TheWaywardPath-v0.4.1-windows.zip`,
  **594 MB**, release smoke **15/15 on the exported pack**, tag `v0.4.1` (moved once the same morning, see Part 7).

## Part by part

| Part | Commit | What |
|---|---|---|
| 1 - Inbox decisions | 8f2f473f | Items 1 and 3 kept; Processing Time softened (`FIRST_UNIT_ENTER_EXHAUSTED`); boss rules applied and shown everywhere (`RulesBrief`, ninja/arena/gatekeeper/Primm wiring, five missing icons); Heckling Crowd, Royal Guard; the sim gives Primm the leaders' boons |
| 2 - Tutorial runs | 37561e09 | Necrocrat -Processing Delay -Huge Mistake +Accountant +Grave Shift Worker; Gourmand -Stock The Pantry -Sourdough Sentry +Sous Chef +Volunteer; L1 round robin spread stays 13 |
| 3 - Onboarding bot | 3770363f | `tools/run_onboarding_timing.sh`, `docs/playtest/onboarding_timing.md`; first-save fix and quest text |
| 4 - First-open stutter | da13e51b | `UiArtWarmup` builds the first screens once, under the loading cover, before the glyph warmup |
| 5 - Tile style | 77bb70ad | `UiSkin.choice_tile` on the Path choice, the equipment-slot choice and the Collection Book |
| 6 - Feedback setup | 83d6703a | `docs/playtest/feedback_log.md` + `tools/feedback_row.js` |
| 7 - v0.4.1 | ee6d8933, rebuilt fe9a6986 | Version bump, same excludes, export, `tools/run_release_smoke_exported.sh`, zip, `docs/release/v0.4.1_notes.md`, tag |

## Part 1 numbers (12 games per Path; `docs/design/balance_log.md` "Daytime Oct 19")

| Fight | Before | After |
|---|---|---|
| Gainlands roamers, Necrocrat (Brute / Golem) | 25% / 25% | 33% / 25% |
| Iron Cave normals, Necrocrat | 25% / 33% | 25% / 42% |
| House of Gains, Necrocrat (Sprinter / Brawler / Clench) | 67 / 58 / 33% | 83 / 67 / 42% |
| Shiro Swindle (all Paths) | 88% (rules missing) | **48%** |
| Grand Bellows (all Paths) | 77% (rules now applied) | **56%** |
| Primm phase 1 (all Paths) | 100% | 100% |
| Primm, three phases in a row, no boons | - | 4-21% per Path |

The other Paths did not move in the Gainlands. A level-5 Necrocrat still struggles against the roamers. The replay shows the reference
deck running out of threats against the Golem's wall (cycle 9 corrected my first reading, which blamed the AI).

**Primm**: last night's "~50% for the three phases" multiplied full-HP phases. Measured as the game plays it (one HP pool), it cleared
4-21% *without* the freed leaders' boons. The sim now adds the boons (the story frees every zone first), but **the re-run was stopped by
Claude Code's low-memory guard** (the PC had ~2.6 GB free) and I did not restart it on my own. Measuring it is next_up 1 (inbox Daytime 1).

## Part 2 numbers (whole cave runs, 50 per Path)

At 50 runs on one seed: Beefcake 92 -> 92, Gourmand 80 -> 90, Refusemancer 82 -> 82, Necrocrat 82 -> 92. **Correction (cycle 11)**, 100 runs
on two seeds: Gourmand's gain holds (old 76% -> 87% at seed 8100), Necrocrat's did not (79% old, 77-81% with the Part 2 deck). A new
Necrocrat deck (no Requisition Form, Dispenser or Audit Wraith; a third Accountant, Ghoul and Pink Slip) gives 83 / 91% on the two seeds
and narrows the L1 round robin to 52 / 48 / 47 / 53 (spread 6). It is on main for the next build; the v0.4.1 zip has the Part 2 deck.
Loop cycle 1 tried three Refusemancer swaps (no change); at 100 runs Refusemancer is ~87%, not the outlier 50 runs suggested.

## Part 3: onboarding timing (`docs/playtest/onboarding_timing.md`)

| | Person ~min | Clicks/keys | Lines |
|---|---:|---:|---:|
| Title -> forest -> Path choice -> into the cave | 3.3 | 31 | 24 |
| Cave (modelled: three duels ~4.5 min + map, well, shrine, picks) | 6.1 | ~54 | - |
| Crosspath: Maren -> walk -> Deck Station -> save | 1.3 | 12 | 7 |
| **Total** | **~10.6** | **97** | **31** |

Fixed: the first save (Save Deck stays available until the first save) and the quest text. Noted for you: the Path choice shows 279
words right after 18 lines of dialogue (inbox Daytime 2). Loading and fades total 3.4 s.

## Part 4: first opens (full tour, worst frame per action)

Character screen 345 ms -> off the slow list; item vendor 254 -> 77; card vendor 245 -> 74-111; Deck Station 167 -> 128 (cycle 2);
town worst 345 -> 128; zones 76-83 -> 63-72; 0 errors. A regression from this part was found and fixed in cycle 2: warming the shops
used up their one-time tips, so a new player would never have seen them. `TipPanel.show_once` now skips warming screens (a test
fails without the fix).

## Part 7: the build

`builds/TheWaywardPath-v0.4.1-windows.zip` - **594 MB** (pck 649 MB; v0.4.0: 593 / 649). Release templates ignore `--script`, so the
new `tools/run_release_smoke_exported.sh` runs the **exported .pck** on the stock Godot 4.7.2 binary with the smoke from disk: 15/15
(title v0.4.1, New Game, F8 report with screenshot and log, pause menu version, save/load). The exe ran 30 s to the title with no script
errors. **The tag moved once**: v0.4.1 was first built at ee6d8933; the shop-tip regression above was found afterwards, so I rebuilt from
fe9a6986 and moved the (unshared) tag there. The zip in `builds/` is the rebuilt one. Notes: `docs/release/v0.4.1_notes.md`.

## Loop cycles (`docs/overnight/loop_log.md`)

| # | What |
|---|---|
| 1 | Refusemancer cave run: three starter swaps measured, none kept |
| 2 | Shop tips no longer used up by the warmup; Deck Station warmed (150 -> 128 ms) |
| 3 | Onboarding bot for every Path (10.6-10.8 min, no Path-specific snag) |
| 4 | `feedback_row.js` batch mode (a folder of reports, or the game's feedback folder) |
| 5 | New `tools/run_boss_rules_smoke.sh`: Bellows and Shiro briefs, Continue, HUD row, enemy seat (17/17) |
| check | Story 73/73, first-battles / prologue OK; the stale gatekeeper smoke refreshed (14/14) |
| 7 | "Choose your Path" (the choice screen said "element") |
| 8 | F8 reports name the hero's Path, deck size, fights won, zones freed; the feedback row shows [Path Lx] |
| 9 | The Necrocrat-vs-Golem replay re-read: deck flood, not an AI stall |
| 10 | `docs/playtest/v0.4.1_checklist.md`: a hand-test checklist for your session |
| 11 | Part 2 re-checked on a second seed: Gourmand holds, Necrocrat did not; a new Necrocrat deck reaches ~87% on two seeds |
| 12 | Part 1 bosses on a second seed (25 games per Path): Shiro 60%, Bellows 60% - in band on both seeds |
| 13 | Gainlands roamers on two seeds (Brute ~71%, Golem ~64%, Necrocrat 44-48%); fewer basics moved nothing - reverted |
| 14 | CLAUDE.md lists the new checks and the two-seed rule |

Cycles 3-14 came after the build, so they are on main but not in the v0.4.1 zip (next_up 5).

## Checks

Final (~11:35): GUT **1908/1908**, playtest smoke OK, onboarding bot OK (Necrocrat, new deck). Earlier today: story playthrough **73/73**; full tour 7 areas / 0 errors; playtest, release (project and exported), prologue,
first-battles, gatekeeper and boss-rules smokes OK. Screenshots used: ~14 (tile style, ninja HUD, brief, onboarding gate/station).

## Next (`docs/overnight/next_up.md`)

1. Primm's three phases with the boons (measure). 2. Refusemancer cave run (HP economy). 3. Level-5 Necrocrat in the Gainlands. 4. The
Path choice's text. 5. A v0.4.2 when you want the post-build fixes. 6. Town slow frames. 7-10. Enemy pictures, townsfolk, listen pass,
a tool-only cap glitch.
