# Music Pass 1 - orchestral Batches 1-2 (Oct 31 2026)

Fifteen new orchestral tracks in the MUS-TOWN v04 sound, written as Python scores (`tools/music/scores/<ID>.py`), rendered with FluidSynth +
FluidR3_GM, and now in the game. Toolchain: `docs/audio/music_toolchain.md`. Writing rules: `docs/audio/score_bible.md`.

**Previews:** `G:\My Drive\Card Game Art\Music Review\Batch 01\` and `\Batch 02\` (MP3 named by ID; each plays the loop once and then 15 s
past the loop point so you can hear the seam).
**Old files:** `G:\My Drive\Card Game Art\Superseded\Music_v01\` (the 15 replaced OGGs plus the Drive's original `registry.json` and
`dungeon_battle_aliases.json`).
**Source of truth for a later re-render:** `tools/music/midi/<ID>.mid` (multi-track, named tracks, section markers).

## Measured results

LUFS = integrated loudness of the delivered OGG; TP = true peak; seam = level of the last second vs the first second (limit 1.5 dB) and the
sample step across the loop point (no click anywhere). Section LUFS show the loudness arc. Motif forms are logged by the scores themselves
(the Lullaby notes are listed too, marked "story theme").

### Batch 01

| ID | Key | Tempo | Length | Motif (bar: form) | Sections (bar: LUFS) | LUFS / TP | Seam | Preview |
|---|---|---|---|---|---|---|---|---|
| MUS-TITLE | D minor | 76 BPM 4/4 | 2:31.6 (48 bars) | 0: head, incomplete (lone horn); 4: stated (horns); 12: stated (tutti strings 8va + trumpet); 20: head in sequence (horn calls); 35: lullaby head (D A F, cut off) - story theme, not the motif; 36: stated (climax, trumpets + strings 15ma); 36: augmented (trombones, under the tune); 46: head, incomplete (lone horn) | 0 intro: -27.9; 4 A: -22.3; 12 A' tutti: -20.3; 20 B adventure: -22.6; 28 C oboe: -26.0; 36 climax: -14.7; 44 outro: -26.1 | -20.0 / -3.5 dB | -0.55 dB, no click | `Music Review/Batch 01/MUS-TITLE.mp3` |
| MUS-FOREST | A minor | 78 BPM 6/8 | 2:09.2 (56 bars) | 2: head, alone (flute); 8: tail (clarinet); 10: head (flute) answered; 16: stated whole, softly (oboe); 24: head on the 5th, walking (flute + clarinet in thirds); 32: stated low (solo cello); 37: lullaby glimmer (A E C, three notes, far away) - story theme; 40: stated (strings) | 0 night: -26.4; 8 fragments: -20.9; 16 warmth: -18.2; 24 the road: -17.0; 32 dark cello: -23.4; 40 warmth': -18.3; 48 night again: -27.1 | -20.0 / -5.5 dB | -1.38 dB, no click | `Music Review/Batch 01/MUS-FOREST.mp3` |
| MUS-TUT-EXP | E minor | 66 BPM 4/4 | 2:10.9 (36 bars) | 2: head (pan flute), left hanging; 8: stated (pan flute); 16: augmented (far horn, ancient); 24: tail (cello); 29: lullaby glimmer (E B G, three notes) - story theme | 0 drone: -26.2; 8 motif: -18.8; 16 ancient court: -18.4; 24 echoes: -20.1; 32 drone again: -26.8 | -20.0 / -6.6 dB | +0.04 dB, no click | `Music Review/Batch 01/MUS-TUT-EXP.mp3` |
| MUS-TUT-BATTLE | E minor | 124 BPM 4/4 | 2:03.9 (64 bars) | 4: stated (horns); 21: head (horn), suspense; 25: head (horn), suspense; 28: stated (trumpets + horns); 45: head in G major (trumpet answer); 49: head (trumpet answer); 52: stated (horns); 52: inverted (trombones, counter) | 0 ostinato: -22.8; 4 A horns: -19.4; 20 B suspense: -23.2; 28 A' brass: -19.2; 44 C lift: -18.4; 52 A'' inverted: -20.3; 60 ostinato: -24.0 | -20.0 / -6.7 dB | -0.16 dB, no click | `Music Review/Batch 01/MUS-TUT-BATTLE.mp3` |
| MUS-TUT-BOSS | B minor | 136 BPM 4/4 | 2:07.1 (72 bars) | 12: head, small (celesta + harp); 14: head, small (celesta + harp); 16: head, small (celesta + harp); 29: lullaby head (B F# D) - recognition, story theme; 31: augmented (strings), dignified answer; 36: stated (trumpets) against the stone theme; 40: stated (trumpets), again; 44: stated (climax tune: trumpets, horns, violins 8va); 52: tail held above (strings) | 0 stone drums: -25.8; 4 A stone theme: -21.2; 12 B royal answer: -24.6; 20 A' stone theme: -19.5; 28 C familiar scent: -25.7; 36 D challenge: -21.0; 44 climax: -14.7; 52 E approval: -19.7; 60 A'' stone theme: -20.4; 68 stone drums: -25.6 | -20.0 / -4.9 dB | +0.07 dB, no click | `Music Review/Batch 01/MUS-TUT-BOSS.mp3` |
| MUS-TOWN-BATTLE | D dorian | 132 BPM 4/4 | 2:10.9 (72 bars) | 4: stated (horns; the town tune head); 12: stated (violins 8va); 22: head (bassoon, under the B tune); 36: head tossed (hn); 37: head tossed (ob); 38: head tossed (tpt); 39: head tossed (fl); 40: head tossed (hn); 41: head tossed (cl); 42: head tossed (tpt); 44: stated (tutti: trumpets, horns, violins 8va); 52: inverted (bassoon); 56: inverted (bassoon); 60: stated (trumpets) | 0 pulse: -24.6; 4 A horns: -19.9; 12 A' strings: -18.9; 20 B clarinet: -20.4; 28 B' brass: -19.8; 36 C tossed head: -21.5; 44 A'' tutti: -16.3; 52 D strategy: -25.6; 60 A''' trumpets: -20.0; 68 pulse: -24.7 | -20.0 / -4.8 dB | -0.09 dB, no click | `Music Review/Batch 01/MUS-TOWN-BATTLE.mp3` |
| MUS-DECK | F major | 72 BPM 4/4 | 2:00.0 (36 bars) | 2: head (piano), a question; 8: stated (piano), open; 12: stated in D minor (piano), open; 19: tail (celesta, a glint); 24: stated on C (piano), open; 34: head (piano), a question | 0 A chords: -23.4; 8 B question: -20.5; 16 C cello: -17.2; 24 A' chords: -20.0; 32 A again: -23.1 | -20.0 / -5.0 dB | -0.40 dB, no click | `Music Review/Batch 01/MUS-DECK.mp3` |
| MUS-MAREN | G minor | 66 BPM 3/4 | 1:27.3 (32 bars) | 0: stated (low clarinet), a question; 9: tail (english horn, answering); 13: tail (english horn, answering); 18: lullaby (G D Bb, three notes) - story theme; 20: head augmented (cello), bare; 24: stated (clarinet) with cello counter | 0 A clarinet: -18.6; 8 B cello: -21.8; 16 C bare: -25.2; 24 A' duet: -18.2 | -20.0 / -8.7 dB | +1.11 dB, no click | `Music Review/Batch 01/MUS-MAREN.mp3` |
| MUS-TOWN-FREED | D major | 92 BPM 4/4 | 2:05.2 (48 bars) | 1: head, slow (horn); 4: RESOLVED (horn; tune head); 12: RESOLVED (violins 8va); 27: head + tail glint (celesta); 36: RESOLVED (tutti; the tune ends on D); 44: RESOLVED (horn), farewell | 0 intro: -26.1; 4 A + Refusemancer: -21.8; 12 A' + Gourmand: -21.8; 20 B + Necrocrat: -21.6; 28 B' + Beefcake: -19.7; 36 all four: -15.8; 44 outro: -26.0 | -20.0 / -4.2 dB | -1.41 dB, no click | `Music Review/Batch 01/MUS-TOWN-FREED.mp3` |

### Batch 02

| ID | Key | Tempo | Length | Motif (bar: form) | Sections (bar: LUFS) | LUFS / TP | Seam | Preview |
|---|---|---|---|---|---|---|---|---|
| MUS-BEEF-EXP | Bb major | 116 BPM 4/4 | 2:12.4 (64 bars) | 1: head (horn fanfare); 4: stated (trumpet fanfare); 32: stated (horn, warm countermelody); 36: diminished (xylophone joke); 40: diminished (xylophone again); 44: stated (tutti); 61: head (horn fanfare) | 0 intro vamp: -28.2; 4 A march: -21.3; 20 B gentle: -22.4; 36 C comic: -27.9; 44 A' tutti: -16.5; 60 outro vamp: -27.5 | -20.0 / -4.7 dB | +0.07 dB, no click | `Music Review/Batch 02/MUS-BEEF-EXP.mp3` |
| MUS-BEEF-BATTLE | Bb mixolydian | 138 BPM 4/4 | 2:05.2 (72 bars) | 2: head (horns, call to arms); 4: stated (trumpets + horns); 12: stated again (strings join 8va); 20: head in sequence (horn stabs on G, Eb, C); 36: augmented (horns, under the strings); 44: augmented on Eb (horns); 52: stated (tutti); 60: augmented (trombones); 70: head (horns, call to arms) | 0 intro ostinato: -23.3; 4 A brass: -21.1; 20 B stabs: -23.9; 36 C broad: -20.2; 52 D tutti: -16.9; 68 outro ostinato: -23.0 | -20.0 / -6.3 dB | +0.63 dB, no click | `Music Review/Batch 02/MUS-BEEF-BATTLE.mp3` |
| MUS-BEEF-DUN-EXP | G minor | 108 BPM 4/4 | 2:22.2 (64 bars) | 2: head (horn, counting in); 4: stated twice (horns: rep 1, rep 2); 12: stated (trumpets, rep 3); 28: augmented (clarinet, the breath); 36: stated, climbing G - Bb - C (trumpets); 44: stated (horns + trumpets 8va); 52: stated (tutti); 62: head (horn, counting in) | 0 intro reps: -27.4; 4 A reps: -20.0; 20 B breath: -23.7; 36 C fortress: -18.4; 52 A' reps tutti: -17.2; 60 outro reps: -27.3 | -20.0 / -5.0 dB | -1.15 dB, no click | `Music Review/Batch 02/MUS-BEEF-DUN-EXP.mp3` |
| MUS-BEEF-DUN-BATTLE | C dorian | 144 BPM 4/4 | 2:13.3 (80 bars) | 2: head (horns, call); 4: stated (horns + trombones); 12: stated (trumpets, strings 8va); 20: augmented (horns, under the tremolo); 28: head augmented (horns); 40: stated (horn countermelody); 44: head (horn answer); 48: augmented (flute, the breath); 60: stated (tutti); 68: augmented (trombones); 78: head (horns, call) | 0 intro riff: -23.3; 4 A drive: -19.9; 20 B hold: -21.2; 32 C drive 2: -21.1; 48 D breath: -24.2; 60 E tutti: -16.8; 76 outro riff: -24.1 | -20.0 / -4.9 dB | -1.21 dB, no click | `Music Review/Batch 02/MUS-BEEF-DUN-BATTLE.mp3` |
| MUS-BEEF-BOSS | F minor | 126 BPM 4/4 | 2:32.4 (80 bars) | 2: inverted head (horns); 7: inverted head (horn, answering the boast); 20: inverted, stated (horns); 28: inverted, stated (trumpets, strings 8va); 52: stated (clarinet, the hero answers); 56: stated (horns: the hero fights back), then sequenced up a fourth; 60: stated (tutti, strings 8va); 66: head (horns, under the theme); 78: inverted head (horns) | 0 intro wheel: -23.9; 4 A Clench: -20.9; 20 B drive: -20.6; 36 C constriction: -23.3; 48 D deflation: -24.7; 56 E climax: -16.2; 72 wind-down: -22.9; 76 outro wheel: -23.0 | -20.0 / -4.0 dB | -0.53 dB, no click | `Music Review/Batch 02/MUS-BEEF-BOSS.mp3` |
| MUS-BEEF-FREED | Bb major | 108 BPM 4/4 | 2:22.2 (64 bars) | 1: head (horn, relaxed); 4: RESOLVED (horns, bars 4-5 and 12-13); 32: RESOLVED (horn, countermelody); 36: RESOLVED (horns); 38: RESOLVED on Eb (trumpets); 40: RESOLVED (strings); 42: RESOLVED on Eb (flute + clarinet); 44: RESOLVED (tutti, strings 8va + horns); 61: head (horn, relaxed) | 0 intro swing: -28.6; 4 A theme: -19.5; 20 B gentle: -22.9; 36 C shared: -22.3; 44 A' tutti: -17.3; 60 outro swing: -27.9 | -20.0 / -6.3 dB | +0.44 dB, no click | `Music Review/Batch 02/MUS-BEEF-FREED.mp3` |

## Listen for

What to judge in each track, and what I could not check without ears.

**Batch 01**

- **MUS-TITLE** - Does the lone horn (D A G, then nothing) read as "an incomplete royal phrase" and pull you in? Is the B section (bar 20,
  string ostinato + horn calls + snare, ~1:03) adventurous enough to make it an RPG overture rather than a town tune? The climax (bar 36,
  ~1:54) is the loudest moment in the batch (-14.7 LUFS): does it feel earned or too loud next to the quiet intro (-27.9)?
- **MUS-FOREST** - Night, lost, curious: the harp pulse skips a beat on purpose every fourth bar. Check the celesta "fireflies" are magical,
  not random plinks, and that the halo pad stays a breath under everything (it is the only synth). The road section (bar 24) is the warmest.
- **MUS-TUT-EXP** - The plucked echoes (harp/pizzicato repeating softer, 0.75 beat apart) should sound like a cave, not like a delay
  effect. The "ancient court" section (bar 16, ~0:58) with the far horn and soft voices is the royal hint; it should feel old, not grand.
- **MUS-TUT-BATTLE** - Modest and learnable: is the 3+3+2 string ostinato too busy under a first-time player reading cards? The suspense
  section (bar 20) drops the drive on purpose.
- **MUS-TUT-BOSS** - Its own track now. The Warden's stone theme (trombones + horns, B A F# | G F#) over concert bass drum and taiko should
  feel heavy and dignified, not villainous. At bar 28 (~0:49) the celesta plays the lullaby's first notes and the strings answer: that is the
  "familiar scent" recognition. At bar 52 (~1:32) the stone theme turns to D major - the Warden approving.
- **MUS-TOWN-BATTLE** - The v04 town tune as a battle: it should feel like the same town with stakes. Check it stays "controlled momentum"
  (132 BPM) and never frantic; the bar 36 section tosses the motif head between horn, oboe, trumpet, flute and clarinet.
- **MUS-DECK** - For long planning screens. Is it calm enough to read over for ten minutes? The cello section (bar 16) is the busiest
  (-17.2 LUFS vs -23 for the chords); say if you want it flatter.
- **MUS-MAREN** - Guarded kindness in 3/4, 87 s. The bare section (bar 16, ~0:44: open fifths, single piano notes, the clarinet's three
  lullaby notes) is meant for when she admits her research history. Phrases end on D or slip to E-flat so nothing resolves.
- **MUS-TOWN-FREED** - The town tune in D major with the motif resolved (D A G F# E D). Each Path takes a turn: fiddle + tin whistle
  (recorder) in A (bar 4), accordion off-beats + mandolin tremolo in A' (bar 12), celesta waltz figures + harpsichord in B (bar 20), warm
  horn/trombone chorale + soft snare in B' (bar 28), all four together at bar 36. Are the four colours audible without turning it into a
  medley, and is it warm rather than a fanfare?

**Batch 02 (Gainlands)** - all orchestral (the old music_list rows still ask for electric guitars; see the inbox).

- **MUS-BEEF-EXP** - Sunny, not military: tuba oompah and snare. The comic interlude (bar 36) has the motif on xylophone, a trombone
  "flex" heave and a piccolo trill - do the jokes land?
- **MUS-BEEF-BATTLE** - The string 8th ostinato should drive without wearing you out; the Ab sequence of the motif (bar 8) is the
  sports-anthem swagger.
- **MUS-BEEF-DUN-EXP** - The cello "rep" figure with cowbell/stick clank and a metronome click should read as a gym, not a clock. The
  breath section (bar 20, pads swelling in and out every two bars) is Flex's meditation.
- **MUS-BEEF-DUN-BATTLE** - Taiko and a moving bass riff: too busy under long turns? The tremolo hold (bar 20) and breath (bar 48) are
  the contrast.
- **MUS-BEEF-BOSS** - Chancellor Clench's own theme boasts upward (F F F Ab C Db) and sags chromatically to an unresolved E; the viola
  "wheel" ostinato turns underneath and a metronome-bell "stopwatch" (Quota) dings every two bars. Phrases shrink in the constriction
  section (bar 36) until a bassoon deflation (bar 48): funny, or an energy drop? The Crossroads motif appears inverted (Clench) and
  upright (the hero) in the climax (bar 56).
- **MUS-BEEF-FREED** - Swung (0.16 beat): judge the amount. In bar 36 each section takes the resolved motif in turn; warm, not a fanfare.

## In the game

| Where | ID | Checked by |
|---|---|---|
| Title screen | MUS-TITLE | launched the real game (`MUSIC_LOG=1 bash tools/play.sh docs/review/play_scripts/music_pass_oct31.txt`): `play MUS-TITLE` |
| Starting forest | MUS-FOREST | same run: `play MUS-FOREST`; music smoke |
| Crosspath | MUS-TOWN (v04, now imported) | same run: `play MUS-TOWN` in town (`_screenshots/play/music_pass_oct31/03_town.png`); music smoke |
| Forgotten Cave map / battles / Hollow Warden | MUS-TUT-EXP / MUS-TUT-BATTLE / **MUS-TUT-BOSS** | `tests/audio` director tests (dungeon:hollow boss -> MUS-TUT-BOSS); new `test_tut_boss_plays_its_own_file` |
| Town duels, neutral encounters | MUS-TOWN-BATTLE | director tests |
| Deck station, Codex, dungeon deck builder | MUS-DECK | director tests (overlay `music_cue()`) |
| Maren's memory conversations | MUS-MAREN | trigger row (`TownScene._play_memory`) |
| Town after all four zones are freed | MUS-TOWN-FREED | director tests |
| Gainlands / gate envoy / House of Gains map / its battles / Clench / freed Gainlands | MUS-BEEF-EXP / -BATTLE / -DUN-EXP / -DUN-BATTLE / -BOSS / -FREED | music smoke walks all but -DUN-BATTLE (director tests cover it) |

- `bash tools/run_music_smoke.sh`: **OK** (forest -> town -> graveyard -> shop -> battle -> zone -> dungeon -> boss -> zone freed -> Capital,
  worst crossfade step 0.00 dB, no clipping).
- GUT: `tests/audio` 89/89 pass; the other tests that touch music (art drop-in, lieutenants, Primm's castle, settings access, battle help,
  overlay exit, UI art warmup) 77/77 pass. The two Capital world tests were not re-run (no Capital audio changed).
- In-game files after "import audio" (Vorbis q5 re-encode): all 15 at -20.0 (+-0.1) LUFS, true peak -3.3 to -8.8 dB, exact lengths, seams
  within 1.5 dB, no clicks.

## Routing changes

- **MUS-TUT-BOSS is its own track.** Before: a compatibility alias of MUS-TUT-BATTLE (the music_list row's notes said "Compatibility
  alias - use MUS-TUT-BATTLE", which `AudioRegistry.alias_target` reads). Now: the row's notes describe it as its own track, the trigger
  row says so, `tests/audio/test_audio_registry.gd` no longer expects the alias, and the Drive's `dungeon_battle_aliases.json` and
  `registry.json` (`alias_of`) no longer list it (`python tools/music/deliver.py --own MUS-TUT-BOSS`). No other ID in the batches shared a file.
- **The Drive's `registry.json` loop records** for the 15 IDs (and MUS-TOWN) now hold the new lengths. The importer treats a recorded loop
  end that falls inside a file as an explicit loop point, so the old records would have cut, for example, the new 87 s MUS-MAREN at 61.5 s
  and MUS-TITLE 0.5 s short. `deliver.py --approve` keeps them in step from now on.
- **Boss victory stings re-cut** from the new climaxes (`node tools/cut_stings.js`): STG-WIN-TUT-BOSS from 84.7 s, STG-WIN-BEEF-BOSS from 130.5 s.
- `data/source/audio_levels.csv` re-analysed; `docs/audio/music_integration.md` regenerated: loops needing a fix went from 23 to 19 (the
  remaining ones are other zones' old tracks).

## Known limits

- FluidR3_GM is a 2008 General MIDI soundfont: brass and strings are good, solo winds and the folk instruments (fiddle, accordion, mandolin,
  recorder as tin whistle) are thinner. The `.mid` files are kept so a better library can re-render the same notes.
- The Lullaby and Primm notes were transcribed from audio by pitch tracking and may be off by a note here and there (they are only quoted
  for three notes per track in this pass).
- MUS-TOWN v04's own seam is +5.5 dB (the outro ends louder than the intro's soft start); it was not changed (inbox).
