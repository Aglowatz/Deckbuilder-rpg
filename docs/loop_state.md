# Loop state - Music Pass 1 (Oct 31 2026)

Brief: orchestral toolkit + Batches 1-2 (pasted brief "MUSIC PASS 1"). Report `docs/audio/music_pass_oct31.md`. Questions go to
`docs/overnight_inbox.md` ("Music Pass 1").
Rules: one Godot process at a time, GUT in groups, commit per part, dialogue freeze. Python: `$LOCALAPPDATA/Programs/Python/Python312/python.exe`.
Toolchain + commands: `docs/audio/music_toolchain.md`. Writing rules: `docs/audio/score_bible.md`.
Previous run (art import batch 10) finished; its log is `docs/art/import_oct31.md`.

| Part | What | State |
|---|---|---|
| 1 | Toolchain (FluidSynth, FluidR3_GM, tools/music/lib, build.py), MUS-TOWN v04 port | done (port identical to v04 MIDI; render matches the Drive file) |
| 2 | Score bible | done (`docs/audio/score_bible.md`) |
| 3 | Batch 1: TITLE, FOREST, TUT-EXP, TUT-BATTLE, TUT-BOSS, TOWN-BATTLE, DECK, MAREN, TOWN-FREED | done (all 9 rendered, checks pass; not yet in game) |
| 4 | Batch 2: BEEF-EXP, BEEF-BATTLE, BEEF-DUN-EXP, BEEF-DUN-BATTLE, BEEF-BOSS, BEEF-FREED | |
| 5 | Previews to Music Review, backups to Superseded/Music_v01, Approved_Audio + import audio, aliases, GUT audio, launch check, report | |

Resume: `build.py --check-only <IDs>` shows which scores exist and pass; renders are in `C:\Dev\music_tools\renders\`.
