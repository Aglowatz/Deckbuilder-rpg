# Report - Size + performance pass Nov 3 (Fable 5.1, then Opus 5.5)

Brief: "SIZE + PERFORMANCE PASS" (Parts 0-8). Tag `pre-size-pass`. Full report: `docs/perf/size_pass_nov3.md`. Decisions:
`docs/overnight_inbox.md` ("Size pass Nov 3", 6 items). v0.5.2 exported and smoke-tested; the v0.5.1 zip is deleted.

| | v0.5.1 | v0.5.2 |
|---|---:|---:|
| Download (zip) | 799 MB | **600 MB** (-25 %) |
| Pack | ~883 MB | 699 MB |
| Crosspath peak RAM / VRAM, Medium D3D12 | 1575 / 843 MB | 1516 / 815 MB |
| Crosspath peak RAM / VRAM, Low-end OpenGL | - | 1305 / 451 MB |
| Capital outskirts fps, Medium / Low-end D3D12 / Low-end OpenGL | 58.0 / - / - | 58.9 / 78.3 / 82.2 |

| Part | Result |
|---|---|
| 0 Baseline | payload by category, RAM / peak / VRAM / load / fps in 15 spots at Low and Medium, min-spec note (UHD 620, 4 GB) |
| 1 Unused files | reference graph tool; the export was already clean (0.8 MB unreferenced, 2 HUD images excluded); no missing resources on the exported build |
| 2 Music | all 123 tracks re-rendered at Vorbis q3 (213 -> 175 MB), blind A/B folder on Drive, spectral check; audio GUT + music smoke OK |
| 3 2D art | on-screen sweep of 26 screens (paintings already drawn above native), WebP 0.80 / 0.85 by kind, stills back to lossy; -75 MB |
| 4 World textures | opaque surfaces BC1 + mipmaps, normal / roughness maps 256; nine before/after shots, no visible change; -93 MB |
| 5 Memory | bounded LRU ArtCache behind seven loaders, 8 music streams kept, no parked scene on Low-end |
| 6 Low-end | preset + settings row + first-launch auto-pick + 30 fps cap; all shaders compile on OpenGL 3.3; walk smokes, battles and the exported bot OK there |
| 7 Engine build | not attempted (no toolchain, 2.7 GB disk) |
| 8 Build | v0.5.2 zip 600 MB, release smoke + exported playtest bot OK, full sharded GUT 0 failing, policy doc + 750 MB budget |

Not reached: the 350-450 MB download (600 MB; the rest needs a trade-off, inbox 2) and a third off peak RAM (4-7 % on D3D12, 17 % on
Low-end OpenGL; the remaining memory is engine-side, inbox 3).

# Report - Overnight Nov 2-3 (Opus 5.5)

Brief: "QUEUED FOLLOW-ON - OVERNIGHT Nov 2 -> 3" (Parts 1-7), started after the Batch 11 import (e33421ca). Tag `pre-overnight-nov2`.
State: docs/loop_state.md. Decisions: docs/overnight_inbox.md ("Overnight Nov 2-3").

**STOPPED IN PART 6.** The sharded full GUT run was stopped by Claude Code (the machine ran critically low on memory) and is not restarted
without you; C: has 1.4 GB free, too little for the v0.5.2 export (about 1.7 GB peak), and deleting the importer's staging folder
`_art_inbox/npc_sprites` (890 MB) to make room was not permitted. Parts 1-5 are done, verified on their own test groups and pushed.

**Nov 3 morning (designer-approved cleanup + Part 6 resumed):** disk cleanup done (`docs/cleanup_nov3.md`; C: 1.31 -> 4.63 GB free, Drive
1.19 GB to trash). Full sharded GUT run: 2 failures, both fixed, then **2615/2617 passed, 0 failing, 2 risky/pending** (32 shards, 20 min).
(1) `test_every_script_compiles`: a stray draft `_screenshots/nov2/town_streets_new.gd` (from Part 4) also declared `class_name TownStreets`;
renamed to `.gd.txt`. (2) `test_back_from_the_arena...`: `UiArtWarmup._warm_screens` awaited `get_tree().process_frame` after the town was
parked (null tree) - a real bug on any arena / graveyard fight started during the first-screens warmup; it now stops when it leaves the tree,
frees the half-drawn screen and leaves input on (`_exit_tree` already restores it). **v0.5.2 export NOT done**: `export_windows.sh 0.5.2` was
stopped by Claude Code for low memory while baking the zone build cache (2.26 GB free RAM at start; the baker peaked at 1.67 GB). The guarded
script left no staging folder; v0.5.1 is kept (not deleted), no release smoke. The payload estimate is 883 MB, over the 800 MB budget.

| Part | State | Commit |
|---|---|---|
| 1 Dialogue (freeze ends) | **done**: 217 lines applied (208 critic suggestions, 4 designer-line fixes, 3 over the Nov 1 typo fixes, 1 typo fix, Primm's phase-1 rule wording); 2 suggestions already in; 0 conflicts / failures; 1 held beat (the rift sign's "failing") reworded around; story / quest / dialogue groups (104 files) green; `docs/dialogue/edit_nov3.csv` re-exported; `docs/dialogue/applied_nov3.md` (counts + 15 highlights) | 7c2d4538 |
| 2 Items | **done**: Field Bandage -> **Power Wraps** (id power_wraps; old saves load it through `ContentSet.ITEM_RENAMES`); **Reckless Tonic** heals 5 or, **1 in 4**, deals 1 damage instead (sim: every odds from 1/6 to 1/3 sits with the Vitality Charm; the description states both and the odds; toast + sound); `docs/design/items_nov3.md`; 193 item tests green | 77c90e1c |
| 3 Faster returns | **done**: arena 4.6 / 4.2 s -> **1.0 / 0.9 s**, graveyard 4.2 / 4.3 s -> **0.88 / 0.87 s** (parked town); dungeon node fights keep the rebuild (0.7 s, mostly fades); two park bugs fixed (dialogue portraits freed when a scene left the tree - this also hit the Nov 2 roamer resumes; UI sounds wired twice); `docs/perf/loading_nov3.md` | 6c40c713 |
| 4 Capital props + Grave Row | **done**: wheels at 60 % on gilded plinths, the paste dispenser gilded and ornate, a decorative twin tram shed (the big transit rift moved to the yards' east corner - inbox 2), Grave Row and the palace approach paved in checker with formal parterres; `docs/art/capital_nov3/` (before / after); Capital tests + walk smoke OK | 94e7fdd2 |
| 5 City camera | **done**: Settings "City camera" Standard / Raised / Low (default Standard) + a Dev Menu picker; six spots x three cameras, `docs/art/capital_camera_nov3/contact_sheet.jpg`; fresh critic: **Raised 1st** (7/8/6), Standard 2nd, Low 3rd (grandest, least readable); **recommend Raised** - inbox 4 | 12f6806d |
| 6 Verify + build | **stopped**: full GUT killed for low memory (not restarted); export blocked by disk space. Walk smokes, perf and the release smoke not run this night (the Batch 11 run earlier did all seven smokes + perf). **Nov 3**: disk freed; full GUT green after 2 fixes (stray class copy, warmup null tree); v0.5.2 export stopped again for low memory - not built | Nov 3 commit |
| 7 Critic cycles | not started | - |

Decisions for you (also in the inbox, most important first): 1) free memory / disk and say go for Part 6 (full GUT, smokes, perf, export
v0.5.2); 2) the city camera default (Raised recommended); 3) the twin tram shed moved the big transit rift; 4) Grave Row's headstones read
lower on the pale checker; 5) the dialogue is applied - your next edits go in edit_nov3.csv.

---

# ART LIST READY - docs/art/art_needed_nov2.csv (47 rows; Part 1 of the Nov 2 pass)

# Report - Nov 2 pass (Fix + polish, Fable 5.1)

Sun Nov 2, from 09:45 MST. Brief: "FIX + POLISH PASS Nov 2 - The Wayward Path", Parts 1-8. Tag `pre-nov2`. Judgment calls:
`docs/overnight_inbox.md` ("Nov 2 pass"). State: `docs/loop_state.md`. Previous report (the Capital sides pass) is below this one.

## Summary (all eight parts; commits edf1950d, 3fcd7d39, 6cf0462e, e027e5df, 27d49f01 and the finish commit)

- **Art list** `docs/art/art_needed_nov2.csv` (47 rows) + seven 3D figures swapped to painted sets (Part 1).
- **No plants inside the Capital walls** on any entry path, with a test per path (Part 2).
- **Back from a fight in 0.9-1.0 s** everywhere (the world scene parked through the battle; was 2.5-8.6 s); the Capital builder 7.5 -> 4.9 s;
  the rest of the loading work (town caching, threaded pre-load, shader pre-warm) is listed as next in `docs/perf/loading_nov2.md` (Part 3).
- **Items**: every description exact; Scroll Draw 1, Tonic 30 g, Bandage +0/+2 for the battle, the high shelf at level 17 retuned, by sim (Part 4).
- **Hats** fitted to the head in the tailor and the world alike (Part 5). **The Crosspath fountain** is solid, symbol pillars and coloured
  water, never fading or turning (Part 6). **Packs centred** in reward boxes (Part 7).
- **Verified**: GUT 2586/2589 (2 pending), six walk smokes OK, perf inside budget, a play-script run (Part 8). Judgment calls: inbox items 1-10.

## Part 1 - Art audit (done first; commit "Nov 2 pass, Part 1")

**The art list**: `docs/art/art_needed_nov2.csv`, the Art Batch tab's columns (Art ID, Category, Zone, Name/what, Priority, Lock, Size/format,
Save to, File name(s), Image description, Notes), 47 rows. High = seen in normal play. Contents: the Rescuer portrait redo (both arms), two
Rescuer expressions on the redone base, the Leaf Crown sheet redo, 11 sprite sets + 7 portraits for the figures below that have no fitting set
(plus a Low-priority dedicated gate-guard set), 11 story stills for the beats that still play on the icon stage (Primm's phase 1, phase 2
and fall; the House of Gains rescue; the Doppelganger reveal; epilogue beats 1, 3, 9, 4, 10, 6, 7), the Crease prop sheet + brick texture, the
D.N.A. lobby carpet / terrazzo / prop sheet, the Gate Road palace backdrop, the Buffet bridge's salt-shaker pillars, the Quota lieutenant
battle board, the four Capital requests from the Nov 1 report, the skipped expression portraits and N-10-REDO. No item icon changes: Part 4
keeps every item's name and object (see Part 4).

**3D figures found in walkable areas** (every NPC, roamer, guard, citizen, vendor and enemy was checked: the sprite-vs-model choice is
`NpcSprites.character_for_entry` for list NPCs (an entry with neither `npc_id` nor `sprite` keeps its 3D model), `ZoneEnemy._make_model` for
roamers (all 22 enemy kinds have painted sets), `TownScene._add_npc` for Crosspath). The Rescuer, Maren, the rift operators, the ninja, the
Dump workers and Colonel Casserole have painted sets with a 3D fallback only when the art is missing; none fall back today.

| Figure | Where | Was | Now |
|---|---|---|---|
| Gate Guard (Height Inspection), Gate Guard (Queue Management) | Capital, outside the gate beside Spotless | tinted KayKit Knight | painted Correction Officer set (`"sprite": "FOE_CORRECTION_OFFICER"`, 1.2 x hero): a white-and-gold officer, the fitting guard look; talk spots unchanged |
| Gate Guard (Exit Control) x 2 | Capital, inside the gate by the plaza fountain (the ones in the user's screenshot) | tinted Knight | the same officer set, facing into the city as before (`nov2_p1_gate_guards_in.jpg`) |
| Primm's Guard | the Crease after Primm falls (freed state) | tinted Knight | the same officer set |
| Citizen 4471 (the ward patient) | Capital, Correction Ward | tinted Rogue | the painted CITIZEN set, pale tint (`nov2_p1_patient.jpg`) |
| Foreman Gus | Gainlands, by the works | tinted Rogue_Hooded (his own set existed but the entry never named it) | `"sprite": "GUS"` (`nov2_p1_gus.jpg`) |
| Nurse Hesper Dray | Capital, the Crease heal spot | tinted Mage | art list: SPR-HESPER + NPC-HESPER (High) |
| The Exit Clerk | Capital, Gate Plaza booth | tinted Rogue_Hooded | art list: SPR-EXIT-CLERK + NPC-EXIT-CLERK (High); the Lost Junior Clerk set is a 0.6-height child and reads wrong |
| Gym attendant (cheering) | Gainlands gym hall | Barbarian, Cheer animation | art list: SPR-GYM-ATTENDANT (High; barks only, no portrait) |
| Gary, Currently Under a Barbell | Gainlands yard | Barbarian, Lie_Idle | art list: SPR-GARY (a lying set) + NPC-GARY (High) |
| Sous-Chef Tarragon | Endless Buffet | Rogue_Hooded | art list: SPR-TARRAGON + NPC-TARRAGON (High) |
| Brisket, Sir Loin (gate guardians) | Endless Buffet gates | code-built 3D golems (Casserole is painted) | art list: SPR-BRISKET, SPR-SIR-LOIN (High) |
| Billie Muckfoot | Verdant Dump | Rogue | art list: SPR-MUCKFOOT + NPC-MUCKFOOT (High) |
| Sorrel (growth-spot druid) | Verdant Dump | Mage | art list: SPR-SORREL + NPC-SORREL (High) |
| The Secret Dealer | Crosspath hidden alley | Rogue_Hooded | art list: SPR-DEALER + NPC-DEALER (Medium, hidden) |
| Threadwell's window mannequin | Crosspath | HeroModel "mannequin" | kept: it is a mannequin by design |
| Dump critters, the stable animal | Verdant Dump | Cube Pets animals | kept: ambient wildlife, not characters (inbox 1) |
| D.N.A. queue figures | D.N.A. far landmark (backdrop, not walkable) | KitMesh ghost silhouettes | kept: part of the painted landmark's composition |

**The Rescuer**: only the dialogue portrait `NPC-RESCUER` has the one-armed read (her left arm vanishes under the cloak). Her sprite set and the
STORY-CAPTURE still show both arms; NPC-ELOWEN (revealed) is fine. The list row describes the same design with both hands placed.
**Leaf Crown**: the FRONT view's arc ends point straight up (horns); the row asks for a closed ring whose ends sweep down and round the head.

Shots: `docs/overnight/nov2/shots/nov2_p1_*.jpg`.

## Part 2 - Capital: no plants inside the walls on every entry path

**Cause**: the look rig (`WorldLookRig`) builds a random foliage layer (grass, wildflowers, bushes) from the zone mood's `foliage` block, once,
at scene build, from the mood the hero stands in. `capital_inside` / `capital_freed` carried `density 1` (cells grass, wildflowers, tall
flowers, bush) while `capital_outskirts` has `density 0`. Walking in through the gate therefore never built the layer (the mood change at
the gate only toggles visibility of a layer that does not exist), but any build that STARTS with the hero inside - a save loaded inside, the
return from a fight inside, the first build after the hole in the west wall or the service shaft, the freed city - scattered 2811 cards over
the city, 1418 of them inside the wall. The build cache replayed the same placement.

**Fix**: `data/art/zone_looks.json`: `capital_inside` and `capital_freed` foliage density 0 (the dark variants extend them). The design
dressing (CapitalDressing: topiary, rose planters, parterres) is untouched. Every path now produces the same scene: no WorldFoliage layer,
ZoneDressing's 395 wasteland items all outside the wall (z >= 76).

**Test**: `tests/world/test_capital_no_scatter_paths.gd` builds the real Capital scene per entry path (gate, west-wall hole, service shaft /
Crease spawn, fast-travel landing, a save loaded inside at four points, back from a battle inside, the freed city inside and at the gate, a
second build from the build cache) and counts the generic scatter layers' instances inside the wall: 0 on every path; plus the moods' density
is asserted 0. Run with the old density it fails with 1418 inside. Because the headless renderer returns no MultiMesh transforms, both scatter
producers now keep their instance positions as node metadata (`positions`), which the test reads.

**Screenshot**: `docs/overnight/nov2/shots/nov2_p2_side_left.jpg` - Grave Row's lawn after a build that started inside (the hole's exit), no
bushes.


## Part 3 - Loading times (the return from a fight done; the rest in part)

**Measured first** (`tools/run_loading_timing.sh`, windowed, the real SceneManager; cold = build-cache miss, warm = second visit):
`docs/perf/loading_nov2_before.md`. Back from a fight 2.5-3.5 s in the zones, 4.2 s in town, 8.6 s in the Capital; town -> zone 3.5-3.9 s warm
(the Capital 10 s, the Dump 11 s cold: painted swaps 5 s); zone -> town 5.2 s; zone -> side dungeon map 2.3 s (1.6 s of it the loading screen's
minimum hold). Peak working set 2222 MB.

**(1) Return from a fight - done.** SceneManager keeps the world scene alive OUT of the tree for a zone or town roamer battle and puts it back on
the return (`park_next`, `has_parked`, `_resume_parked`; `ZoneScene.resume_after_battle`, `TownScene.resume_after_battle`, `AmbientEmitter.resume_in`;
`Session.start_battle` asks for it only for roamer fights - gatekeeper, arena, graveyard, dungeon and dev battles rebuild as before). After: 0.9-1.0 s
in every zone, the town and the Capital (`docs/perf/loading_nov2_after_parked.md`); peak RAM 2113 MB (no rise); no script errors over 60 transitions.

**(2) Procedural layouts cached - the Capital, in part.** `KitMesh.fill_cached_set` + `CapitalKit.resolve_slot`: the townhouse and tower generators
(`CapitalGrand`) keep their geometry in the BuildCache (the painted card slots are re-resolved on a hit). Capital builder 7.5 s -> 4.9 s warm (the 16
houses 2.5 s -> 0.2 s, the skyline 1.2 s -> 0.7 s). Left: the other Capital buildings (1.2 s), landmarks + props (1.1 s), the merge (0.4 s); the town's
props (0.8 s), square (0.9 s) and hub land (0.8 s) are many small pieces and are not cached yet (town -> zone stays 3.5-3.9 s warm, zone -> town 5.2 s).

**Loading screen hold** 1.6 -> 1.0 s (`LoadingScreen.MIN_SECONDS`): zone -> dungeon map 2.3 -> 1.6 s.

**Not done**: (3) threaded pre-loading during the fade, (4) shader pre-warm at boot (the settle step is 0.45-0.65 s per zone load, worst frame
320-440 ms), (5) the loading screen already shows zone art + a tip for area changes. The full after-measurement with the Capital cache was not re-run.

## Part 4 - Usable items + economy (done; `docs/design/items_nov2.md`, test `tests/core/data/test_items_nov2.gd`)

Every description now states the effect in plain words (numbers, target, duration, uses), the flavour after the rules where it fits; the
.tres the game loads are regenerated from the code (`tools/generate_content.gd`) and the test checks both agree. Sims: `tools/item_sim.gd`
(no item vs one charge of a variant, the expected player of each Path, every encounter of a zone). Changes:

| Item | Change | Why (sim) |
|---|---|---|
| Scroll of Insight | Draw 2 -> **Draw 1**, 2 uses, 45 g | Draw 2 was the strongest item on the shelf (+12.5 pts at L6); Draw 1 +9.4, level with the Firebrand (+10.4) and the Stone (+9.4) at 45 |
| Reckless Tonic | "One big gulp - use it wisely, there is only one." -> "You heal 5 HP in one big gulp. One use - there is only one."; 45 -> **30 g** | +1.0 at 45 (7 HP tested worse, -3.1); a one-use 5 HP is a weak item |
| Field Bandage | Mend 3 damage on a unit -> **"+0/+2 for the rest of the battle"** on one of your units, 3 uses, 30 g | the mend did nothing (-1.0, used in 0 % of games: unit damage clears each turn); +0/+3 this turn was +11.5 (too strong at 30); +0/+2 for the battle +5.2, a lasting job the Stone's one-turn strike does not do |
| High shelf | opens at **level 17** (was 6; `ProgressionTable.ITEM_VENDOR_ADVANCED_UNLOCK_LEVEL`, `level_track.json` item_advanced + headlines: L6 "A little pocket money", L17 "The shops' best stock: Sable's rares, Tilly's high shelf") | the brief's 17-20; 17 already opens Sable's rare stock, 18 is the Legendary / gilded level, 20 the third item slot |
| Binding Chains | 1 -> **2 uses**, 60 -> 90 g (new `Economy.ItemBand.LATE`) | +2.1 at L17 vs the Capital with one use; the second use makes it the late tempo item |
| Silence Powder | toss 1 -> **toss 2**, 30 -> 60 g | toss 1 +2.1, toss 2 +6.8 |
| Grave Dust | bury 3 -> **bury 6**, 30 -> 45 g | -1.6 / -2.1 against the Capital's graveyard-happy foes: a deck-out niche for the long bosses, kept cheap |
| Summoning Charm | 1 -> **three** 1/1 Militia, 45 -> 90 g | a 1/1 at L17 is nothing; three bodies are a wall or a swarm (the Capital sim for the rest of the shelf timed out at 10 min; `items_nov2_high_b.md` if it is rerun) |
| Ward Sigil | 30 -> 60 g, text states the keyword, the turn and the uses | the policy never found a use (0 %), the price follows the shelf |
| The rest | Draught / Charm / Salve / Firebrand / Stone / rations / Pie: descriptions only | - |

Use count, stacking, where: unchanged (one use per equipped item per battle, charges = uses, the HP ones also between fights; the
inventory has no cap, the item slots pick what comes to a fight). No icon changed (no item changed its object), so nothing went on the
art list. Game-text changes (not dialogue): the 18 item descriptions above, the two level headlines, the shop's frosted-glass line now says
level 17 (it reads the constant).

## Part 5 - Wardrobe hat try-on (done)

The preview and the world place hats from the same anchors and the same fit data (`tools/hat_contact_sheet.tscn` draws every hat x direction
as the world and as the real HeroPreview side by side: identical cells before and after), so there was no second scale path to unify - the
three big hats were simply fitted too big and too deep for both: brims of 1.85-2.25 head widths sunk 0.6-0.7 head widths over the brow,
so in the tailor's close 1.25x view the Wide-Brim covered the whole face. `assets/art/cosmetics/hats/fit.json`: Wide-Brim width 2.25 -> 1.75,
Wizard 1.9 -> 1.55, Tricorn 1.85 -> 1.55, Bowler 1.45 -> 1.3; the front / side sinks lifted (0.48-0.56) so the brim clears the eyes, the back
sinks eased (0.88-0.98). Chef and the (held) Leaf Crown unchanged. Shots: `nov2_p5_before_try_wide_brim.jpg` -> `nov2_p5_try2_wide_brim.jpg`,
`nov2_p5_try2_wizard.jpg`, `nov2_p5_try2_tricorn.jpg`, the world `nov2_p5_world2_wide_brim.jpg`, the contact sheets `nov2_p5_sheet_before_widebrim.jpg`
/ `nov2_p5_sheet_after_widebrim.jpg` / `nov2_p5_sheet_after_wizard.jpg` (FRONT, FRONTSIDE, SIDE, BACKSIDE, BACK; world | preview each), the
numbers in `docs/overnight/nov2/hat_fit_table_after.md`. New shot hook: `--open=tailor --try=hat_wizard`.

## Part 6 - Crosspath fountain (done)

The painted card (TOWN-HERO-FOUNTAIN, a camera-facing billboard) is replaced by solid geometry in `TownStreets._fountain`: a round sandstone
basin of two courses with seams, four square pillars on the rim with a framed Path symbol each (the same icons as the crest ring, facing out)
and a spout mouth facing in, four coloured streams arcing into a vertex-coloured pool (one animated material, `assets/shaders/fountain_water.gdshader`:
two-layer scrolling noise + foam, the Path colour per stream and blended into the pool round each landing), a stepped column with a medallion
and a flat cap, ivy (the kit's decal) on the basin and the pillars, a few drops at each landing. 4.6 m tall (the card stood 7.1 m: the solid
pieces read smaller from the play camera, so the first pass was scaled up a fifth), the blocker radius, anchor and the hero's x-ray silhouette
test unchanged (`FOUNTAIN_ART_HEIGHT` 4.6, `FOUNTAIN_ART_FORWARD` 0). Nothing fades, pops, rotates or billboards. Before / after from four
angles: `nov2_p6_before_{n,s,e,w}.jpg` -> `nov2_p6_after3_n.jpg`, `nov2_p6_after3_e.jpg`, `nov2_p6_after2_s.jpg`, `nov2_p6_after2_w.jpg`; the
symbol face close up `nov2_p6_pillar6.jpg`. One bug on the way: the frame, panel and mouth boxes had their wide axis along the pillar's
outward direction (fins that swallowed the symbol quad) - the axes swapped.

## Part 7 - Pack reward centring (done)

The pack tile's holder filled the tile's width (170 px) while the art was parked at the middle of the holder's minimum width (102 px), so
every pack sat 34 px left of centre in a reward box, at any resolution. `ui/screens/reward_popup.gd`: the holder keeps its own size, centred
in the column (`SIZE_SHRINK_CENTER`), and the art re-centres on the holder's real size when it changes; the pack shop's tile got the same
flag (`ui/town/pack_shop_screen.gd`). Cards and item icons were already centred (direct children of the row / shrink-centre). Shot:
`nov2_p7_reward_pack.jpg` (a STEP REWARD box with a card, an item and a pack; new shot hook `--open=reward_pack`).

## Part 8 - Verify + finish (done; no build export)

- **Sharded GUT** (`bash tools/run_tests.sh`, 31 shards, 20 min): 2586 / 2589 passed, 2 pre-existing pending, the one failure was
  `test_loading_screens` wanting the loading-screen hold at least 1.0 s - the hold is 1.0 s now (not 0.9), the test passes, the dungeon map
  change stays at 1.6 s.
- **Walk smokes**: Crosspath (19 shots), Gainlands (11), Buffet (22), D.N.A. (20), Dump (21), Capital gate AND the hidden hole + districts +
  save / load + freed (36): all OK.
- **Perf frame budget** (Medium): crosspath avg 15.2 ms, 1 % low 24.8 ms, 794 draws, RAM 1549 MB; capital_in avg 17.3 ms, 1 % low 19.3 ms,
  734 draws (was 847: the cached townhouse / tower geometry batches the same), RAM 1512 MB - inside every budget. (A first measure right after
  the 20-minute suite read a 36 ms 1 % low on the Capital; the rerun on a quiet machine is the number above.)
- **Play script** `docs/review/play_scripts/nov2_p8.txt` (`bash tools/play.sh ... nov2_p8 420`, 14 shots in `_screenshots/play/nov2_p8/`):
  the Crosspath fountain walked round from four sides (steady), the wardrobe, a zone change to the Gainlands and a walk through its roamers'
  ground, the Capital entered inside at the Crease spawn (no bushes on the left side, `13_capital_left`), back to town. No roamer happened to
  intercept the blind walk, so the pilot logged "no battle on screen": the fight-and-return path is covered by the loading tool's run (ten
  roamer fights resumed into their parked scenes, `docs/perf/loading_nov2_after_parked.md`) and the blind walk to Tilly's stall stopped at the
  old well; her shop was checked by a screenshot instead (`nov2_p4_tilly_l17.jpg`: the new descriptions, the high shelf open at level 17).
- `docs/design/level_rewards.md` regenerated (the level-6 and level-17 headlines).


---

# Report - Capital sides pass (Nov 2, Fable 5.1)

Sun Nov 2 07:00 -> 09:30 MST. Brief: "CAPITAL SIDES PASS (follow-up to the inner-city rebuild)", items 1-7. Tag `pre-capital-sides-nov2`.
Full report (what the screenshot showed, every part, the critics' rounds, perf, the before / after gallery): `docs/art/capital_rebuild_nov1.md`,
section "The sides pass (Nov 2)". Judgment calls: `docs/overnight_inbox.md` ("Capital sides Nov 2", items 1-5). Previous report below.

## Morning summary

- **No scatter on paving.** Plants stand only on painted lawn or inside a planter; every district lane and separator is lined with continuous
  white planters (gold lips, roses, a cone in a gold urn every 4 m). A test counts loose plants inside the wall (0).
- **No black objects.** The cause was the kit's near-black flat slots under the toon shadow band, not a missing texture. Every inside piece is
  restyled white and gold (bins, sacks, crates, the compost covers, the sick patch, drain covers, Ward bars, tram rails, dead windows, dead
  globes, Fern's shack). A probe test walks every visible triangle inside the wall: 434.8 m2 of near-black before, 0.31 after (budget 0.6).
- **No skinny buildings.** The Reek's yards, Grave Row's crypts and the Hungry Quarter's six stalls are grand townhouses with their district's
  service layer (one long shop-house a side of the Hungry lane); the plaza corners' pylons are gate piers; the district pylons are gone; the
  walls' inner faces wear a blind arcade with niche statuettes, wall basins and eleven engaged towers.
- **Side plazas** at (19, 58) and (100, 58): a two-tier side fountain with the gilded Primm on top, a gilded statue pair, a checker disc with
  ring borders, banner lamps, rose planter arcs; the routes end at the rim. The wheels, the pylons, a chest, the junk and the transit rift
  moved a little for them; every NPC, talk spot, pickup and entrance stays.
- **Gardens / order**: pink 3D lamps in rows on every lane (the painted card read brown), two parterre beds on Grave Row, a white-and-gold
  cordon round every rift inside the wall.
- **Critics (sides only, strict)**: s2 4/4/5/5/4/3/5/4 -> s3 4/4/5/5/4/4/6/5 -> s4 5/5/6/6/4/4/6/5. What they ask for next is mostly the
  story's props (the wheels, the rifts, the shed, the cable) - inbox 1.
- **Verified**: world 432/433 (one pre-existing pending), core 1563/1564 (one pre-existing pending), walk smoke OK (36 screenshots), the walkability test green,
  `capital_in` Medium 833 draw calls / p99 19.5 ms (budget 850 / 25; the first measure was 859 - the new statics merged city-wide fixed it).

Commits: ca14bb1c (Parts 1-4), ff06ea81 (perf), af4b45b2 (round 2), 88762f43 (round 3), and the finish commit.


---

# Report - Capital inner-city rebuild (Nov 1-2, Fable 5.1)

Sun Nov 1 20:10 -> 23:15 MST. Brief: "CAPITAL INNER-CITY REBUILD (overnight)", Parts A-G. Tag `pre-capital-rebuild-nov1`. Full report with
the before/after gallery, the plan, the piece list, the scores per iteration and the perf table: `docs/art/capital_rebuild_nov1.md`.
Questions and judgment calls: `docs/overnight_inbox.md` ("Capital rebuild Nov 1-2", items 1-4). Previous report: `docs/overnight/nov1/report.md`.

## Morning summary

Everything inside the great wall was rebuilt in code from the kit's own textures and painted cards (no new image files):

- **The kit** (`world/capital/capital_grand.gd`): a grand townhouse generator (storeys, bays, pastel accent, hip / mansard / gable roofs,
  balcony, pediment with the sun medallion, flower boxes, door, pinnacles, one banner that can hang a degree off), slender towers with pointed
  pastel spires, the gilded Primm (the painted statue card) on tall laurel plinths, a three-tier fountain, planters, paving borders,
  balustrades, lamp banners. Look-dev lineup: `tools/capital_lineup.tscn`.
- **The layout**: the sixteen Showcase footprints, every route, anchor, spot, sign, rift, entrance and the hidden hole stay exactly where they
  were; the houses are 4- and 5-storey mirrored townhouses, towers stand at the plaza's four corners and three districts' corners, two gilded
  pairs flank the avenue's mouth and the castle terraces, four parterre beds and eight banner lamps ring the enlarged fountain, rose planters
  run the boulevard and the lawn panels, the plaza and the boulevard wear a crisp 2 m checker with white-and-gold borders, the gate piers
  carry medallions, lancets and banners, and a skyline of five-storey rows and spires stands beyond the walls and on the hill top. The Grave
  Row flower clumps are gone; nothing random is left inside.
- **Light**: four grade passes (`data/zone_styles/capital_inside.json`): no violet ambient, thin fog, far blur cut, bloom cut, shadows up,
  exposure down, a bluer horizon band.
- **Checks**: world tests 431/431, core 1564/1564, the Capital walk smoke OK (twice), `perf_budget.sh frame capital_in` met on Medium after
  a perf pass (1004 -> 847 draw calls; the townhouses and towers draw as a shadow body plus a no-shadow detail mesh; the second rank, towers,
  statues, lamps and benches batch or instance). Loading path unchanged.
- **Scores** (a fresh critic per iteration, nine criteria, 1-10): c2 4/5/4/2/7/4/6/3/4 -> c6 6/6/5/4/7/6/7/4/5. Statues/fountain reached 8
  once; towers and light stayed at 4. Every critic reported "no roofs, no spires, white sky, overexposed": the play camera sees about six
  degrees above the horizon, so the roofs of any townhouse nearer than ~40 m, the plaza towers' spires and the blue sky are out of frame in
  play, and the sunlit cream plaster is a look-wide matter. Those are camera and look decisions, not Capital ones (inbox 1, 4). The brief's
  8+ on every criterion was not reached; the loop stopped at the plateau rather than making the zone gloomy to please a still picture.

## What to look at in game

1. Walk in through the gate: the inner gate plaza, the fountain ring with its parterres, the gilded pair at the avenue's mouth, the boulevard
   to the castle. Try the Far zoom and the Overview angle for the skyline.
2. The fallen state (after Primm, or `--flags=zone_final_completed` in a shot): crooked banners, warm windows, toppled statues, the dry
   fountain. The Showcase's houses no longer turn into ruins (inbox 2: say if you want the ruins back).
3. The districts keep their own models and states inside the new frame (inbox 3: replacing them with townhouse modules is a day's work).

## Art requests (nothing missing was invented)

- A side / three-quarter painting of the gold Primm statue: the plinth pairs face south like every card; a second angle would let the pairs
  face each other across the boulevard.
- A tileable pastel slate roof in sage (only pink and blue exist), and a gold urn card without the topiary (the rose beds use white planters).
- A CAP-PATH-WHITE re-upload (the Drive copy is truncated; noted since the art pass).

## Parts

| Part | Result |
|---|---|
| A | 13 before shots from the standard spots and the target's framing; the audit table and the plan (fc73c016) |
| B | `CapitalGrand` + the lineup scene; lineup shots in the report (663bf3af) |
| C | The layout as above; `KitBatch.merge_static(root, cell_size)` keeps far views unculled; `garden_fields` apart from the rows' people-room rule |
| D | The light passes; a fog-off and an ACES diagnostic shot showed the remaining paleness is the scene's own brightness, not fog |
| E | Tests, walk smoke, perf (table in the report); the Transit tower moved off a Tidy-Bot home, the Ward tower dropped (it cut the strip to the Ward chest) (b69feace, 1e19b4f4) |
| F | Six shot sets (c1-c6), five critic reports (`docs/review/capital_critic_c2..c6.md`) |
| G | This report, the gallery, the scores, the art requests; committed and pushed |

Gotchas for the next run: the play camera's six-degree sky band; a `node -e` string with an escaped apostrophe or a backtick inside bash
double quotes hangs the whole command (write .js files); the loudspeakers' open horns read as black discs from the front (gold inside now);
the forecourt lawn holds two rifts, so no tower pair fits there; `KitBatch` merged meshes never fade.
