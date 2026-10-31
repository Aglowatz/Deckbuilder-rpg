# Batch 09 - Path-ology Lab (Music Pass 3, Part 3) - composer fork C

Lab techno (LAB-EXP, LAB-BATTLE, SIPHON-BOSS): quantised, GS electronic kit (SIPHON: TR-808 kit), synth_bass2 + bass_lead detuned +8-10 c,
poly/metal pad pumped by CC11 on every beat, two saw leads 9-11 c apart, square-lead arpeggios, 32nd stutters, sweep-pad risers + snare
builds into the drops, string/brass stabs and timpani. The Lab's own riff (`scores/_fork_c.py` LAB_RIFF, A minor) is shared by all three
(transposed). SIPHON-BOSS is its own track with Siphon's own idea (SIPHON). LAB-CELL / LAB-RESCUE are orchestral story one-shots at -20 LUFS.
Helpers: `tools/music/scores/_fork_c.py` (drums, pump, roll_bass, arp, stutter, glitch, riser, snare_build, human).

| ID | Key | Tempo | Length | Motif / zone theme (bar: form) | Sections (bar: LUFS) | LUFS / TP | Seam / onset | Preview |
|---|---|---|---|---|---|---|---|---|
| MUS-LAB-EXP | A minor | 150 BPM 4/4 | 2:33.6 (96 bars) | 2: head (piano, cold, cut short); 33: glitched (square lead, breakdown); 40: glitched (saw leads, drop 1); 48: glitched an octave up (drop 1); 56: inverted (cello, human); 76: glitched high (drop 2); 86: head (brass, end of drop 2); 90: head (piano, cold, cut short) | 0 bed: -23.3; 8 A grid + cello: -20.3; 24 B breakdown: -22.7; 40 drop 1: -18.5; 56 C glitch: -20.5; 72 drop 2: -17.9; 88 bed: -23.1 | -20.1 / -5.0 dB | +0.62 dB, no click | `Music Review/Batch 09/MUS-LAB-EXP.mp3` |
| MUS-LAB-BATTLE | F# minor | 160 BPM 4/4 | 2:24.0 (96 bars) | 0: glitched (saw lead, bed); 12: stated (saw lead, high); 22: glitched answer to the D.N.A. waltz head; 26: glitched answer to the Buffet hook; 30: glitched answer to the Dump jig head; 34: glitched answer to the Gainlands brass call; 36: augmented (cello, quiet passage); 52: glitched high (drop); 60: head augmented (brass, drop); 68: stated (saw lead, end of drop); 88: inverted glitched (saw lead); 92: glitched (saw lead, bed) | 0 bed: -20.7; 4 A ostinato + riff: -19.9; 20 B Path answers: -20.7; 36 C quiet: -22.5; 52 drop: -18.4; 76 D glitch: -20.6; 92 bed: -20.7 | -20.1 / -5.8 dB | +1.10 dB, no click | `Music Review/Batch 09/MUS-LAB-BATTLE.mp3` |
| MUS-SIPHON-BOSS | C minor | 170 BPM 4/4 | 2:38.1 (112 bars) | 8: stated (cello, answering); 16: glitched (saw lead); 28: glitched (drop 1); 36: head, dissected (saw); 38: tail, spliced onto Siphon (piano); 54: augmented (horns, against Siphon); 60: stated (saw lead, climax); 70: head augmented (horns); 76: head recombined with Siphon; 80: head recombined with Siphon; 84: head recombined with Siphon; 88: inverted glitched (saw); 92: glitched (final drop); 100: head augmented (horns, final) | 0 bed: -22.3; 4 A Siphon on glass: -20.7; 20 drop 1: -19.7; 36 C dissection: -22.5; 52 climax: -18.7; 76 E recombine: -21.5; 92 final drop: -19.2; 108 bed: -22.3 | -20.1 / -5.5 dB | -0.41 dB, no click | `Music Review/Batch 09/MUS-SIPHON-BOSS.mp3` |
| MUS-LAB-CELL | E major | 66 BPM 4/4 | 70.7 s (one-shot) | 4: stated (cello, open); 13: head (horn, rising toward recovery) | 0 marks: -30.1; 4 cello: -22.7; 8 the lullaby, four notes: -24.3; 12 warmth: -17.3; 16 held: -18.0 | -20.0 / -7.0 dB | onset 8.1 ms | `Music Review/Batch 09/MUS-LAB-CELL.mp3` |
| MUS-LAB-RESCUE | A major | 80 BPM 4/4 | 77.1 s (one-shot) | 1: head (horn, the unfinished rescue phrase); 3: head (horn, again); 12: stated (cello, guilt beneath the oboe); 16: RESOLVED (violins: the rescue lands) | 0 urgency: -20.7; 6 turn: -20.9; 8 relief: -20.2; 16 answered: -18.4; 20 breath: -20.0 | -20.0 / -8.2 dB | onset 15.0 ms | `Music Review/Batch 09/MUS-LAB-RESCUE.mp3` |

All: true peak -5.0 to -8.2 dBTP, no clicks; score checks (range, low end, melody) ok.

## Listen for

- MUS-LAB-EXP: the cold glass pulse + pumped pad bed; the very human cello (humanised inside the quantised grid) against the riff; the breakdown with the lullaby's first four notes on the piano (bar 28, A E C B) chopped off by a stutter; the riser into drop 1 and the glitched saw-lead Crossroads motif; drop 2 the loudest.
- MUS-LAB-BATTLE: the 16th string ostinato interlocking with synth ticks; the B section's four Path heads as orchestral stabs (D.N.A. waltz, Buffet hook, Dump jig, a Gainlands-style brass call), each answered by the glitched motif; the kick-less quiet passage with the cello's augmented motif; the drop with timpani and hits.
- MUS-SIPHON-BOSS: Siphon's scalpel figure (C G F# G Eb D B, even 8ths) on glass + piano, later hammered by strings and brass in octaves with choir; the dissection section where the Crossroads head, the lullaby's first four notes (glass, bar 40), the Lab riff and Siphon's cells are spliced together; the horns' augmented motif against Siphon at the climax.
- MUS-LAB-CELL: the near-silent piano counting small intervals; the cello's open motif; the four lullaby notes on celesta with pauses; the warmth arriving at bar 12 and the held E add9 ending.
- MUS-LAB-RESCUE: tremolo + pulsing low strings and the horn's unfinished head (urgency); the turn to A major; clarinet then oboe; the resolved motif in the violins at bar 16; the long breathing A major chord.

## Questions

1. **LAB-CELL and the lullaby.** Its row says "state the lullaby with pauses", and it is a postgame cue (after the reveal), but the brief's
   lullaby rule lists only MEM-04, THRONE, REUNION and CREDITS for the whole melody. I kept the rule: first four notes once. Say if
   LAB-CELL may state the whole lullaby.
2. **LAB-RESCUE resolves the motif.** It is a release/rescue cue ("resolve the prologue's unfinished rescue phrase"), treated like the zone
   *-RELEASE cues. One line to make it open.
3. **Lab rows vs direction.** The LAB-EXP/BATTLE/SIPHON rows describe glass, piano, cello and natural percussion; the brief's techno
   direction wins, and the rows' colours were kept inside it (glass/crystal pulse, piano, human cello, timpani).
4. **LAB-CELL opening is quiet** (-30 LUFS for its first 15 s: solo piano + a breath of pad) by design; the cue still measures -20 overall.
