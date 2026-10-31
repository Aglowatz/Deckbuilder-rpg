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
