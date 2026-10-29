# Next up (ranked) - after the Oct 28-29 overnight run

0. **Play a battle with the new feel** (hold Space, 4x, a Legendary) and walk a zone with the painted roamers; then the inbox "Overnight Oct 28-29" (Spotless, threat pose, rim, the hub smoke).
   Art batches 5-9 (story stills, the 16 cards, gear/feat icons, Leaf Crown, farmhand + Primm postgame sprites, zone pieces) are next to import.

(The Oct 23-24 list follows.)

Last run's list: `docs/overnight/oct22/next_up_oct22.md`.

1. **Play a few scripted fights yourself** (Brick, Clench, the Doppelganger, Mortimer, Compostella): the triggers, the warnings, the
   entrances and the card picks - then say which mercy moments should be threats (inbox 2).
2. **A new build** with tonight's work (v0.4.6): free disk space first (inbox Oct 22 item 9), then `bash tools/export_windows.sh` and the
   exported suite (`tools/run_exported_suite.sh`).
3. **The Itamae's matchups** (inbox 3): Refusemancer / Necrocrat lose every seed-8100 game at L16 - a deck question, not a tuning knob.
4. **Freed-zone sparring** was built in Phase 2 cycle 13 (roamers only); a hand-made challenger per freed zone (named, with a line) would be the next step.
5. **Video memory per scene load - FIXED** (and the D.N.A. leak, overnight Oct 28-29: `DnaMaterials._fade_materials` held every visit's ~560 fade materials, +23 MB a visit; weak references now, flat over 10 round trips - `bash tools/run_memory_roundtrip_smoke.sh`, docs/perf/report.md "Memory leak") (Phase 2 cycle 17): `StyleToon._cache` (keyed by the source material's instance id) and
   `KitFoliage._materials` (every grass clump) held every visit's materials and their textures. Both now hold weak references and
   are pruned when a world scene installs its style rig: town reloads 887 -> 892 -> 893 -> 893 MB (was +12 MB a load), Crosspath <->
   Gainlands 887 -> 900 -> 901 (was 887 -> 946 -> 980), a full two-round tour plateaus at ~1007 MB. Worth re-checking on the laptop
   (integrated GPU) and with an exported build.
6. **Audio listen pass** (the lowest scorecard row, 7.5); the entrances reuse the zone/arena stings - a boss sting per Path would help.
7. Older items still open: the Oct 22 list's art batch (item 5) and the exported tour on a rebuilt pack (item 6).
