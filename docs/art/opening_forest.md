# Opening Forest rebuild

The area where a new campaign begins (`scenes/starting_area.tscn`, `StartingAreaScene`), rebuilt to match the paint-over
`docs/art/paintovers/opening_forest_reference.png`, following `docs/art/zone_rollout_playbook.md` and `docs/art/art_bible.md`.
Judgment calls are OF-01, OF-02, ... below.

## Part A: audit (before)

### Where things are

| What | Where |
|---|---|
| Scene | `scenes/starting_area.tscn` -> `world/starting_area_scene.gd` (`StartingAreaScene`) |
| Walkable area | `world/starting_area_builder.gd` (`StartingAreaBuilder`, a `WalkableArea`): a 5 x 5 KayKit hex map (`MAP`), 2 m hexes |
| Forest round it | `world/starting_forest.gd` (`StartingForest`): Kenney pines in three MultiMesh layers, undergrowth, far mountains, light shafts, fireflies |
| Look | `StylePresets.START`, `data/zone_styles/starting_forest.json`, mood `start` in `data/art/zone_looks.json`, painted ground preset `start` in `data/art/texture_presets.json` (`PaintedContexts.start`) |
| Story text | `data/story/intro_story.tres` (awakening lines), `StoryText` keys `prologue.*`, `start.*`, `cave_mouth.*` |

### Layout before

The clearing is tiny: five hexes across (about 10 m), the wake-up spot (hex 2,3 = 5.0, 5.2) only **2.4 m** from the cave gate (hex 2,1). The cave
is the KayKit `mine` building at 1.35 scale; a teal `StyleBeacon` column and a cyan light mark it. The ring of `M` hexes is a dense treeline of
Kenney pines (the walls). `N` cells are three camouflaged nooks with hidden chests, `H` the hidden tunnel (south-west), `L` the Path-ology Lab hatch
(south, postgame only, treeline until revealed). No camp, no path (a faint worn-path decal), no cliff, no hooded figure standing in the world.
Generic `ZoneDressing` and the world-look foliage scatter over the hexes.

### Scripted flow (must not break)

1. New game -> `StartingAreaScene._ready` -> `_play_awakening` (story still `StoryStills.WAKE` once, flag `wake_seen`) -> awakening lines
   (flag `awakened`).
2. `_start_rescuer_scene`: the hooded **Rescuer** (`ModelKit.character("Rogue_Hooded")`, spawned at spawn + (1, 0, -0.3)) talks
   (`prologue.rescuer.1..3`, `prologue.wanderer.1..2`), the **starting Path choice** (`ElementChoiceScreen`, `Session.choose_starting_path`,
   flag `rescuer_met`), `prologue.rescuer.4`, then the Rescuer slides away and fades; `prologue.wanderer.3`.
3. Free walk. Walking to the treeline (0.7 m probe, `is_floor_at`) plays `prologue.self_talk` and nudges the hero toward the gate
   (not within 2.2 m of a hidden chest or the tunnel).
4. Cave gate (anchor `gate`, 1.7 m): "Enter the cave" -> confirm -> `Session.begin_intro_trial` (the node-based Forgotten Cave).
5. After the cave: `Session.cave_exit_pending` -> `_begin_cave_exit`: hero at gate + (0, 0, 0.5), **Elder Maren** at gate + (0, 0, 2.3), dialogue,
   flag `maren_met`, `SceneManager.go_to_town()`.
6. Secrets: hidden tunnel (anchor `tunnel`, 1.5 m, skips the tutorial: `Session.skip_tutorial_via_secret_tunnel`), three hidden chests
   (`HIDDEN_CHESTS` start_west 40 / start_east 25 / start_cave 70 gold, 1.5 m, documented in `docs/design/secrets.md`).
7. Postgame: Rip's rift station (hex 3,1), the freed Rescuer (hex 1,3), the Lab hatch (anchor `lab`; the test wants the hatch cell to be no floor
   while closed and floor once open).

Code that reads the layout: `tests/world/test_walkability_zones.gd` (every anchor reachable from `spawn`), `test_polish_chests.gd` (3 chests,
gold, models), `test_starting_forest.gd` (reads `MAP`), `test_pathology_lab.gd` (hatch), `test_zone_dressing.gd` (generic dressing on the
area), `PaintedContexts.start` (reads `MAP` for the painted cover), `tools/prologue_smoke.gd`, `tools/starting_area_tunnel_smoke.gd`,
`tools/story_v2_final_smoke.gd` (`anchors["lab"]`), `tools/story_playthrough.gd`.

### Before shots (1280x720, Medium)

`_screenshots/of_before_wake.png`, `of_before_path.png`, `of_before_exit.png`, `of_before_wide.png` (Overview / Far), `of_before_hud.png`.
All five look the same: the clearing is so small that the camera frames the whole thing from every spot. Bright saturated Kenney pines with
red trunks fill the screen; the purple dusk sky and fog sit behind them; the cave is a small mine hut under a teal beacon column; the hero is
small and competes with the trees. Nothing of the paint-over (camp, lantern pool, path, cliff, giant tree, mist) is there.

### fps baseline (Medium, `bash tools/fps.sh res://scenes/starting_area.tscn 1 --quiet=true`)

avg 59.7 fps (16.76 ms), p95 16.67 ms, min 23.8; GPU 11.8 ms, 202 draw calls, 246 k primitives.

### Kit art

`Approved_ZoneKits/OpeningForest` does not exist yet (the Drive has Buffet, Capital, DNA, Gainlands, VerdantDump): every OF- piece is a stand-in
built from shared painted textures (`mat_rock`, `mat_bark`, `start_*` grounds) and existing painted cards, tagged STANDIN.

## Part B: layout and terrain

The hex map is gone. The ground plan is data, `world/opening/opening_forest_layout.gd` (`OpeningForestLayout`): the walkable floor is a union of
circles and capsules (`floor_sdf`), so the treeline itself is the wall and the edge can be any shape. Metres, x east, z south, the camera looks north.

| Piece | Where | Size |
|---|---|---|
| Clearing (camp at the front) | three circles round (0, 0) | about 13 x 10 m |
| Wake-up spot `spawn` | (-0.4, 1.0) beside the bedroll (-2.3, 1.5), pack (-3.6, 1.0), lantern (-1.2, 2.0) | |
| Hooded figure (the Rescuer) | stands at (-2.9, -0.5), behind the bedroll, facing the hero | |
| Worn path | 6-point centre line from (1.8, -2.5) back and right to the gate | 4.4 m wide, about 21 m long |
| Cave apron + `gate` | (10.4, -18.0) r 3.0, gate (10.4, -19.4), the cave mouth at (10.4, -21.6) | |
| Cliff + giant tree | cliff foot line z -22.4 behind the cave, 9.5 m; tree trunk (15.2, -22.8) | |
| Side nook (optional) | spur from the clearing's north-west to a mossy hollow (-4.2, -8.8) r 2.6, chest `start_west` | spur 3.4 m |
| Secrets | tunnel pocket (-6.3, 2.2); chest pockets east (6.8, -3.0) and among the roots (13.9, -18.2); Lab pocket (4.3, 4.2), floor only once revealed | |

The pieces are `world/opening/opening_forest_models.gd` (`OpeningForestModels`, all STANDIN until the OF- kit exists): the cliff of stacked rock
slabs with mossy shelves and vine curtains, the arched cave mouth (an unshaded black-to-teal fan in a jamb-and-lintel frame), the giant tree
(flared trunk, buttress roots, a great root arching over the mouth, heavy canopy), the camp (bedroll, pack, lantern housing, firewood),
mossy boulders in clusters at the rim (plus three rim blockers that bite into the clearing) and long low ledges at the front, flagstones in
three stretches of the path, fern clumps and dark bushes along every edge, tall bark trunks framing the clearing, and painted pine / oak
cards in a 13 m band. `StartingForest` grows beyond that band. Generic `ZoneDressing` is off.

Checks: `tests/world/test_opening_forest.gd` (path width and nothing solid on it, the path's direction and length, the camp and figure at
the front, the gate / Maren / cave-lip spots, the only way out, the nook, breathing room at the gate, the Lab pocket, dressing off the floor
and off the camera side, the STANDIN list); `test_walkability_zones` reaches every anchor.

### Judgment calls

- **OF-01** The Art Bible row says "early morning"; the brief and the paint-over say dusk/night. The paint-over wins (it is the visual target);
  the Art Bible row and `data/zone_styles/starting_forest.json` follow in Part C.
- **OF-02** "The cave mouth is the exit into the rest of the starting forest": the cave gate keeps its job (the node-based Forgotten Cave, then
  Maren at the cave mouth, then Crosspath). Nothing new is walkable; the tutorial flow and its flags are untouched.
- **OF-03** The hooded figure (the existing Rescuer) now stands beside the camp where the paint-over has it, instead of appearing a metre from
  the spawn; it still arrives with the conversation and leaves after it (the flow needs it gone).
- **OF-04** The hex grid (`StartingAreaBuilder.MAP`) is replaced by `OpeningForestLayout`; `StartingAreaBuilder` keeps its public API (anchors,
  obstacles, chest nodes, `lab_open`, `is_walkable`), so the scene, the smokes and the tests read it as before. `StartingForest` and
  `PaintedContexts.start` read the layout instead of the hex cells. The hero's centre stays 0.1 m inside the floor's edge.
- **OF-05** The three hidden chests keep their ids and gold but move with the new layout: `start_west` into the side nook (the optional
  exploration the brief asks for: no marker, it is just there to find), `start_east` into an east pocket, `start_cave` among the giant tree's
  roots. The tunnel is a pocket in the south-west treeline, the Lab hatch a south-east pocket. `docs/design/secrets.md` updated.
- **OF-06** The self-talk at the treeline stays quiet in the nook and round the secrets (`OpeningForestLayout.QUIET`): exploring them should not
  be scolded.
- **OF-07** Generic `ZoneDressing` is off for the forest (playbook 22): the forest dresses itself.

## Part C: lighting and atmosphere

- **Mood** (`StylePresets.START`, `data/zone_styles/starting_forest.json`, mood `start` in `data/art/zone_looks.json`): deep teal-blue dusk. A dim
  cool moon key (#8ab8d0, 0.42), teal ambient (#3a6e7c), teal fog (#1c3c46, 0.018) and volumetric haze, bloom 0.8 / threshold 0.85 for the
  lantern and the mushrooms, vignette 0.5, a cool rim (#9fd8e8). Painted tree cards take a cool `tree` tint; the world-look foliage scatter is off.
- **`OpeningForestAtmosphere`** (`world/opening/opening_forest_atmosphere.gd`): the lantern (glowing glass, an amber OmniLight3D of 8.5 m with a
  soft 1.6 falloff, a gentle three-wave flicker, a faint warm ground glow; shadowed on High only); a cool glow in the cave mouth (slow pulse);
  glowing mushroom clusters along the path's edges, denser toward the cave, two of them with tiny real lights; ground mist in two drifting
  layers plus fog banks between the far trunks (`assets/shaders/opening_mist.gdshader`: noise wisps, edge fade, depth-soft); pale moon rays
  over the clearing's back, the path's bend and the cave; a soft light riding with the hero and the same on the hooded figure and Maren
  (`npc_light`). `StartingForest`'s rays are fainter and cool, its fireflies warm.
- **`OpeningForestFrame`** (`world/opening/opening_forest_frame.gd`): near-black fern sprays at the screen's bottom corners, camera-attached and
  sized from the FOV every frame, so every angle, zoom and swivel is framed the same way and the middle (hero, NPCs, dialogue box) stays clear.
  The tilt-shift blurs them. `--noframe=true` hides them for clean shots.
- **Readability**: the 9 angle x zoom combinations (`_screenshots/of_grid/starting_forest.png`) all read as finished; the hero is the brightest,
  clearest thing in each (hero light + rim), the hooded figure reads in the lantern pool.
- **fps** (Medium): 60.1 avg at the camp, 60.0 at the cave; GPU 11.5 ms (baseline 11.8), 162 draw calls (baseline 202).

### Judgment calls

- **OF-08** The old teal `StyleBeacon` column at the cave is gone: the paint-over leads the eye with the cave mouth itself, its faint glow and the
  mushrooms, not a beam. The minimap still marks the gate.
- **OF-09** Foreground silhouettes ride with the camera rather than standing in the world: the camera follows the hero over a 25 m area, so world
  pieces would only frame the camp. They stay in the bottom corners (and one off the top-left) to keep clear of the dialogue box and the minimap.
- **OF-10** The vines hang still (meta `no_wind`): the toon shader's sway grows with height and turned vines hanging from 9-15 m into giant blades.

## Part D: dress and match

No OF- kit exists yet, so every piece is a STANDIN (list at the end). Repeats vary: boulders are two or three tilted bevelled blocks at random
sizes (0.9-1.8 m) and turns, clustered by a slow wave with random spacing (2.4-4.2 m) and half as many on the camera side; ferns get 7-10
fronds of four greens; trunks, cards and roots take random scales and turns. Ground: the painted `start` preset paints the dirt path along
`OpeningForestLayout.PATH` and the camp, mossy forest floor elsewhere. The pack now lies on its back (upright it read as a small figure).

**Paint-over camera** (`OpeningForestLayout.PO_CAMERA`): hero at the path's start (1.6, -2.0), Classic angle, zoom 2.2:
`bash tools/shot.sh res://scenes/starting_area.tscn of_po --quiet=true --nohud=true --show=rescuer --pos=1.6,-2.0 --set=camera_angle:1,camera_zoom:2.2`.
Side by side: `docs/art/opening_forest/compare_po.jpg`.

| Pass | mean RGB | luma p5 / p50 / p95 | saturation | what changed |
|---|---|---|---|---|
| paint-over | 28, 33, 30 | 2 / 24 / 88 | 0.57 | |
| 1 (after Part C) | 7, 28, 27 | 2 / 18 / 57 | 0.87 | far too cyan and saturated |
| 2 | 16, 29, 23 | 1 / 21 / 65 | 0.64 | grey-green ambient and fog, sun #a8c0c0, warmth +0.04, saturation 0.82-0.86, exposure 1.0, fog 0.012 so the cave reads |
| 3 (final) | 15, 29, 22 | 0 / 21 / 60 | 0.63 | crowns removed (black lid at Far), rays fainter, darker pine tint, fewer camera-side boulders, softer mist banks |

What still does not match (honest list): the paint-over is framed much closer than any game camera (characters about 15% of the height, the
cave and the giant tree filling the upper right); the game keeps its cameras (G-02) and matches palette, light and dressing instead. Its
highlights are brighter (p95 88 vs 60): the lantern's warm spill along the path and the lit grey rocks; ours are darker. Its trees are richly
painted oaks with warm trunks; ours are flat painted cards and plain bark columns. The cave and giant tree are blocky stand-ins. All of
these close with the OF- kit art (prompts below).

### Judgment calls

- **OF-11** The paint-over reframes the scene (CAP-36): the game cameras stay; the paint-over camera is the closest in-game match (Classic, zoom 2.2
  from the path's start) and the match is judged on palette, light, haze and dressing density.
- **OF-12** The paint-over's palette is less teal than the brief's words ("cool deep teal-blue"); the numbers follow the picture (grey-green
  ambient, a little warmth) while fog, mist and the cave glow keep the teal accent.

## Part E: verify and report

### Before / after (1280x720, Medium)

| Spot | Before | After |
|---|---|---|
| Wake-up spot (the camp, the hooded figure) | `opening_forest/of_before_wake.jpg` | `opening_forest/of_after_wake.jpg` |
| The path | `opening_forest/of_before_path.jpg` | `opening_forest/of_after_path.jpg` |
| The exit (cave mouth) | `opening_forest/of_before_exit.jpg` | `opening_forest/of_after_exit.jpg` |
| Wide (Overview / Far) | `opening_forest/of_before_wide.jpg` | `opening_forest/of_after_wide.jpg` |
| Paint-over camera | | `opening_forest/of_after_po.jpg`, side by side `opening_forest/compare_po.jpg` |
| 9 camera combinations | | `opening_forest/camera_grid.jpg` |

Before, the opening was a 10 m hex clearing of bright Kenney pines with the cave 2.4 m from the wake-up spot under a teal beam. After: a camp
in a lantern's amber pool at the front of a mossy clearing, the hooded figure beside it, a 4.4 m dirt path with flagstones winding back and
right past glowing mushrooms to an arched cave mouth in a vine-draped cliff under a giant tree's arching root, teal-grey dusk, drifting
ground mist, faint moon rays, silhouette leaves at the screen corners, a side nook with a chest.

### fps (Medium, `bash tools/fps.sh res://scenes/starting_area.tscn 1 --quiet=true [--pos=x,z]`)

| Where | Before | After |
|---|---|---|
| Camp | 59.7 avg, GPU 11.8 ms, 202 draw calls | 59.8 avg, GPU 11.3 ms |
| Path (5.6, -9.5) | | 60.0 avg, GPU 11.4 ms |
| Cave mouth (10.4, -17.0) | | 60.0 avg, GPU 10.7 ms |

### Checks

- GUT: 1829/1830 (the one failure is the pre-existing CP-2 in `test_world_look_rig.gd`), including `tests/world/test_opening_forest.gd` (14) and
  the walkability probe (`test_walkability_zones`: every anchor reached from the spawn).
- `bash tools/run_opening_forest_smoke.sh` (new, windowed, real input): title -> New Game -> wake-up -> the hooded figure beside the camp, the
  Path choice in the conversation -> the figure leaves -> held WASD from the camp up the path to the cave mouth (5.0 s, no teleport) -> "Enter
  the cave" -> the Forgotten Cave -> out at the mouth, Maren -> Crosspath: all 17 checks OK.
- `bash tools/run_starting_area_tunnel_smoke.sh`: the hidden tunnel still skips the tutorial (its start spot moved to the wake-up spot): OK.

### STANDIN pieces still needing art

All in `OpeningForestModels.STANDINS` / `world/opening/opening_forest_models.gd`. Each row is one image for ChatGPT; save it under the file name
in `Approved_ZoneKits/OpeningForest`, then `bash tools/import_zone_kit.sh opening_forest` (the sheet `data/source/opening_forest_kit.csv`, the
folder mapping and the swaps still have to be written when the art lands).

**Style for every prompt (paste once at the top of the batch):**

> Painted 2.5D storybook style, matching the Opening Forest paint-over (a hooded figure and a young hero at a lantern-lit camp in a dusk forest,
> a path winding to a vine-draped cave under a giant ancient tree): clean bold shapes, soft cel-shaded painting, deep teal-grey dusk light
> from the upper left with a warm amber lantern glow where noted, rich but muted harmonious colours (forest green #3F5E3A, moss #6A8A3A,
> bark brown #6B4E3A, rock grey-blue #6E7A80, fog teal #283C3A, lantern amber #FFA850). One object per image, centred, seen from the game
> camera (about 30 degrees above the horizon, front three-quarter view), on a fully transparent background (PNG with alpha), no ground
> shadow plate, no text, letters or numbers anywhere. Storybook proportions: a 1.7 m hero, trees 2.5-4 times the hero.

| # | File name | ID | Lock | In-game size | Prompt (after the style line) |
|---|---|---|---|---|---|
| 1 | OF-HERO-CAVE-CLIFF.png | OF-HERO-CAVE-CLIFF | CONCEPT | cliff about 20 m wide, 9.5 m tall; mouth 3.4 m wide, 3.8 m tall | A mossy grey-blue rock cliff face with a dark arched cave mouth in its middle, the opening framed by big rough boulders, curtains of yellow-green hanging vines over the top of the mouth and down the face, mossy ledges, ferns at its foot, the inside of the cave fading to black with the faintest cool teal glow deep within. |
| 2 | OF-HERO-ANCIENT-TREE.png | OF-HERO-ANCIENT-TREE | CONCEPT | trunk 5 m across at the foot, about 16 m to the crown; root arch 9 m wide | A giant ancient tree with a broad flared trunk and twisting buttress roots spilling over rocks; one huge mossy root arches sideways over a cave opening (leave the space under the arch empty and dark), hung with vines; a heavy dark green canopy of leaf clumps spreading over the top. |
| 3 | OF-PROP-BEDROLL.png | OF-PROP-BEDROLL | CUTOUT | 1.9 m long, 0.8 m wide | A traveller's bedroll laid out on the ground: an olive-green padded roll with a cream blanket folded back, a rolled pillow at the head, a little rumpled as if someone just woke up. |
| 4 | OF-PROP-PACK.png | OF-PROP-PACK | CUTOUT | 0.66 m long, 0.4 m tall | A worn brown leather travel pack lying on its back with its flap open and two dark straps, a cream blanket roll on the ground beside it. |
| 5 | OF-PROP-LANTERN.png | OF-PROP-LANTERN | CUTOUT | 0.5 m tall | A small black iron camp lantern with a ring handle and four glass panes, a warm amber flame glowing inside, set on the ground. |
| 6 | OF-ROCK-BOULDER-SHEET.png | OF-ROCK-BOULDER | SHEET | 3x2: boulders 0.9-1.8 m, two long ledges 2.4 m | Six mossy forest rocks on a 3x2 grid: four rounded grey-blue boulders of different sizes with thick moss caps and a few ferns at their feet, and two long low flat rock ledges with moss along their tops. |
| 7 | OF-PATH-FLAGSTONE.png | OF-PATH-FLAGSTONE | SURFACE | tiles at 400 px/m | A seamless top-down texture of a worn forest dirt path with old sunken grey flagstones half buried in packed earth, moss in the cracks, a few fallen leaves. |
| 8 | OF-PLANT-FERN-SHEET.png | OF-PLANT-FERN | SHEET | 3x2: 0.6-1.4 m tall | Six forest undergrowth plants on a 3x2 grid: two lush fern clumps, a low dark leafy bush, a tuft of tall grass with seed heads, a cluster of small pale mushrooms and a clump of glowing teal mushrooms. |
| 9 | OF-VINE-DRAPE.png | OF-VINE-DRAPE | CUTOUT | 1.5-4 m long | A curtain of hanging yellow-green vines and ivy strands of different lengths, hanging straight down from a straight top edge (to hang from cliff tops and roots). |
| 10 | OF-TREE-TRUNK.png | OF-TREE-TRUNK | TREE | 12-16 m tall, trunk 1-1.3 m across | A tall straight forest tree with a dark brown furrowed trunk, roots gripping the ground, a few branches and dark green leaf clumps only near the top, for the dense trees framing the clearing. |
| 11 | OF-TREE-PINE.png | OF-TREE-PINE | TREE | 7-9 m tall | A tall dark green forest pine with a reddish-brown trunk and layered drooping branches, softened by dusk light (to replace the bright town pine cards in the forest). |
| 12 | OF-SKY-DUSK.png | OF-SKY-DUSK | BACKDROP | full width | A wide panorama behind a dense forest at dusk: misty teal-grey air between layers of distant tall trees and pines, paler and foggier with distance, nothing brighter than a pale teal. |

### Summary of judgment calls

OF-01 time of day follows the paint-over; OF-02 the cave gate keeps its job (node-based Forgotten Cave, Maren, Crosspath); OF-03 the hooded
figure stands by the camp; OF-04 the hex map is replaced by `OpeningForestLayout`; OF-05 chests and secrets moved with the layout; OF-06 no
self-talk in the nook and at the secrets; OF-07 generic dressing off; OF-08 the beacon column removed; OF-09 camera-attached foreground;
OF-10 vines hang still; OF-11 the paint-over reframes, the cameras stay; OF-12 the palette follows the picture.

### How to test

- New Game from the title: wake at the camp, talk through the hooded figure's conversation, walk up the path to the cave mouth, press E.
- `bash tools/run_opening_forest_smoke.sh` (windowed e2e), `bash tools/run_tests.sh` (GUT), `bash tools/fps.sh res://scenes/starting_area.tscn 1 --quiet=true`.
- Paint-over camera: `bash tools/shot.sh res://scenes/starting_area.tscn of_po --quiet=true --nohud=true --show=rescuer --pos=1.6,-2.0 --set=camera_angle:1,camera_zoom:2.2`.
