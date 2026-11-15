# Path icon style guide (The Wayward Path)

Written Nov 14 2026 (Fable Nov 14, Part 4). **One icon per Path, everywhere.** The four icons below are the ones already on every card
frame and energy orb; this guide makes them the only symbols a Path is ever shown by. The sheet is `docs/art/path_icon_sheet.png`; every
place a Path symbol appears is listed in `docs/art/path_icon_inventory.csv`. In code the table is `PathIcons` (`core/data/path_icons.gd`);
`IconArt.ENERGY_IDS` is the same table and a test keeps them equal.

## The four icons

| Path | Canonical file | Shape | Meaning | Main colour | Accent |
|---|---|---|---|---|---|
| **Beefcake** | `assets/art/icons/ICON-ENERGY-B.webp` | a flexed arm, gold, bent up to the left, on a red disc in a gold rim | strength; the people who keep the lights on | red `#B4281C` | gold `#E0A030` |
| **Gourmand** | `assets/art/icons/ICON-ENERGY-G.webp` | a chef's hat (a tall white toque, three puffs), on a cream disc in a copper rim | the kitchens that feed the kingdom | cream `#EBD2AE` | copper `#C06A3A` |
| **Refusemancer** | `assets/art/icons/ICON-ENERGY-R.webp` | a green leaf inside three rust-orange recycling arrows, on a mossy green disc in a rust rim | waste turned into harvest | moss green `#5E7A2E` | rust `#B5552D` |
| **Necrocrat** | `assets/art/icons/ICON-ENERGY-N.webp` | a pale skull facing front, wrapped in green ghost-flame, on a dark slate disc in a cracked stone rim | the Department that looks after the dead | ghost green `#58B02E` | slate `#3A3F3C` |
| *Colorless / general* | `assets/art/icons/ICON-ENERGY-GENERIC.webp` | a plain grey stone disc, no symbol | energy any card can use; cards of no Path | stone `#9A9590` | `#4C4441` |

The source files are 512 px; the importer writes 24 to 128 px copies (`ICON-ENERGY-B_48.webp`). Always load through `IconArt` so the
right size is picked.

## Outline and background

- The icon is **always the whole medallion**: symbol, disc and rim together. Never the symbol cut out of its disc, and never the
  symbol redrawn on a different shape (a shield, a banner field, a hexagon).
- The rim is the icon's outline. No extra stroke, glow ring or drop shadow is added in the UI; in the 3D world a sign may put the
  medallion on a plain lit board.
- It sits on any background without a plate. On a busy or light background give it clear space of a quarter of its width.
- When a **painted picture** shows a Path's sign (a banner, a crest on a door, a carving), the painter paints the same symbol in the
  same colours: the gold arm on red, the white chef's hat on cream and copper, the leaf in three arrows on moss green, the skull in
  green flame on slate. The medallion's rim may become the picture's own frame (a banner's border, a ring carved in stone).

## Sizes

- **Minimum 24 px** at 1080p for the coloured icon (the cost pips on a small card). Below 24 px use the Path's main colour as a dot.
- Common sizes: 24 (cost pips, deck racks), 28 (card frame corner), 48 to 56 (filters, settings), 72 (Path choice), 128 and up
  (signs, title cards, the ending).
- In the 3D world a sign's icon is at least 0.4 m across at eye height.

## Coloured and monochrome

- **Coloured (the default):** cards and costs, energy, filters, the Deck Station, shops, packs, the HUD, the map, quest text, feats,
  the glossary, signs, banners, the ending.
- **Monochrome (a grey copy of the same medallion, never a different drawing):** a Path that is locked, disabled or not yet met
  (a greyed filter, a locked pack's hint, an unlit plinth). Made in code by desaturating the canonical file; no separate art.
- The old single-colour silhouettes (`assets/icons/game-icons/...`: a viking head, a tree face, a stamp, a flame, a drop) are **not**
  the monochrome version and are no longer used for a Path.

## More than one Path

- **Two Paths** (a dual-Path card, an Alchemist recipe): both medallions side by side at the same size, the card's first Path on the
  left. Never a blended or split medallion.
- **All four** (the royal crest, the Wayweaver arms, the Old Kingdom's banner, the vault's core, the fountain): a ring of four
  medallions read **clockwise from the top: Beefcake, Gourmand, Refusemancer, Necrocrat**. In a row: the same order left to right.
  In words: "an arm, a chef's hat, a leaf and a skull".
- **Colorless** is the plain stone disc. It never joins the ring of four.

## What an icon must never be replaced with

| Never use for the Path | Why it exists | What to use |
|---|---|---|
| a dumbbell, a barbell, a kettlebell, a flame | old banners and plinths; `BAS-B` placeholder art | the flexed arm |
| a ladle, a fork and knife, a cauldron, a water drop, a sun | old banners; `BAS-G` placeholder art; the pack fallback | the chef's hat |
| a single maple leaf, a sprout in a tin, a tree face | old banners and plinths; the ending's silhouettes | the leaf in three arrows |
| a rubber stamp, a tombstone, a crescent moon, a quill, a plain skull and crossbones | old banners and plinths; the ending's silhouettes | the skull in green flame |
| a star, a flame, a leaf and a moon in a ring | the royal crest as first painted (Fragments 3 and 4) | the ring of four medallions |
| the essence flask (`ICON-ESSENCE-*`) | it is the **crafting currency** of a Path | the flask only where essence is counted or spent |
| the resource (`ICON-RES-IRON`, `-INGREDIENT`, `-GARBAGE`, `-REDTAPE`) | it is what the Path's cards **make and spend** | the resource only for the resource (and as set dressing on a prop: a compost bin, a permit desk) |
| a boss's or a ruler's emblem | it marks the regime, not the Path | Primm's emblem only on the regime's own banners |

## Known mismatch to decide (not changed in this pass)

The UI's accent tint for Gourmand is blue (`UIStyle.AFFINITY_COLORS`, `#4A8FE0`) and for Necrocrat violet (`#9A5FC7`), while their
icons are cream and copper, and ghost green on slate. The tints colour text, borders and glows, never the icon. They are logged in
the inbox (Fable Nov 14) because changing them recolours the whole UI.
