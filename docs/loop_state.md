# Loop state - Gainlands rock set + music quality rollback Nov 3 (Fable 5.1)

Brief: pasted "GAINLANDS ROCK SET + MUSIC QUALITY ROLLBACK" (Parts 1-4). Questions: docs/overnight_inbox.md ("Gainlands rock Nov 3").
Report: docs/audio/music_gainlands_rock_nov3.md + summary in docs/overnight_report.md. Tag `pre-gainlands-rock` at the start.
Stop when STOP_OVERNIGHT exists in the repo root.
Rules: one Godot at a time; <= 3 agents, never while Godot/tests run; GUT sharded; verify + commit + push per part. Music toolkit: tools/music/,
score_bible.md (section 10 = the rock palette), FluidR3. No further size work (designer, Nov 3).
Previous state: docs/overnight/nov3/loop_state_size_pass_nov3.md.
Disk: C: had 1.2 GB free at the start; deleted builds/_testpack (stale, rebuilt by export_test_pack.sh) and builds/TheWaywardPath-v0.5.2-windows
(byte-identical to builds/_export, used by no tool) -> 2.7 GB.

| Part | What | State |
|---|---|---|
| 1 | Rock render profile + unit test; bible section 10; music_list rows | done: render.rock_chain (amp_sim, add_risers, glue), Score.profile/stem/risers/stack_drums, to_midi only/skip, lib/rock.py, tests/test_rock_render.py (16 OK); MUS-BEEF-BATTLE ported (guitar stem note-identical to the demo MIDI; rest identical note-ons) + intro/outro loudness fix; 15 music_list rows |
| 2 | Compose the Gainlands set (15 more cues) + Drive previews | |
| 3 | Re-render everything at q6, deliver, import, stings, routing, audio GUT + music smoke, policy doc | |
| 4 | Full sharded GUT, play-script run with MUSIC_LOG, export v0.5.3 + release smoke, cleanup, report | |
