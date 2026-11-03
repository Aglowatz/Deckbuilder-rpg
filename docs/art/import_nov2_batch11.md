# Batch 11 art import (Nov 2)

Source: docs/art/art_needed_nov2.csv = the design sheet's Art Batch tab rows 188-232 (Batch 11, # 172-216, 45 images, all approved).
Tag `pre-batch11`. Loop state docs/loop_state.md; questions in docs/overnight_inbox.md ("Batch 11 import").
Backups of every replaced file: `_art_source/superseded_batch11/` (NPC-RESCUER portrait, N-10 card + thumb, the LEAFCROWN hat cards + icon +
its fit_auto entry, CAP-PATH-WHITE albedo / normal / roughness).

## Part 1 - Delivery check

Tools: `node tools/batch11_delivery.js` (looks up each file by exact name in its Drive folder - no folder scans, Approved_Sprites is too big to
list - stages a copy in `_art_inbox/batch11/`), `Godot --headless -s res://tools/batch11_pixels.gd` (alpha, corners, drawn box, sheet runs),
`node tools/batch11_table.js` (this table).

Result: **all 45 Batch 11 images are present** (78 files: 11 sprite sets x 4 poses, 8 portraits, 12 stills, the hat sheet, 2 prop sheets,
4 textures, the path re-upload, backdrop, 3 cut-outs, battle board, card). The two NPC-RESCUER expressions (WORRIED / RESOLVED) are the
sheet's follow-up row and not part of Batch 11; they are listed as not delivered, not as a REDO.

- Sprite sets: every pose of every set is the same character, same scale and same ground line (drawn y 76-1472 on 1536 for all standing sets;
  Gary's lying set 828-1472 on all four poses). All SIDE poses look LEFT (the game's convention; the right side is mirrored).
- Hat sheet: five views, each 296 px wide on one band (y 432-592) - one scale, clear gaps.
- Prop sheets (CAP-SHEET-CREASE, DNA-SHEET-LOBBY): clean 3 x 2 grids with clear gutters.
- Stills: 1792 x 1024 opaque except a 1-px frame border at alpha 221 (an export artefact on all twelve; it sits on the screen edge).
- NPC-GARY's bottom corners are opaque: the barbell runs across the bottom of the frame, as the row asks.
- N-10 came at 1024 x 1536 (asked 768 x 1152): same 2:3, the card importer scales it.
- CAP-BD-PALACE: sky transparent above the skyline, opaque ground - as a backdrop should be.
- The CSV itself: four rows (SPR-CAPITAL-GUARD, STORY-PRIMM-P1/P2/FALL) have unquoted commas in the Zone column; the checker folds them back.

| # | File | Folder | KB | Dims | Alpha / layout | Result |
|---|---|---|---|---|---|---|
| 1 | NPC-RESCUER.png | Approved_Characters | 3000 | 1024x1536 | cut-out | OK |
| 2 | NPC-RESCUER_WORRIED.png | Approved_Characters | - | - |  | MISSING |
| 3 | NPC-RESCUER_RESOLVED.png | Approved_Characters | - | - |  | MISSING |
| 4 | COS-HAT-LEAFCROWN-SHEET.png | Approved_Cosmetics | 570 | 2560x1024 | 5 cols x 1 rows, clear gutters | OK |
| 5 | SPR-HESPER-FRONT_IDLE.png | Approved_Sprites | 1696 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 6 | SPR-HESPER-SIDE_IDLE.png | Approved_Sprites | 1340 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 7 | SPR-HESPER-BACK_IDLE.png | Approved_Sprites | 1669 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 8 | SPR-HESPER-FRONT_TALK.png | Approved_Sprites | 1725 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 9 | NPC-HESPER.png | Approved_Characters | 2785 | 1024x1536 | cut-out | OK |
| 10 | SPR-EXIT-CLERK-FRONT_IDLE.png | Approved_Sprites | 1075 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 11 | SPR-EXIT-CLERK-SIDE_IDLE.png | Approved_Sprites | 757 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 12 | SPR-EXIT-CLERK-BACK_IDLE.png | Approved_Sprites | 1031 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 13 | SPR-EXIT-CLERK-FRONT_TALK.png | Approved_Sprites | 1111 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 14 | NPC-EXIT-CLERK.png | Approved_Characters | 2670 | 1024x1536 | cut-out | OK |
| 15 | SPR-GARY-FRONT_IDLE.png | Approved_Sprites | 1010 | 1024x1536 | drawn 828-1472 (h 644, ground 1472) | OK |
| 16 | SPR-GARY-SIDE_IDLE.png | Approved_Sprites | 667 | 1024x1536 | drawn 828-1472 (h 644, ground 1472) | OK |
| 17 | SPR-GARY-BACK_IDLE.png | Approved_Sprites | 1022 | 1024x1536 | drawn 828-1472 (h 644, ground 1472) | OK |
| 18 | SPR-GARY-FRONT_TALK.png | Approved_Sprites | 1035 | 1024x1536 | drawn 828-1472 (h 644, ground 1472) | OK |
| 19 | NPC-GARY.png | Approved_Characters | 3391 | 1024x1536 |  | OK - corners not clear |
| 20 | SPR-GYM-ATTENDANT-FRONT_IDLE.png | Approved_Sprites | 995 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 21 | SPR-GYM-ATTENDANT-SIDE_IDLE.png | Approved_Sprites | 856 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 22 | SPR-GYM-ATTENDANT-BACK_IDLE.png | Approved_Sprites | 992 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 23 | SPR-GYM-ATTENDANT-FRONT_TALK.png | Approved_Sprites | 1023 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 24 | SPR-TARRAGON-FRONT_IDLE.png | Approved_Sprites | 1527 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 25 | SPR-TARRAGON-SIDE_IDLE.png | Approved_Sprites | 1283 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 26 | SPR-TARRAGON-BACK_IDLE.png | Approved_Sprites | 1414 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 27 | SPR-TARRAGON-FRONT_TALK.png | Approved_Sprites | 1706 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 28 | NPC-TARRAGON.png | Approved_Characters | 2849 | 1024x1536 | cut-out | OK |
| 29 | SPR-MUCKFOOT-FRONT_IDLE.png | Approved_Sprites | 1481 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 30 | SPR-MUCKFOOT-SIDE_IDLE.png | Approved_Sprites | 1135 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 31 | SPR-MUCKFOOT-BACK_IDLE.png | Approved_Sprites | 1423 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 32 | SPR-MUCKFOOT-FRONT_TALK.png | Approved_Sprites | 1550 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 33 | NPC-MUCKFOOT.png | Approved_Characters | 2790 | 1024x1536 | cut-out | OK |
| 34 | SPR-SORREL-FRONT_IDLE.png | Approved_Sprites | 1665 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 35 | SPR-SORREL-SIDE_IDLE.png | Approved_Sprites | 1406 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 36 | SPR-SORREL-BACK_IDLE.png | Approved_Sprites | 1667 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 37 | SPR-SORREL-FRONT_TALK.png | Approved_Sprites | 1675 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 38 | NPC-SORREL.png | Approved_Characters | 3403 | 1024x1536 | cut-out | OK |
| 39 | SPR-BRISKET-FRONT_IDLE.png | Approved_Sprites | 2879 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 40 | SPR-BRISKET-SIDE_IDLE.png | Approved_Sprites | 2211 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 41 | SPR-BRISKET-BACK_IDLE.png | Approved_Sprites | 2600 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 42 | SPR-BRISKET-FRONT_TALK.png | Approved_Sprites | 2730 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 43 | SPR-SIR-LOIN-FRONT_IDLE.png | Approved_Sprites | 2197 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 44 | SPR-SIR-LOIN-SIDE_IDLE.png | Approved_Sprites | 1558 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 45 | SPR-SIR-LOIN-BACK_IDLE.png | Approved_Sprites | 2174 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 46 | SPR-SIR-LOIN-FRONT_TALK.png | Approved_Sprites | 2253 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 47 | SPR-DEALER-FRONT_IDLE.png | Approved_Sprites | 1952 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 48 | SPR-DEALER-SIDE_IDLE.png | Approved_Sprites | 1505 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 49 | SPR-DEALER-BACK_IDLE.png | Approved_Sprites | 1927 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 50 | SPR-DEALER-FRONT_TALK.png | Approved_Sprites | 2398 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 51 | NPC-DEALER.png | Approved_Characters | 3092 | 1024x1536 |  | OK |
| 52 | SPR-CAPITAL-GUARD-FRONT_IDLE.png | Approved_Sprites | 1609 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 53 | SPR-CAPITAL-GUARD-SIDE_IDLE.png | Approved_Sprites | 1249 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 54 | SPR-CAPITAL-GUARD-BACK_IDLE.png | Approved_Sprites | 1364 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 55 | SPR-CAPITAL-GUARD-FRONT_TALK.png | Approved_Sprites | 1640 | 1024x1536 | drawn 76-1472 (h 1396, ground 1472) | OK |
| 56 | STORY-PRIMM-P1.png | Approved_KeyArt | 4855 | 1792x1024 |  | OK - 1-px border at alpha 221 (frame edge only) |
| 57 | STORY-PRIMM-P2.png | Approved_KeyArt | 5250 | 1792x1024 |  | OK - 1-px border at alpha 221 (frame edge only) |
| 58 | STORY-PRIMM-FALL.png | Approved_KeyArt | 5117 | 1792x1024 |  | OK - 1-px border at alpha 221 (frame edge only) |
| 59 | STORY-RESCUE.png | Approved_KeyArt | 3962 | 1792x1024 |  | OK - 1-px border at alpha 221 (frame edge only) |
| 60 | STORY-REVEAL-KITCHEN.png | Approved_KeyArt | 4340 | 1792x1024 |  | OK - 1-px border at alpha 221 (frame edge only) |
| 61 | STORY-EPI-MODEL-FALLS.png | Approved_KeyArt | 4767 | 1792x1024 |  | OK - 1-px border at alpha 221 (frame edge only) |
| 62 | STORY-EPI-RIFTS-CLOSE.png | Approved_KeyArt | 5257 | 1792x1024 |  | OK - 1-px border at alpha 221 (frame edge only) |
| 63 | STORY-EPI-PRIMM-SEES.png | Approved_KeyArt | 5156 | 1792x1024 |  | OK - 1-px border at alpha 221 (frame edge only) |
| 64 | STORY-EPI-WRINKLES.png | Approved_KeyArt | 5435 | 1792x1024 |  | OK - 1-px border at alpha 221 (frame edge only) |
| 65 | STORY-EPI-FILE-COMPLETE.png | Approved_KeyArt | 5053 | 1792x1024 |  | OK - 1-px border at alpha 221 (frame edge only) |
| 66 | STORY-EPI-TOGETHER.png | Approved_KeyArt | 4315 | 1792x1024 |  | OK - 1-px border at alpha 221 (frame edge only) |
| 67 | STORY-EPI-DECREE.png | Approved_KeyArt | 5094 | 1792x1024 |  | OK - 1-px border at alpha 221 (frame edge only) |
| 68 | CAP-SHEET-CREASE.png | Approved_ZoneKits/Capital | 2728 | 2048x1365 | 3 cols x 2 rows, clear gutters | OK |
| 69 | TEX-CREASE-BRICK.png | Approved_Textures | 2349 | 1024x1024 | opaque | OK |
| 70 | TEX-DNA-CARPET.png | Approved_Textures | 1395 | 1024x1024 | opaque | OK |
| 71 | TEX-DNA-LOBBY-FLOOR.png | Approved_Textures | 1693 | 1024x1024 | opaque | OK |
| 72 | DNA-SHEET-LOBBY.png | Approved_ZoneKits/DNA | 2412 | 2048x1365 | 3 cols x 2 rows, clear gutters | OK |
| 73 | CAP-BD-PALACE.png | Approved_ZoneKits/Capital | 3276 | 2048x1024 | sky clear above y 112 | OK |
| 74 | BUF-PROP-SALT-SHAKER.png | Approved_ZoneKits/Buffet | 2485 | 1024x1536 | cut-out | OK |
| 75 | BB-LIEUTENANT-QUOTA.png | Approved_Battleboards | 4259 | 1792x1024 | opaque | OK |
| 76 | CAP-PROP-PRIMM-STATUE-SIDE.png | Approved_ZoneKits/Capital | 2399 | 1024x1536 | cut-out | OK |
| 77 | TEX-CAP-ROOF-SLATE.png | Approved_Textures | 2176 | 1024x1024 | opaque | OK |
| 78 | CAP-PROP-GOLD-URN.png | Approved_ZoneKits/Capital | 2076 | 1024x1536 | cut-out | OK |
| 79 | CAP-PATH-WHITE.png | Approved_ZoneKits/Capital | 1461 | 1024x1024 | opaque | OK |
| 80 | N-10.png | Approved | 3189 | 1024x1536 | opaque | OK - size 1024x1536, asked 768x1152 |

Contact sheets of the delivery: docs/art/batch11/contact_sets_0.jpg, contact_sets_1.jpg (four poses + portrait per row).

## Part 2 - Characters

**Sprite sets** (`world_test_import.gd --npcs --npc_inbox=res://_art_inbox/npc_sprites_b11/` - the trailing slash matters; the importer
rewrote the whole manifest again, so only the 11 new keys were spliced into HEAD's text). Rows NP-HESPER .. NP-CAPITAL-GUARD added to
`data/source/npc_sprite_batch.csv` with each row note's height:

| Set (manifest key) | Height | Wired to | Was |
|---|---|---|---|
| HESPER | 1.0 | capital_zone.gd `hesper` (the Crease heal spot) | tinted Mage |
| EXIT_CLERK | 1.0 | capital_zone.gd `exit_clerk` (beside the booth) | tinted Rogue_Hooded |
| CAPITAL_GUARD | 1.2 | capital_zone.gd `guard_height`, `guard_queue`, `guard_in_1`, `guard_in_2`, freed `primm_guard` | the Correction Officer set (Nov 2 stand-in) |
| GARY | 0.55 (lying) | gainlands_zone.gd `gary` | Barbarian, Lie_Idle |
| GYM_ATTENDANT | 1.0 | gainlands_zone.gd `gym_attendant` (barks only) | Barbarian, Cheer |
| TARRAGON | 1.0 | buffet_zone.gd `tarragon` | Rogue_Hooded |
| BRISKET / SIR_LOIN | 1.35 | buffet_builder.gd `GATE_SETS` (ingredient / quest gates; Casserole already painted) | code-built 3D golems (kept as the fallback when a set is missing) |
| MUCKFOOT | 1.0 | heap_zone.gd `wren` (Billie Muckfoot) | tinted Rogue |
| SORREL | 1.1 | heap_zone.gd `sorrel` | tinted Mage |
| DEALER | 1.0 | town_scene.gd `NPC_SPRITES["hidden_vendor"]` | Rogue_Hooded |

Talk spots, yaws and anchors are unchanged (a sprite takes its size from the art's relative height; the entry's model `scale` does not
apply). Shots of the hero beside each: `docs/art/batch11/p2_npcs_beside_hero.jpg` (Hesper, Exit Clerk, outer guards / Gary, gym
attendant, Tarragon / Muckfoot, Sorrel, the Dealer) and `p2_exit_clerk_muckfoot.jpg` (the two the first camera hid behind the booth pillar / a
tree). All SIDE poses look left, so turning to the hero mirrors correctly.

**Portraits**: NPC-HESPER, -EXIT-CLERK, -GARY, -TARRAGON, -MUCKFOOT, -SORREL, -DEALER imported (`import_portraits.sh`, source = the staged
byte-for-byte copies of the Approved_Characters files because the disk could not stream the whole folder; the importer rewrote
`portrait_import_manifest.csv` with only these rows, so HEAD's rows were merged back). The seven speakers are `extra_npcs` in
`data/npcs/npc_game_map.json`, named exactly as the code's speaker labels ("Nurse Hesper Dray", "Exit Clerk", "Gary", "Sous-Chef Tarragon",
"Billie Muckfoot", "Secret Dealer" + the alias "A Secret Dealer"), so no line or label changed. Sorrel's portrait is imported but the
growth-spot lines speak as "Moss Mulligan" since the Oct 31 critic pass (inbox). The gym attendant, Brisket and Sir Loin have no portrait (as listed).

**NPC-RESCUER**: the redone portrait (both arms) replaced `assets/art/portraits/NPC-RESCUER.webp` (manifest MD5 updated). It is used only by
the dialogue box (`RescuerDisguise.portrait_id`); no cut-out or cache derives from it (the Godot import cache was refreshed). Shot:
`p2_rescuer_portrait.jpg`. The prologue's own `call:_start_rescuer_scene` shot stops on the forest-wake still first, so the town shot shows
the same portrait in the dialogue box.

**3D-figure audit (re-run)** as a test: `tests/world/test_painted_npcs_batch11.gd` - every NPC entry of every zone (57, freed leaders
included) resolves to an imported painted set; the three Buffet gates are painted; Crosspath's NPCs are painted; heights match the row
notes; the six speakers resolve to their portraits. 6/6 pass. 3D characters left: Threadwell's window mannequin (by design) and the
Verdant Dump's ambient animals (critters, the stable animal - kept by choice).

## Part 3 - Story stills

Imported with `import_key_art.sh` (12 new rows in `data/source/logo_title_art.csv`; source = the staged copies of the Approved_KeyArt files;
`node tools/merge_import_manifest.js data/source/key_art_import_manifest.csv` put HEAD's rows back after the importer's rewrite).
Wired in `StoryStills` - the cutscene screen now picks the still **per beat** (`cutscene_backdrop(scene, beat)`, new
`CUTSCENE_BEAT_BACKDROPS`; `CutsceneScreen._set_backdrop` swaps the picture between beats like the ending screen does):

| Moment | Beats | Still |
|---|---|---|
| primm_p1 | 1-4 | STORY-PRIMM-P1 |
| primm_p2 | 1-5 | STORY-PRIMM-P2 |
| primm_end | 1-8 | STORY-PRIMM-FALL |
| rescue | 1-3 | STORY-RESCUE |
| reveal | 1-4 / 5 | STORY-REVEAL-KITCHEN / STORY-DOPPEL (beat 5 comes right after the full-screen DOPPEL still) |
| flex | 3-5 | STORY-FLEX (beat 3 is its full-screen still; behind beats 3-5 afterwards) |
| epilogue (EndingDefs n) | 1 crumble, 3 rifts, 4 wrinkles, 6 unite, 7 dove, 9 primm_sees, 10 stamp | STORY-EPI-MODEL-FALLS, -RIFTS-CLOSE, -WRINKLES, -TOGETHER, -DECREE, -PRIMM-SEES, -FILE-COMPLETE |
| epilogue 5 reunion | 5 | STORY-REUNION stays behind its words after the full-screen view (it fell back to the icon stage before) |

**Beats still on the icon stage: flex 1 and flex 2 only** (STORY-FLEX is the reveal itself; behind "Hold my coat" it would give the reveal
away - inbox 5). Every other cutscene beat and all ten epilogue beats have a still (`tests/test_story_backdrops_batch11.gd`, 5/5;
`test_story_backdrops_oct29.gd` updated for 27 backdrops, where a caption still may also sit behind beats).

Contact sheets through the real CutsceneScreen / EndingScreen (`Godot --path . --resolution 1600x900 res://tools/beat_shots.tscn`, out
`_screenshots/beats/`): every wired beat (66) `docs/art/batch11/p3_every_wired_beat.jpg` (order in `p3_every_wired_beat.txt`), and one cell
per Batch 11 still `p3_batch11_beats.jpg`. (The TOGETHER cell is caught mid gold flash of the `unite` effect, which fades.)

## Part 4 - World pieces

| Piece | Imported with | Wired | Shot |
|---|---|---|---|
| N-10 Push Broom of Undeath | `import_art.sh` (+ `card_thumbs.js`; it also made 28 thumbnails earlier imports skipped) | the card's art | - |
| BB-LIEUTENANT-QUOTA | `import_battleboards.sh` (row in battleboard_list) | context `lieutenant:quota` (data/battleboards.json) for `Session.make_quota_yards_battle`; her music stays the facade battle song (`MusicDirector._capital_battle`) | - |
| COS-HAT-LEAFCROWN-SHEET | `world_test_import.gd --cosmetics --cos_inbox=` with only this sheet (Bowler / Tricorn / Wide-Brim not re-imported) | refit in `hats/fit.json`: a whole ring now, no `behind_*` keys, sinks FRONT .65 / FRONTSIDE .45 / SIDE .40 / BACKSIDE .80 / BACK .89 (eyes clear in profile, hair clear from behind, no horns); `SpriteCosmetics.HELD_HATS` empty - **back in Threadwell's shop** | p4_leafcrown_after.jpg (contact sheet, world + preview, idle + walk), p4_leafcrown_tryon.jpg, p4_leafcrown_first_fit.jpg (the halo before the refit), fit table |
| TEX-CREASE-BRICK | `import_textures.sh --only=` (rows in textures.csv) | the Crease's four walls (`CapitalBuilder`, PaintedTriplanar, world-space 2.6 m tile; flat colour fallback) | p4_crease_before_after.jpg, p4_crease_wide.jpg |
| CAP-SHEET-CREASE (six props) | `import_zone_kit.sh final --only=` | `CapitalProps._crease_painted`: tea urn (Hesper's heal spot) 1.7 m, records / map tables 1.6, Fig Sly's stall 2.6, bedrolls 0.75 (both cots), lantern columns 3.4 (keep their light), ladder up to the manhole 4.0; spots, anchors and blockers unchanged; the code boxes stay the fallback | same |
| TEX-DNA-CARPET | textures (replaces the old dna_carpet; backup in superseded_batch11/textures) | the offices' carpet variant (already wired) | - |
| TEX-DNA-LOBBY-FLOOR | textures | new `lobby` mask (PaintedContexts.dna) + a terrazzo layer under the checker inlay in the `tile` variant: the lobby only; the mail room / elevator bank keep the marble | p4_lobby_terrazzo_vs_mail_marble.jpg |
| DNA-SHEET-LOBBY (six props) | `import_zone_kit.sh dna --only=` | `DnaDressing._lobby_props` after the ghost queue: chairs + ashtray + plant on the west / south-west wall, notice board by the south wall, vending machine on the east wall, TAKE A NUMBER by the counter; each on a `_free` spot (the middle 5.5 m stays open, talk spots clear, the queue keeps its place) | p4_lobby_before_after.jpg |
| CAP-PROP-PRIMM-STATUE-SIDE | zone kit final | `CapitalGrand.statue_cards`: every standing gilded statue (plinths, both fountains) is the front card + the side card crossed, so from the side plazas / cross streets it reads as a statue | p4_statue_side_view.jpg, p4_statue_front_urns.jpg |
| CAP-PROP-GOLD-URN | zone kit final | `CapitalGrand.gold_urn`: two crossed painted cards (2.0 x the bowl radius, rim at the cone's foot) under every planter cone / rose; the turned lathe is the fallback | p4_statue_front_urns.jpg |
| TEX-CAP-ROOF-SLATE | textures | new `roof_sage` slot (`CapitalKit.roof_slate`): every sage-accent townhouse roof (the Reek's district houses, the skyline's sage houses); townhouse geometry cache key v2 | not seen from the shot cameras (see inbox) |
| CAP-PATH-WHITE (re-upload) | zone kit final (backup of the old albedo / normal / roughness) | already the `road_white` surface | - |
| CAP-BD-PALACE | zone kit final | the outskirts look's north kit card (`zone_looks.json` capital_outskirts, was CAP-BD-WASTELAND @0) | p4_gate_road.jpg - **not visible at play cameras** (inbox) |
| BUF-PROP-SALT-SHAKER | zone kit buffet | `BuffetLandmarks.entrance_bridge`: the side posts (1.7 m), the gate pair (3.8 m, keep lanterns / sign / bunting) and the far landing's pair (2.9 m) are crossed salt-shaker cards; the white meringue lathes are the fallback (the river landing stages keep theirs) | p4_buffet_salt_shakers.jpg |

Manifests: the importers rewrite their manifests from the narrowed source; `node tools/merge_import_manifest.js <manifest>` now keeps HEAD's
order and HEAD's row wherever the run wrote MISSING. The zone kit registries (final / dna / buffet .json) lost nothing (18 new entries; the
rest of their diff is Godot's number formatting).
