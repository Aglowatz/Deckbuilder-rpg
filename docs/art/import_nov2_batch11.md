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

Contact sheets of the delivery: docs/art/batch11/contact_sets_0.png, contact_sets_1.png (four poses + portrait per row).
