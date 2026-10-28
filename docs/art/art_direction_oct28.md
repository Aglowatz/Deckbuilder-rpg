# Art direction review, Oct 28 (overnight Oct 27-28)

A zone-by-zone read of the whole game against the story (`docs/design/story_bible.md`, `canon.md`, `voice_bible.md`) and the Art Bible
(`docs/art/art_bible.md`), written from the Tier 2 reference shots (`docs/art/graphics_tier1/t2_after/*.jpg`), the Oct 23-27 bot and smoke
screenshots and the data. Nothing here was generated: every wanted picture is a row in **`docs/art/art_batch_oct28.csv`** (ChatGPT-ready
descriptions with the matching style lock) and the counts, batch order and import commands are in **`docs/art/art_batch_oct28.md`**. The
enemy roster rework (renames, looks, sizes) is **`docs/design/enemy_roster_oct28.md`**; the code side (sprites, cut-outs, importers) is in
the "Code readiness" section at the end.

How to read a zone entry: **Theme** (one sentence the art must say), **Palette** (the Art Bible's), **Story beat it must carry** (what the
player has to feel here for the story to work), **Who lives there**, **Foes** (who roams and why they serve the zone's ruler), **What is
there today** (the honest read of the shots), **Missing or clearly better** (ranked; H = first hours / main path, M = second visit, L = polish).

The four questions asked of every zone: consistency (does it look like one painted world?), theme (does the zone say its one sentence from
the first screen?), storytelling (can you read the regime, the ruler and the wound without a line of dialogue?), first-hour wow (is there
one thing in the first two minutes a player would screenshot?).

## 0. The whole game in one paragraph

The painted parts are the game's best look: the card art, the dungeon maps, the battleboards, the dialogue portraits and the sixty-six NPC
sprites all read as one world (clean bold shapes, soft cel shading, saturated characters on calmer scenery). The weak seam is everywhere a 3D
stand-in still shows through that paint: the roaming enemies (low-poly models with no face, in a world where every friendly character is a
painted sprite), the hero landmarks that are still coloured blocks (the Hall of Final Approvals' facade, the House of Gains on its rim, the
Capital's walls, the cake cathedral), the skies and far horizons (plain gradients behind painted foregrounds), and the moments the story
asks for a picture and gets a text box (freeing a zone, the Capital's reveal, the ending beats). The first hour already has three wow
moments (the forest at dusk, the Crosspath square, the first battle on a painted board); it is missing a fourth (the first roaming enemy
you meet is a grey capsule with an exclamation mark) and a fifth (the Forgotten Cave's boss has no entrance picture of his own).

Priorities, in order: (1) painted roaming enemies for the forest, Crosspath and the first zone; (2) boss / lieutenant / gatekeeper cut-outs
so every big entrance is a character, not a square; (3) Elder Maren's tortoise redo and the last 3D-model NPCs; (4) the story illustrations
the main line has nothing for (prologue wake is done; the four freeings, the castle gate, the throne, the reunion); (5) the hero landmark
paintings per zone; (6) cards, tokens, icons and the rest of the catalogue.

## 1. The Opening Forest ("The Forest Clearing", area `start`)

- **Theme:** a fresh start in the dark; the woods are kind to him before anyone else is.
- **Palette:** teal-blue dusk (#3F5E3A, #8DAA6B, #C9B98A, #6B4E3A, #A8C3C9); one warm amber lantern; cool mushroom glow leading to the cave.
- **Story beat it must carry:** the wake (leaves in his hair, a four-coloured glow fading from his hand), the hooded Rescuer who will not
  give her name, torches on the ridge, the Path choice, the cave mouth as the only way forward. Later the same clearing holds the Lab hatch
  (postgame), so the forest also has to be able to look "wrong" with roots and a hospital smell.
- **Who lives there:** the Wanderer, Elowen (painted sprite, hooded), the pursuers (never seen, only torches), later Rip's forest station.
- **Foes:** the Forgotten Cave's three fights are node battles (Cave Scavenger, Hollow Stalker, the Hollow Warden). Overworld roamers here are
  the regime's searchers at the treeline (see the roster doc: they become Primm's "Lost Property" patrol, lantern-carrying enforcers who are
  looking for an "improvement opportunity", which is him).
- **What is there today:** the strongest mood shot in the game. Teal gloom, god rays, the lantern camp and bedroll (the shadow-casting
  lantern from Tier 2), painted mushrooms, painted Elowen. The trees and ferns are 3D low-poly; the cave mouth is a dark gap in a rock wall
  that does not read as a destination until the mushrooms lead you to it; the ridge with the torches is not visible from the clearing.
- **Missing or clearly better:**
  - H: a **painted cave-mouth hero piece** (mossy Old Kingdom arch with the faint four-Path crest worked into the keystone; the royal escape
    tunnel should look royal once you know) - the first landmark of the game.
  - H: the **Hollow Warden cut-out** for the boss intro (moss-and-stone guardian, two tiny warm eyes; today the intro shows the Bestiary square).
  - H: **painted roaming patrol sprites** (the forest's three roamers) in the NPC sprite style.
  - M: a **torchline backdrop strip** (transparent sky): the ridge with five torches, so the threat Elowen talks about is on screen.
  - M: **mossy giant-tree cut-outs** (3) and a fallen-log hero prop at storybook scale (trees 2.5-4x character height), replacing the round
    3D blobs at the clearing edge where the tilt-shift does not hide them.
  - L: the Lab hatch as a painted prop (round steel hatch, roots, a sickly green seam of light) for the postgame reveal.

## 2. Crosspath (hub town, `town`)

- **Theme:** the town where the four Paths used to meet; cosy, golden, watched.
- **Palette:** golden late afternoon (#E8B86B, #F2E3C6, #C4573A, #6E8B4E, #5B4636, #6F8FB0).
- **Story beat it must carry:** home base and the royal crest hidden in plain sight (the fountain's four plinths, Maren's stick); five roads
  out, four of them blocked by a corrupted gatekeeper; the town gets louder with every freed zone (the crier, banners, Isla walking home).
- **Who lives there:** Elder Maren (tortoise), Brannoch (bear), the six vendors, Bellows (walrus), Old Hob (ghoul, Death), Brindle the
  Baker (badger), townsfolk, the four corrupted gatekeepers, Shiro's giant chest, the storeroom ghosts, the Secret Dealer (do not touch).
- **Foes:** the four gatekeepers (painted sprites already); the Storeroom Ghosts (three lantern-buyers, a scripted fight); the Restless
  Cairn; the Undercroft's eight arena foes (the Marshal is Bellows); town roamers on the lanes (regime "Visitors" in the roster doc: Primm's
  census takers measuring doors). Every town foe should look like the regime visiting a town that is not theirs: grey coats, clipboards,
  tape measures, one approved smile.
- **What is there today:** the best-dressed area. Half-timbered kit, hanging icon signs, painted townsfolk and vendors, the fountain, the
  square's warm bounce light. Weak spots: the far horizon is a soft gradient with vague blue hills (no painted backdrop strip, so the
  Capital's castle on the skyline is a grey smudge); the fountain is a plain stone model (the Art Bible asks for a redesign with the four
  plinths as a readable royal crest); the gate guards and census roamers are 3D capsules; the Undercroft cottage reads as any cottage.
- **Missing or clearly better:**
  - H: **painted town roamers** (3 sprites).
  - H: the **Elder Maren redo** (tortoise: portrait with 3 expressions + 4 world sprites) - she is the first face the game relies on.
  - H: **Gatekeeper cut-outs** x4 (Bronson, Pallor, Gravois, Mulligan, corrupted looks; their portraits are already transparent and can be
    used tonight; a cut-out is only the wider waist-up framing if wanted).
  - M: a **horizon backdrop strip** with the Capital's white castle far north and the four zones' silhouettes on the four compass sides (a
    gorge and a wheel east, a gloom and a hall, a pink cake dome, a violet ravine).
  - M: the **royal-crest fountain** as a painted hero prop (four plinths in a ring, four coloured spouts).
  - M: **freed-town banners**: four banner cut-outs (one per Path) that hang on the square after each freed zone (the town "gets louder").
  - L: the Undercroft cottage with a cheering-cellar glow decal; the Restless Cairn as a painted stone.

## 3. The Gainlands (Beefcakes, `beefcake`)

- **Theme:** sunny, loud, exhausted: a gym run like a bureaucracy of muscle.
- **Palette:** bright midday (#F2C14E, #D9483B, #8BC34A, #F7EBD3, #7A5230, #5FA8D3).
- **Story beat it must carry:** Clench's regime (quotas, confiscated weights, endless wheels) on top of a people who are kind and tired; Flex
  imprisoned under the House; the lesson "strength comes from the heart and mind". The flag: a barbell with a red line through it.
- **Who lives there:** Old Man Mountain (yeti), Coach Benchley (minotaur), Big Hurl (stone troll), Rip Tearson, Professor Pump (rhino), Chet
  Thunderabs, Foreman Gus, Gary (under a barbell), Shredna; Vivienne Quota (ferret) as the regime's mind.
- **Foes:** the regime's gym enforcers. Today: Flexing Brute, Protein Shake Golem and the Iron Cave's leg-day crowd. In the roster doc they
  become **Quota's Quota Squad**: Spotter Sergeants (buff goats with stopwatches), Wheel Wardens (hamsters in regime caps who make others run),
  the Protein Golem stays (a tub-shaped golem leaking shake). Every one carries the crossed-out barbell and a clipboard: they are not gym
  bros, they are the people who count your reps for Clench.
- **What is there today:** sunny and readable: the bridge with banners, the plaza, the gym hall with painted banners, the hamster wheel
  silhouette, the power lines, water. The plateau rock texture tiles visibly in the mid-ground; the House of Gains on the north rim is a
  blurry red block; the floating islands are discs; the Mount Swolympus gate is a plain arch; the mountains behind are a fuzzy band.
- **Missing or clearly better:**
  - H: **painted roamer sprites** (3 foes x 4 directions).
  - H: **Chancellor Clench cut-out** and **Brick Bronson** (exists as a portrait) for the intros; **Baron Quadzilla** (S-IRON) has no portrait.
  - M: the **House of Gains facade** as a painted backdrop piece on the rim (marble columns in chains, propaganda banners, a barbell
    flagpole) - the story's "it is under the House" needs a House.
  - M: the **Colossal Hamster Wheel** hero landmark painted (today a thin 3D wheel).
  - M: **floating island cut-outs** (3 sizes) with rope and chain.
  - L: regime posters (3 decal sheet: the crossed barbell, "QUOTA" stopwatch, Clench's profile) for walls; the Swolympus trailhead gate.

## 4. The D.N.A. (Necrocrats, `necrocrat`)

- **Theme:** an afterlife run as a government office at 4:59 PM forever; deadpan, grey-green, kind underneath.
- **Palette:** cold overcast (#6E7470, #9BB59A, #3D4A44, #C9C6B8, #4FBF7A ghost green, #8A2E2E stamp red).
- **Story beat it must carry:** "the authorization is valid"; Agnes at the front desk with her stack; Gerald's number never called; the Hall
  of Final Approvals on the skyline as the place where no is decided; the lesson that everyone, even the dead, deserves humanity.
- **Who lives there:** Agnes Overdue (ghost), Gerald (ghost), Clerk Ledgerbone (skeleton), Director Ectomund, Kyle (ghost), Prudence Pallor
  (skeleton, after the zone), Mortimer Grimsby (skeleton), Undersecretary Vellum, Betty Bones; Percival Plume (peacock) on the loudspeakers.
- **Foes:** the office's undead staff doing their jobs. Today: Shambling Middle Manager, Zombie Intern. In the roster doc they become the
  **Compliance Department**: the Shambling Middle Manager stays (a zombie in a crooked tie, a mug that says nothing), the Zombie Intern
  becomes the **Unpaid Intern** (a smaller zombie buried under a stack of forms, with a Hazmat Intern variant in a yellow suit for the new
  card), plus a **Filing Wraith** (a ghost whose body is a filing cabinet with drawers for ribs). They serve Mortimer because the form says so.
- **What is there today:** the mood is right (gloom, checkerboard floors, drifting papers, ghost-green lamps, the causeway). The Hall on the
  skyline is a dark rectangle; the cubicle walls are flat marble slabs; the sky is a flat overcast plate; the office interior is bare.
- **Missing or clearly better:**
  - H: **painted roamer sprites** (3 foes).
  - H: **Mortimer Grimsby cut-out** (exists as a portrait), **Prudence Pallor** (exists), **Undersecretary Vellum** (portrait exists?), **Betty
    Bones** (exists) for intros.
  - M: the **Hall of Final Approvals facade** painted (columned civic hall with a clock stopped at 4:59, filing-cabinet towers behind) as the
    skyline backdrop with transparent sky.
  - M: a **filing-cabinet tower** cut-out (3 heights) and a **queue of ghosts** cut-out sheet (six waiting ghosts with numbers).
  - M: **ghost lamp** and **dead topiary** props painted (2 sheets).
  - L: a wall decal sheet of forms, DENIED stamps and the Form 27-B loop (no legible text; stamp shapes only).

## 5. The Endless Buffet (Gourmands, `gourmand`)

- **Theme:** a banquet that is secretly a weapons factory; warm dinner light over an "innovation" pitch.
- **Palette:** warm evening (#F4D8B0, #E07A5F, #C98B3A, #F6B8C4, #6B8E3D, #7A4A2A); candle and oven glow, steam.
- **Story beat it must carry:** the Chef who never tastes; golems that say "Yes, Chef!"; the Special Sauce in every pot; chefs who flinch at
  the word "weapon"; the lesson that what you are called does not matter.
- **Who lives there:** Basil (rabbit), Madame Mirepoix (Persian cat), Professor Pate, Chef Flambe Fontaine, Sous-Chef Tarragon, Old Meatloaf
  (broken golem), the Grand Chef (in the freezer), the Doppelganger; Colonel Crumb (badger) as the regime's mind.
- **Foes:** the kitchen's war programme. Today: Meatloaf golems, sauce-maddened cooks. In the roster doc they become **Crumb's Culinary
  Defense**: the **Gravy Boat Golem** (a soup-tureen golem on little legs, steam for breath), the **Sauced Sous-Chef** (a cook with Special
  Sauce dripping from the ladle and swirl eyes), the **Prototype Whisk** (an unfinished war machine: a whisk-armed stove on treads with a
  "FOR THE WAR EFFORT" rosette and no letters). They serve the Doppelganger because the sauce says so.
- **What is there today:** warm and funny: the tablecloth road, the cloche posts, painted broccoli trees, the cake dome in the far pink.
  The buildings are blurry cake-coloured blocks; the gravy river is not there; the Test Kitchen is a dark box at the back; the tasting
  stands are generic stalls; the pepper-pot fence is good.
- **Missing or clearly better:**
  - H: **painted roamer sprites** (3 foes).
  - H: **Doppelganger cut-out** (portrait exists and already slides in), **Chef Gravois** (exists), **the Itamae Supreme** and **Colonel Crumb**
    (portrait exists) for intros.
  - M: the **cake cathedral** hero landmark (tiered cake with copper domes and a frosting rose window) painted as a backdrop piece.
  - M: the **Test Kitchen facade** (a chrome-and-copper laboratory kitchen with a cheerful "innovation" banner shape and smoke that is not
    quite steam) painted; the **gravy river** water tint and a bridge prop.
  - M: **tasting-stand cut-out sheet** (prototype tastings under cloches, a golem guard beside each) and a Yes-Chef golem guard sprite.
  - L: Crumb's rosette decal sheet for posters.

## 6. The Verdant Dump (Refusemancers, `refusemancer`)

- **Theme:** a junkyard farm that nature has reclaimed, now reclaiming too much; golden hour over violet terraces.
- **Palette:** golden-hour sunset (#7C8F45, #B5552D, #E3A857, #5C6B5E, #8B6D4C, #E9D8A6) with the v2 violet ravine.
- **Story beat it must carry:** raccoons are royalty, goats eat signs, and under the gags a wrongness that never stops growing toward the
  Rotheart (the corruption gradient); the eleven birthday trees; the lesson that to grow you have to let things go.
- **Who lives there:** Brother Bramble (hedgehog), Granny Gristle (opossum), Druid Thistlewick (stag-headed), Recycle Rhonda, Billie
  Muckfoot, Moss Mulligan (faun, after the zone), the raccoons, the goats, Archdruid Compostella; Hortensia Clipwell (hare) as the mind.
- **Foes:** the overgrowth's creatures and Clipwell's tidiness. Today: Compost Shamblers, Thorn Goats, mutant bees. In the roster doc they
  become the **Hungry Green** and **Clipwell's Tidy Patrol**: the **Compost Shambler** stays (a walking heap with a sprouting watering can),
  the **Thornback Goat** (a goat armoured in brambles, chewing a sign), the **Topiary Warden** (a hedge trimmed into Primm's silhouette that
  walks, Clipwell's shears stuck in its side). The first two serve the Rotheart; the third serves Clipwell.
- **What is there today:** the best atmosphere after the forest: haze, fireflies, violet trees, the windmill gate, terraces. The two blue
  triangle flags at the bridge are flat primary blue in a warm scene (wrong palette); the Rotheart tree is not visible on the skyline (the
  backdrop has no sky-transparent piece); the junk peaks are moss lumps; the Trash Panda Throne's dumpster is a box.
- **Missing or clearly better:**
  - H: **painted roamer sprites** (3 foes).
  - H: **Compostella, the Rotheart cut-out** (portrait exists), **Moss Mulligan** (exists), **His Majesty the Raccoon** (portrait exists) and
    **Hortensia Clipwell** (exists) for intros.
  - H: the **Rotheart backdrop with transparent sky** (the user's item): the great hollow tree with root-veins of sickly green on the far
    ravine wall, wide enough for the terraces' horizon band, sky fully transparent.
  - M: the **junk mountain** hero landmark painted (tyres, a rusted car, a goat on top); the **Trash Panda Throne** dumpster with bottle-cap
    banners.
  - M: recolour the entrance flags to the zone palette (moss green and rust; a data fix if the flags are kit cut-outs; otherwise a 2-piece sheet).
  - L: a corruption decal sheet (fungus clusters, split roots) for the Throne Approach.

## 7. The Capital: outside and inside (`final`)

- **Theme:** outside, a drained wasteland under a perfect white wall; inside, a pastel facade over a broken city, "the gap between the slogan
  and the whisper".
- **Palette:** outside flat overcast dusk with purple rift glow (#8C8A86, #5E5B57, #B9B2A4, #9B59D0, #D8D0C0); inside shadowless noon
  (#F7F3EA, #E6C35C, #F5C6D0, #BFE3D0, #A7C7E7, #7FC97F).
- **Story beat it must carry:** the hunt for an "escaped Royal Asset" (posters), Captain Spotless and the approved height, rifts that opened
  the night the boy got out, the Showcase Quarter's sixteen identical houses and nine Perfectly Happy Citizens, the four broken-service
  districts (dark Transit Yards, the Hungry Quarter's paste, Grave Row's identical stones, the Reek's banished compost), the Crease
  underneath, and the castle on its hill as the end of every road.
- **Who lives there:** Wren (wren), Fig Sly (weasel; untouched), Kestrel, Nurse Hesper, Captain Spotless, Widow Pell, Rollo Spokes, Chef Marlo
  (mole), Old Fern (gnome), the Citizens, Isla (bear) at the end; Primm only as portraits, statues and decrees.
- **Foes:** the regime proper. Today: Enforcers, Rift Wretches, Shard Swarms, gate guards. In the roster doc they become the **Ministry of
  Correction**: the **Correction Officer** (a tall enforcer in white-and-gold with a mirror visor, a ruler on the belt), the **Smile
  Inspector** (a short official with a protractor, measuring smiles at eleven degrees), the **Rift Wretch** stays (a citizen half-unmade by
  a rift, purple seams) and the **Shard Swarm** stays as a sprite cluster. The castle elites (Plume, the Hall of Mirrors) and Primm have their
  own cut-outs.
- **What is there today:** the contrast works: grey cracked road, dead trees, the white wall; inside, pastel chequerboard, the Primm fountain,
  identical houses, citizen sprites. The wall and castle are low-detail white blocks with blurry towers; the gate guards are 3D with floating
  text labels ("GATE GUARD (EXIT CONTROL)" is readable text in the world, against the hard rule - it is a UI label on an NPC but it reads as
  signage; see the inbox); rift crystals are purple shards without paint; the posters are not visible from the road.
- **Missing or clearly better:**
  - H: **painted roamer sprites** (4 foes).
  - H: **Captain Spotless cut-out** (portrait exists), **Vivienne Quota** (exists), **Colonel Crumb** (exists), **Percival Plume** (exists),
    **Primm** (exists; three phase variants wanted: polished, cracked, unravelled), **Siphon** (exists) for intros.
  - M: the **great white wall and gate** painted as a backdrop piece (outside) and the **castle facade** on its hill (inside; the kit's
    CAPI-HERO-PALACE-FACADE concept exists as reference).
  - M: the **lost-property poster** decal sheet (3 states: the silhouette, the "Height: yours" version after the reveal, defaced).
  - M: **rift cut-out** (3 sizes, additive purple) and a **rift-sealed stone** prop.
  - L: Primm statue variants (gold, toppled), the Correction Ward's protractor sign.

## 8. Dungeons and mini-dungeons (node maps)

Every dungeon has a painted 3:2 map and a battleboard, and the inventory confirms all 15 maps and all 25 boards exist on disk (the Paste
Works and the Lab included; `art_backlog.md`'s map rows are done and `Battleboards.STANDIN_BOARDS` is dead data). The node foes' Bestiary
squares exist for every nameless foe; the 21 missing squares are all speaking bosses, elites and lieutenants (they show a crop of their
dialogue portrait meanwhile) and are rows of the catalogue beside their cut-outs.

The Forgotten Cave (D-TUT) deserves one more picture: its three foes are the first three enemies anyone fights and two of them (Cave
Scavenger, Hollow Stalker) have Bestiary art already; the Hollow Warden is the first boss intro and shows a square. H.

## 9. The Path-ology Lab

- **Theme:** sterile, quiet, wrong; the horror is how ordinary the equipment is; one warm thing per room.
- **Palette:** #E4EAEE, #9FB4C4, #4C5B66, #8A5A3C roots, the four Path glows.
- **Story beat:** the Prince's old cell (tally marks, a child's four-colour drawing), the Draining Chamber, the Rescuer's cell, the Mentor's
  Study, Siphon's "my finest work".
- **Missing:** Siphon's cut-out and Bestiary square (his portrait exists), and one story still: **Cell 4** (the drawing on the wall, Elowen
  in the cell doorway), the postgame's one sincere picture. The map, the board, the foes' squares and the T-24 / T-25 tokens all exist.

## 10. Battles

- The battleboards, card frames, HUD plates and the tray are consistent and finished. The enemy's round portrait at the top left is a
  Bestiary square when one exists, otherwise a portrait crop or an icon; roaming enemies with no Bestiary art show a game-icons silhouette
  there, which is the one unpainted thing on an otherwise painted screen in the first hour. Every roaming enemy's Bestiary square is therefore
  H in the catalogue (the same character as its sprite, described identically).
- The **boss intro** (see "Code readiness"): a cut-out character sliding in over the letterbox beside the name card, the Oct 23 look of the
  Doppelganger, for every boss, lieutenant and gatekeeper; the Bestiary square stays the fallback.
- Every token has art now (T-24 Elowen Vey, Defector and T-25 Failed Experiment arrived); the 15 cards without art are the Oct 27 review's
  new rows and the Hazmat Intern, whose sheet rows carry only the style lock: each has a real description in the catalogue.

## 11. Menus, screens and UI

- The UI kit (55 pieces) is complete and consistent; the Collection Book, Deck Station, vendor screens and the map screen are finished.
- Missing: the four lieutenant relic icons (Quota's Stopwatch, the Colonel's Ladle, Plume's Quill, Clipwell's Shears show the placeholder
  gear icon), eight feat group icons for Part 3's Feats screen (existing icons stand in), and the Leaf Crown redo the user asked for (its
  five views exist; the catalogue row replaces the sheet by the same name). Loading screens, zone title cards, vendor screens, item and
  cosmetic icons and the UI kit are complete (27 / 7 / 12 / 18 / 10 / 55 on disk).
- Approved art on disk that nothing uses: three Bestiary squares of retired names (REGIME-CHECKPOINT-CAPTAIN, ROOTBOUND-MILLER,
  OBSERVATION-WARD-ORDERLY), three registered backdrops no scene references (DUMP-BD-ROTHEART with its sky baked in, DUMP-BD-JUNK,
  GAIN-SKY-NOON) and the 18 character look-test frames; the table is in `art_batch_oct28.md`. Nothing is deleted tonight.

## 12. Elder Maren: the tortoise

The sheet, the story bible, the voice bible and the dialogue all say tortoise ("Slow and steady, dearie. I invented that. The hare has never
forgiven me."; the court boy who asked why tortoises carry their houses). Her current portrait (`NPC-ELDER.webp`, plus `_HAPPY`, `_WORRIED`)
and her four world sprites are a human grandmother with braids and spectacles who happens to carry a tortoise shell and have tortoise feet:
a halfway look that reads as a costume. She goes back to an old tortoise proper, keeping everything the player already knows her by: the
patchwork shawl in the four Path colours, the round spectacles, the walking stick carved with the four Path marks, the pie.

**Canonical look (portrait, sprite and any Bestiary / battle art must match):** an elderly anthropomorphic tortoise, about 0.7 of the
Wanderer's height, standing upright. A domed mossy shell with wildflowers growing in the seams, worn like a backpack under the shawl; a
long wrinkled neck; a wise beaked face with heavy-lidded amber eyes behind small round brass spectacles; a few wisps of white hair under a
knitted cap. Patchwork shawl (blue, green, mustard, rose), cream robe, a leather satchel of pie tins, the Path-marked walking stick. Warm,
grumpy, kind. Expressions: base (patient, one eyebrow up), HAPPY (a small closed-eyed smile, pie offered), WORRIED (neck drawn in a little).

Dialogue lines that mention her look were checked (every Maren line against tortoise / shell / human / woman words): no line calls her
human; "Slow and steady, dearie. I invented that." and the court boy who asked why tortoises carry their houses already say tortoise. One
idle line speaks of tortoises as "them" ("Even the tortoises use them. I passed one this morning. Barely.") and is listed as an optional
rewrite in `docs/dialogue/lines_to_update_oct28.csv`. No frozen dialogue file names a renamed roamer, so the renames need no lines.

## 13. Code readiness (what was built tonight so new art swaps in by itself)

- **Boss intro** (`ui/battle/boss_intro.gd`, `Bestiary.cutout`): the entrance now slides a transparent cut-out character in from the left
  over the letterbox bars, feet in the lower bar, beside the name card; no box. The picture is the imported `CUT-<NPC key>` file if one exists
  (a new Portrait Image ID family the portrait importer accepts, kept 1080 px tall), else the dialogue portrait itself (already transparent:
  this is what every boss, lieutenant and gatekeeper shows tonight), else the old Bestiary square pushing in (foes with no speaking character:
  the Restless Dead, Baron Quadzilla, Colonel Casserole, the Wellspring's Echo). `Bestiary.cutout_ids()` lists the 24 cut-outs the intros
  can use; all 24 are rows of the catalogue. Shot: `docs/overnight/oct27/intro_warden_cutout.png`.
- **Roaming enemies** (`ZoneEnemyInfo.sprite_key`, `ZoneEnemy._make_model`): every roamer's sprite set is the world-sprite character
  `FOE-<slug of its name>` (files `SPR-FOE-QUOTA-SPOTTER-FRONT_IDLE.png`...), brought in by the existing "import npc sprites" line; the enemy
  node draws a `SpriteActor` instead of its model as soon as the set exists and skips the model-only tint / accessory / ghost / waddle code.
  The three town roamers joined the Bestiary. Renamed roamers keep old saves' Collection Book counts and old pictures (`Bestiary.RENAMED`,
  `legacy_art_ids`).
- **Maren** needs no code: her new portrait, expressions and sprites replace the current files by the same IDs (the importers re-copy on a
  changed MD5).
- **Tests**: `tests/core/data/test_enemy_art_oct28.gd` (renames and counters, legacy pictures, unique sprite keys for every roamer, the
  town entries, cut-out ids for every entrance, the portrait fallback).

## 14. Story-scene illustrations planned

Seven stills exist (the wake, Flex's reveal, the Doppelganger's true form, the Hall's approval, the Rotheart, Primm's end, the reunion).
Everything else the story asks a picture for is a code-drawn stage of tinted glyphs or text over a vignette. The catalogue designs fifteen:

| Still | Beat | Why it matters | Priority |
|---|---|---|---|
| STORY-CAPTURE | Elowen taken at the castle gate (`pc_capture`) | the main path's cruellest beat; Plume names her | H |
| STORY-THRONE | the Pathwork Throne (ending beat 8) | the climax: everything returns at once | H |
| STORY-WONDER | the true Chef's dish (`wonder`) | the Buffet's freeing has a reveal still but not the resolution | H |
| STORY-MEMORY-3 / -4 | the coup; a name | the two reveals of the memory chain | H |
| STORY-VACANCY | Agnes takes the office | the D.N.A.'s resolution | M |
| STORY-SEVER | letting the seed die | the Dump's resolution | M |
| STORY-MODEL-ROOM | Primm at the model (`primm_intro`) | the first time he is seen in person | M |
| STORY-KEPT-FACE | "I kept your face" (`primm_reveal`) | the darker reveal | M |
| STORY-FACADE-FALLS | the facade falls (ending beat 3) | the kingdom seen honestly | M |
| STORY-CELL-4 | the Prince's old cell | the postgame's sincere picture | M |
| STORY-FUNERAL | the royal funeral | played straight | M |
| STORY-HOME | Isla comes home | Brannoch's gate pays off | M |
| STORY-MEMORY-1 / -2 | warmth; the cells | the first two fragments | M |

Each row carries the composition, who is in it (by portrait ID), the light and the mood. Wiring is one line per still once a file exists
(the cutscene, ending and memory definitions name their picture).
