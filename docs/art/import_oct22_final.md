# Art Batch Oct 22: final import (Oct 23)

Follows `docs/art/import_oct22_partial.md` (Oct 22 evening: 50 done, 1 redo, 22 still to make, plus 4 gear icons outside the batch).
This pass looked for the 27 files that were still open: the Leaf Crown redo, the 9 Verdant Dump kit pieces, the 13 portrait fixes and the 4
lieutenant gear icons. File names below are exactly as in the design sheet.

## What arrived

`Pending Review` was **empty**. The 22 new files had been put straight into the approved folders (none of them had to be moved):

- 9 `DUMP-*` in `Approved_ZoneKits/VerdantDump` (Oct 22, 20:59 - 21:13)
- 13 `NPC-*` in `Approved_Characters` (Oct 23, 06:33 - 06:58), overwriting the old portraits of the same names

A search of the whole `Card Game Art` folder for anything changed since the Oct 22 sort found only these 22. Every one was read through to the
end (signature, every chunk CRC, the pixel data inflated to its exact size) and none is truncated. Their sizes were stable. Nothing in the Drive
was moved, renamed or deleted, and nothing was left unrecognised.

| Group | Expected | Delivered | DONE | REDO | STILL MISSING |
|-------|---------:|----------:|-----:|-----:|--------------:|
| Leaf Crown redo | 1 | 0 | 0 | 1 | 1 |
| Verdant Dump kit | 9 | 9 | 7 | 1 | 0 |
| Portrait fixes | 13 | 13 | 13 | 0 | 0 |
| Lieutenant gear icons | 4 | 0 | 0 | 0 | 4 |
| **Total** | **27** | **22** | **20** | **2** | **5** |

DUMP-TREE-ROTHEART is the 22nd file: it is imported, but nothing in the game uses it yet (see below). It is not counted as DONE or REDO.

With the partial import, the Oct 22 batch now stands at **70 of 73 done**: COS-HAT-LEAFCROWN-SHEET and DUMP-BD-ROTHEART are REDO, and
DUMP-TREE-ROTHEART is waiting for a place to go.

## DONE

Portrait fixes (`bash tools/import_portraits.sh`: 13 replaced, all already transparent, same 768 px framing as the other portraits)
- NPC-ELDER.png, NPC-GATEKEEPER.png, NPC-RIP.png, NPC-PUMP.png, NPC-THUNDERABS.png, NPC-MOUNTAIN.png, NPC-ECTOMUND.png, NPC-PATE.png,
  NPC-FLAMBE.png, NPC-BASIL.png, NPC-WREN.png, NPC-KESTREL.png, NPC-SPOTLESS.png

Each one was compared with the NPC's world sprite (front and side view): species, colours, outfit and props all match. The biggest fix is the
Elder, whose old portrait had a tortoise head while her sprite is a grey-haired woman with a shell on her back. The new portrait matches the
sprite. All 13 were checked in the dialogue box (`dialogue_shots npc:NPC-*`). No mismatches.

Verdant Dump kit (`bash tools/import_zone_kit.sh heap`: 59 of 59 imported)
- DUMP-ROOF-THATCH.png: the "reed" roof slot of the Dump's kit meshes (the shacks with reed roofs) uses the reed-and-bottle thatch instead of
  the plain DUMP-ROOF-REED (`HeapLandmarks._materials`).
- DUMP-GROUND-GRAVEL.png: replaces the junk-gravel stand-in texture (`dump_junkgravel`) in the junk yards, normal and freed.
- DUMP-GROUND-COMPOST.png: replaces the compost stand-in texture (`dump_compost`) on the compost ground of the freed Dump. While the zone is
  not freed, that ground is the corruption layer. The terrain already uses its maximum of five layers, so compost cannot be added there too.
- DUMP-PROP-WINDMILL.png: a new `windmill_plot` cluster (the windmill card, 4.2 m, and a wildflower crate) on three free spots: (37, 79) and
  (64, 76) on the farm terrace and (52, 97) by the farm's lower fields. Nothing stood there before. The procedural stand-in windmill
  (`HeapProps.windmill`) is no longer placed in the v2 layout. The little spinning windmills on the landmarks stay 3D, because a card cannot spin.
- DUMP-DEC-RUST.png, DUMP-DEC-PETAL.png, DUMP-DEC-MOSS.png: replace the generic `rust`, `flowers` and `moss` ground decals of the heap
  preset (same counts, sizes and masks).
- The replaced painted stand-ins (`dump_junkgravel`, `dump_compost`, `decal:rust`) are kept as each entry's `"fallback"` in
  `data/art/texture_presets.json`: they are used only if the kit file is missing (`PaintedLibrary.entry_name`). This also keeps the
  "every imported texture is used" test honest, and a texture re-import does not bring back dead files.

## REDO

- **COS-HAT-LEAFCROWN-SHEET.png** (no redo delivered). The current sheet still shows the wreath standing upright like a hoop, so it is now
  held out of the game: `SpriteCosmetics.HELD_HATS`. Pip's shop shows "Soon" and it cannot be bought. If a save already wears it, nothing is
  drawn. The Verdant Dump chest still gives the Crown of Leaves, so it is owned and appears the moment a good sheet is imported. Ask again:
  a wreath seen from about 25 degrees above, lying flat round the head, with the whole wreath inside each fifth of the 2560x512 sheet. When
  it arrives: `bash tools/import_cosmetics.sh`, then remove "LEAFCROWN" from `HELD_HATS`.
- **DUMP-BD-ROTHEART.png**: a lovely full painting, but its sky is painted in (opaque, 2048x1024, the importer notes "no transparent sky
  above the skyline"). A horizon card has to be transparent above the skyline so the zone's own sky shows through. This is the same problem
  GAIN-BD-MESAS had before its redo. It is imported but not shown. Ask for the same scene with a transparent sky: only the Rotheart, the cliffs
  and the falls, left and right edges matching.

Also worth a redo (not in this batch): the older expression portraits **NPC-ELDER_HAPPY**, **NPC-ELDER_WORRIED**, **NPC-GATEKEEPER_HAPPY**
and **NPC-GATEKEEPER_STERN** were not repainted. The Gatekeeper's two are a bearded human, not the bear, and the Elder's two have no shell.
No dialogue line uses an expression tag yet (only vendors switch expressions), so players never see them. They should be redone before any
`[happy]` or `[stern]` line is written for these two.

## Imported, waiting for a place

- **DUMP-TREE-ROTHEART.png** ("the enormous Rotheart tree seen far away"). It was requested before the Rotheart became the 3D hero model at
  the north end of the Dump, and inside the Dump that model already plays the part, so a card would show the tree twice. Outside the Dump,
  Crosspath's horizon card for the Dump lies due west, and the town camera always faces north, so a card there would never be seen (tried and
  reverted). It is registered and ready. Possible uses: the Rotheart's dungeon map or battleboard, the world map, or a distant view from
  another zone. **Your call.**

## STILL MISSING (not delivered)

- COS-HAT-LEAFCROWN-SHEET.png (the redo)
- ICON-GEAR-QUOTASSTOPWATCH.png, ICON-GEAR-COLONELSLADLE.png, ICON-GEAR-PLUMESQUILL.png, ICON-GEAR-CLIPWELLSSHEARS.png

The four gear icons are already wired. Their IDs come from the gear data (`quotas_stopwatch`, `colonels_ladle`, `plumes_quill`,
`clipwells_shears` -> `IconArt.gear_icon_id`), and the character screen, the vendor, the reward popup, the codex and the quest log all read
them through `IconArt`. Put the four files in `Approved_Icons` and run `bash tools/import_icons.sh`. Until then the four pieces show the
shared gear placeholder, and gear icons stand at 55 of 59.

## Checks

- PNG integrity: 22 of 22 OK.
- 60 fps on Medium in the Dump (`tools/fps.sh heap 1`): hub 65.6 fps (p95 16.7 ms), junk yard by the thatched shack 76.4, farm windmill 69.5,
  lower fields 70.2.
- Routes: the windmill clusters go through `HeapDressing._free` (off routes, stairs, plaza, anchors and chests, 4 m from other clusters).
  `test_heap_slice` checks that all three stand and that every solid cluster keeps off the routes.
- Tests and smokes: see the commit messages of "Final art import Oct 23, Part 2/3".

## Screenshots to look at

- Portraits vs. world sprites (old | new | sprite front | sprite side): `docs/art/import_oct23/portraits_vs_sprites_a.jpg`, `_b.jpg`
- Portraits in dialogue: `docs/art/import_oct23/dialogue_elder.jpg`, `dialogue_kestrel.jpg`
- The stale expression portraits: `docs/art/import_oct23/expressions_elder_gatekeeper.jpg`
- The nine Dump pieces: `docs/art/import_oct23/dump_kit_pieces.jpg`, `dump_kit_pieces_2.jpg`
- Before | after in the Dump (same camera): `docs/art/import_oct23/dump_shack.jpg` (junk gravel, thatch on the shack roof, rust decals),
  `dump_junk.jpg`, `dump_mill1.jpg`, `dump_mill2.jpg`, `dump_mill3.jpg` (the windmill plots)

From the play camera the gravel change is plain to see. The thatch and the windmills are small: the reed-roofed shack sits far up on the
plateau, and the windmill cards stand among bushes and twisted trees in the golden-hour haze. If they should read more, the next step is
taller cards or more open spots.
