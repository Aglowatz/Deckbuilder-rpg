# Art Bible: The Wayward Path

The single source of truth for the world's look. Every paint-over, ChatGPT batch and Claude prompt follows it.
Source: `data/source/art_bible.csv` (export of the sheet's "Art Bible" tab). Edit the sheet, re-export the CSV, and update this file.
Per-area numbers the engine reads live in `data/zone_styles/<area>.json` (hot-reloaded in debug builds; see `docs/art/zone_styles.md`).

## Global rules

| ID | Rule | Details |
|---|---|---|
| G-01 | Scale: Storybook (B) | Characters are 85-90% of a door's height. One story of a building is about 1.5x character height; a one-story house with roof is 2-3x character height. Doors and windows are oversized; walls short; roofs chunky with deep overhangs. Trees are 2.5-4x character height, rounder. Props are slightly oversized (a barrel reaches a character's waist, a crate the hip). Big/small NPCs keep their Relative Height. |
| G-02 | Camera | Fixed facing direction (no free 360 rotation). Small swivel: the player can turn about 15-20 degrees left/right; it eases back when released. Angle presets: Cinematic (about 20 degrees), Classic (about 30), Overview (about 45). Zoom presets: Close, Normal, Far. Every combination auto-adjusts tilt-shift and FOV. Characters are about 10-12% of screen height at Normal zoom. Every area must look finished at all 9 combinations. |
| G-03 | Readability | Characters are always the clearest, most saturated things on screen. The environment is calmer and slightly less saturated. No readable text in the world (signs use icons; info appears in UI). |
| G-04 | Light does the work | One warm or mood-specific key light per area with soft readable shadows; baked ambient occlusion so corners, eaves and gaps are darker; warm local lights (windows, lanterns, magic); darker frame edges; light haze for depth. Time of day per area is fixed (see zone rows). |
| G-05 | Density | Props cluster at doorways, walls, path junctions and landmarks; open space only around important spots (plazas, arenas, vistas). Never evenly scattered. Rule of interest: something worth seeing or doing every 15-20 seconds of walking. |
| G-06 | Framing | Always something soft in the foreground at a screen edge (eave, branch, fence, banner) that the tilt-shift blurs, plus a landmark or backdrop in the distance pulling the player forward. |
| G-07 | Zone structure | The only walkable, explorable areas in the game are the starting forest, the main town, the four Path zones (Gainlands, D.N.A., Endless Buffet, Verdant Dump) and the Capital (outside and inside). There are no additional explorable areas: no sub-area scenes, no walkable dungeon interiors, no walkable antechambers. All dungeons (main, mini and side) are node-based: an entrance in the zone opens the node map. Variety comes from regions within each zone, each with its own landmark and mood; paths loop (no dead ends without a reward); shortcuts open later. (Replaces the hub-plus-sub-areas rule, 2026-10-15; see `docs/design/subarea_removal.md`.) |
| G-08 | Asset layers (resource-friendly) | Layer 1: shared kit (building parts, props, tools), made once. Layer 2: per-zone material swaps and engine palette tinting (one neutral texture tinted per zone). Layer 3: 3-6 hero landmarks per zone (where the art budget goes). Layer 4: ChatGPT makes sheets of 4-6 related items per image (doors, windows, signs), which Claude slices apart. |
| G-09 | Per-zone budget | About 30-45 new images per zone in 2 ChatGPT batches: 1-2 paint-overs, 8-10 surfaces, 3-4 cutout sheets, 4-6 trees/plants, 4-8 props, 3-6 hero landmark concepts, 4-6 decals, 2-4 sky/backdrop pieces. |
| G-10 | Style | Painted, not pixel: clean bold shapes, soft cel-shaded painting, rich but harmonious colours, matching our card art, portraits and PAINTOVER-TOWN.png. Each zone's paint-over is its visual target. |

## Zones

Style file ids (`data/zone_styles/<id>.json`) are in brackets.

### Main Town (Crosspath) [main_town]
- **Time of day / lighting:** golden late afternoon; long warm shadows; lit windows and lanterns.
- **Palette:** #E8B86B (dominant), #F2E3C6, #C4573A, #6E8B4E, #5B4636, #6F8FB0.
- **Mood:** cozy, welcoming, home base.
- **Building language:** half-timbered storybook cottages and shops, stone foundations, red and slate roofs, flower boxes, hanging icon signs.
- **Material swaps:** the current kit (ENV-*) as is.
- **Hero landmarks:** fountain (redesign in palette), the four-Path signpost plaza, graveyard chapel, lakeside dock, the Arena.
- **Regions (one walkable area):** Market Square (the hub), Residential Lanes, Lakeshore and Docks, Graveyard, Arena District. No sub-area scenes.
- **Foliage and props:** oaks, fruit trees, hedges, flower clumps; barrels, crates, stalls, carts, lanterns.
- **Budget:** town kit done (48); about 10-15 more (fountain, roofs, lamp posts, banners, dock pieces, chapel).
- **Paint-over:** approved (PAINTOVER-TOWN).

### Starting Forest [starting_forest]
- **Time of day / lighting:** dusk into night (the Opening Forest paint-over, OF-01): deep teal-blue gloom, layered ground mist, pale moon rays through the canopy, a warm amber lantern at the camp and cool glowing mushrooms leading to the cave.
- **Palette:** #3F5E3A (dominant), #8DAA6B, #C9B98A, #6B4E3A, #A8C3C9.
- **Mood:** quiet, mysterious, a fresh start.
- **Building language:** almost no buildings: a ruined shrine, an old waystone, a rope bridge, the cave mouth.
- **Material swaps:** stone and timber from the shared kit, heavily mossed.
- **Hero landmarks:** ancient waystone, the Forgotten Cave entrance, a fallen giant tree, the secret tunnel.
- **Regions (one walkable area):** The Clearing (the hub), The Old Path, Mossy Hollow, Cave Mouth, Hidden Tunnel. No sub-area scenes.
- **Foliage and props:** huge mossy trees, ferns, mushrooms, fallen logs, roots.
- **Budget:** about 25-30. **Paint-over:** needed.

### The Gainlands (Beefcake) [gainlands]
- **Time of day / lighting:** bright midday sun; crisp shadows, saturated sky.
- **Palette:** #F2C14E (dominant), #D9483B, #8BC34A, #F7EBD3, #7A5230, #5FA8D3.
- **Mood:** energetic, sunny, comically macho.
- **Building language:** sturdy timber-and-brick mills and gym halls, rope and iron details, red-gold banners.
- **Material swaps:** shared kit in sun-bleached wood, red brick, brass; gym-mat and chalk ground.
- **Hero landmarks:** giant hamster-wheel mill, Swole Station rift platform, floating islands, the outdoor Proving Grounds, Mount Swolympus trailhead.
- **Regions (one walkable area):** Swole Station (the hub), Mill Fields, Floating Islands, Proving Grounds, Sky Garden (secret), Swolympus Trailhead. No sub-area scenes.
- **Foliage and props:** sunflowers, hay bales, pines; dumbbells, weight racks, protein stands, throwing catapults.
- **Budget:** about 40. **Paint-over:** draft exists (PAINTOVER-GAINLANDS); redo at storybook scale.

### The Department of Necrotic Affairs (Necrocrat) [dna]
- **Time of day / lighting:** perpetual 4:59 PM overcast gloom; cold flat light with green ghost glows.
- **Palette:** #6E7470 (dominant), #9BB59A, #3D4A44, #C9C6B8, #4FBF7A, #8A2E2E.
- **Mood:** bureaucratic, gloomy, deadpan funny.
- **Building language:** gray stone office blocks, filing-cabinet towers, queue barriers, columned civic halls.
- **Material swaps:** shared kit in gray stone, dark paneling, wallpaper; carpet, marble, linoleum ground.
- **Hero landmarks:** filing-cabinet tower, the endless queue, the Hall of Final Approvals facade, the Records Basement entrance.
- **Regions (one walkable area):** Lobby Plaza (the hub), Cubicle Fields, The Queue, Records Basement, Executive Approach. No sub-area scenes.
- **Foliage and props:** dead topiary, potted office plants, ghostly lilies; desks, stamps, paper stacks, queue ropes, ghost lamps.
- **Budget:** about 40. **Paint-over:** needed.

### The Endless Buffet (Gourmand) [buffet]
- **Time of day / lighting:** warm dinner-time evening; candle and oven glow, steam.
- **Palette:** #F4D8B0 (dominant), #E07A5F, #C98B3A, #F6B8C4, #6B8E3D, #7A4A2A.
- **Mood:** indulgent, warm, absurdly delicious.
- **Building language:** cake and pastry buildings, oven-brick kitchens, copper domes, tablecloth awnings.
- **Material swaps:** shared kit in frosting, biscuit, copper, oven brick; mashed-potato and biscuit ground.
- **Hero landmarks:** cake cathedral, gravy river with bridges, broccoli forest, the Test Kitchen facade, Omakase cliffs.
- **Regions (one walkable area):** Grand Dining Hall (the hub), Mashed Potato Hills, Broccoli Forest, Bakery District, Omakase Cliffs. No sub-area scenes.
- **Foliage and props:** broccoli trees, herb bushes, cheese boulders; cutlery, pots, cloches, sacks of flour.
- **Budget:** about 40. **Paint-over:** needed.

### The Verdant Dump (Refusemancer) [heap]
- **Time of day / lighting:** golden-hour sunset; warm haze, long shadows, fireflies.
- **Palette:** #7C8F45 (dominant), #B5552D, #E3A857, #5C6B5E, #8B6D4C, #E9D8A6.
- **Mood:** scrappy, hopeful, nature reclaiming junk.
- **Building language:** patched shacks of scrap metal and old doors, overgrown with moss and vines, rusty windmills.
- **Material swaps:** shared kit in rusted metal, mossy wood, patchwork panels; junk gravel and compost ground.
- **Hero landmarks:** junk mountain, rusty windmill, the Rotheart tree (in the distance), Trash Panda Throne.
- **Regions (one walkable area):** Compost Commons (the hub), Junk Mountains, Farm Rows, Wildflower Wetlands, Throne Approach. No sub-area scenes.
- **Foliage and props:** wildflowers, vines, reeds; tires, bottles, crates, compost heaps, goats on car roofs.
- **Budget:** about 40. **Paint-over:** needed.

### The Capital: Outside (Wasteland) [capital_outside]
- **Time of day / lighting:** flat eerie overcast dusk; purple rift glow.
- **Palette:** #8C8A86 (dominant), #5E5B57, #B9B2A4, #9B59D0, #D8D0C0.
- **Mood:** bleak, uneasy, drained.
- **Building language:** ruined outposts, broken roads, the huge perfect walls.
- **Material swaps:** shared kit broken and ashen; cracked road and ash ground.
- **Hero landmarks:** the great white walls and gate, open rifts, the Old Service Tunnels entrance, the secret wall passage.
- **Regions (one walkable area):** The Gate Road (the hub), Rift Fields, Ruined Outpost, Tunnel Entrance. No sub-area scenes.
- **Foliage and props:** dead trees, dead grass; rubble, broken carts, rift crystals.
- **Budget:** about 30. **Paint-over:** needed.

### The Capital: Inside (Primm's Perfection) [capital_inside]
- **Time of day / lighting:** flat, shadowless, unnaturally perfect noon.
- **Palette:** #F7F3EA (dominant), #E6C35C, #F5C6D0, #BFE3D0, #A7C7E7, #7FC97F.
- **Mood:** too perfect, eerie, quietly wrong.
- **Building language:** identical pastel facade houses, white-and-gold civic buildings, perfectly symmetrical.
- **Material swaps:** shared kit in pristine white plaster, gold trim, pastel paint; pastel plaza and perfect lawn.
- **Hero landmarks:** Primm statue fountain, identical houses row, the four broken-service districts, the palace approach.
- **Regions (one walkable area):** Gate Plaza (the hub), Transit Yards, Hungry Quarter, Grave Row, The Reek, Palace Approach. No sub-area scenes.
- **Foliage and props:** topiary cones, perfect hedges; identical benches, lampposts, banners with Primm's face.
- **Budget:** about 35. **Paint-over:** needed.

### Primm's Castle [castle_grounds]
Not a walkable area (G-07): Primm's Castle is the Capital's main dungeon, a node map opened by the castle door at the end of the palace approach inside the wall. The look below is for its painted node map, battleboard and loading art (the map pipeline), not for a kit; there is no style file and no zone kit for it.
- **Time of day / lighting:** cold, crisp morning; gleaming highlights.
- **Palette:** #FFFFFF (dominant), #D4AF37, #2E2A4F, #B8B8C8, #8E44AD.
- **Mood:** grand, cold, imposing.
- **Building language:** gleaming marble and gold palace, mirrors, colonnades.
- **Hero landmarks:** the palace facade (seen from the Capital's palace approach, CAPI-HERO-PALACE-FACADE), the mirrored colonnade and the grand stair (painted on the node map).
- **Foliage and props:** perfect topiary; statues, mirrors.
- **Budget:** the node map and battleboard only. **Paint-over:** none.

### The Path-ology Lab [pathology_lab]
Filled in by Claude from `docs/design/pathology_lab.md` and the game's content (overnight run, decision OD-1 in `docs/design/open_questions.md`).
- **Time of day / lighting:** no sun: the hatch yard above is a cold pre-dawn hush; below, flat fluorescent white-blue light with four Path-colour glows from the tanks (red, yellow, purple, green).
- **Palette:** #E4EAEE (dominant), #9FB4C4, #4C5B66, #8A5A3C (roots), #E0443A, #E8C13A, #8E5FD0, #5FBF6A (the four Path glows).
- **Mood:** sterile, quiet, wrong; the horror is how ordinary the equipment is. One warm thing per room (a mug, a child's drawing).
- **Building language:** white-tiled clinical corridors cracked open by tree roots, glass tanks, draining apparatus, bone-pale cell bars, Path-ologists' desks with notes and mugs.
- **Material swaps:** shared kit in white tile, clinical panels, brushed steel and green-blue glass; pale concrete and grating ground; roots over everything the forest broke into.
- **Hero landmarks:** the Hidden Hatch (in the forest clearing), the Glass Tank Hall, the Draining Chamber rig, the Prince's Old Cell (tally marks), the Chief Path-ologist's Laboratory.
- **Where it lives:** not a walkable area (G-07). The Lab is a node-based postgame dungeon opened by the hatch in the forest clearing (`StartingAreaScene`, once Rip has revealed it); there is no antechamber. The look above is for its painted node map, battleboard, loading art and the node-map backdrop (`DungeonBackdrop` theme `lab`, style file `pathology_lab.json`).
- **Foliage and props:** tree roots through tile, dead pale ferns around the hatch; steel carts, tanks, desks, mugs, keycards, cells.
- **Budget:** the node map, battleboard and backdrop only (no kit). **Paint-over:** none.

Sheet-ready row (also in `docs/overnight_report.md`):

`The Path-ology Lab` | `No sun: cold pre-dawn hush above, flat fluorescent white-blue below with four Path-colour tank glows` | `#E4EAEE, #9FB4C4, #4C5B66, #8A5A3C, #E0443A, #E8C13A, #8E5FD0, #5FBF6A` | `Sterile, quiet, wrong; one warm thing per room` | `White-tiled clinical corridors cracked by tree roots, glass tanks, draining rigs, bone-pale cell bars, desks with notes and mugs` | `Shared kit in white tile, clinical panels, brushed steel, green-blue glass; pale concrete and grating ground; roots over everything` | `Hidden Hatch, Glass Tank Hall, Draining Chamber rig, Prince's Old Cell, Chief Path-ologist's Laboratory` | `No walkable area: a node-based dungeon from the forest hatch` | `Tree roots through tile, pale ferns; steel carts, tanks, desks, mugs, keycards, cells` | `About 25` | `Needed`
