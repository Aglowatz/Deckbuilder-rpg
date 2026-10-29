# Brief - OVERNIGHT Oct 28 (Opus): art batches 1-4 + battle feel + memory leak

(Copy of the prompt, for the record.)

Target 9 hours, autonomous, safest choice, questions in docs/overnight_inbox.md ("Overnight Oct 28-29"), never block. `date` at start and per
part; stop by 9 hours. Tag pre-overnight-oct28. Keep docs/overnight/loop_state.md current. Read CLAUDE.md, docs/art/art_batch_oct28.md + .csv,
art_direction_oct28.md, enemy_roster_oct28.md, art_pipeline.md, docs/perf/budgets.md, docs/perf/report.md, docs/overnight/next_up.md first.
Order matters: if time runs short, cut from the end (Part 5, then Part 4), never the art.

What arrived: rows #1-74 of art_batch_oct28.csv - Maren's tortoise portraits (NPC-ELDER, _HAPPY, _WORRIED) and sprites (SPR-ELDER-*); 21
roaming-enemy sprite sets (14 walk sets of 11 files, 7 idle sets of 4); 26 entrance cut-outs (incl. CUT-PRIMM_CRACKED / _UNRAVELLED); 23
Bestiary squares (incl. BST-ENFORCER-CAPTAIN-SPOTLESS). Batches 5-9 are not made: no hooks for them.

Rules: STOP_OVERNIGHT per part; one Godot at a time, foreground, max 12 screenshots per part, GUT in groups; per part GUT + walkability +
walk smoke + performance budgets + commit + push; revert what can't pass. Old saves keep loading; no enemy intent; no image generation;
never read Pending Review or the "Replaced Artwork" folder; Drive copy-only. Black market vendors untouched. Dialogue freeze: no existing
line or key changed; new text only in new keys.

- Part 0 - Inventory: every file present and sound; notes in docs/art/import_oct28.md; assets/art size.
- Part 1 - Maren and the roaming enemies: npc_sprite_batch rows (NPC-FOE-<KEY>, relative heights); import portraits / npc sprites /
  bestiary; check Maren (Crosspath, forest epilogue spot, dialogue x3) and every roamer in its zone next to the hero (idle each direction,
  walking each way, mirrored right, threat pose); fix scale, baseline, facing, walk-strip slicing, frame timing, contrast.
- Part 2 - Boss entrances and the Bestiary: every entrance shows its CUT-*; Primm's phase 2/3 hook; Collection Book + plates show the 23
  squares; Spotless's two ids share the picture; renamed enemies' old saves still count.
- Part 3 - Verify the art: tour bot, story bot, all walk smokes, first-battles, gamepad; budgets (Medium 60+); size before/after and an
  export estimate (flag over 850 MB); docs/art/art_status_oct28.csv for rows #1-74.
- Part 4 - Battle feel (existing art and sounds; no enemy intent): cards arc and land with a thump and dust; lunge / recoil; 40-80 ms
  hit-stop and light shake on big hits (reduced-shake respected); popping, floating numbers in Path colours; deaths dissolve or crumble;
  resources fly to their counters; a clear turn banner; Legendary entrance flourish; nothing slows a turn by more than ~0.3 s; every effect
  follows battle speed (1x/2x/4x) and can be skipped. Before/after sequence of one turn per Path; first-battles smoke, battle AI tests,
  boss-rules smoke; battle frame budget; docs/design/battle_feel.md.
- Part 5 - Memory leak (~33 MB per Crosspath visit): reproduce with round trips (and dungeon in/out), find what isn't freed, fix it; flat
  within ~5 MB after 10 round trips; a smoke that fails if memory grows; cause and fix in docs/perf/report.md.
- Phase 2: polish loop on tonight's work only; log in docs/overnight/loop_log.md.
- Morning report: docs/overnight_report.md. No version bump, no export.
