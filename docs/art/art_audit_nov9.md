# Art audit (Nov 9)

**Scope:** every image the game shows - 1,957 images: 356 cards, 129 portraits and cut-ins, 105 walk sets (one frame each), 125 bestiary and
character images, 55 stills / loading screens / key art, 44 battleboards and dungeon maps, 75 UI backgrounds and vendor stages, 195 icons
(masters; the size variants are resamples), 40 cosmetics, 603 zone-kit and environment props, 126 textures, skies and backdrops.

**Method:** contact sheets per category (`docs/art/audit_nov9/sheets/`, regenerate with `python tools/art_audit_sheets.py`; index.csv maps
sheet -> id -> file), every sheet read at in-game size or larger; suspicious images cropped at full resolution (`docs/art/audit_nov9/crops/`,
`tools/art_audit_crop.py`). The lead reviewed stills, boards, maps, UI, vendors, portraits and sprites; two reviewers took cards and the
world/UI kits; **every reviewer flag was re-checked by the lead** (crops opened). Raw notes: `audit_nov9/notes_raw.md`, `notes_cards.md`,
`notes_world.md`. No art was changed.

**Outputs:** this page; `docs/art/art_audit_nov9.csv` (every flagged image); **`docs/art/batch14_nov9.csv` - the Batch 14 list** (the REDO
rows sorted by severity x visibility, in the art-list columns, with ready prompts and the references to attach).

## Summary

| | Count |
|---|---|
| Images reviewed | 1,957 |
| Flagged | 26 rows (some rows cover a pair of files) |
| Glaring | 6 rows (5 species-flipping portrait variant sets, the giant-Primm stills) |
| Noticeable | 10 |
| Minor | 10 |
| Verdict REDO (Batch 14) | 12 rows = 17 files |
| Verdict FIX IN CODE | 5 (1 applied tonight: the held portrait variants) |
| Verdict KEEP (noted) | 9 |

**The good news:** across 1,957 images there is **no garbled pseudo-text** a player would read (signs, banners, posters, forms, notice boards
and door plaques are pictorial or blank; the two stills with lettering - STORY-EPI-DECREE, STORY-EPI-FILE-COMPLETE - are correct English), no
melted objects or impossible buildings, no bad hands or extra limbs that show at game size, and every walk set matches its portrait. Every
icon reads at 32 px.

**The real problems are narrative, not "AI tells":** five characters change species when their expression changes (their mood variants were
generated without the base portrait as a reference), and two story stills have a scale error (a giant villain over a tiny hero).

## The worst 25 (worst first: severity x visibility)

| # | Image | Seen | Vis | Problem | Severity | Verdict |
|---|---|---|---|---|---|---|
| 1 | V-SABLE_PLEASED / _SCHEMING | Sable's card shop | 5 | fox -> human woman | glaring | REDO; **held in code tonight** |
| 2 | V-TONIC_EXCITED / _OOPS | Tilly Tonic's shop, first errand | 4 | frog -> human woman | glaring | REDO; held tonight |
| 3 | NPC-GATEKEEPER_HAPPY / _STERN | Brannoch, main quest giver | 4 | bear -> bearded human | glaring | REDO; held tonight |
| 4 | V-FENWICK_EXCITED | pack shop | 3 | magpie -> human | glaring | REDO; held tonight |
| 5 | V-THREADWELL_DELIGHTED | hat shop / Wardrobe | 3 | mouse -> human | glaring | REDO; held tonight |
| 6 | STORY-PRIMM-P1 / -P2 | the final fight's phase stills | 2 | giant Primm, hero a sixth of his arm | glaring | REDO (or crop the hero out in code) |
| 7 | RES-IRON | every Beefcake game | 5 | photoreal 3D render among painted cards | noticeable | REDO |
| 8 | CAP-WALL-PASTEL-PINK / -BLUE | Capital house fronts | 4 | green stripes from a bad slice | noticeable | FIX IN CODE |
| 9 | cap_pastelplaza_albedo | Capital plaza | 4 | tiling seam | noticeable | FIX IN CODE |
| 10 | DNA-SHEET-FILING-TOWERS-04 | every D.N.A. ghost queue | 4 | rope cut off in mid-air | noticeable | FIX IN CODE |
| 11 | BAS-G Feastforge | every Gourmand deck | 3 | flat blue vector style, wrong Path colour | noticeable | REDO |
| 12 | B-13 Hulking Hauler | Beefcake decks | 3 | same picture as B-26 The Carpool | noticeable | REDO |
| 13 | DUMP-SHEET-WINDOWS-05 / -06 | Dump houses | 3 | stray strip from the next cell | noticeable | FIX IN CODE |
| 14 | BST-ANTECHAMBER-SENTRY | Lab foe | 2 | visor reads as the Windows logo; sci-fi mecha | noticeable | REDO |
| 15 | STORY-REVEAL-KITCHEN | the Doppelganger reveal | 1 | giant chef, tiny hero | noticeable | REDO (or crop in code) |
| 16 | ICON-ITEM-FIELDBANDAGE (+ NPC-HESPER, STORY-EPI-WRINKLES) | items, Hesper | 3 | Red Cross emblem (protected) | minor | REDO optional |
| 17 | UI-CARDBACK/FRAME/PACK -N vs -R | Necrocrat / Refusemancer | 4 | two green Paths | minor | KEEP (colour-blind item) |
| 18 | TITLE-KEYART-NIGHT | title | 3 | "night" painted in daylight | minor | KEEP |
| 19 | BAS-B Powerhouse | Beefcake decks | 3 | flat vector style | minor | KEEP |
| 20 | Kit style drift (gym props, D.N.A. desk/stamp, Buffet cloche) | zones | 3 | glossy renders vs painted kits | minor | KEEP |
| 21 | NBR-04 Total Teardown | cards | 2 | flat comic look | minor | KEEP |
| 22 | GR-04 Food Fight | cards | 2 | twin chefs | minor | KEEP |
| 23 | N-06 Notary Wraith | cards | 2 | glyph-covered scroll | minor | KEEP |
| 24 | BST-CAPTAIN-SPOTLESS = BST-ENFORCER-CAPTAIN-SPOTLESS | bestiary | 2 | same picture twice | minor | KEEP |
| 25 | GAIN-SKY-NOON | unused | 1 | not a sky (a cottage scene) | minor | KEEP (rename) |

## Per category

- **Cards (356):** 7 flags - RES-IRON, BAS-G and B-13 REDO; BAS-B, NBR-04, GR-04, N-06 KEEP. No hand or anatomy problems found (B-02, B-16,
  P4-02, GB-01, B-09, C-14 checked closely); no pixel duplicates (hash check); Flex appears on no card. `notes_cards.md`.
- **Portraits and cut-ins (129):** the five species flips above; everything else consistent (every CUT-* cut-out, NPC-ELDER and NPC-PLAYER
  variants, Primm's three phases, V-BEETSWORTH_PROUD).
- **Sprites (105 walk sets):** all match their portraits. KEEP.
- **Story stills, loading, key art (55):** the two scale errors; TITLE-KEYART-NIGHT naming. Everything else KEEP.
- **Battleboards and maps (44):** all KEEP (BB-S-GOUR's sushi counter is a minor style drift for the Buffet).
- **UI and vendor stages (75):** all KEEP; the N/R green pair noted.
- **Zone kits, environment, decals (603):** 4 noticeable FIX IN CODE (pastel walls, queue-post rope, Dump windows), style-drift note.
  `notes_world.md`.
- **Textures, skies, backdrops (126):** the plaza seam; GAIN-SKY-NOON naming.
- **Bestiary (125):** BST-ANTECHAMBER-SENTRY REDO; the duplicated Spotless picture.
- **Icons (195) and cosmetics (40):** the bandage emblem; hats have a heavier outline than the hero sprite (KEEP).

## Batch 14 (ready to generate)

`docs/art/batch14_nov9.csv`, 12 rows / 17 files, sorted by severity x visibility: Sable x2, Tonic x2, Brannoch x2, RES-IRON, Fenwick,
Threadwell, Primm P1/P2, BAS-G, B-13, the Antechamber Sentry, the field bandage (optional), the kitchen reveal. Each row carries a ready
description and the reference images to attach. **Attach the base portrait for every expression variant** - that missing reference is what
produced the species flips. After importing a variant set, remove its id from `Portraits.HELD_EXPRESSIONS` (`core/data/portraits.gd`).
