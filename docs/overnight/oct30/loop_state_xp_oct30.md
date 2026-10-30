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
| 2 | done | (Parts 2-3 commit) | 15 encounter groups changed (balance_log.md "XP pass Oct 30, Part 2", sheet_changes_oct30.csv); reports docs/design/sim/oct30_*.md; Primm sequence 78 -> 68 % (Beefcake 32, inbox 4); Doppelganger ~35 % held by the frozen mask script (inbox 8); GUT core/root/ui/world OK, cards OK, first battles + Capital + Gainlands walks OK |
| 3 | done | (Parts 2-3 commit) | reroll + price kept; Belt / Barbell Beefcake-only kept; Binding Chains left; Captain Spotless's ZoneEnemyInfo draws the SPOTLESS NPC set (`sprite = "SPOTLESS"`; idle-only -> hop). The gate figure already wore it (shot `_screenshots/oct30/spotless_gate.png`); the 3D knights by the gate are the unnamed gate guards |
| 4 | done | (final commit, tag v0.4.8) | tour bot OK (281 spots, 0 errors), story 90/90, memory round trip OK; 0.4.8 bump; guarded export OK (zip 762 MB, pck 852 MB); exported release smoke D3D12 Medium + Low PASSED; docs/release/v0.4.8_notes.md |
| Report | done | final | docs/overnight_report.md |
