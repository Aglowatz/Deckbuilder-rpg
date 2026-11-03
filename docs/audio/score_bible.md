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
| Beefcake | **since Gainlands rock Nov 3: section 10** (TECHNO HARD ROCK: distorted double-tracked guitars, lead guitar, bass + synth sub, GS power kit, risers, heroic brass, saw synth, pumped pad, cowbell clank; render profile `rock`) | E minor home (freed: E major), 120-150 BPM |
| Necrocrat | **since Music Pass 2: section 8** (dark orchestral with organ, choir, low brass, ticking woodblock clock) | a dark waltz in 3/4, C minor |
| Gourmand | **since Music Pass 2: section 8** (Broadway showtune orchestra + modern EDM drop layer; no folk) | showtune, F major, ~132 |
| Refusemancer | **since Music Pass 2: section 8** (orchestral fairy folk: solo violin, nylon guitar, harp, celesta, chimes, flute/piccolo, tambourine) | jigs and reels, E Dorian |
| Capital | orchestra-kit `snare`, `harpsichord`, `trumpet` + `trombone` in rigid block chords | stiff, polished, on the grid (humanising turned down) |
| Core (home, cave, story) | `strings`, `slow_strings`, `cello`, `contrabass`, `horn`, `harp`, `flute`, `oboe`, `clarinet`, `timpani` | the v04 orchestra |

## 4. Category rules

| Category | Length | Shape |
|---|---|---|
| Exploration | 2:00-2:45 loop | at least 2 contrasting sections, one of them a gentle B section |
| Battle | 1:45-2:30 loop, 120-150 BPM | a driving string/timpani ostinato under the motif in the brass; sections alternate tension and drive (Beefcake: the riff/drop form of section 10) |
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

## 8. Zone themes and zone directions (Music Pass 2, Oct 31)

The designer listened to three zone demos and approved all three (`G:\My Drive\Card Game Art\Music_Source\zone_demos\`). They are the
zones' sound from now on and are ported note for note as the zones' exploration tracks (`MUS-NECRO-EXP`, `MUS-GOUR-EXP`, `MUS-REF-EXP`,
via `lib/song.py`, the demos' own score engine on top of `Score`). Their melodies live in `tools/music/lib/zones.py`.

| Zone (Path) | Direction | Key / meter / tempo | Palette |
|---|---|---|---|
| D.N.A. (Necrocrat) | dark orchestral **with organ**; a dark 3/4 waltz; a ticking-clock woodblock; choir; low brass. People doing a job, not horror | C minor, 3/4, 100 | church organ, strings + tremolo, cello/contrabass, pizz, bassoon, clarinet, horns, trombones, tuba, timpani, choir, celesta, harpsichord, orchestra-kit woodblock clock (76/77) |
| Endless Buffet (Gourmand) | upbeat, festive **Broadway/Disney showtune** ("Be Our Guest" energy, but always original melodies - never quote a real song) **plus modern EDM drops**: four-on-the-floor kick, claps, synth bass, pumping pad, saw lead. **No folk** | F major, 4/4, ~132 | strings, pizz, clarinet, muted trumpet, brass section, tuba oom-pah, glock, xylophone, horn, choir, piano, timpani; EDM: standard kit, synth bass, saw lead, pumped warm pad |
| Verdant Dump (Refusemancer) | **fairy folk, but orchestral**: a fast solo-violin jig, nylon guitar, piano, harp, celesta, chimes/tubular bells, flute/piccolo, tambourine. Folk instruments belong to the Dump **only** | E Dorian, 6/8 (dotted q = 116; written q = 174) | solo violin, strings, flute, piccolo, nylon guitar, piano, harp, celesta, tubular bells, glock, pizz, cello, contrabass, horn, timpani, tambourine/triangle |

### Rules

- **Each zone has its OWN ZONE THEME** - the demo's main melody (`zones.DNA_THEME`, `zones.BUFFET_THEME` (+ the drop `BUFFET_HOOK`),
  `zones.DUMP_THEME`). It appears in **every** cue of that zone and of its Path's related cues (battle, dungeon, boss, freed, release,
  side dungeon, shop, minigame, Capital district): whole, a phrase, augmented, in another key or mode, corrupted, mirrored. The
  **Crossroads motif guests** in each (at least one logged statement or fragment), as section 1 describes.
- **FREED tracks take the zone theme to major** (or brighter: Dorian -> major, minor -> relative/parallel major, `zones.to_mode`) **with
  the motif resolved** (section 1). Resolved motif still only in FREED / restored / release / homecoming cues - and in **STG-VICTORY**,
  the single exception outside them (its last notes are the motif's resolved tail: the battle lands home).
- Bosses: their own villain idea + the zone theme corrupted (minor, inverted, warped, imitating) + Crossroads fragments.
- Capital districts: "broken" = the zone theme played thin, detuned (a second
  voice 20-30 cents flat via `Score.detune`, a pitch bend) or interrupted (phrases cut mid-bar); "restored" = the same theme full and in tune.
- Stingers: one-shots at -17 LUFS that **start instantly** (no silence at the front: first sound within 20 ms, `build.py` reports
  `onset_ms`), ring out, no loop fold. STG-ZONE-* use their zone's theme and palette (NECRO organ, GOUR a showtune button ending with a
  kick, REF fiddle + chimes, BEEF brass). Pack reveals rise in grandeur common -> rare -> legend.

### Batch 3-8 key / tempo plan (no two tracks in a batch share key AND tempo)

| ID | Key | BPM / meter | Notes |
|---|---|---|---|
| MUS-NECRO-EXP | C minor | 100, 3/4 | the approved demo |
| MUS-NECRO-BATTLE | C minor | 138, 3/4 | the waltz driven: a fast scherzo-waltz, theme in brass, clock ticking 8ths |
| MUS-NECRO-DUN-EXP | F minor | 88, 3/4 | Hall of Final Approvals: desk-to-desk phrases, layered pizz, organ |
| MUS-NECRO-DUN-BATTLE | F minor | 146, 3/4 | deeper percussion, moving bass |
| MUS-NECRO-BOSS | C minor (harmonic) | 126, 4/4 | Mortimer Grimsby's own theme on organ + low brass; the waltz theme forced into 4/4 (corrupted) |
| MUS-NECRO-FREED | C major -> Eb major | 92, 3/4 | warm organ, the theme in major, resolved motif |
| MUS-GOUR-EXP | F major | 132, 4/4 | the approved demo |
| MUS-GOUR-BATTLE | Bb major | 142, 4/4 | showtune at battle tempo with an EDM drop section |
| MUS-GOUR-DUN-EXP | D minor | 112, 4/4 | Test Kitchen: clockwork ostinato, cold harmony, the theme impersonal |
| MUS-GOUR-DUN-BATTLE | G minor | 140, 4/4 | assembly-line drive, deeper percussion |
| MUS-GOUR-BOSS | F minor | 128, 4/4 | The Doppelganger: the Buffet theme warped and imitating (canon), a mirror (inversion) of the hero's motif |
| MUS-GOUR-FREED | F major -> G major | 124, 4/4 | the full festive finale, a real feast |
| MUS-REF-EXP | E Dorian | dq 116 (q 174), 6/8 | the approved demo |
| MUS-REF-BATTLE | A Dorian | 144, 4/4 (reel) | fast reel, driving fiddle |
| MUS-REF-DUN-EXP | B minor | q 120, 6/8 | The Rotheart: cello drone, fairy glimmers fading |
| MUS-REF-DUN-BATTLE | E minor | q 186 (dq 124), 6/8 | tangled ostinatos, deeper percussion |
| MUS-REF-BOSS | E minor (harmonic) | q 156 (dq 104), 6/8 | Compostella: dark fairy tale, the jig in minor, roots and decay |
| MUS-REF-FREED | E major | q 168 (dq 112), 6/8 | spring returning: chimes, harp, the jig in major, resolved motif |
| Batch 07 stingers | per cue | | STG-VICTORY Bb major (brass + strings over a timpani roll, cymbal, held major chord; the motif's resolved tail) |
| Batch 08 Path extras | per Path, keys chosen in each score and listed in `docs/audio/music_pass2_oct31.md` | | Necrocrat / Gourmand / Refusemancer extras use their zone palette and theme; Beefcake extras match the Gainlands tracks (section 3) |

## 9. Music Pass 3 directions (Oct 31): the Capital, Primm, the Lab, story, shops, side areas

The designer's directions (design sheet, Music tab, column J and rows 147-157), turned into rules. Themes: `tools/music/lib/capital.py`
(`CAPITAL_THEME`, `CAPITAL_PROG`, `rudiment`, `stumble`, `QUANTISED`), `theory.PRIMM_HEAD/ANSWER`, `theory.LULLABY_HEAD/ANSWER`, `lib/zones.py`.
Synth programs and GS drum kits for the Lab are in `lib/instruments.py` (saw/square leads, synth bass, poly/metal pads, FX, `electro_kit`).

### The Capital (Pathordia's capital under Primm)

- **Creepy-perfect orchestral with a hint of unease.** Bright C major, rigid 120 BPM as the home tempo, **quantised: `Score(..., human=QUANTISED)`**
  (human feel OFF). Music box, harpsichord, glockenspiel, snare rudiments (`capital.rudiment`), block brass chords, a too-wide-smile cheer.
- **Imperfect bursts:** sudden frantic moments (rushed strings, a wrong chord, a stumble, a cluster; `capital.stumble`) that snap straight back to
  perfect on the next downbeat, as if nothing happened.
- **The Primm motif** (even note lengths) is the city's voice. **The CAPITAL THEME** (`capital.CAPITAL_THEME`, 16 bars, built from the two Primm
  cells) is the zone theme of the Capital: it appears in every Capital cue (whole, a phrase, augmented, in minor, on a music box, glitched).
- **The Crossroads motif keeps trying to break through** - fragments that get cut off or swallowed by the anthem.
- **Human feel returns ONLY in MUS-CAP-RESTORED** (and PRIMM-03's unravelling). Exceptions with their own rules:
  - **MUS-CREASE** (the resistance) is the one warm human place: chamber piano + clarinet + a few strings, human feel on, the Crossroads motif gentle.
  - **MUS-TUNNEL-EXP / -BATTLE**: the old kingdom under the city: warmer, echoing, the Crossroads motif in full. **MUS-TUNNEL-BOSS** is Captain
    Spotless: the rigid Capital march, quantised (his own track, no longer an alias).
- **MUS-CAP-OUT-***: depleted outskirts. Sparse, wind-worn strings; the Primm motif far off like a broadcast (a thin music box / glock with heavy reverb).
- **MUS-CAP-FACADE-***: music-box muzak, a low dread pedal, occasional minor slips; the battle version is the same surface under strain.
- **MUS-CAP-ENFORCER**: a fussy snare-rudiment march. **MUS-CAP-CORRECTION**: a metronome, clinical high strings.
- **MUS-CAP-RIFT**: the four zone themes glitching over each other (D.N.A. waltz, Buffet showtune, Dump jig, Gainlands march), the Capital theme
  trying to hold them on the grid.
- **MUS-CASTLE-***: an elegant Baroque court - strings, harpsichord, choir, minuet (3/4) / gavotte. **No organ** (organ is D.N.A.'s). In battle (the
  mirror parquet) the hero's motif is mirrored (inverted) against Primm's.

### Primm, a tragic villain

| Cue | Rule |
|---|---|
| MUS-PRIMM-01 Standardization | the whole orchestra in unison/octaves on the Primm motif, machine-like, quantised |
| MUS-PRIMM-02 Reflection | the Primm theme imitating each zone style in turn (D.N.A. organ waltz, Buffet showtune/EDM, Dump fiddle jig, Gainlands march), each slightly wrong |
| MUS-PRIMM-03 Unraveling | the rigidity breaks, human feel returns, the four zone themes combine over the Crossroads motif; heroic climax (motif still open: it loops) |
| MUS-PRIMM-BREAK | sparse; the Primm motif on a slowed music box |
| MUS-ARCHIVE, MUS-PRIMM-DEFEAT | the Primm motif tender and human: the sincere reformer he once was (rubato, warm strings, piano) |
| MUS-PRIMM-MOTIF | motif master: keep the existing melody (`PRIMM_HEAD` + `PRIMM_ANSWER`), re-orchestrated in the Capital palette |

### The Path-ology Lab

- **MUS-LAB-EXP, MUS-LAB-BATTLE, MUS-SIPHON-BOSS**: fast techno/EDM action with big-budget sci-fi combat energy, but **original** (no quotes),
  150-170 BPM. Driving kick, distorted/saw synth bass, arpeggiators, glitch stutters (rapid retriggered notes), risers and drops, sidechain-pumped
  pads (CC11 ducking on every beat), plus cold orchestral stabs (strings/brass hits). Clinical and relentless. GM synth programs + one drum kit;
  layer and detune (`Score.detune`) to fatten them. The Crossroads motif appears as a glitched synth lead. SIPHON-BOSS is its own track.
- **Lab story beats (MUS-LAB-CELL, MUS-LAB-RESCUE) are NOT techno:** orchestral, tender, hopeful.

### Story cues

- MUS-LULLABY, MUS-MEM-01..04, MUS-THRONE, MUS-REUNION, MUS-GALLERY, MUS-QUEST-PELL/ROLLO/MARLO/FERN, MUS-CREDITS and the Lab beats: orchestral
  and **hopeful**, lullaby-like. Gentle strings, harp, celesta, solo woodwinds, soft horns; warm and tender, never grim for long. MEM-02/03 may be
  darker but each **ends with hope**.
- The Lullaby and the Crossroads motif carry them (`theory.LULLABY_*`, pitch-tracked, approximate). **MUS-LULLABY is the motif master: keep its
  melody, re-orchestrate only.**
- **The lullaby rule:** the WHOLE lullaby (head + answer) may be stated **only** in MUS-MEM-04, MUS-THRONE, MUS-REUNION and MUS-CREDITS (after the
  reveal) - and in MUS-LULLABY itself. Everywhere else: at most its first four notes, once.
- **MUS-CREDITS**: the Crosspath theme -> each zone theme in turn (Gainlands, D.N.A., Buffet, Dump) -> the Lullaby -> the Crossroads motif resolved
  as a grand finale.
- The Capital quest cues nod to their Path's zone theme (Pell = D.N.A., Rollo = Gainlands, Marlo = Buffet, Fern = Dump) inside the story palette.

### Shops and the quiz: mystic and fun

Pizzicato, celesta/music box, harp glissandi, character woodwinds (clarinet, bassoon, oboe), light percussion; a little magical, a little cheeky,
**calm enough to browse for minutes** (60-90 s loops, low busyness). Each shopkeeper's twist: Sable sly velvet, Tonic bubbly chaos, Beetsworth
stiff-but-odd, Threadwell runway strut, Fenwick collector's wonder, Alembic calm mystic blending (ALEMBIC-POST adds more colours), Figsly sly
back-alley, Bellows showman at rest. MUS-QUIZ joins them.

### Side areas (core orchestra + their own colour)

MUS-VAULT-EXP / -BATTLE / -BOSS: ancient, royal clues (the boss is its own track; at most the lullaby's first four notes, once). MUS-GRAVE-EXP:
creepy-cheerful, Old Hob's hum (bassoon / oohs); MUS-GRAVE-BATTLE. MUS-ARENA-BATTLE / -ELITE: showbiz spectacle (Grand Bellows). MUS-SHIRO-BOSS:
a theatrical trickster.

### Other answers (Pass 2 inbox)

- Zone-freed stingers keep the resolved ending (approved).
- "Broken" Capital districts: the sour voice goes from ~25 to **~15 cents** flat (re-rendered in Part 7).
- MUS-NECRO-BOSS's limping waltz stays as it is.

### Pass 3 key / tempo plan (57 cues; no two related cues share key AND tempo)

| Batch | ID | Key | BPM / meter | Kind |
|---|---|---|---|---|
| 06 Capital | MUS-CAP-OUT-EXP | A minor | 72, 4/4 | loop |
| 06 | MUS-CAP-OUT-BATTLE | E minor | 132, 4/4 | loop |
| 06 | MUS-CAP-FACADE-EXP | C major | 120, 4/4 (the Capital home tempo) | loop |
| 06 | MUS-CAP-FACADE-BATTLE | C major | 144, 4/4 | loop |
| 06 | MUS-CAP-ENFORCER | G major | 120, 4/4 | loop (boss) |
| 06 | MUS-CREASE | F major | 84, 4/4 (human feel) | loop |
| 06 | MUS-CAP-CORRECTION | A minor | 120, 4/4 | loop |
| 06 | MUS-CAP-RIFT | D minor | 152, 4/4 | loop |
| 06 | MUS-TUNNEL-EXP | D dorian | 86, 4/4 | loop |
| 06 | MUS-TUNNEL-BATTLE | D minor | 138, 4/4 | loop |
| 06 | MUS-TUNNEL-BOSS | C major | 132, 4/4 | loop (boss) |
| 06 | MUS-CASTLE-EXP | G major | 96, 3/4 (minuet) | loop |
| 06 | MUS-CASTLE-BATTLE | G minor | 140, 4/4 (gavotte) | loop |
| 06b Primm + ending | MUS-PRIMM-01 | C major | 128, 4/4 | loop (boss) |
| 06b | MUS-PRIMM-02 | F major (moves per zone style) | 136, 4/4 | loop (boss) |
| 06b | MUS-PRIMM-03 | D major | 146, 4/4 | loop (boss) |
| 06b | MUS-PRIMM-BREAK | C major | 60, 4/4 | loop |
| 06b | MUS-PRIMM-DEFEAT | F major | 66, 4/4 | one-shot |
| 06b | MUS-PRIMM-MOTIF | C major | 104, 4/4 | one-shot |
| 06b | MUS-ARCHIVE | Eb major | 72, 4/4 | one-shot |
| 06b | MUS-GALLERY | G minor -> Bb major | 70, 3/4 | one-shot |
| 06b | MUS-CAP-RESTORED | D major | 104, 4/4 (human feel) | loop |
| 06b | MUS-THRONE | D major | 76, 4/4 | one-shot |
| 06b | MUS-REUNION | G major | 84, 4/4 | one-shot |
| 06b | MUS-CREDITS | D major (travels through the zone keys) | 96, 4/4 | one-shot |
| 09 Lab | MUS-LAB-EXP | A minor | 150, 4/4 | loop |
| 09 | MUS-LAB-BATTLE | F# minor | 160, 4/4 | loop |
| 09 | MUS-SIPHON-BOSS | C minor | 170, 4/4 | loop (boss) |
| 09 | MUS-LAB-CELL | E major | 66, 4/4 | one-shot |
| 09 | MUS-LAB-RESCUE | A major | 80, 4/4 | one-shot |
| 08b Story | MUS-LULLABY | D minor | 70, 4/4 | one-shot (motif master) |
| 08b | MUS-MEM-01 | F major | 72, 4/4 | one-shot |
| 08b | MUS-MEM-02 | D minor -> F major | 60, 4/4 | one-shot |
| 08b | MUS-MEM-03 | C minor -> Eb major | 92, 4/4 | one-shot |
| 08b | MUS-MEM-04 | D major | 66, 4/4 | one-shot |
| 08b | MUS-QUEST-PELL | Ab major | 72, 3/4 | one-shot |
| 08b | MUS-QUEST-ROLLO | Bb major | 88, 4/4 | one-shot |
| 08b | MUS-QUEST-MARLO | F major | 80, 4/4 | one-shot |
| 08b | MUS-QUEST-FERN | E major | q 132, 6/8 | one-shot |
| 11 Shops | MUS-SHOP-SABLE | D minor | 92, 4/4 swing | loop |
| 11 | MUS-SHOP-TONIC | G major | 128, 4/4 | loop |
| 11 | MUS-SHOP-BEETSWORTH | C major | 108, 4/4 | loop |
| 11 | MUS-SHOP-THREADWELL | A minor | 112, 4/4 | loop |
| 11 | MUS-SHOP-FENWICK | Eb major | 84, 4/4 | loop |
| 11 | MUS-SHOP-ALEMBIC | E minor | 76, 4/4 | loop |
| 11 | MUS-SHOP-ALEMBIC-POST | E lydian | 80, 4/4 | loop |
| 11 | MUS-SHOP-FIGSLY | B minor | 96, 4/4 swing | loop |
| 11 | MUS-SHOP-BELLOWS | F major | 100, 4/4 | loop |
| 11 | MUS-QUIZ | Bb major | 116, 3/4 | loop |
| 09b Side | MUS-VAULT-EXP | F# minor | 80, 4/4 | loop |
| 09b | MUS-VAULT-BATTLE | B minor | 140, 4/4 | loop |
| 09b | MUS-VAULT-BOSS | F# minor | 128, 4/4 | loop (boss) |
| 09b | MUS-GRAVE-EXP | G minor | 96, 3/4 | loop |
| 09b | MUS-GRAVE-BATTLE | Bb minor | 144, 4/4 | loop |
| 09b | MUS-ARENA-BATTLE | Eb major | 140, 4/4 | loop |
| 09b | MUS-ARENA-ELITE | Ab major | 148, 4/4 | loop (boss) |
| 09b | MUS-SHIRO-BOSS | E minor | 152, 4/4 | loop (boss) |

## 10. The Gainlands is TECHNO HARD ROCK (Gainlands rock Nov 3)

Designer decision, Nov 3: the original music_list rows asked for electric guitars; Music Pass 1 made the Beefcake cues orchestral by
mistake. The approved demo (`Music_Source/zone_demos/ZONE-GAINLANDS_demo_score.py` + `render_rock.py`, "Gainlands battle demo (techno hard
rock).mp3") is the base and the inspiration for the **whole Beefcake set**. It is `MUS-BEEF-BATTLE`, ported note for note.
Section 3's old Beefcake row (orchestral march, Bb) and the Batch 1-2 Beefcake keys are superseded; the Batch 1-2 table stays as history.

### Palette (`tools/music/lib/rock.py`, `band()` seats it)

| Part | GM/GS | Role |
|---|---|---|
| `gtrL` / `gtrR` | 30 distortion guitar, panned 20 / 108, 12-15 ms apart | double-tracked rhythm: gallop (`GALLOP`) and straight 8th chugs (`STRAIGHT`), 16th `MACHINE` chugs for the House of Gains; power chords (root-fifth-octave) on the accents, palm-muted root+fifth between |
| `lead` | 29 overdriven guitar, centre | the Crossroads motif and the Gainlands answer, licks |
| `bass` | 33 finger bass | 8ths with octave pops, gallop, or held roots in breakdowns |
| `sub` | 38 synth bass | drops only: off-beat octave 8ths (`subdrop`) |
| `kit` | GS power kit (bank 128 / 16), channel 10 | `rock_beat` (fills on toms), `four_floor` in drops, `double_kick` for the heaviest cues, `snare_roll` builds, `crash` on drops, `clank` = gym cowbell |
| `brass` | 61 brass section | heroic stabs on the hits (`BRASS_HITS`), chorales in breakdowns - the Beefcake link |
| `saw` / `pad` | 81 saw lead / 89 warm pad | intro arps and drop stabs; the pad pumped (`Song.pump`) in drops |
| `timp` | 47 timpani | 16th rolls under builds |
| risers | `rock.riser(s, bar, bars)` | white-noise risers before drops (render.add_risers) |

### Render profile `rock` (render.rock_chain; Score.profile = 'rock', set by band())

The demo's chain: the guitar stem (`Score.stem`, the `GTR` channels) renders on its own (synth reverb 0.25) through `amp_sim` (120 Hz
high-pass, tanh drive x7, 5.2 kHz cabinet low-pass, a slight 700-1600 Hz scoop); the rest renders with synth reverb 0.45 (room 0.6); mix
0.9 / 0.85; noise risers; a shorter, brighter hall (1.6 s) and light bus saturation (`glue`). Then the usual loop fold, -20 LUFS, peak limit.
`Score.stack_drums` (rock) keeps simultaneous same-note drum hits as two voices, as the demo stacked its crash-bar kicks. Test:
`python -m unittest tools.music.tests.test_rock_render`.

### Themes (all in `lib/rock.py`)

- Home key **E minor**, the progression **i - VI - VII - V (E C D B)** in power chords. FREED / restored: **E major**.
- **The Crossroads motif on lead guitar: E B A G F# B** (`MOTIF`, q e e dq e dh); `MOTIF_RESOLVED` (E B A G# F# **E**) only in FREED /
  restored / release cues (section 1's rule still holds).
- **The Gainlands theme** = the demo's riff (the gallop chug over E C D B) + its answer phrase (`ANSWER`, `ANSWER_TAG`; `ANSWER_MAJOR`
  for E major) + the breakdown lick (`LICK`). Every Beefcake cue carries the riff or the answer (whole, a phrase, half-time, detuned...).
  (The old orchestral Gainlands march theme is still quoted by non-Beefcake cues - FOREST, DECK, CREDITS, PRIMM-02, QUEST-ROLLO... -
  untouched in this pass; see the inbox.)
- Tempo 120-150 BPM. Form for the action cues: riff -> theme -> build -> drop -> breakdown -> build -> drop 2 -> outro (the demo).

### Dynamics (rock is dense)

Keep a real arc: builds quieter than drops, breakdowns lower still; check the report's per-section LUFS (at least ~4 LU between the
quietest and loudest section in action cues, ~6 LU in exploration). Intros that are an arp alone sit 13 LU low through this chain: give
them a held power chord, the sub and a pad (MUS-BEEF-BATTLE's loop fix), and give the outro the same bed so the seam matches.

### Set plan (key / tempo; no two cues of the set share both)

| ID | Key | BPM | Job |
|---|---|---|---|
| MUS-BEEF-BATTLE | E minor | 140 | the approved demo |
| MUS-BEEF-EXP | E minor | 120 | lighter rock groove for walking around: the riff and the theme, no huge drop, room to breathe, long-play friendly |
| MUS-BEEF-DUN-EXP | E minor | 126 | House of Gains: chugging mid-tempo machine riff, gym-machine clank, a quieter breath section for Flex |
| MUS-BEEF-DUN-BATTLE | E minor | 150 | faster and heavier than the zone battle, relentless drops |
| MUS-BEEF-BOSS | D minor (drop-D) | 136 | Chancellor Clench: his own villain riff (lower, the motif inverted), the stopwatch ding, a huge final drop, the hero's motif fighting back on lead guitar |
| MUS-BEEF-FREED | E major | 128 | triumphant arena rock, the motif RESOLVED on lead guitar, big brass, celebratory not aggressive |
| MUS-BEEF-RELEASE | E major | 100 | one-shot: starts orchestral and hopeful, then the band swells in for "true strength" |
| MUS-SWOLY-EXP | B minor | 118 | Mount Swolympus: epic mountain rock, wide and half-time |
| MUS-SWOLY-BATTLE | B minor | 146 | mountain rock in combat |
| MUS-SWOLY-BOSS | F# minor | 138 | The Ancient Spotter's own track and riff |
| MUS-MINIGAME-BEEF | A major | 132 | Chet's aerobics: 80s synth-rock workout |
| MUS-SHOP-BENCHLEY | E Dorian | 104 | the gym pro shop: still mystic and fun like the other shops, with a light rock groove |
| MUS-CAP-BEEF-BROKEN | E minor | 116 | Transit Yards: the Gainlands riff thin and detuned ~15 cents, the Capital grid underneath |
| MUS-CAP-BEEF-RESTORED | E major | 116 | the same, full and in tune; motif resolved |
| STG-ZONE-BEEF | E major | 140 | power chord + crash, resolved ending |

