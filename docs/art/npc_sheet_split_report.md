# NPC sprite sheet split report

Sheets `SPR-<KEY>.png` (four frames left to right: FRONT_IDLE, FRONT_TALK, SIDE_IDLE, BACK_IDLE) in `_art_inbox/npc_sprites/`, split by `tools/split_sprite_sheets.gd`.
SIDE_IDLE is mirrored to face left (the game's convention) unless the key is in `SIDE_ALREADY_LEFT`.

- Split (10): CLIPWELL, CRUMB, ELOWEN, ISLA, KING, PLUME, QUEEN, QUOTA, SIPHON, VAULTWARDEN
- Not split (0): none

## Per sheet

- CLIPWELL: 1774x887 sheet, 4 figures; 0 extra piece(s) joined to a figure, 0 speck(s) dropped; SIDE mirrored to face left; widths FRONT_IDLE 496 px, FRONT_TALK 508 px, SIDE_IDLE 416 px, BACK_IDLE 398 px
- CRUMB: 2126x740 sheet, 4 figures; 0 extra piece(s) joined to a figure, 0 speck(s) dropped; SIDE mirrored to face left; widths FRONT_IDLE 528 px, FRONT_TALK 616 px, SIDE_IDLE 392 px, BACK_IDLE 512 px
- ELOWEN: 1774x887 sheet, 4 figures; 0 extra piece(s) joined to a figure, 0 speck(s) dropped; SIDE mirrored to face left; widths FRONT_IDLE 448 px, FRONT_TALK 512 px, SIDE_IDLE 392 px, BACK_IDLE 400 px
- ISLA: 1774x887 sheet; only 3 separate shape(s) on the sheet (frames touch), so cut along winding seams (each crosses at most 0 px of figure - check the frame edges); widths FRONT_IDLE 458 px, FRONT_TALK 630 px, SIDE_IDLE 471 px, BACK_IDLE 587 px
- KING: 1774x887 sheet, 4 figures; 0 extra piece(s) joined to a figure, 0 speck(s) dropped; SIDE mirrored to face left; widths FRONT_IDLE 472 px, FRONT_TALK 484 px, SIDE_IDLE 384 px, BACK_IDLE 452 px
- PLUME: 2048x768 sheet, 4 figures; 0 extra piece(s) joined to a figure, 0 speck(s) dropped; SIDE mirrored to face left; widths FRONT_IDLE 512 px, FRONT_TALK 536 px, SIDE_IDLE 436 px, BACK_IDLE 472 px
- QUEEN: 1774x887 sheet, 4 figures; 0 extra piece(s) joined to a figure, 0 speck(s) dropped; SIDE mirrored to face left; widths FRONT_IDLE 468 px, FRONT_TALK 472 px, SIDE_IDLE 436 px, BACK_IDLE 466 px
- QUOTA: 1774x887 sheet, 4 figures; 0 extra piece(s) joined to a figure, 0 speck(s) dropped; SIDE mirrored to face left; widths FRONT_IDLE 456 px, FRONT_TALK 512 px, SIDE_IDLE 440 px, BACK_IDLE 380 px
- SIPHON: 1536x1024 sheet, 4 figures; 0 extra piece(s) joined to a figure, 0 speck(s) dropped; SIDE mirrored to face left; widths FRONT_IDLE 428 px, FRONT_TALK 448 px, SIDE_IDLE 368 px, BACK_IDLE 376 px
- VAULTWARDEN: 2172x724 sheet, 4 figures; 0 extra piece(s) joined to a figure, 0 speck(s) dropped; SIDE mirrored to face left; widths FRONT_IDLE 476 px, FRONT_TALK 544 px, SIDE_IDLE 460 px, BACK_IDLE 476 px
