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
- **assets/KayKit-Character-Pack-Adventures-1.0/** - Character Pack: Adventurers (Knight, Mage, Rogue_Hooded, Barbarian with animations)
  - Author: Kay Lousberg (KayKit)
  - Source: https://github.com/KayKit-Game-Assets/KayKit-Character-Pack-Adventures-1.0
  - License: CC0 (license file in the folder)
  - Notes: used for the player character and town NPCs. Added 2026-09-26.
- **assets/KayKit-Dungeon-Remastered-1.0/props/chest_gold.glb** - a treasure chest prop, same
  low-poly family as the other KayKit packs already in use
  - Author: Kay Lousberg (KayKit)
  - Source: https://github.com/KayKit-Game-Assets/KayKit-Dungeon-Remastered-1.0 (also https://kaylousberg.itch.io)
  - License: CC0 (license file in the folder)
  - Notes: only this one prop was copied, for the town's hidden-nook secret. Added 2026-09-27.

- **assets/icons/game-icons/** - game-icons.net silhouettes used as placeholder card art and UI glyphs
  - Authors: Lorc, Delapouite, Sbed, Skoll, Carl Olsen, Cathelineau (each icon sits in its author folder)
  - Source: https://game-icons.net (repository https://github.com/game-icons/icons)
  - License: CC BY 3.0 (https://creativecommons.org/licenses/by/3.0/); license.txt kept in the folder
  - Notes: "Icons made by Lorc, Delapouite, Sbed, Skoll, Carl Olsen and Cathelineau from game-icons.net". Rendered white-on-transparent by a shader; no other modification. Added 2026-09-26.

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
