# Art Batch Oct 22: partial delivery, what is in and what is left (Oct 22 evening)

The design sheet's "Art Batch Oct 22" tab has 73 rows in 4 batches. ChatGPT delivered 51 files to `Pending Review`. All 51 were read through to the end
(every chunk, CRC and the pixel data: none truncated) and then sorted into the `Approved_*` folders. The importers ran in the order of
`docs/art/import_oct22.md`. File names below are exactly as in the sheet.

| Batch | Rows | Delivered | DONE | REDO | STILL TO MAKE |
|-------|-----:|----------:|-----:|-----:|--------------:|
| 1 (hats, Rescuer, icons) | 20 | 20 | 19 | 1 | 0 |
| 2 (tokens, maps, boards, Old Well, bestiary, kit redos) | 20 | 20 | 20 | 0 | 0 |
| 3 (Gainlands + Verdant Dump kit) | 20 | 11 | 11 | 0 | 9 |
| 4 (13 portrait fixes) | 13 | 0 | 0 | 0 | 13 |
| **Total** | **73** | **51** | **50** | **1** | **22** |

Sort notes: 11 files had the same name as an older file in the target folder. Both copies were kept and the new one was renamed `-v2`:
ICON-COS-TRICORN, ICON-GEAR-DUMPSTERGLOVES, ICON-GEAR-STARTERBLADE, ICON-ITEM-BAGOFRUBBISH, ICON-ITEM-SHARPENINGSTONE, ICON-ITEM-SILENCEPOWDER,
ICON-ITEM-SPICEPOUCH, BST-EXECUTIVE-ELEVATOR-OPERATOR, BST-FROZEN-LINE-COOK, DUMP-PROP-STALL, GAIN-BD-MESAS. The icon, bestiary and zone kit
importers now take the highest `-vN` of a name (`ArtImporter.latest_revisions`), like the UI importer already did. Nothing was left unrecognised in
`Pending Review`.

## DONE (imported and in the game)

Batch 1
- COS-HAT-WIDEBRIM-SHEET.png, COS-HAT-CHEF-SHEET.png, COS-HAT-BOWLER-SHEET.png, COS-HAT-TRICORN-SHEET.png, COS-HAT-WIZARD-SHEET.png. Split into 5 views and fitted to the hero's head. They are on sale at Pip Threadwell's and can be worn from the wardrobe.
- ICON-COS-TRICORN.png
- NPC-RESCUER.png: the Rescuer's portrait until Plume names her at the castle gate.
- SPR-RESCUER.png: split into 4 frames (FRONT_IDLE, FRONT_TALK, SIDE_IDLE, BACK_IDLE), no specks. This is the prologue figure.
- ICON-GEAR-DUMPSTERGLOVES.png, ICON-GEAR-STARTERBLADE.png, ICON-ITEM-BAGOFRUBBISH.png, ICON-ITEM-SHARPENINGSTONE.png, ICON-ITEM-SILENCEPOWDER.png, ICON-ITEM-SPICEPOUCH.png
- ICON-GEAR-CHAMPIONSLAURELS.png, ICON-GEAR-CROWDPLEASERSCAPE.png, ICON-GEAR-GLADIATORSNET.png, ICON-GEAR-BLOODSANDBOOTS.png, ICON-GEAR-FIRSTWATERPHIAL.png

Batch 2
- T-24.png, T-25.png, RES-IRON.png, RES-GARBAGE.png, RES-INGREDIENT.png, JUNK-01.png. All 341 cards and tokens now have art.
- MAP-S-PASTE.png and MAP-LAB.png. The node spots were re-fitted to the painted platforms in `data/dungeons/map_layout.json`: S-PASTE 3 stops, D-LAB all 16.
- BB-S-PASTE.png, BB-LAB.png (cropped to 16:9). The Paste Works no longer borrows the Test Kitchen board.
- NPC-OLDWELL.png: the Old Well's portrait (vision, hums, confirm, brief).
- BST-THE-WELLSPRING-S-ECHO.png, BST-RATION-LINE-SUPERVISOR.png, BST-VAT-FLOOR-GOLEM.png, BST-HYBRID-SPECIMEN.png, BST-ANTECHAMBER-SENTRY.png, BST-EXECUTIVE-ELEVATOR-OPERATOR.png, BST-FROZEN-LINE-COOK.png
- DUMP-PROP-STALL.png: the three market stalls in the Dump, which replace the shared kit stall.
- GAIN-BD-MESAS.png: the sky is really transparent this time (306 clear rows at the top). It is three 60° ring cards on the open arcs of the Gainlands horizon.

Batch 3
- GAIN-GROUND-MAT.png: the lifting yards and the Swole Station floor.
- GAIN-GROUND-CHALK.png: the plateau ground.
- GAIN-GROUND-FIELD.png: the floating islands and the landmark grass.
- GAIN-DEC-CHALK.png: the decals on the gym mats.
- DUMP-PLANT-LUPIN.png: the path edges in the healthy regions.
- DUMP-PLANT-LILY.png: the ravine banks and the overflow pool.
- DUMP-TREE-CANOPY.png: 6 leaf masses on the Rotheart's crown.
- DUMP-SKY-SUNSET-SOFT.png: the zone sky. DUMP-SKY-SUNSET is the fallback.
- DUMP-WALL-SCRAP.png: the stables, the fair stage, the junk dam and the gate barricade.
- DUMP-HERO-SCRAPMORE.png: a concept reference for the junk peak, kept under docs/art/zone_kits/heap/concepts/.
- DUMP-PROP-STABLE.png: imported, but not shown. The two stables stay 3D because each holds a rideable animal, and they are re-skinned with DUMP-WALL-SCRAP. No redo is needed.

## REDO (unreadable or wrong)

- COS-HAT-LEAFCROWN-SHEET.png (batch 1): the wreath is painted standing upright, as a ring seen face-on. On the hero it reads as one or two rings standing on top of the head, not a crown resting on the hair. Three views (FRONTSIDE, SIDE, BACK) are also clipped at an edge. Ask for a wreath seen from about 25° above, lying flat round the head, with the whole wreath inside each fifth of the sheet. The current sheet stays in the game until the redo arrives.

No file was unreadable or truncated.

## STILL TO MAKE (not delivered)

Batch 3 (9)
- DUMP-ROOF-THATCH.png, DUMP-GROUND-GRAVEL.png, DUMP-GROUND-COMPOST.png, DUMP-TREE-ROTHEART.png, DUMP-PROP-WINDMILL.png, DUMP-DEC-RUST.png, DUMP-DEC-PETAL.png, DUMP-DEC-MOSS.png, DUMP-BD-ROTHEART.png

Batch 4 (13)
- NPC-ELDER.png, NPC-GATEKEEPER.png, NPC-RIP.png, NPC-PUMP.png, NPC-THUNDERABS.png, NPC-MOUNTAIN.png, NPC-ECTOMUND.png, NPC-PATE.png, NPC-FLAMBE.png, NPC-BASIL.png, NPC-WREN.png, NPC-KESTREL.png, NPC-SPOTLESS.png

## Not from this batch (seen during the import)

- `Approved_Bestiary` has three older files that match no Bestiary ID: BST-OBSERVATION-WARD-ORDERLY.png, BST-REGIME-CHECKPOINT-CAPTAIN.png, BST-ROOTBOUND-MILLER.png.
- `Approved_Characters` has an older NPC-GUS.png that matches no Portrait Image ID.
- Gear icons are at 55 of 59. Still missing: ICON-GEAR-CLIPWELLSSHEARS, ICON-GEAR-COLONELSLADLE, ICON-GEAR-PLUMESQUILL, ICON-GEAR-QUOTASSTOPWATCH. They are not rows of this tab.
