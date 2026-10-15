# Primm's Castle: not a walkable area

Art Bible G-07 (`docs/design/subarea_removal.md`, SR-3): the only walkable areas are the forest, the town, the four Path zones and the Capital. Primm's Castle is the Capital's main dungeon, a node map opened by the castle door (`CapitalZone` spot `castle_door`, "Enter Primm's Castle") at the end of the palace approach inside the wall. There are no castle grounds to walk: the four Castle Grounds scenes (Courtyard, Mirror Colonnade, Grand Stair, Palace Gardens) were removed with their data, their style file and their kit list.

What the castle still needs from art: its painted node map and battleboard (the map pipeline, `bash tools/import_maps.sh`), its loading art, and the palace facade seen from the Capital's palace approach (CAPI-HERO-PALACE-FACADE in `docs/art/zone_kits/capital_inside.md`). The look (cold crisp morning, marble and gold, mirrors, colonnades, the grand stair) stays in `docs/art/art_bible.md` for those pictures.

Saves made in the old castle scenes load at the Capital's palace approach (`LegacySubAreas`).
