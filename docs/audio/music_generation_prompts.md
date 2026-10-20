# Music generation prompts

Overnight Oct 19-20, Part 7. Ready-to-paste prompts for a music generator, for Crosspath's hub tracks (first) and for every track rated 3 or
lower in `docs/audio/music_audit.md` "Oct 19 fixes" (no track is rated 1-2 after the fixes; these are the weakest). Save each result in the
Drive folder Approved_Audio **as the file ID given** (for example `MUS-TOWN_v03.ogg` or `.wav`, 48 kHz stereo) and run "import audio": the
drop-in pipeline trims silence, sets the loop, normalises to -20 LUFS and encodes OGG (`docs/audio/music_integration.md`, "Drop-in pipeline").
Then listen to the wrap two or three times before marking it approved.

Paste the **style lock** before every prompt. The style follows `data/source/music_list.csv` (the designer's sheet; it wins over the older
`docs/audio/music_brief.md` where they differ).

**Style lock:** Natural instruments lead, with subtle synth; mysterious and adventurous; developed melody, richer harmony and contrasting
sections. A storybook fantasy RPG with a comic streak: warm, characterful, never grim for long. Instrumental, no vocals. Seamless loop: the
last bar leads straight back into the first (same tempo, key and energy at both ends, no fade-out, no reverb tail cut off, no silence at
either end). Steady game mix: about -20 LUFS, peaks under -1.5 dBFS, no long near-silent passages.

## The main theme: the Crossroads figure

One motif ties the soundtrack together. It is Crosspath's: the place where every Path meets. (It is separate from the two story motifs,
Concordia's lullaby `MUS-LULLABY` and Primm's `MUS-PRIMM-MOTIF`, which stay as they are.)

- **In words:** a hopeful leap up a fifth, a three-step walk down, then a lift back to the fifth that is left hanging, like a road that
  keeps going. It sounds like a question asked kindly.
- **Notes (home key D Dorian):** D4 - A4 - G4 - F4 - E4 - A4.
- **Rhythm (4/4, two bars):** quarter, eighth, eighth, dotted quarter, eighth, dotted half (then one beat of rest).
  `D4 (1) | A4 (1/2) G4 (1/2) | F4 (1 1/2) E4 (1/2) | A4 (3) - rest (1)`
- **Harmony under it:** Dm - G (major: the Dorian colour) - Dm/F - A7sus4 (the open end).
- **Resolved form** (used only for "freed" and homecoming moments): the last note falls to D4 instead of rising to A4.
- **Generator wording** (paste where a prompt says "the motif"): "a recurring six-note motif: up a perfect fifth, then down three steps
  and back up to the fifth, rhythm quarter, two eighths, dotted quarter, eighth, long held note; D4 A4 G4 F4 E4 A4".

---

## Crosspath (first)

### MUS-TOWN - Crosspath, roads converge (save as `MUS-TOWN_v03`)

> Instrumental fantasy RPG town theme, seamless loop, 2:30 long, 100 BPM, 4/4 with a light lilt, D Dorian. Mysterious and adventurous
> welcome: a crossroads market town at golden late afternoon, the place the hero keeps coming back to. A sampled flute states the motif
> (a recurring six-note motif: up a perfect fifth, then down three steps and back up to the fifth, rhythm quarter, two eighths, dotted
> quarter, eighth, long held note; D4 A4 G4 F4 E4 A4) over piano broken chords and pizzicato violin counterlines, warm cello bass, soft toms
> and shaker, a subtle synth pad for air. Three sections: A (flute melody, full and bright, clear top end), B (adventurous: the motif moves
> to cello, a modulation up to E Dorian, livelier pizzicato), C (quiet and historical: solo piano and low strings, fewer instruments, the
> motif fragmented), then back to A. Keep the high frequencies present and airy (not muffled). Instrumental, seamless loop, the last bar
> leads into the first with no fade.

- **Motif:** flute, full statement, home key, open ending on A.
- **Fixes over the current take:** brighter top end (the current one measures dull above 8 kHz), and no breath before the downbeat at the wrap.

### MUS-TOWN-FREED - Crosspath, returning citizens (save as `MUS-TOWN-FREED_v02`)

> Instrumental fantasy RPG town theme, restored version, seamless loop, 2:40 long, 96 BPM, 4/4, D Dorian moving to D major in the last
> section. Different voices finding harmony: the town after four lost districts have come home. The motif (a recurring six-note motif: up a
> perfect fifth, then down three steps and back up to the fifth, rhythm quarter, two eighths, dotted quarter, eighth, long held note;
> D4 A4 G4 F4 E4 A4) is passed between four distinct voices, one per returning Path: a warm French horn (strength), a clarinet with a little
> bistro swing (food), a bassoon with celesta sparkles (bureaucracy and the afterlife, gently comic), marimba and kalimba (compost and growth).
> Interlocking countermelodies over piano, plucked strings and cello. Begin with a NEW opening, not the plain town arrangement: the four
> voices enter one by one in the first 30 seconds. Warm and full but with space; no constant fanfare. In the final section all four play
> the motif together and it resolves down to D (D4 A4 G4 F4 E4 D4). Moderate, even dynamics (no very quiet passages). Instrumental,
> seamless loop, the last bar leads into the first with no fade.

- **Motif:** four instruments in turn, then together; resolved form at the end of the loop.
- **Fixes over the current take:** the current one opens as the MUS-TOWN recording for about 40 s, and its quiet passages are very quiet (LRA 15.5).

### MUS-TOWN-BATTLE - Friendly ground, serious cards (save as `MUS-TOWN-BATTLE_v02`)

> Instrumental fantasy RPG battle theme for a friendly card duel, seamless loop, 2:30 long, 120 BPM, 4/4, D Dorian. Town adventure with
> strategic tension, controlled momentum, not frantic. A plucked pizzicato ostinato built from the first three notes of the motif (D A G)
> drives the piece; the full motif (a recurring six-note motif: up a perfect fifth, then down three steps and back up to the fifth, rhythm
> quarter, two eighths, dotted quarter, eighth, long held note; D4 A4 G4 F4 E4 A4) is played by low cello in half time, answered by
> oboe and flute phrases. Piano chords, frame drum and taiko accents on the bar lines, steady energy throughout, punchy and present, a
> contrasting middle section in F major with a woodwind duet. Even dynamics. Instrumental, seamless loop, the last bar leads into the first.

- **Motif:** cello, half time, plus a three-note ostinato; home key.
- **Fixes over the current take:** steadier energy (the current one has a wide range, LRA 11.5, for a fight) and a firmer, brighter mix.

### MUS-DECK - A plan in the cards (save as `MUS-DECK_v02`)

> Instrumental calm thinking music for a deckbuilding screen, seamless loop, 2:00 long, 72 BPM, 4/4, D Dorian with suspended chords.
> Thoughtful possibility, a quiet library at night. Solo piano plays only the first four notes of the motif (D4 A4 G4 F4) slowly, at half
> speed, then leaves the question open; soft pizzicato, a gentle cello line and a quiet warm pad. Low intensity and steady from start to
> finish: no swells, no drums, no silence. The ending bar is as loud and as full as the opening bar so the loop is invisible. Instrumental,
> seamless loop, no fade.

- **Motif:** piano, augmented (half speed), first four notes only.
- **Fixes over the current take:** the current take steps 7.7 dB at the wrap (a quiet ending into a fuller start) and had silence at the end.

---

## Other tracks rated 3

### MUS-QUIZ - Questions in triplicate (save as `MUS-QUIZ_v02`)

> Instrumental thinking music for a trivia encounter, seamless loop, 1:45 long, 92 BPM, 4/4, D Dorian. Curiosity and thinking time, no
> ticking clock. Question-and-answer figures: the clarinet asks with the first three notes of the motif (D4 A4 G4), the pizzicato strings
> answer with the last three (F4 E4 A4). Warm low strings, light piano, restrained brushed drums, a clear and uncluttered low end. Same level
> at the start and the end of the loop. Instrumental, seamless loop, no fade.

- **Motif:** split between clarinet (question) and pizzicato (answer).
- **Fixes:** the current take steps 6 dB at the wrap and is a little thick in the low mids.

### MUS-ARENA-BATTLE - The Grand Clashatorium (save as `MUS-ARENA-BATTLE_v02`)

> Instrumental fantasy RPG arena battle theme, seamless loop, 1:45 long, 132 BPM, 4/4, D Mixolydian. A showman's gladiator arena made of
> card tables: bold, theatrical, fun. Trumpets and horns play the motif as a fanfare (a recurring six-note motif: up a perfect fifth, then
> down three steps and back up to the fifth, rhythm quarter, two eighths, dotted quarter, eighth, long held note; D4 A4 G4 F4 E4 A4) over
> driving strings, snare and big drum, crowd-like brass stabs, a cheeky clarinet interlude. Loud and consistent the whole way: no quiet
> passages. Instrumental, seamless loop, no fade.

- **Motif:** brass fanfare, major-ish (Mixolydian), full speed.
- **Fixes:** the current take has the widest dynamics in the game (LRA 18) and is very dark; quiet stretches vanish under battle sounds.

### MUS-ARENA-ELITE - The championship card (save as `MUS-ARENA-ELITE_v02`)

> The same arena style as MUS-ARENA-BATTLE, higher stakes: seamless loop, 1:50 long, 140 BPM, D minor turning to D major in the last
> phrase. The motif in low brass and timpani, answered by high strings in canon one bar later; choir-like synth pad, relentless percussion,
> consistent loudness (no quiet passages). Instrumental, seamless loop, no fade.

- **Motif:** low brass plus a string canon; minor, resolving to major at the end of the loop.
- **Fixes:** as MUS-ARENA-BATTLE (LRA 18.3).
