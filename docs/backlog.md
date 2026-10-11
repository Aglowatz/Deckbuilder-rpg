# Backlog audit

Audit of the project against the backlog, at commit `858e332` (2026-10-11). Nothing was fixed; this file only reports.

**How it was checked.** Three kinds of evidence, and the item entries say which one applies:
- **GUT:** `bash tools/run_tests.sh` run today on HEAD: **1261 of 1261 tests pass**.
- **Code and data:** grep and reading of the current source, data files and `docs/progress.md`.
- **Screenshot:** I looked at the committed `docs/art/screens/dungeons/map_D-PC.jpg`.

I did **not** run any windowed e2e smoke today and did not take fresh screenshots. Items marked DONE on GUT alone are verified in logic, not re-walked in the game. The dated e2e logs in `_screenshots/*.log` are cited where they matter.

---

## DONE (verified working)

| Item | How I checked |
|---|---|
| **Healing Potion type line** | C-12 is `type = 5` (Tool). `CardView._type_text()` maps `TOOL`, `RESOURCE` and `TOKEN` to "Tool", "Resource" and "Token". The shared `_type_text()` feeds both the plain and the framed card layout. GUT `test_card_type_lines_name_every_card_type` (`tests/test_ui_art.gd`) checks every card, token and infrastructure card. |
| **Tutorial battleboard (BB-TUT)** | `data/battleboards.json` maps `dungeon:hollow` to BB-TUT, and `dungeons.json` D-TUT names BB-TUT. GUT `test_the_forgotten_cave_uses_the_tutorial_board_even_after_another_dungeon` forces stale dungeon flags and still gets BB-TUT. `begin_trial()` and `begin_intro_trial()` now call `_clear_dungeon_mode()`. A cave battle screenshot is in `docs/art/screens/card_face_revert/`. |
| **MAP-PC (Primm's Castle) node alignment** | I viewed `map_D-PC.jpg`. Every node sits on a painted landing spot, and the 12 dead-end branches and the main road line up. `map_layout.json` has not changed for D-PC since the Oct 6 fit; the only later edit added D-LAB. GUT `test_map_art.gd` checks the node count per map. See PARTIAL for the Model Room judgment call. |
| **Dungeon map node alignment, the other maps** | The Dungeons Part B notes record that every map has exactly as many painted landing spots as nodes. GUT passes. I looked only at D-PC myself. |
| **Old name "Verdant Heap"** | No player-visible occurrence is left. The only hits are `docs/`, `test_story_rewrite.gd` (which asserts its absence) and old logs. Internal `heap_*` ids and `HeapZone` are kept by design (progress.md line 2079). |
| **Long card names vs cost** | GUT `test_every_card_name_fits_beside_its_cost_pips` passes. It covers every card in FULL and COMPACT mode and shrinks, wraps or shortens names. Gaps are listed under PARTIAL. |
| **Polish: rock collision** | Small decorative rocks no longer block movement in the town, Gainlands, Dump and Capital outskirts. GUT `test_walkability_town` and `test_walkability_zones` flood-fill from spawn and report no unreachable key locations. Last run: Gainlands 34 locations, Buffet 54, none unreachable. |
| **Polish: Gainlands building** | The Swole Station's single 4 m collider was replaced by four 1 m colliders on the real footprint. Covered by the Gainlands walkability test. |
| **Polish: starting forest** | `world/starting_forest.gd` (900 m endless forest, MultiMesh, light shafts, fireflies). GUT `test_starting_forest.gd` passes. |
| **Polish: extra chests, chest and quest popups, chests staying open** | 37 new chests. `ChestKit` rebuilds the opened state from the save. `RewardPopup`, the Quest Complete box and the level-up box share `PopupFrame`. GUT `test_polish_chests`, `test_chest_scan*` and the popup tests pass. |
| **Feature: Refuse Pile viewer and targeting** | GUT `test_refuse_pile_targeting.gd` checks the legal targets of every card with a Refuse Pile target against an independent oracle, plus Regrow, Reinstate, Shred and Lich play-throughs. |
| **Feature: Shiro Swindle and the 5 giant chests** | GUT `test_ninja_boss.gd` passes (steal, smoke bomb, return duel, 3 Gilded Packs). |
| **Feature: Capital secret passage** | GUT `test_capital_wall_passage.gd` passes. It asserts the gate stays shut and the city is reachable only through the wall gap. |
| **Feature: zone connectors and labels** | GUT `test_town_connectors.gd` and `test_passages.gd` pass. Labels are the destination names only. |
| **Feature: multiple saves** | GUT `test_save_slots.gd` passes (5 slots plus autosave, legacy `save.json` migrated to slot 1). |
| **Feature: saved decks and deck box upgrade** | GUT `test_deck_box.gd` passes (5 slots, 10 after level 3). |
| **Feature: no-gold level rewards** | GUT `test_level_up_rewards.gd` and `test_progression` pass. `docs/design/progression.md` was regenerated. |
| **Feature: four-lever vault** | GUT `test_vault_guardian.gd` passes. |
| **Feature: Path Pack guarantee** | GUT `test_pack_path_rule.gd` passes (1,500 seeds per pack type). |
| **NPC dialogue portraits** | 71 portraits imported with no missing ids and no unmatched files. GUT portrait and NPC registry tests pass. The dialogue_shots tool and screenshots exist. |
| **Dungeon and map import** | All 12 dungeons come from `dungeon_list.csv` and all 12 maps are imported. `_screenshots/dungeons_final_smoke.log` reports "OK - 0 check failure(s)". It covers D-TUT, D-HOG with the rescue, S-BEEF via its quest, and "the side dungeon leads back to the zone". |
| **Side dungeon quests** | Covered by the same smoke and `test_mini_dungeon.gd` (`test_every_side_dungeon_is_sealed_until_its_quest_is_done`). |
| **Kingdom rename** | `data/story/royal_family.tres` has `kingdom = "Pathwork"`. Tokens such as `{kingdom}` are used in the story data. "Concordia" survives only as the queen's name. |
| **Texture rollout, per zone and building materials** | All 65 CSV textures and decals are imported. `data/art/texture_presets.json` has presets for Main Town, Starting Area, Gainlands, D.N.A., Buffet, Dump, Capital (outside and inside) and the Castle stage. Building and prop materials are classified through the toon shader (`TEX-MAT-*` and zone prop bindings). GUT `test_painted_textures.gd` checks that every CSV texture is imported and used, that presets name real textures, and the decal scatter. Per-zone fps is recorded in progress.md (lowest 57 on Medium). |

---

## PARTIAL / BROKEN

### D.N.A. mini-dungeon return: not confirmed
- The return path exists. `rewards_screen.gd:144` handles the boss clear, `game_session.gd` ends the mini run (about line 2138), and GUT `test_hp_left_goes_back_to_the_zone` and `test_losing_wakes_at_the_hub_for_a_fee` pass.
- **The D.N.A. e2e still fails.** `_screenshots/fifth_brief_final_smoke.log` (2026-10-08, the latest run) ends `FAILED`: 33 checks ok and 7 FAIL. They are the tracker listing, courier hit, invulnerability window, slow-enemy battle, "Cubicle Zombie is for sale", the buy check and "the mini dungeon opens the node map".
- progress.md blames the last one on the smoke script still looking for the old "Chalk up" button, and the other six on script timing. That diagnosis was never confirmed with a re-run.
- The sixth-brief Gainlands smoke fails the same mini-dungeon step.
- **Left:** update or rerun the D.N.A. smoke against the new side-dungeon flow, then confirm in the game that finishing or losing the D.N.A. mini dungeon puts you back in the zone. Today the return is unit-tested, not played end to end.

### Dungeon map alignment: judgment calls
- MAP-PC: node 10 (the Model Room) has no empty circle on the painted platform, so it sits at the foot of the red staircase, with node 9 on the landing before it. Confirmed in the screenshot. If you wanted it on the platform itself, that is still open.
- D-LAB (the postgame Path-ology Lab) uses a placeholder map, with no painted art and hand-set coordinates.
- Several maps have large mean fit offsets (S-GOUR 94 px, D-PC 75 px). That is the nodes being moved to the painted spots, not a defect.

### NPC CSV mismatches
- The Story v2 re-import (63 NPCs) fixed names and ids. These prose and data leftovers remain:
  - **Granny Gristle introduces herself as "Hob Tillbury"**: `data/story/refusemancer_story.tres:113` and `:167`. The portrait name is Granny Gristle.
  - **Shop and place names still use the old owners:** "Farmer Hob's Swap Shed" (`core/zone/heap_zone.gd:132`) and "Tiny Tony's Protein & Pasteboard" (4 files).
  - **Old Man Mountain** says "Head Spotter of the Swole Station" (`gainlands_story.tres:91`). I could not tell from the data whether that is his intended title.
  - progress.md also lists bare first names ("Brenda", "Mabbit", "Tilda") and he/she mismatches (Prudence Pallor, Brother Bramble). My grep found no "Mabbit", "Tilda" or "Coach Brenda" strings left in `core data world app ui`. I did not re-check the he/she lines.
  - Placeholder portraits (king, queen, Rescuer, Dr. Siphon, NPC-NINJA, NPC-VAULTWARDEN) are code-drawn or placeholders until real art arrives.
  - Some in-game NPCs have no list row and so show no portrait. 8 list NPCs do not exist in the game yet because their dungeons are not built (Hob, Kestrel, Warden, Spotter, Itamae, Betty, Raccoon King, Automaton).

### Leftover old names
- **"Wellspring" is still player-visible.** `TitleScreen.GAME_TITLE = "WELLSPRING"` (`ui/screens/title_screen.gd:5`). The town has a "The Wellspring" shop label (`world/town_layout.gd:107`), a "Wellspring" spot (`town_scene.gd:404`) and a "Touch the Wellspring" prompt (`town_scene.gd:709`). The README title is "Wellspring (working title)". No replacement title exists in `story_source_v2.md`.
- **"Beefcake Path" as a place name survives in:**
  - `data/story/capital_story.tres` (the `fx.no_travel` line);
  - `data/story/intro_story.tres` (`beefcake_npc_intro_lines`);
  - `data/npcs/npcs.json:174` (location "Main Town, Beefcake Path");
  - `dungeons.json` `reward_repeat` text (2 entries), which `DungeonCatalog` parses into a pack id;
  - code comments and README.
  - "Beefcake" as the Path name is valid and not a leftover. Whether the story lines should say "the Gainlands" is your call.
- "Verdant Heap" is clean in player-visible text (see DONE).

### Long card names
- The test skips tokens and infrastructure cards. It also only exercises the plain layout. `use_card_frame_overlays=false` is the default, so the framed layout is not covered if you switch it back on.

### Polish: town paths
- Polish A removed the brown dirt ribbons. Story v2 Part B then rebuilt the town (`world/town_streets.gd`) with cream cobble ribbons edged by a tan dirt kerb. I did not look at a current town screenshot, so I cannot say whether you would read those as "brown paths" again. progress.md also lists "painted road ribbons in the town (still the old dirt/cobble ribbons)" as a later idea.

### Polish and feature round: how far "verified" goes
- Most of both rounds is verified by GUT and screenshots only. The polish-round e2e runs were partial: `town_interact_smoke` ran twice with timing patches never re-run, and the Gainlands flow passed 77 of 78 checks.
- The ninja chests, levers, saves and decks were never walked by a scripted mouse.
- Known limits: a loaded save resumes in town or the zone hub (position and zone HP are not saved); the ninja and Warden decks were tuned by eye, not simulated.

### Dungeon import: documented gaps
- Not implemented: the 11 dungeon buffs and debuffs are shown on the Rules panel but not enforced. The Shredding Room pays gold instead of shredding a card. Dungeon node events and challenges are placeholder text and numbers. The Hollow Warden and the Trial have no boss lines.
- D-TTK, D-HFA, D-ROT, D-PC and five side dungeons were checked on map screenshots and unit tests, not walked through the UI.

### Texture rollout: caveats
- The Main Town (59 fps) and Starting Area (57) are a few frames under the 60 target on Medium, within the stated ±5 fps noise.
- Not painted:
  - The Path-ology Lab zone and the town road ribbons.
  - The Gainlands trees (flat colour).
  - The Capital's outer districts, which share one paving look.
  - Wall decals (supported but unused).
- The castle stage only shows where a dungeon has no painted map.
- I did not re-screenshot any zone today.

---

## NOT STARTED

- **3D-model species mismatches.** The world still uses the KayKit humanoids (Mage, Barbarian, Rogue, Rogue_Hooded, Knight) for NPCs whose portraits are tortoise, bear, fox, frog, walrus, ogre, minotaur, yeti, rhino, skeleton, ghosts, cat, otter and others. The full table is `docs/progress.md` lines 2593 to 2625. There are no new models in `assets/` (only KayKit and Kenney packs) and no commits that touch this.
- ~~Papercraft test cleanup~~ — DONE (Group 1): tests, tools, art and docs removed; nothing else depended on them. `.import` files under `docs/` are now git-ignored and untracked.
- **Game title and the "Wellspring" shop and spot names.** No new title has been chosen or applied (see PARTIAL).

---

## Housekeeping noticed

- Running Godot leaves untracked `.import` files under `docs/art/screens/*/` (for example `card_face_revert/`). I left them alone and did not commit them.
