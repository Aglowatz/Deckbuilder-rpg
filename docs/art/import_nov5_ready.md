# Art import, Nov 5 morning: where to save each image

The rows of `docs/art/art_needed_nov4.csv` (38 rows: the Nov 4 list, three generic townsfolk and the Shattered Gallery map), with the
Google Drive folder and filename to save each final image as, and the command that picks it up. Every folder is under
`G:/My Drive/Card Game Art/` (`data/source/art_config.cfg`); the importers only COPY from there. Save PNGs named exactly as below; sizes
and formats are in the CSV's "size" and "format" columns.

After saving, say **"import art Nov 5"** and I run, in this order (one Godot at a time): portraits, npc sprites, key art, bestiary, UI art,
maps, the two zone kits. The dry run of every importer on placeholder files of these exact names passed tonight (see the end).

| Id(s) | Save into | Filename(s) | Command |
|---|---|---|---|
| NPC-FLEX, NPC-FLEX_REVEAL, CUT-FLEX, NPC-TOWNSFOLK, NPC-GYM-ATTENDANT, NPC-BRISKET, NPC-SIR-LOIN, NPC-CAPITAL-GUARD, NPC-TOWNSFOLK-A, NPC-TOWNSFOLK-B, NPC-TOWNSFOLK-C | `Approved_Characters` | `<ID>.png` (e.g. `NPC-TOWNSFOLK-A.png`, `CUT-FLEX.png`) | `bash tools/import_portraits.sh` |
| SPR-FLEX-FRONT_IDLE, -FRONT_TALK, -SIDE_IDLE, -BACK_IDLE | `Approved_Sprites` | `SPR-FLEX-FRONT_IDLE.png` ... | `bash tools/import_npc_sprites.sh` |
| SPR-FLEX-FREED (set) | `Approved_Sprites` | `SPR-FLEX-FREED-REF.png`, `SPR-FLEX-FREED-FRONT_IDLE.png`, `-FRONT_TALK`, `-SIDE_IDLE`, `-BACK_IDLE` | `bash tools/import_npc_sprites.sh` |
| SPR-PRIMM, SPR-ROLLO, SPR-FIGSLY, SPR-KYLE, SPR-GERALD | `Approved_Sprites` | `SPR-<KEY>-FRONT_IDLE.png`, `-SIDE_IDLE`, `-BACK_IDLE`, `-FRONT_TALK`, `-REF` | `bash tools/import_npc_sprites.sh` |
| SPR-TOWNSFOLK-A, -B, -C (walkers) | `Approved_Sprites` | per key: `SPR-TOWNSFOLK-A-FRONT_IDLE.png`, `-FRONTSIDE_IDLE`, `-SIDE_IDLE`, `-BACK_IDLE`, `-FRONT_WALK`, `-FRONTSIDE_WALK`, `-SIDE_WALK`, `-BACK_WALK`, `-FRONT_TALK`, `-REF` | `bash tools/import_npc_sprites.sh` (rows NT-TOWNSFOLK-A/B/C in `data/source/npc_sprite_batch.csv` give the height) |
| SPR-PLAYER-CLOAK | (decision first: the row asks which way to go) | | |
| SPR-BENCHLEY / LEDGERBONE / GRISTLE / MIREPOIX | (check only, no file) | | |
| STORY-RESCUE, STORY-FLEX, STORY-CLENCH-THRONE, STORY-PRIMM-FALL, STORY-EPI-TOGETHER | `Approved_KeyArt` | `<ID>.png` | `bash tools/import_key_art.sh` |
| BST-UNPAID-INTERN, BST-HUNGRY-SCARECROW, BST-CORRECTION-OFFICER, BST-UNDERSECRETARY-VELLUM, BST-INTAKE-ORDERLY | `Approved_Bestiary` | `<ID>.png` | `bash tools/import_bestiary.sh` |
| UI-BG-DECKBUILDER | `Approved_UI` | `UI-BG-DECKBUILDER.png` (replaces the old one) | `bash tools/import_ui_art.sh` |
| MAP-S-GALLERY | `Approved_Maps` | `MAP-S-GALLERY.png` (1536 x 1024; node guide `docs/art/paintover_inputs/gallery_map_guide.png`) | `bash tools/import_maps.sh` (the castle stand-in drops out by itself: `MapArt.map_path` prefers the real file) |
| OF-PROP-BRAMBLES | `Approved_ZoneKits/OpeningForest` | `OF-PROP-BRAMBLES.png` | `bash tools/import_zone_kit.sh openingforest --only=OF-PROP-BRAMBLES` |
| GAIN-HERO-IRON-CRAG | `Approved_ZoneKits/Gainlands` | `GAIN-HERO-IRON-CRAG.png` | `bash tools/import_zone_kit.sh gainlands --only=GAIN-HERO-IRON-CRAG` |

Notes:

- The generic townsfolk are new characters. The importer cuts and scales them like every walker; using them in Crosspath's crowds is a
  small follow-up once they exist (they are not wired into a scene tonight).
- MAP-S-GALLERY: paint a platform under each of the 13 circles of the guide; the walkways follow its lines. The guide's percentages are the
  node positions in `data/dungeons/postgame_dungeons.json`, so no re-fitting is needed if the platforms land on them.

## Dry run (tonight)

See the end of `docs/overnight_report.md`, "Art import checklist", for the importer dry run on placeholder files of these names (every id
was picked up and written where the game reads it; the placeholders and their outputs were removed afterwards).

**Imported Nov 6:** see `docs/art/import_nov6_batch12.md` (all 84 files; NPC-PLAYER held back for a transparent redo).
