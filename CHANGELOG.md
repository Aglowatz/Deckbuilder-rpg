# Changelog

## v1.0.0-rc3 - release candidate 3 (Nov 11 2026)

- Finding things in the world:
  - every step of every active quest marks everything it needs - each item, person, place or enemy - on the world map, the minimap and the
    map's "Point me to..." list, and drops each marker as it is done (sea salt, black truffle, Old Meatloaf; the three favour givers; every roaming
    enemy or stash a step counts); the tracked quest's parts carry chevrons and the arrow points at the nearest;
  - the way to each main dungeon is marked through its gate: Sir Loin's gate in the Buffet (and Sir Loin and Basil say where the salt and the
    truffle are), the stables and the junk barricade on the Dump's stairs;
  - nobody stands behind a prop any more (a probe checks every talking NPC at the default and the Low camera): Basil, Tarragon, Madame Mirepoix,
    Billie Muckfoot, Dex in the Dump, Kestrel and a Capital citizen moved or their props did; a prop between the camera and the person you can talk
    to dissolves; E walks you to the nearest person in view when nobody is in reach;
  - map labels: landmarks named first, minor names hidden on a small map and shown on hover; the "Point me to..." list opens over the map, never
    over the legend; one legend line per quest goal;
  - steam and mist no longer fill the screen as white sheets when the camera is inside a plume.
- Turns count both players: the battle shows "Turn N" (both players have gone) with "Your turn" / "Enemy's turn" beneath; the log, the boss
  "Setting Up" window ("from turn 3"), the result lines and the sims agree; cards say "until the end of your turn" (or "the enemy's turn" for a
  trap that fires on theirs). Nothing happens at a different moment than before.
- Hand cards show their numbers as this fight's rules would apply them (Primm's 3/3, a cost change, a zone rule) in green or red, and the
  preview says the printed values.
- No more "losing costs nothing": a dungeon defeat says the dungeon starts over and that the cards and gold you won are kept.
- Fights inside dungeons pay 50 % more gold and XP; every dungeon's completion reward is 20 % smaller.
- New equipment: the Hall Pass Slippers (Boots, 500 gold at Madame Mirepoix's) - roaming troublemakers and the world's hazards can't hurt you outside battle.

## v1.0.0-rc2 - release candidate 2 (Nov 10 2026)

- Fixes from three fresh-eyes reviews of the exported build (first hour, midgame, late game):
  - the opening forest is brighter, with less blur; the Crosspath fountain is painted stone instead of flat white;
  - in the Forgotten Cave your draws skip extra infrastructure once you hold five;
  - "End your turn?" asks about the attack when attackers are picked; the map's place list is "Point me to...";
  - the Path choice keeps the picked Path described and shows its Resource on hover;
  - Primm's first phase opens with 3 Militia (was 4); the Setting Up countdown matches its rule; Primm's node describes the three duels;
  - no speaker cut-out pasted over painted story stills; clearer skip prompt, quest tracker and dungeon defeat text;
  - the Buffet: Basil steps out from behind the soup fountain; the ingredient quest says where the truffle and the salt are.
- Settings > Text: one "Text size" switch (Normal / Large / Larger) for dialogue, cards and tooltips.
- Key rebinding never leaves moving, Interact or Pause without a key; the pause menu keeps Esc.
- A playtester dialogue import tool (tools/import_playtester_dialogue.py).

## v1.0.0-rc1 - release candidate (Nov 9 2026)

- Every Path plays through with real fights; Primm's Castle can no longer strand the party in its nested side rooms.
- Level hints at every dungeon door and on the map ("Travellers here are usually around level N", amber when 2+ under).
- The Shattered Gallery, Dex's Cardsharp's Circuit (fair targets, painted table, the Matching Pair), Mount Swolympus and the Iron Cave, the
  Lab's south wing, the Undercroft arena, the four-lever vault, hidden traits, Glossary and Collection Book.
- Balance: max HP 15 -> 30, two-turn boss setup window, dungeon clear XP bonus, the 21k no-grind gold curve, cheaper crafting, single-use items
  in four slots, the Extra Pocket, Primm's rules in plain words.
- Art Batches 11-14 (about 170 images): painted portraits for every NPC, every story still, vendor stalls, zone kit pieces, the quiz classroom,
  Sable's redesign, the species-flip variants redone, true-scale Primm and Test Kitchen stills, a painted Iron / Feastforge / Hulking Hauler.
  The Red Cross on Nurse Hesper is recoloured in code until her redo.
- Music: the full orchestral score at its designed quality (Gainlands hard rock set); a smaller build otherwise (WebP/BC1 pass, ArtCache).
- Dialogue: the main-story read and the designer's edit sheets applied; roamer and vendor barks.
- Release basics: autosave quill, colour-blind Path symbols on by default, Reduce motion, camera angle Low, Report a Problem (F8) and Copy log,
  Credits with every licence and the AI disclosure, Alex Glowatz credited, hidden Support buttons until a donation link is set.

## v0.5.1 - the Fable pass (Nov 1 2026)

- Max HP 15 -> 30 over the game (was 10 -> 25); a "Loose Ends" quest after the credits.
- Healing: the Crease nurse reads as a healer and answers E from her side; the Capital's hit toast names what hit you (a rift, a roamer).
- Bosses: every boss opens with a 2-turn setup window (its units do not attack: "Setting Up"); Compostella's Wild Growth stops at +3 per unit;
  the too-easy and too-hard bosses retuned into their band (the Restless Dead, Shiro, the Warden, the Echo, the Spotter, Betty, Spotless, the
  Automaton harder; Siphon without Elowen easier; Primm's phases tougher).
- A dungeon's first clear pays an XP bonus scaled with its tier (side dungeons too).
- The Grand Chef, the Doppelganger and Escoffina named consistently before and after the reveal.
- Freed zones: their damaging roamers wander in peace; the Capital stands down once Primm fell and its rifts close.
- First hour: the first duel deals a teaching hand and ends in a few turns; a right-click inspects any card; Crosspath roofs dissolve when
  they cover you; the square's fountain is bigger, never fades, and shows your silhouette through it.
- Click an NPC or a sign to walk there and talk; boss card picks offer at least two cards of your Path or Colorless; deck-test events can be
  declined; the rarest card of a pick starts chosen; one Victory popup; the Lab's -5 max life shows on the map; arena first-clear prizes
  scale with your level; the Verdant Dump loads faster (its layout is cached).

## v0.5.0 - release candidate (Nov 1 2026)

- Music: every track re-rendered with the note-overlap fix (pads, organ and choir chords hold their full length).
- The designer's 37 dialogue rewrites for the prologue, the cave and Maren's first talks.
- Captain Spotless paces before the Capital gate; Esc can skip a scene on a first viewing (after a confirm); the Doppelganger keeps its
  cover name until the reveal.
- Map: a "Where to?" list that pings any named place, a marked dungeon entrance. Locked gear slots say how to open them; dungeon nodes
  say "Click again to go"; a banner when a zone's max HP differs and when you return to a freed zone.
- Fixes: boss intros no longer ignore clicks or freeze; Sable answers from in front of her stall; plain tooltips spell out energy;
  deck-test events show the test and your odds first; "Open all" for packs; Esc closes Deck Station popups first; Quit Game asks and saves.
- Battle AI: a boss that stalls with no units deploys units instead of a fourth Tool.

## v0.3.1 - smaller build

Same game as v0.3.0, one third of the download: 477 MB instead of 1.63 GB, with no visible change in the art.

- Textures are compressed (VRAM compressed for the world, lossy for painted 2D art) and right-sized; working art that was shipped by mistake is gone.
- The window title and the executable are "The Wayward Path"; saves and settings are untouched.
- Developer: `docs/build_size_policy.md`, `bash tools/export_windows.sh` warns above 800 MB and prints sizes by category.

## v0.3.0 - playtest build

The new look, the new story and a lot of polish. Tester notes: `builds/RELEASE_NOTES_v0.3.0.md` (not committed).

### Look
- New low cinematic camera with tilt-shift, bloom and a mood per area; sky, water, foliage and distant scenery everywhere.
- Painted 2.5D hero and NPC sprites (talk poses; hats and cloaks wired in, art pending).
- Crosspath town square rebuilt from an Environment Kit (20 buildings, props, paths, lighting).
- Painted textures and decals on the ground and walls of every area.
- New title screen, loading screens with tips, zone title cards, story stills, 12 painted vendor screens.
- UI art kit: panels, buttons, card frames, icons for energy, resources, keywords, equipment and more.

### Sound
- 123 music tracks and 21 stings with crossfades and ducking; separate Master, Music, Effects and Interface volumes.

### Story and gameplay
- New prologue, Elder Maren as a tortoise, memory fragments, Path lock (1, then 2, then 4), the Path-ology Lab postgame, all 12 dungeons.
- Five save slots plus autosave, saved decks, Refuse Pile viewer and targeting, Shiro Swindle and giant chests, four-lever vault, pack rule, gold-free level rewards.
- Settings and accessibility: text sizes, colour-blind symbols, reduced shake and flashing, UI scale, key rebinding.
- No character-creation screen: New Game goes straight into the forest.
- Saves from an incompatible format are reset with a message on the title screen (the old file is kept as `.old`).

### Playtest tools
- F8 (or the pause menu's Send Feedback) saves a report with rating, notes, screenshot, game state and log to the feedback folder; Open feedback folder in the pause menu and the form.
- The version shows on the title screen and in the pause menu; file logging is on in release builds.

### Fixes
- Elder Maren's first memory now shows the second-Path announcement and returns control to the hero.

## v0.2.0 - the big one

Thanks for playing! Here is what's new since the last build you got.

### Cards and art
- A brand new designed card set: over 300 cards and 26 tokens, each with its own full-art frame.
- Painted art for almost every card and token.
- Resources are now real things on the table: Iron, Red Tape, Ingredient and Garbage, shown in a new four-coin resource tray. Contracts are their own tokens, and there is gear and items that use them.
- Cards can now have costs, triggers, Tools, Wonders and Traps, and the enemy AI knows how to use them (and values fuel and traps more).

### Battles
- Every battle now happens on a painted battleboard (22 of them), and each zone has its own themed table.
- Floating energy, a tidier resource tray, and a lot of enemy deck balancing.

### The world
- Zones are more fun to walk around: new passageways with signposts, secret ways, and sealed doors.
- 37 new hidden chests, with open/empty states and a proper reward box.
- A spread-out town with a new arena meadow, a calmer square, grass and worn paths.
- The starting clearing now sits in an endless forest with light shafts and fireflies.
- The Capital is a wasteland outside and an idyll inside, with a dramatic gate crossing.
- A big graphics pass on every area: better light, water, grass, sky, particles and shadows.

### Dungeons and maps
- All 12 dungeons from the design list, including side dungeons with their own quests, rescue nodes and special rules.
- Dungeon maps are now painted art with the nodes laid out over them.

### People and quests
- 71 NPC portraits, shown visual-novel style in dialogue, with expressions.
- A proper quest system with a single tracked quest, a Quest Complete box, and rewards.

### Places and shops
- The Arena, the Alchemist (craft potions and more) and card packs with a pack-opening screen. Duplicate cards turn into essence.
- A clothing vendor and tailor with a try-on screen: 12 hats and 10 cloaks, dyes, and secret cosmetics.

### UI
- Resource tray, minimap, a cleaner HUD, and mouse-wheel camera zoom.
- The title screen now shows the version.

### Heads up
- Old saves from before this version can't be loaded. The game will tell you and start fresh (your old file is kept as `save.json.old`).
- Art and names are still a mix of placeholder and final. Things will change!
