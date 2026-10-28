# Cards Oct 27

Three parts, one commit each (pushed): Part 1 `64b26aab`, Part 2 `84e29a2e`, Part 3 `284f77a0`; the bots and the post-change sweeps
`3625bf8a`; the v0.4.6 build `6f2947ef`. Questions and the safe choices taken: `docs/overnight_inbox.md`, section "Cards Oct 27".
Old saves load unchanged (new saved fields have defaults; decks are never touched). No new art; no enemy intent; the Black Market
(Fig Sly, the Secret Dealer) and its cards untouched.

Design docs written on the way: `docs/design/card_availability.md` (who can get which card), the "Cards Oct 27" sections of
`docs/design/balance_log.md` (the sims) and `docs/design/reward_cards.md` (collection routing). Sheet mirrors for the designer:
`docs/design/sheet_changes_oct27.csv` (one row per changed or new card, `node tools/sheet_changes_oct27.js` rebuilds it) and
`docs/design/sheet_availability_oct27.csv`.

## Part 1 - The card review applied (29 changes + 14 new cards)

No "Card Review Oct 25" sheet export existed in `data/source/`, so every row of `docs/design/card_review_oct25.csv` counted as approved,
the three opposing-Path hate cards included. `_logs/cards_oct27_apply.js` wrote the CSV rows byte-exact, `_logs/cards_oct27_scripts.js` the
script blocks; then `bash tools/import_cards.sh --stamp` / `--write`.

**Changed** (full table with the why of each: balance_log.md): Let Them Eat Cake deals 3 and destroys a Gourmand unit, Landfill Ox has one
clear cost, the Recycling Center works on your own turn, Reclaimed Land asks for one Infrastructure, Rusty Can Opener makes a Garbage, the
Cullinator costs 4, Bronzer costs (B), Dry Scoop gives +1/+0, Alarm-ish Clock and the Mill Worker cost one less, Push Broom of Undeath is a
Tool that destroys resources, Resting In Peace Clause is Uncommon, Hamster Ball makes Garbage, Shredded Spectre pumps off Red Tape and Iron,
Jello Weights is **Wobble Weights** (name, text, flavour), Ratatouille's flavour is ours, Bulking Program is an Ingredient trigger, Harvest
Festival uses the Pantry's wording, Cannon Fodder is 2/1, the Old Kingdom Automaton 4/6, plus title-case names and flavour rows.

**New**: B-34 Hammer Thrower, B-35 Protein Shake, B-36 Desk Flip, N-34 Final Notice, N-35 Pending Approval, N-36 Service Charge, N-37
Compliance Review, G-34 Amuse-Bouche, G-35 Pest Control, R-34 Curb Alert, R-35 Sewer Choir, R-36 Landfill Leviathan, C-35 Hand-Me-Down
Shield, NB-17 Iron Filing Clerk.

**Engine**: the `on_path(sel, X)` value, `pump(sel, a, d, next)` (a change that lingers until the controller's next turn, like Red Tape), and
`once` on triggered abilities (it was only enforced on activated ones). Tests `tests/core/game/test_cards_oct27.gd`.

**Placement**: each starter swaps one Colorless card for its Path's new Common (Protein Shake, Pending Approval, Amuse-Bouche, Curb Alert);
Sable sells two Commons of the player's own Path; the shelves, packs and reward tables pick the rest up by rarity and Path. The sim's expected
player (`ProgressionModel.UPGRADES`) buys them where a player would.

**Decisions** (inbox 1-3): Final Notice at **1(N)(N)** instead of the review's 2(N)(N), measured on the level-12 round robin; Cannon Fodder's
2/1 body pushed Beefcake and Refusemancer under 80% in the Forgotten Cave, so each cave deck carries one Fodder fewer and one basic more
(cleared runs B 90 / N 94 / G 90 / R 85, two-seed means); the round robin's 23% Necrocrat was the sim's deck cut order (it cut its own
bodies), fixed in `ProgressionModel.CUT_ORDER` - Necrocrat reads 20-33% now, Gourmand 73, no Path above 75.

## Part 2 - Card availability

Every card carries an availability (`CardData.availability`, from the `availability` and `source` columns of `data/source/card_overrides.csv`;
`CardAvailability`, `core/data/card_availability.gd`):

- **GENERAL** - packs, shops, picks, the Alchemist: the default.
- **REWARD-LOCKED** - never generated until earned once from its named source; afterwards it may show up anywhere at its rarity (this
  replaces `not_in_packs` for the prizes, which before Oct 27 never appeared in packs even when owned).
- **ENEMY-ONLY** - only the named encounter's deck runs it: Mortimer Grimsby (N-33), Betty Bones (N-30), Chancellor Clench (NB-16, his deck
  now carries his card), Mr. Tiggle (P4-03). `ZoneDecks.from_recipe` drops such a card from any other deck.

The check sits in every generator: `PackRoller`, `VendorStocks` (Sable and the four zone shelves), `RewardPicks` (elite / boss / gatekeeper
picks), `RewardGenerator` (dungeon picks and the tutorial's), `Alchemy`, and the Dev Menu's add-card (refused without "Ignore caps"; with it
the card is added and marked grandfathered). `Session.earned_cards` (saved) records what was earned once; a save that already owns a now
enemy-only card keeps it as **grandfathered** (`Session.grandfathered_cards`, set on load). The Collection Book shows enemy-only cards in a
**"Seen in battle"** section that never counts toward the Path bars or the 100%, and a locked card as "Locked" with its source.

**Signature cards**: the Hall of Final Approvals now pays Mass Layoffs (N-29) and the Waiting Room the Department of Final Approvals (N-31)
in place of their bosses; each main dungeon's boss forces a chase card into its pick until earned (`DungeonSignatures.BOSS_PICKS`: Iron
Filing Clerk, Resting In Peace Clause, Chef de Golem, Mount Trashmore, the Harmony Engine); the Paste Works pays the Infinite Pantry and the
Lab the Champion of the Four Paths (both paid no card before). Two consequences for the designer (inbox 5-6): the Buffet shelf's Epic tier
shows only what was earned, and the Necrocrat / Beefcake pair has no craftable Legendary at the Alchemist. Tests
`tests/core/data/test_card_availability.gd` (every generator, the owners, the archetypes hold no enemy-only card, grandfathering).

## Part 3 - Earned cards go to the collection, not the deck

Every card won, picked, found or bought joins the collection only (`Session.add_cards`); dungeon picks, elite / boss / gatekeeper picks,
quests, chests, packs, vendors, dungeon events (`EventResolver`) and challenges (`ChallengeResolver`) all route through `to_deck = false`.
The one exception is the Forgotten Cave's first run (`Session.rewards_go_to_deck()`): the tutorial's picks still build the starting deck, and
a replay leaves the deck as it is. The pick screens say "Added to your collection" (the tutorial's "joins your deck"); the first time it
happens after the cave a one-time tip points at the Deck Station (`Session.take_collection_tip`), which marks every card that joined since it
was last closed **NEW** (`Session.new_cards`, saved; cleared in `_exit_tree`). Existing saves: decks stay exactly as they were. Tests
`tests/core/dungeon/test_collection_routing.gd`.

## Checks

GUT per part: all four groups (root, core, ui, world) green after each part (the ui group flaked once on a non-card test and passed on
the rerun). Rerun on the final tree (after v0.4.6): root 276, core 1463 (+1 known pending), ui 234, world 418 - all passing. Data validators (`bash tools/import_cards.sh`) and the first-battles smoke after each part. Balance sims: the cave, the first
zone, the level-12 round robin (Part 1), then a post-change sweep of the town, D-HOG, D-HFA, D-TTK and the side dungeons
(`docs/design/sim/cards27*`); the two first-seed outliers (Betty Bones 31%, the Restless Dead 31%) read 47% and 69% on the 8-game reseed, so
no card or encounter was changed for them.

Bots (rerun on the final tree, after v0.4.6):

- Story playthrough bot (`bash tools/run_story_playthrough.sh`): **90 steps, 90 passed, 0 failed**, no script errors. It now answers the
  card-pick boxes itself (choose the first card, Keep) since a pick no longer closes on a click beside the cards.
- Tour bot (`bash tools/run_tour_bot.sh`, 8.2 minutes): every area, 281 spots, 9 menus, one battle per zone and the final -
  **0 errors, 0 warnings**, no script errors. Report `docs/overnight/bot_report.md`. Frames over 33 ms are the known ones (the town well
  484 ms, the Capital's seals and signs ~380 ms as their text loads; nothing new).

## Gotchas for the next pass

- A unit's `enter` ability is index 0, so its activated ability is index 1 in `_activate`.
- Typed-array `+` with `as Array[String]` is a parse error; use `append_array`.
- `_logs/print_deck.gd -- necrocrat 12` prints a Path's reference deck; re-run `node tools/sheet_changes_oct27.js` after CSV edits.
- Read `docs/design/card_availability.md` before adding a reward card: a new prize wants a REWARD-LOCKED row with its source.
