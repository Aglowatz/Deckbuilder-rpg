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
