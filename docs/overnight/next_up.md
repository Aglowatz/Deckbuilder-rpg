# Next up (ranked) - after the Oct 23-24 overnight run

Last run's list: `docs/overnight/oct22/next_up_oct22.md`.

1. **Play a few scripted fights yourself** (Brick, Clench, the Doppelganger, Mortimer, Compostella): the triggers, the warnings, the
   entrances and the card picks - then say which mercy moments should be threats (inbox 2).
2. **A new build** with tonight's work (v0.4.6): free disk space first (inbox Oct 22 item 9), then `bash tools/export_windows.sh` and the
   exported suite (`tools/run_exported_suite.sh`).
3. **The Itamae's matchups** (inbox 3): Refusemancer / Necrocrat lose every seed-8100 game at L16 - a deck question, not a tuning knob.
4. **Freed-zone sparring** was built in Phase 2 cycle 13 (roamers only); a hand-made challenger per freed zone (named, with a line) would be the next step.
5. **Video memory grows per scene load** (bisected further on Oct 23, Phase 2 cycle 16; `_logs/probe_bisect.log`): it is NOT one of the
   town's optional pieces - with birds, outskirts, clouds, the look rig, dressing and the painted pass all switched off
   (`WAYWARD_PROBE_SKIP=...`) the growth is the same (+92 vs +95 MB over two Crosspath<->Gainlands loops). A plain town->town reload
   (`memory_probe.tscn -- --townloop`) grows ~12 MB and ~160 objects per load, a Gainlands->Gainlands reload (`--zoneloop`) ~13 MB and
   ~190 objects; no orphan nodes accumulate and only 33 objects leak at exit, so something long-lived (a static cache or an autoload)
   holds per-load objects. Next: dump object counts by class per load (a small tool walking the autoloads' and static caches' sizes:
   SpriteLibrary grows 74 -> 116 over a tour, GameLog/LoadTiming records, Audio players, EventBus connections).
6. **Audio listen pass** (the lowest scorecard row, 7.5); the entrances reuse the zone/arena stings - a boss sting per Path would help.
7. Older items still open: the Oct 22 list's art batch (item 5) and the exported tour on a rebuilt pack (item 6).
