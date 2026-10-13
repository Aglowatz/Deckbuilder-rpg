# Sound effects inventory

What the game plays today and what it lacks (music and stings are in `music_integration.md`). **To paste into a Google Sheet:** open
`docs/audio/sfx_inventory.tsv` (tab separated, one header row) and paste it into cell A1, or use Data > Split text to columns on this table.

- 111 rows: 31 exist (Kenney CC0 packs), 34 are placeholders (a stand-in sound is reused), 46 are missing.
- Priority 1 = needed next (every playthrough hears it or it carries the feel of an area), 2 = clearly improves the game, 3 = polish.
- ID convention: `SFX-<GROUP>-<NAME>` for one-shots, `AMB-<PLACE>` for loops (ambience, weather, water). Keep the ID when a file is replaced, like the music IDs.
- Footsteps today use the grass sound everywhere; there is no ambience at all (the old synthesized music tracks carried a little wind, birds and mains hum; the
  new music has none of that), no weather, and no spatial water.
- Not covered: voices, and the card-specific sound of each of the 300+ cards (the table asks for a handful of categories first).

| Suggested ID | Event | Area | Current status | What plays now | Ideal sound | Priority |
|---|---|---|---|---|---|---|
| SFX-CARD-DRAW | A card is drawn to the hand | Battle | exists | Kenney casino card-slide (3 variations) | Soft card slide on felt with a tiny flick at the end; three variations, a touch quieter for the opponent's draws | 3 |
| SFX-CARD-PLAY-UNIT | A unit card is played to the field | Battle | placeholder | The same Kenney card-place for every card | A weighty set-down with a short body: wood-on-felt thud plus a small Path-coloured accent (see the RES rows for the Path flavour) | 1 |
| SFX-CARD-PLAY-SPELL | A spell card is cast | Battle | placeholder | Kenney card-place plus an interface "maximize" blip | A magical release: a rising whoosh with a bright tail, shorter for cheap spells, bigger for expensive ones | 1 |
| SFX-CARD-PLAY-ITEM | An item / equipment card is played | Battle | missing | Plays the generic card-place | Metallic clink and leather creak, like setting a tool on a bench | 2 |
| SFX-CARD-HOVER | Hovering or fanning a card in hand | Battle | exists | Kenney card-fan (quiet) | A very light paper rustle, almost subliminal; must never tire over a long fight | 3 |
| SFX-CARD-DISCARD | A card is discarded / dissolves | Battle | exists | Kenney card-shove (2) | A short papery dissolve with a soft shimmer tail | 3 |
| SFX-CARD-SHUFFLE | Deck is shuffled | Battle | exists | Kenney card-shuffle | A crisp riffle; slightly shorter than the current one | 3 |
| SFX-CARD-RETURN | A unit is sent back to the hand | Battle | placeholder | The card-draw slide | A reverse whoosh and a soft pop as it lands in the hand | 2 |
| SFX-RES-BEEF | A Beefcake resource (infrastructure) is played | Battle | placeholder | One Kenney wood thud for every resource | A dumbbell plate set on a rack: iron clank with a low ring | 2 |
| SFX-RES-GOUR | A Gourmand resource is played | Battle | placeholder | One Kenney wood thud for every resource | A pot lid set on a stove with a little sizzle and a spoon tap | 2 |
| SFX-RES-NECRO | A Necrocrat resource is played | Battle | placeholder | One Kenney wood thud for every resource | A rubber stamp thump on a paper stack with a faint bell toll | 2 |
| SFX-RES-REF | A Refusemancer resource is played | Battle | placeholder | One Kenney wood thud for every resource | A wet leaf slap and a soft compost squelch with a tiny glass chime | 2 |
| SFX-RES-NEUTRAL | A neutral resource is played | Battle | placeholder | One Kenney wood thud for every resource | A plain stone set-down | 3 |
| SFX-ENERGY-SPEND | Energy is spent paying a cost | Battle | missing | Nothing (the counter just changes) | A tiny glassy tick per point spent, so a 4-cost card reads as four ticks | 3 |
| SFX-ATTACK-DECLARE | Attackers are declared | Battle | placeholder | Kenney draw-knife (3) | A short battle shout swell plus blades drawn; a Path-flavoured variation (rock-guitar stab, pan clang, bell, rustle) would tie in with the music | 2 |
| SFX-BLOCK | A blocker is assigned | Battle | placeholder | Kenney card-place | A shield or pan catching a blow: short metallic clank | 2 |
| SFX-DAMAGE-LIGHT | A unit takes light damage | Battle | exists | Kenney punch-medium (3) | Fine as a base; add a soft cloth layer so it matches the card art style | 3 |
| SFX-DAMAGE-HEAVY | A unit takes heavy damage | Battle | exists | Kenney punch-heavy (2) | A deeper hit with a short low boom and a camera-shake-synced rattle | 2 |
| SFX-DAMAGE-METAL | Damage on an armored unit | Battle | exists | Kenney impact-metal (2) | Metal on metal with a short ring | 3 |
| SFX-DAMAGE-PLAYER | The hero or the opponent takes damage on the portrait | Battle | placeholder | Same as light damage | A distinct body hit with a muffled grunt; add a heartbeat layer below a third of the HP | 2 |
| SFX-HEAL | HP is restored | Battle | placeholder | Kenney "confirmation" blip | A warm rising chime with a soft breath of air | 2 |
| SFX-DEATH-UNIT | A unit dies | Battle | placeholder | Kenney glass-impact (2) | A short dissolve that echoes the card's Path: sparkle, steam, ink-spill, leaf scatter | 2 |
| SFX-TRAP-SET | A trap is set face down | Battle | placeholder | Kenney metal latch (quiet) | A latch click and a creak of a hidden mechanism | 2 |
| SFX-TRAP-TRIGGER | A trap is triggered | Battle | placeholder | Kenney metal latch (loud) | A spring snap with a short alarm stinger and a camera-shake thump | 2 |
| SFX-TOOL-USE | An item (a Tool) is used in battle | Battle | missing | The generic UI confirm | Per category: a cork pop and glug for potions, a charm chime, a scroll unfurl; short and distinct | 1 |
| SFX-TOOL-EQUIP | Equipment is equipped in the character screen | UI | missing | The generic UI confirm | Leather and buckle for armor, a metallic slide for weapons | 2 |
| SFX-STAT-UP | A unit gains stats or a keyword | Battle | missing | Nothing (floating text only) | A rising two-note sparkle; the debuff version falls | 3 |
| SFX-TOKEN | A token is created | Battle | missing | Nothing | A small poof with a pop of confetti dust | 3 |
| SFX-TURN-START | The turn begins | Battle | exists | Kenney impact-bell (heavy) | A softer, warmer bell; the heavy one is too loud on every turn | 3 |
| SFX-END-TURN | The end-turn / next-phase button | Battle | placeholder | UI tick | A card-stack tap, clearly different from a menu click | 3 |
| SFX-BATTLE-START | A battle begins | Battle | missing | Nothing (a scene fade) | A short drum-roll hit and a whoosh that settles into the battle song | 2 |
| SFX-REFUSE-PILE | The Refuse Pile viewer opens | Battle | placeholder | UI open | Papers sliding and a lid opening | 3 |
| SFX-UI-CLICK | A button is clicked | UI | exists | Kenney UI-audio click | Keep, or restyle with a warm wooden click to match the fantasy UI kit | 3 |
| SFX-UI-HOVER | A button is hovered | UI | exists | Kenney UI-audio rollover (quiet) | A faint tick; must not irritate when sweeping across a list | 3 |
| SFX-UI-CONFIRM | A choice is confirmed | UI | exists | Kenney interface confirmation | A pleasant two-note confirm | 3 |
| SFX-UI-BACK | Back / cancel | UI | exists | Kenney interface back | A short descending note | 3 |
| SFX-UI-ERROR | An action is refused (not enough gold, illegal play) | UI | exists | Kenney interface error | A soft low buzz, gentler than now (it is the most-used sound in the game) | 2 |
| SFX-UI-OPEN | A panel / overlay opens | UI | exists | Kenney interface open | A paper-and-wood slide open | 3 |
| SFX-UI-CLOSE | A panel / overlay closes | UI | exists | Kenney interface close | The mirror of the open sound | 3 |
| SFX-UI-TOGGLE | A checkbox or option toggles | UI | exists | Kenney interface toggle | A small switch click | 3 |
| SFX-UI-TICK | A list step, dialogue advance, counter tick | UI | exists | Kenney interface tick | A light tick; also used by the dialogue box | 3 |
| SFX-UI-SELECT | A card or node is selected | UI | exists | Kenney interface select | A bright select note | 3 |
| SFX-UI-TOAST | A toast appears (gold or item gained) | UI | placeholder | The coins sound | A soft notification chime, with a coin sound only when gold is gained | 3 |
| SFX-UI-SLIDER | A volume or settings slider is dragged | UI | missing | Nothing | A tiny step tick per notch, with the volume slider previewing its own bus | 3 |
| SFX-UI-PAGE | A page of the book / quest log turns | UI | exists | Kenney RPG book-flip (2) | Fine as is | 3 |
| SFX-DIALOGUE-BLIP | Each typewriter step of a line of dialogue | Dialogue | exists | Kenney interface tick (quiet) | A tiny voice-like blip per speaker (higher for light characters, lower for the heavy ones), very quiet | 2 |
| SFX-NPC-TALK | Starting a conversation with an NPC | Overworld | placeholder | UI open | A short vocal "hm?" or cloth rustle, per NPC kind (animal, elder, merchant) | 2 |
| SFX-NPC-INTERACT-PROP | Using a sign, a board or a lever | Overworld | placeholder | UI open / lever clunk | Wood creak for signs, paper pin rattle for the board | 3 |
| SFX-QUEST-ACCEPT | A quest is accepted | UI | missing | The generic UI confirm | A pen scratch and a short rising motif | 2 |
| SFX-STEP-GRASS | Footstep on grass (forest, Gainlands, Verdant Dump edges) | Overworld | exists | Kenney footstep-grass (4) | Keep; add a quiet run version for a sprinting hero | 3 |
| SFX-STEP-COBBLE | Footstep on the town's stone tiles | Overworld | placeholder | The grass footstep | Leather boots on stone, a little hollow echo | 2 |
| SFX-STEP-DIRT | Footstep on packed earth (forest paths, the Dump's soil, the Reek) | Overworld | placeholder | The grass footstep | A dry crunch of dirt with small pebbles | 2 |
| SFX-STEP-WOOD | Footstep on wooden planks (bridges, lifting platform, stages) | Overworld | placeholder | The grass footstep | A hollow plank knock | 2 |
| SFX-STEP-TILE | Footstep on tile and linoleum (the Buffet, the D.N.A. lobby, the Hungry Quarter) | Overworld | placeholder | The grass footstep | A clean click on tile with a faint squeak | 2 |
| SFX-STEP-METAL | Footstep on metal grating (the Transit Yards, tunnels) | Overworld | placeholder | The grass footstep | A bright ringing clank | 3 |
| SFX-STEP-GRAVEL | Footstep on gravel and the outskirts road | Overworld | placeholder | The grass footstep | A heavy gravel crunch | 3 |
| SFX-STEP-WATER | Wading through shallow water | Overworld | missing | The grass footstep | A splashing wade with drips | 3 |
| SFX-JUMP | The hero jumps / lands (zones) | Overworld | missing | Nothing | A small cloth hop and a soft landing thump, surface-aware | 3 |
| SFX-HERO-HURT | The hero is hit by a roaming enemy or a rift | Overworld | placeholder | Heavy impact | A grunt with a cloth hit and a short stagger tone | 2 |
| SFX-HERO-FAINT | The hero is carried to the hub at 0 HP | Overworld | missing | Nothing | A soft collapse and a descending sigh before the wake-up scene | 3 |
| SFX-ENEMY-ALERT | A roaming enemy notices the hero | Overworld | missing | Nothing | A short two-note alert per enemy kind | 2 |
| SFX-ENEMY-DEFEAT-WORLD | A roaming enemy is beaten | Overworld | missing | Victory sting only | A poof and a puff of Path-coloured sparkles | 3 |
| SFX-DOOR | A door or entrance is used | Overworld | placeholder | Kenney RPG door-open for every entrance | Varied: wooden door, iron gate, cave entrance, trapdoor; with a latch | 2 |
| SFX-TRANSITION | A scene change (town to zone, into a dungeon) | Overworld | missing | A fade only | A whoosh of wind or a rift sizzle that fits the destination | 2 |
| SFX-GATE-OPEN | The Capital's gate opens / the hero crosses the wall | Capital | placeholder | "heal" or "door" | A big mechanical gate winding open with a hollow boom | 2 |
| SFX-LADDER | Climbing a ladder, manhole or service shaft | Capital | missing | Nothing | Metal rungs and a hatch cover scrape | 3 |
| SFX-RIFT-EXPRESS | Using the Rift Express fast travel | Overworld | missing | UI sounds | A sizzling rift whoosh up to a pop at the other end | 2 |
| SFX-RIFT-NEAR | Standing near an open Capital rift | Capital | missing | A camera shake only | A low unstable rumble that rises with proximity, with crackles | 2 |
| SFX-RIFT-SEAL | A rift is sealed | Capital | exists | STG-RIFT sting | Add a short implosion hit under the sting | 3 |
| SFX-CHEST-OPEN | A chest is opened | Overworld | placeholder | Kenney metal latch | A wooden lid creak, a latch and a sparkle | 2 |
| SFX-CHEST-GIANT | The giant chest (Shiro's prank) | Overworld | placeholder | A synthesized "boing" | A big creak, a spring, and a cheeky pop before the ninja appears | 3 |
| SFX-COINS | Gold is gained or spent | Overworld | exists | Kenney RPG coins (2) | Fine; a larger sound for big sums would help | 3 |
| SFX-PICKUP | An item or secret pickup | Overworld | missing | Nothing | A small chime with a bag rustle | 3 |
| SFX-HEAL-SPOT | Using a couch, well or other healing spot | Overworld | placeholder | The heal blip | A relaxed sigh with a warm chime, differently dressed per zone | 3 |
| SFX-LEVER | A lever is pulled (the vault) | Town | exists | Synthesized lever clunk | Replace the synthesized clunk with a recorded iron lever and chain | 3 |
| SFX-VAULT-GRIND | The Four-Seal Vault opens | Town | exists | Synthesized stone grind | Replace with a real stone slab drag and a deep boom | 3 |
| SFX-SMOKE-BOMB | Shiro's smoke bomb | Overworld | exists | Synthesized smoke puff plus STG-SHIRO | Replace the synthesized puff with a real whoomph and a cartoon "ping" | 3 |
| SFX-SPLASH | Water splashes (Buffet soup, the Dump's ponds) | Overworld | exists | Synthesized splash | A real splash with a droplet tail | 3 |
| SFX-BOING | A bounce pad or mushroom bounces the hero | Overworld | exists | Synthesized boing | A real spring boing; fine as a placeholder | 3 |
| SFX-PACK-TEAR | A pack is torn open | Packs | exists | Kenney cloth / draw-knife | A foil tear with a crisp rip | 3 |
| SFX-PACK-WHOOSH | Cards fan out of the pack | Packs | exists | Synthesized whoosh | A real swoosh of cards in the air | 3 |
| SFX-PACK-FLIP | A card is flipped in the reveal | Packs | exists | Kenney card-slide | A snappy flip per card, pitched up with rarity | 3 |
| SFX-PACK-CHIME-UNCOMMON | An uncommon card is revealed | Packs | placeholder | Synthesized chime | A bright two-note bell (the rare and legendary reveals use the registry stings) | 3 |
| SFX-CRAFT-BREW | The Alchemist's cauldron bubbles while crafting | Town | missing | Nothing (the sting plays at the end) | A bubbling loop with a rising whistle and a pop; ends on the craft sting | 2 |
| SFX-VENDOR-REACT | A vendor reacts (buy, too poor, sold out) | Shops | missing | UI error for "too poor", the purchase sting for a buy | A short vocal reaction per vendor (hum, tut, delighted gasp) | 3 |
| SFX-ARENA-CROWD | The Grand Clashatorium crowd | Arena | missing | Nothing | A crowd murmur loop with cheers at a win and a groan at a loss | 2 |
| SFX-MINIGAME-TICK | Minigame feedback: match, sort, order, rep | Minigames | placeholder | UI ticks and "ding" | A distinct satisfying note per correct move, a buzz per miss, per Path instrument | 2 |
| SFX-PUZZLE-CLICK | Puzzle pieces move (tubes, wheels, recipe, growth) | Puzzles | missing | UI clicks | A mechanical clunk (wheels), glass clink (tubes), pot clatter (recipe), soil rustle (growth) | 3 |
| AMB-FOREST | The starting forest | Forest | missing | Nothing (the old synthesized music carried a little wind) | Leaves in a light breeze, distant birdsong, a small stream; day / dusk variation | 1 |
| AMB-TOWN | The town of Crosspath | Town | missing | Nothing (the old synthesized town track had a wind layer) | Plaza murmur, a distant market, a well drip, birds and a bell far away | 1 |
| AMB-GRAVEYARD | The graveyard corner | Town | missing | Nothing | Low wind, a crow, a creaking branch and a faint ghostly hum | 2 |
| AMB-GAINLANDS | The Gainlands | Gainlands | missing | Nothing (old synth wind and birds) | Clanking plates and distant grunts, wind over an open field, a whistle | 1 |
| AMB-BUFFET | The Endless Buffet | Buffet | missing | Nothing | Kitchen bustle: sizzle, distant plates, a bell, a simmering pot | 1 |
| AMB-DNA | The Department of Necrotic Affairs | D.N.A. | missing | Nothing (the old synthesized track had a mains-hum layer) | Fluorescent buzz, a distant stamp and printer, and a ticking clock | 1 |
| AMB-DUMP | The Verdant Dump | Verdant Dump | missing | Nothing (old synth wind and birds) | Wind through junk, flies, dripping, creaking vines and a far-off bird | 1 |
| AMB-CAPITAL-OUT | Outside the Capital's wall | Capital | missing | Nothing (old synth wind and hum) | A bare wasteland wind, ash hiss, a distant creak of the gate | 1 |
| AMB-CAPITAL-IN | Inside the Capital's wall | Capital | missing | Nothing (old synth hum) | A too-cheerful loudspeaker hiss, polite crowd murmur, birdsong that is slightly looped | 2 |
| AMB-CREASE | The Crease hideout | Capital | missing | Nothing | Pipes and drips, a low murmur and a muffled generator | 2 |
| AMB-CAVE | The Forgotten Cave and the side dungeons | Dungeons | missing | Nothing | Dripping water with a long reverb, a soft wind from deep below, glow-moss hum | 2 |
| AMB-HOUSE-OF-GAINS | House of Gains (main dungeon) | Dungeons | missing | Nothing | A busy gym: weights, a locker door, distant motivational shouting | 3 |
| AMB-TEST-KITCHEN | Test Kitchen (main dungeon) | Dungeons | missing | Nothing | Industrial kitchen hum, steam hiss, a timer beep | 3 |
| AMB-HALL-OF-APPROVALS | Hall of Final Approvals (main dungeon) | Dungeons | missing | Nothing | An echoing hall, distant rubber stamps and a clock | 3 |
| AMB-ROTHEART | The Rotheart (main dungeon) | Dungeons | missing | Nothing | Creaking roots, a slow heartbeat-like pulse and wet drips | 3 |
| AMB-CASTLE | Primm's Castle | Dungeons | missing | Nothing | A vast, too-clean hall tone with perfect footsteps echoing and a ticking metronome | 2 |
| AMB-LAB | The Path-ology Lab | Dungeons | missing | Nothing | Bubbling tanks, electric hum and a beeping monitor | 3 |
| AMB-ARENA | The Grand Clashatorium | Arena | missing | Nothing | See SFX-ARENA-CROWD; a stadium bed with a distant announcer | 3 |
| AMB-WEATHER-WIND | Wind as a world layer (wasteland, mountain, open fields) | World | missing | Nothing | A gusting wind loop with three intensities that zones can blend | 2 |
| AMB-WEATHER-RAIN | Rain (not in the game yet; for the Dump and the Reek) | World | missing | Nothing | Soft rain on leaves and puddles, with a heavier version | 3 |
| AMB-WEATHER-ASH | Falling ash over the Capital (a visual effect exists) | Capital | missing | Nothing | A faint papery hiss and the odd distant thunder; swapped for a soft chime of confetti once the Capital is restored | 3 |
| AMB-WATER-STREAM | Streams, fountains and the town well | World | missing | Nothing | A gentle stream loop with a spatial falloff near the source | 2 |
| AMB-WATER-SOUP | The Buffet's soup ponds and the Dump's puddles | World | missing | Nothing | A thick bubbling loop with the odd glug | 3 |

## Sound names the game uses today

`Audio.sfx(&"name")` calls (count in code), from `app/audio_catalog.gd` (Kenney packs: UI audio, interface sounds, impact sounds, RPG audio, casino audio, music jingles; licenses in `CREDITS.md`)
and `app/music_synth.gd` (synthesized, original):

| Name | Calls | Source |
|---|---|---|
| `ui_error` | 59 | catalog (1 file) |
| `ui_confirm` | 26 | catalog (1 file) |
| `ui_tick` | 25 | catalog (1 file) |
| `hit_heavy` | 21 | catalog (2 files) |
| `heal` | 21 | catalog (1 file) |
| `ui_open` | 21 | catalog (1 file) |
| `ui_toggle` | 19 | catalog (1 file) |
| `coins` | 17 | catalog (2 files) |
| `ui_select` | 14 | catalog (1 file) |
| `door` | 13 | catalog (1 file) |
| `spell` | 11 | catalog (2 files) |
| `victory` | 9 | catalog (1 file) |
| `turn_start` | 8 | catalog (1 file) |
| `card_hover` | 8 | catalog (1 file) |
| `chest_open` | 8 | catalog (1 file) |
| `card_draw` | 7 | catalog (3 files) |
| `level_up` | 7 | catalog (1 file) |
| `card_play` | 6 | catalog (3 files) |
| `ui_hover` | 6 | catalog (1 file) |
| `ui_close` | 6 | catalog (1 file) |
| `ui_back` | 6 | catalog (1 file) |
| `land_play` | 5 | catalog (2 files) |
| `hit_light` | 5 | catalog (3 files) |
| `footstep` | 5 | catalog (4 files) |
| `attack` | 4 | catalog (3 files) |
| `hit_metal` | 4 | catalog (2 files) |
| `card_shuffle` | 3 | catalog (1 file) |
| `dialogue` | 3 | catalog (1 file) |
| `boing` | 3 | synthesized |
| `trap` | 2 | catalog (1 file) |
| `death` | 2 | catalog (2 files) |
| `card_discard` | 2 | catalog (2 files) |
| `ui_click` | 2 | catalog (1 file) |
| `pack_whoosh` | 2 | synthesized |
| `pack_flip` | 2 | catalog (2 files) |
| `book` | 2 | catalog (2 files) |
| `splash` | 2 | synthesized |
| `pack_tear` | 1 | catalog (3 files) |
| `pack_chime_uncommon` | 1 | synthesized |
| `ding` | 1 | synthesized |
| `smoke_bomb` | 1 | synthesized |
| `lever_clunk` | 1 | synthesized |
| `vault_grind` | 1 | synthesized |

Names that route to a music sting when its file is present (`AudioManager.STING_ALIASES`): `victory` (STG-VICTORY), `defeat` (STG-DEFEAT), `level_up` (STG-LEVEL).
