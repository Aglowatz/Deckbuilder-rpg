# Music Pass 3 - the rest of the soundtrack (Oct 31 2026)

All 57 remaining cues are written, rendered and in the game, plus the four "broken" Capital districts re-rendered with a gentler sour
voice. With this pass every row of `data/source/music_list.csv` plays an orchestral-toolkit file, and **no compatibility aliases are left**
(MUS-TUNNEL-BOSS, MUS-SIPHON-BOSS and MUS-VAULT-BOSS have their own tracks; their victory stings were re-cut).

Directions: `docs/audio/score_bible.md` section 9 (Capital, Primm, Lab, story, shops, side areas, the lullaby rule, the key/tempo plan).
New theme: the **Capital theme** (`tools/music/lib/capital.py`), 16 bars built from the two Primm cells, heard in every Capital cue.
Toolchain as before (`docs/audio/music_toolchain.md`); delivery per part with `bash tools/music/deliver_part.sh "<batch>" [--own IDS] IDS`.

**Previews** (`G:\My Drive\Card Game Art\Music Review\`): `Batch 06\` Capital (13), `Batch 06b\` Primm + ending (12), `Batch 09\` Lab (5),
`Batch 08b\` story (9), `Batch 11\` shops + quiz (10), `Batch 09b\` side areas (8), `Batch 08\` the four broken districts (re-rendered).
Loop MP3s play the loop once and then 15 s past the loop point, so the seam can be heard.
**Old files:** `G:\My Drive\Card Game Art\Superseded\Music_v01\` (deliver.py never overwrites a backup; the replaced story WAVs are there too).
**Source of truth for a later re-render:** `tools/music/midi/<ID>.mid`.

Measured, not heard: every loop is at -20.0 LUFS with its seam within 1.2 dB and no click; every one-shot starts within 16 ms. Story and
ending one-shots are at **-20 LUFS** like the *-RELEASE cues (the brief said -17 for one-shots; see the inbox). Score checks (range, low end,
melody audibility) pass on all 61 renders.

Composition: three parallel composer agents (A: Capital + shops, B: Primm/ending + story, C: Lab + side areas), the parent delivering each
part as it finished. Their notes: `tools/music/reports/_notes_pass3_part1..6.md`.

Columns: LUFS = integrated loudness of the delivered file; TP = true peak; seam = last second vs first second (limit 1.5 dB) and the sample
step across the loop point; one-shots show the onset (time to the first sound; limit 20 ms) instead.

## Part 0 - docs

- Score bible section 9 with every Oct 31 direction and a key/tempo plan for all 57 (no two related cues share key and tempo; build.py
  checked each part's cues together).
- `data/source/music_list.csv`: palette, description and notes for the 57 Pass 3 rows, and the **description** column of every row done in
  passes 1-2 rewritten to the approved directions (zone demos, orchestral Beefcake, stingers) - `tools/music/music_list_pass3.py`.
- `lib/capital.py` (Capital theme, snare rudiments, `stumble` for the imperfect bursts, `QUANTISED`); synth leads/basses/pads/FX and the GS
  drum kits in `lib/instruments.py` for the Lab.

## Part 1 - Capital world (Batch 06)

| ID | Key | Tempo | Length | Motif / zone theme (bar: form) | Sections (bar: LUFS) | LUFS / TP | Seam / onset | Preview |
|---|---|---|---|---|---|---|---|---|
| MUS-CAP-OUT-EXP | A minor | 72 BPM 4/4 | 2:26.7 (44 bars) | 12: stated (lone cello, the question); 24: head (distant flute, answers); 28: stated twice (violins, A minor then C) | 0 wind: -25.3; 4 A cello and piano: -20.4; 16 B the broadcast: -24.4; 28 C strings gather: -16.6; 40 wind: -25.7 | -20.0 / -2.9 dB | -0.70 dB, no click | `Music Review/Batch 06/MUS-CAP-OUT-EXP.mp3` |
| MUS-CAP-OUT-BATTLE | E minor | 132 BPM 4/4 | 1:56.4 (64 bars) | 1: head (trombones, low); 4: stated, then turned up (horns); 12: stated in G then E (horns + violins); 26: head (flute, cuts through the patrol); 40: augmented head (cello); 48: stated + sequenced (horns, violins 8va); 61: head (trombones, low) | 0 intro drive: -19.9; 4 A the motif fights: -20.0; 20 B the patrol (Capital theme): -21.6; 36 C broadcast breakdown: -23.6; 48 D climax: -17.1; 60 outro drive: -19.9 | -20.0 / -6.0 dB | +0.29 dB, no click | `Music Review/Batch 06/MUS-CAP-OUT-BATTLE.mp3` |
| MUS-CAP-FACADE-EXP | C major | 120 BPM 4/4 | 2:08.0 (64 bars) | 12: head (flute, far back, swallowed); 27: head (clarinet, breaks through the gap) | 0 intro muzak: -22.2; 4 A music box theme: -19.6; 20 B harpsichord + glock, missing cadence: -21.1; 36 C minor slips, the burst: -19.3; 48 A' the smile widens: -18.9; 60 outro muzak: -22.3 | -20.0 / -5.5 dB | -0.85 dB, no click | `Music Review/Batch 06/MUS-CAP-FACADE-EXP.mp3` |
| MUS-CAP-FACADE-BATTLE | C major | 144 BPM 4/4 | 2:00.0 (72 bars) | 2: head (horns, under the strain); 36: stated (horns, in D minor against the C major grid); 40: stated higher (horns + violins); 58: head (horns, in the cracks); 66: head (horns); 70: head (horns, under the strain) | 0 intro strain: -21.5; 4 A measured theme: -20.9; 20 B slips: -21.7; 36 C the motif breaks through: -19.2; 52 D full strain: -18.5; 68 outro strain: -21.5 | -20.0 / -6.5 dB | -0.75 dB, no click | `Music Review/Batch 06/MUS-CAP-FACADE-BATTLE.mp3` |
| MUS-CAP-ENFORCER | G major | 120 BPM 4/4 | 2:08.0 (64 bars) | 0: head (horn, before the drill); 13: stated, short (horns, under the inspection); 44: inverted (horns: the question turned upside down); 48: stated + sequenced (horns, violins 8va); 60: head (horn, before the drill) | 0 intro drill: -21.6; 4 A Spotless inspects: -23.4; 20 B the anthem in block brass: -19.7; 36 C pressure (G minor): -18.9; 48 D the hero fights back: -18.3; 60 outro drill: -21.5 | -20.1 / -5.9 dB | -0.74 dB, no click | `Music Review/Batch 06/MUS-CAP-ENFORCER.mp3` |
| MUS-CREASE | F major | 84 BPM 4/4 | 2:17.1 (48 bars) | 15: head (clarinet, guarded); 20: stated (cello, gentle); 22: stated (clarinet answers in F); 36: countermelody (cello under the violins) | 0 intro piano: -24.4; 4 A clarinet tune: -19.0; 20 B the motif, Path colours: -22.2; 32 A' strings join: -18.3; 44 outro piano: -25.0 | -20.0 / -6.9 dB | -0.43 dB, no click | `Music Review/Batch 06/MUS-CREASE.mp3` |
| MUS-CAP-CORRECTION | A minor | 120 BPM 4/4 | 2:08.0 (64 bars) | 33: head (oboe, a human phrase - unfinished); 39: head again (oboe, stops) | 0 metronome: -20.7; 4 A the anthem as procedure: -24.1; 20 B threat: -17.5; 32 C the unfinished phrase: -24.0; 44 D threat returns: -18.1; 60 metronome: -20.8 | -20.0 / -4.6 dB | +0.36 dB, no click | `Music Review/Batch 06/MUS-CAP-CORRECTION.mp3` |
| MUS-CAP-RIFT | D minor | 152 BPM 4/4 | 2:06.3 (80 bars) | 0: head (horns, breaking in); 44: stated twice (trumpets, breaks in); 60: stated + sequenced (violins, over the collision); 68: stated (cello, alone in the glass); 76: head (horns, breaking in) | 0 intro pulse: -20.6; 4 A D.N.A. waltz cracks: -21.7; 20 B Buffet + Dump collide: -21.8; 36 C Gainlands vs the grid: -18.7; 52 D all four: -17.9; 68 E dissolve: -23.5; 76 outro pulse: -20.7 | -20.0 / -6.2 dB | -1.17 dB, no click | `Music Review/Batch 06/MUS-CAP-RIFT.mp3` |
| MUS-TUNNEL-EXP | D dorian | 86 BPM 4/4 | 2:14.0 (48 bars) | 4: stated (piano, with tunnel echo); 14: stated (piano, the voices listen); 16: stated twice (cello); 20: stated twice (violins, cello below); 24: augmented chorale (horns); 32: stated three times (violins + horns, piano canon) | 0 drone: -25.2; 4 A four voices answer: -24.1; 16 B a shared direction: -19.9; 32 C the old harmony: -16.9; 44 drone: -25.3 | -20.0 / -5.4 dB | -0.14 dB, no click | `Music Review/Batch 06/MUS-TUNNEL-EXP.mp3` |
| MUS-TUNNEL-BATTLE | D minor | 138 BPM 4/4 | 1:58.3 (68 bars) | 0: head (horns); 4: stated in D then F (horns); 8: stated higher (trumpets + violins); 32: head (clarinet); 36: augmented (trombones + horns); 52: stated three times (tutti: trumpets, horns, violins 8va); 64: head (horns) | 0 intro: -20.4; 4 A the motif in full: -19.5; 20 B four voices: -22.7; 36 A' augmented, countermelody: -19.9; 52 C climax: -18.3; 64 outro: -20.4 | -20.0 / -5.1 dB | -0.93 dB, no click | `Music Review/Batch 06/MUS-TUNNEL-BATTLE.mp3` |
| MUS-TUNNEL-BOSS | C major | 132 BPM 4/4 | 2:03.6 (68 bars) | 2: head (horn, the tunnel stirs); 13: head + falling third (horns, under the inspection); 36: stated twice (cello, the tunnels answer); 40: stated + sequenced (horns, violins); 48: stated in C minor then Eb (horns + violins 8va, against the theme); 52: stated (trumpets); 66: head (horn, the tunnel stirs) | 0 intro march: -22.9; 4 A Spotless inspects the tunnels: -23.4; 20 B the anthem: -20.9; 36 C the tunnels answer: -20.7; 48 D climax: -17.0; 64 outro march: -21.6 | -20.0 / -6.1 dB | +0.14 dB, no click | `Music Review/Batch 06/MUS-TUNNEL-BOSS.mp3` |
| MUS-CASTLE-EXP | G major | 96 BPM 3/4 | 2:15.0 (72 bars) | 9: head (oboe, half hidden in the continuo); 50: head (oboe); 52: stated (oboe, exposed, in 3/4); 55: stated (violins answer) | 0 intro court: -21.8; 4 A minuet: -19.5; 20 B trio, Path ghosts: -20.5; 36 A' the symmetry cracks: -18.2; 52 C exposed (E minor): -21.7; 68 outro court: -21.9 | -20.0 / -6.8 dB | -0.69 dB, no click | `Music Review/Batch 06/MUS-CASTLE-EXP.mp3` |
| MUS-CASTLE-BATTLE | G minor | 140 BPM 4/4 | 1:56.6 (68 bars) | 2: head (horns, under the dance); 12: stated (choir, low, behind the mirror); 36: stated (horns, left); 36: inverted - the mirror (trombones, right); 40: stated (violins); 40: inverted (violas, the reflection); 48: stated four times (violins + trumpets, against Primm); 66: head (horns, under the dance) | 0 intro gavotte: -21.1; 4 A Primm and his reflection: -22.9; 20 B the Capital gavotte: -19.8; 36 C resistance: the motif vs its mirror: -18.4; 48 D climax: -19.3; 64 outro gavotte: -21.1 | -20.0 / -7.3 dB | -0.55 dB, no click | `Music Review/Batch 06/MUS-CASTLE-BATTLE.mp3` |

Theme placements per track (from the composer's notes):

- **MUS-CAP-OUT-EXP**: Capital theme bars 1-8 in C major on a far music box 20 c flat (the broadcast) 16-23; Capital head in A minor (cello) 28 / motif: stated (cello) 12, head (flute, distant) 24, stated twice A minor -> C (violins) 28 
- **MUS-CAP-OUT-BATTLE**: Capital theme in E harmonic minor (trumpets, the patrol) 20-35, music-box broadcast 36-43, trombones under the climax 48-55 / motif: head (trombones) 1, stated + turned up (horns) 4, stated G then E 12, head (flute) 26, augmented head (cello) 40, stated + sequenced (horns, violins) 48 
- **MUS-CAP-FACADE-EXP**: Capital theme whole on music box 4-19; harpsichord bars 1-7 with the cadence missing 20-26, music box bars 9-16 28-35; music box major/minor halves 36-43; snap-back cadence 46; bars 1-8 + 13-16 47-59 / motif: head (flute, swallowed) 12, head (clarinet, breaks through the gap) 27 
- **MUS-CAP-FACADE-BATTLE**: Capital theme music box 4-19; harpsichord major/minor halves 20-35; block-brass heads 38, 42; music box 44-51; trumpets + violins whole 52-67 / motif: head (horns) 2, stated D minor (horns) 36, stated E minor (horns + violins) 40, heads 58, 66 
- **MUS-CAP-ENFORCER**: own idea SPOTLESS (inspection flourish) 2, 4-19, trombones in the climax 48-59; Capital theme in G trumpets + horns 20-35, G minor trombones 36-43, bars 13-16 trumpets 56 / motif: head (horn) 0, stated short (horns) 13, inverted (horns + violins) 44, stated + sequenced (horns, violins 8va) 48 
- **MUS-CREASE**: no Capital theme (the resistance's own warm clarinet tune 4-19, violins 32-39) / motif: head (clarinet) 15, stated (cello) 20, stated in F (clarinet) 22, countermelody (cello) 36; Path cameos 24-29 (horn call, pizz waltz step, glock wink, flute turn) 
- **MUS-CAP-CORRECTION**: Capital theme bars 1-8 in A harmonic minor augmented on celesta 4-19; muted trumpets + trombone heads 20-31; trombones bars 1-8 44-51; celesta augmented 52 / motif: head (oboe, unfinished) 33, again 39 
- **MUS-CAP-RIFT**: D.N.A. waltz in 3-beat cells (celesta) 4-12; Capital theme minor on music box 13-19, block brass 36-43, trumpets 52-59 + 64-67, broken head 72; Buffet welcome (muted tpt) 20-29; Dump jig (violin) 26-35, 54; Gainlands theme (horns) 36-50, 60 / motif: head (horns) 0, stated twice (trumpets) 44, stated + sequenced (violins) 60, stated (cello) 68 
- **MUS-TUNNEL-EXP**: four zone heads: D.N.A. clarinet 6/24, Dump jig flute 8/26, Buffet muted horn 10/28, Gainlands horn 12 / motif: stated (piano + echo) 4, stated in F (piano) 14, stated twice (cello) 16, stated twice (violins) 20, augmented chorale (horns) 24, stated three times (violins + horns, piano canon) 32 
- **MUS-TUNNEL-BATTLE**: zone heads in phrase B: D.N.A. clarinet 20, Dump flute 22, Buffet trumpet 24, Gainlands horn 26 / motif: head (horns) 0, stated D then F (horns) 4, stated higher (trumpets + violins) 8, head (clarinet) 32, augmented (trombones + horns) 36, stated three times (tutti) 52 
- **MUS-TUNNEL-BOSS**: own idea SPOTLESS (as ENFORCER, in C) 0, 4-19, stumble 44; Capital theme trumpets + glock 20-35 (horns 28-35), C minor trombones 48-63, head 0 / motif: head (horn) 2, head + falling third (horns) 13, stated twice (cello) 36, stated + sequenced (horns, violins) 40, C minor/Eb (horns + violins) 48, stated (trumpets) 52 
- **MUS-CASTLE-EXP**: minuet built from the Capital theme's Primm cells 4-19 and 36-51; Capital theme in 4/4 across the 3/4 dance (horns, the cracks) 40-50; Path ghosts in the trio: D.N.A. celesta 18 c flat 21, Dump jig 27, Buffet muted 30, Gainlands call 33 / motif: head (oboe) 9, head (oboe) 50, stated in 3/4 (oboe, exposed) 52, stated (violins) 55 
- **MUS-CASTLE-BATTLE**: Primm motif in G minor (violins L) answered by its inversion (violas R) 0-1, 4-19; Capital theme in G minor (violins, mirrored violas) 20-35; Primm line + its mirror in the trombones 48-63 / motif: head (horns) 2, stated (choir) 12, stated vs inverted (horns L vs trombones R) 36, stated vs inverted (violins vs violas) 40, stated four times (violins + trumpets) 48 

### Listen for

- MUS-CAP-OUT-EXP: the wind pad and the hesitant long-short contrabass pulse; the lone cello; the music box broadcast far off and audibly flat (bright C major against the bleak A minor); the strings gathering at bar 28 and thinning back to wind.
- MUS-CAP-OUT-BATTLE: dry kit + low-string 8ths; the Bb chord a tritone from E minor (bar 9); the Capital theme as a minor-key trumpet patrol; the breakdown with the far music box broadcast; the climax motif vs the theme in the trombones.
- MUS-CAP-FACADE-EXP: music-box muzak on a rigid grid; the unmoving C pedal and the glass pad a few cents flat (dread); the one-bar C minor slip at 25; the missing cadence at 27 with the clarinet slipping into the gap; the rushed, wrong-note string burst at 44 and the instant perfect cadence after it.
- MUS-CAP-FACADE-BATTLE: repeated-note strings, flams and rim clicks; the same theme flipping major/minor every bar in B; horns breaking in with the motif in D minor against the C major grid; block brass slamming the anthem back.
- MUS-CAP-ENFORCER: Spotless's fussy inspection flourish (trumpet / piccolo, xylophone curl); drag/flam/paradiddle rudiments; Primm's even quarters in the timpani; the turn to G minor and the inverted motif (real pressure, not a joke); the hero answering in the horns.
- MUS-CREASE: the only human-feel Capital cue - piano, clarinet, cello, a few strings; the gentle cello motif; the four little Path cameos at 24-29; no snare, no music box.
- MUS-CAP-CORRECTION: the metronome that never stops; fluorescent high strings; the anthem slowed on celesta like a procedure; tremolo threat swells; the oboe's unfinished phrase in near silence (check the quiet C section is not too sparse in game).
- MUS-CAP-RIFT: the steady 3+3+2 pulse under everything; glass/crystal stutters; the D.N.A. waltz cells crossing the 4/4 barline; showtune and jig colliding in B; the Gainlands march against the Capital theme in C; all four at once in D.
- MUS-TUNNEL-EXP: the harp/piano echo a dotted quarter behind; the four zone heads answering one another (clarinet, flute, muted horn, horn); the motif growing from piano to cello to violins to a warm tutti; no grid.
- MUS-TUNNEL-BATTLE: warm core battle with a stepwise walking bass and harp echoes; the motif in full in the horns; the lighter pizzicato B phrase passing the zone heads around; the augmented motif with the violin countermelody.
- MUS-TUNNEL-BOSS: Spotless's rigid march in C dragged into the tunnels; the anthem in block brass; the warm contrasting tunnel section (cello/horn motif) interrupted by clipped brass and a rushed stumble; the climax: hero's motif vs the theme in C minor.
- MUS-CASTLE-EXP: a real minuet (harpsichord continuo, violins, flute/oboe trio, choir), no organ; the detuned celesta D.N.A. ghost behind the trio; the horns playing the anthem in 4/4 across the 3/4 dance (it should feel slightly off); the exposed E minor oboe question; the court snapping back to its cadence.
- MUS-CASTLE-BATTLE: two harpsichords hard left and right; the Primm line on the left answered upside down on the right; the hero's motif against its own inversion (horns L, trombones R) in C; detuned glass/metal shadows.


## Part 2 - Primm and the ending (Batch 06b)

| ID | Key | Tempo | Length | Motif / zone theme (bar: form) | Sections (bar: LUFS) | LUFS / TP | Seam / onset | Preview |
|---|---|---|---|---|---|---|---|---|
| MUS-PRIMM-01 | C major | 128 BPM 4/4 | 2:07.5 (68 bars) | 14: flattened into even quarters (clarinet), swallowed; 38: head flattened (horn), cut off; 46: head flattened (clarinet), swallowed | 0 intro clockwork: -21.0; 4 A unison: -20.4; 20 B the anthem: -21.0; 36 C compression: -22.2; 52 D tutti unison: -17.0; 64 outro clockwork: -20.9 | -20.0 / -6.1 dB | +0.46 dB, no click | `Music Review/Batch 06b/MUS-PRIMM-01.mp3` |
| MUS-PRIMM-02 | F major | 136 BPM 4/4 | 1:52.9 (64 bars) | 48: head (horn), then copied | 0 intro mirror: -19.5; 4 D.N.A. waltz: -23.1; 16 Buffet showtune: -21.3; 24 Buffet drop: -19.2; 32 Dump jig: -21.3; 40 Gainlands march: -19.1; 56 glitch stack: -17.1; 60 outro mirror: -19.5 | -20.0 / -5.1 dB | +0.96 dB, no click | `Music Review/Batch 06b/MUS-PRIMM-02.mp3` |
| MUS-PRIMM-03 | D major | 146 BPM 4/4 | 1:51.8 (68 bars) | 6: stated (horn) breaking through; 10: stated (trumpet), louder; 13: head (horns), the grid gives way; 16: augmented (trombones, bass); 26: tail (horn) answering; 32: augmented, stated (horns + strings): the climax; 40: stated (tutti); 44: stated, compressed (tutti), open on A; 48: head traded (tpt); 50: head traded (hn); 52: head traded (cl); 54: head traded (fid); 56: head traded (tpt); 58: head traded (vln) | 0 intro grid: -18.7; 4 A fracture: -21.9; 16 B voices return: -21.3; 32 C climax: -18.3; 48 D drive: -20.8; 64 outro grid: -18.6 | -20.0 / -5.8 dB | +0.67 dB, no click | `Music Review/Batch 06b/MUS-PRIMM-03.mp3` |
| MUS-PRIMM-BREAK | C major | 60 BPM 4/4 | 1:20.0 (20 bars) | 6: head (low cello), let go | 0 tick: -20.0; 2 A music box: -19.8; 10 B unstable: -20.5; 18 hold: -19.3 | -20.0 / -4.1 dB | +0.11 dB, no click | `Music Review/Batch 06b/MUS-PRIMM-BREAK.mp3` |
| MUS-PRIMM-DEFEAT | F major | 66 BPM 4/4 | 87.6 s (one-shot) | 14: stated (cello), open | 0 piano + cello: the motif human: -20.2; 6 the Path voices stand apart: -20.0; 14 crossroads, open: -19.7; 18 unresolved cadence: -19.8 | -20.0 / -5.2 dB | onset 3.8 ms | `Music Review/Batch 06b/MUS-PRIMM-DEFEAT.mp3` |
| MUS-PRIMM-MOTIF | C major | 104 BPM 4/4 | 37.7 s (one-shot) | 5: head (horn) under the music box, cut off by the brass | 0 chime: -31.9; 1 sincere: music box: -26.0; 6 coercive: the city: -19.0; 11 held: -16.9 | -20.0 / -7.3 dB | onset 2.7 ms | `Music Review/Batch 06b/MUS-PRIMM-MOTIF.mp3` |
| MUS-ARCHIVE | Eb major | 72 BPM 4/4 | 78.0 s (one-shot) | 8: tail (cello), a question | 0 sincere: -18.5; 10 narrowing: -21.2; 18 the grid: -25.6; 20 bare octave: -21.1 | -20.0 / -4.6 dB | onset 5.1 ms | `Music Review/Batch 06b/MUS-ARCHIVE.mp3` |
| MUS-GALLERY | G minor -> Bb major | 70 BPM 3/4 | 61.7 s (one-shot) | 12: head (piano), quiet; 15: head (piano), quieter | 0 piano alone: -26.2; 4 four notes: -27.2; 8 the missing answer: -25.0; 10 cello: -17.4; 18 Bb, held: -20.9 | -20.0 / -5.9 dB | onset 4.0 ms | `Music Review/Batch 06b/MUS-GALLERY.mp3` |
| MUS-CAP-RESTORED | D major | 104 BPM 4/4 | 2:27.7 (64 bars) | 33: head (horn) under the jig; 36: stated (flute), the question; 44: RESOLVED, augmented (strings 8va + horns): many ways home; 52: RESOLVED (tutti) | 0 intro: -22.5; 4 A the city, human: -18.7; 20 B four voices weave: -22.1; 36 C gentle: -23.1; 44 D resolved tutti: -18.3; 60 outro: -21.6 | -20.0 / -3.4 dB | +0.66 dB, no click | `Music Review/Batch 06b/MUS-CAP-RESTORED.mp3` |
| MUS-THRONE | D major | 76 BPM 4/4 | 65.0 s (one-shot) | 12: RESOLVED, augmented (horns + strings): the throne | 0 glimmer: -26.6; 2 the lullaby, whole: -22.1; 7 the lullaby, all voices: -19.0; 12 crossroads RESOLVED: -17.5; 16 ring: -31.3 | -20.0 / -6.1 dB | onset 3.7 ms | `Music Review/Batch 06b/MUS-THRONE.mp3` |
| MUS-REUNION | G major | 84 BPM 4/4 | 73.5 s (one-shot) | 9: head (flute); 10: head (horn); 18: RESOLVED (horn): a royal cadence | 0 gathering: -23.2; 4 lullaby: clarinet: -19.1; 9 Path punctuation: -23.6; 13 lullaby: violins: -17.8; 18 royal cadence: -18.8; 21 space for Agnes: -30.5 | -20.0 / -6.6 dB | onset 3.1 ms | `Music Review/Batch 06b/MUS-REUNION.mp3` |
| MUS-CREDITS | D major | 96 BPM 4/4 | 297.3 s (one-shot) | 0: stated in two halves (flute); 4: Crosspath theme (horn), its head is the motif; 38: head (horn), into the waltz; 52: tail (flute), into the Buffet; 80: stated (horns); 82: head (trumpet), answering; 84: inverted (clarinet); 86: tail (strings); 88: augmented (horns + strings); 108: RESOLVED, augmented (tutti): the grand finale; 116: RESOLVED (tutti); 120: RESOLVED (flute), tender | 0 intro: -24.7; 4 Crosspath: -19.5; 22 Gainlands: -19.2; 40 D.N.A.: -22.2; 54 Buffet: -19.9; 72 Dump: -23.0; 80 adventure: -20.1; 98 lullaby: -20.8; 108 finale: -17.6; 120 tender close: -27.8 | -20.0 / -4.1 dB | onset 4.5 ms | `Music Review/Batch 06b/MUS-CREDITS.mp3` |

Theme placements per track (from the composer's notes):

- **MUS-PRIMM-01**: Primm head+answer in unison 0 (strings), tutti 4, 8, augmented horns 12, minor-coloured unison 36-51, tutti + low 52, 56; Capital theme A (trumpets) 20, B 28 / motif: flattened to even quarters 14 (cl), 38 (hn, cut off), 46 (cl) 
- **MUS-PRIMM-02**: Primm copies: organ waltz 7, trumpet (showtune, even) 20, strings 28 (drop), fiddle jig 34, trumpet march 44, 52; calls: D.N.A. theme (cello) 4 + 13, Buffet welcome 16, hook 24, Dump jig 32 + 38, Gainlands theme 40 + 49 / motif: head (horn) 48, copied by Primm 48.5 
- **MUS-PRIMM-03**: Primm unison 0 + 64, fractured 4 + 8; zone heads in D: Gainlands 16 + 36 + 49, D.N.A. (major) 20 + 40 + 57, Buffet 24 + 38 + 53, Dump 28 + 42 + 60 / motif: stated 6 (hn) + 10 (tpt), head 13, augmented bass 16, tail 26, augmented climax 32, tutti 40, compressed 44 (open on A), heads traded 48-58 
- **MUS-PRIMM-BREAK**: Primm motif in half notes on the music box 2-9, again with two wrong (raised) notes over unstable chords 10-17 / motif: head (low cello) 6 
- **MUS-PRIMM-DEFEAT**: Primm motif human on piano 0-5, fragments 7 + 9; Path voices alone: Gainlands horn 6, Buffet clarinet 8, D.N.A. bassoon 10, Dump violin 12 / motif: stated (cello) 14, open; ends on Bbadd9 (unresolved, per the row) 
- **MUS-PRIMM-MOTIF**: the melody unchanged: music box 1-4 (sincere), strings + glock + block brass 6-9 (coercive) / motif: head (horn) 5, cut off 
- **MUS-ARCHIVE**: Primm motif at half speed on piano 2-9 (free harmony), twice at tempo 10-17 (tonic/dominant, ticking, tightening), on the grid 18 / motif: tail (cello) 8 
- **MUS-GALLERY**: lullaby first four notes ONCE 4; silence where the answer would be 8-9 / motif: head (piano) 12, 15 
- **MUS-CAP-RESTORED**: Capital theme lifted (dotted) A horn 4, B strings 12, head (flute) 0, 41, 60, glock 22, trumpets 48; Gainlands horn 20 + 56, Buffet clarinet 24 + 50, D.N.A. (major) cello 28 + 55, Dump fiddle 32 + 54 / motif: head 33, stated (flute, open) 36, RESOLVED augmented 44, RESOLVED tutti 52 
- **MUS-THRONE**: WHOLE lullaby flute + piano 2-6, strings + horn 7-11 with Buffet (cl) 8, D.N.A.-style bassoon 9, Dump (fl) 10, Gainlands (tpt) 10 / motif: RESOLVED augmented 12 
- **MUS-REUNION**: WHOLE lullaby in G: clarinet 4-8, violins 13-17; punctuation: horn call 0, Buffet flourish 1, jig turn 2 + 11, D.N.A. waltz step (bsn) 9 / motif: head (fl) 9, (hn) 10, RESOLVED (horn) 18; held G 21-23 for Agnes 
- **MUS-CREDITS**: Crosspath theme horn 4, strings 12; Gainlands 22; D.N.A. waltz clarinet 40, violins (major) 46; Buffet 54 + 62; Dump jig 72; WHOLE lullaby 98 + 103; zone heads in the finale 112-113 / motif: two halves (fl) 0, Crosspath head 4, head 38, tail 52, stated 80, head 82, inverted 84, tail 86, augmented 88, RESOLVED augmented 108, RESOLVED tutti 116, RESOLVED (fl) 120 

### Listen for

- MUS-PRIMM-01: the whole orchestra on one line in octaves; the clockwork piano + harpsichord 8ths never easing; the Capital theme in block brass on every beat; the Crossroads head (clarinet/horn) forced into even quarters and swallowed by the unison; the minor-coloured compression section; the fortissimo tutti hammering C and G.
- MUS-PRIMM-02: each zone's call followed by Primm's copy doubled by a thin square-wave synth; the organ waltz pulling against the 4/4 barline (hemiola) with Primm's MAJOR third over the minor oom-pah; the showtune copy in stiff even quarters, then the machine drop (kick, claps, synth bass, pumping pad); the jig copy stopping dead on the beat; the march copy landing on a Gb chord before snapping back; Primm copying the hero's head at bar 48.
- MUS-PRIMM-03: the opening grid, then the cracks (off-beat displacement, cluster stabs, raised wrong notes); the horn's Crossroads motif breaking through; from bar 16 the timing loosens (human again) and each zone theme enters in turn in its own colour; the broad horn + string motif at the climax with the zone heads around it; the outro snapping back to the grid as the loop restarts (intended: the duel keeps fighting it).
- MUS-PRIMM-BREAK: the music box in slow even halves; the tick; the second pass's chords sliding to Fm, Ab and Db over the C pedal while the music box carries on; two raised notes in the second pass; quiet enough for dialogue.
- MUS-PRIMM-DEFEAT: the Primm tune finally uneven and breathing on piano; each Path voice alone in its own space; the cello's open motif; the IV chord at the end (no home cadence).
- MUS-PRIMM-MOTIF: the same melody twice - first sincere (music box, harpsichord), then coercive (strings, glock, block brass, rudiments); check the transcription of the melody by ear (it came from pitch tracking).
- MUS-ARCHIVE: rich, free chords under the first statement; the harmony draining to I-V, the tick creeping in, the timing tightening to the grid; the bare Eb octave at the end.
- MUS-GALLERY: the four lullaby notes and the silence after them; the cello line; no crescendo; the soft turn to Bb.
- MUS-CAP-RESTORED: the Capital theme now lilting (dotted rhythms, horns not block brass); the four zone themes taking turns over one progression; the motif resolved in the tutti; no grid, no rudiments anywhere.
- MUS-THRONE: the first complete lullaby; the second statement with counterlines from each Path; the resolved motif with choir and timpani; the long D major ring.
- MUS-REUNION: the little Path punctuations (horn call, clarinet flourish, bassoon waltz step, violin jig turn); the lullaby in the clarinet then violins; the horn's resolved motif; three quiet bars at the end for Agnes.
- MUS-CREDITS: the tempo changes between sections (they are steps, not ramps); the D.N.A. waltz turning to C major and the Dump jig to E major (healed); the adventurous D minor middle; the lullaby slowing everything down; the grand resolved finale and the tender close.


## Part 3 - Path-ology Lab (Batch 09)

| ID | Key | Tempo | Length | Motif / zone theme (bar: form) | Sections (bar: LUFS) | LUFS / TP | Seam / onset | Preview |
|---|---|---|---|---|---|---|---|---|
| MUS-LAB-EXP | A minor | 150 BPM 4/4 | 2:33.6 (96 bars) | 2: head (piano, cold, cut short); 33: glitched (square lead, breakdown); 40: glitched (saw leads, drop 1); 48: glitched an octave up (drop 1); 56: inverted (cello, human); 76: glitched high (drop 2); 86: head (brass, end of drop 2); 90: head (piano, cold, cut short) | 0 bed: -23.3; 8 A grid + cello: -20.3; 24 B breakdown: -22.7; 40 drop 1: -18.5; 56 C glitch: -20.5; 72 drop 2: -17.9; 88 bed: -23.1 | -20.1 / -5.0 dB | +0.62 dB, no click | `Music Review/Batch 09/MUS-LAB-EXP.mp3` |
| MUS-LAB-BATTLE | F# minor | 160 BPM 4/4 | 2:24.0 (96 bars) | 0: glitched (saw lead, bed); 12: stated (saw lead, high); 22: glitched answer to the D.N.A. waltz head; 26: glitched answer to the Buffet hook; 30: glitched answer to the Dump jig head; 34: glitched answer to the Gainlands brass call; 36: augmented (cello, quiet passage); 52: glitched high (drop); 60: head augmented (brass, drop); 68: stated (saw lead, end of drop); 88: inverted glitched (saw lead); 92: glitched (saw lead, bed) | 0 bed: -20.7; 4 A ostinato + riff: -19.9; 20 B Path answers: -20.7; 36 C quiet: -22.5; 52 drop: -18.4; 76 D glitch: -20.6; 92 bed: -20.7 | -20.1 / -5.8 dB | +1.10 dB, no click | `Music Review/Batch 09/MUS-LAB-BATTLE.mp3` |
| MUS-SIPHON-BOSS | C minor | 170 BPM 4/4 | 2:38.1 (112 bars) | 8: stated (cello, answering); 16: glitched (saw lead); 28: glitched (drop 1); 36: head, dissected (saw); 38: tail, spliced onto Siphon (piano); 54: augmented (horns, against Siphon); 60: stated (saw lead, climax); 70: head augmented (horns); 76: head recombined with Siphon; 80: head recombined with Siphon; 84: head recombined with Siphon; 88: inverted glitched (saw); 92: glitched (final drop); 100: head augmented (horns, final) | 0 bed: -22.3; 4 A Siphon on glass: -20.7; 20 drop 1: -19.7; 36 C dissection: -22.5; 52 climax: -18.7; 76 E recombine: -21.5; 92 final drop: -19.2; 108 bed: -22.3 | -20.1 / -5.5 dB | -0.41 dB, no click | `Music Review/Batch 09/MUS-SIPHON-BOSS.mp3` |
| MUS-LAB-CELL | E major | 66 BPM 4/4 | 70.7 s (one-shot) | 4: stated (cello, open); 13: head (horn, rising toward recovery) | 0 marks: -30.1; 4 cello: -22.7; 8 the lullaby, four notes: -24.3; 12 warmth: -17.3; 16 held: -18.0 | -20.0 / -7.0 dB | onset 8.1 ms | `Music Review/Batch 09/MUS-LAB-CELL.mp3` |
| MUS-LAB-RESCUE | A major | 80 BPM 4/4 | 77.1 s (one-shot) | 1: head (horn, the unfinished rescue phrase); 3: head (horn, again); 12: stated (cello, guilt beneath the oboe); 16: RESOLVED (violins: the rescue lands) | 0 urgency: -20.7; 6 turn: -20.9; 8 relief: -20.2; 16 answered: -18.4; 20 breath: -20.0 | -20.0 / -8.2 dB | onset 15.0 ms | `Music Review/Batch 09/MUS-LAB-RESCUE.mp3` |

Theme placements per track (from the composer's notes):

- **MUS-LAB-EXP**: 2: head (piano, cold, cut short); 33: glitched (square lead, breakdown); 40: glitched (saw leads, drop 1); 48: glitched an octave up (drop 1); 56: inverted (cello, human); 76: glitched high (drop 2); 86: head (brass, end of drop 2); 90: head (piano, cold, cut short) 
- **MUS-LAB-BATTLE**: 0: glitched (saw lead, bed); 12: stated (saw lead, high); 22: glitched answer to the D.N.A. waltz head; 26: glitched answer to the Buffet hook; 30: glitched answer to the Dump jig head; 34: glitched answer to the Gainlands brass call; 36: augmented (cello, quiet passage); 52: glitched high (drop); 60: head augmented (brass, drop); 68: stated (saw lead, end of drop); 88: inverted glitched (saw lead); 92: glitched (saw lead, bed) 
- **MUS-SIPHON-BOSS**: 8: stated (cello, answering); 16: glitched (saw lead); 28: glitched (drop 1); 36: head, dissected (saw); 38: tail, spliced onto Siphon (piano); 54: augmented (horns, against Siphon); 60: stated (saw lead, climax); 70: head augmented (horns); 76: head recombined with Siphon; 80: head recombined with Siphon; 84: head recombined with Siphon; 88: inverted glitched (saw); 92: glitched (final drop); 100: head augmented (horns, final) 
- **MUS-LAB-CELL**: 4: stated (cello, open); 13: head (horn, rising toward recovery) 
- **MUS-LAB-RESCUE**: 1: head (horn, the unfinished rescue phrase); 3: head (horn, again); 12: stated (cello, guilt beneath the oboe); 16: RESOLVED (violins: the rescue lands) 

### Listen for

- MUS-LAB-EXP: the cold glass pulse + pumped pad bed; the very human cello (humanised inside the quantised grid) against the riff; the breakdown with the lullaby's first four notes on the piano (bar 28, A E C B) chopped off by a stutter; the riser into drop 1 and the glitched saw-lead Crossroads motif; drop 2 the loudest.
- MUS-LAB-BATTLE: the 16th string ostinato interlocking with synth ticks; the B section's four Path heads as orchestral stabs (D.N.A. waltz, Buffet hook, Dump jig, a Gainlands-style brass call), each answered by the glitched motif; the kick-less quiet passage with the cello's augmented motif; the drop with timpani and hits.
- MUS-SIPHON-BOSS: Siphon's scalpel figure (C G F# G Eb D B, even 8ths) on glass + piano, later hammered by strings and brass in octaves with choir; the dissection section where the Crossroads head, the lullaby's first four notes (glass, bar 40), the Lab riff and Siphon's cells are spliced together; the horns' augmented motif against Siphon at the climax.
- MUS-LAB-CELL: the near-silent piano counting small intervals; the cello's open motif; the four lullaby notes on celesta with pauses; the warmth arriving at bar 12 and the held E add9 ending.
- MUS-LAB-RESCUE: tremolo + pulsing low strings and the horn's unfinished head (urgency); the turn to A major; clarinet then oboe; the resolved motif in the violins at bar 16; the long breathing A major chord.


## Part 4 - Story (Batch 08b)

| ID | Key | Tempo | Length | Motif / zone theme (bar: form) | Sections (bar: LUFS) | LUFS / TP | Seam / onset | Preview |
|---|---|---|---|---|---|---|---|---|
| MUS-LULLABY | D minor | 70 BPM 4/4 | 36.5 s (one-shot) | - | 0 harp: -23.3; 1 the lullaby: -17.9; 6 resolution: -25.4 | -20.0 / -7.4 dB | onset 3.3 ms | `Music Review/Batch 08b/MUS-LULLABY.mp3` |
| MUS-MEM-01 | F major | 72 BPM 4/4 | 77.6 s (one-shot) | 14: stated (flute), tender; 18: head (celesta), an echo | 0 piano: -26.3; 4 humming: -20.5; 10 four colours: -22.2; 14 crossroads: -17.2; 20 slipping away: -24.7 | -20.0 / -5.7 dB | onset 4.8 ms | `Music Review/Batch 08b/MUS-MEM-01.mp3` |
| MUS-MEM-02 | D minor -> F major | 60 BPM 4/4 | 84.7 s (one-shot) | 12: stated (cello), slow | 0 white room: -22.6; 2 separated notes: -21.1; 12 the cello remembers: -18.7; 16 F major: -18.2 | -20.0 / -8.3 dB | onset 14.0 ms | `Music Review/Batch 08b/MUS-MEM-02.mp3` |
| MUS-MEM-03 | C minor -> Eb major | 92 BPM 4/4 | 77.7 s (one-shot) | 0: head as a royal processional (strings); 24: head (flute), hope | 0 royal phrase: -18.7; 8 the pulse cuts in: -20.6; 18 Maren's admission: -20.5; 24 hope: -20.9 | -20.0 / -6.4 dB | onset 4.3 ms | `Music Review/Batch 08b/MUS-MEM-03.mp3` |
| MUS-MEM-04 | D major | 66 BPM 4/4 | 77.0 s (one-shot) | 12: stated (cello); 14: stated (violins), open | 0 uncertain: -29.2; 4 the lullaby in focus: -18.1; 10 held: -23.7; 12 crossroads, open: -17.9; 17 held fifth: -20.7 | -20.0 / -6.2 dB | onset 3.2 ms | `Music Review/Batch 08b/MUS-MEM-04.mp3` |
| MUS-QUEST-PELL | Ab major | 72 BPM 3/4 | 64.3 s (one-shot) | 14: head (piano), gentle | 0 organ: -25.7; 8 cello: -18.6; 16 toward rest: -17.1; 20 held: -20.8 | -20.0 / -7.1 dB | onset 15.4 ms | `Music Review/Batch 08b/MUS-QUEST-PELL.mp3` |
| MUS-QUEST-ROLLO | Bb major | 88 BPM 4/4 | 76.2 s (one-shot) | 8: head (clarinet), catching breath | 0 the wheel: -20.4; 8 easing: -23.2; 12 free phrasing: -18.2; 20 rest: -22.3 | -20.0 / -6.6 dB | onset 6.0 ms | `Music Review/Batch 08b/MUS-QUEST-ROLLO.mp3` |
| MUS-QUEST-MARLO | F major | 80 BPM 4/4 | 69.6 s (one-shot) | 14: head (flute) | 0 the machine kitchen: -22.4; 10 a real recipe: -19.2; 18 flavour: -18.7 | -20.0 / -7.1 dB | onset 2.8 ms | `Music Review/Batch 08b/MUS-QUEST-MARLO.mp3` |
| MUS-QUEST-FERN | E major | 132 BPM 6/8 | 59.6 s (one-shot) | 16: head (flute) | 0 regulation pulse: -20.7; 8 flute: -19.9; 16 pulse tightens: -21.5; 24 growth: -18.7; 36 warm close: -20.6 | -20.0 / -6.5 dB | onset 2.5 ms | `Music Review/Batch 08b/MUS-QUEST-FERN.mp3` |

Theme placements per track (from the composer's notes):

- **MUS-LULLABY**: the lullaby unchanged (head + answer, 19 beats) on solo flute 1-5, celesta shadows the answer 2; harmony alone resolves A -> D 5-9 / motif: none (motif master: the Crossroads motif's parent) 
- **MUS-MEM-01**: lullaby first four notes hummed (oohs) 4, trailing off 7; four coloured glints 10-13 / motif: stated (flute) 14, head (celesta) 18; ends on Gm7/C (unresolved, per the row) 
- **MUS-MEM-02**: lullaby first four notes separated by gaps (celesta) 2, 4, 6, 8 over a glass cluster; human cello line 0-11 / motif: stated (cello, slow) 12; F major close 16 
- **MUS-MEM-03**: royal phrase (strings, horn) 0-7; Primm motif even, quantised rudiments 8-17 (low brass + cello); royal phrase cut off 12, 16; solo clarinet 18-23 / motif: head as the royal processional 0, head (flute) 24 into Eb 
- **MUS-MEM-04**: neutral open fifths 0-3; lullaby head + answer up to C G (17 of 19 beats) on flute + piano 4-9, held 10-11 / motif: stated (cello) 12, (violins, open) 14; held A 17 
- **MUS-QUEST-PELL**: D.N.A. theme in major: organ 0-7, cello 8-15; bassoon wink 12 / motif: head (piano) 14; plagal close 20 
- **MUS-QUEST-ROLLO**: Gainlands theme on a weary horn 0-11 over a pizzicato wheel + soft snare (fading); strings broad 12-19 / motif: head (clarinet) 8 
- **MUS-QUEST-MARLO**: Buffet welcome slowed: clarinet 0-9 over quantised harpsichord + woodblock; oboe with pizz/strings/harp 10-17 / motif: head (flute) 14 
- **MUS-QUEST-FERN**: Dump jig: solo violin 0, flute 8, violin 18 over a quantised pizz + click pulse; in E major 24 (violin), 28 (flute) / motif: head (flute) 16 

### Listen for

- MUS-LULLABY: the melody exactly as transcribed - check it against the original master by ear (pitch tracking is approximate); the strings and harp resolving to D major after the tune's last E.
- MUS-MEM-01: the hummed four notes (GM "oohs" - check it reads as a woman humming, not a choir); the four little coloured glints; the flute's motif with the cello under it; the unresolved Gm7/C ending.
- MUS-MEM-02: the cold glass cluster and the four notes far apart; the cello never stopping; the thaw into strings and harp and the warm F major chord.
- MUS-MEM-03: the dignified opening; the quantised snare and the even Primm motif in the low brass cutting it off; the royal phrase trying twice; the bare clarinet for Maren; the Eb major close.
- MUS-MEM-04: the neutral open fifths (works for both reveal routes); the lullaby clearest yet but stopping short; the motif held open on A.
- MUS-QUEST-PELL: the D.N.A. waltz theme in major on a soft organ, then cello; the bassoon's two-note "stamp"; the plagal close.
- MUS-QUEST-ROLLO: the tired pizzicato wheel and fading snare; the tempo steps down (88 -> 70); the strings' broad free phrase.
- MUS-QUEST-MARLO: the human clarinet against the machine-straight harpsichord and woodblock; the machine stopping at bar 10 and the warm pizzicato bounce with the oboe.
- MUS-QUEST-FERN: the clipped pizz + click on every dotted beat against the scrappy violin; the pulse stopping at bar 24 and the jig turning to E major.


## Part 5 - Shops and the quiz (Batch 11)

| ID | Key | Tempo | Length | Motif / zone theme (bar: form) | Sections (bar: LUFS) | LUFS / TP | Seam / onset | Preview |
|---|---|---|---|---|---|---|---|---|
| MUS-SHOP-SABLE | D minor | 92 BPM 4/4 | 1:23.5 (32 bars) | 24: stated (piano, home key); 28: head (flute) | 0 A clarinet: -18.3; 8 B piano and flute: -24.4; 16 A' clarinet, celesta: -18.4; 24 C the motif: -21.5 | -20.0 / -7.6 dB | +0.64 dB, no click | `Music Review/Batch 11/MUS-SHOP-SABLE.mp3` |
| MUS-SHOP-TONIC | G major | 128 BPM 4/4 | 1:15.0 (40 bars) | 28: stated twice (marimba, E minor then G); 32: head (clarinet) | 0 intro bubbles: -20.0; 4 A marimba: -19.5; 12 B flute and clarinet argue: -18.4; 20 A' xylophone: -22.8; 28 C the motif bubbles up: -20.4; 36 intro bubbles: -19.7 | -20.0 / -6.7 dB | -1.15 dB, no click | `Music Review/Batch 11/MUS-SHOP-TONIC.mp3` |
| MUS-SHOP-BEETSWORTH | C major | 108 BPM 4/4 | 1:20.0 (36 bars) | 28: stated (bassoon, very solemn); 30: head (oboe, approving) | 0 intro procedure: -22.6; 4 A bassoon, seriously: -20.9; 12 B the oboe corrects: -19.9; 20 A' clarinet joins: -17.8; 28 C the motif, solemnly: -20.3; 32 intro procedure: -22.4 | -20.0 / -6.4 dB | -0.50 dB, no click | `Music Review/Batch 11/MUS-SHOP-BEETSWORTH.mp3` |
| MUS-SHOP-THREADWELL | A minor | 112 BPM 4/4 | 1:17.1 (36 bars) | 28: stated (oboe, strutting rhythm); 30: head (clarinet answers) | 0 intro walk: -22.7; 4 A the strut: -20.5; 12 B browsing: -18.8; 20 A' the strut, flute ornaments: -19.6; 28 C the motif walks: -19.0; 32 intro walk: -22.7 | -20.0 / -8.9 dB | -1.04 dB, no click | `Music Review/Batch 11/MUS-SHOP-THREADWELL.mp3` |
| MUS-SHOP-FENWICK | Eb major | 84 BPM 4/4 | 1:20.0 (28 bars) | 20: stated (celesta: found in the binder); 22: stated on G (flute, the answer) | 0 A celesta: -20.9; 8 hold (anticipation): -22.4; 10 B music box + flute: -19.3; 18 hold: -22.9; 20 A' the motif in the binder: -19.1 | -20.0 / -7.3 dB | +0.34 dB, no click | `Music Review/Batch 11/MUS-SHOP-FENWICK.mp3` |
| MUS-SHOP-ALEMBIC | E minor | 76 BPM 4/4 | 1:15.8 (24 bars) | 16: stated (flute + clarinet in thirds below: blended); 18: stated in G (clarinet, flute a sixth above) | 0 A the flute speaks: -22.3; 4 the clarinet answers: -19.5; 8 B conversation: -20.2; 16 C blended: the motif in thirds: -17.7; 20 A again: -21.4 | -20.0 / -7.3 dB | +0.94 dB, no click | `Music Review/Batch 11/MUS-SHOP-ALEMBIC.mp3` |
| MUS-SHOP-ALEMBIC-POST | E lydian | 80 BPM 4/4 | 1:24.0 (28 bars) | 16: stated in four-part harmony (flute lead, oboe, clarinet, horn) | 0 A three voices: -19.7; 8 B four voices in counterpoint: -19.2; 16 C the royal phrase: -20.7; 24 A again: -21.1 | -20.0 / -8.3 dB | +0.13 dB, no click | `Music Review/Batch 11/MUS-SHOP-ALEMBIC-POST.mp3` |
| MUS-SHOP-FIGSLY | B minor | 96 BPM 4/4 | 1:20.0 (32 bars) | 24: stated (low clarinet, cautious - the resistance phrase); 26: head (piano, in D, warmer) | 0 A low clarinet: -19.5; 8 B the Crease tune, warmth: -20.0; 16 A' with piano answers: -20.6; 24 C the resistance phrase: -19.9 | -20.0 / -7.6 dB | -0.63 dB, no click | `Music Review/Batch 11/MUS-SHOP-FIGSLY.mp3` |
| MUS-SHOP-BELLOWS | F major | 100 BPM 4/4 | 1:16.8 (32 bars) | 24: stated as a little fanfare (horn); 26: head (muted trumpet answers) | 0 fanfare (restrained): -19.9; 4 A calm: clarinet: -20.0; 12 fanfare: -20.0; 16 B calm: flute and harp: -19.4; 24 C the motif as a fanfare: -22.2; 28 calm: -19.2 | -20.0 / -9.4 dB | -0.14 dB, no click | `Music Review/Batch 11/MUS-SHOP-BELLOWS.mp3` |
| MUS-QUIZ | Bb major | 116 BPM 3/4 | 1:26.9 (56 bars) | 20: stated in 3/4 (flute: the biggest question); 24: stated (cello answers with the same question); 34: head (flute) | 0 intro: -27.1; 4 A three questions: -19.5; 20 B thinking: -19.7; 36 A' three more: -19.2; 52 intro: -26.7 | -20.0 / -8.8 dB | +1.02 dB, no click | `Music Review/Batch 11/MUS-QUIZ.mp3` |

Theme placements per track (from the composer's notes):

- **MUS-SHOP-SABLE**: own sly chromatic clarinet tune 0-7, 16-23; piano answer 8-15; Crosspath tune wink (clarinet) 26 / motif: stated in its home key (piano) 24, head (flute) 28 
- **MUS-SHOP-TONIC**: own bouncing marimba tune 4-11, xylophone 20-27; flute/clarinet argument 12-19; surprise chords Eb (2, 6), Bb (10), E7 (15) / motif: stated twice E minor then G (marimba) 28, head (clarinet) 32 
- **MUS-SHOP-BEETSWORTH**: own serious bassoon tune 4-11, 20-27 (clarinet 8va); oboe 12-19 with a wrong C#6 at 14 "corrected" by the glock; hiccup bar 13 (no downbeat); oboe fanfares 23, 27 / motif: stated very solemnly (bassoon) 28, head (oboe) 30 
- **MUS-SHOP-THREADWELL**: own strut (oboe) 4-11, 20-27 with flute runs and harp glissandi on each entrance; calm browsing B (clarinet + harp) 12-19 / motif: stated in strut rhythm (oboe) 28, head (clarinet) 30 
- **MUS-SHOP-FENWICK**: own celesta tune 0-7, music box 10-13, flute 14-17; held-breath bars 8-9 and 18-19 (sus chord, a chime, a crystal glint) / motif: stated (celesta) 20, stated on G (flute) 22 
- **MUS-SHOP-ALEMBIC**: two voices: flute 0-3, clarinet 4-7, conversation 8-15 / motif: stated in thirds (flute + clarinet: blended) 16, stated in G with the flute a sixth above (clarinet) 18 
- **MUS-SHOP-ALEMBIC-POST**: three voices 0-7 (flute, oboe, clarinet), four in counterpoint 8-15 (+ cello); lullaby head (4 notes, in major) on a quiet horn 21 / motif: stated in four-part harmony (flute lead) 16 
- **MUS-SHOP-FIGSLY**: own low-clarinet tune 0-7, 16-23; the Crease tune (MUS-CREASE) in D 8-11 / motif: stated (low clarinet, the resistance phrase) 24, head in D (piano) 26 
- **MUS-SHOP-BELLOWS**: restrained fanfare (muted trumpet) 0-3, 12-15; calm clarinet 4-11, flute + harp 16-23 / motif: stated as a little fanfare (horn) 24, head (muted trumpet) 26 
- **MUS-QUIZ**: question (flute) / answer (clarinet / bassoon) in threes 4-17, 36-49 / motif: stated in 3/4 (flute) 20, stated (cello) 24, head (flute) 34 

### Listen for

- MUS-SHOP-SABLE: swung walking bass + brushes; the clarinet sliding down chromatically (D - C# - C); flute question flourishes; harp glissandi on glamour; the motif on piano in D minor; a two-bar wink of the Crosspath tune at 26.
- MUS-SHOP-TONIC: syncopated pizzicato fizz, tambourine and clicks; celesta bubbles rising; the Eb and Bb chords that change colour like a potion; flute and clarinet interrupting each other at 12.
- MUS-SHOP-BEETSWORTH: stiff quarters and dry piano chords; the bassoon's earnest tune; bar 13's missing downbeat (the bassoon fills it); the oboe's C# "mistake" at bar 14 corrected by a glock C; the solemn bassoon motif.
- MUS-SHOP-THREADWELL: the strut (dotted oboe pickups, walking bass, castanet flicks); flute runs and harp glissandi as entrances; the calm clarinet browse in the middle.
- MUS-SHOP-FENWICK: celesta/music box sparkle over warm strings; the two held-breath bars where everything waits on a suspended chord and a bell; crystal glints used sparingly.
- MUS-SHOP-ALEMBIC: flute (air) and clarinet (earth) taking turns, then singing the motif together in thirds; the faint glass pad; rolling piano and cello.
- MUS-SHOP-ALEMBIC-POST: the Lydian raised fourth (F#/E chords) for the new magic; three then four voices in counterpoint; the motif in four-part harmony; the lullaby's first four notes on a quiet horn at bar 21 (check it is quiet enough).
- MUS-SHOP-FIGSLY: hushed swung pizz bass and soft hats; the low clarinet glancing about; the warm turn to D major with the Crease's tune; the cautious motif.
- MUS-SHOP-BELLOWS: two short, restrained fanfares, then long calm pizz/harp stretches; the horn motif as a little fanfare; a soft timpani roll leading back to the top.
- MUS-QUIZ: 3/4 thinking pulse with no ticking; flute questions rising to an open note, clarinet/bassoon answers falling home, in threes; the motif as the "biggest question" in flute then cello.


## Part 6 - Side areas (Batch 09b)

| ID | Key | Tempo | Length | Motif / zone theme (bar: form) | Sections (bar: LUFS) | LUFS / TP | Seam / onset | Preview |
|---|---|---|---|---|---|---|---|---|
| MUS-VAULT-EXP | F# minor | 80 BPM 4/4 | 2:12.0 (44 bars) | 1: head (celesta, a clue); 12: stated (cello, under the clarinet); 20: stated (violins, A major - discovery); 34: head (horn, under the phrase); 41: head (celesta, a clue) | 0 clockwork: -25.2; 4 A royal phrase, four colours: -20.1; 20 B discovery: -19.3; 32 C the phrase together: -18.4; 40 clockwork: -26.5 | -20.0 / -6.9 dB | -0.29 dB, no click | `Music Review/Batch 09b/MUS-VAULT-EXP.mp3` |
| MUS-VAULT-BATTLE | B minor | 140 BPM 4/4 | 2:03.4 (72 bars) | 1: head (horns, over the bed); 8: stated (flute, over the horns); 20: stated (trumpets); 28: stated (trumpets); 44: head augmented (horns); 52: augmented (trombones, tension); 69: head (horns, over the bed) | 0 bed: -20.2; 4 A royal phrase (horns): -18.9; 20 B four colours answer: -21.7; 36 C strings drive: -19.4; 52 D tension: -20.6; 68 bed: -19.9 | -20.0 / -6.5 dB | -0.18 dB, no click | `Music Review/Batch 09b/MUS-VAULT-BATTLE.mp3` |
| MUS-VAULT-BOSS | F# minor | 128 BPM 4/4 | 2:07.5 (68 bars) | 1: head (horns, over the seals); 12: stated (trumpet, defying); 20: stated - horn (Beefcake seal); 24: stated - celesta (Necrocrat seal); 28: stated - clarinet (Gourmand seal); 32: stated - flute (Refusemancer seal); 44: head augmented (cello, hush); 50: augmented (horns, climax); 56: stated (violins high, climax); 65: head (horns, over the seals) | 0 seal strokes: -19.4; 4 A the Guardian: -19.4; 20 B four seals: -20.9; 36 C hush: -25.6; 48 climax: -18.2; 64 seal strokes: -19.7 | -20.0 / -4.8 dB | -0.03 dB, no click | `Music Review/Batch 09b/MUS-VAULT-BOSS.mp3` |
| MUS-GRAVE-EXP | G minor | 96 BPM 3/4 | 2:00.0 (64 bars) | 0: head (clarinet, a lantern peeking); 20: stated (clarinet, Bb major, amused); 36: inverted (cello, unease); 60: head (clarinet, a lantern peeking) | 0 lanterns: -22.1; 4 A the hum (bassoon, then Hob): -19.4; 20 B amusing: -19.4; 36 C mist: -23.1; 52 D all hum: -17.8; 60 lanterns: -22.3 | -20.0 / -7.1 dB | -0.19 dB, no click | `Music Review/Batch 09b/MUS-GRAVE-EXP.mp3` |
| MUS-GRAVE-BATTLE | Bb minor | 144 BPM 4/4 | 1:46.7 (64 bars) | 1: head (horns, over the bed); 20: stated (trumpets); 28: stated (trumpets); 44: head augmented (horns, under the hum); 52: inverted (trombones, tension); 61: head (horns, over the bed) | 0 bed: -20.2; 4 A the hum: -18.4; 20 B motif: -21.8; 36 C bones: -19.9; 52 D tension: -21.1; 60 bed: -20.7 | -20.0 / -6.8 dB | +0.99 dB, no click | `Music Review/Batch 09b/MUS-GRAVE-BATTLE.mp3` |
| MUS-ARENA-BATTLE | Eb major | 140 BPM 4/4 | 1:49.7 (64 bars) | 2: head (glockenspiel sparkle); 8: stated (flute, over the trumpets); 20: stated (horn, strategy); 28: stated (clarinet); 38: countermelody (horns, under the violins); 46: head augmented (trombones); 62: head (glockenspiel sparkle) | 0 fanfare: -19.6; 4 A the tune: -20.1; 20 B strategy: -23.4; 36 C the tune, strings: -19.2; 52 D presenting: -18.9; 60 fanfare: -19.3 | -20.0 / -6.3 dB | -0.31 dB, no click | `Music Review/Batch 09b/MUS-ARENA-BATTLE.mp3` |
| MUS-ARENA-ELITE | Ab major | 148 BPM 4/4 | 1:50.3 (68 bars) | 10: stated (flute, above the canon); 24: stated (trombones, E major, in the fugato); 32: stated (trumpets, climax); 36: stated (trumpets, C minor, climax); 40: head augmented (horns); 50: stated (horn, the strategy canon) | 0 fanfare: -19.7; 4 A tune + countersubject + canon: -20.2; 20 B fugato: -20.1; 28 C climax: -18.8; 44 D strategy canon: -23.8; 56 E tutti return: -18.9; 64 fanfare: -19.8 | -20.0 / -6.5 dB | -0.89 dB, no click | `Music Review/Batch 09b/MUS-ARENA-ELITE.mp3` |
| MUS-SHIRO-BOSS | E minor | 152 BPM 4/4 | 1:53.7 (72 bars) | 1: head (horns, behind the curtain); 12: stated (cello, under the trick); 26: stated (clarinet, regaining composure); 36: stated (horns, the sincere side); 52: head augmented (trombones); 66: tail (clarinet, recovering); 69: head (horns, behind the curtain) | 0 clappers: -19.8; 4 A the trick: -22.1; 20 B the pose: -17.6; 28 C chase (sincere): -18.7; 44 D brass trick: -22.6; 60 E the pose again: -19.2; 68 clappers: -19.9 | -20.0 / -3.6 dB | -0.96 dB, no click | `Music Review/Batch 09b/MUS-SHIRO-BOSS.mp3` |

Theme placements per track (from the composer's notes):

- **MUS-VAULT-EXP**: 1: head (celesta, a clue); 12: stated (cello, under the clarinet); 20: stated (violins, A major - discovery); 34: head (horn, under the phrase); 41: head (celesta, a clue) 
- **MUS-VAULT-BATTLE**: 1: head (horns, over the bed); 8: stated (flute, over the horns); 20: stated (trumpets); 28: stated (trumpets); 44: head augmented (horns); 52: augmented (trombones, tension); 69: head (horns, over the bed) 
- **MUS-VAULT-BOSS**: 1: head (horns, over the seals); 12: stated (trumpet, defying); 20: stated - horn (Beefcake seal); 24: stated - celesta (Necrocrat seal); 28: stated - clarinet (Gourmand seal); 32: stated - flute (Refusemancer seal); 44: head augmented (cello, hush); 50: augmented (horns, climax); 56: stated (violins high, climax); 65: head (horns, over the seals) 
- **MUS-GRAVE-EXP**: 0: head (clarinet, a lantern peeking); 20: stated (clarinet, Bb major, amused); 36: inverted (cello, unease); 60: head (clarinet, a lantern peeking) 
- **MUS-GRAVE-BATTLE**: 1: head (horns, over the bed); 20: stated (trumpets); 28: stated (trumpets); 44: head augmented (horns, under the hum); 52: inverted (trombones, tension); 61: head (horns, over the bed) 
- **MUS-ARENA-BATTLE**: 2: head (glockenspiel sparkle); 8: stated (flute, over the trumpets); 20: stated (horn, strategy); 28: stated (clarinet); 38: countermelody (horns, under the violins); 46: head augmented (trombones); 62: head (glockenspiel sparkle) 
- **MUS-ARENA-ELITE**: 10: stated (flute, above the canon); 24: stated (trombones, E major, in the fugato); 32: stated (trumpets, climax); 36: stated (trumpets, C minor, climax); 40: head augmented (horns); 50: stated (horn, the strategy canon) 
- **MUS-SHIRO-BOSS**: 1: head (horns, behind the curtain); 12: stated (cello, under the trick); 26: stated (clarinet, regaining composure); 36: stated (horns, the sincere side); 52: head augmented (trombones); 66: tail (clarinet, recovering); 69: head (horns, behind the curtain) 

### Listen for

- MUS-VAULT-EXP: the woodblock/glock clockwork; the royal phrase handed horn -> celesta -> clarinet -> flute (one colour per Path); the middle brightening to A major with the violins' motif and the lullaby's first four notes on the celesta (bar 28, F# C# A G#); the phrase in octaves at the end.
- MUS-VAULT-BATTLE: the 8th string drive and ticking woodblock; the royal phrase in the horns; phrase two's trumpet motif answered by four quick colour calls; the violins taking the phrase up an octave with brass stabs; the darker trombone passage.
- MUS-VAULT-BOSS: the four seal strokes + grinding answer (trombones/tuba over concert bass drum); the royal phrase mirrored in the horns; one seal per Path colour (horn, celesta, clarinet, flute) each with a motif statement; the hush (the phrase as it was, celesta/flute); the climax with the phrase in the strings over the seals.
- MUS-GRAVE-EXP: Old Hob's hum on bassoon, then on the oohs choir (his voice); the late "crooked" pizzicato chords; xylophone bones; the amused Bb-major clarinet section; the misty tremolo with the inverted motif; everybody humming at bar 52. No organ.
- MUS-GRAVE-BATTLE: the chromatic low-string creep; dry stick/click/snare percussion; woodwind echoes a beat behind each phrase end; the hum in bassoon + horns, later in violins with xylophone; trumpets' motif in B.
- MUS-ARENA-BATTLE: the fanfare with snare rolls; the broad tune in trumpet/horns; the quiet strategic B (pizz, clarinet, horn motif); the tune in the violins with the horns' motif as countermelody; the "presenting..." chord ladder over a drumroll.
- MUS-ARENA-ELITE: the violin countersubject and the cellos' canon a bar behind; the fugato through C minor and E major; the climax with the tune augmented in trombones/tuba and the trumpets' motif; the quiet oboe/clarinet/flute canon.
- MUS-SHIRO-BOSS: the accelerating wooden clappers; the sly figure in piccolo + pizzicato with feints; the grand pose climbing to high E and the chromatic slip, the bassoon apologising; the sincere G-major violin melody in the chase with the horns' motif; the second, longer slip.


## Part 7 - the four broken districts (Batch 08)

| ID | Key | Tempo | Length | Motif / zone theme (bar: form) | Sections (bar: LUFS) | LUFS / TP | Seam / onset | Preview |
|---|---|---|---|---|---|---|---|---|
| MUS-CAP-BEEF-BROKEN | Bb major | 88 BPM 4/4 | 2:00.0 (44 bars) | 16: head (muted trumpet, unfinished); 32: head (horn, slowed, unfinished) | 0 A thin: -19.2; 12 B fragments: -22.2; 24 C stalling: -20.8; 36 A' thin: -17.8; 40 thin (loop): -18.1 | -20.0 / -2.9 dB | -0.14 dB, no click | `Music Review/Batch 08/MUS-CAP-BEEF-BROKEN.mp3` |
| MUS-CAP-GOUR-BROKEN | F minor | 96 BPM 4/4 | 2:00.0 (48 bars) | 1: head (flute, unanswered); 32: head (flute, fading); 45: head (flute, unanswered) | 0 rift: -22.7; 8 broken theme: -17.8; 24 hollow recipe: -23.9; 36 broken theme again: -19.3; 44 rift again: -20.8 | -20.0 / -3.9 dB | -0.09 dB, no click | `Music Review/Batch 08/MUS-CAP-GOUR-BROKEN.mp3` |
| MUS-CAP-NECRO-BROKEN | C minor | 80 BPM 3/4 | 1:57.0 (52 bars) | 21: head (clarinet, cut off) | 0 stall: -23.8; 4 A thin theme: -20.1; 20 B interrupted: -22.0; 36 C the clerk returns: -17.2; 48 stall: -24.1 | -20.0 / -5.4 dB | +0.91 dB, no click | `Music Review/Batch 08/MUS-CAP-NECRO-BROKEN.mp3` |
| MUS-CAP-REF-BROKEN | E minor | 132 BPM 6/8 | 1:49.1 (80 bars) | 40: stated (flute, drifting, unresolved); 66: head (flute, unanswered) | 0 clutter: -25.1; 8 A thin theme: -18.2; 24 B holes: -20.1; 40 flute drift: -17.5; 48 A' thinner: -19.8; 64 clutter, glimmer: -21.3; 72 clutter again: -25.4 | -20.0 / -6.3 dB | -0.03 dB, no click | `Music Review/Batch 08/MUS-CAP-REF-BROKEN.mp3` |

Part 7 also covers the description rewrite (done with Part 0). The sour voice is now ~15 cents flat (BEEF shadow horn, GOUR clarinet,
NECRO second celesta, REF lead fiddle, whose bar-48 dip went from 30 to 18 cents).

### Listen for (Part 7)

- All four: the out-of-tune voice should now read as worn and sad rather than wrong; if it no longer reads as broken at all, say "more".

## Checks run

- GUT audio group (`-gconfig= -gdir=res://tests/audio`) after every part: 90/90 (Part 4 first showed 89/90 - the story hand-back test assumed
  MEM-01 lasted 64 s; it now reads the length from the registry).
- Music smoke after Part 1 + 7: OK (forest -> town -> graveyard -> shop -> battle -> zone -> dungeon -> boss -> freed -> Capital, including
  CAP-OUT-EXP, CREASE, CAP-FACADE-EXP, CAP-CORRECTION and the restored districts; worst crossfade step 0.00 dB).
- Director tests cover the Lab, the vault (both boss duels), the tunnels, Primm phases, story nodes, shops and quiz screens.
