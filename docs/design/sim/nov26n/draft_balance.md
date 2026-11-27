# The draft balance audit (Nov 26 night, Part B) - proposals only, nothing applied

Brief: `docs/prompts/opus_nov26_night_v2.md`, Part B. **Nothing in the game was changed**: every proposal below is one number or one line,
and the card proposals were simulated with a sim-only override (`tools/draft_audit.gd --override=...`), never written to the data.

## How it was measured

- **Tool:** `tools/draft_audit.gd` (batches: `bash tools/run_draft_audit.sh 8 1`; raw files `raw/*.json`; tables
  `python tools/nov26n_draft_report.py` -> `draft_tables.md`, which holds every number quoted here).
- **The drafter** plays like a sensible player: each card by a plain taste (units on curve, cheap answers) plus fit with what it has
  plus rarity; gear by rarity plus a bonus for pieces that name one of its Paths; items heal first. It builds the default deck and plays
  every fight **as the game builds it** (`DraftRun.build_game`: the rivals' drafted decks, full opening hands, their gear, their skill).
  Mystery Mini plays a mini dungeon's three fights on one HP pool.
- **Volume:** 216 drafts, 584 fights: Classic with each single Path and each pair (8 drafts each, level 18), three-Path and four-Path
  Classic (level 23; two of the four trios), High Rollers with each single Path, two pairs and all four Paths, Mystery Mini with each Path,
  and the four zone drafts (level 12). One game per rival per draft; a fight undecided after 20 turns each counts as lost.
- **Not measured** (time): four High Rollers pairs, two three-Path Classic sets, High Rollers with three Paths. Their cards and gear are
  still counted wherever they appear in the other modes.

**How to read it.** A row of 8 drafts is 24 fights: about +/-20 points of noise, so only big gaps mean something. The card and gear
"change" compares decks of the same configs with and without the card or piece; it is a lead, not a verdict, which is why each proposal
was simulated on its own. **Pick rates are the sim drafter's, not a player's:** its taste never picks spells like Pink Slip or Mass
Layoffs (0 % below), which says more about the drafter than the cards; those are reported but not proposed against.

## Draft win rates by mode and Path set

| Mode | Paths | Win rate (fights) | Note |
|---|---|---:|---|
| Classic (L18) | Refusemancer | **92 %** (22/24); 81 % over 16 drafts with the proposal sims' seeds | the outlier of the night |
| Classic | Beefcake + Necrocrat | **79 %** | the strongest pair |
| Classic | Beefcake + Gourmand | **75 %** | |
| Classic | Beefcake / Beefcake + Refusemancer | 62 % / 62 % | |
| Classic | Gourmand + Necrocrat, Gourmand + Refusemancer, Necrocrat + Refusemancer | 46 % each | |
| Classic | Gourmand | 42 % | |
| Classic | Necrocrat | **33 %** | the weakest single Path |
| Classic (L23) | three Paths (two sets) / all four | 50 % / 46 % | |
| High Rollers (L18) | Beefcake, Necrocrat / Refusemancer, Gourmand + Refusemancer / Beefcake + Necrocrat | 54 % / 46 % / 50 % | |
| High Rollers | **Gourmand** | **29 %** | |
| High Rollers (L23) | all four Paths | 25 % | |
| Zone drafts (L12) | Beefcake / Gourmand / Necrocrat / Refusemancer | **29 %** / 42 % / 50 % / 54 % | Trey's Gainlands draft is the hardest |
| Mystery Mini | Beefcake, Gourmand / Necrocrat / Refusemancer | 38 % / 50 % / 75 % (clears) | |

By mode: Classic 58 % a fight before Primm (49 % after), High Rollers 47 % (25 % with all four Paths after Primm), zone drafts 44 %,
Mystery Mini 50 % of runs cleared. The target of earlier passes was 50-60 % for a sensible draft: Classic and the zone drafts sit there
on average; **Gourmand is the weak draft Path** (42 / 29 / 42 % in Classic / High Rollers / its zone) and **Refusemancer the strong one**.

## The top overperformers (held by 8+ decks; full list in `draft_tables.md`)

| Card | Decks | Win rate with it | Change |
|---|---:|---:|---:|
| Notary Wraith (N-06, C) | 11 | 62 % | +22.7 |
| Raccoon (R-27, E) | 30 | 68 % | +22.6 |
| Middle Management Zombie (N-23, U) | 30 | 60 % | +21.5 |
| Spice Bazaar (INF-03, U Infrastructure) | 22 | 45 % | +19.1 |
| Bone-afide Strongman (NB-14, E) | 10 | 73 % | +19.0 |
| Body-builder (N-04, C) | 14 | 61 % | +18.0 |
| Gym Rat (BR-01, U) | 8 | 67 % | +16.7 |
| Millstone Pusher (B-04, C) | 20 | 67 % | +16.6 |
| Wandering Medic (C-07, C) | 17 | 71 % | +16.0 |
| Corpseified Public Accountant (N-05, C) | 16 | 52 % | +15.4 |

## The ten weakest (held by 8+ decks)

| Card | Decks | Win rate with it | Change |
|---|---:|---:|---:|
| Farm-to-Table Chef (GR-01, U) | 9 | 30 % | -29.9 |
| Recyc-lops (GR-12, E) | 9 | 33 % | -29.6 |
| Possum Prowler (R-08, C) | 21 | 47 % | -21.4 |
| Grand Chef Escoffina (G-33, L) | **58** | 44 % | **-20.7** |
| Rubbish Goat (R-04, C) | 8 | 45 % | -17.9 |
| Spotter (B-08, C) | 12 | 47 % | -15.3 |
| Snack Bar (B-23, U) | 10 | 38 % | -15.3 |
| En Garde-Manger (G-23, U) | 38 | 39 % | -15.1 |
| Mount Trashmore (R-29, E) | 37 | 59 % | -12.9 |
| Cartographer's Table (C-28, U) | 24 | 48 % | -11.8 |

Cards the drafter never took although offered 12+ times (a drafter blind spot, not proposed against): Desperate Measures, Second Wind,
Mass Layoffs, Windowsill Herb Garden, Flex on 'Em, Compliance Review, Counterweight, Pink Slip, Recycling Day, Meatloaf Mold, Sent Back to
the Kitchen, Buried in Paperwork, Reclaimed Land, The Verdant Vines, Membership Cancellation.

The firmest signals, by sample size: **Grand Chef Escoffina** (58 decks, the drafter takes her 83 % of the time on rarity, her decks
win 21 points less), **Raccoon** and **Middle Management Zombie** (30 decks each, +22), and **En Garde-Manger** (38 decks, -15). They
match the Path picture: Gourmand's Legendary and its 2/4 Sucker Punch drag Gourmand drafts down; the Raccoon carries Refusemancer.

## Equipment and items in the draft pool

The 12 newer draft pieces and the rest, with offers, takes and the change (decks with it against decks of the same configs without):

- **Overperformers:** Quota's Stopwatch (+22.2, 10 drafts), Pantry Apron (+20.7, 13), Protein Shaker Bandolier (+18.4, 23),
  Mystery-Stain Bib (+17.3, 23), Glass Jaw Gauntlets (+16.7, 15), Elastic Waistband (+14.6, 20), Curve-Topper Boots (+13.1, 29).
- **Underperformers:** Bin Lid Helm (-25.7, 4), Red Tape Dispenser (-24.1, 11), Crowd-Pleaser's Cape (-23.1, 17), Steady Sandals (-15.2,
  10), Pathwork Waistcoat (-14.3, 19), Booster-Wrapper Cape (-14.3, 33), Overdue Library Book (-13.4, 7), Velvet Rope (-11.5, 15).
- **Never taken** (the drafter takes the rarer piece, and these Commons always lose that race): Cardboard Cuirass, Solid Plate, Thinking
  Cap, Wicked Dagger, Lucky Pack Wrapper, the Extra Pocket (offered 54 times). Not a verdict on the pieces.
- **The Extra Pocket, measured on its own:** see the note under the proposals.
- **Hover Boots at High Rollers:** rivals wearing them lost more than average: the player won **58 %** against a rival in Hover Boots
  (26 fights) against 47 % at High Rollers overall. The boots' "block only flyers" costs a rival more than its flying gains; not an
  outlier, no change proposed. As the player's own piece the drafter took them 39 times, change -6.6.
- **Items:** Vitality Charm (-11.5, 52 drafts) and Bag of Rubbish (-15.8, 13) trail; Scroll of Insight, Power Wraps and Binding Chains
  lead on small samples. Healing Salve and Hearty Pot Pie are taken most (94 %, 81 %) and sit just above average.

## Mode rewards against the economy

`modes_economy.md` (`python tools/draft_economy.py` with tonight's win rates: Classic 58 %, High Rollers 47 %, Mystery Mini 50 %; the
Halls and the Dungeon Draft at the Nov 24 rates, not re-measured):

| Before Primm | Worth a run | Worth per hour |
|---|---:|---:|
| Classic Draft (replay) | 155 | **430** |
| High Rollers (replay, 100 gold fee) | 239 | 688 |
| Mystery Mini | 208 | 654 |
| Dungeon Draft (a zone dungeon) | 615 | 828 |
| The Shuffled Halls (replay) | 269 | 708 |
| *main game: a replayed main dungeon / side dungeon* | 450 / 350 | 675 / 1,500 |

- **No mode breaks the economy:** nothing out-earns a replayed side dungeon, and only the Dungeon Draft beats a replayed main dungeon
  per hour (by about a fifth, and it needs that dungeon cleared first).
- **Classic replays are the one mode that pays too little:** 430 an hour, two thirds of a main-dungeon replay, because 58 % a fight
  makes only 44 % of runs full wins. It is still the place to learn drafting, and its first win pays well (about 464 weighted).

## Proposals (one number or one line each; simulated where marked)

The card proposals were simulated on their own: the same configs and draft seeds with and without the change (`proposals/*.json`,
`tools/run_nov26n_proposals.sh`).

| # | Group | Proposal | Why | Simulated (same configs and seeds, 16 drafts, 48 fights) |
|---|---|---|---|---|
| B1 | Overperformer | **Raccoon (R-27): cost 0 -> 1 generic** (1 + R) | +22.6 over 30 decks; carries Refusemancer drafts | Refusemancer Classic + High Rollers **60 % -> 50 %** (-10). **Recommended.** |
| B2 | Overperformer | Middle Management Zombie (N-23): 3/5 -> 3/4 | +21.5 over 30 decks | Necrocrat / Beefcake + Necrocrat 60 % -> 62 % (+2, noise): **not supported; leave it.** |
| B3 | Dead card | Grand Chef Escoffina (G-33): cost 3 -> 2 generic | -20.7 over 58 decks | Gourmand / Gourmand + Refusemancer 60 % -> 60 % (+0): **cost is not her problem; leave it** (her three Ingredients need payoffs a draft rarely has) |
| B4 | Dead card | **En Garde-Manger (G-23): 2/4 -> 3/4** | -15.1 over 38 decks; Gourmand is the weakest draft Path | Gourmand Classic + High Rollers 60 % -> 65 % (+4). **Mildly recommended.** |
| B5 | Gear outlier | Crowd-Pleaser's Cape: "gain 1 HP" -> "gain 2 HP" when you declare attackers | -23.1 over 17 drafts | not simulated (gear has no sim override yet) |
| B6 | Gear outlier | Red Tape Dispenser (the helm): "create 1 Red Tape" -> "create 1 Red Tape and gain 1 HP" at the start of your turn | -24.1 over 11 drafts | not simulated |
| B7 | Gear outlier | Quota's Stopwatch: Max HP +3 -> +1 | +22.2 over 10 drafts (small sample) | not simulated |
| B8 | Economy | Classic replay gold +50 % (20/45/80/140 -> 30/68/120/210) | Classic replays pay least (430 an hour) | 430 -> **553** an hour in the economy model, still under a main-dungeon replay (675) |
| B9 | Path | No direct change: B1 and B4 move Refusemancer down and Gourmand up; re-measure after them | | |

The Extra Pocket's paired measurement ran over its 20-minute limit and wrote nothing; see the report for whether a smaller rerun made it.
Raw proposal runs: `proposals/*_base.json`, `*_proposal.json`; table: `proposals/proposals.md` (`python tools/nov26n_proposal_table.py`).
