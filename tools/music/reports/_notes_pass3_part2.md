# Batch 06b - Primm + ending (Music Pass 3, Part 2)

Themes: the Primm motif (`theory.PRIMM_HEAD + PRIMM_ANSWER`), the Capital theme (`lib/capital.py`), the zone themes (`lib/zones.py`, the
Gainlands and Crosspath themes copied into `scores/_fork_b.py`), the whole lullaby (`_fork_b.LULLABY` = head + answer, the last E held one
beat longer to fill 5 bars) only in THRONE, REUNION, CREDITS; GALLERY has its first four notes once. Story/ending one-shots at -20 LUFS
(`s.lufs = -20`, as the *-RELEASE cues). Quantised (`human=QUANTISED`): PRIMM-01, -02, -BREAK, -MOTIF, and PRIMM-03's first 16 bars + outro.

| ID | key | BPM/meter | length s | theme + motif placements (bars) | LUFS | seam dB (or onset ms) |
|---|---|---|---|---|---|---|
| MUS-PRIMM-01 | C major | 128, 4/4, quantised | 127.5 | Primm head+answer in unison 0 (strings), tutti 4, 8, augmented horns 12, minor-coloured unison 36-51, tutti + low 52, 56; Capital theme A (trumpets) 20, B 28 / motif: flattened to even quarters 14 (cl), 38 (hn, cut off), 46 (cl) | -20.0 | +0.46 |
| MUS-PRIMM-02 | F major (D.N.A. F minor, Buffet F, Dump F Dorian, Gainlands Bb) | 136, 4/4 (waltz as 3-beat bars across the grid, jig as triplets), quantised | 112.9 | Primm copies: organ waltz 7, trumpet (showtune, even) 20, strings 28 (drop), fiddle jig 34, trumpet march 44, 52; calls: D.N.A. theme (cello) 4 + 13, Buffet welcome 16, hook 24, Dump jig 32 + 38, Gainlands theme 40 + 49 / motif: head (horn) 48, copied by Primm 48.5 | -20.0 | +0.96 |
| MUS-PRIMM-03 | D major | 146, 4/4 (rigid 0-15 + 64-67, human 16-63) | 111.8 | Primm unison 0 + 64, fractured 4 + 8; zone heads in D: Gainlands 16 + 36 + 49, D.N.A. (major) 20 + 40 + 57, Buffet 24 + 38 + 53, Dump 28 + 42 + 60 / motif: stated 6 (hn) + 10 (tpt), head 13, augmented bass 16, tail 26, augmented climax 32, tutti 40, compressed 44 (open on A), heads traded 48-58 | -20.0 | +0.67 |
| MUS-PRIMM-BREAK | C major | 60, 4/4, quantised | 80.0 | Primm motif in half notes on the music box 2-9, again with two wrong (raised) notes over unstable chords 10-17 / motif: head (low cello) 6 | -20.0 | +0.11 |
| MUS-PRIMM-DEFEAT | F major | 66 rubato (50-66), 4/4, one-shot | 87.6 | Primm motif human on piano 0-5, fragments 7 + 9; Path voices alone: Gainlands horn 6, Buffet clarinet 8, D.N.A. bassoon 10, Dump violin 12 / motif: stated (cello) 14, open; ends on Bbadd9 (unresolved, per the row) | -20.0 | onset 3.8 ms |
| MUS-PRIMM-MOTIF | C major | 104, 4/4, quantised, one-shot | 37.7 | the melody unchanged: music box 1-4 (sincere), strings + glock + block brass 6-9 (coercive) / motif: head (horn) 5, cut off | -20.0 | onset 2.7 ms |
| MUS-ARCHIVE | Eb major | 72 (66 at bar 8), 4/4, one-shot | 78.0 | Primm motif at half speed on piano 2-9 (free harmony), twice at tempo 10-17 (tonic/dominant, ticking, tightening), on the grid 18 / motif: tail (cello) 8 | -20.0 | onset 5.1 ms |
| MUS-GALLERY | G minor -> Bb major | 70, 3/4, one-shot | 61.7 | lullaby first four notes ONCE 4; silence where the answer would be 8-9 / motif: head (piano) 12, 15 | -20.0 | onset 4.0 ms |
| MUS-CAP-RESTORED | D major | 104, 4/4, human | 147.7 | Capital theme lifted (dotted) A horn 4, B strings 12, head (flute) 0, 41, 60, glock 22, trumpets 48; Gainlands horn 20 + 56, Buffet clarinet 24 + 50, D.N.A. (major) cello 28 + 55, Dump fiddle 32 + 54 / motif: head 33, stated (flute, open) 36, RESOLVED augmented 44, RESOLVED tutti 52 | -20.0 | +0.66 |
| MUS-THRONE | D major | 76, 4/4, one-shot | 65.0 | WHOLE lullaby flute + piano 2-6, strings + horn 7-11 with Buffet (cl) 8, D.N.A.-style bassoon 9, Dump (fl) 10, Gainlands (tpt) 10 / motif: RESOLVED augmented 12 | -20.0 | onset 3.7 ms |
| MUS-REUNION | G major | 84, 4/4, one-shot | 73.5 | WHOLE lullaby in G: clarinet 4-8, violins 13-17; punctuation: horn call 0, Buffet flourish 1, jig turn 2 + 11, D.N.A. waltz step (bsn) 9 / motif: head (fl) 9, (hn) 10, RESOLVED (horn) 18; held G 21-23 for Agnes | -20.0 | onset 3.1 ms |
| MUS-CREDITS | D major (Crosspath D Dorian, Gainlands Bb, D.N.A. C minor -> C major, Buffet F, Dump E Dorian -> E major) | 96 -> 108 -> 112 -> 128 -> 116 -> 132 -> 72 -> 88 -> 66, one-shot | 297.3 | Crosspath theme horn 4, strings 12; Gainlands 22; D.N.A. waltz clarinet 40, violins (major) 46; Buffet 54 + 62; Dump jig 72; WHOLE lullaby 98 + 103; zone heads in the finale 112-113 / motif: two halves (fl) 0, Crosspath head 4, head 38, tail 52, stated 80, head 82, inverted 84, tail 86, augmented 88, RESOLVED augmented 108, RESOLVED tutti 116, RESOLVED (fl) 120 | -20.0 | onset 4.5 ms |

All: true peak -3.4 to -7.3 dBTP; score checks (range, low end, melody) ok; the 12 rendered together pass the key+tempo uniqueness check.

## Listen for

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

## Questions

1. Story/ending one-shots (DEFEAT, MOTIF, ARCHIVE, GALLERY, THRONE, REUNION, CREDITS) are at -20 LUFS like the *-RELEASE cues, not the brief's -17 one-shot target.
2. MUS-PRIMM-DEFEAT ends unresolved (a held IV chord) because its row asks for "a quiet unresolved human cadence"; the brief allowed the resolved motif there. Say if you want it resolved.
3. MUS-PRIMM-03 keeps the motif open and returns to the rigid grid at the loop point; if the duel's last phase should never go back to the grid, the outro can be made human (seam would need re-checking).
4. The whole lullaby is the transcribed head + answer with its last note held one beat longer (to fill five bars); its harmonisation (Dm A Em7 Dm C G A) is mine.
5. MUS-CREDITS uses the freed (major) forms of the D.N.A. and Dump themes in their second halves; MUS-PRIMM-MOTIF gained a quiet three-note Crossroads head between its two statements (the melody itself is unchanged).
