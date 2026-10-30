# XP Pass Oct 30 (Opus) - XP CURVE + RECHECK + v0.4.8 - loop state (resume from here)

Start: Fri Oct 30 ~07:30 MDT 2026. Tag `pre-xp-oct30`. Last run's state: `docs/overnight/oct29/loop_state_econ_oct29.md`; its report
`docs/overnight/oct29/overnight_report_econ_oct29.md`. Questions: `docs/overnight_inbox.md`, section "XP pass Oct 30".

Rules: one Godot process at a time, foreground; GUT in groups (`bash tools/gut_group.sh root|core|ui|world`); sims modest, one at a
time (7.4 GB RAM); per part GUT + data validators (`bash tools/import_cards.sh`) + first-battles smoke + walk smokes +
`bash tools/perf_budget.sh structure` + commit + push; revert what can't pass. Old saves keep loading and never lose levels. No enemy
intent; no new art; black market untouched. DIALOGUE FREEZE: no line or key changes; numbers only in dungeon_content.json / core/quests.

## Plan

| Part | What |
|---|---|
| 1 | XP curve re-based on the timeline's real XP; level timelines before/after; track, slots, caps, economy re-checked |
| 2 | Re-sim at the real levels + real gear: cave + first zone per Path, zone elites, main bosses, side dungeons, Vault, Primm's sequence (45-60 %) |
| 3 | Small calls: reroll kept, Belt/Barbell Beefcake-only kept, Binding Chains left; Captain Spotless on his SPOTLESS NPC sprite set |
| 4 | v0.4.8 candidate: tour bot, story playthrough bot, memory round-trip smoke, bump, guarded export, exported release smoke (d3d12 Medium + Low), zip, notes, tag |
| Report | docs/overnight_report.md |

## Progress

| Part | State | Commit | Notes |
|---|---|---|---|
| 1 | done | (this commit) | `ProgressionTable` step table (EARLY_STEPS, 325 + 10 L to 20, 500 + 35 (L - 20) after); `ProgressionModel.LEVELS` = real levels, ELITE/BOSS_STEP 0, PRIMM_STEP 1; economy model level timeline (old vs now); character screen XP bar clamps for old saves; tests; GUT core/root/ui OK, cards OK, first battles OK, hub + Crosspath walks OK, structure OK |
