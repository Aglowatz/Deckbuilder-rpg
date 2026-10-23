# Next up (ranked) - after the Oct 22-23 overnight run

Last run's list: `docs/overnight/oct19/next_up_oct19.md`.

1. **Test v0.4.5 yourself** (`builds/TheWaywardPath-v0.4.5-windows.zip`), then share it. How to test: `docs/overnight_report.md`.
2. **Video memory creep** (Performance): textures 437 -> 733 MB over a tour. Prove whether it is the bounded session caches (CardArt,
   IconArt, UiArt, Portraits, SpriteLibrary: they are not in `AreaCaches.release()` on purpose) by touring twice and checking for a
   plateau. Tonight's probe stalled on the first arrival because `SceneManager.busy` stays true while the arrival popups are queued -
   wait on `ZoneScene`/`TownScene` instead, as `tools/tour_bot.gd` does.
3. **Free disk space** (inbox item 9) before the next export or art batch.
4. **The rest of the balance list** (balance_log.md, end of "Overnight Oct 22 - Part 1"): Captain Spotless 50%, Colonel Casserole 79%,
   the Doppelganger 67%, Clipwell 83%, the Clocktower Sentinel 83%, the Ancient Spotter 67% (all 6-game numbers: confirm on two seeds
   first); Beefcake in the Rotheart waits for your call (inbox item 7).
5. **Art still to come**: the 26 images ChatGPT is making (Pending Review), the LEAFCROWN redo, 9 Dump kit pieces, 13 portrait fixes
   (`docs/art/import_oct22_partial.md`).
6. **The exported tour on the rebuilt pack** was not re-run after the model fix (the disk filled up); the v0.4.5 pack has the five models
   (checked by name in the pack) and the release smoke passed. Re-run `bash tools/run_exported_suite.sh <test pck> d3d12 1 tour` once
   there is room for a test pack (`tools/export_test_pack.sh`, ~760 MB).
7. **Audio listen pass** (the lowest scorecard row, 7.5).
