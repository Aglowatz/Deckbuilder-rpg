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
| B - simulator | todo | |
| C - card rebalance | todo | |
| D - starting decks | todo | |
| E - encounters + modifiers | todo | |
| F - equipment + items | todo | |
| G - iterate | todo | |
| H - docs + sheet changes | todo | |

## Decisions so far

- Chancellor Clench (NB-16) doubles the new effects: Iron +2/+2, Red Tape -4/-0 (flags `iron_plus_2` / `red_tape_minus_2` keep their names).
- Red Tape lasts "until the start of its controller's next turn": a lingering stat change on the unit, expired in `_begin_turn` of the
  unit's controller. The AI's threat estimate ignores lingering changes that expire before the opponent attacks.
- Eat Garbage HP cost moved onto specific strong cards as a written `lose(N)` cost (script cost `lose(1)` / `lose(2)`).
