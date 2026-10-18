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
