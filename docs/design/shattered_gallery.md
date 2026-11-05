# The Shattered Gallery (S-GALLERY) - postgame dungeon

Overnight Nov 4-5, Part 5 (`docs/prompts/overnight_nov4.md`). Code: `core/dungeon/shattered_gallery.gd`; data: `data/dungeons/postgame_dungeons.json`
(the blueprint), `data/dungeons/dungeon_content.json` (foes, events, blurbs), `data/encounters/modifiers.json` (the Echo rules),
`core/dungeon/dungeon_rules.gd` (the stacking wing rules); tests: `tests/core/dungeon/test_shattered_gallery.gd`.

## Concept

After Primm falls, the mirrors of his castle keep showing the kingdom he wanted: perfect, cold and wrong. One of them, by the castle door,
cracks from the inside. Behind it is a gallery where every frame holds a "perfect" version of someone the Wanderer beat: an **Echo**. The
Echoes fight with their originals' decks, more HP and one twisted rule each, and the gallery's own mirror rules stack wing by wing. At the end,
in the mirror room, waits **The Perfect Copy**: the player's own deck, the player's own face, a little stronger.

It is meant to be unfair. It is the last thing in the game, for players who want a real wall.

## Entry

- **Quest "Cracks in the Glass"** (`cracks_in_the_glass`, side, Wren in the Crease, postgame only). Wren: the mirrors are still showing a
  kingdom that never was, and one cracked from the inside. One step: look into the cracked mirror at the castle door (flag
  `gallery_mirror_seen`). No hand-in: finishing it unlocks the dungeon (`DungeonCatalog.side_unlock_flag("S-GALLERY")`).
- **The mirror** (`CapitalScene._build_gallery_mirror`, `CapitalProps.gallery_mirror`): a tall gilt frame by the castle door, silvered glass
  with glowing cracks and a cold light, primitives only. It appears after Primm. Using it starts the quest for a player who never asked Wren,
  finishes it, and asks "Step through / Not yet". The run uses the Capital's zone HP (`Session.enter_mini_dungeon("S-GALLERY")`) and returns
  to the Capital.

## Structure (13 nodes)

| # | Node | Kind | Who / what | Twisted rule |
|---|---|---|---|---|
| 1 | The Cracked Frame | start | | |
| 2 | The Hall of Efficiency | battle | Echo of Vivienne Quota (Beefcake bruisers, 18 HP) | **Ahead of Schedule**: always goes first, draws an extra card on its first turn |
| 3 | The Weight of Glass | event | lift (5 damage, +1 attack boon) / leave (-2 max HP) / break (+150 gold, lose a card) | |
| 4 | The Iron Mirror | elite | Echo of Chancellor Clench (24 HP) | **Iron in the Glass**: starts with 3 Iron and two 1/1 Militia |
| 5 | The Gallery of Good News | battle | Echo of Percival Plume (20 HP) | **Even Better News**: an extra card each turn |
| 6 | The Valid Reflection | event | sign (+3 max HP, -1 attack) / refuse (4 damage) / forge Agnes's name (pay 100, heal 6) | |
| 7 | The Notarized Glass | elite | Echo of Mortimer Grimsby (26 HP) | **The Reflection Is Valid**: starts with 3 Red Tape; your first card each turn costs 1 more (on top of Reflected Order) |
| 8 | The Quiet Frame (optional) | event | the one rest: pay 250 gold to heal 12, or leave a card to heal 8, or keep moving | |
| 9 | The Banquet of Likenesses | battle | Echo of the Doppelganger (20 HP) | **Plated Twice**: two Sashimi Weenies on the field |
| 10 | The Trimmed Garden | battle | Echo of Hortensia Clipwell (20 HP) | **Mirror Topiary**: a 1/1 Topiary every second turn; its tokens +1/+1 |
| 11 | The Evergreen Frame | elite | Echo of the Rotheart (24 HP) | **Evergreen Glass**: 4 Garbage, heals 2 a turn, its units +0/+1 |
| 12 | Your Reflection | event | look (+1 attack, -3 max HP) / turn away (3 damage) / smash (6 damage, +1 defense) | |
| 13 | The Mirror Room | boss | **The Perfect Copy** | **Everything You Have**: your current deck, your max HP + 20, one extra card each turn |

Every enemy starts with a board somewhere (Militia, Weenies, Topiaries): Just Arrived still applies to those units.

**The wing rules stack** (`DungeonRules`, node lists):

| Rule | From | Text |
|---|---|---|
| Silvered | the Iron wing (node 2 on) | Enemy units get +1/+0. |
| Reflected Order | the Order wing (node 5 on, the mirror room too) | The first card you play each turn costs 1 more. |
| Perfect Form | the Appetite wing (nodes 9-12) | The first unit you play each turn is copied for the enemy (`Modifier.Kind.MIRROR_FIRST_UNIT`, new). |

**HP:** the run starts at full HP with **Silver Reserve** (+40 max life inside the Gallery); nothing heals between fights except node 8, and node 8 costs (gold or a card). Events cost HP or
max HP. There is no deck editing inside a dungeon (Part 2.4), so a card lost to an event stays lost for the run - and the Perfect Copy plays
the deck as it is at that moment.

## The Perfect Copy

`ShatteredGallery.perfect_copy_setup(run.current_deck(), run.max_hp())`: an exact copy of the run's current deck (lost cards removed), HP =
the player's max HP + 20, and its encounter rule (one extra draw a turn). The card art is the player's own (same cards); the battle plate shows
the hero's own picture (`HeroBust`) through the silver mirror shader. Like Primm's Reflection phase, the sim plays it with
`EncounterSpec.mirror_player_deck`.

## Look and sound (no new assets except one map)

- **Echo pictures:** each Echo's battle plate shows its original's Bestiary picture (`ShatteredGallery.original_of`) through
  `assets/shaders/mirror_tint.gdshader` (cold silver desaturation, a slow sheen, the round medallion cut).
- **Map:** `MAP-S-GALLERY` is the one new image (row in `docs/art/art_needed_nov4.csv`, node guide `docs/art/paintover_inputs/gallery_map_guide.png`).
  Until it arrives the castle map stands in (`MapArt.STANDIN_MAPS`); the battleboard is the castle's permanently (`Battleboards.STANDIN_BOARDS`).
- **Music:** the castle's cues and Primm's Reflection theme (`MusicDirector.DUNGEONS["S-GALLERY"]`) through a mirror effect on the Music bus
  while inside (`AudioMix.set_mirror_music`: a detuned chorus and a 1.5 % pitch-down). No new audio files.
- **Bytes added:** two small shaders, one script, JSON rows (a few KB in total); no textures, no audio. RAM/VRAM: one ShaderMaterial per
  mirrored picture.

## Rewards

- **First clear:** 1,500 gold, 6 essence of every Path, the hidden feat **Through the Glass** (+100 gold), and the **Mirrored card finish**:
  a silver sheen (`assets/shaders/mirror_sheen.gdshader`) the player can put on or off any card they own from the Collection Book's card
  inspect ("Mirrored finish: On/Off"; `CosmeticState.mirrored_cards`, saved). Shader only, no art.
- **Repeat clears:** the side dungeons' small repeat gold and a Prismatic Pack, plus the clear bonus (the run's gold again, Part 2).

## Balance target and sim

Target: a strong late deck wins the final boss about 20-35 % of the time.

### Sim (`tools/run_balance_sim.gd`, the reference deck of each Path at level 26 with its gear and items)

**The Perfect Copy alone, at full HP** (`--what=one --id=S-GALLERY:13`, 20 games per Path):

| Mirror room rules | Copy's HP bonus | Player wins |
|---|---:|---:|
| all three wing rules + its extra draw | +15 | 3 % |
| Silvered only + its extra draw | +5 | 88 % |
| Silvered + Reflected Order + its extra draw | +10 | 64 % |
| **Silvered + Reflected Order + its extra draw (kept)** | **+20** | **51 %** (Beefcake 40, Gourmand 45, Necrocrat 55, Refusemancer 65) |

The player meets it after seven duels with no healing, so the arrival rate is lower than this fresh-HP number; 51 % fresh puts the boss
near the 20-35 % target for a player who arrives with about half their life.

**The whole run** (`--what=sequence --filter=postgame:S-GALLERY`, eight duels in one HP pool, 20 runs per Path; the sim skips the events,
their boons and the costly rest):

| Setting | Cleared | Where runs ended |
|---|---:|---|
| first draft (Echo HP 26-38, Plume with Militia) | 0 % | almost all at the third Echo (Plume) |
| Echo HP 18-26, Plume without Militia | 0 % | Plume, then the Doppelganger |
| + run starts at full HP with Silver Reserve +20 max life; Doppelganger and Clipwell eased | 0 % | spread over Plume, the Doppelganger, Clipwell; one run reached the Copy |
| Silver Reserve +40 (kept) | not measured | the run was stopped by the host for low memory |

Each Echo alone is beatable (Quota and Clench 100 %, Mortimer 94 %, Plume 84 %, the Rotheart 56 %), but every duel costs a strong deck
about 10 HP. The Gallery is very hard by design; the knobs are `ShatteredGallery.SILVER_RESERVE`, `PERFECT_COPY_HP_BONUS`, the WING_*_ON
node lists and the Echo HP in `dungeon_content.json`.
