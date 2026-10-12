# Hero and cosmetics (painted sprite version, world rollout Part C)

The hero is the painted 2.5D sprite `SPR-PLAYER-*` (docs/art/world_look_test.md): five drawn directions (FRONT, FRONTSIDE, SIDE, BACKSIDE, BACK, the art looks LEFT and the other
side is mirrored), a four-frame walk strip per direction and an idle. The default look is the **dark teal hooded cloak, no hat**. The old 3D Rogue (`HeroModel`) is only the
fallback when the sprite art is missing and the look of the 3D tailor and her mannequin. There is no character-design screen at the start of a game any more.

## What is wearable
Two slots, **hat** and **cloak**; data in `core/cosmetics/` (`CosmeticCatalog`, `CosmeticState`, `Dye`, `CosmeticMigration`), saved in the campaign (`Session.cosmetics`).

| Item | Id | Art name | Price | Opens at |
|---|---|---|---|---|
| Wide-Brim Hat | `hat_wide_brim` | WIDEBRIM | 90 | from the start |
| Chef's Toque | `hat_chef` | CHEF | 110 | from the start (also a Buffet chest) |
| Bowler Hat | `hat_bowler` | BOWLER | 140 | from the start (also a Capital chest) |
| Tricorn | `hat_tricorn` | TRICORN | 220 | level 5 |
| Wizard Hat | `hat_wizard` | WIZARD | 280 | one zone freed |
| Crown of Leaves | `hat_leaf_crown` | LEAFCROWN | 360 | two zones freed (also the Verdant Dump hidden chest) |
| Patchwork Cloak | `cloak_patchwork` | PATCHWORK | 210 | level 4 |
| Red Cape | `cloak_red_cape` | REDCAPE | 260 | one zone freed (also the Four-Seal Vault's reward) |
| Tattered Cloak | `cloak_tattered` | TATTERED | 180 | two zones freed (also the Gainlands hidden chest) |
| Royal Mantle | `cloak_royal` | ROYAL | 900 | after Primm (also his drop) |

The clothing vendor, Pip Threadwell, sells all ten. Items whose art is not imported yet show as **"arriving soon"** in the shop (Try and Buy are disabled and the session refuses
the purchase) and cannot be worn from the wardrobe; nothing breaks while art is missing.

## The art to make
- **Hats** `COS-HAT-<NAME>-<FRONT|FRONTSIDE|SIDE|BACKSIDE|BACK>.png`: transparent, one hat, **its bottom-centre is where it meets the head** (the game puts that point on the
  head anchor of the hero's current frame, sinks it a little and mirrors it for the right-hand directions). Size is free (it is scaled from the head's width); 640 px wide is plenty.
  The side directions are drawn looking LEFT like the body. Fit tweaks (width, sink, nudges per direction) go in `assets/art/cosmetics/hats/fit.json`.
- **Cloaks** `SPR-PLAYER-CLOAK-<NAME>-<DIR>_<IDLE|WALK>.png`: a whole alternate player sprite set, exactly like the `SPR-PLAYER-*` files (single idle per direction, a 4-frame
  strip for each walk), same pose, hair and clothes, only the cloak changes. Equipping a cloak swaps the whole set. The default set is the dark teal cloak.
- Both can sit in `Approved_WorldTest` or a new `Approved_Cosmetics` folder: `bash tools/import_cosmetics.sh` copies matching files (read-only on the Drive), slices, trims,
  measures the head anchors of every frame and the cloak's hue, re-imports and prints which items are still "arriving soon".

## How it is drawn
- `WorldSprite` (world/sprites): the hero card; `set_character("PLAYER_CLOAK_<NAME>")` swaps the set (frames the cloak set lacks fall back to the default's), `set_hat("<NAME>")`
  lays a second card on the head, `set_dye(color)` recolours.
- **Hat placement**: `tools/sprite_anchors.gd` measures, for every frame of every sprite set, the head anchor (crown centre, top row, head width). The hat card is placed from the
  anchor of the frame that is showing, so it follows the head through every walk and idle frame; its size is the head's width times the hat's `width` fit (default 1.5).
- **Dye = a recolour of the cloak**: the shader finds the cloak by its hue (the sprite set's `cloak_hue`, measured from the back view where the cloak covers the figure) and
  replaces it with the dye colour, keeping the painted shading, so hair, skin and boots stay as they are. "Natural" is the cloak as painted. There is no hat dye (a hat is one
  painted piece; recolouring it would need a per-hat mask): this is a change from the 3D wardrobe.
- `SpriteActor` is the node `TownPlayer.model` is: the scenes' effects (the bounce squash, the tumbles of the pads and slides, the mount's lift, the blink) drive it as they drove
  the 3D model.

## Old saves
A save from the 3D wardrobe loads in the default look. Every item that was **bought** is refunded as gold at its old price (a toast says how much), the free starter choices were
free, found items that still exist (the leaf crown, the tattered cloak, the royal mantle) stay owned and unequipped, and a found item that no longer exists is replaced
(the four-seals cloak by the red cape). `CosmeticMigration` has the old price table.
