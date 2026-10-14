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

---

## ART INVENTORY

Collected in Group 8 from the repo (`tools/dump_inventory.gd` for the item, equipment and cosmetic lists; file listings against `assets/art/` for the missing ids). "Art" here means bespoke imported art; library icons and code-drawn pictures count as placeholders.

### 1. Cards and tokens with no art yet

All 328 imported images in `assets/art/cards/` are real art. These **11** entries have none:

| ID | Name | Kind |
|---|---|---|
| C-17 | Ambush Party | Colorless Trap |
| NB-10 | The Afterlife Gym | Necrocrat/Beefcake multi-Path |
| NR-09 | Plague of Rats | Necrocrat/Refusemancer multi-Path |
| INF-08 | Bulk Barn | Infrastructure |
| INF-09 | Market Garden | Infrastructure |
| INF-10 | Scrapyard Mill | Infrastructure |
| INF-11 | Old Kingdom Crossroads | Infrastructure |
| JUNK-01 | Heap of Rubbish | Token (junk card) |
| RES-IRON | Iron | Resource token |
| RES-INGREDIENT | Ingredient | Resource token |
| RES-GARBAGE | Garbage | Resource token (the other resource, Red Tape, has art) |

(Source: `docs/art/art_status.md`; the three resource tokens draw as coins with icons on the table.)

### 2. Other missing or placeholder art ids

| Category | Status |
|---|---|
| **Battleboards** | All 22 boards in `battleboard_list.csv` have an image. `BB-LAB` (the Path-ology Lab) is **not in the sheet** and its image is a placeholder. `BB-S-CAP` and `BB-S-TOWN` exist but no battle context uses them yet. |
| **Maps** | All 12 sheet maps are imported. `MAP-LAB` (not in the sheet) is a placeholder. |
| **Portraits** | 58 base portraits (plus 13 expression variants) exist. **Missing (drawn in code by `portrait_placeholders.gd`):** `NPC-KING` (King Harmon Wayweaver), `NPC-QUEEN` (Queen Concordia Wayweaver), `NPC-RESCUER` (The Rescuer, name undecided), `NPC-SIPHON` (Dr. Ambrose Siphon). **Not in the sheet, also code-drawn:** `NPC-NINJA` (Shiro Swindle) and `NPC-VAULTWARDEN` (The Warden of the Four Seals). 13 expression variants exist (see `art_status.md`). |
| **UI** | All 55 `UI-*` ids of `ui_art_kit.csv` are imported. |
| **Icons** | Items, equipment, cosmetics and many enemy/foe icons use the game-icons.net library (`assets/icons/game-icons`), not bespoke icons. No ids are missing, but none of them is custom art. |
| **Textures** | All 65 `TEX-`/`DEC-` ids of `textures.csv` are imported. **Wanted:** the 16-entry `TEX-PLAB-*` set for the Path-ology Lab (`docs/design/pathology_lab.md`). |
| **3D models** | Wanted (also `docs/assets_wanted.md`): species models for the animal NPCs (`docs/design/npc_models.md`), a tortoise for Elder Maren, a hatch model for the Lab entrance. |

### 3. Items, equipment and cosmetics

**Consumable items (18).** The items sold or given in the game. (Three descriptions in the data are flavour only; their real effect is in brackets.)

| Item | Effect |
|---|---|
| Bag of Rubbish | Create 3 Garbage. |
| Binding Chains | Return an enemy unit to its owner's hand. |
| Blank Form | Create 2 Red Tape. |
| Field Bandage | Mend 3 damage from one of your units. |
| Firebrand Charm | Deal 2 damage to an enemy unit. |
| Grave Dust | The opponent buries their top 3 cards. |
| Healing Draught | Heal 3 HP (3 uses). A common camp remedy. |
| Healing Salve | Heal 4 HP. |
| Hearty Pot Pie | Baked at the Grand Pantry oven. Heal 6 HP. |
| Iron Ration | Create 2 Iron. |
| Reckless Tonic | Heal 6 HP (single use). One big gulp: use it wisely, there is only one. |
| Scroll of Insight | Draw a card. |
| Sharpening Stone | Give a unit +2/+2 until end of turn. |
| Silence Powder | The opponent tosses a random card. |
| Spice Pouch | Create 2 Ingredients. |
| Summoning Charm | Summon a 1/1 Militia token. |
| Vitality Charm | Heal 2 HP (2 uses). A small, steady comfort. |
| Ward Sigil | Give a unit Untouchable until end of turn. |

**Equipment (28 pieces, all slots: Helm, Weapon, Armor, Boots, Relic).** Includes the zone pieces (one set per Path zone), the puzzle and arena prizes, the vault and Lab rewards.

| Piece | Slot | Effect |
|---|---|---|
| Big Brain Beret | Helm | It itches, but it's undeniably working. Draw an extra card each turn, but you can play only one non-infrastructure card per turn. |
| Bin Lid Helm | Helm | Whenever you create Garbage, create 1 extra. |
| Bloodsand Boots | Boots | Whenever you are dealt damage, draw a card. |
| Champion's Laurels | Helm | At the start of the duel, gain 4 HP and draw a card. |
| Cheater's Dice | Relic | They only ever land the way you need them to. You always go first, but your opening hand is 1 card smaller. |
| Clerk's Stamp | Relic | Start every duel with 1 Red Tape and 1 Contract. |
| Compliance Clipboard | Relic | At the end of your turn, the opponent loses 1 HP. |
| Compost Boots | Boots | Whenever a unit of yours dies, your units get +0/+1 permanently. |
| Soul Courier's Lanyard | Relic | Everything is routed exactly where you need it. Draw an extra card on your first turn, and max hand size +1. |
| Crowd-Pleaser's Cape | Armor | Each time you declare attackers, gain 1 HP. |
| Extra Pocket | Relic | Sewn in where no one thinks to look. Max hand size +1. |
| Flamethrower | Weapon | Alchemist's fire in a backpack tank. At the start of your turn, deal 1 damage to each opposing unit. |
| Four-Seal Signet | Relic | Max HP +3. Start every duel with 1 Iron, 1 Ingredient, 1 Garbage and 1 Red Tape. |
| Gladiator's Net | Weapon | Whenever an enemy unit enters the field, it gets -1/-1 permanently. |
| Head Chef's Ladle | Weapon | Heavy, battered and trusted by a hundred golems. At the start of your turn, gain 1 HP. |
| Head Chef's Toque | Helm | Whenever you gain HP, gain 1 extra HP. |
| Hover Boots | Boots | A finger's width of clearance, always. Your units have Flying but cannot block. |
| Iron Knuckles | Weapon | Start every duel with 2 Iron. |
| Pantry Apron | Armor | Start every duel with 2 Ingredients, and whenever you create Ingredients, create 1 extra. |
| Refusemancer Seed Satchel | Relic | Every pocket holds something that wants to grow. At the start of your turn, your units get +0/+1 permanently. |
| Siphon's Lens | Relic | A glass lens from the draining chamber, ground to see all four Paths at once. Max HP +2, and you draw an extra card on your first turn. |
| Solid Plate | Armor | Unglamorous, unyielding. Your units get +1 defense. |
| Spotter's Barbell | Weapon | Whenever a unit enters the field under your control, deal 1 damage to the opponent. |
| Gainsmith's Lifting Belt | Armor | Brace the core, brace the deck. Max HP +3 and your units get +1 defense. |
| Thorned Loincloth | Armor | Nobody enjoys being the one who has to remove this from a corpse. Max HP -5; whenever an enemy unit attacks you, it takes 1 damage. |
| Traveler's Boots | Boots | Worn thin by roads longer than this one. Draw an extra card at the start of your first turn. |
| Wicked Dagger | Weapon | A blade with a reputation it didn't earn honestly. Your units get +1 attack. |
| X-Ray Goggles | Helm | Everything looks the same underneath. The opponent's hand is revealed to you - it doesn't see through a face-down trap, though. |

**Cosmetics: hats (12) and cloaks (12).** Visual only, sold by Pip Threadwell or found.

| Name | Slot | Description |
|---|---|---|
| Wizard Hat | Hat | Pointy, wide and slightly too big. Comes with a feeling of competence. |
| Wide-Brim Hat | Hat | Shade for the head, drama for the walk. |
| Bobble Beanie | Hat | Warm, round and topped with a pompom. |
| Tricorn | Hat | Three corners, zero regrets. Arr, mostly. |
| Crown of Leaves | Hat | Grown, not forged. Smells like a very good morning. |
| Chef's Toque | Hat | Tall, white and full of opinions about seasoning. |
| Bowler Hat | Hat | Respectable. Suspiciously respectable. |
| Top Hat | Hat | For the hero who wishes to be a gentleman. |
| Cat-Ear Band | Hat | Two ears, no tail. Purrfectly acceptable. |
| Sun Straw Hat | Hat | Wide, floppy and ready for a picnic. |
| Party Cone | Hat | Every fight is a celebration if you wear it right. |
| Mushroom Cap | Hat | Spotted, squishy and very much alive. |
| Short Cape | Cloak | A jaunty little cape, just for flapping. |
| Traveler's Cloak | Cloak | Long, plain and made for roads. |
| Poncho | Cloak | Stripes, a hole for your head, and zero stress. |
| Hooded Cloak | Cloak | The hood stays down. For now. |
| Patchwork Cloak | Cloak | Every patch has a story. Most of them involve a goat. |
| Tattered Cloak | Cloak | Survived things. Would survive more. |
| Royal Mantle | Cloak | Fur trim, gold clasp and a quiet sense of entitlement. |
| Leaf Cloak | Cloak | Overlapping leaves that rustle when you walk. |
| Starfall Cloak | Cloak | Night-blue with a scatter of tiny stars. |
| Long Scarf-Cape | Cloak | A scarf that got ideas above its station. |
| Cloak of the Four Seals | Cloak | Four sigils, one for every Path, stitched on a cloak that does not wrinkle. |

**Dyes (12):** Crimson, Sunset, Gold, Meadow, Teal, Sky, Royal, Plum, Rose, Cream, Slate, Ink.

### 4. NPCs, bosses and vendors in the game that are not in `npc_list.csv`

| Name | Role | Where |
|---|---|---|
| Shiro Swindle, Master of the Oldest Trick (`NPC-NINJA`) | Trickster / giant-chest con artist, questline boss | Main Town and the four Path zones (inside the giant chests); registered in `npc_game_map.json`, portrait drawn in code |
| The Warden of the Four Seals (`NPC-VAULTWARDEN`) | Vault guardian, hidden boss | The Four-Seal Vault, Main Town; registered in `npc_game_map.json`, portrait drawn in code |
| A Secret Dealer | Hidden vendor (appears after opening the original giant chest) | Main Town |
| Foreman Gus, Wheel Wrangler | Quest giver (Juice the Station) | Gainlands hub |
| Gary, Currently Under a Barbell | "Spot Me!" quest NPC | Gainlands |
| Sous-Chef Tarragon, Fetcher of Things | Quest giver | The Endless Buffet |
| Brisket, Sir Loin, Colonel Casserole | Gate doormen / gate foes of the Cheese Cliffs | The Endless Buffet |
| Old Meatloaf | The Grand Pantry's oldest golem (repair quest target) | The Endless Buffet |
| Wren Muckfoot, Animal Handler | Quest giver | The Verdant Dump |
| Druid Sorrel | Wants the herd rounded up (vine bridge quest) | The Verdant Dump |
| Nurse Hesper Dray | Wake-up nurse | The Capital |
| Gate Guards (Height Inspection, Queue Management, Exit Control x2) | Gate gags and checkpoints | The Capital gate |
| The Exit Clerk | Exit Interview Booth clerk | The Capital |
| Citizen 4471 (A Corrected Citizen) | Correction Ward patient | The Capital, Correction Ward |
| The Hollow Warden | Tutorial boss (no dialogue) | The Forgotten Cave |
| The Restless Cairn | Graveyard boss (a pile of stones, not a person) | Main Town graveyard |
| Props that talk | Compost Bin, Sprout Mound, Fortune Cookie, Grand Oven, "Narrator", Mabbit's loudspeakers | Various zones |

Not in the game although in the sheet: Old Hob the Gravedigger (`NPC-HOB`), `NPC-WARDEN`, `NPC-SPOTTER`, `NPC-ITAMAE`, `NPC-BETTY`, `NPC-RACCOONKING`, `NPC-AUTOMATON` (their dungeons' boss beats are not written).

### 5. Everything else that uses placeholder art

- Code-drawn portraits for the king, queen, Rescuer, Siphon, Shiro Swindle and the Four-Seal Warden (section 2).
- `MAP-LAB` and `BB-LAB` for the Path-ology Lab, and the Lab's 3D stage (primitives plus the existing furniture kit, painted with existing D.N.A. textures; Group 5).
- All NPC and vendor **3D models**: five KayKit humanoids stand in for every species (`docs/design/npc_models.md`); bosses have no 3D model.
- The five giant chests, the vault, the Rift stations and most zone landmarks are primitives or recoloured kit pieces.
- The Primm's Castle 3D stage only shows where a dungeon has no painted map (it has all of them today).
- Shop screens: vendor screens are generic panels (`VS-*` rows in the sheet have no art).
- Dungeon node events, challenges and loot have no illustrations (text only).
- Sound: all sound effects are Kenney CC0 packs; there is no per-zone music beyond what `assets/audio` holds.

## Icons still missing (icon set integration)

- **Equipment without an icon** (they keep their game-icons fallback; add `ICON-GEAR-*` rows to `data/source/icons.csv` and `IconArt.EQUIPMENT_IDS` when art arrives): Four-Seal Signet, Courier Lanyard, Swole Belt, Head Chef's Ladle, Seed Satchel, Compliance Clipboard, Spotter's Barbell, Head Chef's Toque, Compost Boots, Bin Lid, Bloodsand Boots, Champion's Laurels, Clerk's Stamp, Crowd-Pleaser's Cape, Gladiator's Net, Iron Knuckles, Pantry Apron, Siphon's Lens (all `data/equipment/zone/*.tres`).
- **Items** (`ICON-ITEM-OTHERS`, 13 consumables in `CardIcons.BY_ITEM_ID`) and **hats and cloaks** (`ICON-HAT-OTHERS`, the wardrobe and tailor): placeholder rows only, no art supplied; the game-icons silhouettes stay.
- No icon exists for: the "pay N" generic cost inside rules text, the Arena's puzzle/duel markers, the Sprout/Growth minimap points (they keep the lettered disc), the player's own HP in the old (non-art) portrait.

---

## Later (decided 2026-10-14)

| Item | Note |
|---|---|
| **Split the existing hub regions into their own scenes** | Mill Meadow, the Capital districts and the other regions that still live inside a hub scene. Decided "later" in answer to overnight question 2. It needs a quest and save audit first (NPCs, quests, vendors, puzzles, chests and levers keep their anchors in the hub scenes today, OD-8). Sub-area scenes added overnight are new scenes; nothing was moved. |
| **Icons for the remaining lettering** | Done (2026-10-14) for every hub sign, banner, plinth, poster, prop front, Rift station and sub-area gate. Left on purpose: the spot name plates (they fade in near the hero; converting them means a HUD decision: icon plates or prompt-only), feedback pop-ups, the Capital citizens' ":)" card. See progress.md, "Icon signs in every hub". |
| **Mount Swolympus (postgame bonus)** | Postponed 2026-10-14 (Gainlands corrective pass, GC-11): the Swolympus Trailhead sub-area and the Sky Garden-side lever stay in the data, the S-BEEF side dungeon "The Ascent of Mount Swolympus" and its quest "Water for the Hermit" keep their data, but the hub gate is locked ("coming soon"), the Iron Cavern is sealed, the quest needs the postgame, and nothing in quests, hints, the tracker or the minimap points there. The Sky Garden hangs off the Proving Grounds east exit meanwhile. Reopen: `locked` off in `data/subareas/gainlands/_zone.json`, the quest prerequisite in `ZoneQuestDefinitions.side_quests` and `data/quests/side_s_beef.tres`, `GainlandsScene._ask_mini_dungeon`, the `mini_dungeon` POI in `GainlandsZone.poi_kinds`, and the Sky Garden exits. |

---

## Stale smoke sweep (2026-10-14)

Each older smoke run **once**, one Godot process at a time, headless where possible, with short caps to keep total e2e time near 20 minutes. Headless runs have no frame to save, so each brief smoke's screenshot helper now skips the save instead of raising a SCRIPT ERROR. "Capped" means my time limit stopped the run (their own limits are 9 to 30 minutes); steps after the cap did not run.

| Smoke | Mode, time | Result | Stale steps updated | Real bugs |
|---|---|---|---|---|
| `battle_smoke` | headless, 14 s | **pass** (5 turns) | none | none |
| `battle_item_smoke` | headless, 10 s | **pass** | none | none |
| `battle_space_attackall_smoke` | headless, 11 s | **pass** | none | none |
| `battle_human_turns_smoke` | headless 14 s, then windowed | headless **fail**, windowed **pass** | none | none: headless runs frames so fast that for one frame after "Attack with" the screen still shows ATTACK while the AI is choosing blocks. The script says to run windowed; nothing a player can hit. |
| `music_smoke` | headless, 68 s | **pass** (worst crossfade step 0.44 dB) | none | none |
| fourth brief | headless, 75 s, finished | 1 fail, stale | the equipment vendor's advanced stock unlocks at level 13 now (`ProgressionTable.EQUIPMENT_VENDOR_UNLOCK_LEVEL`, moved with the deck box rework), not 10: the smoke keeps using the dev shrine until 13 | none |
| seventh brief (Buffet part; the sixth part passed in the last run) | headless, capped at 240 s | 89 ok, 8 fail | the town exit is named "The Endless Buffet" (was "Path of the Gourmand"); a Quest Complete box from exploring held the hero before M (same fix the sixth smoke got) | **yes, from part 1 of today:** the new hidden sign spots won the E over the spot beside them (soup fountain sign vs. the fountain). Fixed: `ZoneScene._nearest_spot` counts a sign 3 m farther (`SIGN_YIELD`), test `test_a_sign_never_steals_the_e_from_the_spot_beside_it`. Jelly pad / Butter Butte / bounce count: **not diagnosed** (probably the held hero; needs a rerun). |
| eighth brief (Dump part) | headless, capped at 120 s | 34 ok, 4 fail | town exit named "The Verdant Dump" (was "Path of the Refusemancer"; passed after the update); Quest Complete box before M | Brother Bramble's quest / junk dam / objective: **not diagnosed** (follows the held-hero step; needs a rerun) |
| ninth brief | headless, capped at 90 s | 7 ok, 1 fail | zone-effects tooltip is a `HoverTip` on each row now (no `tooltip_text`): check the row names and the hover instead | none seen |
| tenth brief | headless, capped at 90 s | 35 ok, 7 fail | broken-services tooltip is a `HoverTip` per row now | facade citizen and Widow Pell: E after a teleport did nothing (no dialogue, quest not taken; 5 follow-on checks fail with it). **Not diagnosed:** the checks now print overlay / lock / dialogue / nearest spot so the next run shows what swallows the E. |
| eleventh brief | headless, capped at 90 s | 59 ok, 0 fail before the cap | none | none seen |
| twelfth brief | - | **no smoke exists** (`tools/` has none; brief 12's look / tailor / wardrobe flow is covered by the thirteenth) | - | - |
| thirteenth brief | headless, capped at 90 s | ok except 1 stale check | since the passageway rework the zone name on approach is the town's passage label, not the portal spot's plate | none seen |

**Updated and not rerun yet** (time budget): fourth, seventh, eighth, ninth, tenth, thirteenth. Next session: run seventh, eighth and tenth windowed in full (about 30 minutes in total) to confirm the updates and diagnose the jelly pad, the Bramble quest and the Capital E presses.
