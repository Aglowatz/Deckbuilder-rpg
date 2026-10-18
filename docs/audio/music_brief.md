# Music brief

Overnight Oct 17, Part 12. One entry per place or moment, ready to paste into a music generator. Paste the **style lock** first every time;
then the entry. IDs are the game's (`data/source/music_list.csv`); keep them when a track is replaced so the game picks the new file up
(drop it in the Drive folder, run "import audio", then `node tools/loop_fix.js` and `node tools/music_audit.js`).

**Style lock (all tracks):** Natural instruments lead, with subtle synth; mysterious and adventurous; developed melody, richer harmony and
contrasting sections. A storybook fantasy RPG with a comic streak: warm, characterful, never grim for long. Mixed for a game: no long
silences, no fade-out endings on loops, steady loudness (about -20 LUFS integrated, peaks under -1.5 dBFS).

**Loop rules (every loop):** a seamless loop of 2:00-3:00; the last bar must lead back into the first (same tempo, key and energy at both
ends, no reverb tail cut off, no silence at either end); at least two contrasting sections so it does not hammer one phrase.

---

## The starting forest (MUS-FOREST) - exploration
- **Mood:** quiet, mysterious, a fresh start in early-morning mist; curiosity with a hint of melancholy (the hero has lost his memory).
- **Tempo:** 72-84 BPM, gentle 6/8 sway.
- **Instruments:** solo flute or ocarina over fingerpicked nylon guitar, soft string pads, celesta sparkles, a distant low drum later.
- **Length / loop:** 2:00-2:30 seamless loop.
- **References:** a misty-forest opening area in a hand-drawn adventure game; a lullaby that slowly turns into a walking tune; dawn in a
  storybook woodland with fireflies still out.

## Crosspath, the town (MUS-CROSSPATH) - exploration, home base
- **Mood:** cozy, welcoming, golden late afternoon; the place you come back to.
- **Tempo:** 96-108 BPM, a light skipping swing.
- **Instruments:** accordion or concertina melody, mandolin, pizzicato strings, upright bass, light hand percussion, a warm clarinet answer.
- **Length / loop:** 2:30-3:00 seamless loop with a calmer B section (fewer instruments) so long town visits do not tire.
- **References:** a market-square town theme from a classic top-down RPG; a village fair heard from a bench; a tavern band warming up
  outdoors.

## The Gainlands (Beefcake zone) - exploration
- **Mood:** energetic, sunny, comically macho: a montage that takes itself slightly too seriously.
- **Tempo:** 120-128 BPM, driving straight eighths.
- **Instruments:** brass fanfare hits, snare and big tom groove, strummed acoustic guitar, low strings ostinato, a heroic horn melody,
  claps; one cheeky kazoo or slide-whistle moment per loop.
- **Length / loop:** 2:00-2:30 seamless loop.
- **References:** a training-montage theme played by a fantasy marching band; a sunny overworld theme with a sports-anthem swagger; a
  brass band at a strongman contest.

## The D.N.A. (Necrocrat zone, Department of Necrotic Affairs) - exploration
- **Mood:** bureaucratic, gloomy, deadpan funny; perpetual 4:59 PM.
- **Tempo:** 84-92 BPM, plodding and precise.
- **Instruments:** harpsichord, muted pizzicato strings, bassoon, a ticking clock or typewriter as percussion, theremin or saw for the
  ghosts, a faint office-hold-music lilt.
- **Length / loop:** 2:30 seamless loop.
- **References:** spooky-office elevator music; a haunted registry office waltz; a gothic comedy's paperwork montage.

## The Endless Buffet (Gourmand zone) - exploration
- **Mood:** indulgent, warm, absurdly delicious; dinner-time evening.
- **Tempo:** 100-112 BPM, a lilting bistro swing.
- **Instruments:** accordion, clarinet, upright bass, brushed snare, plucked strings, a little glockenspiel for the desserts, pots and
  pans as playful percussion.
- **Length / loop:** 2:30 seamless loop.
- **References:** a busy cartoon kitchen at the dinner rush; a French bistro band in a fairy-tale bakery town; a cooking-show theme played
  by a folk band.

## The Verdant Dump (Refusemancer zone) - exploration
- **Mood:** scrappy, overgrown, hopeful under the grime: nature taking the junk back.
- **Tempo:** 92-100 BPM, a loose shuffle.
- **Instruments:** junk percussion (bins, cans, bottles), banjo, fiddle, harmonica, low marimba, a pastoral woodwind line that grows over
  the loop.
- **Length / loop:** 2:30 seamless loop.
- **References:** a junkyard jam session at sunset; a folk tune played on found objects; a ruined garden coming back to life.

## The Capital (outside: the ash wasteland; inside: Primm's Perfection) - exploration
- **Mood (outside):** desolate, uneasy, resistance hiding in the ruins. **Mood (inside):** eerily perfect, too clean, smiling through
  clenched teeth.
- **Tempo:** outside 70-80 BPM; inside 108 BPM, metronomic.
- **Instruments:** outside: low cello drones, wind, sparse piano, distant bells. Inside: a music-box or celesta melody over rigid
  strings, a marching snare that never varies, a choir singing one vowel.
- **Length / loop:** 2:30-3:00 seamless loops (two tracks).
- **References:** outside: a ruined city after the war in a fantasy RPG; inside: a utopian city in a dystopian story, a parade where
  nobody is having fun.

## Battle (one per Path zone, plus the town and the tutorial)
- **Mood:** fun, focused, rhythmic: a card duel, not a war. Each zone's battle borrows its exploration instruments and melody fragment.
- **Tempo:** 132-144 BPM.
- **Instruments:** the zone's lead instrument over a driving groove (taiko or rock kit, low strings ostinato), short stabs that leave room
  for the card sounds; no long held notes in the 1-4 kHz range (where the UI sounds live).
- **Length / loop:** 2:00 seamless loop; the first 4 seconds must work as an intro (battles often start mid-loop).
- **References:** a turn-based RPG battle theme with a catchy hook; a tabletop game night soundtrack with drums; a duel in a tavern.

## Boss battles (each zone's main dungeon, the side dungeons, Primm's phases)
- **Mood:** high stakes but still the game's tone: the boss's personality turned up (Clench: brass and bravado; the Doppelganger: a
  waltz that goes wrong; Mortimer: an organ fugue in triplicate; Compostella: a forest that has gone feral; Primm: perfection cracking).
- **Tempo:** 140-160 BPM.
- **Instruments:** full orchestra with choir hits, the zone's signature instrument as the lead, a clear climax every 30-40 seconds
  (the game cuts its boss-victory sting from the loudest stretch, `tools/cut_stings.js`).
- **Length / loop:** 2:30-3:00 seamless loop with a build and a climax.
- **References:** a final boss theme from a 16-bit era RPG reimagined with real instruments; an opera villain's entrance; a showdown
  in a cartoon about cooking / bureaucracy / gyms.

## Dungeons (node maps: the dungeon map screen)
- **Mood:** tense exploration between fights; each dungeon in its zone's colours (the gym fortress, the test kitchen, the hall of
  approvals, the rot).
- **Tempo:** 90-100 BPM.
- **Instruments:** the zone's instruments thinned out, low drones, a pulse on muted percussion, a melody that only appears halfway.
- **Length / loop:** 2:00-2:30 seamless loop.
- **References:** a map screen in a roguelike deckbuilder; a dungeon crawl that is more mischievous than scary.

## Shops (each vendor's browsing theme)
- **Mood:** relaxed, characterful, the vendor's personality (Sable: smoky and sly; Tilly: bubbly; Beetsworth: officious; Fenwick: shiny
  and greedy; Alembic: mystical).
- **Tempo:** 80-100 BPM.
- **Instruments:** small ensembles (3-4 players): the vendor's signature instrument (clarinet, xylophone, marching snare, celesta...),
  bass, brushes.
- **Length / loop:** 1:30-2:00 seamless loop, quiet enough to talk over.
- **References:** a shop theme you could listen to for an hour; a lounge band in a fantasy market; a jingle stretched into a song.

## The title and menus (MUS-TITLE, MUS-DECK)
- **Mood:** wonder and invitation (title); calm focus for deckbuilding (deck station, collection book).
- **Tempo:** title 80-90 BPM; deck 70-80 BPM.
- **Instruments:** title: full orchestra stating the main theme, harp, choir; deck: piano and strings, soft and patient.
- **Length / loop:** title 2:00 loop with a grand opening; deck 2:00-3:00 seamless loop with no big swells (players think here).
- **References:** the opening of a beloved fantasy adventure; a quiet library at night; a thinking theme in a puzzle game.

## Level-up and reward stings (STG-LEVEL, STG-QUEST, STG-PACK-*)
- **Mood:** bright, earned, short.
- **Tempo:** free; 2-4 seconds.
- **Instruments:** a brass or woodwind flourish over a cymbal swell and harp gliss; the level-up rises, the quest resolves, the pack
  reveal escalates by rarity (Legendary gets a choir).
- **Length:** 2-4 s one-shots, no tail longer than 1.5 s, peak under -1.5 dBFS.
- **References:** a classic RPG level-up jingle; a victory fanfare after a battle; opening a present.
