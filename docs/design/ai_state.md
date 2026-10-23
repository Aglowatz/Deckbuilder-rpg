# Battle AI upgrade - running state

Resume file for the "BATTLE AI UPGRADE" brief (Oct 23 2026). Read this first after a context reset. Parts 1-6; each part ends with
GUT passing, the first-battles smoke, a commit and a push. Check for a `STOP_TASK` file in the repo root (or `C:\Users\asche`) before
each part. Rules: one Godot process at a time (foreground), sims headless in modest batches (7.4 GB RAM), old saves keep loading,
enemy intent stays hidden, no new art.

## Where things live

- AI: `core/ai/ai_player.gd` (the heuristic one-step AI, Oct 23 state), `core/ai/ai_personality.gd` (+ `data/ai/*.tres`).
- Engine: `core/game/game_state.gd` (`legal_actions`, `clone(deep, hide_traps_of)`, `apply_action`), `combat_resolver.gd`.
- Sim: `core/sim/balance_sim.gd` (`play_game` builds both AIs by name), `encounter_catalog.gd`, `tools/replay_encounter.gd`
  (`--id --path --games --show --all --level`), `tools/run_balance_sim.gd`, `node tools/sim_summary.js <reports>`.
- UI driver: `ui/battle/battle_screen.gd` `_ai_step` (0.35 s think pause + 0.5 s announce, scaled by `board.speed`).
- Docs: `docs/design/ai_audit.md` (Part 1), this file, `balance_log.md`, `sheet_changes.md`.

## Status

| Part | Status | Notes |
|---|---|---|
| 1 - audit | in progress | replays across the four Paths; findings in `docs/design/ai_audit.md` |
| 2 - core | not started | |
| 3 - personalities | not started | |
| 4 - skill levels + pacing | not started | |
| 5 - sim + rebalance | not started | |
| 6 - verify | not started | |

## Decisions

(none yet)
