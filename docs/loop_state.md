# Loop state - Music Pass 2 (Oct 31 2026)

Brief: zone soundtracks from the approved demos + all stingers (pasted brief "MUSIC PASS 2"). Report `docs/audio/music_pass2_oct31.md`.
Questions go to `docs/overnight_inbox.md` ("Music Pass 2").
Rules: one Godot process at a time, GUT in groups, commit per part, dialogue freeze. Python: `$LOCALAPPDATA/Programs/Python/Python312/python.exe`.
Toolchain + commands: `docs/audio/music_toolchain.md`. Writing rules: `docs/audio/score_bible.md`.
Approved demos: `G:\My Drive\Card Game Art\Music_Source\zone_demos\` (ZONE-DNA / -BUFFET / -DUMP, musiclib.py, render2.py).
Previous run (Music Pass 1) finished; its report is `docs/audio/music_pass_oct31.md`.

| Part | What | State |
|---|---|---|
| 0 | Bible (zone directions, zone-theme rule, freed rule); demos ported as NECRO/GOUR/REF-EXP; inbox answers (music_list rows, TOWN v05, lullaby removals, DECK cello) | done (in game; GUT audio 89/89, music smoke OK) |
| 1 | 21 stingers (Batch 07) | done (in game as WAV; victory sting fired after a pilot-played battle; GUT audio 89/89, smoke OK) |
| 2 | D.N.A. Batch 03: NECRO-BATTLE, -DUN-EXP, -DUN-BATTLE, -BOSS, -FREED | done (in game; boss sting re-cut; GUT audio 89/89, smoke OK) |
| 3 | Buffet Batch 04: GOUR-BATTLE, -DUN-EXP, -DUN-BATTLE, -BOSS, -FREED | done (in game; boss sting re-cut; GUT audio 89/89, smoke OK) |
| 4 | Dump Batch 05: REF-BATTLE, -DUN-EXP, -DUN-BATTLE, -BOSS, -FREED | todo |
| 5 | Path extras Batch 08 (RELEASE, side dungeons with own BOSS, shops, minigames, Capital districts) | todo |

Delivery after each part: `build.py IDS` -> `deliver.py --review "Batch NN"` + `--approve` -> `bash tools/import_audio.sh` -> `node tools/cut_stings.js`
(boss changes) -> `node tools/audio_doc.js` -> GUT audio group + `bash tools/run_music_smoke.sh` -> commit.

Resume: `build.py --check-only <IDs>` shows which scores exist and pass; renders are in `C:\Dev\music_tools\renders\`.

Composition: all Part 2-5 scores were written by four parallel composer forks (Oct 31) and render + pass; markers `tools/music/reports/_batch0*_done.txt`, notes `tools/music/reports/_notes_{necro,gour,ref,beef}.md`. What is left per part is delivery (previews, approve, import, doc rows, GUT audio + smoke, commit).
