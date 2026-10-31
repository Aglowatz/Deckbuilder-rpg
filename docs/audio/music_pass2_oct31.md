# Music Pass 2 - zone soundtracks and all stingers (Oct 31 2026)

The three approved zone demos are now the zones' sound. Each zone has its own theme (`tools/music/lib/zones.py`), heard in every cue of
that zone and of its Path's related cues, with the Crossroads motif as a guest. All 21 stingers are new. Same toolchain as Pass 1
(`docs/audio/music_toolchain.md`); writing rules in `docs/audio/score_bible.md` (section 8 is new: zone directions, the zone-theme rule,
the freed rule, the Batch 3-8 key plan).

**Previews:** `G:\My Drive\Card Game Art\Music Review\Batch 03\` (D.N.A.), `\Batch 04\` (Buffet), `\Batch 05\` (Dump), `\Batch 07\`
(stingers), `\Batch 08\` (Path extras), and `\Batch 01\` (the five Pass 1 tracks re-rendered from the inbox answers). Loop MP3s play the
loop once and then 15 s past the loop point, so the seam can be heard.
**Old files:** `G:\My Drive\Card Game Art\Superseded\Music_v01\` - a file replaced for the first time keeps its plain name; a Pass 1 render
replaced now is kept as `<ID>_orch-v1.ogg` beside it (deliver.py never overwrites a backup).
**Source of truth for a later re-render:** `tools/music/midi/<ID>.mid`.

Columns as in Pass 1: LUFS = integrated loudness of the delivered file; TP = true peak; seam = last second vs first second (limit 1.5 dB)
and the sample step across the loop point; one-shots show the onset (time to the first sound above -30 dBFS; limit 20 ms) instead.

## Part 0 - the approved demos as the zones' exploration tracks, and the Pass 1 inbox answers

The demos are ported line for line through `tools/music/lib/song.py` (their own `musiclib.Song` API on top of `Score`): `compare_midi.py`
against each demo `.mid` printed **identical** (D.N.A. 1460 notes, Buffet 2108, Dump 3634). Only the loop seam was then fixed, with velocity
eases on the last bars (`Score.fade_vel`, no note changed): D.N.A. +3.94 -> +0.55 dB, Buffet +2.65 -> +0.45 dB, Dump +2.25 -> -0.19 dB.
The demos' low-end warnings (organ pedal + bass, tuba + synth bass in the drop) are left as approved.

| ID | Key | Tempo | Length | Motif / zone theme (bar: form) | Sections (bar: LUFS) | LUFS / TP | Seam / onset | Preview |
|---|---|---|---|---|---|---|---|---|
| MUS-NECRO-EXP | C minor | 100 BPM 3/4 | 1:55.2 (64 bars) | 22: stated (horns, low, minor); 30: stated (horns, low, minor); 36: stated (celesta 8va, the calm); 40: stated (celesta 8va) | 0 intro: -33.8; 4 A waltz: -23.8; 20 A' organ: -23.5; 36 B calm: -30.7; 44 climax: -16.2; 60 outro: -30.8 | -20.0 / -5.5 dB | +0.55 dB, no click | `Music Review/Batch 03/MUS-NECRO-EXP.mp3` |
| MUS-GOUR-EXP | F major | 132 BPM 4/4 | 1:56.4 (64 bars) | 24: stated (horns, F major); 40: stated (saw lead, the drop); 48: stated (saw lead + violins + glock) | 0 intro: -30.3; 4 A verse: -21.6; 20 A' big band: -19.9; 36 drop: -20.9; 52 finale: -16.7; 60 outro: -26.6 | -20.0 / -5.3 dB | +0.45 dB, no click | `Music Review/Batch 04/MUS-GOUR-EXP.mp3` |
| MUS-REF-EXP | E Dorian | 174 BPM 6/8 | 1:39.3 (96 bars) | 40: augmented (flute, E Dorian); 48: augmented (flute) | 0 intro glimmer: -30.2; 8 A jig: -24.3; 24 A' tutti: -20.1; 40 B lyrical: -23.0; 56 C fast variation: -20.1; 72 A'' climax: -15.9; 88 outro: -27.6 | -20.0 / -5.7 dB | -0.19 dB, no click | `Music Review/Batch 05/MUS-REF-EXP.mp3` |

Listen for:
- **MUS-NECRO-EXP** (ZONE-DNA): the woodblock clock and organ pedal under the bassoon/clarinet waltz; the organ takes the theme at bar 20 with horns asking the motif; the celesta motif in the eerie calm (~65 s); the dark tutti (~79 s). The last two bars now settle to the intro's level.
- **MUS-GOUR-EXP** (ZONE-BUFFET): the dinner-bell intro and "ta-da" brass; clarinet + muted trumpet verse over the oom-pah; the drop at bar 36 (~65 s) with the pumping pad, synth bass and the saw-lead hook, then the motif in the lead; the grand finale with the kick still under it.
- **MUS-REF-EXP** (ZONE-DUMP): fairy glimmer and chimes, then the fiddle jig; the lyrical B section with the motif stretched on the flute (~41 s); the fast fiddle variation (~58 s); the guitar now falls away into the glimmer at the loop.

### Inbox answers from Music Pass 1

| # | Answer | Done |
|---|---|---|
| 1 | Update the BEEF rows to orchestral; NECRO/GOUR/REF rows to the new directions | `music_list.csv`: the instrument palette and notes of 60 rows (every MUS-/STG- row of the four Path families: zones, side dungeons, Capital districts, shops, minigames, STG-ZONE-*) now describe the orchestral Beefcake march and the three approved zone directions. Alias rows keep their alias notes until Part 5 gives them their own tracks. |
| 2 | MUS-TOWN v05: the bar 0 pad from ~75 | Done (CC11 75 -> 92). That alone left the seam at +4.6 dB: the held horn and oboe of the outro were the louder part, so their last two bars were also eased (velocity only). v05 seam **+0.41 dB**. Registry revision `v05`. |
| 3 | Lullaby only in TUT-BOSS and MAREN | Removed from TITLE (bar 35), FOREST (bar 37) and TUT-EXP (bar 29); each gap now holds a quiet Crossroads head in the same celesta voice (logged as the motif). |
| 5-8 | Lengths fine; DECK cello ~3 LU flatter; keep the stopwatch; keep the battle intro levels | DECK section C is now -19.1 LUFS against -19.3 for B (was -17.2 vs -20.5): cello, its swell, the pizzicato and the piano each a step softer. |

| ID | Key | Tempo | Length | Motif / zone theme (bar: form) | Sections (bar: LUFS) | LUFS / TP | Seam / onset | Preview |
|---|---|---|---|---|---|---|---|---|
| MUS-TOWN | D dorian | 88 BPM 4/4 | 2:10.9 (48 bars) | 4: stated (horn); 12: stated (strings 8va); 36: stated (tutti brass); 44: fragment (augmented, horn) | 0 intro: -31.1; 4 A: -24.0; 12 A': -22.2; 20 B: -25.3; 28 B': -22.8; 36 climax: -14.5; 44 outro: -26.3 | -20.0 / -2.3 dB | +0.41 dB, no click | `Music Review/Batch 01/MUS-TOWN.mp3` |
| MUS-TITLE | D minor | 76 BPM 4/4 | 2:31.6 (48 bars) | 0: head, incomplete (lone horn); 4: stated (horns); 12: stated (tutti strings 8va + trumpet); 20: head in sequence (horn calls); 35: head (celesta, cut off); 36: stated (climax, trumpets + strings 15ma); 36: augmented (trombones, under the tune); 46: head, incomplete (lone horn) | 0 intro: -27.9; 4 A: -22.3; 12 A' tutti: -20.3; 20 B adventure: -22.6; 28 C oboe: -26.0; 36 climax: -14.7; 44 outro: -26.1 | -20.0 / -3.5 dB | -0.55 dB, no click | `Music Review/Batch 01/MUS-TITLE.mp3` |
| MUS-FOREST | A minor | 78 BPM 6/8 | 2:09.2 (56 bars) | 2: head, alone (flute); 8: tail (clarinet); 10: head (flute) answered; 16: stated whole, softly (oboe); 24: head on the 5th, walking (flute + clarinet in thirds); 32: stated low (solo cello); 37: head (celesta, far away); 40: stated (strings) | 0 night: -26.4; 8 fragments: -20.9; 16 warmth: -18.2; 24 the road: -17.0; 32 dark cello: -23.4; 40 warmth': -18.3; 48 night again: -27.1 | -20.0 / -5.5 dB | -1.38 dB, no click | `Music Review/Batch 01/MUS-FOREST.mp3` |
| MUS-TUT-EXP | E minor | 66 BPM 4/4 | 2:10.9 (36 bars) | 2: head (pan flute), left hanging; 8: stated (pan flute); 16: augmented (far horn, ancient); 24: tail (cello); 29: head (celesta) | 0 drone: -26.2; 8 motif: -18.8; 16 ancient court: -18.4; 24 echoes: -20.1; 32 drone again: -26.8 | -20.0 / -6.6 dB | +0.04 dB, no click | `Music Review/Batch 01/MUS-TUT-EXP.mp3` |
| MUS-DECK | F major | 72 BPM 4/4 | 2:00.0 (36 bars) | 2: head (piano), a question; 8: stated (piano), open; 12: stated in D minor (piano), open; 19: tail (celesta, a glint); 24: stated on C (piano), open; 34: head (piano), a question | 0 A chords: -22.2; 8 B question: -19.3; 16 C cello: -19.1; 24 A' chords: -19.4; 32 A again: -22.0 | -20.0 / -6.2 dB | -0.41 dB, no click | `Music Review/Batch 01/MUS-DECK.mp3` |

## Part 1 - all 21 stingers (Batch 07)

All in `tools/music/scores/_stingers.py` (one builder per ID). One-shots at -17 LUFS, ring out with no fold, the synth's lead-in trimmed:
every cue's first sound arrives within 2.4-12.1 ms (`onset`). Constantly heard cues are capped short with a 0.5 s fade (`max_seconds`):
VICTORY 4.0 s, PURCHASE 1.0 s, MINI-* under 2 s. Delivered as 48 kHz 16-bit WAV (stings stay WAV in the game); their levels were
re-analysed (`AUDIO_ONLY=STG- node tools/audio_analyze.js ...`, new) so the registry does not boost them by the old files' -23 LUFS.
The melody check warns on cues too short to have a "melody per bar"; ignored for stingers.

**In game:** `docs/review/play_scripts/music_pass2_victory.txt` (run with `MUSIC_LOG=1 bash tools/play.sh ... music_pass2_victory 420`):
new game -> Crosspath -> an ordinary encounter (Pantry Hound) played to a win by the built-in pilot in 16 turns; the log shows
`push MUS-TOWN-BATTLE` ... `pop MUS-TOWN-BATTLE` -> `play MUS-TOWN from 17.1s` -> **`sting STG-VICTORY`**, screenshot
`_screenshots/play/music_pass2_victory/03_victory.png`. The music smoke also fires every STG-ZONE-* at its zone's freeing.

| ID | Key | Tempo | Length | Motif / zone theme (bar: form) | Sections (bar: LUFS) | LUFS / TP | Seam / onset | Preview |
|---|---|---|---|---|---|---|---|---|
| STG-VICTORY | Bb major | 120 BPM 4/4 | 4.0 s (one-shot) | 0.25: RESOLVED tail (trumpets): the battle lands home | 0 lift: -17.6; 1 cadence: -17.5 | -17.0 / -4.8 dB | onset 5.4 ms | `Music Review/Batch 07/STG-VICTORY.mp3` |
| STG-DEFEAT | D minor -> F major | 72 BPM 4/4 | 5.0 s (one-shot) | 0.38: head (clarinet, a quiet question under the fall) | 0 all: -16.4 | -17.0 / -7.5 dB | onset 3.4 ms | `Music Review/Batch 07/STG-DEFEAT.mp3` |
| STG-LEVEL | G major | 132 BPM 4/4 | 3.8 s (one-shot) | - | 0 all: -15.6 | -17.0 / -5.4 dB | onset 4.4 ms | `Music Review/Batch 07/STG-LEVEL.mp3` |
| STG-QUEST | F major | 104 BPM 4/4 | 3.8 s (one-shot) | - | 0 all: -16.2 | -17.0 / -5.5 dB | onset 4.2 ms | `Music Review/Batch 07/STG-QUEST.mp3` |
| STG-DUNGEON | Bb major | 96 BPM 4/4 | 6.0 s (one-shot) | - | 0 all: -17.0 | -17.0 / -5.4 dB | onset 5.4 ms | `Music Review/Batch 07/STG-DUNGEON.mp3` |
| STG-ZONE-NECRO | C minor -> C major | 116 BPM 3/4 | 8.0 s (one-shot) | 3: RESOLVED tail (horn, C major): approved | 0 all: -16.6 | -17.0 / -5.2 dB | onset 3.2 ms | `Music Review/Batch 07/STG-ZONE-NECRO.mp3` |
| STG-ZONE-GOUR | F major | 132 BPM 4/4 | 7.0 s (one-shot) | 2: RESOLVED tail (brass): the button | 0 all: -16.5 | -17.0 / -3.5 dB | onset 3.6 ms | `Music Review/Batch 07/STG-ZONE-GOUR.mp3` |
| STG-ZONE-REF | E Dorian -> E major | 174 BPM 6/8 | 8.0 s (one-shot) | 2: RESOLVED tail (flute, E major) | 0 all: -16.4 | -17.0 / -5.2 dB | onset 4.1 ms | `Music Review/Batch 07/STG-ZONE-REF.mp3` |
| STG-ZONE-BEEF | Bb major | 126 BPM 4/4 | 8.0 s (one-shot) | 2: RESOLVED, stated (warm horns) | 0 all: -17.1 | -17.0 / -2.4 dB | onset 3.5 ms | `Music Review/Batch 07/STG-ZONE-BEEF.mp3` |
| STG-PACK-COMMON | C major | 140 BPM 2/4 | 1.9 s (one-shot) | - | 0 all: -14.2 | -17.0 / -4.2 dB | onset 2.5 ms | `Music Review/Batch 07/STG-PACK-COMMON.mp3` |
| STG-PACK-RARE | D major | 120 BPM 4/4 | 3.6 s (one-shot) | - | 0 all: -16.1 | -17.0 / -6.2 dB | onset 4.5 ms | `Music Review/Batch 07/STG-PACK-RARE.mp3` |
| STG-PACK-LEGEND | Eb major | 96 BPM 4/4 | 6.0 s (one-shot) | - | 0 all: -16.7 | -17.0 / -5.4 dB | onset 5.1 ms | `Music Review/Batch 07/STG-PACK-LEGEND.mp3` |
| STG-CRAFT | G major | 120 BPM 4/4 | 3.8 s (one-shot) | - | 0 all: -16.0 | -17.0 / -5.9 dB | onset 12.1 ms | `Music Review/Batch 07/STG-CRAFT.mp3` |
| STG-CRAFT-POST | A major | 120 BPM 4/4 | 4.8 s (one-shot) | - | 0 all: -17.0 | -17.0 / -4.4 dB | onset 11.2 ms | `Music Review/Batch 07/STG-CRAFT-POST.mp3` |
| STG-SECRET | C Lydian -> D major | 112 BPM 4/4 | 3.0 s (one-shot) | - | 0 all: -16.0 | -17.0 / -4.8 dB | onset 3.6 ms | `Music Review/Batch 07/STG-SECRET.mp3` |
| STG-PURCHASE | C major | 150 BPM 2/4 | 1.0 s (one-shot) | - | 0 all: -16.3 | -16.9 / -6.7 dB | onset 2.4 ms | `Music Review/Batch 07/STG-PURCHASE.mp3` |
| STG-ARENA | D major | 126 BPM 4/4 | 5.0 s (one-shot) | - | 0 all: -16.8 | -17.0 / -2.3 dB | onset 5.7 ms | `Music Review/Batch 07/STG-ARENA.mp3` |
| STG-SHIRO | C major -> Db major | 132 BPM 4/4 | 3.5 s (one-shot) | - | 0 all: -15.5 | -16.8 / -5.8 dB | onset 4.9 ms | `Music Review/Batch 07/STG-SHIRO.mp3` |
| STG-MINI-SUCCESS | C major | 132 BPM 2/4 | 1.8 s (one-shot) | - | 0 all: -14.5 | -17.0 / -3.1 dB | onset 2.4 ms | `Music Review/Batch 07/STG-MINI-SUCCESS.mp3` |
| STG-MINI-FAIL | E minor | 112 BPM 2/4 | 1.9 s (one-shot) | - | 0 all: -16.8 | -17.0 / -9.4 dB | onset 9.4 ms | `Music Review/Batch 07/STG-MINI-FAIL.mp3` |
| STG-RIFT | D major | 90 BPM 4/4 | 5.0 s (one-shot) | - | 0 all: -20.2 | -17.0 / -4.1 dB | onset 5.9 ms | `Music Review/Batch 07/STG-RIFT.mp3` |

Listen for:
- **STG-VICTORY** (the most-heard cue): a one-beat timpani roll on F with a string run into the downbeat; trumpets, horns and violins sing D - C over Bb - F7 in the motif's dotted rhythm, then Bb lands with the cymbal on a warm, full Bb major chord (tuba + basses + horns + strings), held ~1.3 s and faded by 4.0 s. The tune is the Crossroads motif's **resolved tail** - the only resolved motif outside freed tracks. No fanfare repeat, no long tail.
- **STG-DEFEAT**: oboe falling A G F E D over D minor, a quiet clarinet head under it, then Bb and a soft F major chord - hope left.
- **STG-LEVEL**: harp + pizzicato rising G B D G B D, answered by a Gadd9 (horn, strings, flute) and a triangle.
- **STG-QUEST**: clarinet/piano C A Bb G -> F over IV - V7 - I; the strings answer with a warm F chord.
- **STG-DUNGEON**: VICTORY broadened - slower, horns and strings climb Eb - F - Bb and land on the third, cymbal, held a little longer (6 s).
- **STG-ZONE-NECRO**: the D.N.A. theme's last phrase on bassoon + clarinet over organ, pizzicato and the clock; the cadence it always postponed arrives on **C major** - softened organ, choir, the clock stops; a horn sings the resolved tail.
- **STG-ZONE-GOUR**: the Buffet theme's two opening bars with the full showtune band, a snare build, then the **button**: the resolved tail A G | F as a brass stab with kick, clap and crash.
- **STG-ZONE-REF**: the fiddle's jig head over guitar and tambourine; then B7 -> E major: a clear flute sings the resolved tail, harp, celesta and chimes ring, the strings decay.
- **STG-ZONE-BEEF**: the Gainlands fanfare (the motif, open) on trumpets over the march; then warm horns sing the motif **resolved**, the bass walks up, a snare/timpani flourish and a held Bb chord.
- **STG-PACK-COMMON / -RARE / -LEGEND**: grandeur rises - a small celesta/harp sparkle (1.9 s); a harp rise with Dsus4 -> D and a crystal shimmer (3.6 s); a horn call (Bb Eb F Bb) over a timpani roll opening into Eb add9 strings, choir, flute shimmer and a synth glint (6 s).
- **STG-CRAFT / -CRAFT-POST**: two gestures (low pizzicato, high flute) join on G major; three (pizzicato, flute, horn) join on A major.
- **STG-SECRET**: a Lydian clarinet lift (C D E F#) answered by a celesta/harp sparkle on D.
- **STG-PURCHASE**: harp + pizzicato G4 -> C5, 1 s, soft.
- **STG-ARENA**: triplet trumpet/horn flourish leaping to the octave, a snare roll and timpani, D major chord with a cymbal.
- **STG-SHIRO**: smug pizzicato run up in C, a rim click, then the cheeky clarinet/bassoon staccato cadence a semitone sideways in Db.
- **STG-MINI-SUCCESS / -FAIL**: piano + harp G -> C; clarinet E D B ending on the fifth (a question, kind).
- **STG-RIFT**: a bowed-glass cluster wobbling out of tune (pitch bends) settles into a warm D major string/piano chord.
