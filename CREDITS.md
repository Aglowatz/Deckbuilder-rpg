# Credits

Tracks the license/attribution for every non-original asset in `assets/`. Add an entry here
in the same commit that adds the asset.

## Format

For each asset:

```
- **<file path>** — <name/description>
  - Author: <author/creator>
  - Source: <URL>
  - License: <license name, e.g. CC0, CC-BY 4.0, OFL>
  - Notes: <attribution text required by license, modifications made, etc.>
```

## Art

- **assets/KayKit-Medieval-Hexagon-Pack-1.0/** - Medieval Hexagon Pack (hex tiles, buildings, nature and props; the town and dungeon-map scenery)
  - Author: Kay Lousberg (KayKit)
  - Source: https://github.com/KayKit-Game-Assets/KayKit-Medieval-Hexagon-Pack-1.0 (also https://kaylousberg.itch.io)
  - License: CC0 (license file in the folder)
  - Notes: only the files actually used were copied; the albedo of the grass tile is tinted at runtime. Added 2026-09-26.
- **assets/KayKit-Character-Pack-Adventures-1.0/** - Character Pack: Adventurers (Knight, Mage, Rogue_Hooded, Barbarian, Rogue with animations)
  - Author: Kay Lousberg (KayKit)
  - Source: https://github.com/KayKit-Game-Assets/KayKit-Character-Pack-Adventures-1.0
  - License: CC0 (license file in the folder)
  - Notes: used for the player character and town NPCs (including the 4 corrupted NPCs, Part E,
    tinted per element - no new pack, just one more file from this one: Rogue.glb). Added
    2026-09-26, Rogue.glb added 2026-09-28.
- **assets/KayKit-Dungeon-Remastered-1.0/props/chest_gold.glb** - a treasure chest prop, same
  low-poly family as the other KayKit packs already in use
  - Author: Kay Lousberg (KayKit)
  - Source: https://github.com/KayKit-Game-Assets/KayKit-Dungeon-Remastered-1.0 (also https://kaylousberg.itch.io)
  - License: CC0 (license file in the folder)
  - Notes: only this one prop was copied, for the town's hidden-nook secret. Added 2026-09-27.

- **assets/icons/game-icons/** - game-icons.net silhouettes used as placeholder card art, item
  icons (Part F), equipment icons (New brief, Part B) and UI glyphs
  - Authors: Lorc, Delapouite, Sbed, Skoll, Carl Olsen, Cathelineau, Faithtoken (each icon sits in its author folder)
  - Source: https://game-icons.net (repository https://github.com/game-icons/icons)
  - License: CC BY 3.0 (https://creativecommons.org/licenses/by/3.0/); license.txt kept in the folder
  - Notes: "Icons made by Lorc, Delapouite, Sbed, Skoll, Carl Olsen, Cathelineau and Faithtoken from game-icons.net". Rendered white-on-transparent by a shader; no other modification. Added 2026-09-26, extended 2026-09-28, re-picked for the 10 new equipment pieces 2026-09-28 (Caro Asercion's one icon, warlord-helmet, is no longer used by anything and was dropped from the credited-authors list).

## Audio

All sound effects are from Kenney (https://kenney.nl), license CC0 (each pack folder keeps its License.txt). Added 2026-09-26.

- **assets/audio/kenney_ui-audio/** - UI Audio (Kenney) - https://kenney.nl/assets/ui-audio
- **assets/audio/kenney_interface-sounds/** - Interface Sounds (Kenney) - https://kenney.nl/assets/interface-sounds
- **assets/audio/kenney_impact-sounds/** - Impact Sounds (Kenney) - https://kenney.nl/assets/impact-sounds
- **assets/audio/kenney_rpg-audio/** - RPG Audio (Kenney) - https://kenney.nl/assets/rpg-audio
- **assets/audio/kenney_casino-audio/** - Casino Audio (Kenney) - https://kenney.nl/assets/casino-audio (card sounds)
- **assets/audio/kenney_music-jingles/** - Music Jingles (Kenney) - https://kenney.nl/assets/music-jingles (victory and defeat stingers)

Town, battle and title music are generated in code by `app/music_synth.gd` (original, no third-party audio).

## Fonts

- **assets/fonts/Cinzel/Cinzel-Variable.ttf** - Cinzel (titles)
  - Author: Natanael Gama
  - Source: https://fonts.google.com/specimen/Cinzel (https://github.com/google/fonts/tree/main/ofl/cinzel)
  - License: SIL Open Font License 1.1 (OFL.txt in the folder)
- **assets/fonts/AlegreyaSans/** - Alegreya Sans (body text)
  - Author: Juan Pablo del Peral, Huerta Tipografica
  - Source: https://fonts.google.com/specimen/Alegreya+Sans (https://github.com/google/fonts/tree/main/ofl/alegreyasans)
  - License: SIL Open Font License 1.1 (OFL.txt in the folder)

## Third-party code / tools

- **addons/gut** — Unit testing framework for Godot
  - Author: Butch Wesley (bitwes)
  - Source: https://github.com/bitwes/Gut
  - License: MIT

## Brief 5: the D.N.A. zone (added 2026-10-01)

- **assets/kenney-furniture-kit/** - Furniture Kit 2.0 (desks, chairs, monitors, cabinets, kitchen, lounge, plants)
  - Author: Kenney (www.kenney.nl)
  - Source: https://kenney.nl/assets/furniture-kit
  - License: CC0 (license file in the folder)
  - Notes: only the ~85 models actually used were copied; colours are graded at runtime (`DnaMaterials`) to the zone's cold-green palette.
- **assets/kenney-graveyard-kit/** - Graveyard Kit 5.0 (animated zombie/skeleton/ghost characters, coffins, crypts, urns, lanterns)
  - Author: Kenney (www.kenney.nl)
  - Source: https://kenney.nl/assets/graveyard-kit
  - License: CC0 (license file in the folder)
  - Notes: the three roaming enemy designs use its animated characters (tinted); coffins/urns/crypt dress the Records Basement.
- **assets/KayKit-Halloween-Bits-1.0/** - Halloween Bits 1.0 (decorated coffin, skull candle, candles)
  - Author: Kay Lousberg (KayKit)
  - Source: https://github.com/KayKit-Game-Assets/KayKit-Halloween-Bits-1.0 (also https://kaylousberg.itch.io)
  - License: CC0 (license file in the folder)
  - Notes: only the files used were copied.
- **assets/icons/game-icons/** - extra game-icons.net silhouettes (zombie, tie, ticket, party popper, folder, phone, VHS, cassette, disc, friends, egg, joystick...) for the Necrocrat cards and the matching minigame
  - Author: Delapouite, Lorc, Caro Asercion, Darkzaitzev (game-icons.net)
  - Source: https://game-icons.net
  - License: CC BY 3.0 (license.txt in the folder)
  - Notes: attribution required: icons by Delapouite, Lorc, Caro Asercion and Darkzaitzev via game-icons.net.

## Brief 6: the Gainlands (added 2026-10-02)

No new third-party asset packs were needed. The Gainlands reuses packs that are already credited above:
- **KayKit Medieval Hexagon Pack** (CC0): windmills (spinning sails), the tavern (Swole Station), mountains, trees, rocks, clouds.
- **KayKit Character Pack: Adventurers** (CC0): the Beefcake NPCs, throwers, portal rippers and the Flexing Brute (Barbarian, with its Throw / Interact / Running / Lie animations), Mage, Rogue.
- **KayKit Dungeon Remastered** (CC0): the hidden chest prop.
- Everything else (hamster wheels, boulder-and-log gym equipment, the hot tub, stalls, stage, arch, Leg Day gate, energy pipes, floating islands, terrain, the Golem and Sprite enemy models) is original procedural geometry built in code from primitives (`world/gainlands/`), and the `gainlands` music track is generated in code by `app/music_synth.gd`.
- game-icons.net (CC BY 3.0, credited above): no new icons were added for the Gainlands cards (they fall back to the generic card art).

## Brief 7: the Endless Buffet (added 2026-10-02)

- **assets/kenney-food-kit/** - Food Kit 2.0 (200 CC0 3D food models: broccoli, cauliflower, cakes, cheese, pancakes, cutlery, pots, pie, donuts, sausages, pickups...)
  - Author: Kenney (www.kenney.nl)
  - Source: https://kenney.nl/assets/food-kit
  - License: CC0 (license file in the folder)
  - Downloaded 2026-10-02. Used at 2-13x scale as the giant food of the Endless Buffet; golems are assembled from its pieces.
- **assets/KayKit-Restaurant-Bits-1.0/** - Restaurant Bits 1.0 (kitchen counters, stoves, fridges, oven, pots, tables, studio wall, food props)
  - Author: Kay Lousberg (KayKit)
  - Source: https://github.com/KayKit-Game-Assets/KayKit-Restaurant-Bits-1.0 (also https://kaylousberg.itch.io)
  - License: CC0 (license file in the folder)
  - Downloaded earlier into `_asset_library/`; first used here (2026-10-02) for the Grand Pantry and the Dinner in a Dash set.
- The jelly pads, crouton rafts, lazy susan, layer-cake buildings, golem gates, signs, the Gravy River and the table rim are original procedural geometry (`world/buffet/`). The `buffet` music track and the "boing" / "splash" / "ding" sound effects are generated in code (`app/music_synth.gd`); no recorded audio was added.

## Brief 8: the Verdant Dump (added 2026-10-02)

- **assets/kenney-nature-kit/** - Nature Kit 2.1 (trees, bushes, crops, flowers, rocks, logs, mushrooms, fences)
  - Author: Kenney (www.kenney.nl) - Source: https://kenney.nl/assets/nature-kit - License: CC0 (license file in the folder)
- **assets/kenney-survival-kit/** - Survival Kit (barrels, buckets, crates, metal panels, workbench, tool props)
  - Author: Kenney (www.kenney.nl) - Source: https://kenney.nl/assets/survival-kit - License: CC0 (license file in the folder)
- **assets/kenney-car-kit/** - Car Kit (sedans, vans, trucks, tractors, tyres and debris, used as rusted wrecks and junk)
  - Author: Kenney (www.kenney.nl) - Source: https://kenney.nl/assets/car-kit - License: CC0 (license file in the folder)
- **assets/kenney-cube-pets/** - Cube Pets 1.0 (animated animals: boar, deer as goat, pig, cat as raccoon)
  - Author: Kenney (www.kenney.nl) - Source: https://kenney.nl/assets/cube-pets - License: CC0 (license file in the folder)
- All downloaded 2026-10-02; only the models actually used were kept in `assets/`. The scrap barns, windmills, junk piles, compost heaps, vine bridges, beanstalks, trash chutes, shrine, fair stage and the three enemy models are original procedural geometry (`world/heap/`); the `heap` music track is generated in code (`app/music_synth.gd`).

- **assets/icons/game-icons/** (brief 9 additions: carnival-mask, prisoner, fur-shirt, strong-man, biceps, tree-roots, plant-roots, root-tip, mushrooms-cluster, gingerbread-man, bubbling-flask, pirate-cannon, imprisoned, stamper, open-folder, lotus) - extra game-icons.net silhouettes for the zone dungeons' enemies and cutscenes.
  - Author: Delapouite and Lorc (game-icons.net)
  - Source: https://game-icons.net (repository https://github.com/game-icons/icons)
  - License: CC BY 3.0 (https://creativecommons.org/licenses/by/3.0/)
  - Notes: attribution required: icons by Delapouite and Lorc via game-icons.net. Added 2026-10-04.
