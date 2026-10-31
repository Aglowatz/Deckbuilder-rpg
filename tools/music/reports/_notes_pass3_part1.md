# Batch 06 - the Capital (Music Pass 3, Part 1)

Zone theme = the CAPITAL THEME (`lib/capital.py`, 16 bars built from the two Primm cells), quoted in every Capital cue except the Crease
and the tunnels' exploration/battle (the old kingdom: the Crossroads motif in full instead, plus the four zone heads). Quantised
(`human=QUANTISED`) everywhere except MUS-CREASE, MUS-TUNNEL-EXP and MUS-TUNNEL-BATTLE. No resolved motif anywhere. No organ.
Shared helpers: `scores/_fork_a.py` (theme slices `cap()`, chord transposition, beds, arps; note lengths end 0.02 beat early so a
re-struck pitch is never cut by the previous note-off).

| ID | key | BPM/meter | length s | theme + motif placements (bars) | LUFS | seam dB |
|---|---|---|---|---|---|---|
| MUS-CAP-OUT-EXP | A minor | 72, 4/4 | 146.7 | Capital theme bars 1-8 in C major on a far music box 20 c flat (the broadcast) 16-23; Capital head in A minor (cello) 28 / motif: stated (cello) 12, head (flute, distant) 24, stated twice A minor -> C (violins) 28 | -20.0 | -0.70 |
| MUS-CAP-OUT-BATTLE | E minor | 132, 4/4 | 116.4 | Capital theme in E harmonic minor (trumpets, the patrol) 20-35, music-box broadcast 36-43, trombones under the climax 48-55 / motif: head (trombones) 1, stated + turned up (horns) 4, stated G then E 12, head (flute) 26, augmented head (cello) 40, stated + sequenced (horns, violins) 48 | -20.0 | +0.29 |
| MUS-CAP-FACADE-EXP | C major | 120, 4/4 | 128.0 | Capital theme whole on music box 4-19; harpsichord bars 1-7 with the cadence missing 20-26, music box bars 9-16 28-35; music box major/minor halves 36-43; snap-back cadence 46; bars 1-8 + 13-16 47-59 / motif: head (flute, swallowed) 12, head (clarinet, breaks through the gap) 27 | -20.0 | -0.85 |
| MUS-CAP-FACADE-BATTLE | C major | 144, 4/4 | 120.0 | Capital theme music box 4-19; harpsichord major/minor halves 20-35; block-brass heads 38, 42; music box 44-51; trumpets + violins whole 52-67 / motif: head (horns) 2, stated D minor (horns) 36, stated E minor (horns + violins) 40, heads 58, 66 | -20.0 | -0.75 |
| MUS-CAP-ENFORCER | G major | 120, 4/4 | 128.0 | own idea SPOTLESS (inspection flourish) 2, 4-19, trombones in the climax 48-59; Capital theme in G trumpets + horns 20-35, G minor trombones 36-43, bars 13-16 trumpets 56 / motif: head (horn) 0, stated short (horns) 13, inverted (horns + violins) 44, stated + sequenced (horns, violins 8va) 48 | -20.0 | -0.74 |
| MUS-CREASE | F major | 84, 4/4 (human feel ON) | 137.1 | no Capital theme (the resistance's own warm clarinet tune 4-19, violins 32-39) / motif: head (clarinet) 15, stated (cello) 20, stated in F (clarinet) 22, countermelody (cello) 36; Path cameos 24-29 (horn call, pizz waltz step, glock wink, flute turn) | -20.0 | -0.43 |
| MUS-CAP-CORRECTION | A minor | 120, 4/4 | 128.0 | Capital theme bars 1-8 in A harmonic minor augmented on celesta 4-19; muted trumpets + trombone heads 20-31; trombones bars 1-8 44-51; celesta augmented 52 / motif: head (oboe, unfinished) 33, again 39 | -20.0 | +0.36 |
| MUS-CAP-RIFT | D minor | 152, 4/4 | 126.3 | D.N.A. waltz in 3-beat cells (celesta) 4-12; Capital theme minor on music box 13-19, block brass 36-43, trumpets 52-59 + 64-67, broken head 72; Buffet welcome (muted tpt) 20-29; Dump jig (violin) 26-35, 54; Gainlands theme (horns) 36-50, 60 / motif: head (horns) 0, stated twice (trumpets) 44, stated + sequenced (violins) 60, stated (cello) 68 | -20.0 | -1.17 |
| MUS-TUNNEL-EXP | D Dorian | 86, 4/4 (human feel ON) | 134.0 | four zone heads: D.N.A. clarinet 6/24, Dump jig flute 8/26, Buffet muted horn 10/28, Gainlands horn 12 / motif: stated (piano + echo) 4, stated in F (piano) 14, stated twice (cello) 16, stated twice (violins) 20, augmented chorale (horns) 24, stated three times (violins + horns, piano canon) 32 | -20.0 | -0.14 |
| MUS-TUNNEL-BATTLE | D minor | 138, 4/4 (human feel ON) | 118.3 | zone heads in phrase B: D.N.A. clarinet 20, Dump flute 22, Buffet trumpet 24, Gainlands horn 26 / motif: head (horns) 0, stated D then F (horns) 4, stated higher (trumpets + violins) 8, head (clarinet) 32, augmented (trombones + horns) 36, stated three times (tutti) 52 | -20.0 | -0.93 |
| MUS-TUNNEL-BOSS | C major | 132, 4/4 | 123.6 | own idea SPOTLESS (as ENFORCER, in C) 0, 4-19, stumble 44; Capital theme trumpets + glock 20-35 (horns 28-35), C minor trombones 48-63, head 0 / motif: head (horn) 2, head + falling third (horns) 13, stated twice (cello) 36, stated + sequenced (horns, violins) 40, C minor/Eb (horns + violins) 48, stated (trumpets) 52 | -20.0 | +0.14 |
| MUS-CASTLE-EXP | G major | 96, 3/4 (minuet) | 135.0 | minuet built from the Capital theme's Primm cells 4-19 and 36-51; Capital theme in 4/4 across the 3/4 dance (horns, the cracks) 40-50; Path ghosts in the trio: D.N.A. celesta 18 c flat 21, Dump jig 27, Buffet muted 30, Gainlands call 33 / motif: head (oboe) 9, head (oboe) 50, stated in 3/4 (oboe, exposed) 52, stated (violins) 55 | -20.0 | -0.69 |
| MUS-CASTLE-BATTLE | G minor | 140, 4/4 (gavotte) | 116.6 | Primm motif in G minor (violins L) answered by its inversion (violas R) 0-1, 4-19; Capital theme in G minor (violins, mirrored violas) 20-35; Primm line + its mirror in the trombones 48-63 / motif: head (horns) 2, stated (choir) 12, stated vs inverted (horns L vs trombones R) 36, stated vs inverted (violins vs violas) 40, stated four times (violins + trumpets) 48 | -20.0 | -0.55 |

All: true peak -2.9 to -7.3 dBTP; score checks (range, low end, melody) ok; no two share key and tempo (one build.py run).

## Listen for

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

## Questions

1. The Crease has no Capital theme at all (the brief says it is the one warm human place); it uses its own clarinet tune plus four Path cameos. Say if you want a distant Capital quote there too.
2. MUS-CAP-ENFORCER and MUS-TUNNEL-BOSS share Captain Spotless's idea (the inspection flourish), in G and in C. The enforcer track is calmer/fussier; the tunnel boss is faster and has the warm tunnel contrast section.
3. Exploration loudness arcs: FACADE-EXP spans ~3.8 LU (muzak is meant to be flat) and CASTLE-EXP ~3.9 LU (formal court) - under the bible's ~6 LU guideline on purpose.
