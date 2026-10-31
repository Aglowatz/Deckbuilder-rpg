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
