# Batch 15 import (Nov 13)

All 39 approved images are imported and wired. Brief: `docs/prompts/batch15_import_and_fixes.md`, Part 1. Art list:
`docs/art/batch15_nov12.csv` (22 rows "In game"; the world maps and the Gallery's bestiary pictures were not in the batch). Shots:
`docs/overnight_shots/batch15/`. Tests: `tests/test_batch15_import.gd`.

| Images | Where it is in the game | Shot |
|---|---|---|
| CAP-SHEET-WINDOWS-07 / -08 | Every townhouse window of the Capital (`CapitalGrand`): -07 by day, -08 (lit) in the freed city. The Capital has no dusk of its own, so "lit" means after Primm | `windows_day_plaza`, `windows_day_reek`, `freed_capital_approach_low` |
| CAP-BANNER-FREED-01..04 | After `primm_defeated`: a row down the avenue (one inside each bunting post) and the four in a row over Primm's emblem on the castle, the Ward and the gate (`CapitalKit.emblem`) | `freed_capital_approach`, `freed_capital_approach_low`, `freed_capital_plaza_low` |
| CAP-BD-LANTERNS, CAP-FX-FIREWORKS | After `primm_defeated` (`CapitalSkyFx`): the lanterns climb slowly from the grand stair in front of the castle; one soft burst every 4.5 to 9 s before the keep's upper face. Reduce motion or Low-end: one still lantern card, no fireworks | `freed_capital_approach_low` |
| CAP-PROP-PORTRAIT-PRIMM-01..03 | The easel portraits on the verges (`CapitalProps.portrait`). The smiley stays Primm's emblem everywhere else | `freed_capital_approach_low` |
| CAP-PROP-RUBBLE-ROW | The foot of the south wall inside the Reek and the Transit Yards, and the outskirts' south edge either side of the road (`CapitalBuilder.RUBBLE_ROWS`) | `rubble_row_transit_yards` |
| BUFF-PROP-STALL-01 / -02 | The Buffet hub: Madame Mirepoix's sweet stall (now behind her, facing the camera) and a savoury stall beside it | `buffet_stalls` |
| DNA-PROP-SERVING-ORB | The D.N.A. lobby: at the head of the ghost queue and beside TAKE A NUMBER | `dna_serving_orb` |
| DUMP-HERO-RACCOON-STATUE | The raccoon king on the throne beside the Rotheart's gate (the grey faceted statue) | `dump_raccoon_statue` |
| DUMP-PROP-MILL-SAILS | The sails of the farm rows' windmill, Junk Mountain's wheel and the glasshouse's little mill, turning slowly (0.35 rad/s) | `dump_mill_sails` |
| GAIN-GROUND-MAT | The gym mats (same id, replaced) | `gainlands_gym_mat` |
| ICON-EQ-HALLPASSSLIPPERS, ICON-GEAR-EARNEDBLADE | Their own icons (60 of 60 gear icons now) | `icons_gallery`, `gear_icons_character` |
| MAP-S-GALLERY | The Shattered Gallery's map. It is 16:9 now (the old one was 3:2); all 13 nodes moved onto the painted landings, and every painted path matches a link of the dungeon | `gallery_map_nodes` |
| MG-BG-MATCHTABLE, UI-CARDBACK-DEX | Dex's matching game: the table behind the screen, his card back on the face-down cards | `dex_match_table` |
| UI-BATTLE-ITEMSLOT-EMPTY / -READY | The battle item slots, inside the same slot rect | `battle_item_slots` |
| UI-PACK-LOCKED-B / -G / -N / -R | Fenwick's locked Path Packs (no dimmed pack, velvet cover or lock glyph any more) | `locked_packs` |
| UI-NODE-BANNER | The base of the pop-up banner (`NodeCard.BANNER_ART_ID`) | `node_banner_shrine`, `node_banner_treasure` |
| NPC-HESPER, STORY-EPI-WRINKLES | Replaced. The code recolour (`ArtPatches`) and its test are deleted | `portrait_hesper` |
| V-FIGSLY | Replaced (two arms) | `portrait_figsly` |
| STORY-CREDITS-PANORAMA | Behind the credits scroll and the thanks card: screen-high, panning from its left end to its right while the credits run (still with Reduce motion). Kept 3072 px wide, never cropped | `credits_panorama`, `credits_thanks_card` |
| SPR-ELOWEN-*_WALK (5) | See below | `elowen_walk_default`, `elowen_walk_low` (+ `_frame`) |

## The locked packs
Checked against the unlocked packs: Beefcake red, Gourmand orange and Necrocrat deep green match. The Refusemancer parcel also has a
green seal, the same as the Necrocrat one, while its pack carries a rust-red medallion. Its seal is tinted to that rust in code
(`PackArt.LOCKED_SEAL_TINTS`, a small shader that re-colours only the wax), so each seal echoes its pack's medallion and the two green
parcels can be told apart. Delete the entry to get the painted green back.

## Elowen's walk
- Imported the way the walkers are: each sheet sliced into four frames, scaled so a direction's mean walk height equals her idle height
  (440 px figure on her 304x504 canvas, the walkers' own figure height), `_n` normal maps, the walkers' frame rate (the walk cycle follows
  the distance covered), mirrored for the right-facing directions.
- She has idles for front, side and back only. The importer now accepts a walk strip for a direction with no idle
  (`tools/world_test_import.gd`), and `WorldSprite` picks among the walk directions while a figure moves and among the idles when it
  stops.
- **The intro:** she walks north-west into the trees (away from the cave path, never across the hero), 3 m in 2.6 s, in her back
  three-quarter frames, and fades over the last second.
- **Elsewhere:** the only other place her figure moves is the cave mouth in Crosspath (after each freed zone she walks to the cave and
  fades). The Lab, her rescue and the epilogue are played as stills and dialogue: no figure walks there.
- **One thing to know:** until Plume names her she wears the disguise (scarf over her face), and the disguise set has no walk frames. She
  walks in Elowen's frames. On both paths she walks away from the camera, so her face is turned away, but the scarf is not in the
  walk art. A masked walk set (SPR-RESCUER-*_WALK) would close that.

## Importer changes
- `UiArt`: UI-NODE-BANNER is kept whole (opaque, no trim, no background removal).
- `KeyArt.UNCROPPED`: the panorama is not cropped to 16:9 or shrunk; import rule `STORY-CREDITS-PANORAMA*` (lossy WebP, 3072 px).
- The portrait importer re-added the opaque NPC-PLAYER again: reverted, as before.
- Registries spliced into HEAD's text (`tools/kit_splice.py`, the sprite manifest by hand) to avoid float churn.

## Size
81 new files, 8.0 MB of source art; **about 17 MB more in the pack** (RC1's pack was 847 MB, so about 864 MB; the zip about 750 MB).
The seven replaced files are 0.3 MB smaller in source. The pack was already over the 750 MB warning on purpose (music at q6,
`docs/build_size_policy.md`); this batch adds 2 %. The largest new pieces are Elowen's 20 walk frames and their normals, the lantern and
firework cards and the panorama.
