# Loop state - Size + performance pass Nov 3 (Fable 5.1)

Brief: pasted "SIZE + PERFORMANCE PASS" (Parts 0-8). Questions: docs/overnight_inbox.md ("Size pass Nov 3").
Report: docs/perf/size_pass_nov3.md + summary in docs/overnight_report.md ("Size pass Nov 3"). Tag `pre-size-pass` at the start.
Stop when STOP_OVERNIGHT exists in the repo root.
Rules: one Godot at a time; <= 3 agents, never while Godot/tests run; GUT sharded (bash tools/run_tests.sh); verify + commit + push per part.
Never delete source art/audio masters; size changes live in tools/art_import_rules.json, the import scripts and the export filters.
Goals: zip 883 -> 350-450 MB; peak RAM down ~1/3; 30+ fps on old iGPUs in a Low-end preset. Quality gate: visual/listening check per change.
Previous state: docs/overnight/nov2/loop_state_overnight_nov2.md (Overnight Nov 2-3, Part 6 stopped for memory; v0.5.2 not exported).

| Part | What | State |
|---|---|---|
| 0 | Baseline: payload by category, RAM/VRAM/load per spot, frame times Medium + Low, min-spec note | done: 874 MB payload (music 219, VRAM textures ~340, keyart 64), floor 600 MB RAM, zones 1.2-1.6 GB RAM + 0.6-0.85 GB VRAM, loads 3-8 s; docs/perf/size_pass_nov3.md |
| 1 | Unused files: reference graph, exclude from export, exported-build smokes | done: tools/reference_graph.js; export already clean (0.8 MB unreferenced, 2 HUD files excluded via export_unused.json); exported-build check deferred to the Part 4 test pack + Part 8 |
| 2 | Music: re-render + Vorbis q2/q3/q4 A/B, pick, apply, audio GUT + music smoke | done: q3, 213 -> 175 MB, A/B folder + KEY on Drive, renders imported verbatim, audio GUT + music smoke OK; 762266e0 |
| 3 | Painted 2D art: size limits from on-screen sizes, WebP quality test, contact sheets | done: texfit sweep (26 screens, docs/art/size_pass/texfit.md) - paintings already drawn above native, limits kept (bestiary 512 -> 384); q 0.80 paintings/cards, 0.85 portraits/sprites; stills BC7 -> lossy; payload 838.5 -> 763 MB |
| 4 | World textures: BC1 for opaque, far textures 512, normal maps half, mipmaps | done: opaque surfaces BC1 + mipmaps, _n/_r/_nr 256, backdrops kept (drawn wide); 9-spot before/after shots, no visible change; payload 763 -> 669.7 MB |
| 5 | Memory: on-demand art with an LRU cache, streamed music, parked scene per preset | code written: core/data/art_cache.gd (LRU, budget per preset) behind UiArt/KeyArt/Portraits/CardArt/Battleboards/MapArt/Bestiary + warmup + AreaCaches; AudioRegistry stream cache bounded to 8; tests written, not yet run |
| 6 | Low-end preset + Compatibility renderer fallback + auto-pick | code written: GraphicsQuality.low_end (+knobs), Settings.low_end + first-launch rule + 30 fps cap, settings row, no parking, project fallback_to_* ; tests written, not yet run; shader check on opengl3 next |
| 7 | Slimmer engine (optional) | - |
| 8 | Export v0.5.2, smokes, compare, policy doc, GUT, delete v0.5.1 zip | - |
