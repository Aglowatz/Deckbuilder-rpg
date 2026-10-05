# Hero and cosmetics (Brief 12, Part E)

## The hero
The armored Knight is gone. The playable hero is the **KayKit Rogue** (CC0, already in the project) with every weapon and the cape hidden: a leather tunic, belt and boots, no armor. It shares
KayKit's animation rig (Idle, Walking_A, Running_A, Interact, Cheer, ...), so no retargeting was needed. `HeroModel` (world/character/hero_model.gd) builds it and puts the cosmetics on the **head bone** (hat)
and the **chest bone** (cloak). Equipment (helm, armor, ...) stays stat-only and is never drawn.
No new asset pack was added. Alternatives considered: Quaternius modular characters (would need a download, a new rig and retargeting) - kept as a later option for a custom character.

## Cosmetics (purely visual)
Two slots, HAT and CLOAK, each with a dye (12-colour palette, the trim colour is derived). Data: `core/cosmetics/` (`CosmeticCatalog`, `CosmeticState`, `Dye`). Saved in the campaign (`Session.cosmetics`);
old saves load with the look marked as chosen. Meshes: `world/character/cosmetic_meshes.gd` (builders) on top of `ProcMesh` (a tiny flat-shaded low-poly mesh builder).

| Hat | Made how |
|---|---|
| Wizard Hat | the KayKit Mage's own hat mesh (CC0), tinted by the dye, scaled to the Rogue |
| Wide-Brim Hat, Bobble Beanie, Tricorn, Crown of Leaves, Chef's Toque, Bowler, Top Hat, Cat-Ear Band, Sun Straw Hat, Party Cone, Mushroom Cap | procedural (ProcMesh: frustums, rings, spheres, boxes), built to the style guide palette |

| Cloak | Made how |
|---|---|
| Short Cape, Traveler's Cloak, Hooded Cloak, Tattered Cloak (jagged hem), Royal Mantle (fur collar, gold clasp), Patchwork Cloak (per-segment colours), Poncho (front drape), Leaf Cloak (overlapping leaves), Starfall Cloak (stars), Long Scarf-Cape (two strands) | procedural, a chain of 2-5 pivots each |

**Secondary motion:** `CloakSway` bends the pivot chain: back when the hero moves forward, sideways when strafing or turning, a small flutter when idle; each segment is a lagged spring so the cloth whips.

## Wardrobe, new game, tailor
`WardrobeScreen` (hotkey **T**, HUD button): rotating `HeroPreview`, owned hats and cloaks, dye swatches, applied and saved at once. At the start of a new game it opens in starter mode (3 hats, 3 cloaks) before the first story line.
The tailor (Part F) reuses the preview for try-on.

## Honest limits
The head mesh includes the Rogue's hair, so hats sit over it (a hat that is smaller than the hair block pokes through); faces are the stock KayKit faces (no expressions); cloaks are plain coloured cloth (no texture).
A custom character with a hat-friendly bald head, facial expressions and painted cloth is on the Blender wish list (docs/art/style_guide.md, section 12).
