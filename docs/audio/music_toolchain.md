# Orchestral music toolchain

Music Pass 1 (Oct 31 2026). The game's music is written as Python scores that produce multi-track MIDI, rendered with FluidSynth and the
FluidR3_GM soundfont, then given the hall reverb, loop fold and loudness of the MUS-TOWN v04 reference. The writing rules are in
`docs/audio/score_bible.md`; the per-track results are in `docs/audio/music_pass_oct31.md`.

## Install (outside the repo)

Everything lives in `C:\Dev\music_tools\` (override with the `WP_MUSIC_TOOLS` environment variable). Never commit the soundfont.

| What | Where | Source | Licence |
|---|---|---|---|
| Python 3.12.10 | `%LOCALAPPDATA%\Programs\Python\Python312\python.exe` | `winget install Python.Python.3.12 --scope user` | PSF |
| mido, numpy, scipy | that Python's site-packages | `python -m pip install mido numpy scipy` | MIT / BSD |
| FluidSynth 2.6.1 | `C:\Dev\music_tools\fluidsynth\fluidsynth-v2.6.1-win10-x64-cpp11\bin\fluidsynth.exe` | official GitHub release `fluidsynth-v2.6.1-win10-x64-cpp11.zip` | LGPL-2.1 |
| FluidR3_GM.sf2 (148 MB) | `C:\Dev\music_tools\soundfonts\FluidR3_GM.sf2` | Debian package `fluid-soundfont-gm_3.1-6_all.deb` (deb.debian.org) | **MIT** (Frank Wen); copy of the licence beside it: `FluidR3_GM.copyright.txt` |
| ffmpeg | already installed (winget Gyan.FFmpeg) | | |

SHA-256 of the soundfont: `74594e8f4250680adf590507a306655a299935343583256f3b722c48a1bc1cb0`. Overrides: `WP_SOUNDFONT`, `WP_FLUIDSYNTH`, `FFMPEG`,
`WP_DRIVE` (default `G:\My Drive\Card Game Art`).

## Commands

```
PY=$LOCALAPPDATA/Programs/Python/Python312/python.exe
$PY tools/music/build.py MUS-TITLE MUS-FOREST            # render + check; .mid -> tools/music/midi/, report -> tools/music/reports/
$PY tools/music/build.py --check-only MUS-TITLE          # score checks only, no audio (fast)
$PY tools/music/deliver.py --review "Batch 01" IDS...    # MP3 previews -> <Drive>/Music Review/Batch 01/<ID>.mp3
$PY tools/music/deliver.py --approve IDS...              # back up Approved_Audio/<ID>.* to Superseded/Music_v01, copy the new OGG in,
                                                         #   and set the Drive registry.json loop record to the new length
$PY tools/music/deliver.py --own MUS-TUT-BOSS            # an ID that was a compatibility alias gets its own file (Drive metadata)
$PY tools/music/deliver.py --record-only --revision v04 MUS-TOWN   # refresh one registry.json record from the Drive file as it is
bash tools/import_audio.sh                               # then "import audio" as always
node tools/cut_stings.js && node tools/audio_doc.js      # after a new *-BOSS track: re-cut its victory sting; refresh the doc
$PY tools/music/compare_midi.py a.mid b.mid              # prove two .mid files carry the same notes
$PY tools/music/compare_audio.py a.ogg b.ogg             # length, loudness, seam and band-envelope likeness of two renders
```

Audio lands in `C:\Dev\music_tools\renders\<ID>\` (`<ID>.ogg` for the game, `<ID>.mp3` preview = one pass plus 15 s past the loop point
so the seam can be heard). A render takes about 20 s.

## Layout

| File | What |
|---|---|
| `tools/music/lib/theory.py` | pitch names, scales/modes, chord parsing and voicing, the Crossroads motif (transpose by degree, invert, head/tail, resolved form), the Lullaby/Primm themes, the orchestra-kit key map |
| `tools/music/lib/instruments.py` | instrument name -> (bank, program) in FluidR3_GM, including its GS extras (mandolin 16/25, Italian accordion 8/21, orchestral pad 8/48) |
| `tools/music/lib/score.py` | `Score`: channels (pan/reverb/volume), humanised notes, phrase-arc lines, CC11 swells, sections, motif log; helpers for pads, bass patterns, harp arpeggios, pizzicato, figures, ostinatos, brass chords, scale runs, timpani hits/rolls, kit hits, snare rolls; the MIDI writer |
| `tools/music/lib/render.py` | FluidSynth (48 kHz, float) -> hall reverb -> loop fold / ring-out -> BS.1770 loudness -> true-peak limiter -> OGG q6 + MP3 192k; measured checks (LUFS, true peak, seam, loudness per section) |
| `tools/music/lib/checks.py` | score checks: nothing below E1, at most 2 bass pitches under C3 together, melody coverage and audibility |
| `tools/music/scores/<ID>.py` | one score per ID, `build() -> Score` |
| `tools/music/midi/<ID>.mid` | the written MIDI (source of truth for a later re-render with better instrument libraries) |
| `tools/music/reports/<ID>.json` | the measured report of the last render |

## The render chain (from render_loop.py, Oct 31)

1. FluidSynth: gain 0.45, 48 kHz, float output (no clipping inside the synth), its reverb on (room 0.82, damp 0.35, width 1, level 0.55),
   chorus off, 512 voices. The render copy of the MIDI runs 6 s past the loop point so releases and reverb are rendered, not cut.
2. Hall: a 2.6 s decaying-noise stereo impulse (band 180 Hz-7 kHz, 18 ms predelay), dry 0.82 + wet 0.32.
3. Loops: everything past the loop point is added back onto the start, so the wrap is seamless. One-shots: the tail rings out, trailing
   silence trimmed, a 0.25 s fade on the last of the tail.
4. Loudness: integrated LUFS (ITU-R BS.1770-4) to -20 (loops) or -17 (one-shots); true peak (4x oversampled) held at -2.0 dBTP by a
   look-ahead limiter that wraps around the loop (0.5 dB of margin under the game's -1.5 ceiling for the importer's Vorbis re-encode).
5. OGG Vorbis q6 for the game, MP3 192k preview, both measured again with ffmpeg's ebur128 for the report.

## Port check (MUS-TOWN v04)

`tools/music/scores/MUS-TOWN.py` is the v04 sketch on the toolkit. `compare_midi.py` against `Music_Source/MUS-TOWN_v04.mid`: **identical**
(1271 notes, 3145 events, 131.42 s). Its render against the Drive's `Approved_Audio/MUS-TOWN.ogg`: both 130.91 s, -20.0 LUFS, true peak
-2.3 vs -2.5 dB, band-envelope correlation 0.989, no systematic EQ difference. FluidR3_GM is the soundfont the reference was made with.

## Gotchas

- FluidR3's orchestra kit (bank 128, program 48) is the GS layout: notes 41-53 are **timpani**, not toms/crash. Crashes are 57 and 59, the
  concert bass drum 35/36, the snare 38/40. Use the names in `theory.KIT`. (The v04 sketch used 49 meaning a crash; it is a timpani - kept
  in the port for fidelity.)
- The Windows Store `python` alias is not Python; call the full path above.
- The importer (`import audio`) re-encodes new loops at Vorbis q5 with a linear loudnorm to -20 LUFS / -2 dBTP; a render already at that
  level passes through with no gain change.
- The Drive's `Approved_Audio/registry.json` records a loop end per file, and the importer obeys one that falls inside the file. Replace
  a file only through `deliver.py --approve`, which rewrites that record; a stale record silently shortens the new loop.
- Seams: the check compares the last second with the first. It fails when bar 0 has a voice the last bar lacks (or the reverse). Give the
  last bar the same voices and dynamic as bar 0, plus a small CC11 swell or soft roll into the loop point; `tools/music/seam_view.py`
  prints the level in 0.25 s steps either side of the seam.
- Battle and boss loops: an intro of ostinato alone sits 10+ dB under the body and becomes a hole every time the loop comes round; give
  the intro (and the matching outro) a sustained pad/brass bed so it stays within ~4 LU of the body.

## Music Pass 2 additions (Oct 31)

| What | Where |
|---|---|
| `Song` - the zone demos' score engine (`musiclib.Song`: explicit channels, raw GM programs, chord lists in melodies, `ramp`, `pump` for the EDM pad) on top of `Score`; the demos port line for line and give identical MIDI | `tools/music/lib/song.py` |
| The three approved zone themes, chord maps and palettes (`DNA_THEME`, `BUFFET_THEME` + `BUFFET_HOOK`, `DUMP_THEME`, `to_mode`) | `tools/music/lib/zones.py` |
| Seam fixes without touching notes: `Score.fade_vel(bar0, bar1, factor, chans)`, `recc11`; `tag_melody` (audibility check only); `detune(ch, cents, bar)` = pitch bend for "broken" cues | `tools/music/lib/score.py` |
| One-shots: lead-in silence trimmed, `onset_ms` reported (must be <= 20 ms), `Score.max_seconds` caps the ring-out (0.5 s fade), `Score.lufs` overrides the target (story one-shots -20), a 16-bit `<ID>_pcm16.wav` written beside the OGG | `tools/music/lib/render.py` |
| Stingers: all 21 builders in one module; `scores/STG-*.py` import theirs | `tools/music/scores/_stingers.py` |
| Delivery: `STG-` IDs go to Approved_Audio as WAV (stings stay WAV in the game); one-shot registry records keep null loop points; a Pass 1 render replaced later is backed up as `<ID>_<revision>.ogg` beside the original (never overwritten) | `tools/music/deliver.py` |
| Report rows (key, tempo, length, motif log, section LUFS, LUFS/TP, seam or onset, preview path) | `python tools/music/report_rows.py --batch "Batch 03" IDS...` |

## Music Pass 3 additions (Oct 31)

| What | Where |
|---|---|
| The Capital theme (built from the Primm motif), snare rudiments, `stumble` (imperfect bursts), `QUANTISED` (human feel off) | `tools/music/lib/capital.py` |
| Synth leads/basses/pads/FX and the GS drum kits (standard, room, power, electro, TR-808; every kit shares MIDI channel 10, one per score) | `tools/music/lib/instruments.py` |
| One command per finished part: previews + approve (+ `--own` for a former alias) + level analysis for those IDs + import (retried once) + boss stings + doc | `bash tools/music/deliver_part.sh "Batch 06" [--own "ID"] IDS` |
| music_list palette/description/notes rewrite; `--own ID` drops a former alias's note | `tools/music/music_list_pass3.py` |

Gotchas: the importer's ffmpeg calls can fail transiently while other renders load the machine (22 files dropped from the registry once);
`deliver_part.sh` restores the generated files and retries. A held note that runs past the next strike of the same pitch has its note-off
cut the new note (end sustained notes a hair early when re-striking).
