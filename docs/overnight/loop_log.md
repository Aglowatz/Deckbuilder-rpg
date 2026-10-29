# Overnight Oct 28-29 - Phase 2 polish loop

Rules: polish on tonight's work only (new art placement, scale, contrast, walk timing, entrance framing, battle-feel timing); each cycle verified,
committed or reverted; STOP_OVERNIGHT checked between cycles. Parts 0-5 landed at afeb463e, a2d52559, 8a5972a8, 03021ca4.
Last night's log: `docs/overnight/oct27/loop_log_oct27.md`.

## Cycles

1. **Roamer placement (23:55)**: the Gainlands road guards and their training partners (now painted) turn to face a hero within 6 m of
   the challenge circle, and the guard strikes its threat pose while the "!" is up (a painted guard with its back to the hero read as asleep;
   the 3D models never turned either). Test `test_a_painted_road_guard_turns_to_the_hero...`; world GUT 418/418; Gainlands walk smoke OK.
   Shot `_screenshots/oct28/p2_guard_faces.png` (inconclusive by itself: the hero stood south, the default facing). Kept.
2. **Maren in the world (00:02)**: `--show=maren` at the forest cave mouth (`_screenshots/oct28/p2_maren_forest.png`): the tortoise set
   stands on the ground at 0.7 of the hero, shell, shawl and stick read from behind, rim light on. No change needed.
3. **Battle-feel timing (00:06)**: `tools/battle_sequence.tscn` got `--crop=x,y,w,h` to film part of the screen larger. The resource mote
   is visible mid-flight to its counter (`p2_feel_zoom.png`); the turn ribbon's "Turn N" line was too faint at 22 px: now 28 px in the
   ribbon colour lightened, the title nudged up (`p2_banner.png`). test_battle_feel_oct28 6/6. Kept.
4. **Threat pose (00:09)**: `--lineup=threat` in the D.N.A. (`p2_lineup_dna_threat.png`): the managers lunge reaching, the interns and
   couriers rear up - the FRONT_TALK frames read as a threat, in colour against the near-monochrome office. No change.
5. **Colonel Casserole in the world (00:15)**: he is not a roamer but the Buffet's battle-gate guardian, still the 3D gate golem, so his new
   painted set was unused. `BuffetBuilder._gate_figure` now uses `FOE_COLONEL_CASSEROLE` for the battle gate (the scene only moves and turns
   it; the other two gate golems and the fallback stay 3D). `p2_casserole_gate.png`; Buffet walk smoke OK (the gates open); world 418/418. Kept.
6. **Entrance framing (00:25)**: the Hollow Warden's entrance on the real board (`p2_intro_warden.png`): the hips-up cut-out ended in a hard
   straight crop drawn over the lower letterbox bar. The lower bar is now drawn above the figure (cut-out mode only), so the crop line sits
   behind it and the boss stands behind the bar. ui GUT 236/236, boss-rules smoke OK. Kept.
