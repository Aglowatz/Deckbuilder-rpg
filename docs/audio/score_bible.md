# Score bible - The Wayward Path

Music Pass 1 (Oct 31 2026). The rules every orchestral score follows. The house sound is **MUS-TOWN v04** (`tools/music/scores/MUS-TOWN.py`):
a real orchestra seated and mixed the same way in every track, a melody that is always clearly on top, harmony that moves, and sections that
build and breathe. Toolchain and commands: `docs/audio/music_toolchain.md`. Per-track results: `docs/audio/music_pass_oct31.md`.
Each score also reads its row in `data/source/music_list.csv` (mood, description, related motifs, notes) before a note is written.

## 1. The Crossroads motif - in every track

```
D4  A4  G4  F4    E4  A4          scale degrees 1 5 4 3 2 5 of the home key
q   e   e   dq    e   dh          7 beats: a rising fifth, a step back, a falling line that turns up again - a question
```

`theory.motif(tonic, mode)` places it in any key **by scale degree**, so a major key gets a major third (Bb F Eb D C F in Bb major).

| Form | Helper | Use |
|---|---|---|
| Stated | `motif(...)` | the full six notes as a tune: titles, A sections, climaxes |
| Fragment | `motif_head` (D A G) / `motif_tail` (F E A) | answers, transitions, battle stabs, under dialogue |
| Augmented | `augment(motif(...), 2)` | brass chorales, bass lines, boss climaxes, slow string pads |
| Inverted | `motif(..., inverted=True)` | villains, corrupted places (the question turned upside down) |
| Countermelody | any form in a second voice under another tune | town, freed areas |
| **Resolved** | `motif(..., resolved=True)` / `motif_tail(..., resolved=True)` | last note falls to the tonic (D A G F E **D**): the question answered. **ONLY in FREED / restored / homecoming tracks.** Everywhere else the motif ends open. |

Every `s.motif(...)` call is logged, and the report lists where the motif appears in each track.

## 2. Story themes (stay as they are)

The Lullaby and Primm's theme are **story themes**, not the Crossroads motif. Their masters are audio only; the notes below were transcribed
by pitch tracking on Oct 31 (`theory.LULLABY_HEAD`, `LULLABY_ANSWER`, `PRIMM_HEAD`, `PRIMM_ANSWER`) - approximate, confirm by ear.

- **Lullaby** (`MUS-LULLABY`, Concordia): D4 A4 F4 E4 A4 E4 - G4 E4 D4 F4 A4 F4 C5 G4 B4 A4 E4. It opens with the same rising fifth as the
  Crossroads motif: the motif is the lullaby's child, which is why the hero's tune feels like a half-remembered song. **Never state the
  whole lullaby before the story reveals it** (music_list, MUS-TITLE notes): before the memories, use at most its first four notes, once,
  quietly, and let something interrupt it.
- **Primm** (`MUS-PRIMM-MOTIF`): C4 E4 G4 C5 B4 A4 G4 D4 | C4 F4 A4 C5 D5 C5 B4 G4 - every note the same length, a too-perfect pulse.
  Capital and Primm cues only (none in Batches 1-2).

## 3. Path palettes

Programs are FluidR3_GM names from `tools/music/lib/instruments.py`.

| Path | Instruments (GM/GS) | Style |
|---|---|---|
| Beefcake | `brass`, `horn`, `trumpet`, `trombone`, `tuba`, orchestra-kit `snare` / `bd` / `crash`, `timpani`, `xylophone` for jokes | heroic march, Bb major / Mixolydian (and its modes: C Dorian, G Aeolian, F Mixolydian), 108-132 BPM |
| Necrocrat | `contrabass`, `cello`, `celesta`, `harpsichord`, `music_box`, `bassoon` | a music-box waltz in 3/4, minor |
| Gourmand | `accordion` / `accordion_it`, `clarinet`, `mandolin` (bank 16), `pizz`, `castanets` | a tarantella in 6/8 |
| Refusemancer | `fiddle`, `nylon`, `whistle` (or `flute` / `recorder` as the tin whistle), `ac_bass`, `tamb` | folk dance, reels and jigs |
| Capital | orchestra-kit `snare`, `harpsichord`, `trumpet` + `trombone` in rigid block chords | stiff, polished, on the grid (humanising turned down) |
| Core (home, cave, story) | `strings`, `slow_strings`, `cello`, `contrabass`, `horn`, `harp`, `flute`, `oboe`, `clarinet`, `timpani` | the v04 orchestra |

## 4. Category rules

| Category | Length | Shape |
|---|---|---|
| Exploration | 2:00-2:45 loop | at least 2 contrasting sections, one of them a gentle B section |
| Battle | 1:45-2:30 loop, 120-150 BPM | a driving string/timpani ostinato under the motif in the brass; sections alternate tension and drive |
| Boss | loop | heavier than its battle; its **own villain idea** plus Crossroads fragments; one big climax |
| Freed | loop | the zone theme reharmonised warmer, **resolved** motif, the zone palette plus the core orchestra |
| Menu / story | as its music_list row | low busyness under reading or dialogue; ends lead back to the start |

**No two tracks in a batch share the same key AND tempo** (`build.py` refuses it).

### Batch 1-2 plan

| ID | Key | BPM / meter | Palette |
|---|---|---|---|
| MUS-TITLE | D minor -> F major | 76, 4/4 | core tutti |
| MUS-FOREST | A minor (Aeolian) | 78 (dotted-q 52), 6/8 | core, night colours (celesta, harp harmonics, a breath of `halo_pad`) |
| MUS-TUT-EXP | E minor | 66, 4/4 | core, plucked echoes, breathy `pan_flute` |
| MUS-TUT-BATTLE | E minor | 124, 4/4 | core, string ostinato, horns |
| MUS-TUT-BOSS | B minor | 136, 4/4 | core + stone percussion (`concert_bd`, `taiko`), the Lullaby head as recognition |
| MUS-TOWN-BATTLE | D Dorian | 132, 4/4 | v04 orchestra, pizzicato ostinato, snare |
| MUS-DECK | F major | 72, 4/4 | `piano`, `pizz`, `cello`, `slow_strings` |
| MUS-MAREN | G minor | 66, 3/4 | `clarinet`, `bassoon`, `cello`, `piano`, `slow_strings` |
| MUS-TOWN-FREED | D major | 92, 4/4 | v04 orchestra + one solo per Path (brass/snare, celesta/harpsichord, accordion/mandolin, fiddle/whistle) |
| MUS-BEEF-EXP | Bb major | 116, 4/4 | Beefcake march |
| MUS-BEEF-BATTLE | Bb Mixolydian | 138, 4/4 | Beefcake + string/timpani ostinato |
| MUS-BEEF-DUN-EXP | G minor | 108, 4/4 | Beefcake, low strings, gym clank (`stick`, `cowbell`, woodblock) |
| MUS-BEEF-DUN-BATTLE | C Dorian | 144, 4/4 | Beefcake + low string drive |
| MUS-BEEF-BOSS | F minor | 126, 4/4 | Beefcake brass turned stern; Clench's wheel ostinato |
| MUS-BEEF-FREED | Bb major | 108, 4/4 swing | Beefcake + core, swung, warm horns |

## 5. Seating and mix (from v04)

| Section | Pan (CC10) | Reverb (CC91) | Volume (CC7) |
|---|---|---|---|
| violins / string melody | 36 (left) | 100 | 92 |
| string pad | 64 | 100 | 84 |
| cello | 82 | 90 | 88 |
| contrabass | 92 (right) | 90 | 92 |
| harp | 46 | 80 | 82 |
| horns | 78 | 95 | 92 |
| trombones / tuba | 88 | 95 | 80 |
| trumpets | 70 | 90 | 74 |
| flute 52 / oboe 60 / clarinet 72 | | 85 | 76-84 |
| timpani | 64 | 75 | 96 |
| choir | 64 | 110 | 70 |
| pizzicato | 74 | 70 | 84 |
| glockenspiel / celesta | 44 | 90 | 60 |
| orchestra kit | 64 | 80 | 90 |

- Phrase arcs on every melody (`line`), CC11 swells across 4-8 bar spans, velocity 40-60 for accompaniment, 70-95 for the tune.
- The melody owns its register: when the tune is in the strings, the winds rest or double it; when a solo wind sings, the pad drops 10.
- Timpani on downbeats of phrase starts and rolls into section changes, never on every bar outside battles.

## 6. Writing loops

- The last two bars must **land where bar 0 starts**: same texture, same dynamic (CC11 and velocity), same harmony leading into the first
  chord. Do not start bar 0 from silence or a CC11 of 40 when the outro ends at 90 (v04's own seam drops 5.5 dB for that reason).
- The renderer folds the tail onto the start, so a held chord or a timpani roll across the loop point wraps cleanly.
- One-shots end on a held chord and ring out.

## 7. Quality checklist (every track; `build.py` measures what it can)

| Check | How it is measured |
|---|---|
| Loudness arc by section: it builds and breathes | integrated LUFS per section in the report; at least ~6 LU between the quietest and loudest section in an exploration track, a clear peak section |
| Loop seam within 1.5 dB, no click | last second vs first second RMS; the sample step across the wrap vs the file's 99.9th-percentile step |
| No clipping | true peak (4x oversampled) <= -1.5 dBTP in the OGG (renders aim at -2.0) |
| Nothing piled up in the low end | no pitched note below E1; at most 2 distinct pitches under C3 at once (`checks.low_end_report`) |
| Melody always audible | the lead-melody line covers most bars and outweighs same-register accompaniment (`checks.melody_report`; rough: GM patches differ) |
| Matches its music_list row | by the composer, noted per track in the report ("listen for") |
