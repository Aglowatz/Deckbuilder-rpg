# Major rebalance - running state

Resume file for the "MAJOR REBALANCE" brief (Oct 18 2026). Read this first after a context reset. Parts A-H; each part ends with GUT
passing, a commit and a push. Check for a `STOP_TASK` file in the repo root (or `C:\Users\asche`) before each part.

## Where things live

- Design rules: `data/source/design_guidance.csv` (the sheet snapshot; the brief's `docs/design/sheet_snapshot/` folder does not exist - the
  CSVs in `data/source/` are the snapshot). `docs/design/canon.md` does not exist either.
- Cards: `data/source/card_list.csv` -> `bash tools/import_cards.sh --write` -> `data/cards/*.tres`; rules scripts in `data/scripts/*.txt`.
  Changing a card = edit the CSV row (cost / stats / text), edit its script, then `--stamp` and `--write`.
- Enemy decks: `core/data/enemy_decks.gd` archetypes; dungeon foes `data/dungeons/dungeon_content.json`; zone roamers `core/zone/*_enemies.gd`;
  bosses `core/dungeon/{primm_boss,vault_guardian,ninja_boss,graveyard_boss}.gd`; dungeon rules `core/dungeon/dungeon_rules.gd`.
- Equipment: `core/data/expansion_gear.gd`, `core/data/progression_content.gd`; items `ProgressionContent.items`; prices in
  `ui/town/equipment_vendor_screen.gd`, `ui/town/item_vendor_screen.gd`, `ExpansionGear.zone_vendor_stock`.
- Sim: `core/sim/*` + `tools/run_*simulation*.gd` (old). New balance sim: `core/sim/balance_sim.gd` + `tools/run_balance_sim.gd` (Part B).
- Logs: `docs/design/balance_log.md` (every number change), `docs/overnight_inbox.md` (questions for the designer),
  `docs/design/sheet_changes.md` (Part H).

## Status

| Part | Status | Notes |
|---|---|---|
| A - rules changes | done (commit "Rebalance Part A") | Iron +1/+1 eot, Red Tape -2/-0 until controller's next turn, Eat Garbage no HP cost + `lose(N)` cost; arena Colossus retuned; GUT 1833/1834 (pre-existing test_world_look_rig) |
| B - simulator | done (commit "Rebalance Part B") | `core/sim/{player_spec,encounter_spec,encounter_catalog,progression_model,sim_item_policy,balance_sim}.gd`, CLI `tools/run_balance_sim.gd` (loads `tools/balance_sim_tool.gd` after the autoloads). Run: `Godot --headless --path . -s res://tools/run_balance_sim.gd -- --what=encounters --mode=quick --filter=zone:beefcake --out=res://docs/design/sim/x.md` (what: encounters, tutorial, sequence, decks, iron, one; mode quick=12 games/Path, full=100). ~0.09 s per game; whole catalog quick = ~9 min. Reports in `docs/design/sim/`. GUT 1840/1841 |
| C - card rebalance | first pass done (commit "Rebalance Parts C+D") | 5 batches in balance_log.md; Part G iterates. Tools: scratch `card_patch.js` (CSV + log), `--what=decks/matchup`. Round robin L1 after batch 5: see decks_l1_c5.md |
| D - starting decks | done (same commit) | `CampaignStart.STARTING_DECKS` (45 cards, 19 infra + 26), docs/design/starting_decks.md; tutorial clears (real run) B 86 / R 82 / N 80 / G 78 |
| E - encounters + modifiers | done for this run (commit "Rebalance Part E"); measured: tutorial, town, Gainlands, House of Gains, D.N.A. roamers, Waiting Room, Hall of Final Approvals, Buffet roamers and gate, Omakase, Test Kitchen; UNMEASURED after the batch-9 halving (re-measure first in Part G): Dump roamers, Rotheart, Trash Panda Throne, Capital roamers and gate, Old Service Tunnels, Primm's Castle and Primm, Mount Swolympus, the Lab, Iron Cave, Forgotten Vault, arena | Engine: `EncounterModifiers` (core/dungeon) + `data/encounters/modifiers.json` (one-sided rules: starting tokens/resources, timed summons (new `Modifier.Kind.TIMED_SUMMON`, `PlayerState.turns_taken`), stat buffs, boss abilities), applied in `MainDungeons.enemy_setup` / `ZoneEnemies.enemy_setup` / `TrialOfTheHollow.enemy_setup` (enemy side) and `Session.make_*_battle` (player side + `BattleContext.encounter_rules`); shown by `EncounterRulesPanel` in the battle HUD, in the dungeon node info and the zone toast; the sim catalog attaches the same rules. Tests: tests/core/dungeon/test_encounter_modifiers.gd. Next: tune numbers per group with `--what=encounters --filter=<group>` (dungeon_content.json hp/size/extra, *_enemies.gd, modifiers.json) |
| F - equipment + items | done (Overnight Oct 18, Part 1, commit dea1e329) | sim mode `--what=gear` (per-piece/item lift vs bare, f_gear_l5/l12.md), economy audit `tools/economy_audit.gd`; items once per battle; rarity/price/effect fixes in balance_log.md Part F |
| G - iterate | 5 iterations done (Overnight Oct 18, Part 2); targets NOT all met | full catalog g_iter1.md, then changed fights g_iter2..5_*.md; sim bug fixed (town NPC HP); levers that work: foe basics for early/mid fights, one-sided stat rules (modifiers.json) for late bosses; HP alone barely moves anything. Still out of band: most late elites/bosses too easy, Gainlands roamers / Casserole / Prudence / Rotheart normals / Iron Cave + Vault normals too hard (see balance_log.md Part G end table). Starting decks spread 24 -> 13. Next: Phase 2 Balance cycles, one group at a time with --games=6. |
| H - docs + sheet changes | partly done | `docs/design/sheet_changes.md` is generated by `node tools/sheet_changes.js` (run it again after Parts F/G); docs updated so far: combat_rules.md, starting_decks.md, starting_deck_and_affinity.md, progression_model.md, card_pipeline.md, inbox. Still to do with F/G: docs/progress.md section, backlog, CLAUDE.md pointer to the sim tools. |

## Part E progress (resume here)

- Tuned so far (see balance_log.md Part E batches 1-5): tutorial decks; Gainlands roamers (9 HP, 24 cards, 12 basics - still ~60% at L5, accepted as the first-zone gap, see inbox); D-HOG (82/61/72/95/47/54 at 100 games); town NPCs (Brick 60, Chef 70, Moss ~55-85, Prudence rebuilt on necro_zombies 22 HP); Graveyard 50; Vault 48; Shiro rebuilt (deck + 30 HP); late-game batch 5 applied blind (HP/size up everywhere from L11) - MEASURE NEXT: zone:necrocrat, S-NECRO, D-HFA, zone:gourmand, D-TTK, S-GOUR, zone:refusemancer, D-ROT, S-REF, zone:final, S-CAP, D-PC, S-BEEF, D-LAB, S-IRON, S-TOWN, arena.
- Run one group per foreground call (`--games=15`, out names without colons); a call over 10 min gets backgrounded and may be killed under memory pressure (the user runs the editor and the game on this PC).
- Tools: `tools/replay_encounter.gd --id=<spec id> --path=<path> --games=N --show=1 [--all]` prints action logs; scratch helpers `foe_patch.js` (dungeon_content.json + log) and `apply_edits.js`.

## Decisions so far

- Chancellor Clench (NB-16) doubles the new effects: Iron +2/+2, Red Tape -4/-0 (flags `iron_plus_2` / `red_tape_minus_2` keep their names).
- Red Tape lasts "until the start of its controller's next turn": a lingering stat change on the unit, expired in `_begin_turn` of the
  unit's controller. The AI's threat estimate ignores lingering changes that expire before the opponent attacks.
- Eat Garbage HP cost moved onto specific strong cards as a written `lose(N)` cost (script cost `lose(1)` / `lose(2)`).


## Playtest v0.4.0 (Oct 18)

- Part D roamers: three Crosspath outskirts enemies tuned at level 1 (hound 84%, clerk 90%, raccoon 85% overall; report docs/design/sim/s2_town_roamers.md; the per-Path floor is 80%).
- Part E cards: Yeet (B-25) now destroys the thrown unit; the Raccoon (R-27) text reworded (same free_eat mechanic).
- Part E (4): the battle board boxes are the trap slots and the token tray; both labelled now (see balance_log.md).
- Part F: rule badges + icon rows (map, briefs, zone HUD, battle HUD); chest sparkle bigger/brighter with a light pulse; Deck Station slots are the painted racks (DeckRack).
- Part G: `bash tools/run_playtest_smoke.sh` (new opening hour end to end) passes; prologue smoke updated for the arrival beside Maren.
