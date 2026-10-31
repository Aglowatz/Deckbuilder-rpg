# Batch 11 - shops and the quiz (Music Pass 3, Part 5)

Mystic and fun: pizzicato, celesta / music box, harp glissandi, character woodwinds (clarinet, bassoon, oboe, flute), light percussion
(brushes, tambourine, castanets, woodblock); 60-90 s loops, low busyness for browsing. Human feel on (shops are not the Capital's grid).
Each keeper's twist from their music_list row. Crossroads motif logged in every track; never resolved. Shared helpers in
`scores/_fork_a.py` (plucked bass styles, brushes, harp glissando).

| ID | key | BPM/meter | length s | theme + motif placements (bars) | LUFS | seam dB |
|---|---|---|---|---|---|---|
| MUS-SHOP-SABLE | D minor | 92, 4/4 swing 0.12 | 83.5 | own sly chromatic clarinet tune 0-7, 16-23; piano answer 8-15; Crosspath tune wink (clarinet) 26 / motif: stated in its home key (piano) 24, head (flute) 28 | -20.0 | +0.64 |
| MUS-SHOP-TONIC | G major | 128, 4/4 | 75.0 | own bouncing marimba tune 4-11, xylophone 20-27; flute/clarinet argument 12-19; surprise chords Eb (2, 6), Bb (10), E7 (15) / motif: stated twice E minor then G (marimba) 28, head (clarinet) 32 | -20.0 | -1.15 |
| MUS-SHOP-BEETSWORTH | C major | 108, 4/4 | 80.0 | own serious bassoon tune 4-11, 20-27 (clarinet 8va); oboe 12-19 with a wrong C#6 at 14 "corrected" by the glock; hiccup bar 13 (no downbeat); oboe fanfares 23, 27 / motif: stated very solemnly (bassoon) 28, head (oboe) 30 | -20.0 | -0.50 |
| MUS-SHOP-THREADWELL | A minor | 112, 4/4 swing 0.08 | 77.1 | own strut (oboe) 4-11, 20-27 with flute runs and harp glissandi on each entrance; calm browsing B (clarinet + harp) 12-19 / motif: stated in strut rhythm (oboe) 28, head (clarinet) 30 | -20.0 | -1.04 |
| MUS-SHOP-FENWICK | Eb major | 84, 4/4 | 80.0 | own celesta tune 0-7, music box 10-13, flute 14-17; held-breath bars 8-9 and 18-19 (sus chord, a chime, a crystal glint) / motif: stated (celesta) 20, stated on G (flute) 22 | -20.0 | +0.34 |
| MUS-SHOP-ALEMBIC | E minor | 76, 4/4 | 75.8 | two voices: flute 0-3, clarinet 4-7, conversation 8-15 / motif: stated in thirds (flute + clarinet: blended) 16, stated in G with the flute a sixth above (clarinet) 18 | -20.0 | +0.94 |
| MUS-SHOP-ALEMBIC-POST | E Lydian | 80, 4/4 | 84.0 | three voices 0-7 (flute, oboe, clarinet), four in counterpoint 8-15 (+ cello); lullaby head (4 notes, in major) on a quiet horn 21 / motif: stated in four-part harmony (flute lead) 16 | -20.0 | +0.13 |
| MUS-SHOP-FIGSLY | B minor | 96, 4/4 swing 0.14 | 80.0 | own low-clarinet tune 0-7, 16-23; the Crease tune (MUS-CREASE) in D 8-11 / motif: stated (low clarinet, the resistance phrase) 24, head in D (piano) 26 | -20.0 | -0.63 |
| MUS-SHOP-BELLOWS | F major | 100, 4/4 | 76.8 | restrained fanfare (muted trumpet) 0-3, 12-15; calm clarinet 4-11, flute + harp 16-23 / motif: stated as a little fanfare (horn) 24, head (muted trumpet) 26 | -20.0 | -0.14 |
| MUS-QUIZ | Bb major | 116, 3/4 | 86.9 | question (flute) / answer (clarinet / bassoon) in threes 4-17, 36-49 / motif: stated in 3/4 (flute) 20, stated (cello) 24, head (flute) 34 | -20.0 | +1.02 |

All: true peak -6.4 to -9.4 dBTP; score checks (range, low end, melody) ok; no two share key and tempo (one build.py run).

## Listen for

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

## Questions

1. MUS-SHOP-ALEMBIC-POST quotes the lullaby's first four notes once (horn, quiet, bar 21, re-spelled in E major) for the "completed royal phrase"; the rule allows it, but this is a postgame shop - say if you prefer no lullaby there.
2. MUS-QUIZ is 86.9 s: its row says 90-120 s, the brief's shop/quiz rule says 60-90 s; I followed the brief.
3. Crosspath shops quote MUS-TOWN only lightly (Sable's two-bar wink); the others have their own tunes. MUS-SHOP-FIGSLY (in the Crease) quotes MUS-CREASE.
