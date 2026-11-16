# Batch 16 import (Nov 16)

All 46 approved images are imported and wired. Brief: `docs/prompts/fable_nov16_overnight.md`, Part 1. Art list:
`docs/art/batch16_nov14.csv` (23 rows, all "In game"). Shots: `docs/overnight_shots/nov16/b16_*`. Tests: `tests/test_batch16_import.gd`.

| Images | Where it is in the game | Shot (`b16_...`) | Against the Path icon guide |
|---|---|---|---|
| V-FIGSLY | Fig Sly's shop portrait and his dialogue portrait. **Two hands**: his right on the coat's lapel, his left hanging at his side | `figsly_shop`, `dlg_npc_V-FIGSLY` | no Path sign |
| STORY-MEMORY-3, STORY-MEMORY-4 | Fragments 3 and 4 (same ids, replaced) | `still_STORY-MEMORY-3_1600x900`, `still_STORY-MEMORY-4_1600x900` | the royal crest is the ring of four medallions, clockwise from the top: arm, chef's hat, leaf, skull. Correct |
| STORY-REUNION, STORY-EPI-FILE-COMPLETE | The ending's reunion and Agnes's stamp (same ids) | `still_STORY-REUNION_1600x900`, `still_STORY-EPI-FILE-COMPLETE_1600x900` | each banner carries one whole medallion on its Path's colour. Correct |
| NPC-SCUFF, CUT-SCUFF, BST-ENFORCER-SERGEANT-SCUFF | Sergeant Scuff's dialogue portrait, boss-intro cut-out and Bestiary square. The Correction Officer stand-ins are gone (`Portraits.STAND_INS`, `Bestiary.ART_STAND_INS` are empty) | `dlg_npc_NPC-SCUFF`, `bestiary_scuff` | no Path sign |
| UI-CARDBACK-B, UI-CARDBACK-N | The Beefcake and Necrocrat card backs (same ids) | `battle_backs` (the Beefcake deck) | the arm on red; the skull in green flame, no quill. Correct |
| ICON-FEAT-PATHS | The **Path feats** heading on the Feats page, above the four one-Path groups (`FeatDefs.PATHS_BADGE`). Each group keeps its own Path icon | `feats` (top of the list; the heading is further down) | four whole medallions on a shield (the prompt asked for a hexagon). The medallions are not redrawn. Fine |
| DEC-PLINTH-BEEF / GOUR / REF / NECRO | The four crest plinths round Crosspath's fountain once each zone is free (same ids, same height in the world: 1.35 m) | `town_square_freed` | a bronze hand holds each medallion up, whole. Correct |
| TOWN-SHEET-FREED-BANNERS-01..04 | One banner per freed zone on the square's lamp posts (same ids; they came as six files instead of one sheet, so the town kit lists them as six cut-outs now) | `town_square_freed` | arm on red, chef's hat on copper, skull on slate green, leaf in arrows on moss green. Correct |
| TOWN-SHEET-FREED-BANNERS-05 / -06 | **New in the game:** once all four zones are free the two ring banners hang on the next two lamp posts of the square (they were imported and unused) | `town_square_freed` | the ring reads clockwise from the top: arm, chef's hat, leaf, skull. Correct |
| CAP-BANNER-FREED-03 / -04 | The freed Capital's avenue and castle banners (same ids) | covered by the Batch 15 shots' places; not re-shot | the leaf in arrows; the skull in flame in laurels. Correct |
| LOGO-EMBLEM, LOGO-WORDMARK, APP-ICON | The title screen, the loading and pause screens, the credits, the window icon and the **Windows export icon** (`assets/icon/app_icon.ico`, `.png`, `.icns` are rewritten by the key-art importer; the export preset already points at the `.ico`) | `title`, `credits` | emblem: arm top, chef's hat right, leaf bottom, skull left. Wordmark row: arm, chef's hat, leaf, skull. Correct |
| TOWN-PROP-SHORE-STONES-01..03 | The lake bank of Crosspath: each stone group is one painted card (`BoundaryKit._painted_stones`); the modelled stones stay as the fallback | `lakeshore` | no Path sign |
| CAP-PROP-CREASE-STALL-01 / -02, CAP-PROP-CREASE-CRATES | The Crease market: Fig Sly stands in front of stall 01 (plum awning), stall 02 (green awning) beside it, five crate stacks | `crease_market` | no Path sign |
| SPR-RESCUER-*_WALK (5) | The Rescuer walks away in her own masked frames (the intro, the cave mouth in Crosspath). Imported like Elowen's: four frames per sheet, scaled to her idle height (440 px figure, 240x504 canvas), `_n` normal maps, mirrored for the right-facing directions | `rescuer_walk` | no Path sign |
| NPC-QUADZILLA, NPC-CAIRN | Baron Quadzilla's lines at the Leg Press Throne (before and after) and the Restless Cairn's lines in the Graveyard | `dlg_npc_NPC-QUADZILLA`, `dlg_npc_NPC-CAIRN` | no Path sign |
| DNA-PROP-CRATES, DNA-PROP-CABINET-TIPPED | Outside the D.N.A.: three tipped cabinets and three crate stacks in `DnaWasteland.OFFICE_DEBRIS` (the cabinet cards turned on their side are gone) | `dna_debris` | no Path sign |
| UI-PACK-GILDED-G / -N / -R, UI-PACK-N, UI-PACK-R | The gilded pack of each Path and the two Path packs. Their painted medallion is the canonical icon, so **no icon is drawn over these five** (`PackArt.PAINTED_MEDALLIONS`). The Beefcake and Gourmand Path packs and the Beefcake gilded pack are the old paintings and keep the overlay | `packs_all` | each medallion is whole and centred in its ring. The foil patterns: chef's hats, skulls, leaves in arrows; the Necrocrat Path pack's stamps and the Refusemancer's leaves are set dressing. Correct |

## Things to know

- **Baron Quadzilla is a speaking boss now**, so the game expects a cut-out for his intro (`CUT-QUADZILLA`). There is none: his intro
  slides his dialogue portrait in (the seated figure). It is listed in `Bestiary.CUTOUTS_AWAITING_ART`.
- **The gilded packs came with painted medallions** (the prompt asked for a plain dark disc). They match the guide, so the painting
  shows and the code overlay is off for them.
- **The portrait importer overwrote NPC-PLAYER again** (the known fault: an opaque file with the same name sits in the Drive folder);
  reverted, file and manifest line.
- `STORY-MEMORY-4` has a dumbbell lying on the courtyard floor. It was in the first painting too; it is a prop, not a Path sign.
- The sprite importer's `--npc_inbox=` needs a trailing slash (`res://_art_inbox/batch16_rescuer/`), or it finds no files.

## Size

100 art files written (47 new pictures and their size copies, 24 walk frames and 24 normal maps). Source art in `assets/`: **+6.8 MB**
net (the replaced files were 11.1 MB, they and the new ones are 17.9 MB). The pack figure is in the report's build section (the
export in Part 6 measures it); the pack was already over the 750 MB warning on purpose (`docs/build_size_policy.md`: music at q6).
