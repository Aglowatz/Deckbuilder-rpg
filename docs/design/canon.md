# Canon quick reference

Locked names, spellings and rules on one page. Created Oct 19 2026. Detail, sources and status for every item:
`docs/design/story_bible.md` (the story reference). Authority when sources disagree: the user's locked decisions > the design sheet
(`data/source/npc_list.csv`, `dungeon_list.csv`) > game data > old docs.

## Names and spellings

| What | Canon | Token |
|---|---|---|
| Game title | The Wayward Path | - |
| Kingdom | Patchwork | `{kingdom}` |
| Its throne | the Pathwork Throne (sheet name; "Pathwork" appears only here) | - |
| Royal house | Wayweaver | `{royal_house}` |
| The player | the Wanderer, who is Prince Tessar Wayweaver (21) | `{wanderer}`, `{prince}`, `{prince_full}` |
| Late king / queen | King Harmon Wayweaver / Queen Concordia Wayweaver | `{king}` / `{queen}` |
| The rescuer | Elowen Vey: "The Rescuer" until Percival Plume names her at the castle gate, then "Elowen" (Oct 21) | `{rescuer}`, `{rescuer_full}` |
| Villain | Primm, "His Perfection" (former Royal Minister of Improvements) | `{villain}`, `{villain_title}` |
| Hub town | Crosspath | `{town}` |
| Capital | Primm's Perfection; Pathordia after his fall | `{capital}`, `{pathordia}` |
| Facade district | the Showcase Quarter | `{showcase}` |
| Resistance / hideout | the Wrinkles / the Crease | - |
| Starting area | the forest outside Crosspath ("The Forest Clearing") | - |
| Tutorial dungeon | the Forgotten Cave (boss: the Hollow Warden) | - |
| Arena | the Undercroft (under the abandoned cottage on Champions' Road; Announcer Grand Bellows) | - |
| Alchemist | Auntie Alembic's | - |
| The town well | the Old Well ("Wellspring" is a lore word only: the one spring that once fed all four Paths) | - |
| Postgame dungeon | the Path-ology Lab (boss: Dr. Ambrose Siphon, Chief Path-ologist) | - |
| Scientists of the Paths | Path-ologists (the field: Path-ology; founded by Elder Maren) | - |
| Fast travel | the Beefcake Rift Express (Rip Tearson and his cousins) | - |

Spellings to copy exactly: D.N.A. (the Department of Necrotic Affairs); CE-No; Path-ology; Doppelganger (no umlaut in names); Gerald,
Number 4,000,212; Kyle (Deceased Since '09); Bertram Beetsworth, Assistant to the Regional Merchant; Shiro Swindle, Master of the Oldest
Trick; His Majesty the Raccoon; Form 27-B/6.

## The four Paths

| Path | Service | Zone (id) | Resource / colour | Rival | Gatekeeper (road obstacle) | Main dungeon | Boss | True leader after the zone | Lieutenant |
|---|---|---|---|---|---|---|---|---|---|
| Beefcakes | energy and transport | the Gainlands (`beefcake`) | Iron / red | Necrocrats | Brick Bronson (gorge bridge) | the House of Gains | Chancellor Clench, Iron Regent | Grandmaster Flex, the Unbroken | Vivienne Quota |
| Gourmands | food and protection | the Endless Buffet (`gourmand`) | Ingredient / blue | Refusemancers | Chef Fennel Gravois (pantry door) | the Test Kitchen | the Doppelganger (later named Escoffina) | the Grand Chef | Colonel Cornelius Crumb |
| Necrocrats | death administration | the D.N.A. (`necrocrat`) | Red Tape / purple | Beefcakes | Prudence Pallor (permit barrier) | the Hall of Final Approvals | Mortimer Grimsby, CE-No | Agnes Overdue | Percival Plume |
| Refusemancers | waste removal and agriculture | the Verdant Dump (`refusemancer`) | Garbage / green | Gourmands | Moss Mulligan (thorn wall) | the Rotheart | Compostella, the Rotheart | Archdruid Compostella | Hortensia Clipwell |

Zone lessons: strength comes from the heart and mind; what you are called does not matter, what you do does; everyone deserves humanity,
even the dead; to grow, you have to let things go.

## Tokens

`{villain}` `{villain_title}` (data/story/villain.tres); `{prince}` `{prince_full}` `{royal_house}` `{king}` `{queen}` `{rescuer}`
`{rescuer_full}` `{kingdom}` `{town}` `{capital}` `{pathordia}` `{showcase}` (data/story/royal_family.tres); `{wanderer}` ("Wanderer", then the prince's
name after `prince_revealed`). Story files use tokens, never the literal names.

## Hard rules (locked)

- Walkable areas: only the forest, Crosspath, the four Path zones and the Capital (Oct 15 rule). Every dungeon is node-based; no
  explorable sub-areas, no walkable dungeons.
- No chapters.
- Enemy intent is never shown.
- No readable text in the 3D world: signs are pictures; words live in the "E to read" text.
- Primm is only seen or heard in person inside his castle (and in the postgame); elsewhere he is portraits, statues and decrees, and the
  loudspeaker voice is Percival Plume.
- The black market vendors (Fig Sly) are not to be changed.
- No two characters share a name. Oct 22: the game-only Wren Muckfoot is now Billie Muckfoot and the Gainlands ripper Rhonda is now Shredna
  (Wren of the Crease and Recycle Rhonda keep theirs). "Wren Muckfoot" and "Rhonda, Portal Ripper" are retired names.
- Power follows the story: one Path at the start, two after the first freed zone, all after Primm falls.
- Memory fragments follow the number of zones freed, not which zone.
- Sincere beats are played straight (captivity, grief, the leader reveals, the memories, Isla, Primm's fall).
- The card list is frozen: card names (including G-33 "Grand Chef Escoffina" and N-33 "Mortimer Grimsby, CE-No") stay as they are.
- No monetization decisions.

## Banned old names

Retired names that must never appear in player-facing text (story files, quest text, loading tips, UI strings, NPC names). Exact,
case-sensitive strings, one per line, for the banned-names test. Checked Oct 19 against `data/` (except `data/source/`, the sheet exports)
and `core/`, `world/`, `ui/`, `app/`.

- Pathavia
- Concord Crossing
- Concordia Prime
- Neatropolis
- Mabbit Quill
- Tilda Marrow
- Grandfather Marrow
- Haulsworth
- Odile Bisque
- Gus Peelings
- Zinnia Vex
- Z.V.
- Crucible & Co.
- Aurelio
- Saucier
- Thaddeus
- Commander Gristle
- Registrar of Final Approvals
- Fernwick Loam
- Torvin
- Corwyn
- Over-Seasoned
- Thistlebark
- Vesna
- Tuskmore
- Trial of the Hollow
- Central Throne
- Gate Captain
- Tiny Tony
- Dolcetta
- Heartlift
- Bev Pettigrew
- Head Spotter
- Grand Clashatorium
- Brenda
- Thimble's Hats & Hems
- Wren Muckfoot
- Rhonda, Portal Ripper

**Still present on Oct 19** (to fix; nothing else on the list was found):
- `Z.V.`: `data/story/intro_story.tres:116` (`town.alchemist.locked`, the note's signature).
- `Grand Clashatorium`: `world/town_scene.gd:962` (the arena spot's prompt string, "Enter the Grand Clashatorium"). Code comments, class
  names and `data/audio/audio_registry.json` (lines 29, 1399, internal track names) also use it; they are not player-facing.
- `Brenda`: `data/story/gainlands_story.tres:280`, in a quiz question's `"where"` authoring note (not shown to players).
- `Heartlift` and `Dolcetta` survive only as internal keys (`freed_npc.heartlift`, `npc.dolcetta.*`, `NPC_DOLCETTA`); the test should check
  text values, not keys.

**Allowed only in one fixed phrase** (a test should check the context, not ban the word):
- `Pathwork`: only in "the Pathwork Throne". Wrong use today: `data/loading/loading_tips.txt:35` and `:46` ("Pathwork has four Paths...",
  "Pathwork's four Paths...", meaning the kingdom).
- `Concordia`: only in "Queen Concordia (Wayweaver)" (and the music cue "Concordia's lullaby").
- `Gus`: only in "Foreman Gus" (the Capital's Gus became Rollo Spokes; id NPC-GUS is retired).
- `The Usurper` / `THE USURPER`: the retired placeholder for Primm; one in-character use remains in the same Alchemist note
  (`intro_story.tres:116`). Prefer `{villain}`.
- `The Rescuer`: her name until Plume names her at the castle gate (`rescuer_named`); write `{rescuer}`, never the literal name.
- `element`: retired in player text for the four Paths ("Choose your Path"); fine as a general word.
