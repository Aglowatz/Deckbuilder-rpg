# Music Pass 2 - Necrocrat fork notes (Batch 03 + Batch 08 Necrocrat)

| ID | key | BPM/meter | length s | zone theme + motif placements (bars) | LUFS | seam dB (or onset ms) |
|---|---|---|---|---|---|---|
| MUS-NECRO-BATTLE | C minor | 138 3/4 | 125.22 | theme: hn+tbn 4-19, organ+vln 44-59, vln frags 61-75, hn 76-91. Motif: 1 head (horns, the call); 20 stated (horns); 23 stated (horns, sequenced up a third); 28 stated (horns + violins 8va); 42 tail (clarinet, left unfinished); 60 augmented (trombones); 74 head (horns, pushing on); 82 head (organ echo); 93 head (horns, the call) | -20.0 | +0.68 |
| MUS-NECRO-DUN-EXP | F minor | 88 3/4 | 130.91 | theme (F minor): cl 4, bsn 12 (stamped short), fragments 20-35, organ+choir 48-59. Motif: 2 head (bassoon, low); 33 tail (horn, between desks); 36 stated, slow (cello); 41 stated (clarinet, an answer that stops short); 62 head (bassoon, low) | -20.0 | -1.21 |
| MUS-NECRO-DUN-BATTLE | F minor | 146 3/4 | 157.81 | theme (F minor): hn 4-19, choir/organ 20-35, vln 52-67, brass tutti 84-99, fragments 100-115. Motif: 1 head (horns); 30 head (celesta glint); 36 stated (trombones); 39 stated (horns, up a third); 44 stated (trombones + tuba); 68 augmented (choir); 116 stated (tutti: horns, trombones, violins 8va); 125 head (horns) | -20.0 | -0.25 |
| MUS-NECRO-BOSS | C minor (harmonic) | 126 4/4 | 167.62 | own theme MORT: organ+tbn 4-19, 52, 80; DNA theme forced into 4/4: hn 20-35, vln 44-51, organ 68-75. Motif: 2 head (horns, entering the office); 36 inverted (cello); 40 inverted (horn); 48 head (horn, upright again); 60 stated (horns: the hero fights back), sequenced up a third; 86 head (horns, entering the office) | -20.0 | -0.08 |
| MUS-NECRO-FREED | C major -> Eb major | 92 3/4 | 140.87 | theme in C major: cl 4-19, vln 20-35; in Eb major: vln+organ 48-63. Motif: 1 tail resolved (celesta); 18 tail resolved (flute); 24 RESOLVED (horns, countermelody); 30 RESOLVED (horns, on G); 36 stated slow (flute, in A minor - one last question); 44 RESOLVED (flute: answered); 60 RESOLVED (horns, Eb); 69 tail resolved (celesta) | -20.0 | -0.12 |
| MUS-NECRO-RELEASE | Eb major | 72 3/4 | 73.5 (70.0 + ring) | theme in Eb major: cl 4-11, vln 12-19. Motif: 1 tail resolved (celesta); 20 RESOLVED, augmented (horn + organ) | -20.0 | onset 2.9 ms (report JSON not written: render.py onset_ok is a numpy bool) |
| MUS-WAIT-EXP | Ab major | 96 3/4 | 120.0 | theme in Ab major (waiting-room tune): piano 4-19, fl 20-35, piano 47, 52-59 (cadences sidestep). Motif: 1 head (celesta); 36 stated (clarinet, F minor - still waiting); 44 stated (flute, Ab major, open on the fifth); 61 head (celesta) | -20.0 | +1.20 |
| MUS-WAIT-BATTLE | G minor | 136 3/4 | 127.06 | theme (G minor): piano+cl 4-19, bsn/hn 26-35, fl+vln 36-51, hn+tbn 68-83, piano 84-91. Motif: 1 head (horns); 20 stated (horns); 23 stated (horns, up a third); 52 stated (clarinet, on the fifth); 60 stated (horns + violins); 93 head (horns) | -20.0 | -0.56 |
| MUS-WAIT-BOSS | Eb minor | 124 3/4 | 139.35 | own idea BETTY + desk bell: cl 4, vln 12, tbn 52, vln 60, cl 84; DNA theme Eb minor: organ+hn 20-35, 76-83; waiting tune on glock 36-51. Motif: 1 head (celesta); 28 head twice (trombones, stamping); 42 stated (clarinet, past the desk?); 48 stated (cello, lower); 68 stated (horns: the hero insists), sequenced up a third; 93 head (celesta) | -20.0 | +1.13 |
| MUS-SHOP-LEDGERBONE | C minor | 84 3/4 | 77.14 | theme: harpsichord 4-19, 28-31; completed cadence 32-35. Motif: 20 stated (bassoon, a polite question) | -20.0 | +1.08 |
| MUS-MINIGAME-NECRO | A minor | 110 3/4 | 78.55 | theme (A minor) in cells 4-19, fl 28-43 (ends on the dominant). Motif: 1 head (celesta); 20 stated (flute, curious); 45 head (celesta) | -20.0 | +1.05 |
| MUS-CAP-NECRO-BROKEN | C minor | 80 3/4 | 117.0 | theme on celesta + celesta 25 c flat, cut off: 4, 8, 13, 16, 24, 29, 33, 36, 44. Motif: 21 head (clarinet, cut off) | -20.0 | +0.92 |
| MUS-CAP-NECRO-RESTORED | C major | 96 3/4 | 112.5 | theme in C major in tune: cl+cel 4-19, vln 20-35, vln 44-55. Motif: 1 head (celesta, in tune); 36 RESOLVED (horns); 41 head (clarinet, the Capital shadow); 57 head (celesta, in tune) | -20.0 | -0.97 |

## Listen for

- **MUS-NECRO-BATTLE**: the eighth-note woodblock clock under the brass theme; the quiet bassoon/clarinet/harpsichord hand-off at bar 36 (~47 s) is the breather.
- **MUS-NECRO-DUN-EXP**: the rim-shot "stamp" that cuts the bassoon off (~39 s); pizz/harpsichord layers piling up 20-35; the cello motif that never finishes (~74 s).
- **MUS-NECRO-DUN-BATTLE**: walking bass throughout; held sections (B, E) vs active ones; brass tutti at ~1:43.
- **MUS-NECRO-BOSS**: Mortimer's stamp theme (repeated notes, half-step, exact cadence) on the organ; the waltz limping in 4/4 at ~38 s; organ+choir alone at ~1:39 ('he is sure'); hero motif vs his theme at ~1:54. Calm, not screaming.
- **MUS-NECRO-FREED**: the theme in major with the polite tick still there; resolved horn motif at ~47 s; the lift to Eb major at ~1:34.
- **MUS-NECRO-RELEASE**: resolved motif augmented in horn + organ at ~50 s, then a 4-bar held Eb chord for the last line of dialogue.
- **MUS-WAIT-EXP**: pleasant piano waltz whose cadences sidestep (Fm, Db) instead of landing; the ghostly organ is discreet (vol 60).
- **MUS-WAIT-BATTLE**: two contrasting phrases: the piano theme over the string ostinato vs held tremolo + organ with the horn motif.
- **MUS-WAIT-BOSS**: Betty's curtsying phrase and the glock desk bell 'ding' at each phrase end; the music-box middle over diminished chords (~46 s) is deliberately quiet.
- **MUS-SHOP-LEDGERBONE**: the clean Fm-G7-Cm cadence with the clarinet landing home and the little harpsichord signature at the loop end.
- **MUS-MINIGAME-NECRO**: the GM square-lead arpeggios (old computer) kept low in the mix; phrases end on E (dominant), gently unresolved.
- **MUS-CAP-NECRO-BROKEN**: the flat second celesta (beating against the first); phrases stop early; the clock skips beats. Check the detune reads as broken, not as a mistake.
- **MUS-CAP-NECRO-RESTORED**: same theme, in tune, with the celesta doubling the violins cleanly; the snare tick and the Fm/Ab colours keep a Capital edge.
