# Exported-build stability check (Overnight Oct 22, Part 5)

Builds: a test pack (the release export's content plus `tools/`, `bash tools/export_test_pack.sh`) for the windowed bots, then the
v0.4.5 release export itself (`builds/_export/`, zip `builds/TheWaywardPath-v0.4.5-windows.zip`) for the release smoke and the shots.
The stock Godot 4.7.2 binary runs the pack (`--main-pack`) from a folder outside the project: `bash tools/run_exported_suite.sh <pck>
<d3d12|vulkan> <0|1|2|safe> <playtest|tour|story|shot>`; the player's settings.cfg and boot_state.cfg are backed up and restored.
PC: AMD Radeon(TM) Graphics (integrated).

## Results

| Run | Driver | Quality | Result | Worst frame in the 5 s after a fade-in |
|---|---|---|---|---|
| Opening hour (`playtest`: forest, Path choice, cave, Maren, shops, Deck Station, ghosts, level 5, Bertram, story quests) | D3D12 | Medium | OK, 0 script errors | 55 ms (one 456 ms frame = the smoke's own screenshot readback) |
| Opening hour | Vulkan | Medium | OK | - |
| Opening hour | D3D12 | Low | OK | - |
| Opening hour | D3D12 | Safe Mode (log: "SAFE MODE: started from the Safe Mode launcher", Low, render scale 0.5) | OK | - |
| Opening hour | Vulkan | Safe Mode | OK | - |
| Story playthrough (New Game -> Primm -> the funeral, Isla, Maren's news) | D3D12 | Medium | 90/90, 0 script errors | 82 ms |
| Story playthrough | Vulkan | Low | 90/90, 0 script errors | - |
| Tour bot (281 spots, 9 menus, 5 battles) | D3D12 | Medium | 5 errors, 10 warnings - all five were 3D models missing from the export (below), fixed | town 119, Capital 96, Gainlands 57, D.N.A. 55, Dump 49, Buffet 47, battles 18-31 ms |
| Release smoke on the v0.4.5 export | D3D12 | default | PASSED (0.4.5) | - |

**Fixed: five props missing from the exported game.** `BuffetModels.food("cup" / "pie" / "egg")` and `HeapModels.cars("van")` /
`survival("box")` build their paths from a folder constant and a bare name, so `tools/update_export_excludes.js` (via
`unused_assets.js`) thought the models were unused and left them out of the pack: in the exported game the Buffet and the Dump
spawned empty nodes where those props stand. The exclude script now keeps any model whose folder is named in a script and whose file
name is a quoted string in the scripts (11 kept: the five plus suv, mug, bed, pot, log and the car-kit box - a few KB). Checked in the
v0.4.5 pack: all five paths present.

**Memory after the full tour** (D3D12 Medium): RAM 499 MB, video memory 1412 MB (textures 733 MB, buffers 45 MB). Battles release
buffers (back to ~1.1 GB), but textures creep up area by area (437 MB after Crosspath -> 733 MB after the Capital). Sane for now;
next: let `AreaCaches.release()` drop battleboard / portrait / map textures too.

**Disk**: the PC's C: drive was full (700 MB free) - the second test pack was cut short and would not load. Only this run's files were
removed (the truncated pack and the old `builds/_export`); `_screenshots/` holds 5 GB of older shots and `builds/` the old zips.

## The new things, on the v0.4.5 pack (`bash tools/exported_feature_shots.sh`, shots in `docs/playtest/exported_oct22/`)

| Shot | What it shows |
|---|---|
| `wardrobe.png` | the wardrobe preview with the Royal Mantle and the Wizard Hat |
| `zone_gainlands.png`, `zone_dna.png`, `zone_buffet.png`, `zone_heap.png`, `zone_capital.png` | the hero walking in each zone with a hat and a cloak (`--wear=`, new zone hook) |
| `deck_station_720.png`, `deck_station_1080.png` | the Deck Station at 1280x720 and 1920x1080: nothing cut off, cover cards on the racks |
| `battle_paste_works.png` | a battle on the Paste Works board (BB-S-PASTE): card crops keep the heads |
| `map_lab.png`, `map_paste_works.png` | the painted Lab (16 nodes) and Paste Works (3 stops) maps |

The lieutenant fights, the Paste Works and Elowen's Lab fight run in the sim on the same content (Part 1 sweep, 6 games per Path: Quota 71%, Clipwell
83%, Crumb in the Paste Works 54%, `D-LAB:16:elowen` 58%); the story bot covers the capture at the castle gate and the postgame beats. The disguised
Rescuer's portrait/figure only shows in the prologue conversation (not shot tonight).
