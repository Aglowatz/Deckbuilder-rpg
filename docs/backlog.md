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

### D.N.A. mini-dungeon return: DONE (Group 3)
- `tools/fifth_brief_final_smoke.gd` was updated (sealed side dungeon, "Enter", Level Up box, equipment-slot picker, card offer, dialogue on arrival) and run windowed: **58 checks ok, 0 FAIL**, including "the mini dungeon opens the node map", "the mini dungeon run ended and returned to the zone" and "clearing it granted the unique card (N-30)". No game bug was found; every failure was a stale script step (BL-7).
- The Gainlands smoke still looks for the old "Chalk up" button at its mini-dungeon step; not updated.

### Dungeon map alignment: judgment calls
- MAP-PC: node 10 (the Model Room) has no empty circle on the painted platform, so it sits at the foot of the red staircase, with node 9 on the landing before it. Confirmed in the screenshot. If you wanted it on the platform itself, that is still open.
- D-LAB (the postgame Path-ology Lab) uses a placeholder map, with no painted art and hand-set coordinates.
- Several maps have large mean fit offsets (S-GOUR 94 px, D-PC 75 px). That is the nodes being moved to the painted spots, not a defect.

### NPC CSV mismatches: largely fixed in Group 2
- Granny Gristle introduces herself as herself; shops are now Benchley's Protein & Pasteboard, Granny Gristle's Compost Grange and Mirepoix's Dessert & Deckery; "Head Spotter" and the fair judge were updated (BL-6).
- Still open: placeholder portraits (king, queen, Rescuer, Dr. Siphon, NPC-NINJA, NPC-VAULTWARDEN); in-game NPCs with no list row (see the ART INVENTORY section); 8 list NPCs whose dungeons are not built (Hob, Kestrel, Warden, Spotter, Itamae, Betty, Raccoon King, Automaton).

### Leftover old names: fixed in Group 2 (judgment calls BL-2 to BL-6)
- Title is "The Wayward Path" (title screen, README, export path and product name, window title set at runtime). The town well is "The Old Well". "Wellspring" now appears only in lore text about the in-world springs, code comments, and historical docs.
- "Beefcake Path" as a place name is gone from story lines, NPC location and repeat-reward text. It remains only as the Path's own name (Rollo's quest row in `npc_list.csv`), history docs (`progress.md`, `open_questions.md`), a test assertion that accepts either name, and a code comment.
- "Pathavia" is now "Pathwork" everywhere except the history line in `open_questions.md`.
- Final search results are in the Group 2 report in `docs/progress.md`.

### Long card names (Group 7: the fit test now also covers tokens, Infrastructure and the framed look; all pass)
- The test skips tokens and infrastructure cards. It also only exercises the plain layout. `use_card_frame_overlays=false` is the default, so the framed layout is not covered if you switch it back on.

### Polish: town paths (fixed in Group 6, BL-12: streets are mown grass, stone only on the plaza)
- Polish A removed the brown dirt ribbons. Story v2 Part B then rebuilt the town (`world/town_streets.gd`) with cream cobble ribbons edged by a tan dirt kerb. I did not look at a current town screenshot, so I cannot say whether you would read those as "brown paths" again. progress.md also lists "painted road ribbons in the town (still the old dirt/cobble ribbons)" as a later idea.

### Polish and feature round: how far "verified" goes
- Most of both rounds is verified by GUT and screenshots only. The polish-round e2e runs were partial: `town_interact_smoke` ran twice with timing patches never re-run, and the Gainlands flow passed 77 of 78 checks.
- The ninja chests, levers, saves and decks were never walked by a scripted mouse.
- Known limits: a loaded save resumes in town or the zone hub (position and zone HP are not saved); the ninja and Warden decks were tuned by eye, not simulated.

### Dungeon import: documented gaps
- **Fixed in Group 4:** all 11 buffs and debuffs are enforced (plus Corrupted Food, which was listed as active but did nothing) and the 11 inline Event nodes have real scenes with 2-3 choices (BL-8 to BL-10, `test_dungeon_rules.gd`, `test_dungeon_events.gd`). Still open: the Shredding Room pays gold instead of shredding a card; node challenges still use placeholder numbers; the Hollow Warden and the Trial have no boss lines.
- D-TTK, D-HFA, D-ROT, D-PC and five side dungeons were checked on map screenshots and unit tests, not walked through the UI.

### Texture rollout: caveats
- Main Town and Starting Area now hold 64 fps on Medium (Group 6, BL-13).
- Not painted:
  - The Path-ology Lab zone and the town road ribbons.
  - The Gainlands trees (flat colour).
  - The Capital's outer districts, which share one paving look.
  - Wall decals (supported but unused).
- The castle stage only shows where a dungeon has no painted map.
- I did not re-screenshot any zone today.

---

## NOT STARTED

- **3D-model species mismatches** (research and options written in Group 7: `docs/design/npc_models.md`; no remodel yet, your decision).** The world still uses the KayKit humanoids (Mage, Barbarian, Rogue, Rogue_Hooded, Knight) for NPCs whose portraits are tortoise, bear, fox, frog, walrus, ogre, minotaur, yeti, rhino, skeleton, ghosts, cat, otter and others. The full table is `docs/progress.md` lines 2593 to 2625. There are no new models in `assets/` (only KayKit and Kenney packs) and no commits that touch this.
- ~~Papercraft test cleanup~~ — DONE (Group 1): tests, tools, art and docs removed; nothing else depended on them. `.import` files under `docs/` are now git-ignored and untracked.

---
