# Art import Oct 28 (rows #1-74 of art_batch_oct28.csv)

## Part 0 - inventory (Oct 28 20:40 MDT)

Checked by a full PNG decode (every chunk CRC, IEND, inflate, every row of pixels) of the Drive files, copy-only (local copies in `_art_inbox/oct28_check/`),
plus contact sheets `_screenshots/oct28/review_{walks,idle,cut,bst}.png` looked at by eye.

- **239 files present, 0 missing, 0 structural problems** (no truncation, no bad CRC). assets/art before import: **365 MB**.
- Portraits / cut-outs / sprites: all RGBA with transparent backgrounds, no grey box, no ground shadow, no text. Sizes as asked (2:3 1024x1536, walk strips 3:2 1536x1024).
- Bestiary squares: 1:1 1024x1024, opaque painted backgrounds as the BESTIARY lock asks (11 are saved without an alpha channel at all; fine for squares).
- Portraits and cut-outs touch the bottom edge (waist / hips-up framing, expected). A few cut-outs (RACCOONKING, SPOTLESS, SIPHON, PRIMM*, BELLOWS) also touch the sides (wide poses / props): fine behind the letterbox.
- Walk strips whose last figure touches the right edge (a hand or tail may be clipped by a few px): SPR-FOE-PANTRY-HOUND-FRONT_WALK, SPR-FOE-PANTRY-HOUND-SIDE_WALK, SPR-FOE-BIN-RACCOON-FRONT_WALK, SPR-FOE-SHAMBLING-MIDDLE-MANAGER-FRONT_WALK, SPR-FOE-GELATIN-SENTINEL-FRONT_WALK, SPR-FOE-MOSSY-TRASH-GOLEM-FRONT_WALK, SPR-FOE-CORRECTION-OFFICER-FRONT_WALK, SPR-FOE-PERFECTION-INSPECTOR-FRONT_WALK. Not visible at game scale; noted only.
- Idles touching the side: SPR-FOE-PROTEIN-SHAKE-GOLEM-FRONT_IDLE (fists at both edges), -FRONT_TALK. Wide figure; check in game.
- Every walk strip splits into four separate figures (contact sheet).

| File | Size | Px | Notes |
|---|---:|---|---|
| NPC-ELDER.png | 3.01 MB | 1024x1536 | touches bottom |
| NPC-ELDER_HAPPY.png | 3.09 MB | 1024x1536 | touches bottom/right |
| NPC-ELDER_WORRIED.png | 2.90 MB | 1024x1536 | touches bottom |
| SPR-ELDER-FRONT_IDLE.png | 2.63 MB | 1024x1536 |  |
| SPR-ELDER-SIDE_IDLE.png | 2.67 MB | 1024x1536 |  |
| SPR-ELDER-BACK_IDLE.png | 2.71 MB | 1024x1536 |  |
| SPR-ELDER-FRONT_TALK.png | 2.61 MB | 1024x1536 |  |
| SPR-FOE-PANTRY-HOUND-FRONT_IDLE.png | 2.36 MB | 1024x1536 |  |
| SPR-FOE-PANTRY-HOUND-FRONTSIDE_IDLE.png | 2.36 MB | 1024x1536 |  |
| SPR-FOE-PANTRY-HOUND-SIDE_IDLE.png | 2.20 MB | 1024x1536 |  |
| SPR-FOE-PANTRY-HOUND-BACKSIDE_IDLE.png | 2.19 MB | 1024x1536 |  |
| SPR-FOE-PANTRY-HOUND-BACK_IDLE.png | 2.24 MB | 1024x1536 |  |
| SPR-FOE-PANTRY-HOUND-FRONT_WALK.png | 2.34 MB | 1536x1024 | touches right |
| SPR-FOE-PANTRY-HOUND-FRONTSIDE_WALK.png | 2.16 MB | 1536x1024 |  |
| SPR-FOE-PANTRY-HOUND-SIDE_WALK.png | 2.06 MB | 1536x1024 | touches right |
| SPR-FOE-PANTRY-HOUND-BACKSIDE_WALK.png | 1.90 MB | 1536x1024 |  |
| SPR-FOE-PANTRY-HOUND-BACK_WALK.png | 2.02 MB | 1536x1024 |  |
| SPR-FOE-PANTRY-HOUND-FRONT_TALK.png | 2.45 MB | 1024x1536 |  |
| SPR-FOE-LOST-JUNIOR-CLERK-FRONT_IDLE.png | 2.04 MB | 1024x1536 |  |
| SPR-FOE-LOST-JUNIOR-CLERK-FRONTSIDE_IDLE.png | 1.97 MB | 1024x1536 |  |
| SPR-FOE-LOST-JUNIOR-CLERK-SIDE_IDLE.png | 2.00 MB | 1024x1536 |  |
| SPR-FOE-LOST-JUNIOR-CLERK-BACKSIDE_IDLE.png | 1.88 MB | 1024x1536 |  |
| SPR-FOE-LOST-JUNIOR-CLERK-BACK_IDLE.png | 1.91 MB | 1024x1536 |  |
| SPR-FOE-LOST-JUNIOR-CLERK-FRONT_WALK.png | 1.92 MB | 1536x1024 |  |
| SPR-FOE-LOST-JUNIOR-CLERK-FRONTSIDE_WALK.png | 2.00 MB | 1536x1024 |  |
| SPR-FOE-LOST-JUNIOR-CLERK-SIDE_WALK.png | 1.91 MB | 1536x1024 |  |
| SPR-FOE-LOST-JUNIOR-CLERK-BACKSIDE_WALK.png | 1.87 MB | 1536x1024 |  |
| SPR-FOE-LOST-JUNIOR-CLERK-BACK_WALK.png | 1.92 MB | 1536x1024 |  |
| SPR-FOE-LOST-JUNIOR-CLERK-FRONT_TALK.png | 2.04 MB | 1024x1536 |  |
| SPR-FOE-BIN-RACCOON-FRONT_IDLE.png | 2.44 MB | 1024x1536 |  |
| SPR-FOE-BIN-RACCOON-FRONTSIDE_IDLE.png | 2.46 MB | 1024x1536 |  |
| SPR-FOE-BIN-RACCOON-SIDE_IDLE.png | 2.43 MB | 1024x1536 |  |
| SPR-FOE-BIN-RACCOON-BACKSIDE_IDLE.png | 2.31 MB | 1024x1536 |  |
| SPR-FOE-BIN-RACCOON-BACK_IDLE.png | 2.43 MB | 1024x1536 |  |
| SPR-FOE-BIN-RACCOON-FRONT_WALK.png | 1.96 MB | 1536x1024 | touches right |
| SPR-FOE-BIN-RACCOON-FRONTSIDE_WALK.png | 1.94 MB | 1536x1024 |  |
| SPR-FOE-BIN-RACCOON-SIDE_WALK.png | 1.95 MB | 1536x1024 |  |
| SPR-FOE-BIN-RACCOON-BACKSIDE_WALK.png | 1.83 MB | 1536x1024 |  |
| SPR-FOE-BIN-RACCOON-BACK_WALK.png | 1.92 MB | 1536x1024 |  |
| SPR-FOE-BIN-RACCOON-FRONT_TALK.png | 2.54 MB | 1024x1536 | touches right |
| SPR-FOE-QUOTA-SPOTTER-FRONT_IDLE.png | 2.17 MB | 1024x1536 |  |
| SPR-FOE-QUOTA-SPOTTER-FRONTSIDE_IDLE.png | 2.27 MB | 1024x1536 |  |
| SPR-FOE-QUOTA-SPOTTER-SIDE_IDLE.png | 2.11 MB | 1024x1536 |  |
| SPR-FOE-QUOTA-SPOTTER-BACKSIDE_IDLE.png | 2.17 MB | 1024x1536 |  |
| SPR-FOE-QUOTA-SPOTTER-BACK_IDLE.png | 2.18 MB | 1024x1536 |  |
| SPR-FOE-QUOTA-SPOTTER-FRONT_WALK.png | 2.17 MB | 1536x1024 |  |
| SPR-FOE-QUOTA-SPOTTER-FRONTSIDE_WALK.png | 2.10 MB | 1536x1024 |  |
| SPR-FOE-QUOTA-SPOTTER-SIDE_WALK.png | 2.06 MB | 1536x1024 |  |
| SPR-FOE-QUOTA-SPOTTER-BACKSIDE_WALK.png | 1.98 MB | 1536x1024 |  |
| SPR-FOE-QUOTA-SPOTTER-BACK_WALK.png | 2.10 MB | 1536x1024 |  |
| SPR-FOE-QUOTA-SPOTTER-FRONT_TALK.png | 2.29 MB | 1024x1536 |  |
| SPR-FOE-PROTEIN-SHAKE-GOLEM-FRONT_IDLE.png | 2.08 MB | 1024x1536 | touches left/right |
| SPR-FOE-PROTEIN-SHAKE-GOLEM-FRONTSIDE_IDLE.png | 2.15 MB | 1024x1536 |  |
| SPR-FOE-PROTEIN-SHAKE-GOLEM-SIDE_IDLE.png | 1.80 MB | 1024x1536 |  |
| SPR-FOE-PROTEIN-SHAKE-GOLEM-BACKSIDE_IDLE.png | 2.14 MB | 1024x1536 |  |
| SPR-FOE-PROTEIN-SHAKE-GOLEM-BACK_IDLE.png | 2.01 MB | 1024x1536 |  |
| SPR-FOE-PROTEIN-SHAKE-GOLEM-FRONT_WALK.png | 1.91 MB | 1536x1024 |  |
| SPR-FOE-PROTEIN-SHAKE-GOLEM-FRONTSIDE_WALK.png | 1.94 MB | 1536x1024 |  |
| SPR-FOE-PROTEIN-SHAKE-GOLEM-SIDE_WALK.png | 1.89 MB | 1536x1024 |  |
| SPR-FOE-PROTEIN-SHAKE-GOLEM-BACKSIDE_WALK.png | 1.82 MB | 1536x1024 |  |
| SPR-FOE-PROTEIN-SHAKE-GOLEM-BACK_WALK.png | 1.91 MB | 1536x1024 |  |
| SPR-FOE-PROTEIN-SHAKE-GOLEM-FRONT_TALK.png | 2.16 MB | 1024x1536 | touches right |
| SPR-FOE-SPRINTING-ENERGY-SPRITE-FRONT_IDLE.png | 2.10 MB | 1024x1536 |  |
| SPR-FOE-SPRINTING-ENERGY-SPRITE-SIDE_IDLE.png | 2.05 MB | 1024x1536 |  |
| SPR-FOE-SPRINTING-ENERGY-SPRITE-BACK_IDLE.png | 2.16 MB | 1024x1536 |  |
| SPR-FOE-SPRINTING-ENERGY-SPRITE-FRONT_TALK.png | 2.26 MB | 1024x1536 |  |
| SPR-FOE-SHAMBLING-MIDDLE-MANAGER-FRONT_IDLE.png | 2.07 MB | 1024x1536 |  |
| SPR-FOE-SHAMBLING-MIDDLE-MANAGER-FRONTSIDE_IDLE.png | 2.17 MB | 1024x1536 |  |
| SPR-FOE-SHAMBLING-MIDDLE-MANAGER-SIDE_IDLE.png | 1.95 MB | 1024x1536 |  |
| SPR-FOE-SHAMBLING-MIDDLE-MANAGER-BACKSIDE_IDLE.png | 2.13 MB | 1024x1536 |  |
| SPR-FOE-SHAMBLING-MIDDLE-MANAGER-BACK_IDLE.png | 2.06 MB | 1024x1536 |  |
| SPR-FOE-SHAMBLING-MIDDLE-MANAGER-FRONT_WALK.png | 2.19 MB | 1536x1024 | touches right |
| SPR-FOE-SHAMBLING-MIDDLE-MANAGER-FRONTSIDE_WALK.png | 2.11 MB | 1536x1024 |  |
| SPR-FOE-SHAMBLING-MIDDLE-MANAGER-SIDE_WALK.png | 2.08 MB | 1536x1024 |  |
| SPR-FOE-SHAMBLING-MIDDLE-MANAGER-BACKSIDE_WALK.png | 2.02 MB | 1536x1024 |  |
| SPR-FOE-SHAMBLING-MIDDLE-MANAGER-BACK_WALK.png | 1.90 MB | 1536x1024 |  |
| SPR-FOE-SHAMBLING-MIDDLE-MANAGER-FRONT_TALK.png | 2.16 MB | 1024x1536 |  |
| SPR-FOE-UNPAID-INTERN-FRONT_IDLE.png | 1.62 MB | 1024x1536 |  |
| SPR-FOE-UNPAID-INTERN-FRONTSIDE_IDLE.png | 1.92 MB | 1024x1536 |  |
| SPR-FOE-UNPAID-INTERN-SIDE_IDLE.png | 1.82 MB | 1024x1536 |  |
| SPR-FOE-UNPAID-INTERN-BACKSIDE_IDLE.png | 1.80 MB | 1024x1536 |  |
| SPR-FOE-UNPAID-INTERN-BACK_IDLE.png | 1.65 MB | 1024x1536 |  |
| SPR-FOE-UNPAID-INTERN-FRONT_WALK.png | 2.30 MB | 1536x1024 |  |
| SPR-FOE-UNPAID-INTERN-FRONTSIDE_WALK.png | 2.25 MB | 1536x1024 |  |
| SPR-FOE-UNPAID-INTERN-SIDE_WALK.png | 2.14 MB | 1536x1024 |  |
| SPR-FOE-UNPAID-INTERN-BACKSIDE_WALK.png | 2.05 MB | 1536x1024 |  |
| SPR-FOE-UNPAID-INTERN-BACK_WALK.png | 2.01 MB | 1536x1024 |  |
| SPR-FOE-UNPAID-INTERN-FRONT_TALK.png | 2.06 MB | 1024x1536 |  |
| SPR-FOE-SPEEDY-GHOST-COURIER-FRONT_IDLE.png | 1.89 MB | 1024x1536 |  |
| SPR-FOE-SPEEDY-GHOST-COURIER-SIDE_IDLE.png | 1.93 MB | 1024x1536 |  |
| SPR-FOE-SPEEDY-GHOST-COURIER-BACK_IDLE.png | 1.88 MB | 1024x1536 |  |
| SPR-FOE-SPEEDY-GHOST-COURIER-FRONT_TALK.png | 2.03 MB | 1024x1536 |  |
| SPR-FOE-MEATLOAF-GOLEM-FRONT_IDLE.png | 2.50 MB | 1024x1536 |  |
| SPR-FOE-MEATLOAF-GOLEM-FRONTSIDE_IDLE.png | 2.47 MB | 1024x1536 |  |
| SPR-FOE-MEATLOAF-GOLEM-SIDE_IDLE.png | 2.37 MB | 1024x1536 |  |
| SPR-FOE-MEATLOAF-GOLEM-BACKSIDE_IDLE.png | 2.38 MB | 1024x1536 |  |
| SPR-FOE-MEATLOAF-GOLEM-BACK_IDLE.png | 2.49 MB | 1024x1536 |  |
| SPR-FOE-MEATLOAF-GOLEM-FRONT_WALK.png | 2.18 MB | 1536x1024 |  |
| SPR-FOE-MEATLOAF-GOLEM-FRONTSIDE_WALK.png | 2.20 MB | 1536x1024 |  |
| SPR-FOE-MEATLOAF-GOLEM-SIDE_WALK.png | 2.07 MB | 1536x1024 |  |
| SPR-FOE-MEATLOAF-GOLEM-BACKSIDE_WALK.png | 2.08 MB | 1536x1024 |  |
| SPR-FOE-MEATLOAF-GOLEM-BACK_WALK.png | 2.08 MB | 1536x1024 |  |
| SPR-FOE-MEATLOAF-GOLEM-FRONT_TALK.png | 2.43 MB | 1024x1536 |  |
| SPR-FOE-GELATIN-SENTINEL-FRONT_IDLE.png | 2.28 MB | 1024x1536 |  |
| SPR-FOE-GELATIN-SENTINEL-FRONTSIDE_IDLE.png | 2.24 MB | 1024x1536 |  |
| SPR-FOE-GELATIN-SENTINEL-SIDE_IDLE.png | 2.20 MB | 1024x1536 |  |
| SPR-FOE-GELATIN-SENTINEL-BACKSIDE_IDLE.png | 2.24 MB | 1024x1536 |  |
| SPR-FOE-GELATIN-SENTINEL-BACK_IDLE.png | 2.25 MB | 1024x1536 |  |
| SPR-FOE-GELATIN-SENTINEL-FRONT_WALK.png | 2.09 MB | 1536x1024 | touches right |
| SPR-FOE-GELATIN-SENTINEL-FRONTSIDE_WALK.png | 1.93 MB | 1536x1024 |  |
| SPR-FOE-GELATIN-SENTINEL-SIDE_WALK.png | 1.98 MB | 1536x1024 |  |
| SPR-FOE-GELATIN-SENTINEL-BACKSIDE_WALK.png | 2.00 MB | 1536x1024 |  |
| SPR-FOE-GELATIN-SENTINEL-BACK_WALK.png | 1.92 MB | 1536x1024 |  |
| SPR-FOE-GELATIN-SENTINEL-FRONT_TALK.png | 2.29 MB | 1024x1536 |  |
| SPR-FOE-RUNAWAY-MEATBALL-FRONT_IDLE.png | 2.21 MB | 1024x1536 |  |
| SPR-FOE-RUNAWAY-MEATBALL-SIDE_IDLE.png | 1.97 MB | 1024x1536 |  |
| SPR-FOE-RUNAWAY-MEATBALL-BACK_IDLE.png | 2.40 MB | 1024x1536 |  |
| SPR-FOE-RUNAWAY-MEATBALL-FRONT_TALK.png | 2.36 MB | 1024x1536 |  |
| SPR-FOE-COLONEL-CASSEROLE-FRONT_IDLE.png | 2.51 MB | 1024x1536 |  |
| SPR-FOE-COLONEL-CASSEROLE-SIDE_IDLE.png | 2.33 MB | 1024x1536 |  |
| SPR-FOE-COLONEL-CASSEROLE-BACK_IDLE.png | 2.55 MB | 1024x1536 |  |
| SPR-FOE-COLONEL-CASSEROLE-FRONT_TALK.png | 2.54 MB | 1024x1536 |  |
| SPR-FOE-MOSSY-TRASH-GOLEM-FRONT_IDLE.png | 2.87 MB | 1024x1536 |  |
| SPR-FOE-MOSSY-TRASH-GOLEM-FRONTSIDE_IDLE.png | 2.86 MB | 1024x1536 |  |
| SPR-FOE-MOSSY-TRASH-GOLEM-SIDE_IDLE.png | 2.07 MB | 1024x1536 |  |
| SPR-FOE-MOSSY-TRASH-GOLEM-BACKSIDE_IDLE.png | 2.90 MB | 1024x1536 |  |
| SPR-FOE-MOSSY-TRASH-GOLEM-BACK_IDLE.png | 2.89 MB | 1024x1536 |  |
| SPR-FOE-MOSSY-TRASH-GOLEM-FRONT_WALK.png | 2.90 MB | 1536x1024 | touches right |
| SPR-FOE-MOSSY-TRASH-GOLEM-FRONTSIDE_WALK.png | 2.57 MB | 1536x1024 |  |
| SPR-FOE-MOSSY-TRASH-GOLEM-SIDE_WALK.png | 2.57 MB | 1536x1024 |  |
| SPR-FOE-MOSSY-TRASH-GOLEM-BACKSIDE_WALK.png | 2.86 MB | 1536x1024 |  |
| SPR-FOE-MOSSY-TRASH-GOLEM-BACK_WALK.png | 2.59 MB | 1536x1024 |  |
| SPR-FOE-MOSSY-TRASH-GOLEM-FRONT_TALK.png | 3.12 MB | 1024x1536 |  |
| SPR-FOE-HUNGRY-SCARECROW-FRONT_IDLE.png | 2.61 MB | 1024x1536 |  |
| SPR-FOE-HUNGRY-SCARECROW-FRONTSIDE_IDLE.png | 2.60 MB | 1024x1536 |  |
| SPR-FOE-HUNGRY-SCARECROW-SIDE_IDLE.png | 2.04 MB | 1024x1536 |  |
| SPR-FOE-HUNGRY-SCARECROW-BACKSIDE_IDLE.png | 2.76 MB | 1024x1536 |  |
| SPR-FOE-HUNGRY-SCARECROW-BACK_IDLE.png | 2.73 MB | 1024x1536 |  |
| SPR-FOE-HUNGRY-SCARECROW-FRONT_WALK.png | 3.13 MB | 1536x1024 |  |
| SPR-FOE-HUNGRY-SCARECROW-FRONTSIDE_WALK.png | 2.65 MB | 1536x1024 |  |
| SPR-FOE-HUNGRY-SCARECROW-SIDE_WALK.png | 2.47 MB | 1536x1024 |  |
| SPR-FOE-HUNGRY-SCARECROW-BACKSIDE_WALK.png | 2.50 MB | 1536x1024 |  |
| SPR-FOE-HUNGRY-SCARECROW-BACK_WALK.png | 2.95 MB | 1536x1024 |  |
| SPR-FOE-HUNGRY-SCARECROW-FRONT_TALK.png | 2.92 MB | 1024x1536 |  |
| SPR-FOE-JUNK-GULL-FLOCK-FRONT_IDLE.png | 1.86 MB | 1024x1536 |  |
| SPR-FOE-JUNK-GULL-FLOCK-SIDE_IDLE.png | 1.54 MB | 1024x1536 |  |
| SPR-FOE-JUNK-GULL-FLOCK-BACK_IDLE.png | 1.94 MB | 1024x1536 |  |
| SPR-FOE-JUNK-GULL-FLOCK-FRONT_TALK.png | 2.29 MB | 1024x1536 |  |
| SPR-FOE-CORRECTION-OFFICER-FRONT_IDLE.png | 1.34 MB | 1024x1536 |  |
| SPR-FOE-CORRECTION-OFFICER-FRONTSIDE_IDLE.png | 1.25 MB | 1024x1536 |  |
| SPR-FOE-CORRECTION-OFFICER-SIDE_IDLE.png | 0.93 MB | 1024x1536 |  |
| SPR-FOE-CORRECTION-OFFICER-BACKSIDE_IDLE.png | 1.22 MB | 1024x1536 |  |
| SPR-FOE-CORRECTION-OFFICER-BACK_IDLE.png | 1.30 MB | 1024x1536 |  |
| SPR-FOE-CORRECTION-OFFICER-FRONT_WALK.png | 2.44 MB | 1536x1024 | touches right |
| SPR-FOE-CORRECTION-OFFICER-FRONTSIDE_WALK.png | 2.22 MB | 1536x1024 |  |
| SPR-FOE-CORRECTION-OFFICER-SIDE_WALK.png | 1.98 MB | 1536x1024 |  |
| SPR-FOE-CORRECTION-OFFICER-BACKSIDE_WALK.png | 2.07 MB | 1536x1024 |  |
| SPR-FOE-CORRECTION-OFFICER-BACK_WALK.png | 2.28 MB | 1536x1024 |  |
| SPR-FOE-CORRECTION-OFFICER-FRONT_TALK.png | 1.36 MB | 1024x1536 |  |
| SPR-FOE-PERFECTION-INSPECTOR-FRONT_IDLE.png | 2.24 MB | 1024x1536 |  |
| SPR-FOE-PERFECTION-INSPECTOR-FRONTSIDE_IDLE.png | 2.17 MB | 1024x1536 |  |
| SPR-FOE-PERFECTION-INSPECTOR-SIDE_IDLE.png | 1.63 MB | 1024x1536 |  |
| SPR-FOE-PERFECTION-INSPECTOR-BACKSIDE_IDLE.png | 1.91 MB | 1024x1536 |  |
| SPR-FOE-PERFECTION-INSPECTOR-BACK_IDLE.png | 1.84 MB | 1024x1536 |  |
| SPR-FOE-PERFECTION-INSPECTOR-FRONT_WALK.png | 2.61 MB | 1536x1024 | touches left/right |
| SPR-FOE-PERFECTION-INSPECTOR-FRONTSIDE_WALK.png | 2.55 MB | 1536x1024 |  |
| SPR-FOE-PERFECTION-INSPECTOR-SIDE_WALK.png | 2.09 MB | 1536x1024 |  |
| SPR-FOE-PERFECTION-INSPECTOR-BACKSIDE_WALK.png | 1.89 MB | 1536x1024 |  |
| SPR-FOE-PERFECTION-INSPECTOR-BACK_WALK.png | 1.97 MB | 1536x1024 |  |
| SPR-FOE-PERFECTION-INSPECTOR-FRONT_TALK.png | 2.32 MB | 1024x1536 |  |
| SPR-FOE-TIDY-BOT-FRONT_IDLE.png | 1.62 MB | 1024x1536 |  |
| SPR-FOE-TIDY-BOT-SIDE_IDLE.png | 1.58 MB | 1024x1536 |  |
| SPR-FOE-TIDY-BOT-BACK_IDLE.png | 1.58 MB | 1024x1536 |  |
| SPR-FOE-TIDY-BOT-FRONT_TALK.png | 1.77 MB | 1024x1536 |  |
| SPR-FOE-RIFT-WRETCH-FRONT_IDLE.png | 1.69 MB | 1024x1536 |  |
| SPR-FOE-RIFT-WRETCH-FRONTSIDE_IDLE.png | 1.83 MB | 1024x1536 |  |
| SPR-FOE-RIFT-WRETCH-SIDE_IDLE.png | 1.62 MB | 1024x1536 |  |
| SPR-FOE-RIFT-WRETCH-BACKSIDE_IDLE.png | 1.82 MB | 1024x1536 |  |
| SPR-FOE-RIFT-WRETCH-BACK_IDLE.png | 1.89 MB | 1024x1536 |  |
| SPR-FOE-RIFT-WRETCH-FRONT_WALK.png | 2.80 MB | 1536x1024 |  |
| SPR-FOE-RIFT-WRETCH-FRONTSIDE_WALK.png | 2.86 MB | 1536x1024 |  |
| SPR-FOE-RIFT-WRETCH-SIDE_WALK.png | 2.19 MB | 1536x1024 |  |
| SPR-FOE-RIFT-WRETCH-BACKSIDE_WALK.png | 2.63 MB | 1536x1024 |  |
| SPR-FOE-RIFT-WRETCH-BACK_WALK.png | 2.66 MB | 1536x1024 |  |
| SPR-FOE-RIFT-WRETCH-FRONT_TALK.png | 2.05 MB | 1024x1536 |  |
| SPR-FOE-SHARD-SWARM-FRONT_IDLE.png | 1.72 MB | 1024x1536 |  |
| SPR-FOE-SHARD-SWARM-SIDE_IDLE.png | 1.43 MB | 1024x1536 |  |
| SPR-FOE-SHARD-SWARM-BACK_IDLE.png | 1.76 MB | 1024x1536 |  |
| SPR-FOE-SHARD-SWARM-FRONT_TALK.png | 1.95 MB | 1024x1536 |  |
| BST-PANTRY-HOUND.png | 2.64 MB | 1024x1024 | touches top/bottom/left/right |
| BST-LOST-JUNIOR-CLERK.png | 2.72 MB | 1024x1024 | touches top/bottom/left/right |
| BST-BIN-RACCOON.png | 2.65 MB | 1024x1024 | touches top/bottom/left/right |
| BST-QUOTA-SPOTTER.png | 2.60 MB | 1024x1024 | touches top/bottom/left/right |
| CUT-WARDEN.png | 3.28 MB | 1024x1536 | touches bottom |
| BST-HOLLOW-WARDEN.png | 2.84 MB | 1024x1024 | touches top/bottom/left/right |
| CUT-BRONSON.png | 2.85 MB | 1024x1536 | touches bottom |
| CUT-PALLOR.png | 2.99 MB | 1024x1536 | touches bottom |
| CUT-GRAVOIS.png | 3.34 MB | 1024x1536 | touches bottom |
| CUT-MULLIGAN.png | 3.56 MB | 1024x1536 | touches bottom |
| CUT-NINJA.png | 2.72 MB | 1024x1536 | touches bottom/right |
| BST-SHIRO-SWINDLE.png | 2.75 MB | 1024x1024 | touches top/bottom/left/right |
| CUT-VAULTWARDEN.png | 3.21 MB | 1024x1536 | touches bottom/right |
| BST-THE-WARDEN-OF-THE-FOUR-SEALS.png | 2.92 MB | 1024x1024 | touches top/bottom/left/right |
| CUT-CLENCH.png | 2.87 MB | 1024x1536 |  |
| BST-CHANCELLOR-CLENCH-IRON-REGENT.png | 2.70 MB | 1024x1024 | touches top/bottom/left/right |
| CUT-QUOTA.png | 2.20 MB | 1024x1536 | touches bottom |
| BST-VIVIENNE-QUOTA-MINISTER-OF-EFFICIENCY.png | 2.45 MB | 1024x1024 | touches top/bottom/left/right |
| CUT-SPOTTER.png | 3.04 MB | 1024x1536 | touches bottom/right |
| BST-THE-ANCIENT-SPOTTER.png | 2.91 MB | 1024x1024 | touches top/bottom/left/right |
| CUT-DOPPEL.png | 2.90 MB | 1024x1536 | touches bottom |
| BST-THE-DOPPELGANGER.png | 1.76 MB | 1024x1024 | touches top/bottom/left/right no alpha |
| CUT-ITAMAE.png | 2.10 MB | 1024x1536 | touches bottom |
| BST-THE-ITAMAE-SUPREME.png | 1.45 MB | 1024x1024 | touches top/bottom/left/right no alpha |
| CUT-CRUMB.png | 2.27 MB | 1024x1536 | touches bottom/left/right |
| BST-COLONEL-CORNELIUS-CRUMB-DIRECTOR-OF-CULINARY-DEFENSE.png | 1.71 MB | 1024x1024 | touches top/bottom/left/right no alpha |
| CUT-MORTIMER.png | 1.93 MB | 1024x1536 | touches bottom |
| BST-MORTIMER-GRIMSBY-CE-NO.png | 2.20 MB | 1024x1024 | touches top/bottom/left/right |
| CUT-BETTY.png | 2.17 MB | 1024x1536 | touches bottom |
| BST-BETTY-BONES-SURLY-SECRETARY.png | 2.29 MB | 1024x1024 | touches top/bottom/left/right |
| CUT-PLUME.png | 2.82 MB | 1024x1536 | touches bottom |
| BST-PERCIVAL-PLUME-DEPUTY-MINISTER-OF-GOOD-NEWS.png | 1.83 MB | 1024x1024 | touches top/bottom/left/right no alpha |
| CUT-ROTHEART.png | 3.81 MB | 1024x1536 | touches bottom |
| BST-COMPOSTELLA-THE-ROTHEART.png | 2.19 MB | 1024x1024 | touches top/bottom/left/right no alpha |
| CUT-CLIPWELL.png | 2.00 MB | 1024x1536 | touches bottom |
| BST-HORTENSIA-CLIPWELL-ROYAL-GROUNDSKEEPER.png | 1.62 MB | 1024x1024 | touches top/bottom/left/right no alpha |
| CUT-RACCOONKING.png | 2.86 MB | 1024x1536 | touches bottom/left/right |
| BST-HIS-MAJESTY-THE-RACCOON.png | 1.85 MB | 1024x1024 | touches top/bottom/left/right no alpha |
| CUT-SPOTLESS.png | 2.59 MB | 1024x1536 | touches bottom/left/right |
| BST-CAPTAIN-SPOTLESS.png | 1.76 MB | 1024x1024 | touches top/bottom/left/right no alpha |
| BST-ENFORCER-CAPTAIN-SPOTLESS.png | 1.76 MB | 1024x1024 | touches top/bottom/left/right no alpha |
| CUT-PRIMM.png | 2.85 MB | 1024x1536 | touches bottom/left |
| BST-PRIMM-HIS-PERFECTION.png | 1.79 MB | 1024x1024 | touches top/bottom/left/right no alpha |
| CUT-AUTOMATON.png | 2.95 MB | 1024x1536 | touches bottom/left |
| BST-THE-OLD-KINGDOM-AUTOMATON.png | 2.84 MB | 1024x1024 | touches top/bottom/left/right |
| CUT-SIPHON.png | 2.75 MB | 1024x1536 | touches bottom/left/right |
| BST-DR-AMBROSE-SIPHON-CHIEF-PATH-OLOGIST.png | 1.80 MB | 1024x1024 | touches top/bottom/left/right no alpha |
| CUT-BELLOWS.png | 2.51 MB | 1024x1536 | touches bottom/right |
| CUT-PRIMM_CRACKED.png | 2.82 MB | 1024x1536 | touches bottom/left/right |
| CUT-PRIMM_UNRAVELLED.png | 3.25 MB | 1024x1536 | touches bottom/left |

## Part 1 - Maren and the roaming enemies (Oct 28 20:50-21:20)

- `data/source/npc_sprite_batch.csv`: section G, 21 `NE-*` rows (`NPC-FOE-<KEY>`, relative heights from the batch rows: hound 0.75, clerk 0.6,
  raccoon 0.62, spotter 1.05, golems 1.3-1.35, sprite 0.8, manager 1.15, intern 0.9, courier 0.95, meatball 1.0, casserole 1.3, gulls 1.1,
  officer 1.2, inspector 1.0, tidy-bot 0.9, wretch 1.2, swarm 1.0). Maren keeps her 0.7 row.
- Imported: `import portraits` (26 CUT-* added, NPC-ELDER / _HAPPY / _WORRIED replaced), `import npc sprites` (21 FOE sets + ELDER re-cut;
  14 walk sets of 26 frames, 7 idle sets of 4), `import bestiary` (24 squares incl. the BST-ENFORCER-CAPTAIN-SPOTLESS copy).
  `tools/sprite_anchors.gd` re-measured the head / cloak anchors; only ELDER and the FOE sets kept the new numbers (the rest restored).
- Walk strips: 22 of the 70 strips have touching figures, so the importer cuts them at the emptiest column near each quarter; a new pass
  (`_drop_edge_slivers`) clears small neighbour slivers left at a cut edge. Contact sheets: `_art_inbox/world_test_sheets/FOE_*.png`.
- Every SIDE / FRONTSIDE / BACKSIDE picture faces left as the lock asks (`_screenshots/oct28/review_sides.png`), so the mirrored right side is right.
- Code: `ZoneEnemy` looks the set up under the manifest's folder name (`FOE-PANTRY-HOUND` -> `FOE_PANTRY_HOUND`; before tonight no roamer
  would ever have found its set), draws it untinted (the spec tint was for the 3D model), strikes the threat pose (FRONT_TALK, 0.45 s) when it
  spots the hero, puts the "!" above the sprite's head, hops and sways when an idle-only set moves, and gives the painting a warm hostile rim.
  `WorldSprite.walk_dirs()`, `set_rim()`, `demo_walk_speed`.
- Check tool: `--lineup=idle|walk|threat` on the zone and town scenes (`RoamerLineup`, world/dev): every roamer kind of the area in all six
  facings beside the hero; prints each copy's frame. Shots: `_screenshots/oct28/lineup_{town,gainlands,dna,buffet,heap,capital}_idle.png`,
  `lineup_heap_walk.png` (with `--set=camera_zoom:0.6-0.75`). Maren: `_screenshots/dialogue/oct28_elder.png`.
- Not covered: Captain Spotless (Capital roamer) has no FOE set and stays 3D (inbox 1). Colonel Casserole is not on the Buffet's open map
  at the entrance (its lineup was not shot; the set imports and is tested).

## Part 2 - boss entrances and the Bestiary

- `Bestiary.cutout(name, phase)`: Primm's phase 2 and 3 use `CUT-PRIMM_CRACKED` / `CUT-PRIMM_UNRAVELLED` (`PHASE_CUTOUTS`); the battle passes
  `BattleContext.boss_phase`.
- `scenes/dev/entrance_gallery.tscn` plays and holds every `BossIntros` entrance (Primm once per phase) and tiles them into
  `_screenshots/oct28/entrances.png`: 27 of 31 use their CUT-* cut-out; Baron Quadzilla, Colonel Casserole, the Restless Dead and the
  Wellspring's Echo keep their Bestiary square (no speaking character, no cut-out asked for).
- The 23 squares show through `Bestiary.art` (Collection Book and battle plates); both Spotless ids have the picture; renamed enemies keep
  counting and keep their old pictures (`Bestiary.RENAMED`, `legacy_art_ids`).
- Test: `tests/core/data/test_art_import_oct28.gd` (7 tests).
