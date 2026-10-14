# Changelog

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
