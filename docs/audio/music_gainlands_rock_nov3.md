# Gainlands rock set + music quality rollback (Nov 3)

Designer decisions (Nov 3): the Gainlands is **TECHNO HARD ROCK** (the original music_list rows asked for electric guitars; Music Pass 1 made
them orchestral by mistake). The approved demo (`Music_Source/zone_demos/ZONE-GAINLANDS_demo_score.py` + `render_rock.py`) is the base for the
whole Beefcake set. Music goes back to **Vorbis q6** everywhere. No further size work.

Rules: `docs/audio/score_bible.md` section 10. Toolkit: `tools/music/lib/rock.py` (palette + the demo's helpers + the Gainlands riff, answer
and lick), `render.rock_chain` (guitar stem through an amp sim, noise risers, a shorter hall, bus glue), test `tools/music/tests/test_rock_render.py`.
Previews: `G:\My Drive\Card Game Art\Music Review\Gainlands rock\` (MP3s; `sources\` holds every score, its MIDI and, for the rock cues, the
two MIDI stems the renderer synthesises separately: `_guitars.mid` (through the amp sim) and `_band.mid`).

## The set

All loops at -20 LUFS (story one-shot -20, sting -17), seams within 1.5 dB, true peak <= -9.9 dBTP. Section loudness is integrated LUFS per
section from the render report. `low_end` warns on every full-band cue: power chords + bass + sub on the low strings, exactly as the approved
demo (accepted). Composers: the parent (BATTLE) and three composer forks (A: EXP/FREED/RELEASE/Transit Yards; B: House of Gains, boss, sting;
C: Swolympus, minigame, shop).

| ID | Key / BPM | Length | Sections (LUFS) | Seam | Listen for |
|---|---|---|---|---|---|
| MUS-BEEF-BATTLE | E minor 140 | 64 bars, 109.7 s | intro arp -24.9, riff -20.4, theme -19.3, build -22.7, drop -20.2, breakdown -20.1, build 2 -21.9, drop 2 -18.3, outro riff -21.3, outro arp -26.1 | +0.44 | the approved demo note for note; the only change is a bed under the intro/outro arp (held power chord, the drops' sub 8ths, a pad, the saw louder) - from the script the arp alone sat 13 LU under the track at every battle start and loop, while the approved MP3's opening was loud |
| MUS-BEEF-EXP | E minor 120 | 72 bars, 144.0 s | intro bed -25.9, riff -20.1, theme -18.5, B gentle -22.8, lift -21.2, riff + theme -17.7, riff thinning -21.3, outro bed -25.8 | -0.40 | the riff at walking pace, a half-time B section with the breakdown lick and a brass chorale; a lift with a short riser but no drop |
| MUS-BEEF-DUN-EXP | E minor 126 | 72 bars, 137.1 s | intro machine -22.9, machine riff -21.8, theme (stern) -19.1, breath (Flex) -29.4, build -21.7, riff + lick -17.3, outro riff -22.6, outro machine -23.0 | +0.59 | the 16th "reps" chug with a metallic clank (ride bell, cowbell, side stick); at 0:53 the guitars drop out for Flex's clean-guitar breath |
| MUS-BEEF-DUN-BATTLE | E minor 150 | 96 bars, 153.6 s | intro -24.7, riff hammered -20.6, build 1 -24.4, drop 1 -19.5, breakdown -21.2, build 2 -24.2, drop 2 -19.1, build 3 -23.8, drop 3 -18.7, outro riff -21.3, outro -24.6 | +0.20 | relentless double kick, three drops each prepared by a pulled-back build |
| MUS-BEEF-BOSS | D minor (drop-D) 136 | 96 bars, 169.4 s | intro stopwatch -24.1, Clench riff -21.3, the hero fights back -19.3, constriction -22.8, drop 1 -19.3, breakdown -21.2, build -22.7, final drop -18.0, Clench riff returns -22.4, outro stopwatch -24.3 | -0.52 | Clench's riff = the Crossroads motif inverted (D2 G1 A1 Bb1 C2 G1) as grinding drop-D chugs, the stopwatch (click 8ths + a ding every two bars, doubled by a triangle); from bar 68 the hero's motif on lead guitar over his riff in the final drop, left open |
| MUS-BEEF-FREED | E major 128 | 68 bars, 127.5 s | intro bed -26.4, riff -21.2, theme -19.1, B anthem -21.2, build -22.6, arena chorus -17.9, riff -20.3, theme 2 -21.2, outro bed -26.9 | +0.04 | E major chugs (I-vi-IV-V), big brass on the hits, the motif falling home to E on lead guitar; the arena chorus keeps a rock beat (celebratory, not four-on-the-floor) |
| MUS-BEEF-RELEASE | E major 100 | one-shot 68.8 s | hope (orchestral) -24.7, the band swells in -20.3, true strength -17.9, chorale -19.8, held E major -20.5 | onset 9.8 ms | strings, harp and horn alone for 8 bars (room for dialogue), power chords swelling in under a roll at bar 8, the band on the resolved motif at bar 12, a held E major chord ringing out |
| MUS-SWOLY-EXP | B minor 118 | 64 bars, 130.2 s | intro -26.1, A wide -19.9, B thin air -28.0, C the climb -18.8, D summit -18.4, outro -26.6 | -0.39 | half-time two-bar power chords, the lead climbing the Gainlands answer; the thin-air B section should feel like altitude, not a hole |
| MUS-SWOLY-BATTLE | B minor 146 | 80 bars, 131.5 s | intro -25.5, climbing riff -20.5, theme + brass calls -19.4, build -23.4, drop -20.5, breakdown -20.4, build 2 -22.2, drop 2 -18.5, outro riff -21.4, outro -26.1 | -0.82 | the riff climbing B-D-E-F# a step a bar; brass call -> lead answer |
| MUS-SWOLY-BOSS | F# minor 138 | 72 bars, 125.2 s | intro count -23.2, A the Spotter -20.9, B Gainlands vs the count -19.5, C thin air -22.2, build -22.6, D climax -18.8, outro count -22.8 | +0.27 | the Spotter's count: hammered stop chords, toms climbing 1-2-3-"one more" to the leading tone; the hero's motif fighting it in the climax (open) |
| MUS-MINIGAME-BEEF | A major 132 | 40 bars, 72.7 s | count-in -23.4, A workout -21.5, B lead + count -19.0, cool-down -24.0, build -22.5, drop -18.5, count-in -23.3 | -0.36 | gated 8th power chords + saw arps; a synth-voice "1-2-3-4" count (A C# E A) - aerobics count-in, or cheesy in a bad way? |
| MUS-SHOP-BENCHLEY | E Dorian 104 | 32 bars, 73.8 s | A clean guitar -20.0, B clarinet and pizz -19.4, A' guitar and celesta -19.7, C the motif -20.9 | -0.94 | clean (not driven) guitars, a muted-guitar skank under the Gainlands answer, clarinet/pizz/celesta for the shop's "mystic and fun"; level on purpose (browsing) |
| MUS-CAP-BEEF-BROKEN | E minor 116 | 56 bars, 115.9 s | intro bed -25.7, A thin -20.0, B fragments -18.9, C stalling -20.1, A' thin -19.9, outro bed -25.9 | -0.84 | one gappy guitar (bars missing), a shadow guitar 15 cents flat, the quantised harpsichord grid + march snare carrying on when the band stalls |
| MUS-CAP-BEEF-RESTORED | E major 116 | 56 bars, 115.9 s | intro bed -27.2, A riff -20.5, B theme -18.9, C riff + brass -19.1, A' theme -21.0, outro bed -27.1 | +1.09 | the same cue whole: every hit back, the second guitar in tune doubling the lead, the grid still ticking underneath |
| STG-ZONE-BEEF | E major 140 | one-shot 7.5 s | answer -16.6, resolved landing -17.6 | onset 3.6 ms | an instant crash + E power chord, the answer climbing, landing home on the resolved tail (G# F# E) |

Motif / theme placement per cue (bar numbers) is in each score's comments and its report (`tools/music/reports/<ID>.json`, "motifs").
The resolved motif appears only in FREED, RELEASE, CAP-BEEF-RESTORED and STG-ZONE-BEEF.

## Part 3 - back to q6 for everything

- Every one of the 144 toolkit scores (all MUS- and STG- IDs) re-rendered fresh at Vorbis q6 (`WP_VORBIS_Q=6 bash tools/music/rerender_all.sh
  render`; the host stopped one 12-ID chunk for low memory, its 7 IDs were rendered again on resume). Delivered with `deliver.py --approve`
  (Gainlands set `--revision rock-v1`, its orchestral versions backed up to Superseded/Music_v01; the other 129 `--no-backup --revision
  orch-q6`: their q3 files were turned down and their q6 originals are in `C:\Dev\music_tools\q6_backup`), levels re-analysed, "import
  audio" with `--no-process` (124 copied, 20 unchanged, 0 missing). Every game file is byte-identical to its render (checked 144/144).
- Boss victory stings re-cut (`cut_stings.js`: STG-WIN-BEEF-BOSS from 126.0 s, STG-WIN-SWOLY-BOSS from 83.0 s); `audio_doc.js`: 142 in game, 0 missing.
- Routing: the music smoke (OK - forest -> town -> graveyard -> shop -> battle -> zone -> dungeon -> boss -> zone freed -> Capital, worst
  crossfade 0.00 dB, including MUS-CAP-BEEF-RESTORED + STG-ZONE-BEEF), test_music_playback (zone/battle/dungeon/boss -> the BEEF IDs), and
  the Part 4 play-script run below. Audio GUT 91/91 (one tolerance aligned: the rock chain lands at -20.2 LUFS after encoding, so the
  registry trims +0.2 dB; the "no double gain" check now uses the same 0.25 tolerance as its loudness check).
- **Size, read this:** the music folder is **290 MB** (q3 was 175, the old in-game "q6" 224). The old in-game files were never really q6:
  the drop-in pipeline re-encoded the q6 renders at q5 (nominal 160 kbps; `ffprobe` on q6_backup). Fresh single-pass q6 is 192 kbps nominal,
  ~35 % bigger. See the inbox for the q5 option.


## Part 4 - verify + build

- Full sharded GUT: **2628/2630 passed, 0 failing**, 2 risky/pending (20 min).
- Play scripts with MUSIC_LOG=1 (`docs/review/play_scripts/gainlands_rock_nov3.txt` + `_clench.txt`, shots in
  `_screenshots/play/gainlands_rock_nov3*`): MUS-BEEF-EXP (zone) -> MUS-BEEF-BATTLE (Quota Spotter) -> MUS-BEEF-DUN-EXP (House of Gains map)
  -> MUS-BEEF-DUN-BATTLE (Treadmill Sprinter) -> MUS-BEEF-BOSS (under Clench's intro card) -> STG-WIN-BEEF-BOSS + STG-ZONE-BEEF ->
  MUS-BEEF-FREED. The first run played MUS-TOWN-BATTLE in both fights: dev encounters (`DevActions.make_encounter_battle`) never set a board,
  so the director fell back to the town. Fixed (a zone encounter keeps `zone:<id>`, a dungeon encounter its dungeon's battleboard) with a
  test in test_dev_menu.gd; the real game's routing was already right (test_music_playback).
- **Export v0.5.3: not done.** `tools/export_windows.sh` needs 2.5 GB of free disk (stage + zip); C: has ~2.0 GB after the music grew.
  Making room meant deleting `builds/TheWaywardPath-v0.5.2-windows.zip` (600 MB; the brief's cleanup, no tool reads it) and
  `C:\Dev\music_tools\q6_backup` (214 MB, the old q5-re-encoded game files, also in git history); the permission check refused both
  deletes, so they wait for you. Then: `bash tools/export_windows.sh 0.5.3` + `bash tools/run_release_smoke_exported.sh`.
- Already cleaned at the start: `builds/_testpack` (stale, rebuilt by `tools/export_test_pack.sh` when the exported suite needs it - it is
  not needed permanently) and `builds/TheWaywardPath-v0.5.2-windows` (a byte-identical copy of `builds/_export`).

