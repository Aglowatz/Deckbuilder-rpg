# Bot report

Written by the playthrough bot (`bash tools/run_tour_bot.sh`, `tools/tour_bot.gd`) on 2026-10-19T02:39:17, 8.0 minutes.

- Areas: forest, town, beefcake, necrocrat, gourmand, refusemancer, capital
- Spots used (NPCs, shops, signs, chests...): 220
- Menus opened: deck_station, codex, character_screen, quest_log, full_map, wardrobe, vendor, item_vendor, pack_vendor
- Battles: beefcake (Flexing Brute), necrocrat (Shambling Middle Manager), gourmand (Meatloaf Golem), final (Compliance Officer)
- Errors: 20, warnings: 0

## Frames over 33 ms

| Area | Frames | Over 33 ms | Worst (ms) |
|---|---|---|---|
| forest | 60 | 0 | 27 |
| town | 2949 | 50 | 176 |
| beefcake | 2942 | 23 | 101 |
| beefcake battle | 241 | 0 | 18 |
| necrocrat | 3707 | 15 | 71 |
| necrocrat battle | 241 | 0 | 18 |
| gourmand | 3169 | 8 | 79 |
| gourmand battle | 241 | 0 | 18 |
| final | 8749 | 39 | 148 |
| final battle | 241 | 0 | 18 |

## Slowest moments (worst frame during one action)

- town: use deck: 176 ms
- town: open character_screen: 167 ms
- town: use pack_vendor: 154 ms
- town: use vendor: 151 ms
- final: use fig: 148 ms
- town: use item_vendor: 139 ms
- town: open deck_station: 133 ms
- beefcake: use tony: 101 ms
- final: use lost_poster_0: 98 ms
- town: open deck_station (again): 82 ms
- final: use complaint_1: 80 ms
- final: use spotless: 80 ms
- gourmand: use dolcetta: 79 ms
- town: open full_map: 74 ms
- town: use codex: 74 ms

## Where the slow frames are (frames over 33 ms per action, top 15)

- town: use deck: 5
- town: open vendor: 5
- town: use vendor: 4
- town: use equipment_vendor: 4
- beefcake: use sign_1: 4
- beefcake: use brenda: 4
- town: open vendor (again): 4
- final: use lost_poster_0: 3
- final: use citizen_1: 3
- final: use kestrel: 3
- final: use wren: 3
- necrocrat: use dolores: 3
- beefcake: use tony: 3
- town: open full_map: 3
- town: use item_vendor: 3

## Errors

- [refusemancer] Parse Error: Could not resolve class "HeapMaterials", because of a parser error. (heap_scene.gd:650 in GDScript::reload)
- [refusemancer] Parse Error: Could not resolve class "HeapMaterials", because of a parser error. (heap_scene.gd:674 in GDScript::reload)
- [refusemancer] Parse Error: Could not resolve class "HeapMaterials", because of a parser error. (heap_scene.gd:818 in GDScript::reload)
- [refusemancer] Parse Error: Could not resolve class "HeapMaterials", because of a parser error. (heap_scene.gd:838 in GDScript::reload)
- [refusemancer] Parse Error: Could not resolve class "HeapMaterials", because of a parser error. (heap_scene.gd:840 in GDScript::reload)
- [refusemancer] Parse Error: Could not resolve class "HeapMaterials", because of a parser error. (heap_scene.gd:841 in GDScript::reload)
- [refusemancer] Parse Error: Could not resolve class "HeapMaterials", because of a parser error. (heap_scene.gd:843 in GDScript::reload)
- [refusemancer] Parse Error: Could not resolve class "HeapMaterials", because of a parser error. (heap_scene.gd:844 in GDScript::reload)
- [refusemancer] Parse Error: Could not resolve class "HeapMaterials", because of a parser error. (heap_scene.gd:846 in GDScript::reload)
- [refusemancer] Parse Error: Could not resolve class "HeapMaterials", because of a parser error. (heap_scene.gd:847 in GDScript::reload)
- [refusemancer] Parse Error: Could not resolve class "HeapMaterials", because of a parser error. (heap_scene.gd:848 in GDScript::reload)
- [refusemancer] Parse Error: Could not resolve class "HeapMaterials", because of a parser error. (heap_scene.gd:881 in GDScript::reload)
- [refusemancer] Parse Error: Could not resolve class "HeapMaterials", because of a parser error. (heap_scene.gd:882 in GDScript::reload)
- [refusemancer] Parse Error: Could not resolve class "HeapMaterials", because of a parser error. (heap_scene.gd:884 in GDScript::reload)
- [refusemancer] Parse Error: Could not resolve class "HeapMaterials", because of a parser error. (heap_scene.gd:885 in GDScript::reload)
- [refusemancer] Parse Error: Could not resolve class "HeapMaterials", because of a parser error. (heap_scene.gd:886 in GDScript::reload)
- [refusemancer] Parse Error: Could not resolve class "HeapMaterials", because of a parser error. (heap_scene.gd:890 in GDScript::reload)
- [refusemancer] Parse Error: Could not resolve class "HeapMaterials", because of a parser error. (heap_scene.gd:891 in GDScript::reload)
- [refusemancer] Failed to load script "res://world/heap/heap_scene.gd" with error "Parse error". (gdscript_resource_format.cpp:46 in load)
- [refusemancer] the scene did not load

## Warnings

None.

## Log

- forest: no spot list to tour
