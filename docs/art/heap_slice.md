# The Verdant Dump slice: the layout fixed before its art pass

The Verdant Dump (area id `heap`, zone id `refusemancer`, `scenes/heap_zone.tscn`) prepared for its art pass by the rollout playbook (`docs/art/zone_rollout_playbook.md`), with the Gainlands, D.N.A. and Buffet lessons (the declutter rules of section 5, the Buffet lessons of section 7) applied to the layout FIRST, before any kit exists. The Verdant Dump is ONE walkable zone: there are no sub-areas and no walkable dungeon interiors (`docs/design/subarea_removal.md`); its dungeons are node maps entered from the zone. Gameplay, quests, NPC logic and the camera system are untouched. Judgment calls are VD-1... in `docs/design/open_questions.md`.

## The regions (all in the one scene)

Coordinates are metres, x east, z south (north is up the screen, where the Rotheart stands). `HeapLayout._areas` names them (`REGION_IDS`); the HUD shows the title.

| Region (id) | Where | What is there | Stand-in landmark (`HeapLayout` constant, size w x h x d) |
|---|---|---|---|
| **Compost Commons** (`commons`, the hub) | south centre, the plaza round (50, 64), reached over the entrance bridge from town (x 50, z 74 to 90) | the arrival bridge and the exit at its far landing, Brother Bramble (56, 57), Granny Gristle's shop and shed (61, 60), the Harvest Meal (40.5, 63.5), Wren Muckfoot (42.5, 69), Boris the boar's stable (38, 70.5), the Rift Express (44, 73), the compost bin (57.5, 70.5), the trough (63, 72.5), the druid shrine (69, 71), the scrap barn (38, 57.5) | **the greenhouse** at the plaza's centre, `GREENHOUSE` 9 x 5.5 x 6.5 m (`HeapLandmarks.greenhouse`): where the greenhouse centrepiece goes |
| **The Farm Rows** (`farm`) | south-west | the three crop plots in a row (12 to 22, 56), Druid Thistlewick's quiz in the appliance grove (19, 66), the bean, fertilizer and junk pickups, two escaped animals, the scarecrow, the compost heap and its chest in the corner, Shiro Swindle's giant chest (22.8, 73.8), a compost pit (28, 69) | **the rusty windmill** at the rows' west edge, `WINDMILL` (8.5, 64) 5 x 12 x 5 m, its sails turn (`HeapLandmarks.windmill`) |
| **The Junk Peaks** (`peaks`) | the whole east side: south of the stream Mount Scrapmore (86, 56) with the county fair at its foot; north of it the scree fields (a mount's ground) with the scrap barn (82, 14) | Recycle Rhonda's fair stage (73, 56) facing the east road, the chute that lands at the road's end, the sprout mound and the beanstalk (86, 63.5), the summit chests, the fridge chest and the vault lever (90, 72) in the secret corner, a compost pit (84, 72); the barn chest and the scree chest, the gulls | **Junk Mountain** beyond the north-east corner, `JUNK_MOUNTAIN` (108, -6) 48 x 28 x 26 m, a view the fair and hub cameras see ahead-right (`LandmarkKit` mound) |
| **The Stream, the Dam and the Vine Bridges** (`stream`) | the band across the middle, z about 34 to 50 | the recycling stream, the three vine bridges (x 22, 50, 78) with their sprout mounds and Druid Sorrel (46, 47) on the south bank, the south bank road from the west crossing past the plaza's north junction to the east crossing, the north bank road between the crossings and the three gaps in the tyre wall, the junk dam at the water's edge (36.5, 39), the haybale chest, Gideon the goat's stable at the bank's west end (12, 38) | none (the bridges themselves) |
| **The Wetlands** (`wetlands`) | the centre district behind the junk barricade (x 38 to 64, z 5 to 30) | the barricade gap (50, 30), the road north to the Rotheart's root gate, reed beds at the edges, two junk clusters in the corners by the wall, the car-husk chest, the scarecrow; the land grows violet and dark toward the roots (VD-8) | **the Rotheart** beyond the north rim, `ROTHEART` (50, -16) 44 x 46 x 44 m, castle scale, seen from the whole zone (`LandmarkKit` giant_tree); **its root gate** on the land, `ROOT_GATE` (50, 5.5) 10 x 6 x 4 m (`HeapLandmarks.root_gate`), the main_dungeon spot at (50, 9.2) in front of the hollow, no lettered plate |
| **The Throne Approach** (`throne`) | the north-west district through the open west gap | the avenue (x 31) from the gap past Rust Peak's east cliff to the throne's steps; Rust Peak (16, 16, radius 5) with the Seed Shrine on its summit, its beanstalk mound (16, 24.5) and the chute down its west side; the hollow-log chest, the corner chests, a golem on the avenue | **the Trash Panda Throne** beyond the north-west rim, `THRONE` (31, -3.5) 18 x 14 x 12 m (`HeapLandmarks.throne`), its steps on the land; the Landfill Depths door (the side dungeon's, VD-1) at the steps (31, 9.5), no lettered plate |

The zone has two dungeons (`data/dungeons/dungeons.json`): D-ROT the Rotheart (main) and S-REF the Trash Panda Throne (side); the Landfill Depths door *is* the way into the Trash Panda Throne (VD-1), as the Buffet's Walk-In Freezer is the way into the Omakase (BF-2).

## Part A: regions and layout

The playbook's declutter rules (section 5) applied to the one zone before any dressing; every quest NPC, the vendor, the puzzle, the minigame, every chest, the giant chest, the lever and both dungeon entrances still work (the ones that moved: VD-2, VD-7, VD-9; the reachability tests updated with them).

- **The way in is walked** (VD-3): a plank-and-tyre bridge (`HeapLandmarks.entrance_bridge`, 16 m, 4 m between its kerbs, a gate of stacked tyres with the zone's icon at the land end) from the land's south rim out over an overflow pool to a far landing; a fresh visit starts on it facing north, the exit spot waits at the landing, walking off the far end leaves for town (`HeapScene._update_entrance_exit`); the tyre arch is gone and the Dump's town passage lost its far glow. Waking after a faint puts the hero in the plaza.
- **The hub** (VD-7): an empty plaza (9.5 m) round the greenhouse stand-in; the hub's things on the rim, 4 m or more apart, each off every road; the barn off the north road; the hub's two windmills gone.
- **Routes**: main roads 4.2 m, spurs 3.6 m, nothing solid within 2.4 m of a route edge, 5.5 m of open ground round every anchor, every region on a loop (plaza - farm - the farm spur - the south bank road - plaza; plaza - fair - the fair spur to the mound; the three crossings - the north bank road - the three gaps; the avenue and the wetlands road end at their doors, the scree track at the barn). The walkability probe reaches all 65 key locations with lanes 1.3 m wide (`tests/world/test_walkability_zones.gd`).
- **Trees and props** (VD-5): trees only in the rim bands and eleven framing groups, bushes at the edges and as reed beds in the wetlands, flowers in clumps along the path edges and the crop row, junk in six tidy clusters; 23 boards (was 35), none a memo or poster; the generic dressing keeps only its grass carpet.
- **The goal you can see**: the Rotheart at castle scale beyond the north rim on the zone's centre line, every paint-over camera has it in frame; its root gate on the land is the main dungeon's door. Junk Mountain beyond the north-east corner, the Trash Panda Throne beyond the north-west rim, the windmill at the farm's west edge, the greenhouse at the plaza's centre: all of the planned sizes (`docs/art/zone_kits/heap.md`), their blocking circles layout data (`LANDMARK_BLOCKERS`) so the layout-only readers see them.
- **The corruption gradient** (VD-8): `data/zone_styles/heap.json` `corruption` read by `HeapLayout.corruption_at`: the ground lerps toward the Rot's violet and darkens from the north bank to the Rotheart's roots, strongest in the centre district; the flower clumps thin to 15 % there.
- **Occlusion**: the fader uses the per-instance transparency (no dither); the land, the rim, the far ground, the stream, the pits, the overflow pool, the entrance bridge and the three views never fade or cull; the greenhouse, the root gate and the windmill fade as a group when they block the view.
- **The sea plane** (VD-4): off for the heap mood (it flooded the land, as the Buffet's did).

| Part A | Before (the zone as found) | After Part A |
|---|---|---|
| The hub at the paint-over camera (Cinematic / Normal) | ![](heap_slice/before_PO-HEAP-HUB.jpg) | ![](heap_slice/a_PO-HEAP-HUB.jpg) |
| The 9 camera combinations (the plaza) | | ![](heap_slice/a_heap.jpg) |
| The arrival on the bridge | | ![](heap_slice/a_w_01_arrival_on_the_bridge.jpg) |
| The Compost Commons from the plaza | | ![](heap_slice/a_w_02_the_compost_commons.jpg) |
| The fair at Mount Scrapmore's foot | | ![](heap_slice/a_w_12_recycle_rhonda.jpg) |
| The Seed Shrine on Rust Peak | | ![](heap_slice/a_w_13_seed_shrine.jpg) |
| The Landfill Depths door at the throne's steps | | ![](heap_slice/a_w_14_landfill_depths_door.jpg) |
| The Rotheart's root gate | | ![](heap_slice/a_w_16_rotheart_root_gate.jpg) |
| The vault lever in the secret corner | | ![](heap_slice/a_w_18_vault_lever.jpg) |
| Leaving over the bridge | | ![](heap_slice/a_w_19_leaving_over_the_bridge.jpg) |

The "before" shot shows the sea plane flooding the land, the tyre arch and the scatter.

**fps on Medium** (`bash tools/fps.sh res://scenes/heap_zone.tscn 1 --at=<spot>`, the dev iGPU, 60 fps is the cap):

| Spot | avg fps | min fps | GPU ms | CPU ms |
|---|---|---|---|---|
| po_hub | 60.0 | 60.0 | 13.1 | 2.5 |
| po_farm_rows | 60.0 | 60.0 | 10.0 | 1.6 |
| po_junk_peaks | 60.0 | 60.0 | 11.4 | 1.9 |
| po_stream | 60.0 | 60.0 | 12.9 | 2.1 |
| po_wetlands | 60.0 | 60.0 | 12.3 | 1.8 |
| po_throne_approach | 60.0 | 60.0 | 11.5 | 1.5 |
| main_dungeon (the root gate) | 60.0 | 49.9 | 9.6 | 1.2 |

**Checks**: 1568 GUT tests, 1567 passing (the one failure is GC-6, the local camera FOV, pre-existing); `tests/world/test_heap_slice.gd` (the regions, the routes, the open ground, the clusters, the plaza, the boards, the bridge, the landmarks, the gradient, the cameras, the fresh visit) and `tests/core/zone/test_heap.gd` (the gating with the door moved); the walkability probe; the windowed walk smoke `bash tools/run_heap_walk_smoke.sh <camera>` (21 screenshots: the bridge, the plaza, every quest NPC and the vendor, every interactable, the boar mounted and dismounted, the quiz, the fair, the Seed Shrine, the Landfill Depths door sealed and unlocked into the Trash Panda Throne node map, the root gate, the giant chest, the lever, the walk back out) passes at the Cinematic (0) and the Overview (2) camera.

**Things to look at**: the stand-ins are plain `KitMesh` shapes in the zone's colours (the Rotheart reads pale through the golden haze at 80 m); the divider posts between the districts are the old pale slabs (a knee-high wall as in the Buffet, BF-11, is a Part B/C candidate); the eighth brief smoke (`tools/run_eighth_brief_final_smoke.sh`) walks hard-coded positions of the old layout and was not run in this pass (its legs will need the new anchors).

## Part B: paint-over inputs

One clean shot per region at Cinematic / Normal, 1600 x 900, the hero visible, no UI, no world labels or spot markers (`bash tools/shot.sh res://scenes/heap_zone.tscn PO-DUMP-<REGION> --at=po_<region> --nohud=true --clean=true --wait=2.6 --set=camera_angle:0,camera_zoom:1.5`; `--clean` is new in `tools/screenshot.gd`, it hides the Label3D plates and the gold markers as `tools/zone_shots.gd` does). Saved to `docs/art/paintover_inputs/heap/` and copied to `G:\My Drive\Card Game Art\Paintover_Inputs\verdant_dump\` (nothing else in the Drive touched). The cameras are layout data (`HeapLayout.PO_CAMERAS`, the hero's standing spot; the camera looks north from behind), so the final art pass shoots the same views; each stands on open ground off every interact spot and enemy line (VD-10) and has the Rotheart in frame.

| File | Camera spot (x, z) | What it frames |
|---|---|---|
| `PO-DUMP-HUB.png` | `po_hub` (50, 72.5), on the road just inside the entrance gate | the arrival: the tyre gate's pillars either side, the plaza and the greenhouse centrepiece ahead, the rift station and the boar stable left, the compost bin and the shed right, the Rotheart over the greenhouse |
| `PO-DUMP-JUNK-PEAKS.png` | `po_junk_peaks` (80, 71), the secret corner by the fridge | Mount Scrapmore with its chute ahead, the fair at its foot left, the compost pit in front, Junk Mountain beyond the north-east corner right, the Rotheart far left |
| `PO-DUMP-FARM-ROWS.png` | `po_farm_rows` (11.5, 70), the south-west corner by the compost heap | the rusty windmill left, the crop rows and the appliance grove ahead, the barn and the Commons beyond, the Rotheart top right |
| `PO-DUMP-STREAM.png` | `po_stream` (50, 51), the south bank road at the plaza's north junction | the stream and the centre crossing ahead with Druid Sorrel, the dam and the barn left, the haybale right, the wetlands' junk clusters and the root gate beyond, the Rotheart centre |
| `PO-DUMP-WETLANDS.png` | `po_wetlands` (50, 22), the wetlands road past the barricade | the reed beds, the junk clusters by the wall either side, the Rotheart's root gate with its hollow ahead and the trunk above; the barricade in the foreground |
| `PO-DUMP-THRONE-APPROACH.png` | `po_throne_approach` (32, 17), the avenue | the Trash Panda Throne's dais, banners and steps ahead with the Landfill Depths board, Rust Peak's cliff left, the divider right, the Rotheart top right |

| | |
|---|---|
| ![](heap_slice/b_PO-DUMP-HUB.jpg) HUB | ![](heap_slice/b_PO-DUMP-JUNK-PEAKS.jpg) JUNK-PEAKS |
| ![](heap_slice/b_PO-DUMP-FARM-ROWS.jpg) FARM-ROWS | ![](heap_slice/b_PO-DUMP-STREAM.jpg) STREAM |
| ![](heap_slice/b_PO-DUMP-WETLANDS.jpg) WETLANDS | ![](heap_slice/b_PO-DUMP-THRONE-APPROACH.jpg) THRONE-APPROACH |

**The stand-ins in the pictures** (what the painter replaces): the greenhouse (glass house, 9 x 5.5 x 6.5 m), the Rotheart (giant tree, 44 x 46 x 44 m, pale through the haze at 80 m), its root gate (10 x 6 x 4 m, the violet hollow), Junk Mountain (mound, 48 x 28 x 26 m), the Trash Panda Throne (dumpster-lid dais on can towers, 18 x 14 x 12 m), the rusty windmill (5 x 12 x 5 m), the entrance bridge (16 m) and its tyre gate. The pale divider slabs between the north districts are the old posts (a knee-high wall as the Buffet's, BF-11, is for the art pass).

**fps on Medium** at the six camera spots: 60.0 average and 60.0 minimum at every one (the Part A table above, same spots).


# The art pass: the Verdant Dump dressed from its approved kit

The zone kit (`Approved_ZoneKits/VerdantDump`, 33 files, and the six paint-overs `PAINTOVER-DUMP-*` that sat in the same folder) brought in and dressed by the playbook (`docs/art/zone_rollout_playbook.md` sections 1 to 4), on the layout of the prep pass above (regions, routes, plaza, clearances and anchors unchanged). Judgment calls VD-11... in `docs/design/open_questions.md`. The compare strips are paint-over left, game right, from the recorded `PO_CAMERAS` (`bash tools/heap_po_shots.sh <prefix> [region ...]` shoots them and writes `heap_slice/<prefix>_compare_<region>.jpg`).

## Art Part A: import

- **The sheet**: `data/source/heap_kit.csv` did not exist; it was rebuilt from `docs/art/zone_kits/heap.md` and the 33 delivered files (VD-11). The delivered kit differs from the planned list: no DUMP-WALL-SCRAP, -ROOF-THATCH, -GROUND-GRAVEL / -COMPOST, -PROP-WINDMILL, -DEC-RUST / -MOSS, -TREE-ROTHEART, -BD-ROTHEART; new are DUMP-ROOF-REED, -GROUND-CORRUPT, -TREE-TWISTED, -PLANT-FUNGUS, -DEC-CORRUPT, -PROP-SCRAPPILE and a fifth concept, the Commons greenhouse. The painted textures and decals of the earlier batches (TEX-DUMP-MOSSYDIRT, -JUNKGRAVEL, -COMPOST, -FARMROWS, -RUSTMETAL, DEC-RUST, DEC-MOSS, DEC-FLOWERS) are registry aliases.
- **"import zone kit heap"**: the Drive folder is `VerdantDump`, not the area id, so `art_config.cfg` gains `zonekit_folders={"heap": "VerdantDump"}` (read by `tools/import_zone_kit.gd`; the importer also read `zonekits_dir` from the wrong config section and only worked because the default matched). Report `docs/art/zone_kits/heap_import_report.md`: 33 imported, 0 missing, the six paint-overs unmatched (right: they are copied to `docs/art/paintovers/`), one note (DUMP-SKY-SUNSET is opaque: a real full-frame sunset sky, used as the sky panorama).
- **Slices and pivots** checked on magenta: the four 3x2 sheets slice clean (doors, windows, icon signs, rag flags); the trees, plants and props trim clean with no halo. DUMP-TREE-BIRCH measured its pivot at 0.79 (a stray leaf at the base) and gets a hand pivot 0.47 (`pivot_hand`, a new hand key the importer keeps over the measured one). Hand heights in the registry: birch 5.4, oak 6.2, twisted tree 6.0, wildflower crate 1.2, reeds 2.2, fungus 1.9, tyre garden 1.5, bottle wall 1.3, compost 1.8, goat cart 2.2, scrap pile 1.7 m; windows 1.4 m, flags 3.0 m wide.
- **Style**: every image is painted (soft cel shading, no pixel grid), including the sky; nothing reads as pixel art.
- **The hero landmarks** (`world/heap/heap_landmarks.gd`, registered as `DUMP-HERO-` in `HeroLandmarks.BUILDERS`; every stand-in is gone): the **Rotheart** (44 x 46 x 44 m view beyond the north rim: a trunk with nine twisting root strands, a heart-shaped hollow with a pulsing violet glow and a real light, veins, twelve mutated fungi, six arms under a wide green-gold canopy with hanging moss and wisteria, swallowed doors, a wheel and pipes, a treehouse in the crown, twelve roots spilling out over a corrupted mound; refined in Part B), **Junk Mountain** (48 x 28 x 26 m view at the north-east corner turned toward the zone: a steep cone of doors, tin, crates, wheels, barrels and green, a zig-zag plank stair with rope rails and lanterns, the summit shack with lit windows, a turning six-blade windmill and a rag flag, tree and flower cards on its shoulders), the **windmill** (5 x 12 x 5 m on the farm rows' west edge: an eight-sided tower of mossy planks patched with tin and doors, a tin cap, a sliced door and window, a lit round window, a porch with a two-tone awning, flower crates and a lantern, a violet root creeping up its side, four patchwork sails that turn slowly), the **Trash Panda Throne** (18 x 14 x 12 m beyond the north-west rim, its stair on the land: three tiers of crates, bins and barrels, the stair between lantern posts, two raccoon guards with lollipop staves, the crowned raccoon king with a scepter and a red cape on a bin throne, rag pennants on rope, two little windmills, a lit doorway with a sliced door), the **Commons greenhouse** (9 x 5.5 x 6.5 m centrepiece: warm glass on a timber frame, a lit rose window over a green arched door, a little windmill on the ridge, an awning, a rusty water tank and a compost crib, vines and planters, a warm real light inside). Their blocking circles are the stand-ins' (the layout's `LANDMARK_BLOCKERS` unchanged).
- **Sky and backdrop**: the `heap` mood carries `sky.panorama: DUMP-SKY-SUNSET` and five DUMP-BD-JUNK cards on the far ring at 60 degrees each (BF-7).
- **Real lights**: the greenhouse's warm light, the windmill's lantern and the Rotheart's heart (pulsed with its glow, about one slow beat every five seconds) are the zone's only `KitLights`; every other lantern is emissive.

| Region | Paint-over beside the game after Part A |
|---|---|
| Hub | ![](heap_slice/a_compare_hub.jpg) |
| Junk Peaks | ![](heap_slice/a_compare_junk_peaks.jpg) |
| Farm Rows | ![](heap_slice/a_compare_farm_rows.jpg) |
| Stream | ![](heap_slice/a_compare_stream.jpg) |
| Wetlands | ![](heap_slice/a_compare_wetlands.jpg) |
| Throne Approach | ![](heap_slice/a_compare_throne_approach.jpg) |

**What the Part A shots show** (the list for the next parts): the land floats over a flat beige plane (the far ground 26 m down, through the fog) where the paint-overs have land, forest and mountains to the horizon; the ground is one dark brown where they have green clover, orange paths and flowers; the old rusty junk models, the white tyre-wall slabs and the pale divider posts are still there; the Rotheart stands dead centre and too near in every view where the paint-overs set it upper right, far and whole.

**fps on Medium** after Part A: po_hub 59.9 (min 55.4, 726 draw calls), po_wetlands 60.0, po_farm_rows 60.0.
