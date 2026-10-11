# NPC 3D models vs. portraits: options

**Status: research only. Nothing was remodelled or changed in the game.** The decision is yours.

## The problem

The world uses the KayKit Adventurers humanoids (`Mage`, `Barbarian`, `Rogue`, `Rogue_Hooded`, `Knight`, via `ModelKit.character`) for every NPC, while the approved dialogue portraits are mostly animals and creatures: tortoise, bear, fox, frog, walrus, ogre, minotaur, yeti, rhinoceros, skeleton, ghosts, Persian cat, otter, rabbit, opossum, stag-headed druid, hedgehog, birdfolk, weasel, mole, gnome and others. The full per-NPC table (portrait species vs. 3D model) is in `docs/progress.md`, section "NPC dialogue portraits".

## What I found (free, with licences)

I could not find a free CC0 or CC-BY pack of *anthropomorphic* animal characters (animal heads on humanoid bodies) in our low-poly style. What exists:

| Source | What it is | Licence | Notes |
|---|---|---|---|
| [KayKit Skeletons Character Pack](https://kaylousberg.itch.io/kaykit-skeletons) (Kay Lousberg) | Rigged, animated low-poly skeletons (the free tier has 4 characters; the paid tier more) | CC0 | Same artist and rig as the Adventurers we already use, and the same animations apply. Fits the skeleton NPCs directly (Clerk Ledgerbone, Mortimer Grimsby). Not animals. |
| [KayKit Character Animations](https://kaylousberg.itch.io/kaykit-character-animations) | Free animation set for all KayKit rigs | CC0 | Already compatible with everything we use. |
| [Quaternius: LowPoly Animated Animals](https://quaternius.itch.io/lowpoly-animated-animals) | 6 animated animals (idle, walk, run, jump, death) | CC0 | Quadrupeds, not upright. FBX/OBJ/Blend (convert to glTF in Blender). Useful for pets and wandering animals, not for talkative NPCs. A commenter reports only some animations present: check the files. |
| [Quaternius: LowPoly Animated Monsters](https://quaternius.itch.io/lowpoly-animated-monsters) | Bats, dragons, skeletons, slimes and other monsters | CC0 | Gives the ogre/troll/yeti-type look partly (big monsters); the free pack has no goblin (Patreon only). FBX/OBJ/Blend. |
| [Quaternius: Ultimate Monsters (Sketchfab)](https://sketchfab.com/3d-models/ultimate-monsters-pack-fd72e114d119488da71fe3a16f216c4f) | About 50 animated monsters, glTF included | Listed as CC0 in the description but "CC Attribution" in the licence field: **check the download page before use**; carries a "NoAI" notice | The best candidate for troll, yeti, minotaur-ish and ogre NPCs if the licence is confirmed. |
| [Quaternius: LowPoly RPG Characters (OpenGameArt)](https://opengameart.org/content/lowpoly-rpg-characters) | 6 rigged fantasy humanoids (wizard, warrior, rogue, monk, ranger) | Free for personal and commercial use (confirm CC0 on the page) | Same humanoid problem as KayKit, only more variety. |
| [Textured Cute Monster Pack (OpenGameArt)](https://opengameart.org/content/textured-cute-monster-pack) | 21 cute animated monsters (crabs, penguins, mushrooms, bees ...) | Free for personal and commercial use (confirm licence on the page) | Cute style matches our tone; mostly non-humanoid. |
| Kenney Cube Pets (already in `assets/kenney-cube-pets`) | Blocky animals | CC0 | Already in the project. Static or lightly animated; good for companion animals (the Cave raccoon, Gristle's raccoon, Tilly's pets). Blocky, so it is a different style from KayKit. |
| [Open Game Art: Low poly animal pack (WIP)](https://opengameart.org/content/low-poly-animal-pack-wip) | A single dog head so far | CC0 | Not usable yet. |

**Paid but cheap (for comparison):** a [CGTrader pack of 25 anthropomorphic animal characters](https://www.cgtrader.com/3d-model-packs/anthropomorphic-animal-character-pack-low-poly-assets) (wolf, lion, tiger, fox, squirrel, boar and more, rig-ready) is about $47.50 under a royalty-free licence. Unity Asset Store has several "toon humanoid animal" packs too. Both would need conversion and a licence read before use; the style would not match KayKit exactly.

Poly Pizza (poly.pizza) is worth a manual search with the CC-BY filter: it aggregates CC0 and CC-BY low-poly models, but my search did not surface a usable humanoid animal there. I did not verify anything on Poly Pizza itself.

## Recommended path

1. **Short term (no new models):** use the interim options below so every NPC is at least recognisable at a glance.
2. **Medium term:** add the **KayKit Skeletons** pack (CC0, same rig, zero friction) for the skeleton NPCs, and confirm the licence of the **Quaternius Ultimate Monsters** glTF pack for the big creatures (ogre, troll, yeti, minotaur, rhino).
3. **Long term, for the animal NPCs:** either commission or generate a small set of one humanoid body with swappable animal heads (a head kit: tortoise, bear, fox, frog, walrus, cat, otter, rabbit, opossum, hedgehog, bird, weasel, mole). A shared body and rig keeps animations free and the art style consistent. This is the only route that matches the portraits closely; none of the free packs does.

## Quick interim option (no new art, small code)

All of these work with what is already in the game (`HeroModel` already attaches hats and cloaks to bones with `BoneAttachment3D`, `CosmeticMeshes` builds simple primitive meshes):

- **Species props on the existing model** (a few primitives per species, attached to the head and spine bones): round ears for bear, otter and mouse; long ears for rabbit; pointed ears and a tail for fox, cat and weasel; a stag-antler crown for the stag-headed druid; a small shell backpack for the tortoise (Elder Maren); a bird beak and feathered cap for the wren; spikes for the hedgehog; a round hat and big moustache for the walrus; a snout cone for the opossum and mole.
- **Colour:** tint the skin/clothes material per NPC to the portrait's palette (frog green, fox orange, cat grey, ghost translucent and bluish, skeleton bone white). The ghosts only need an alpha + glow shader, which `StyleRig` can already do.
- **Scale and silhouette:** scale big species (Barbarian-based ones: bear, walrus, minotaur, yeti, ogre, troll) up 1.2 to 1.5x and tiny ones (mouse tailor, hedgehog) down to about 0.75x with a larger hat.
- **Name plates and portraits already carry the species**, so this only has to make the 3D figure not contradict it.

Cost estimate: one afternoon for a generic `SpeciesProps` helper plus a data table (NPC id to species, props, tint, scale), and tests that every NPC id with a species has an entry. It could be shipped without touching any art pipeline.
