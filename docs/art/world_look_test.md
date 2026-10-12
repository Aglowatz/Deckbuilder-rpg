# World Look Test

A polished slice of the real main town in the chosen style: **painted 2.5D character sprites, a low cinematic camera with tilt-shift and bloom, painted textures, a real sky and distant scenery.** It is a test bench, not a change to the game: `tests/world/world_look_test.tscn` is the real town (`WorldLookTest extends TownScene`, painted textures and all) with new pieces added on top. No real game scene or script was touched, and the bench never writes the save.

**Launch it**

```
# from C:\Dev\Deckbuilder-rpg
"C:\Tools\Godot\Godot_v4.7.2-stable_win64.exe" --path . res://tests/world/world_look_test.tscn
```

or open `tests/world/world_look_test.tscn` in the editor and press F6. It starts on **F5 Recommended**, just south of the plaza fountain. The panel (Tab) shows every value.

| Key | What |
|---|---|
| WASD / arrows, E, mouse wheel | walk, talk to whoever is near, zoom (the town's own wheel zoom works inside every preset) |
| **F1 - F4** | the four old character-test cameras (Current, Classic RPG, HD-2D, Low and cinematic), re-expressed in the new parameters |
| **F5** | **Recommended** (the values below) |
| **F6** | **My Preset**: loads what "Save as My Preset" wrote to `data/art/world_look_my_preset.json` |
| **Tab** | the live tuning panel (16 sliders, fog colour, "Save as My Preset", "Reset to Recommended", "Copy values") |
| **[ and ]** | turn the view 30 degrees at a time, to look towards every landmark (WASD stays screen-relative) |

A caption in the top-left always shows the current numbers.

Tools: `bash tools/world_shots.sh one <name> [--preset=5 --pos=x,z --yaw=180 --pitch= --distance= --fov= --height= --hide=Ring_mid_hills --off=post]` (one screenshot), `... shots [--only=square_f5,walk,talk,villager,shade,panel]` (the whole documented set into `docs/art/world_look/`), `... perf [--spots=square,water,lm_gainlands --presets=5]` (frame times), `... perfab` (what each feature costs, switched off one at a time); the art importer `Godot --headless --path . -s res://tools/world_test_import.gd`. Tests: `tests/world/test_world_sprite.gd`, `tests/world/test_world_foliage.gd`.

## 1. Source art and import

Copied (never modified) from `G:\My Drive\Card Game Art\Approved_WorldTest` (69 PNGs) plus `CHAR-REF` from `Character_Test`; the cleaned results are in `assets/art/world_test/` and the importer's own report is `assets/art/world_test/import_report.txt`.

- **Missing IDs: none.** All 69 asset IDs of `data/source/world_look_test.csv` have a file. **Unmatched files: none** (every file in the folder has a checklist row). The model sheets (`SPR-*-REF`, six of them) and `CHAR-REF` are references and are not used in the game; the `CHAR-25D` fallback sprites were not needed.
- **Brannoch is `SPR-GATEKEEPER-*`** (the checklist calls him Gatekeeper Brannoch), the town spot id is `guard`.
- All the images are genuinely transparent (alpha is clean, there is no glow halo to cut). One thing the old test did not meet: the walk **strips overlap in x** (a cloak of one figure reaches over the next one), so cutting at empty columns does not work. The importer labels connected pieces of the alpha channel instead, joins specks to the nearest figure, and falls back to a cut at the emptiest column near each quarter when two figures touch (it did once: `VILLAGER FRONT_WALK`).
- Backdrops: painted mist below alpha 0.12 is made fully transparent (the Capital card showed a faint rectangle before), the tileable layers are cropped to their content rows, the foam strip is turned 21 degrees so its foam line is horizontal (wet sand below, open water above), and the six foliage sprites are packed into one 3 x 2 atlas.

## 2. Part A: the sprite character system (`world/sprites/`)

Reusable for the whole game: `WorldSprite` (a node), `SpriteLibrary` (loads the manifest and caches textures), two shaders. `setup("PLAYER", camera, sun)`, then `follow(world_pos, delta)` for walkers and `look_toward(direction)` for standing characters; `talking = true` shows the TALK pose.

**Slicing and alignment (`tools/world_test_import.gd`).** Every walk strip is cut into its four figures; every frame is trimmed, scaled and laid on **one canvas per character** so that:
- the **feet stand on one baseline** (16 px above the canvas bottom, for every frame of every direction);
- **one scale per direction**: the four walk frames of a direction share the scale that makes their mean height equal that direction's idle height, idles and the TALK pose share the character scale (so a figure never changes size when it starts walking or turns); the canvas is sized from the largest frame; the figure is 440 px tall in a canvas of 256 - 384 x 496 - 512 px (70 frames, 24 MB of PNG for the whole world test, lossless);
- the **torso is centred horizontally**: the anchor is the alpha-weighted x of the head and upper-body band (10 % - 45 % of the figure height), which does not swing with legs or cloak. Every frame's anchor is put on the canvas centre line, so a walk cycle cannot jitter sideways and the mirrored (right-hand) copy turns about the same line.

The contact sheets show the result with the baseline (red) and the centre line (green) over every frame: [PLAYER](world_look/sheets/PLAYER.png), [VILLAGER](world_look/sheets/VILLAGER.png), [GATEKEEPER](world_look/sheets/GATEKEEPER.png), [ELDER](world_look/sheets/ELDER.png).

![](world_look/sheets/PLAYER.png)

**Eight directions from five drawn ones.** The sprite knows where its body points (a heading that turns towards the direction of travel at 540 deg/s, or towards the player for an NPC at 260 deg/s) and measures it against the camera: 0 deg = facing the camera. The nearest drawn direction wins (FRONT 0, FRONTSIDE 45, SIDE 90, BACKSIDE 135, BACK 180, with 9 degrees of grace for the one already shown so the 22.5 / 67.5 / 112.5 / 157.5 degree boundaries do not flicker); the art looks LEFT, so a body pointing to the screen's right mirrors it. Because the choice is made against the **camera**, turning the view with `[` `]` turns the sprites correctly. NPCs have only FRONT, SIDE and BACK, so a diagonal falls back to the nearest of those.

**Walk and idle.** Frames WALK1 - WALK4 in order; cycles per second = speed / (1.5 character heights), capped at 3.2, so the hero (4.6 m/s) steps about 2.9 times a second and the baker (1.15 m/s) about 0.9; a subtle vertical bob (1.8 % of the height, peaking on the passing frames) rides on top. Idle: a gentle breath, a squash of about 1 % about the feet, each character on its own phase. Textures are filtered linearly with mipmaps and anisotropy. Heights follow the checklist: player 1.0 (1.25 m in the world), Elder 0.7, Brannoch 1.35, Sable 0.95, Tilly 0.85, Fenwick 0.8, baker 0.85.

**Grounded, not pasted on.** (1) A **ground shadow**: the card's own silhouette sheared flat along the sun's direction (next pass of the sprite material), soft and violet, plus the town's contact blob. (2) **Scene-reactive light**: the card is lit by the real sun, lamp pools and ambient through its own `light()` function; the sun's shadow map darkens it in a building's shadow and a cool blue is added there, the sun side gets the warm sun colour. (3) A **rim light**: edge pixels whose neighbour towards the sun is empty glow warm (two texture lookups, no geometry). (4) An upright billboard (it turns round the vertical axis only), so the figure keeps true perspective at low camera angles.

| In the sun | In a wall's shadow (same spot) |
|---|---|
| ![](world_look/shade_in_sun.jpg) | ![](world_look/shade_in_shadow.jpg) |

(The wall is a test box added for this shot only. The difference is real but modest: the cool shade is a few percent; a stronger grade would need the art to carry less baked lighting.)

**NPCs.** Elder Maren, Brannoch, Sable, Tilly Tonic and Foil Fenwick stand at their usual spots with their idle sprites (their 3D models are hidden in this test), turn to face the hero by angle (front / side / back) when he is within 4.2 m and back to their own heading when he leaves, and switch to the TALK pose during dialogue, with the dialogue portraits working exactly as before:

| Elder Maren | Brannoch | Sable | Tilly Tonic | Foil Fenwick |
|---|---|---|---|---|
| ![](world_look/talk_elder.jpg) | ![](world_look/talk_guard.jpg) | ![](world_look/talk_vendor.jpg) | ![](world_look/talk_item_vendor.jpg) | ![](world_look/talk_pack_vendor.jpg) |

**The wandering baker** (`tests/world/villager_walker.gd`) walks a small graph: a 14-point ring round the fountain, the four street mouths and the market / deck / gate / well doorsteps, picking the next waypoint without turning straight back, pausing for 1.5 - 4 s at about half of them, stopping politely if the hero stands in the way, using the full 5-direction walk set:

| | | |
|---|---|---|
| ![](world_look/villager_1.jpg) | ![](world_look/villager_2.jpg) | ![](world_look/villager_3.jpg) |

**Walking** (frames caught mid-stride at F5): towards the camera, away, left, right (mirrored):

| Toward | Away | Left | Right |
|---|---|---|---|
| ![](world_look/walk_toward.jpg) | ![](world_look/walk_away.jpg) | ![](world_look/walk_left.jpg) | ![](world_look/walk_right.jpg) |

## 3. Part B: sky, sun, clouds (`tests/world/world_sky.gd`)

- **Gradient**: a sky shader on the town's own environment: warm pale-gold haze at the horizon (it follows the fog colour), a golden band, soft blue-lavender, then blue at the zenith, with a little painted streak noise and a warm glow on the sun's side.
- **Sun**: the SKY-SUN glow card, additive, hung in the compass direction of the town's real sun light. **Honest caveat:** the town's sun stands behind the north-facing camera (south-west, 38 degrees up) and a low camera sees no more than about 9 degrees above the horizon, so the glow card is clamped to 9 degrees elevation and appears only when the view is turned towards it (look at the shots towards the Gainlands, the glow is in the top-right corner). I did not move the light: the town is toon-lit for a sun behind the camera and a sun in front would put every storefront in shade.
- **Clouds**: the six SKY-CLOUD sprites in three layers (29 cards) at 1350 / 980 / 720 m, drifting at 3.5 / 6.5 / 10 m/s (times the panel's cloud speed), so the near ones sweep past faster: parallax. Each card dissolves into the horizon haze the farther and lower it is.
- **Cloud shadows**: a soft drifting noise plane just above the ground and water, violet and faint (strength 0.16). Cheap (0.2 ms) and it looks fine.

## 4. Part C: distant scenery and world edges (`tests/world/world_scenery.gd`)

Rings round the middle of the whole town (25.2, 26 m; the zone islands reach 70 m out):

| Layer | Radius | Height | Notes |
|---|---|---|---|
| Far shore (grass, sand lip, foam) | 128 - 165 m | flat | a narrow strip so the treeline stands on something |
| BD-NEAR-TREELINE | 146 m | 9.5 m | 31 repeats, crisp, little haze |
| BD-MID-HILLS | 215 m | 17 m | 38 % haze, 28 % cool |
| BD-LANDMARK x5 | 275 m | 34 - 42 m cards | between hills and mountains |
| BD-FAR-MOUNTAINS | 375 m | 36 m | 58 % haze, 50 % cool lavender |

Haze is done in the layer shader (the scene fog would be warm; the far layers need to be **paler and cooler**): each layer is pulled towards lavender and then the horizon haze, and every base dissolves a little.

**Landmarks** stand in the direction from the middle of the town to the island at the end of each passageway's bridge: the Gainlands south (178 deg from north), the D.N.A. west-south-west (-97), the Endless Buffet east (79), the Verdant Dump west-north-west (-79), the Capital north (-10). (A ray straight out of each passage mouth would put the two western zones 4 degrees apart and their cards on top of each other; from the centre they are 18 degrees apart.)

**Water**: the hex water tiles are no longer drawn; one plane of **TEX-TOWN-WATER** (two layers drifting against each other, a slow patchy depth tint, twinkling glints) runs out to 800 m under the rings, so there is no water edge anywhere. **DEC-SHOREFOAM** cards (476 of them, one MultiMesh) lap in and out along **every hex shoreline** (computed from the water tiles' neighbours, zone islands included), and a repeated foam strip runs along the far shore. The water is deliberately **opaque**: an earlier version read the depth texture for shoreline foam, but that put it in the sorted pass, where it painted over the see-through rings, and the town's outline pass then drew the outlines of the submerged tiles over it.

**The four things the old test found, fixed:**
1. *Jagged water edge and the hard water line against the sky* - gone: water runs under three rings and a far shore; there is no edge; the horizon is a painted treeline on a foam-edged shore.
2. *The pale empty wedge* - gone: the sky is a gradient plus clouds all the way down to the rings.
3. *Cliff-ring backs* - the hex wall of rocky mountains and hills behind the town (110 pieces) is hidden in this test and replaced by the painted layers. The map's own mountain cells at the north rim stay (they are part of the walkable map) and loom large when the hero stands next to them.
4. *The Capital from behind as bare shapes* - the ring of white wall prisms and the plain castle block on the Capital's island are hidden; the bridge, the island, the two gate towers and flags stay, and the painted Capital stands far behind. **It is a bare white island now, not a finished place** (see the notes).

## 5. Part D: foliage and atmosphere

- **Foliage** (`world_foliage.gd`): about 1,750 cards of the six FOL- sprites in **one MultiMesh**: grass, grass with seed heads, wildflowers, tall flowers, bushes, ferns. Chance rises towards the edges of the land and near buildings (gardens, flowers and bushes there); **never** within 1.75 m of a road, on the plaza paving, within 1.5 m of a doorstep or NPC spot, or inside an obstacle (`tests/world/test_world_foliage.gd` checks it for every plant and that plants favour the shores). Wind sways the top of every card with a slow gust travelling across the field. I chose **camera-facing cards** (upright, turning round the vertical axis) over crossed quads: at a 20 degree camera crossed quads show their thin edge for half of all angles.
- **Ambient life** (`world_ambient.gd`): about 110 drifting pollen / dust motes (soft additive dots, warm), 12 falling leaves (green, yellow, orange, tumbling), and a **flock of 3 - 6 birds** crossing the sky every 22 - 48 s (a flapping silhouette drawn in the shader, 110 - 170 m away). The town's own ambient particles (fireflies, motes) are switched off in this test: under the low camera and the bloom they were big white balls.
- **Light shafts: tried and left off.** Five warm additive strips along the sun's direction looked fine from the side and like flat translucent plates with hard edges over the water when the sun is behind the camera. `--shafts=1` turns them on.

## 6. Part E: camera and live tuning

All presets are now one set of parameters, so the panel edits any of them:

| Preset | Pitch | Distance (x zoom 1.5) | FOV | Height offset | Extras |
|---|---|---|---|---|---|
| F1 Current | 53.3 | 13.72 (20.6) | 38 | 0 | no blur, no bloom boost |
| F2 Classic RPG | 45 | 10.0 (15.0) | 38 | 0 | none |
| F3 HD-2D | 30 | 7.4 (11.1) | 30 | 0.4 | tilt-shift 9 px, bloom 0.9 / threshold 0.75 |
| F4 Low and cinematic | 20 | 7.0 (10.5) | 44 | 0.85 | none |
| **F5 Recommended** | **20** | **6.2 (9.3)** | **44** | **0.9** | tilt-shift, bloom, golden grade, fog, vignette |

"Height offset" aims the camera that many metres above the hero (the view tilts up by atan(height / distance)), which lowers the horizon in the frame; it replaces the old test's "look-up" angle.

**Final F5 values (the numbers to quote when you tell me what you like)**

```
pitch 20.0 deg   distance 6.2 (x zoom 1.5 = 9.3)   fov 44 deg   camera height offset 0.9
tilt-shift: focus 0.62 (of the screen height from the top), band 0.13, blur far (top) 7 px, blur near (bottom) 6 px
bloom: intensity 0.50, threshold 1.05, glow spread 0.60 (glow also capped at luminance 2.0)
fog: density 0.0035, colour #f2cfa4 (light atmospheric fog, also the horizon haze)
grade: warmth 0.30, saturation 1.10, vignette 0.28     clouds: speed 1.0
```

**Why these differ from the brief (pitch about 25, distance about 9, FOV about 34).** With a 25 degree pitch and a 34 degree field of view the top of the frame is 8 degrees *below* the horizon whenever the hero sits near the middle of the screen: there is no sky, no mountains and no clouds in the picture at all. To see a horizon, the pitch has to come down or the field of view has to go up, and the F5 above is the compromise that keeps the hero in the lower third (the focus band sits on him) and the horizon about 28 % of the way down (mountains and sky fill the top quarter): pitch 20, FOV 44, the distance brought in to 6.2 so the 1.25 m hero is about 16 % of the screen height. Tuned by eye in the plaza and at every landmark; the bloom threshold was raised from 0.75 (F3) to 1.05 so only the brightest things glow (sun glow, glints, lamp tops), the sharp band was moved from focus 0.60 / band 0.12 to 0.62 / 0.13 so it sits on the hero's chest.

**The panel** (Tab): sliders for pitch, distance, field of view, camera height offset, tilt-shift focus position, focus band width, blur far and near, bloom intensity and threshold, glow spread, fog density, colour warmth, saturation, vignette and cloud speed; a colour picker for the fog colour; **Save as My Preset** (writes `data/art/world_look_my_preset.json`, F6 loads it; the round trip is checked by `--run=roundtrip`), **Reset to Recommended**, and **Copy values** (to the clipboard and the console, as JSON). Each slider shows its number, and the caption keeps the current values on screen when the panel is closed. Values blend over about 0.2 s when you switch presets.

![](world_look/panel_f5.jpg)

## 7. Part F: performance (Ryzen 5 4500U iGPU, 1600x900, **Medium**, vsync off, 4 s per cell, run alone)

Medium renders the 3D at 0.62 scale with FSR, so everything below is fill-rate bound.

| Spot | F1 | F2 | F3 | F4 | **F5** |
|---|---|---|---|---|---|
| Town square (the heaviest view) | 65.7 fps | 66.4 | 61.1 | 68.6 | **61.8** (16.2 ms, p95 16.7 ms) |
| By the water | 90.6 | 97.3 | 87.1 | 94.8 | **84.6** |
| Toward the Gainlands | 94.1 | 95.8 | 89.8 | 98.0 | **86.9** |

F5 holds 60 fps on Medium, but **the margin at the plaza is thin** (about 1.5 fps; the 3D town alone is 15 ms there). What the new pieces cost at the plaza in F5 (each switched off in turn, same process): bloom 1.5 ms, the tilt-shift / grade / vignette pass 1.0 ms, painted rings and water 0.5 ms, foliage 0.35 ms, everything else (sky, clouds, birds, motes, water, sprites) too small to measure.

What was done about it (rather than removing blur and bloom):
- **The tilt-shift pass** first cost **2.8 ms**: nearly all of it was generating the screen texture's mipmaps every frame for the blur to read. It now reads the plain screen texture with 8 golden-angle taps and a per-pixel jitter (no mip chain), which costs 1.0 ms and looks the same at 7 px of blur.
- **Bloom**: only about three of the seven glow levels carry weight (spread 0.6), the glow is thresholded high and capped, which keeps it at 1.5 ms.
- **Look updates** are only pushed when a value changes: updating the sky material every frame forced the sky's reflection cube to be redrawn every frame (20 - 70 ms hitches), the bug that made my first measurements useless.
- Foliage is one MultiMesh with faked lighting, water is opaque, clouds / rings / foam are a few dozen quads.

## 8. The same spots at F1 - F5

| Spot | F1 Current | F2 Classic RPG | F3 HD-2D | F4 Low | **F5 Recommended** |
|---|---|---|---|---|---|
| Town square | ![](world_look/square_f1.jpg) | ![](world_look/square_f2.jpg) | ![](world_look/square_f3.jpg) | ![](world_look/square_f4.jpg) | ![](world_look/square_f5.jpg) |
| By the water (west shore) | ![](world_look/water_f1.jpg) | ![](world_look/water_f2.jpg) | ![](world_look/water_f3.jpg) | ![](world_look/water_f4.jpg) | ![](world_look/water_f5.jpg) |
| Toward the Capital (north) | ![](world_look/lm_capital_f1.jpg) | ![](world_look/lm_capital_f2.jpg) | ![](world_look/lm_capital_f3.jpg) | ![](world_look/lm_capital_f4.jpg) | ![](world_look/lm_capital_f5.jpg) |
| Toward the Endless Buffet (east) | ![](world_look/lm_buffet_f1.jpg) | ![](world_look/lm_buffet_f2.jpg) | ![](world_look/lm_buffet_f3.jpg) | ![](world_look/lm_buffet_f4.jpg) | ![](world_look/lm_buffet_f5.jpg) |
| Toward the Verdant Dump (west) | ![](world_look/lm_dump_f1.jpg) | ![](world_look/lm_dump_f2.jpg) | ![](world_look/lm_dump_f3.jpg) | ![](world_look/lm_dump_f4.jpg) | ![](world_look/lm_dump_f5.jpg) |
| Toward the D.N.A. (west) | ![](world_look/lm_dna_f1.jpg) | ![](world_look/lm_dna_f2.jpg) | ![](world_look/lm_dna_f3.jpg) | ![](world_look/lm_dna_f4.jpg) | ![](world_look/lm_dna_f5.jpg) |
| Toward the Gainlands (south) | ![](world_look/lm_gainlands_f1.jpg) | ![](world_look/lm_gainlands_f2.jpg) | ![](world_look/lm_gainlands_f3.jpg) | ![](world_look/lm_gainlands_f4.jpg) | ![](world_look/lm_gainlands_f5.jpg) |
| Map edge: north | ![](world_look/edge_north_f1.jpg) | ![](world_look/edge_north_f2.jpg) | ![](world_look/edge_north_f3.jpg) | ![](world_look/edge_north_f4.jpg) | ![](world_look/edge_north_f5.jpg) |

More edges (the old test found the problems at the low angles):

| | F4 Low | F5 Recommended |
|---|---|---|
| West (the D.N.A. side) | ![](world_look/edge_west_f4.jpg) | ![](world_look/edge_west_f5.jpg) |
| East (the Buffet side) | ![](world_look/edge_east_f4.jpg) | ![](world_look/edge_east_f5.jpg) |
| South (the Gainlands side) | ![](world_look/edge_south_f4.jpg) | ![](world_look/edge_south_f5.jpg) |

## 9. What still looks unfinished (honestly)

- **The Capital's island is a bare white disc** with two gate towers; the city exists only as the faint painted card 275 m away, which the haze makes hard to read. A real Capital needs a painted facade card on the island itself (billboarded so every angle works), or a rebuilt 3D gate.
- **The other four zone islands are the original 3D models**, unchanged (and their backs were not checked). Their style (flat prisms, KayKit props) is a different kind of picture from the painted backdrop behind them. Only the five NPCs asked for are sprites: the tailor, the equipment vendor, the alchemist, the arena master and the four corrupted NPCs are still 3D models, so the plaza mixes two styles.
- **The hero sprite ignores cosmetics** (hat, cloak colours, the wardrobe): it is the one painted Wanderer.
- **Foreground props are huge at this angle**: signposts and the notice board cover a lot of the frame and often the hero. The occlusion fader dithers some, but not the sign boards. They want to be smaller, or lower-poly and faded, in a sprite town.
- **The sun glow is never in the default view** (it is behind the camera), and the sun is the only light source: there is no sky colour on the ground other than the existing ambient.
- **Clouds are only seen in the top 10 - 15 % of the frame** at this camera; the layering shows when you turn the view or lower the pitch. Birds are small and brief.
- **Foliage cards do not receive the sun's shadow** and are lit with a faked colour, so they can look slightly too bright inside a building's shadow; the town's own 3D grass tufts are still there under them. Plants on the zone islands are not placed.
- **Water has no refraction and no depth read**: the shallows are not paler. Shoreline foam is laid per hex edge, so corners overlap and the bridge posts and island props have no foam of their own.
- **Sprite art**: the cloak shape changes a lot between WALK frames and the hand glow differs, which no code can fix; right-hand directions are mirrors, so the cloak always hangs on the same side; the NPCs have no diagonals and do not walk. Turning is instant at the 45 degree boundaries (smoothed only by the body's heading speed).
- **Tilt-shift is a screen-space blur**: it also softens things that should be sharp at the top and bottom (the HUD is not affected, it is drawn later), and the 8-tap blur is visibly grainier than the 14-tap one if you push the radius above about 10 px.
- Backdrop tiles use a crude seam fix (the images tile with a small mismatch); I did not look at every seam from every angle.

## 10. Plan: this style for the whole game (effort estimates are for one person, in working days)

1. **All NPCs as sprites (about 8 - 10 days, 60 % of it art).** About 25 characters. Each needs the checklist's set: FRONT / SIDE / BACK idle and a TALK pose, so 4 images, plus a model sheet first (as done here) - roughly 1 hour of generation and cleanup per character, so 3 - 4 days for the named NPCs and 2 days for generic townsfolk. Walkers (the baker, guards on patrol, travellers) need the 5-direction walk set (10 images each). Code: `WorldSprite` already takes any manifest entry; 1 day to add a per-NPC data row (id, character, spot, heading, wanders yes / no) and to replace `_add_npc`; 1 day for the corrupted NPCs' tinted / particle variants; 1 day to add FRONTSIDE / BACKSIDE art for the main NPCs if the pops at 45 degrees bother you.
2. **Every zone's sky, backdrops and foliage (about 10 - 12 days).** 5 zones + the starting forest + the Capital interior ring: per zone a palette preset (sky colours, haze, fog, sun), a set of 3 rings (near, mid, far), 2 - 3 landmark cards, 4 - 6 foliage sprites (about 1.5 days of art each), and a water / ground texture choice. Code: move `WorldSky` / `WorldScenery` / `WorldFoliage` out of the test folder and drive them from `ZonePreset` (1.5 days), make the ring centres and radii data instead of constants (0.5 day), the shore foam from each zone's own coastline (1 day). The dungeons are different: they are enclosed, so they need a ceiling / wall treatment, not a sky (2 days of design before art).
3. **Battle and dungeon transitions (about 4 - 5 days).** Camera: ease from the world camera to the battle camera and back using the same parameter set (1 day, the panel's values become `ZonePreset` fields); sprite poses for battle intros (hero draw / hurt / win - 3 more images each, 1 day art); a tilt-shift ramp that closes to full blur during the card-table swap (0.5 day); dungeon entry fades through the same fog (0.5 day); testing every zone entrance and exit (1 day).
4. **Productising the bench (about 5 - 6 days).** A quality tier for the whole stack (Low: no tilt-shift or bloom, 40 % foliage, two cloud layers; Medium as measured; High: shadow-receiving foliage, soft shafts), Settings options for tilt-shift and bloom strength (reduce-motion friendly: no drifting clouds), accessibility checks (the blur must never cover the interaction prompts), moving the test's camera parameters into the game camera (the passage zoom-out already exists and must keep working), cosmetics on the sprite hero (hat and cloak as layered cards, 2 - 3 days alone), frame-time budget per zone on the dev PC.
5. **Verification (about 3 days):** the screenshot matrix for every zone at the three presets, the perf table, a human pass for the foreground-prop sizes.

Total: roughly **30 - 36 working days**, of which about 40 % is art. The risk is the hero: the painted cloak, hat and the wardrobe do not exist as sprites; deciding that up front (layered cards or a fixed look) is the one decision that changes the estimate by more than a week.
