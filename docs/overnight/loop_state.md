# Overnight Oct 29-30 (Fable) - ECONOMY + EQUIPMENT BALANCE, HAT FIT - loop state (resume from here)

Start: Thu Oct 29 18:54 MDT 2026. Target 10 hours (stop by ~04:50). Tag `pre-overnight-oct29`. Last run's state:
`docs/overnight/oct29/loop_state_art_oct29.md`; last report `docs/overnight/oct29/overnight_report_art_oct29.md`.
Brief: "OVERNIGHT - Oct 29 (Fable): ECONOMY + EQUIPMENT BALANCE, HAT FIT" (Parts 1-4, Phase 2 loop, morning report).
Questions: `docs/overnight_inbox.md`, section "Overnight Oct 29-30". Loop log: `docs/overnight/loop_log.md`.

Rules: STOP_OVERNIGHT check per part/cycle (repo root or C:\Users\asche); one Godot at a time, foreground, closed between runs; max 12
screenshots per part; GUT in groups (`bash tools/gut_group.sh root|core|ui|world`); sims modest, one at a time; per part GUT + data
validators + first-battles smoke + walk smokes + `bash tools/perf_budget.sh` + commit + push; revert what can't pass. Old saves keep
loading (owned gold/items/equipment stay owned; changed stats apply to owned copies). No enemy intent; no new art; black market (Fig Sly,
the Secret Dealer) stock and prices untouched. **DIALOGUE FREEZE** (data/story/*, story_scenes.json, old_well_story.json, npcs.json,
boss_intros.json, encounter_scripts.json, dungeon_content.json, core/quests, story_beats.gd): no line or key changed; item / equipment
names, descriptions and shop UI text may change. No version bump, no export.

## Plan

| Part | What | Deliverables |
|---|---|---|
| 1 | Economy audit | `tools/economy_model.gd` (sources, sinks, three profiles over the story timeline), `docs/design/economy_audit_oct29.md` |
| 2 | Economy design + pricing | `docs/design/economy.md` (targets, curve), every price/payout set from it, before/after curves |
| 3 | Equipment + items balance | power budget in `docs/design/equipment.md`, outliers fixed (Wicked Dagger), caps/track checked, gear sims, `balance_log.md`, `docs/design/sheet_changes_oct29.csv` |
| 4 | Hats + cloaks fit | per-hat/direction fit, preview = world anchors, contact-sheet tool, sheets committed |
| Phase 2 | polish loop | shop/character readability of prices + rarity + upgrade hints, reward screens, loop_log.md |
| Report | `docs/overnight_report.md` | by part with commits, curves, price table, power budget, sim results, sheets, inbox |

## Progress

| Part | State | Commit | Notes |
|---|---|---|---|
| 1 | done | 6264456c | tools/economy_model.gd + economy_model_tool.gd, docs/design/economy_audit_oct29.md, sim/economy_model_before.md |
| 2 | done | (this commit) | core/data/economy.gd curve; cards 30/60/150/300, gear by rarity x tier, items 3 bands, cosmetics, packs II 200, essence x2, alchemy 150, roamers by tier, side clears 100/40, arena replay 25, level track front-loaded; GUT core/ui/root OK (release_readiness fixed: export_presets 0.4.7), first battles + hub walk OK |
| 3 | done | 45311175 | budget doc, 20 piece changes + Blade, Colorless matching fix, sims, log, csv, inbox 1-8; GUT core/ui OK, first battles OK, structure budget OK |
| 4 | done | (this commit) | tools/hat_contact_sheet.tscn + crop_png.gd, WorldSprite.forced_key + hat rot/pivot, fit.json sinks per hat x direction, DIR_SINK re-based; world GUT 422 OK, Crosspath walk OK; sheets docs/art/apparel/oct29 |
| Phase 2 | cycles 1-7 done | 74259648 5e2ee265 f65f7631 + cycles 5-7 | verdicts + rarity colours, purse line, hat tilt test, reward-pick reroll (late sink), side-dungeon sims + Quadzilla / Raccoon / Spotless rules, tailor check |
| Report | written | - | docs/overnight_report.md (update the stop time at the end) |
