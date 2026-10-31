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

## Part 2 - D.N.A. (Batch 03)

The D.N.A. theme (`zones.DNA_THEME`) in every cue, the organ/choir/low-brass palette and the woodblock clock; keys and tempos as the bible plan. NECRO-BOSS is Mortimer Grimsby's own stamp theme on organ + trombones with the waltz theme forced into 4/4; NECRO-FREED takes the theme to C major and then Eb major with the resolved motif. The boss victory sting STG-WIN-NECRO-BOSS was re-cut from the new boss climax (`tools/cut_stings.js`).

| ID | Key | Tempo | Length | Motif / zone theme (bar: form) | Sections (bar: LUFS) | LUFS / TP | Seam / onset | Preview |
|---|---|---|---|---|---|---|---|---|
| MUS-NECRO-BATTLE | C minor | 138 BPM 3/4 | 2:05.2 (96 bars) | 1: head (horns, the call); 20: stated (horns); 23: stated (horns, sequenced up a third); 28: stated (horns + violins 8va); 42: tail (clarinet, left unfinished); 60: augmented (trombones); 74: head (horns, pushing on); 82: head (organ echo); 93: head (horns, the call) | 0 intro: -23.8; 4 A brass theme: -18.5; 20 B motif: -20.7; 36 C paperwork: -20.9; 44 D organ tutti: -18.1; 60 E augmented: -22.3; 76 F theme again: -20.1; 92 outro: -24.4 | -20.0 / -6.8 dB | +0.68 dB, no click | `Music Review/Batch 03/MUS-NECRO-BATTLE.mp3` |
| MUS-NECRO-DUN-EXP | F minor | 88 BPM 3/4 | 2:10.9 (64 bars) | 2: head (bassoon, low); 33: tail (horn, between desks); 36: stated, slow (cello); 41: stated (clarinet, an answer that stops short); 62: head (bassoon, low) | 0 intro clock: -26.3; 4 A desk to desk: -19.1; 20 B fragments pile up: -19.2; 36 C humane line: -21.1; 48 D paperwork peak: -19.4; 60 outro clock: -27.0 | -20.0 / -6.6 dB | -1.21 dB, no click | `Music Review/Batch 03/MUS-NECRO-DUN-EXP.mp3` |
| MUS-NECRO-DUN-BATTLE | F minor | 146 BPM 3/4 | 2:37.8 (128 bars) | 1: head (horns); 30: head (celesta glint); 36: stated (trombones); 39: stated (horns, up a third); 44: stated (trombones + tuba); 68: augmented (choir); 116: stated (tutti: horns, trombones, violins 8va); 125: head (horns) | 0 intro: -24.0; 4 A walking theme: -19.3; 20 B held tension: -22.4; 36 C active motif: -19.9; 52 D violins: -20.1; 68 E choir: -26.7; 84 F brass tutti: -16.2; 100 G fragments: -22.9; 116 H climax: -17.7; 124 outro: -23.8 | -20.0 / -5.0 dB | -0.25 dB, no click | `Music Review/Batch 03/MUS-NECRO-DUN-BATTLE.mp3` |
| MUS-NECRO-BOSS | C minor (harmonic) | 126 BPM 4/4 | 2:47.6 (88 bars) | 2: head (horns, entering the office); 36: inverted (cello); 40: inverted (horn); 48: head (horn, upright again); 60: stated (horns: the hero fights back), sequenced up a third; 86: head (horns, entering the office) | 0 intro: -24.3; 4 A Mortimer: -19.3; 20 B the waltz in 4/4: -19.6; 36 C the question inverted: -23.5; 52 D he is sure: -23.0; 60 E climax: -16.9; 76 F filing: -22.3; 84 outro: -24.3 | -20.0 / -5.0 dB | -0.08 dB, no click | `Music Review/Batch 03/MUS-NECRO-BOSS.mp3` |
| MUS-NECRO-FREED | C major -> Eb major | 92 BPM 3/4 | 2:20.9 (72 bars) | 1: tail resolved (celesta); 18: tail resolved (flute); 24: RESOLVED (horns, countermelody); 30: RESOLVED (horns, on G); 36: stated slow (flute, in A minor - one last question); 44: RESOLVED (flute: answered); 60: RESOLVED (horns, Eb); 69: tail resolved (celesta) | 0 intro: -27.4; 4 A winds, major: -18.8; 20 A' strings + resolved motif: -19.6; 36 B calm: -23.3; 48 C Eb major tutti: -18.6; 64 turn home: -20.3; 68 outro: -26.7 | -20.0 / -5.6 dB | -0.12 dB, no click | `Music Review/Batch 03/MUS-NECRO-FREED.mp3` |

Listen for:
- **MUS-NECRO-BATTLE**: the eighth-note woodblock clock under the brass theme; the quiet bassoon/clarinet/harpsichord hand-off at bar 36 (~47 s) is the breather.
- **MUS-NECRO-DUN-EXP**: the rim-shot "stamp" that cuts the bassoon off (~39 s); pizz/harpsichord layers piling up 20-35; the cello motif that never finishes (~74 s).
- **MUS-NECRO-DUN-BATTLE**: walking bass throughout; held sections (B, E) vs active ones; brass tutti at ~1:43.
- **MUS-NECRO-BOSS**: Mortimer's stamp theme (repeated notes, half-step, exact cadence) on the organ; the waltz limping in 4/4 at ~38 s; organ+choir alone at ~1:39 ('he is sure'); hero motif vs his theme at ~1:54. Calm, not screaming.
- **MUS-NECRO-FREED**: the theme in major with the polite tick still there; resolved horn motif at ~47 s; the lift to Eb major at ~1:34.

## Part 3 - Endless Buffet (Batch 04)

The Buffet theme (`zones.BUFFET_THEME`, the drop `BUFFET_HOOK`) in every cue; showtune orchestra + EDM layer, no folk; original melodies only. GOUR-BATTLE has a drop section; GOUR-DUN-EXP hides the theme in clockwork machinery; GOUR-BOSS (The Doppelganger) imitates the theme in canon, drifting a semitone flat, with the hero's motif mirrored (inverted) and a darker middle; GOUR-FREED is the full feast with the resolved motif. STG-WIN-GOUR-BOSS re-cut.

| ID | Key | Tempo | Length | Motif / zone theme (bar: form) | Sections (bar: LUFS) | LUFS / TP | Seam / onset | Preview |
|---|---|---|---|---|---|---|---|---|
| MUS-GOUR-BATTLE | Bb major | 142 BPM 4/4 | 2:01.7 (72 bars) | 1: head (horns, over the bed); 12: stated (horns, under the theme); 20: stated (horns, G minor); 28: stated (horns, G minor); 40: stated (saw lead, the drop); 48: stated (saw lead + violins); 60: head augmented (horns, finale); 69: head (horns, over the bed) | 0 intro bed: -22.0; 4 A showtune: -18.4; 20 B minor turn: -22.4; 36 drop: -21.5; 52 finale: -18.4; 68 outro bed: -22.3 | -20.0 / -7.0 dB | -1.07 dB, no click | `Music Review/Batch 04/MUS-GOUR-BATTLE.mp3` |
| MUS-GOUR-DUN-EXP | D minor | 112 BPM 4/4 | 2:17.1 (64 bars) | 4: head augmented (bassoon, in the machine); 24: stated (muted trumpet, a question at the station); 30: stated, a fifth up (muted trumpet); 44: stated low (horns, under the strings); 60: head augmented (bassoon, in the machine) | 0 machinery: -26.3; 8 A cold theme: -17.6; 24 B assembly line: -21.7; 36 A' strings: -19.1; 56 machinery again: -26.3 | -20.0 / -5.3 dB | -0.80 dB, no click | `Music Review/Batch 04/MUS-GOUR-DUN-EXP.mp3` |
| MUS-GOUR-DUN-BATTLE | G minor | 140 BPM 4/4 | 2:03.4 (72 bars) | 1: head (brass, over the bed); 8: stated (horns, under the brass); 20: augmented (horns, tension); 28: augmented, a fifth up (horns); 40: stated (saw lead, machine drop); 60: stated (horns, tutti); 69: head (brass, over the bed) | 0 intro bed: -19.6; 4 A brass theme: -19.4; 20 B tension: -20.7; 36 C machine drop: -21.9; 52 D tutti: -19.0; 68 outro bed: -19.3 | -20.0 / -7.0 dB | -0.70 dB, no click | `Music Review/Batch 04/MUS-GOUR-DUN-BATTLE.mp3` |
| MUS-GOUR-BOSS | F minor | 128 BPM 4/4 | 2:30.0 (80 bars) | 2: head (horns, in the bed); 14: stated (horns, borrowed - the hero in the Gourmand key); 24: stated (horns: the hero); 24: inverted - the MIRROR (trombones, against the hero); 36: inverted, augmented (trombones, the mirror); 48: head augmented (horns, alone); 64: stated (horns, the hero, climax); 64: inverted (trombones, the mirror, climax); 78: head (horns, in the bed) | 0 intro mask: -21.7; 4 A borrowed elegance: -17.7; 20 B warmth peels: -19.7; 36 C disguise lost: -25.9; 52 D warped drop: -20.0; 72 wind-down: -19.7; 76 outro mask: -21.6 | -20.0 / -5.3 dB | -0.08 dB, no click | `Music Review/Batch 04/MUS-GOUR-BOSS.mp3` |
| MUS-GOUR-FREED | F major | 124 BPM 4/4 | 2:34.8 (80 bars) | 1: head (clarinet, sparkle); 28: RESOLVED (horns, countermelody); 44: RESOLVED (saw lead, the feast); 64: RESOLVED (horns, G major tutti); 72: RESOLVED (cello, home); 77: head (clarinet, sparkle) | 0 sparkle: -28.9; 4 A cello: -24.2; 20 A' the house sings: -19.4; 36 feast drop: -22.9; 52 climb: -18.9; 56 G major tutti: -16.7; 72 home: -25.2; 76 sparkle again: -29.8 | -20.0 / -5.9 dB | +0.14 dB, no click | `Music Review/Batch 04/MUS-GOUR-FREED.mp3` |

Listen for:
- **MUS-GOUR-BATTLE**: the "welcome" theme bouncing at battle tempo over tuba and string 8ths; the horns' G-minor motif in B; the saw-lead drop at 0:51; the kick staying under the finale.
- **MUS-GOUR-DUN-EXP**: the machine is on the grid (no humanising); the clarinet's theme should sound correct but lifeless; the head passed station to station in B.
- **MUS-GOUR-DUN-BATTLE**: walking contrabass + claves/woodblock line; B's held tension; whether the minor hook in the machine drop still reads as the Buffet's.
- **MUS-GOUR-BOSS**: the strict canon in A (the copy drifting a semitone flat from bar 12); hero motif vs its mirror at 0:45 and 2:00; the 40-cent-flat celesta in the dark middle.
- **MUS-GOUR-FREED**: the warm cello theme first; the climb on D7 into G major (1:37); resolved motifs throughout; the sparkle loop point.

## Part 4 - Verdant Dump (Batch 05)

The Dump theme (`zones.DUMP_THEME`, the jig) in every cue; orchestral fairy folk (solo violin, nylon guitar, harp, celesta, chimes, flute/piccolo, tambourine). REF-BATTLE is a fast reel in A Dorian; REF-DUN-EXP (The Rotheart) sits on a cello drone while the fairy glimmers fade; REF-BOSS (Compostella) is a dark fairy tale with the jig in minor, roots and decay, grief rather than a monster; REF-FREED is spring returning: the jig in E major, chimes and harp, the resolved motif. STG-WIN-REF-BOSS re-cut.

| ID | Key | Tempo | Length | Motif / zone theme (bar: form) | Sections (bar: LUFS) | LUFS / TP | Seam / onset | Preview |
|---|---|---|---|---|---|---|---|---|
| MUS-REF-BATTLE | A Dorian | 144 BPM 4/4 | 2:00.0 (72 bars) | 2: head (horns, the call); 20: stated (horns, A Dorian); 24: stated (horns + violins 8va); 48: tail (horns, under the fiddle); 70: head (horns, the call) | 0 intro: -21.6; 4 A reel: -21.9; 20 B horn call: -21.2; 28 C fiddle variation: -20.8; 44 D tension: -22.1; 52 A' tutti: -17.1; 68 outro: -21.2 | -20.0 / -6.0 dB | +0.01 dB, no click | `Music Review/Batch 05/MUS-REF-BATTLE.mp3` |
| MUS-REF-DUN-EXP | B minor | 120 BPM 6/8 | 2:12.0 (88 bars) | 28: stated low (horns, choked by the tangle); 40: stated (flute, the spring glimpse); 76: tail (violins, caught in the canon) | 0 drone: -25.2; 8 A slow theme: -20.0; 24 B tangle grows: -19.4; 40 spring glimpse: -21.6; 48 A' cello theme: -21.9; 64 C canon, overgrown: -17.5; 80 drone again: -24.8 | -20.0 / -6.0 dB | +0.20 dB, no click | `Music Review/Batch 05/MUS-REF-DUN-EXP.mp3` |
| MUS-REF-DUN-BATTLE | E minor | 186 BPM 6/8 | 2:31.0 (156 bars) | 26: stated (horns through the tangle); 108: stated (horns, tutti); 116: stated a fourth up (horns) | 0 intro: -20.8; 4 A jig: -21.3; 20 B tangle + motif: -21.3; 36 sustained tension: -23.0; 52 C fiddle variation: -20.7; 68 spring glimpse: -22.2; 76 D cello theme, build: -24.1; 92 A' tutti: -16.8; 108 B' tangle tutti: -19.8; 124 E climax canon: -16.5; 140 wind-down: -23.8; 152 outro: -20.9 | -20.0 / -4.6 dB | +0.15 dB, no click | `Music Review/Batch 05/MUS-REF-DUN-BATTLE.mp3` |
| MUS-REF-BOSS | E harmonic minor | 156 BPM 6/8 | 2:46.2 (144 bars) | 6: inverted head (horns, from the roots); 48: inverted (horns, the question upside down); 74: head (horns, stabs); 78: head (horns, stabs); 82: head (horns, stabs); 86: head (horns, stabs); 104: stated (horns, the hero answers her) | 0 roots: -24.6; 8 A jig in minor: -22.1; 24 B lament: -21.2; 40 C lament trapped: -17.8; 56 grief break: -26.3; 72 E drive: -20.8; 88 F climax: -16.6; 112 decay: -21.8; 128 drive again: -22.8; 140 roots again: -24.7 | -20.0 / -4.4 dB | -0.33 dB, no click | `Music Review/Batch 05/MUS-REF-BOSS.mp3` |
| MUS-REF-FREED | E major | 168 BPM 6/8 | 2:08.6 (120 bars) | 40: RESOLVED (flute); 48: RESOLVED again (flute + fiddle 8vb); 104: RESOLVED (horns, tutti) | 0 spring glimmer: -26.8; 8 A flute jig: -21.1; 24 A' fiddle: -19.4; 40 B resolved motif: -22.6; 56 C fiddle variation: -21.2; 72 D the lament in major: -23.9; 88 A'' tutti: -16.5; 112 outro glimmer: -27.7 | -20.0 / -4.9 dB | +0.28 dB, no click | `Music Review/Batch 05/MUS-REF-FREED.mp3` |

Listen for:
- **MUS-REF-BATTLE** - the jig turned into a straight reel (each jig bar a b c d e f -> a b c b d e f e); the horn call in B; the running fiddle arpeggios over the violins' theme in C.
- **MUS-REF-DUN-EXP** - ostinatos piling up (pizz close steps, a 5-eighth harp cell against the 6/8 bar, bassoon seconds) until it feels wrong; the bar-40 drop to a clean D major spring glimpse; the glimmers getting fainter each time.
- **MUS-REF-DUN-BATTLE** - sustained-tension (36-51, 140-151) vs active passages; the moving bass (every bar steps to the next chord); the G major glimpse at 68.
- **MUS-REF-BOSS** - Compostella's lament (E F E | D# B | C B A G | F# D#), always left on the leading tone; trapped in a wind canon at 40; the grief break with the cello alone at 56; the hero's motif against her lament at 104.
- **MUS-REF-FREED** - the jig in major on a clear flute first; the resolved motif at 40 with chimes; the boss lament in major, now landing home, at 72.

## Part 5 - each Path's related cues (Batch 08)

Same palette and zone theme as each zone; Beefcake extras match the Gainlands tracks (orchestral march, the Gainlands theme from MUS-BEEF-EXP). The four side-dungeon bosses that used to share their battle track's file (**MUS-WAIT-BOSS, MUS-OMAKASE-BOSS, MUS-PANDA-BOSS, MUS-SWOLY-BOSS**) now have their **own** tracks, each with its own villain idea: alias removed in `music_list.csv`, `music_triggers.csv`, the Drive's `dungeon_battle_aliases.json` + `registry.json` (`deliver.py --own`), and `tests/audio/test_audio_registry.gd` (new `test_side_dungeon_bosses_play_their_own_files`); their victory stings STG-WIN-*-BOSS were re-cut. Remaining aliases: TUNNEL-BOSS, VAULT-BOSS, SIPHON-BOSS (not in this brief). Capital "broken" districts play the zone theme thin, interrupted and with one voice ~25 cents flat (`Score.detune`); "restored" plays the same theme full and in tune with the resolved motif. RELEASE cues are story one-shots at -20 LUFS (like the loops) with a held ending.

### Necrocrat

| ID | Key | Tempo | Length | Motif / zone theme (bar: form) | Sections (bar: LUFS) | LUFS / TP | Seam / onset | Preview |
|---|---|---|---|---|---|---|---|---|
| MUS-NECRO-RELEASE | Eb major | 72 BPM 3/4 | 73.5 s (one-shot) | 1: tail resolved (celesta); 20: RESOLVED, augmented (horn + organ) | 0 organ and harp: -26.1; 4 clarinet asks: -17.8; 12 strings answer: -19.9; 20 resolved motif: -19.7; 24 held ending: -24.2 | -20.0 / -7.8 dB | onset 2.9 ms | `Music Review/Batch 08/MUS-NECRO-RELEASE.mp3` |
| MUS-WAIT-EXP | Ab major | 96 BPM 3/4 | 2:00.0 (64 bars) | 1: head (celesta); 36: stated (clarinet, F minor - still waiting); 44: stated (flute, Ab major, open on the fifth); 61: head (celesta) | 0 intro: -31.6; 4 A piano tune: -24.1; 20 A' flute: -16.8; 36 B the question: -21.7; 52 A'' and the sidestep: -20.5; 60 outro: -29.3 | -20.0 / -7.1 dB | +1.20 dB, no click | `Music Review/Batch 08/MUS-WAIT-EXP.mp3` |
| MUS-WAIT-BATTLE | G minor | 136 BPM 3/4 | 2:07.1 (96 bars) | 1: head (horns); 20: stated (horns); 23: stated (horns, up a third); 52: stated (clarinet, on the fifth); 60: stated (horns + violins); 93: head (horns) | 0 intro: -24.4; 4 A piano theme: -22.2; 20 B held, the motif: -21.4; 36 A' flute + violins: -17.1; 52 B' motif again: -23.2; 68 C theme in the brass: -17.0; 84 D wind-down: -26.9; 92 outro: -24.3 | -20.0 / -5.6 dB | -0.56 dB, no click | `Music Review/Batch 08/MUS-WAIT-BATTLE.mp3` |
| MUS-WAIT-BOSS | Eb minor | 124 BPM 3/4 | 2:19.4 (96 bars) | 1: head (celesta); 28: head twice (trombones, stamping); 42: stated (clarinet, past the desk?); 48: stated (cello, lower); 68: stated (horns: the hero insists), sequenced up a third; 93: head (celesta) | 0 intro bell: -28.2; 4 A Betty: -20.6; 20 B the paperwork: -19.1; 36 C music box: -28.9; 52 D the desk: -20.3; 68 E climax: -17.8; 84 F please wait: -20.5; 92 outro bell: -28.4 | -20.0 / -6.3 dB | +1.13 dB, no click | `Music Review/Batch 08/MUS-WAIT-BOSS.mp3` |
| MUS-SHOP-LEDGERBONE | C minor | 84 BPM 3/4 | 1:17.1 (36 bars) | 20: stated (bassoon, a polite question) | 0 intro: -25.2; 4 A harpsichord theme: -21.8; 20 B bassoon question: -18.8; 28 A answer: -19.9; 32 cadence: -16.1 | -20.0 / -6.5 dB | +1.08 dB, no click | `Music Review/Batch 08/MUS-SHOP-LEDGERBONE.mp3` |
| MUS-MINIGAME-NECRO | A minor | 110 BPM 3/4 | 1:18.5 (48 bars) | 1: head (celesta); 20: stated (flute, curious); 45: head (celesta) | 0 intro: -34.6; 4 A cells: -21.4; 20 B the question: -22.6; 28 A' together: -18.3; 44 outro: -32.3 | -20.0 / -8.7 dB | +1.05 dB, no click | `Music Review/Batch 08/MUS-MINIGAME-NECRO.mp3` |
| MUS-CAP-NECRO-BROKEN | C minor | 80 BPM 3/4 | 1:57.0 (52 bars) | 21: head (clarinet, cut off) | 0 stall: -23.8; 4 A thin theme: -20.1; 20 B interrupted: -22.1; 36 C the clerk returns: -17.2; 48 stall: -24.1 | -20.0 / -5.4 dB | +0.92 dB, no click | `Music Review/Batch 08/MUS-CAP-NECRO-BROKEN.mp3` |
| MUS-CAP-NECRO-RESTORED | C major | 96 BPM 3/4 | 1:52.5 (60 bars) | 1: head (celesta, in tune); 36: RESOLVED (horns); 41: head (clarinet, the Capital shadow); 57: head (celesta, in tune) | 0 intro: -29.6; 4 A clarinet + celesta: -18.8; 20 A' strings + organ: -20.0; 36 B resolved motif: -22.3; 44 A'' tutti: -19.1; 56 outro: -28.9 | -20.0 / -7.2 dB | -0.97 dB, no click | `Music Review/Batch 08/MUS-CAP-NECRO-RESTORED.mp3` |

Listen for:
- **MUS-NECRO-RELEASE**: resolved motif augmented in horn + organ at ~50 s, then a 4-bar held Eb chord for the last line of dialogue.
- **MUS-WAIT-EXP**: pleasant piano waltz whose cadences sidestep (Fm, Db) instead of landing; the ghostly organ is discreet (vol 60).
- **MUS-WAIT-BATTLE**: two contrasting phrases: the piano theme over the string ostinato vs held tremolo + organ with the horn motif.
- **MUS-WAIT-BOSS**: Betty's curtsying phrase and the glock desk bell 'ding' at each phrase end; the music-box middle over diminished chords (~46 s) is deliberately quiet.
- **MUS-SHOP-LEDGERBONE**: the clean Fm-G7-Cm cadence with the clarinet landing home and the little harpsichord signature at the loop end.
- **MUS-MINIGAME-NECRO**: the GM square-lead arpeggios (old computer) kept low in the mix; phrases end on E (dominant), gently unresolved.
- **MUS-CAP-NECRO-BROKEN**: the flat second celesta (beating against the first); phrases stop early; the clock skips beats. Check the detune reads as broken, not as a mistake.
- **MUS-CAP-NECRO-RESTORED**: same theme, in tune, with the celesta doubling the violins cleanly; the snare tick and the Fm/Ab colours keep a Capital edge.

### Gourmand

| ID | Key | Tempo | Length | Motif / zone theme (bar: form) | Sections (bar: LUFS) | LUFS / TP | Seam / onset | Preview |
|---|---|---|---|---|---|---|---|---|
| MUS-GOUR-RELEASE | F major | 76 BPM 4/4 | 71.7 s (one-shot) | 1: head augmented (clarinet, opening); 16: RESOLVED (horn, slowly); 18: resolved tail (cello, falling home) | 0 opening: -25.2; 4 cello theme: -18.6; 12 violins: -21.3; 16 resolution: -20.1; 20 held chord: -18.3 | -20.0 / -8.2 dB | onset 4.7 ms | `Music Review/Batch 08/MUS-GOUR-RELEASE.mp3` |
| MUS-OMAKASE-EXP | D minor | 84 BPM 4/4 | 2:17.1 (48 bars) | 1: head (shakuhachi, a breath); 24: stated (shakuhachi); 28: stated a fifth down (shakuhachi); 45: head (shakuhachi, a breath) | 0 space: -22.4; 8 A koto course: -20.9; 24 B shakuhachi: -18.8; 32 A' strings: -18.5; 44 space again: -20.5 | -20.0 / -5.2 dB | -0.39 dB, no click | `Music Review/Batch 08/MUS-OMAKASE-EXP.mp3` |
| MUS-OMAKASE-BATTLE | D minor | 140 BPM 4/4 | 2:03.4 (72 bars) | 1: head (shakuhachi, over the bed); 20: stated (shakuhachi, the knife phrase); 28: stated (shakuhachi, the knife phrase); 24: stated (horns, answering); 60: stated (horns, tutti); 69: head (shakuhachi, over the bed) | 0 intro bed: -20.3; 4 A theme: -20.1; 20 B knife: -22.2; 36 C half time: -19.5; 52 D tutti: -18.9; 68 outro bed: -19.7 | -20.0 / -5.6 dB | +0.09 dB, no click | `Music Review/Batch 08/MUS-OMAKASE-BATTLE.mp3` |
| MUS-OMAKASE-BOSS | G minor | 132 BPM 4/4 | 2:25.5 (80 bars) | 24: inverted (horns, against the corrupted course); 32: inverted (horns); 36: stated, broadened (shakuhachi, the tea ceremony); 44: head (violins, suspense); 52: stated twice (horns: the hero fights back) | 0 intro knife: -21.4; 4 A Itamae: -18.3; 20 B corrupted course: -23.6; 36 C tea ceremony: -25.3; 48 build: -21.3; 52 D climax: -18.4; 72 wind-down: -19.8; 76 outro knife: -21.6 | -20.0 / -6.8 dB | +0.19 dB, no click | `Music Review/Batch 08/MUS-OMAKASE-BOSS.mp3` |
| MUS-SHOP-MIREPOIX | Bb major | 100 BPM 4/4 | 1:26.4 (36 bars) | 19: head (clarinet, a taste); 25: head, lower (clarinet) | 0 formal: -21.8; 16 welcoming: -17.6; 28 formal again: -22.4 | -20.0 / -5.8 dB | +0.19 dB, no click | `Music Review/Batch 08/MUS-SHOP-MIREPOIX.mp3` |
| MUS-MINIGAME-GOUR | C major | 138 BPM 4/4 | 1:16.5 (44 bars) | 0: head (muted trumpet, "and now!"); 20: stated (clarinet, the exchange); 24: stated (clarinet, in C); 40: head (muted trumpet, "and now!") | 0 studio intro: -22.2; 4 A theme: -23.6; 20 B exchange: -17.8; 28 A' studio band: -18.2; 40 studio intro again: -19.4 | -20.0 / -6.7 dB | +0.25 dB, no click | `Music Review/Batch 08/MUS-MINIGAME-GOUR.mp3` |
| MUS-CAP-GOUR-BROKEN | F minor | 96 BPM 4/4 | 2:00.0 (48 bars) | 1: head (flute, unanswered); 32: head (flute, fading); 45: head (flute, unanswered) | 0 rift: -22.7; 8 broken theme: -17.8; 24 hollow recipe: -23.9; 36 broken theme again: -19.2; 44 rift again: -20.8 | -20.0 / -3.8 dB | -0.09 dB, no click | `Music Review/Batch 08/MUS-CAP-GOUR-BROKEN.mp3` |
| MUS-CAP-GOUR-RESTORED | F major | 112 BPM 4/4 | 2:00.0 (56 bars) | 1: head (flute); 44: RESOLVED (horns, the district restored); 48: RESOLVED (cello, under the clarinet); 53: head (flute) | 0 intro: -27.0; 4 A theme in tune: -17.6; 20 B guarded: -24.3; 32 A' full + resolved: -19.6; 52 intro again: -26.9 | -20.0 / -7.9 dB | -0.43 dB, no click | `Music Review/Batch 08/MUS-CAP-GOUR-RESTORED.mp3` |

Listen for:
- **MUS-GOUR-RELEASE**: sincere and slow; the clarinet's little answers; the resolved motif onto a held F chord, room for dialogue.
- **MUS-OMAKASE-EXP**: the space - koto single notes, shakuhachi breaths; GM koto/shakuhachi are thin patches, judge them as colour.
- **MUS-OMAKASE-BATTLE**: the "knife" string stabs in B answering the shakuhachi; taiko on the grid; the half-time C section.
- **MUS-OMAKASE-BOSS**: the ITAMAE theme's blade-like 16th cut; koto and shamisen deliberately half a beat apart; the quiet tea-ceremony middle.
- **MUS-SHOP-MIREPOIX**: crisp formal piano, then strings warm it up; low busyness for browsing.
- **MUS-MINIGAME-GOUR**: TV energy (brass "and now!", timer woodblock, triangle dings); the clarinet/piano trade in B.
- **MUS-CAP-GOUR-BROKEN**: the detuned clarinet behind the celesta (it should sound wrong, not broken audio); phrases cut mid-bar; the one bar of warm cello.
- **MUS-CAP-GOUR-RESTORED**: the same theme, in tune and full; the stiff snare keeping the Capital's tension; the resolved motif at 1:34.

### Refusemancer

| ID | Key | Tempo | Length | Motif / zone theme (bar: form) | Sections (bar: LUFS) | LUFS / TP | Seam / onset | Preview |
|---|---|---|---|---|---|---|---|---|
| MUS-REF-RELEASE | E major | 108 BPM 6/8 | 71.3 s (one-shot) | 16: RESOLVED, augmented (flute); 34: RESOLVED tail (flute, the seed) | 0 seed: -27.4; 8 the lament, home: -18.2; 16 resolved motif: -18.2; 24 the jig as a hymn: -21.4; 32 held ending: -19.4 | -20.0 / -7.6 dB | onset 3.7 ms | `Music Review/Batch 08/MUS-REF-RELEASE.mp3` |
| MUS-PANDA-EXP | G Mixolydian | 112 BPM 4/4 | 2:00.0 (56 bars) | 22: stated (xylophone, the court dance); 26: head (horns, answering) | 0 fanfare: -23.5; 4 A procession: -21.5; 20 B court dance: -22.7; 28 C chase: -18.9; 44 A' procession tutti: -17.2; 52 outro fanfare: -22.5 | -20.0 / -5.7 dB | +0.57 dB, no click | `Music Review/Batch 08/MUS-PANDA-EXP.mp3` |
| MUS-PANDA-BATTLE | D Dorian | 146 BPM 4/4 | 2:11.5 (80 bars) | 20: stated (trumpet, the court); 26: head (horns); 68: stated (trumpet + violins, tutti) | 0 intro: -21.6; 4 A reel: -20.9; 20 B court phrase: -21.5; 28 C chase: -21.7; 44 D tension: -24.1; 52 A' tutti: -17.0; 68 B court tutti: -19.6; 76 outro: -21.1 | -20.0 / -5.0 dB | +0.18 dB, no click | `Music Review/Batch 08/MUS-PANDA-BATTLE.mp3` |
| MUS-PANDA-BOSS | B minor | 134 BPM 4/4 | 2:16.1 (76 bars) | 2: head (horns, under the fanfare); 28: inverted (horns, the court mocks); 40: stated (flute, the hero asks); 44: stated (horns, the hero fights back), then a fourth up; 52: stated (horns against the trumpets); 74: head (horns, under the fanfare) | 0 intro: -23.8; 4 A KING: -20.2; 20 B jig drive: -20.3; 36 C comic collapse: -24.9; 44 D climax: -17.5; 60 E drive: -20.2; 68 wind-down: -22.3; 72 outro: -24.0 | -20.0 / -5.4 dB | -1.08 dB, no click | `Music Review/Batch 08/MUS-PANDA-BOSS.mp3` |
| MUS-SHOP-GRISTLE | D major | 144 BPM 6/8 | 1:10.0 (56 bars) | 20: stated (solo violin, the question); 45: head (violin, trading with the xylophone) | 0 porch: -20.3; 4 A flute: -20.1; 20 B fiddle question: -20.0; 28 A' with harp: -18.6; 44 raccoon coda: -24.3; 52 porch again: -20.5 | -20.0 / -7.2 dB | -0.61 dB, no click | `Music Review/Batch 08/MUS-SHOP-GRISTLE.mp3` |
| MUS-MINIGAME-REF | A major | 150 BPM 4/4 | 1:16.8 (48 bars) | 3: head (xylophone, the fair's ding); 24: stated (horns, under the fiddle); 37: head (xylophone, the fair's ding); 39: head (xylophone, the fair's ding); 41: head (xylophone, the fair's ding); 43: head (xylophone, the fair's ding); 42: head + turn (flute, closing the answers); 47: head (xylophone, the fair's ding) | 0 intro: -21.0; 4 A flute reel: -19.8; 20 B fiddle reel: -19.9; 36 C answers: -19.6; 44 outro: -21.2 | -20.0 / -7.2 dB | +0.70 dB, no click | `Music Review/Batch 08/MUS-MINIGAME-REF.mp3` |
| MUS-CAP-REF-BROKEN | E minor | 132 BPM 6/8 | 1:49.1 (80 bars) | 40: stated (flute, drifting, unresolved); 66: head (flute, unanswered) | 0 clutter: -24.9; 8 A thin theme: -18.3; 24 B holes: -20.2; 40 flute drift: -17.4; 48 A' thinner: -19.9; 64 clutter, glimmer: -21.2; 72 clutter again: -25.2 | -20.0 / -6.2 dB | -0.03 dB, no click | `Music Review/Batch 08/MUS-CAP-REF-BROKEN.mp3` |
| MUS-CAP-REF-RESTORED | E Dorian | 150 BPM 6/8 | 1:55.2 (96 bars) | 48: RESOLVED (flute, chimes); 80: RESOLVED (horns) | 0 glimmer: -25.4; 8 A theme whole: -20.0; 24 B flute, breathing: -22.7; 40 Capital tension: -23.9; 48 C resolved motif: -23.5; 64 A' tutti: -16.8; 88 outro glimmer: -25.0 | -20.0 / -4.7 dB | +0.10 dB, no click | `Music Review/Batch 08/MUS-CAP-REF-RESTORED.mp3` |

Listen for:
- **MUS-REF-RELEASE** - quiet enough for dialogue; the lament resolved on the solo violin, then the slow resolved motif; the held E major ring at the end (the importer converts it to OGG like the other story one-shots).
- **MUS-PANDA-EXP** - swung swagger; the trumpet's regal flourish tripping on its top note (F#-G); bottle caps = muted triangle off-beats, sticks, cowbell.
- **MUS-PANDA-BATTLE** - two phrases: the reel (A) and the court phrase with the motif in the trumpet (B); the chase tosses the jig head between fiddle, piccolo and xylophone.
- **MUS-PANDA-BOSS** - KING: a pompous dotted fanfare that slinks down chromatically; the comic collapse at 36 (KING on a lone bassoon, the xylophone's wrong note); the hero's motif in the horns against KING at 44.
- **MUS-SHOP-GRISTLE** - relaxed porch jig on flute; the little xylophone/piccolo raccoon counterphrases at phrase ends; very soft metal percussion.
- **MUS-MINIGAME-REF** - county fair: banjo-bright off-beat chop (GM banjo, the Dump's folk colour) and the xylophone "ding" (the motif's head) answering the fiddle and flute.
- **MUS-CAP-REF-BROKEN** - the beating between the flat fiddle and the in-tune violin; phrases that stop mid-bar; dry pizz/harp clutter that never rings; faint bowed-glass rift.
- **MUS-CAP-REF-RESTORED** - the same theme whole and in tune; the stiff, quiet snare tick and B pedal at 40-47 (the Capital's tension); never a final cadence.

### Beefcake

| ID | Key | Tempo | Length | Motif / zone theme (bar: form) | Sections (bar: LUFS) | LUFS / TP | Seam / onset | Preview |
|---|---|---|---|---|---|---|---|---|
| MUS-BEEF-RELEASE | Bb major | 80 BPM 4/4 | 77.5 s (one-shot) | 4: stated (horn: the Gainlands fanfare, slowed); 20: RESOLVED, augmented (horns, strings 8va): strength shared willingly | 0 opening: -22.4; 4 A horn theme: -20.2; 12 B strings, swing: -20.5; 20 resolution + held chord: -17.4 | -20.0 / -6.2 dB | onset 3.2 ms | `Music Review/Batch 08/MUS-BEEF-RELEASE.mp3` |
| MUS-SWOLY-EXP | Eb major | 100 BPM 4/4 | 2:14.4 (56 bars) | 4: stated (horns: the Gainlands fanfare, climbing); 28: head (trumpet, distant, augmented); 36: stated (flute, thin air); 40: stated a fourth higher (flute) | 0 intro wind: -26.0; 4 A climb: -21.2; 20 B vista: -19.4; 36 C thin air: -24.5; 44 D summit: -15.9; 52 outro wind: -25.7 | -20.0 / -4.9 dB | +0.91 dB, no click | `Music Review/Batch 08/MUS-SWOLY-EXP.mp3` |
| MUS-SWOLY-BATTLE | C minor | 142 BPM 4/4 | 2:01.7 (72 bars) | 1: head (trumpet call); 20: stated (trumpets); 24: stated on Ab (trumpets); 28: augmented (horns), trumpets answer with the theme head; 64: head twice, climbing (trumpets); 69: head (trumpet call) | 0 intro bed: -23.5; 4 A theme: -19.2; 20 B call and climb: -21.9; 36 C broad: -18.4; 52 D stone breakdown: -20.5; 68 outro bed: -22.4 | -20.0 / -5.9 dB | -1.15 dB, no click | `Music Review/Batch 08/MUS-SWOLY-BATTLE.mp3` |
| MUS-SWOLY-BOSS | D minor | 128 BPM 4/4 | 2:07.5 (68 bars) | 1: head (clarinet, far); 36: inverted (clarinet: the question upside down); 42: stated (flute, in F major - the vista); 48: stated (horns: the hero holds the bar), sequenced up a third; 65: head (clarinet, far) | 0 intro count: -22.9; 4 A the Spotter: -21.3; 20 B Gainlands theme vs the count: -19.7; 36 C thin air: -25.2; 48 D climax: -17.2; 64 outro count: -22.5 | -20.0 / -5.2 dB | -1.09 dB, no click | `Music Review/Batch 08/MUS-SWOLY-BOSS.mp3` |
| MUS-SHOP-BENCHLEY | F major | 104 BPM 4/4 | 1:13.8 (32 bars) | 0: stated (horn: the Gainlands fanfare, relaxed); 10: stated (horn, low countermelody); 19: head (xylophone wink) | 0 A horn: -19.5; 8 B clarinet: -19.8; 16 C muted trumpet + xylophone: -22.9; 24 A' horn + flute: -18.7 | -20.0 / -7.7 dB | -1.42 dB, no click | `Music Review/Batch 08/MUS-SHOP-BENCHLEY.mp3` |
| MUS-MINIGAME-BEEF | Bb major | 128 BPM 4/4 | 1:07.5 (36 bars) | 1: head (horns, warming up); 4: stated (trumpet: the Gainlands fanfare, showing off); 20: stated (horns, the stretch); 24: stated on Eb (trumpet); 33: head (horns, warming up) | 0 count-in: -21.5; 4 A trumpet rep: -21.0; 12 B strings + xylophone: -19.2; 20 C stretch: -22.7; 28 D tutti rep: -16.1; 32 count-in again: -21.2 | -20.0 / -6.0 dB | +0.13 dB, no click | `Music Review/Batch 08/MUS-MINIGAME-BEEF.mp3` |
| MUS-CAP-BEEF-BROKEN | Bb major | 88 BPM 4/4 | 2:00.0 (44 bars) | 16: head (muted trumpet, unfinished); 32: head (horn, slowed, unfinished) | 0 A thin: -19.2; 12 B fragments: -22.2; 24 C stalling: -20.8; 36 A' thin: -17.8; 40 thin (loop): -18.0 | -20.0 / -3.6 dB | +0.20 dB, no click | `Music Review/Batch 08/MUS-CAP-BEEF-BROKEN.mp3` |
| MUS-CAP-BEEF-RESTORED | Bb major | 112 BPM 4/4 | 1:42.9 (48 bars) | 1: head (horn); 4: stated (trumpets: the theme the broken cue could not finish); 24: RESOLVED (horns: the service returns); 40: RESOLVED, quick (horns under the last phrase); 45: head (horn) | 0 intro vamp: -23.4; 4 A full theme: -21.0; 20 B Capital shadow: -22.7; 28 A' tutti: -17.7; 44 outro vamp: -23.4 | -20.0 / -6.6 dB | -0.04 dB, no click | `Music Review/Batch 08/MUS-CAP-BEEF-RESTORED.mp3` |

Listen for:
- **MUS-BEEF-RELEASE**: the march loosening into a swung pizzicato/tuba; the resolved motif landing on Bb at bar 22 and the long held chord; room for dialogue throughout.
- **MUS-SWOLY-EXP**: the lone flute on the wind over stone drums (concert bass drum); the theme climbing in the horns; the broad string vista; the thin-air flute section; the summit tutti.
- **MUS-SWOLY-BATTLE**: the climbing string ostinato under the C-minor theme; the trumpet call answered by the flute climbing; the stone-drum breakdown at bar 52 rebuilding.
- **MUS-SWOLY-BOSS**: the Spotter's three hammered reps and strained climb in the trombones/tuba (his own theme); the inverted motif in the calm; the hero's motif in the horns over the count in the climax.
- **MUS-SHOP-BENCHLEY**: an easy acoustic bass + brush groove (no strings, no snare drum); the xylophone wink at bar 19; the pickup at the end back into bar 0.
- **MUS-MINIGAME-BEEF**: the four-on-the-floor bass drum + claps; the trumpet "five, six, seven, eight"; the quiet GM square-lead wink in bars 12-19 (check it is restrained enough).
- **MUS-CAP-BEEF-BROKEN**: phrases stopping mid-line, the shadow horn audibly flat, missing tuba beats, the faint bowed-glass rift pad; warmth barely there.
- **MUS-CAP-BEEF-RESTORED**: the same theme now complete and in tune; the stiff grid snare and the minor-chord passage (Capital tension) before the resolved motif and the tutti.
