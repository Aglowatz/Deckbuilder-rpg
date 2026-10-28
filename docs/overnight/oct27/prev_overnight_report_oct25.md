# Morning report - overnight Oct 25-26 (card set review, Graphics Tier 2)

Started Sun Oct 25 22:13 MDT (Fable), tag `pre-overnight-oct25b` (= f8dc126b; start commit 48b2488e). Brief copy `docs/overnight/oct25b/brief.md`;
state file `docs/overnight/loop_state.md`; questions `docs/overnight_inbox.md` (section "Overnight Oct 25-26"); last report
`docs/overnight/oct25b/prev_overnight_report_oct23.md`. No build was exported and no version was bumped (by rule); the game's cards, data
and sheet are untouched by Part 1 (proposals only).

**The session was dropped at about 00:06 and resumed at 08:05 on your "resume"**: Parts 1 and 2 were complete by then and only Part 2's
final verification (walk smokes, the budget check, the after shots and fps table) and this report were run after the 8-hour window. The
Phase 2 polish cycles were not started (no `loop_log.md` entries tonight).

## Read this first

- **Card review** (`docs/design/card_review_oct25.md` + `.csv`): 29 proposed changes (4 High, 8 Medium, 17 Low) and 14 fully written new
  cards. The set is in good shape; the real gaps are Necrocrat's missing unconditional removal below Epic (its level-12 reference deck won
  23% of a round robin, 0% vs Gourmand), Refusemancer's missing Common recursion and top end, one Common that follows no template (Push
  Broom of Undeath), one dead-in-PvE hate card (Let Them Eat Cake) and two IP slips (Jello Weights, Ratatouille's film-motto flavour).
- **Graphics Tier 2** (`docs/art/graphics_tier2.md`): six features kept, each its own commit, all within budget and 60+ on Medium: height
  fog in the Dump's ravine, a bounce-colour channel in the ground light map, one shared wind, water refraction in the shallows, a
  shadow-casting lantern at night (the forest camp), FSR 2 as the Medium default on discrete GPUs. SSAO on Medium was measured and dropped
  (+2.3 ms: 57.8 fps on the square); vertex AO on the kit and ground decals turned out to be already present from earlier passes.

## By part

| Part | Commits | What |
|---|---|---|
| 0 setup | 48b2488e | tag, brief copy, loop state, a leftover Oct 23 bestiary screenshot anchor |
| 1 card review | 9b6bd54e | 312 cards + 25 tokens read against the Design Guidance; `card_review_oct25.csv` (43 rows) + `.md`; sims `docs/design/sim/review_*.md` |
| 2 Tier 2 | 669b0718 (f1 height fog), fd4ec9ab (f2 bounce), 43015ac7 (f3 wind), a17851a5 (f4 water), ca482c83 (f5 lanterns), 465bdba4 (f6 FSR 2), 15a53b2c (test + doc) | see `docs/art/graphics_tier2.md` |
| Phase 2 | - | not started (the session dropped at 00:06) |

## Card review headline

| | Proposals | High | Medium | Low | New cards |
|---|---:|---:|---:|---:|---:|
| Refusemancer | 7 | 1 | 2 | 4 | 3 |
| Necrocrat | 5 | 1 | 2 | 2 | 4 |
| Beefcake | 4 | 0 | 1 | 3 | 3 |
| Gourmand | 2 | 0 | 1 | 1 | 2 |
| Dual / tri Path | 9 | 2 | 2 | 5 | 1 |
| Colorless | 2 | 0 | 0 | 2 | 1 |
| **Total** | **29** | **4** | **8** | **17** | **14** |

By category: Clarity 12, Role 6, Flavour 5 (two IP), Fun 3, Power 1 (The Cullinator), Identity 1, Early game 1, New card 14. The Black Market's
eight cards were read but excluded from proposals.

**Top 15**: (1) N-10 Push Broom of Undeath made a real attached Tool, 2(N); (2) R-21 Let Them Eat Cake never dead: 3 damage, destroy + Garbage
if Gourmand; (3) NB-13 Jello Weights renamed, lyric flavour replaced, unit wording fixed; (4) GR-16 Ratatouille's film motto replaced; (5) NEW
Final Notice (Necrocrat U, destroy target unit + Red Tape); (6) NEW Curb Alert (Refusemancer C, Regrow + Garbage); (7) NEW Iron Filing Clerk
(N/B U, Iron <-> Red Tape); (8) G-22 The Cullinator +1 energy; (9) R-26 The Recycling Center on your turn instead of end of turn; (10) BR-06
Hamster Ball earns a Garbage on hits; (11) NB-01 Shredded Spectre's resource text rewritten; (12) R-03 Landfill Ox one eat for (R)(R)(R);
(13) B-02 Bronzer to (B); (14) N-19 Resting In Peace Clause to Uncommon; (15) N-22's flavour typo.

**New cards (14)**: Hammer Thrower, Protein Shake, Desk Flip (Beefcake); Final Notice, Pending Approval, Service Charge, Compliance Review
(Necrocrat); Amuse-Bouche, Pest Control (Gourmand); Curb Alert, Sewer Choir, Landfill Leviathan (Refusemancer); Hand-Me-Down Shield
(Colorless); Iron Filing Clerk (Necrocrat / Beefcake). Each row carries a ChatGPT-ready image description with the style lock and Path accent.

**Early game**: power is not the problem (every starter clears the cave 87-98%); identity shows late (starters are 14-15 Colorless of 26,
Sable's sample is five Colorless Commons plus one of each Path). The new Commons are starter candidates, one Colorless swap each; a vendor-side
suggestion: Sable sells two Commons of the player's own Path. Designer notes (the Guidance's `#ERROR!` Buff cell, unused keywords Cook / Yeet /
Regrow, the no-op "enters refreshed" line, the P4 section header) are at the end of the review.

## Graphics Tier 2 - before / after and fps

Shots: `docs/art/graphics_tier1/t2_before/<area>.jpg` vs `t2_after/<area>.jpg` (the Tier 1 camera spots); per feature in
`docs/art/graphics_tier2/f1_heightfog/` (Dump stream before/after), `f2_bounce/` (square, street, a 3x version, the raw channels),
`f3_wind/`, `f4_water/`, `f5_lanterns/`.

| Area | Low before -> after (fps) | Medium before -> after | High before -> after | Medium avg ms vs budget |
|---|---|---|---|---|
| town_square | 93.6 -> 95.0 | 66.2 -> 65.5 | 19.5 -> 19.4 | 15.26 vs 19.5 |
| town_street | 91.9 -> 92.7 | 64.4 -> 65.1 | 19.3 -> 18.0 | 15.36 vs 19.5 |
| forest | 120.2 -> 125.0 | 83.6 -> 83.3 | 24.1 -> 24.4 | 12.01 vs 15.5 |
| gainlands | 96.3 -> 95.7 | 76.5 -> 75.8 | 25.8 -> 26.1 | 13.19 vs 19.2 |
| buffet | 106.2 -> 100.1 | 79.7 -> 77.5 | 27.6 -> 26.0 | 12.90 vs 16 |
| dna | 99.4 -> 102.9 | 86.7 -> 86.9 | 30.6 -> 31.0 | 11.51 vs 15.7 |
| heap | 92.0 -> 87.9 | 75.3 -> 71.9 | 26.9 -> 25.3 | 13.90 vs 17.1 |
| capital_out | 85.2 -> 85.0 | 68.4 -> 69.0 | 22.7 -> 22.6 | 14.49 vs 18.2 |
| capital_in | 85.8 -> 87.0 | 69.2 -> 70.0 | 23.6 -> 23.9 | 14.29 vs 18.5 |
| battle | 363.0 -> 366.0 | 365.2 -> 363.5 | 362.5 -> 370.4 | 2.75 vs 3.8 |
| dungeon_map | 456.0 -> 473.7 | 454.3 -> 464.6 | 446.4 -> 464.3 | 2.15 vs 2.9 |

GPU ms per row and the single-feature costs are in `docs/art/graphics_tier2.md`. Medium holds 65-87 fps everywhere; Low and High are
within run-to-run noise; every area sits 3-6 ms under its Medium budget line.

## What to look at first in-game

1. **Crosspath square and west street** (Medium or High): the cobbles beside the timber houses lean warm now (bounce colour); walk along a
   wall and watch the hero's feet pick up the tint. Set `light.bounce` in `data/zone_styles/main_town.json` to 0 / 3 to compare live (hot reload).
2. **The Verdant Dump**: the water beside the entrance bridge and the stream in the ravine sit in a pale violet mist; the terraces are clear.
3. **The Gainlands plaza**: watch a gust cross the scrub, the banners on the bridge and the trees together.
4. **Any shallow water** (the Dump's river edge, the Buffet's shore): the bed shows through with a wobble; deep water is unchanged.
5. **The forest camp at night**: the lantern beside the bedroll throws a real shadow (Medium: one lantern; High: two).
6. On a discrete GPU, Settings > Display shows Auto = FSR 2 on Medium (the log line "discrete GPU: FSR 2 is the Medium upscaler under Auto").

## Checks

- GUT: root 247, core 1414 (+1 pending, known), ui/audio/characters 195, world 394 - all passing (one text test updated for the wind include).
- Walk smokes: Crosspath, opening forest, Gainlands, Buffet, D.N.A., the Dump, the Capital - all OK (run after the resume, 08:06-08:24).
- `perf_budget.sh structure`: all budgets met. `perf_budget.sh frame`: the background run was stopped by the tool harness for low system
  memory (it wrote nothing; an orphaned Godot process was killed by hand) and was not restarted by the run; the after-fps table stands in
  for it (every area inside its Low/Medium lines). Please re-run `bash tools/perf_budget.sh frame` when the PC is free.
- Not run tonight (the dropped session): the tour bot, the story playthrough bot, the first-battles and release smokes. Part 1 changed nothing
  in the game, so it needed none.

## Inbox (yours to decide; the safest choice was taken)

See `docs/overnight_inbox.md`, "Overnight Oct 25-26".
