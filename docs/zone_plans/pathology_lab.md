# The Path-ology Lab: not a walkable area

Art Bible G-07 (`docs/design/subarea_removal.md`, SR-3): the only walkable areas are the forest, the town, the four Path zones and the Capital. The Path-ology Lab (D-LAB, `docs/design/pathology_lab.md`) is the postgame dungeon, a 14-node map opened by the hatch in the forest clearing (`StartingAreaScene._enter_lab`, revealed once Rip has opened the forest). There is no antechamber to walk: the five Lab scenes (Hatch Yard, Decontamination Corridor, Specimen Gallery, Records and Break Room, Glass Tank Hall) were removed with their data and their kit list.

What the Lab still needs from art: its painted node map and battleboard (MAP-LAB / BB-LAB placeholders, the map pipeline), its loading art, and the node-map backdrop (`DungeonBackdrop` theme `lab`, driven by the `lab` style preset and `data/zone_styles/pathology_lab.json`, which stay). The look (no sun, white tile cracked by roots, four Path-colour tank glows, one warm thing per room) stays in `docs/art/art_bible.md` for those pictures; the lore of the old wings (the child's drawing, the notes on the subject, the draining log) already lives in the dungeon's nodes.

Saves made in the old Lab scenes load in the forest clearing at the hatch (`LegacySubAreas`).
