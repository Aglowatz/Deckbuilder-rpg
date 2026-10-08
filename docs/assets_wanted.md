# Assets wanted (nice-to-have, not needed for the proof of concept)

Nothing in the Endless Buffet is blocked on a missing asset; everything uses direct-download CC0 packs
(Kenney Food Kit, KayKit Restaurant Bits) plus procedural geometry. Ideas that would lift it further, if you
want to spend time on them:

- **Animated food-golem characters** (rigged, with walk/attack cycles) to replace the procedural Meatloaf Golem,
  Gelatin Sentinel and gate guardians. No suitable CC0 rigged food-monster pack was found on a direct-download
  site; itch.io has many low-poly monster packs (search "low poly monsters CC0" at https://itch.io/game-assets/free/tag-3d),
  but each needs its license page checked (and often a login to download) before use.
- **Recorded audio**: a real "boing", gravy "splash" and diner "ding" (OpenGameArt / Kenney Digital Audio; CC0) and a recorded
  kitchen-ambience loop. The zone currently uses sounds and music synthesized in code.
- **A rounded display font** (e.g. Fredoka, Google Fonts, OFL) for the zone's signage, which currently uses the game's title font.

## Elder Maren (tortoise)
- A stylized upright **tortoise** character (female, elderly, kind, a shell with a patched cloth wrap, a kettle or a pie) in the KayKit-adventurers scale, with Idle/Walk animations. Until then Maren is the Mage model with a code-drawn shell (`world/tortoise_kit.gd`). Portrait NPC-ELDER already exists.

## Path-ology Lab (postgame)
- **MAP-LAB** (3:2 painted dungeon map) and **BB-LAB** (16:9 battleboard): currently code-drawn placeholders (`tools/make_lab_placeholder_art.gd`). Replace the two files in `assets/art/maps/` and `assets/art/battleboards/` with the real art under the same IDs; re-fit the node coordinates in `data/dungeons/map_layout.json` (`D-LAB`) with `bash tools/map_fit_sheet.sh D-LAB`.
- Portraits for **NPC-RESCUER** (hooded / revealed) and **NPC-SIPHON** (neutral / fascinated / furious) are still code-drawn silhouettes (`docs/art/` portraits list).
- A hatch model for the forest entrance (currently a code-drawn steel disc with a cyan ring).
