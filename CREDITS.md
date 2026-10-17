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
  - Notes: "Icons made by Lorc, Delapouite, Sbed, Skoll, Carl Olsen, Cathelineau and Faithtoken from game-icons.net". Rendered white-on-transparent by a shader; no other modification. Added 2026-09-26, extended 2026-09-28, re-picked for the 10 new equipment pieces 2026-09-28 (Caro Asercion's one icon, warlord-helmet, is no longer used by anything and was dropped from the credited-authors list). Extended 2026-10-04 (Brief 10): 17 more icons by Delapouite and Cathelineau (castle, castle-ruins, broken-wall, portrait, shinto-shrine-mirror, scroll-quill, shattered-heart, peace-dove, nested-hearts, globe-ring, olive, book-cover, cyborg-face, guards, party-flags, old-king, nun-face) for Primm castle foes, its cutscenes and the ending. Extended 2026-10-05 (packs): fork-knife-spoon, sparkles (Delapouite), recycle, rainbow-star (Lorc), card-random (Faithtoken) for the card pack art. Extended 2026-10-05 (resource tray): crime-scene-tape, trash-can (Delapouite) for the Red Tape and Garbage coins; weight-lifting-up now marks Iron.

## Audio

All sound effects are from Kenney (https://kenney.nl), license CC0 (each pack folder keeps its License.txt). Added 2026-09-26.

- **assets/audio/kenney_ui-audio/** - UI Audio (Kenney) - https://kenney.nl/assets/ui-audio
- **assets/audio/kenney_interface-sounds/** - Interface Sounds (Kenney) - https://kenney.nl/assets/interface-sounds
- **assets/audio/kenney_impact-sounds/** - Impact Sounds (Kenney) - https://kenney.nl/assets/impact-sounds
- **assets/audio/kenney_rpg-audio/** - RPG Audio (Kenney) - https://kenney.nl/assets/rpg-audio
- **assets/audio/kenney_casino-audio/** - Casino Audio (Kenney) - https://kenney.nl/assets/casino-audio (card sounds)
- **assets/audio/kenney_music-jingles/** - Music Jingles (Kenney) - https://kenney.nl/assets/music-jingles (victory and defeat stingers)

<!-- sfx-credits:start (written by tools/sfx_build.js) -->
**assets/audio/sfx/** - the sound-effects pass (2026-10-16): 191 files, every one CC0, processed (trimmed, filtered, levelled, looped) by `tools/sfx_build.js`; the per-file source, author and licence are in `docs/audio/sfx_sources.md`.

- Kenney (https://kenney.nl), CC0: casino-audio (https://kenney.nl/assets/casino-audio), impact-sounds (https://kenney.nl/assets/impact-sounds), rpg-audio (https://kenney.nl/assets/rpg-audio), ui-audio (https://kenney.nl/assets/ui-audio).
- Freesound (https://freesound.org), sounds released under Creative Commons 0 (CC0 1.0), by: _natiKatz (freesound.org/s/223375); ani_music (freesound.org/s/632477); applauseav (freesound.org/s/239639); beatmad (freesound.org/s/201936); Breviceps (freesound.org/s/447918); brktkrgll (freesound.org/s/856167, freesound.org/s/856169); brokenmachinery (freesound.org/s/730078); bsmacbride (freesound.org/s/108524); Dalesome (freesound.org/s/352719); deathpie (freesound.org/s/19245); eddies2000 (freesound.org/s/448474); EminYILDIRIM (freesound.org/s/535361); eyesonlegs (freesound.org/s/464302); I.fekry (freesound.org/s/470710); kev_durr (freesound.org/s/383226); keweldog (freesound.org/s/181773); Kodack (freesound.org/s/256307); ludde44 (freesound.org/s/170311); MilkyGacha (freesound.org/s/467721); Nightflame (freesound.org/s/368615); philberts (freesound.org/s/71513); qubodup (freesound.org/s/59988, freesound.org/s/59995, freesound.org/s/60013); roboroo (freesound.org/s/436791); SomeoneCool15 (freesound.org/s/423767); Valenspire (freesound.org/s/699494).
- 11 sounds generated with ffmpeg for this game (original, CC0).
<!-- sfx-credits:end -->

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

## Music and stings (assets/audio/music, assets/audio/stings)

- **assets/audio/music/** and **assets/audio/stings/** - the game's soundtrack: 123 music cues (loops, story cues, motif references) and 21 musical stings, original compositions for this game (catalogue: `data/source/music_list.csv`; ID registry: `data/audio/audio_registry.json`)
  - Author: the project's composer (this repo's designer), rendered with LMMS 1.2.2 from selected sampled and modeled instruments
  - Sample sources (all CC0 1.0): VSCO 2 Community Edition (Sam Gossner, Simon Dalzell; https://github.com/sgossner/VSCO-2-CE), Karoryfer and Virtuosity recordings, plus original modeled organ, banjo and synth patches. Pinned revisions, hashes and licenses: `DEPENDENCIES.md` and the manifests of the Drive folder `Approved_Audio`.
  - License: the compositions are original; every sample set is CC0, so no attribution is required (listed here for provenance). Imported 2026-10-12 (copy-only from the Drive folder; long story cues converted to OGG).
