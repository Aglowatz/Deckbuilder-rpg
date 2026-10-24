# Next up (ranked) - after the Oct 22-23 overnight run

Last run's list: `docs/overnight/oct19/next_up_oct19.md`.

1. **Test v0.4.5 yourself** (`builds/TheWaywardPath-v0.4.5-windows.zip`), then share it. How to test: `docs/overnight_report.md`.
2. **Video memory grows ~33 MB per Crosspath visit** (Performance; Phase 2 cycle 3, `tools/memory_probe.gd`, logs in
   `_logs/memory_probe*.log`): textures plateau at ~600 MB on the second loop (the sprite / icon caches fill and stop - bounded) and
   buffers stay at 26-33 MB, but total video memory and the object count rise every Crosspath round trip (Crosspath <-> Gainlands x4:
   887 -> 1045 MB, 8.6k -> 11.0k objects; resources flat; only 5 stray TextureRect nodes; no script creates RenderingServer RIDs
   directly). So something per town build stays alive outside the node tree - next: bisect the town build (GroundLight map, haze cards,
   world sprites' normal maps, hub land, painted swaps) with the probe's --short route, checking 'video' after each step is skipped.
3. **Free disk space** (inbox item 9) before the next export or art batch.
4. **Three confirmed balance fixes to apply** (balance_log.md, "Phase 2 cycle 4", two seeds x 16 games): the Doppelganger 69/75%
   (boss, +1/+1 rule), Colonel Casserole 81/81% (elite, fewer basics), Captain Spotless 55/52% (elite, soften his rule). Not applied
   tonight so the v0.4.5 zip stays current. Beefcake in the Rotheart waits for your call (inbox item 7).
5. **Art still to come**: the 26 images ChatGPT is making (Pending Review), the LEAFCROWN redo, 9 Dump kit pieces, 13 portrait fixes
   (`docs/art/import_oct22_partial.md`).
6. **The exported tour on the rebuilt pack** was not re-run after the model fix (the disk filled up); the v0.4.5 pack has the five models
   (checked by name in the pack) and the release smoke passed. Re-run `bash tools/run_exported_suite.sh <test pck> d3d12 1 tour` once
   there is room for a test pack (`tools/export_test_pack.sh`, ~760 MB).
7. **Audio listen pass** (the lowest scorecard row, 7.5).
