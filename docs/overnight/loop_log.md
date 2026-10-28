# Overnight Oct 27-28 - Phase 2 polish loop

Rules: one cycle = one category of the scorecard (`docs/overnight/oct27/scorecard.md`), first-hour clarity and visual polish first, the
dialogue freeze respected (no existing line or key touched), GUT for what changed, commit per cycle, STOP_OVERNIGHT checked between cycles.
Parts 1-3 landed at a5c59207, d05586d9, 93ab2b47.

## Cycles

1. **Stability (blocked, then resumed)**: the Part 3 world GUT group was stopped by the tool harness for low system memory and left an
   orphaned Godot runner (pid 7932, ~480 MB) that the session is not allowed to kill; the machine had ~750 MB free. Doc-only cycles ran
   until it exited; the world group was then rerun in the foreground: **418 / 418 passing** (22:55).
2. **Combat feel / visual polish**: a soft dark radial halo behind the boss intro's cut-out, sliding in with it, so a pale figure (the
   Doppelganger's white coat, Spotless's armour) reads on a bright board (shot `docs/overnight/oct27/c2_intro_halo.png`; subtle on the
   cave's dark board by design).
3. **Onboarding / first hour**: the same shot caught two feat toasts drawn over the boss entrance (the shot tool's fast-forwarded game
   earned them as the battle opened). Feat toasts now queue while a battle is pending and flush when it ends (`Session.flush_feat_toasts`);
   the load-time summary toast is unaffected. Test added (feats 10/10).
4. **Stability**: with the feats hooked into the session, the first-battles smoke (0 failures, the Warden intro as a cut-out) and the
   opening-hour playtest smoke (OK, 163 s) both pass; cycles 2-3 committed as f2c0c34c.
5. **Stability**: story playthrough bot 90 / 90 steps on the Part 3 tree (23:04-23:11).
6. **Stability**: tour bot OK - 281 spots, 9 menus, 5 battles, 0 errors, 0 warnings (23:11-23:20).
7. **First-hour clarity**: the first feat toast of a session ends with "Menu > Feats" so a new player knows where the list lives; a UI
   test builds the Feats page (every group and feat, hidden ones as ???, "Earned here" marks) and opens it from the pause menu.
8. **UI consistency**: a dev scene for the Feats page (`scenes/dev/feats_gallery.tscn`, `bash tools/shot.sh res://scenes/dev/feats_gallery.tscn feats_page`;
   shot `docs/overnight/oct27/c8_feats_page.png`) and a `--open=feats` hook on the town for the in-menu version; the page reads like the
   Glossary (same plate, heading sizes, row layout), earned rows bright with "Earned here", locked ones dimmed, hidden ones "???".
9. **Balance (measured, no change)**: a third round-robin seed (9200): Necrocrat 47% (three-seed mean 46), vs Gourmand 20 and vs
   Refusemancer 60; Refusemancer 22 (mean 27). Both outliers are consistent across seeds, so they are real; logged for the designer
   (balance_log, inbox 1) rather than re-tuned at midnight.
10. **Stability / controller**: gamepad smoke OK (506 pad events, the pause menu included, 155 s) with the new Feats entry in the menu.
11. **Combat feel**: boss-rules smoke OK (the Before-the-fight brief and HUD rules with the cut-out entrance in front of them).

## Where it ended

Eleven cycles between 22:55 and 23:40: stability (world GUT 418, first-battles, playtest, story bot 90/90, tour bot 0 errors, gamepad,
boss-rules), two polish changes (the intro halo, feat toasts that wait for the battle to end and name Menu > Feats), the Feats page shots,
and a third balance seed. Not done: the Dump's two blue entrance flags (not found in the zone's code tonight; a catalogue row covers them)
and `perf_budget.sh frame` (skipped on a machine that had just reaped a Godot for memory). Scorecard: `docs/overnight/oct27/scorecard.md`.
12. **Balance (measured, reverted)**: the inbox's two cheap counter-moves on seed 8100: one Hazmat Intern in the sim package (Necrocrat
    47, Refusemancer 23, the Gourmand cell 15 - no help) and Pink Slip at "attack 4 or less" (Necrocrat 53, vs Beefcake 65, the Gourmand
    cell still 15). Neither kept; balance_log and inbox 1 updated with the finding.
