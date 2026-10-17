# Sound direction

How The Wayward Path should sound outside its music. The music direction is in `data/source/sound_guidance.csv` and `music_integration.md`; the look
is in `docs/art/art_bible.md`. This page is the brief every sound effect and ambience is chosen and mixed against. The system that plays them is
described at the end; where each file comes from is in `sfx_sources.md`; every event and its status is in `sfx_inventory.md`.

## The overall voice

- **A storybook made of real things.** The art is painted storybook and the cards are physical objects, so the sounds are acoustic and tactile:
  paper, card stock, wood, cloth, iron, crockery, leaves. Nothing digital, nothing that beeps. Magic is made of real materials too (a whoosh of
  paper, a ring of glass, a breath of air), never a synthesizer zap.
- **Comedy with consequences.** Funny where the world is funny (mashed potato squelches, a goat bleating on a car roof, the creak of a giant hamster
  wheel), but never cartoon "boing" ornament over a serious beat. Timing, not silliness, makes it funny.
- **Warm and close, then wide.** Interface and card sounds are close and dry, as if the cards were on a table in front of you. The world is placed
  around the hero with distance and the space of each place.
- **Never fatiguing.** A battle lasts minutes and a session hours: the most frequent sounds are the quietest and the softest (hover, draw, footsteps,
  dialogue blips), every frequent sound has several variants with pitch and volume drift, and nothing harsh lives above 6 kHz.

## The interface family (Part D)

One family, built from a card table: **paper, card stock, wood and a little brass.**

| Role | Character | Built from |
|---|---|---|
| Hover | A breath of paper: a very soft card-edge brush, almost subliminal | card fan, filtered and very quiet |
| Click / select | A light wooden tap with a paper tick on top | light wood impact + card place, short |
| Confirm | The click plus a small warm wooden "tock" a beat later | two wood taps rising |
| Back / close | The same tap, lower and softer, a card sliding away | card slide, low pitch |
| Open a menu | A book or folder opening: a paper swish and a soft wooden settle | book open, card slide |
| Tabs | A page turn | book flip |
| Error | A soft muted double knock on wood (never a buzzer) | wood knock, low-passed |
| Coins | Real coins in a leather pouch, with a fuller pile for big sums | coins, chips stack |
| Rewards, level up, quest complete | A brass-and-wood shimmer under the existing stings | glass and bell hits, low in the mix |
| Dialogue | A soft woody "tok" per character, pitched by speaker kind | a marimba-like synthesized pluck |

Rules: UI sounds are 2D, dry, on the UI bus, quieter than every battle sound. Hover is the quietest sound in the game. Nothing in the family has a hard
digital attack.

## Battle (Part B)

The table, the cards and the Paths' materials. A **card landing** is the core sound: a paper snap (transient) + a wooden thud (body) + a soft dust
puff (tail); cheap cards are light snaps, expensive cards land with weight. Hits are cloth-and-body, with a low thump on heavy hits; a trap is a latch
and a spring; deaths dissolve in the Path's material.

| Path | Material | Summon | Resource / token |
|---|---|---|---|
| Beefcake | Iron, gym plates, leather, brass | heavy metallic set-down, a plate clank | **Iron**: a dumbbell plate clank |
| Necrocrat | Paper, stamps, quills, a ghostly breath | a papery whoosh with a ghostly sigh | **Red Tape**: a stamp and a rip; **Contract**: a quill scratch |
| Gourmand | Pans, pot lids, sizzle, crockery | a sizzle and a pan clatter | **Ingredient**: a sizzle |
| Refusemancer | Junk, cans, leaves, compost | a rustle of junk and leaves | **Garbage**: a can-and-bottle rattle |

Battle sounds are 2D (a card table has no distance) on the Battle bus, with a small dry room. They are fired by the battle animations themselves
(`BattleBoard`), and their layer delays shrink with the battle speed, so they stay in sync at Fast and Very Fast. Big moments (a trap springing, a
heavy hit, a death, the last blow) duck the music by a few dB for half a second.

## Places (Part C)

Each place has a bed (a 30-60 second seamless loop), randomised one-shots placed around the hero, spot sounds at landmarks and an acoustic profile on
the World bus.

| Place | Identity | Bed | One-shots and spots | Space |
|---|---|---|---|---|
| Starting forest | Quiet, mysterious, a fresh start | soft leaves in a breeze | birdsong, a woodpecker far away, leaf gusts | forest: soft and absorbed |
| Crosspath (town) | Cozy, welcoming, home | a gentle town murmur | birds, distant chatter, wind chimes, the fountain, a far bell | stone plaza: a short bright slap |
| Gainlands | Sunny, energetic, comically macho | warm open wind | grunts and cheers from the training grounds, clanking weights; the hamster-wheel mill creaks | open meadow: nearly dry |
| D.N.A. | Gloomy, bureaucratic, deadpan | low office hum, a ticking clock | far typewriters and stamps, paper shuffles, ghostly whispers | office halls: a grey tail |
| Endless Buffet | Warm, indulgent, busy | distant kitchen bustle, sizzle | clinking pots, bubbling gravy, a kitchen bell | kitchen: bright and close |
| Verdant Dump | Scrappy, hopeful; eerie near the Rotheart | crickets at golden hour | goats, frogs, a creaking windmill, rustling junk; a low drone and a heartbeat pulse rise toward the Rotheart | wetlands: damp, short |
| Capital, outside | Bleak, drained, uneasy | hollow wasteland wind, a hiss of ash | rift crackles, creaking debris, a far crow; rifts hum | wasteland: vast, a late thin echo |
| Capital, inside | Too perfect, quietly wrong | an unnatural quiet (a faint even hiss) | perfect fountain splashes, polite loudspeaker chimes, one birdsong that repeats exactly | perfect plaza: hard, too clean |
| Capital districts | Broken or restored | broken: dead machines, flies; restored: the Path's life | broken: groans, paper, paste squelch; restored: weights, pans, birds, frogs | as inside |

**Footsteps** follow the ground under the hero (and NPCs, quieter): grass, dirt, cobble, wood planks, carpet, marble, ash, mashed potato (squelchy and
funny), junk gravel, metal grating, pastel plaza paving. They are synced to the painted walk cycle's foot contacts, not a timer.

## Mix

- Buses: **Master** (limiter at -1 dBFS) > **Music** (ducked), **SFX** (gentle compressor and a -2 dB limiter) > **World** (zone reverb), **Battle**
  (small room), **UI**; **Ambience** (ducked); **Voice** (dialogue blips). The player's sliders: master, music, effects (the whole SFX group),
  interface, ambience, dialogue voices.
- **Loudness targets** (applied by `tools/sfx_build.js` to every file; the RMS of the loudest 50 ms, or integrated loudness for beds):
  hover -31, UI -25, dialogue -29, light card -25, card -21, heavy card -17, light hit -18, medium hit -15, heavy hit -12, accents -20, big moments
  -14, footsteps -24, world -20, ambience one-shots -24 dBFS; beds -30 LUFS, layered beds -33 LUFS, landmark spots -26 LUFS. Each event then has a
  fine level in `data/source/sfx_events.csv`.
- **Ducking:** the music and ambience dip 3-5 dB under big battle moments (half a second, fast attack, slow release) and the ambience 5 dB under
  dialogue (the music's own dialogue and sting ducks stay as they were).
- **Many sounds at once:** a pool of 28 2D and 20 3D voices; each event has a priority and an instance limit; an event at its limit replaces its own
  oldest instance, otherwise the least important voice yields. A 40 ms (or longer) cooldown per event stops identical sounds stacking in one frame.

## The system

| Piece | Where |
|---|---|
| Sources: one row per shipped file (source, trim, filters, loudness category, loop) | `data/source/sfx_sources.csv` |
| Events: layers, bus, level, pitch and volume range, priority, limit, cooldown, 3D range, duck | `data/source/sfx_events.csv` |
| Build: download (freesound CC0 previews), trim, normalise, loop, encode, delete the raw file; writes the bank and the sources doc | `node tools/sfx_build.js` |
| Freesound search and fetch (CC0 only, licence checked on each sound's page) | `node tools/freesound.js` |
| The bank the game reads | `data/audio/sfx_bank.json` -> `SfxBank` |
| Variants (no repeats, pitch and volume drift) | `SfxVariantPicker` |
| Voice limits and priorities | `SfxVoicePolicy` |
| Playback, layers, 3D, listener on the hero, ducks | `Audio` (`app/audio_manager.gd`) |
| Bus tree, effects, per-place reverb | `AudioMix`, `AcousticProfiles` |
| Ambience beds and one-shots | `AmbienceProfiles`, `AmbienceManager` (`Audio.set_ambience`) |
| Landmark spot loops | `AmbientEmitter` |

To add or replace a sound: add a row to `sfx_sources.csv` (keep the set name; add variants as more rows), run `node tools/sfx_build.js`, then
`bash tools/run_tests.sh` (which imports the new files).
