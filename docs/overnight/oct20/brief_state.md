# Overnight Oct 20-21: playtest stability (resume file)

Brief saved verbatim-in-spirit: make the game reliable on testers' Intel iGPU PCs, hotfix build. Started 2026-10-20 22:16 MDT, stop by 08:16.
Tag pre-overnight-oct20. v0.4.2 already exists (earlier today) -> this hotfix is v0.4.3.
Parts: 1 reproduce (drivers, cold cache, presets, 4 Paths, Continue; static analysis) / 2 logging (file log flush, startup GPU info,
scene steps, loads, modals, lock, 5 s heartbeat, rotate, F8 includes log) / 3 fixes (no main-thread waits on threads, transition watchdog,
arrival queue + lock release, Esc/F8 always, renderer default, iGPU -> Medium/Low, crash-safe Safe Mode start, tests) / 4 launchers +
README_PLAYTEST.txt / 5 verify on export both drivers + soak / 6 v0.4.3 zip + notes + tag / Phase 2 loop (docs/overnight/loop_log.md) /
morning report docs/overnight_report.md. Rules: one Godot at a time, <=12 shots per part, STOP_OVERNIGHT, GUT+smoke+commit+push per part,
old saves (incl. stuck at Crosspath) must Continue.

## Progress
- 22:16 start, tag pushed. Part 1 matrix done (_screenshots/p1/matrix.txt): no hang on AMD; D3D12 first launch = High on iGPU (root cause of
  the default-settings crash). Findings in docs/playtest/stability_oct20.md.
- Part 2/3 code written: app/game_log.gd (autoload, first), app/boot_guard.gd, app/gpu_info.gd, SceneManager watchdog/_input F8/Esc
  queue, LoadTiming -> GameLog, warmup timeouts + no-thread Safe Mode, modal/lock logging, thumbnail guard, Continue replays the welcome,
  arrival order level_ups first, TownScene.recover_after_timeout, tests/test_playtest_stability.gd (18 pass). Pending: p21.js (settle
  up to 30 s while spiking, watchdog ignores pause) - apply after GUT. Tester kit in tools/playtest_kit; export_windows.sh copies it.
- Next: try shader_baker/enabled=true at export (needs non-headless export), version 0.4.3.
