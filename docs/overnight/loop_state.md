# Cards Oct 27 (Fable) - loop state (resume from here)

Start: Tue Oct 27 2026. Brief: the "CARDS - Oct 27 (Fable)" prompt (three parts + tests + finish). Base commit 64e9cf3b (Fixes Oct 27).
Session model: Fable 5.1; if the allowance runs out, continue on Opus from this file. Questions for the designer go in
`docs/overnight_inbox.md` under "Cards Oct 27".

Rules in force: one Godot process at a time, foreground; GUT in groups (`bash tools/gut_group.sh root|core|ui|world`); sims modest and one at
a time (7.4 GB RAM); per part: GUT + data validators (`bash tools/import_cards.sh`) + first-battles smoke + the named balance sims, commit + push;
revert what can't pass. Old saves keep loading. No new art. No enemy intent. Black market vendors (Fig Sly, the Secret Dealer) and their
cards untouched.

Decisions so far:
- No "Card Review Oct 25" sheet export exists in `data/source/`, so every row of `docs/design/card_review_oct25.csv` is APPROVED
  (29 changes + 14 new cards incl. Desk Flip, Pest Control, Compliance Review).
- Final Notice kept at 1(N)(N) (measured vs the review's 2(N)(N); balance_log.md "Cards Oct 27, Part 1").
- The cave foes carry one Cannon Fodder fewer each (its new 2/1 body had pushed B/R under 80%).
- The sim's Necrocrat reference deck cut order was fixed (it cut the bodies): the 23% round-robin number was the model, not the cards.

## Parts
| Part | Status | Notes |
|---|---|---|
| 1 - apply the card review | done: CSV + scripts + engine (`on_path`, `pump(...,next)`, `once` on triggers), 14 new cards, starters/Sable/UPGRADES, sims, balance_log, sheet_changes_oct27.csv; GUT all 4 groups green; first-battles smoke (see commit) | new tests `tests/core/game/test_cards_oct27.gd`; tools `_logs/cards_oct27_apply.js`, `_logs/cards_oct27_scripts.js`, `tools/sheet_changes_oct27.js` |
| 2 - availability | done (code + data + tests + doc); GUT core/root/ui green (ui flaked once on a non-card test, green on rerun), world + smoke: see commit | `core/data/card_availability.gd`, `core/dungeon/dungeon_signatures.gd`, `data/source/card_overrides.csv` (4 cols), filters in PackRoller / VendorStocks / RewardPicks / RewardGenerator / Alchemy / ZoneDecks.from_recipe, Session earned_cards + grandfathered_cards (saved), Codex "Seen in battle", Dev Menu override; Mortimer + Betty + Clench + Tiggle ENEMY-ONLY, Hall -> N-29, Waiting Room -> N-31; `docs/design/card_availability.md`; tests `tests/core/data/test_card_availability.gd` |
| 3 - collection not deck | not started | reward routing (dungeon picks, treasure, events, challenges: `run.gain_card` sites), tutorial exception (`TrialOfTheHollow`), "Added to your collection", one-time tip, Deck Station "New" badge, text updates |
| tests + bots | not started | GUT for filters/unlock/routing/migration; tour bot + story playthrough bot at the end |
| finish | not started | `docs/cards_oct27.md`, final commit + push |

## Where things live
- Cards: `data/source/card_list.csv` (cols: Path, Rarity, Name, Cost, Type, Text, P/T, Flavor, Image, Notes, ..., Source, Card ID at col 14),
  `token_list.csv`, `card_overrides.csv` (Card ID,not_in_packs), scripts `data/scripts/cards_*.txt`, importer `core/data/card_importer.gd` +
  `tools/import_cards.gd` (`bash tools/import_cards.sh --stamp` / `--write`).
- Generators: `core/data/pack_roller.gd`, `core/data/vendor_stocks.gd` (`sellable`), `core/dungeon/reward_picks.gd` (world picks),
  `core/dungeon/reward_generator.gd` (dungeon picks + the tutorial's), `core/data/chest_loot.gd`, `core/data/enemy_decks.gd`, `core/zone/zone_decks.gd`,
  `app/dev_actions.gd` (`add_card`), `core/zone/zone_cards.gd` (vendor ids, mini/main dungeon reward ids), `core/data/alchemy.gd` (dual cards),
  `core/zone/zone_shrine.gd` (a chest-table card), `core/data/content_definitions.gd` (challenge reward pool), the D.N.A. printer (`dna_interactables.gd`).
- Session: `app/game_session.gd` (`add_cards` 432, `open_pack` 486, `reward_pick` 3429, `take_reward_pick`, `apply_rewards` ~3530 (dungeon pick ->
  collection + `run.gain_card`), treasure ~3160, `resolve_dungeon_event` ~3215, `grant_chest_reward` 3659, `collection_percent` 723, `seen_cards`,
  save `to_dict` ~900 / `from_dict` ~1000).
- Collection Book: `ui/town/codex_screen.gd` (`card_progress`, `_refresh_grid`, `inspect`). Deck Station: `ui/town/deckbuilder_screen.gd`
  (`_collection`, `_make_tile`, `_badges`). Dungeon rewards screen `ui/dungeon/rewards_screen.gd`; world pick popup `ui/screens/reward_popup.gd`.
- Starters: `core/dungeon/campaign_start.gd`. Reference decks: `core/sim/progression_model.gd`.
- Sim: `Godot_console --headless --path . -s res://tools/run_balance_sim.gd -- --what=tutorial|decks|encounters --games=N --seed=7000 --level=12
  --filter=zone:beefcake --out=res://docs/design/sim/<name>.md`; a Path's reference deck: `-s res://_logs/print_deck.gd -- necrocrat 12`.

## Part 2 notes (from the enemy-deck survey, Oct 27)
- Boss nodes use only the dungeon's `boss` block (foe-level `extra` is dropped: S-CAP Spotless, S-TOWN Automaton). Archetypes already
  contain unique-reward cards (bruisers B-30/31/32/33, golems G-27, garbage R-27, rats R-30, zombies N-30/N-33, regime C-21/C-30, militia C-22,
  four_paths P4-01). N-29 and R-29 are in `card_overrides.csv` as not_in_packs but granted nowhere (enemy decks only).
- Signature cards per boss (candidates for ENEMY-ONLY): Mortimer N-33/N-32/N-28/N-29; Doppelganger G-33; Compostella R-33; Clench (none explicit,
  bruisers has B-32); Primm C-30/C-32 (phase 1), P4-03/P4-01/C-30 (phase 3); Quadzilla B-12; Ancient Spotter B-30/B-28/B-29/B-32; Itamae G-27;
  Betty Bones N-30; His Majesty the Raccoon R-27; Crumb C-30/G-29; Failed Experiment B-28; Drain Warden N-29/C-30; Siphon N-33/B-32/G-33/R-33;
  Automaton (vault) C-21; Royal Staircase Guard / Clocktower Sentinel C-30/C-32; Quota rematch B-12/B-28/C-30; Captain Spotless C-30/C-34/C-29/C-32/C-33;
  Bellows B-13/B-28/B-11/B-29/B-30; Shiro, the Echo, the Vault Warden: hand-written lists (see the survey in `docs/design/card_availability.md`).
