# Report - Overnight Oct 29-30: economy + equipment balance, hat fit (Fable)

Thu Oct 29, 18:54 MDT -> (the stop time is at the end). Tag `pre-overnight-oct29`. State `docs/overnight/loop_state.md`; loop log
`docs/overnight/loop_log.md`; questions `docs/overnight_inbox.md` ("Overnight Oct 29-30", items 1-10). Last run's report:
`docs/overnight/oct29/overnight_report_art_oct29.md`. Dialogue freeze respected (no dialogue file, quest file or key touched); no art
generated; the black market untouched; no version bump, no export. Old saves load: nothing is deleted or confiscated, owned pieces take
their new stats and the shops their new prices.

## Read this first

- **The economy has a curve now** (`core/data/economy.gd`, `docs/design/economy.md`): cards 30 / 60 / 150 / 300 by rarity, gear by rarity x
  tier (60 / 90, 120 / 180 / 240, 450), items 30 / 45 / 60, cosmetics by unlock stage, packs 100 / 150 / 200 / 600 / 900. Payouts: roamers by
  zone tier (35-70), side-dungeon clears 100 / 40, arena replays 25, the level track's gold front-loaded, essence per duplicate doubled.
- **The Wicked Dagger** buffs Colorless units only now (half the early decks); its old "+1 attack to every unit" is the new **Blade of Earned
  Reputation** (Epic, Bertram's L13 rack, 450). Same treatment for the Solid Plate; the Spotter's Barbell and the Lifting Belt are
  Beefcake-only; 20 pieces and the Reckless Tonic changed in all (table below).
- **Hats**: the preview never differed from the world (same anchors, checked cell by cell); the hats sat too high from the side and behind in
  both. Fixed per hat and direction in `fit.json`; contact sheets in `docs/art/apparel/oct29/`.
- **Phase 2** added the late sink the audit found missing: a world card pick can be **rerolled once for gold** (40 + 10 x level); shop tiles
  show rarity colours, readable effects and an Upgrade / Sidegrade / Downgrade verdict; reward boxes say what the gold is now and buys.
- **Open for you** (inbox): the XP curve runs far ahead of the progression model (1); Primm as a sequence is 78 % with the real L22 gear (2);
  the House of Gains' Honor Guard reads 50 % and the Forgotten Vault's normals 54-67 % (3, 10); the reroll's price and reach (4).

## By part

| Part | Commit | What |
|---|---|---|
| 1 Economy audit | 6264456c | `tools/economy_model.gd` + `economy_model_tool.gd`: every source and sink on the story timeline, three profiles; `docs/design/economy_audit_oct29.md` (10 ranked problems); `sim/economy_model_before.md` |
| 2 Economy design + pricing | 04d28dcc | `Economy` curve; every vendor, roamer, clear and reward reads it; `docs/design/economy.md`; before / after curves; `sheet_changes_oct29.csv`; tests; export preset version 0.4.7 (a pre-existing failing test) |
| 3 Equipment + items | 45311175 | `docs/design/equipment_budget_oct29.md` (points, budget, every piece reviewed, slot progression); 20 piece changes + the Blade; `Modifier.matches_card` handles Colorless; unit-enter effects honour colour; expected player's gear by stage; sims |
| 4 Hat fit | 2d38e6e9 | `tools/hat_contact_sheet.tscn` (world and preview side by side, fit table), `WorldSprite.forced_key`, per-hat tilt, `fit.json` sinks, `DIR_SINK` re-based, `tools/crop_png.gd` |
| Phase 2 | 74259648, 5e2ee265, f65f7631 + later cycles | shop / picker verdicts and rarity colours; reward-box purse line; hat tilt test; reward-pick reroll; Primm phase HP; Quadzilla; side-dungeon sims |

## Part 1 - what the audit found (`docs/design/economy_audit_oct29.md`)

Sources once: ~19,600 gold (main route 6,285; chests 4,185; level track 3,070; side quests 2,090; arena 1,560; feats 1,620 ...). Sinks that
are not repeatable: ~12,000. Ranked problems: gold in lumps at the dungeons and nothing on arrival; everything affordable at every stop;
hoarding from the Capital on with no sink; the armory pinch at L5; prices on no curve; side-dungeon clears paying less than their nodes;
the XP curve throwing the level track's late gold into the main game; essence that barely exists; items the one flat sink.

## Part 2 - targets and before / after (expected profile, gold on hand -> after buying)

| Stop | Before | After (Part 2) | After (with the reroll) |
|---|---:|---:|---:|
| Level 5, the armory | 329 -> 39 | 320 -> 35 | 320 -> 35 |
| Gainlands freed | 1,674 -> 323 | 1,735 -> 315 | 1,735 -> 315 |
| D.N.A. freed | 1,703 -> 352 | 1,890 -> 340 | 1,890 -> 340 |
| Buffet freed | 1,752 -> 341 | 1,855 -> 65 | 1,855 -> 65 |
| Dump freed | 2,676 -> 545 | 2,695 -> 355 | 2,695 -> 355 |
| End of the run | 3,982 left | 3,070 left | 1,900 left |
| Spent of income | 79 % | 84 % | 90 % |

Rusher 80 -> 91 -> 95 %, thorough 72 -> 76 -> 81 %. Droughts: none for the expected player (the rusher sits at 18-63 gold for three stops
after the armory by its own choice of stock). Hoarding: none through the Dump; the Capital's surplus is what the reroll now eats.
Targets 1-3 and 5-8 hold; target 4 (gold always has a use late) holds with the reroll. Full tables: `docs/design/sim/economy_model.md`
(before: `economy_model_before.md`).

### The price table

| Sink | Common | Uncommon | Epic | Legendary |
|---|---:|---:|---:|---:|
| Cards (no energy term) | 30 | 60 | 150 | 300 |
| Gear tier 1 / 2 / 3 | 60 / 90 / - | 120 / 180 / 240 | - / 300 / 450 | never sold |
| Items (weak / standard / strong) | 30 | 45 | 60 | - |

Packs General 100, Path 150, General II 200, Gilded 600, Prismatic 900. Cosmetics 100 / 120 / 150 (start), 250 / 250 (L4-5), 300 / 300
(one zone), 350 / 400 (two zones), 1,000 (Primm). Alchemist 150 + essence. Reroll 40 + 10 x level. Payouts: roamers 35 / 40 / 50 / 60 / 70
by zone, elites 100 / 150, side clears 100 first / 40 repeat, arena replay 25, level track 240 / 520 / 1,230 / 1,100 by band, essence
2 / 4 / 8 / 16 per duplicate. Every row with old and new: `docs/design/sheet_changes_oct29.csv`.

## Part 3 - the power budget and every change (`docs/design/equipment_budget_oct29.md`)

Points per effect (max HP +1 = 0.5, a draw each turn = 3, any-colour +1 attack = 3, one-Path +1/+1 = 2.5, drawbacks negative); budget
Common <= 1, Uncommon 1.5-2.5 (3 with a drawback), Epic 3.5-5, Legendary 5-6; board-wide any-colour effects never at tier 1, from L9 with a
drawback, from L13 without.

| Piece | Change |
|---|---|
| **Wicked Dagger** (U, L5) | your units +1 attack -> your **Colorless** units +1 attack (the designer's outlier; L5 lift +3 -> +5 on Colorless only) |
| **Blade of Earned Reputation** (E, NEW, L13 rack, 450) | your units +1 attack (the Dagger's old effect, where it belongs) |
| Solid Plate (U, L5) | your units +1 defense -> Colorless units +1 defense |
| Spotter's Barbell (E, Gainlands quest) | 1 damage whenever a unit enters -> whenever a Beefcake unit enters (+17 alone at L5 -> +0) |
| Gainsmith's Lifting Belt (puzzle) | units +1 defense -> Beefcake units +1 defense; Uncommon |
| Glass Jaw Gauntlets (E, D-HOG) | -3 starting HP -> max HP -3 (the cost counts in dungeons) |
| Sucker Punch Mitts | -1 defense to all, Epic 450 -> max HP -3, Uncommon 240 |
| Gotta-Go Galoshes / Champion's Laurels / Gladiator's Net | Epic -> Common / Epic -> Uncommon / Uncommon -> Epic (+21) |
| Crown of Mild Hubris (L) | + your units +1 attack (+1/+1 pushed Primm's phases to 92-100 %) |
| Four-Seal Signet (L) / Siphon's Lens (E) / Phial of First Water (L) | max HP +5 + first-turn draw / draw an extra card each turn / + max HP +3 |
| Quota's Stopwatch / Colonel's Ladle / Plume's Quill / Clipwell's Shears (E) | first-turn draw + max hand +2 / max HP +3 / 2 Red Tape + a Contract / 2 damage to each attacker |
| Reckless Tonic | heal 6 -> 5 |
| Engine | `Modifier.matches_card`: colour NEUTRAL = Colorless cards (never matched before); `ON_UNIT_ENTER_EFFECT` honours the modifier's colour |

Caps and the track checked (one Epic slot until L13 is a real choice; the Uncommon cap of 2 until L10 bites); every slot has upgrades and
sidegrades per zone (the Boots are the thin slot).

### Sim results (expected player's real gear; `docs/design/sim/oct29_*.md`)

| Check | Result |
|---|---|
| The cave (30 runs per Path) | B 90 / G 92 / R 80 / N 97 |
| Gainlands roamers at L5 (16 games) | 81 % (B 94 / G 94 / R 69-81 / N 69) |
| House of Gains (seeds 7000 x6, 8100 x12, 7000 x12) | normals 69-98; Quota 71 / 54 / 63; Honor Guard 46 / 52 / 50 (band 60-75; inbox 3); Clench 38 / 42 / 46 (band 40-60) |
| Hall of Final Approvals | elites 67-79; Mortimer 67 |
| Test Kitchen | elites 75-83; the Doppelganger 50 |
| Rotheart | elites 83; Compostella 67 |
| Buffet / Capital elites | Casserole 63; Spotless 92 |
| Primm's Castle | normals 100, elites 83-88; the phases as one HP pool 82 % -> 78 % with phase HP 40 / 36 / 36 (inbox 2) |
| Side dungeons (6-12 games) | Iron Cave normals 75-85, Quadzilla 33 / 31 -> see the loop log (his rule softened); the Vault normals 54-67 (inbox 10), the Automaton 50 / 63; the Waiting Room 88-100, Betty 50; Omakase 88-92, the Itamae 83 |
| Items alone at L12 (6 games, +-12) | Chains +17, Tonic +13 (after 6 -> 5), Pie +13, Salve +8, Firebrand +8, Scroll -8, Stone -8 (inbox 6) |

The first three zones' bosses sit in or just over their 40-60 band.

## Part 4 - hats

- Tool: `Godot --path . --resolution 1200x900 res://tools/hat_contact_sheet.tscn -- --out=oct29/hats_after [--hats=..] [--combined=1]`:
  every hat x FRONT / FRONTSIDE / SIDE / BACKSIDE / BACK x idle / walk1-4, each cell as the world draws it and as the wardrobe / tailor
  preview draws it, plus `fit_table.md`. (The hero has no TALK frame.)
- Finding: world and preview place hats identically (the same `hat_anchor` per frame). In both, every hat floated above the hair from the
  side (0.1-0.15 head widths) and from behind (0.2): the importer's sinks were tuned on the front view. A first pass at twice that buried
  the eyes; the second pass is in `assets/art/cosmetics/hats/fit.json` (per hat, per direction) and `HatSheet.DIR_SINK` for future imports.
- Sheets: `docs/art/apparel/oct29/before_WIDEBRIM.png`, `before_CHEF.png`, `after_ALL.png` (all six hats), `fit_table.md`;
  `_screenshots/oct29/hats_before/*.png` (six) and `hats_after/`.
- Art notes (inbox 9): the Leaf Crown's back half over the hair (known), the Chef's BACK and the Wizard's SIDE views painted larger than
  the rest (the fit scales them). `fit.json` now also takes `rot` / `rot_<DIR>` (a tilt about the hat's own middle); none needed.

## Phase 2 (`docs/overnight/loop_log.md`)

1. Shop and picker: rarity name and colour on every tile, effect text readable, "Upgrade / Sidegrade / Downgrade vs <worn piece>"
   (`EquipmentCompare.verdict`, tests). Shot `_screenshots/oct29/p2_vendor_geared.png`.
2. Reward boxes: "462 gold in your purse now - an Uncommon card's worth" under the counters. Shot `p2_reward_gold.png`.
3. Hat tilt covered by `test_hat_sheets`.
4. **Reward-pick reroll**: a world pick rerolls once for 40 + 10 x level gold (button under the cards; never counts as a win). Tests,
   gatekeeper pick probes by mouse and pad, shot `p2_reroll.png`. The economy model with it: expected leftover 3,070 -> 1,900.
5. Later cycles: see the loop log (side-dungeon sims, Baron Quadzilla's rule, the tailor preview check).

## Checks run

GUT root 286 (release-readiness fixed), core 1493 + 1 pending, ui 242, world 422; first-battles smoke (twice), hub walk smoke, Crosspath
walk smoke, gatekeeper pick probes (mouse, pad); structure budget OK. Screenshots: 2 (Part 2), 0 (Part 3), 10 (Part 4), 4+ (Phase 2).

## Inbox (Overnight Oct 29-30)

1 XP curve vs the progression model. 2 Primm 78 % as a sequence. 3 the Honor Guard 50 %. 4 the reroll (added; price / reach). 5 quests,
chests, feats left alone. 6 Binding Chains +17. 7 zone fees left. 8 the Belt and the Barbell Beefcake-only. 9 hat art notes. 10 the Vault's
normals.
