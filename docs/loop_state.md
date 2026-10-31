# Loop state - Music Pass 3 (Oct 31 2026)

Brief: finish the soundtrack, all 57 remaining cues (pasted brief "MUSIC PASS 3"). Report `docs/audio/music_pass3_oct31.md`.
Questions go to `docs/overnight_inbox.md` ("Music Pass 3").
Rules: one Godot process at a time, GUT in groups (audio group: `-gconfig= -gdir=res://tests/audio`), never the full suite while agents or Godot
run, commit + deliver + import per part, dialogue freeze. Python: `$LOCALAPPDATA/Programs/Python/Python312/python.exe`.
Toolchain + commands: `docs/audio/music_toolchain.md`. Writing rules + the Pass 3 key plan: `docs/audio/score_bible.md` section 9.
New lib: `tools/music/lib/capital.py` (CAPITAL_THEME, rudiment, stumble, QUANTISED); synth programs + GS kits in `lib/instruments.py`.
music_list rewrite: `tools/music/music_list_pass3.py` (run once; `--own MUS-SIPHON-BOSS` / `--own MUS-VAULT-BOSS` when their tracks are delivered).

Composition: three parallel composer forks (A: Part 1 then 5; B: Part 2 then 4; C: Part 3 then 6). Each writes
`tools/music/reports/_notes_pass3_partN.md` and the marker `_pass3_partN_done.txt` when all its IDs render and pass; the parent delivers.

| Part | What | Review folder | State |
|---|---|---|---|
| 0 | Bible section 9, capital.py, music_list palette/description/notes for the 57 + descriptions of passes 1-2 | | done (committed) |
| 1 | Capital world (13) | Batch 06 | done (in game; TUNNEL-BOSS own track; GUT audio 90/90, music smoke OK) |
| 2 | Primm + ending (12) | Batch 06b | done (in game; GUT audio 90/90) |
| 3 | Path-ology Lab (5), SIPHON-BOSS own track | Batch 09 | done (in game; SIPHON-BOSS own track; GUT audio 90/90) |
| 4 | Story (9) | Batch 08b | done (in game; hand-back test fixed; GUT audio 90/90) |
| 5 | Shops + quiz (10) | Batch 11 | done (in game; GUT audio 90/90) |
| 6 | Side areas (8), VAULT-BOSS own track | Batch 09b | done (in game; VAULT-BOSS own track, no aliases left; GUT audio 90/90) |
| 7 | Four broken districts at 15 cents (scores changed + rendered) + description rewrite (done in Part 0) | Batch 08 | done (in game; GUT audio 90/90, music smoke OK) |
| Final | full GUT run when nothing else runs | | running |

Delivery per part: `build.py IDS` (already done by the fork) -> `deliver.py --review "Batch NN"` + `--approve` (+ `--own` for a former alias) ->
`AUDIO_ONLY="ID.,ID." node tools/audio_analyze.js` -> `bash tools/import_audio.sh` -> `node tools/cut_stings.js` (boss changes) ->
`node tools/audio_doc.js` -> GUT audio group + `bash tools/run_music_smoke.sh` -> commit.

Resume: `build.py --check-only <IDs>` shows which scores exist and pass; renders are in `C:\Dev\music_tools\renders\`.
