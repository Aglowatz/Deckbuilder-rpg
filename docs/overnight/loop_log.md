# Overnight Oct 28-29 - Phase 2 polish loop

Rules: polish on tonight's work only (new art placement, scale, contrast, walk timing, entrance framing, battle-feel timing); each cycle verified,
committed or reverted; STOP_OVERNIGHT checked between cycles. Parts 0-5 landed at afeb463e, a2d52559, 8a5972a8, 03021ca4.
Last night's log: `docs/overnight/oct27/loop_log_oct27.md`.

## Cycles

1. **Roamer placement (00:10)**: the Gainlands road guards and their training partners (now painted) turn to face a hero within 6 m of
   the challenge circle, and the guard strikes its threat pose while the "!" is up (a painted guard with its back to the hero read as asleep;
   the 3D models never turned either). Test `test_a_painted_road_guard_turns_to_the_hero...`; world GUT 418/418; Gainlands walk smoke OK.
   Shot `_screenshots/oct28/p2_guard_faces.png` (inconclusive by itself: the hero stood south, the default facing). Kept.
2. **Maren in the world (00:15)**: `--show=maren` at the forest cave mouth (`_screenshots/oct28/p2_maren_forest.png`): the tortoise set
   stands on the ground at 0.7 of the hero, shell, shawl and stick read from behind, rim light on. No change needed.
3. **Battle-feel timing (00:25)**: `tools/battle_sequence.tscn` got `--crop=x,y,w,h` to film part of the screen larger. The resource mote
   is visible mid-flight to its counter (`p2_feel_zoom.png`); the turn ribbon's "Turn N" line was too faint at 22 px: now 28 px in the
   ribbon colour lightened, the title nudged up (`p2_banner.png`). test_battle_feel_oct28 6/6. Kept.
