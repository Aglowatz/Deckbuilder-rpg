# The Path-ology Lab (D-LAB)

> **Superseded Oct 21 2026:** the Lab now follows the design sheet's 16-node layout (Cell 4, the Mentor's Study, Siphon's Protocols, Elowen as
> T-24). See `docs/design/story_bible.md` section 18 and `core/dungeon/pathology_lab.gd`. The rest of this page describes the old placeholder.

Design notes for the designer's sheet. Everything here describes what the game does today (from `data/dungeons/postgame_dungeons.json`, `data/dungeons/dungeon_content.json` and `core/dungeon/pathology_lab.gd`), plus clearly marked **proposals** where the sheet still says "To be designed". The row in `data/source/dungeon_list.csv` has no node list yet; when it gets one, the CSV import wins over this document.

## What it is

The postgame dungeon of the game: a hidden laboratory under the forest where the Wanderer first woke up. It is the place where Primm's Path-ologists (his scientists) held Prince Tessar for ten years and drained his Path power, one drop at a time, to feed Primm's "perfection". It is optional, opens only after Primm falls, and is built to be far harder than Primm's Castle. Dungeon ID `D-LAB`, type "Postgame Dungeon", map `MAP-LAB`, battleboard `BB-LAB`.

## Where it is

In the forest outside Crosspath, in the starting clearing. After Primm falls, Rip Tearson opens a Rift Express station in the forest (flag `rift_station_forest`) and tells the player about a hatch "that was never there before. It smells like a hospital." The hatch appears in the clearing (anchor `lab`, flag `lab_revealed`) and leads down into the Lab. It is a dungeon map like the others (14 nodes, two routes that split and rejoin), not a walkable zone.

## Theme and mood

White, sterile and wrong. Long tiled corridors cracked open by tree roots from the forest above; glass tanks glowing in the four Path colours (red Beefcake, yellow Gourmand, purple Necrocrat, green Refusemancer); draining apparatus; cells with bone-pale bars; Path-ologists' desks covered in notes, mugs and keycards. Cold clinical light (fluorescent white-blue), one warm thing per room (a mug, a child's drawing). It should feel quiet rather than loud: the horror is how ordinary the equipment is. Palette: white and pale blue-grey, steel, with four saturated Path-colour glows and brown roots as the only organic note.

## Story purpose

It closes the personal story. Primm's castle answered "who ruined the kingdom"; the Lab answers "what was done to the Wanderer". Beats, in order:

1. Rip's tip and the hatch (the way in).
2. The Break Room: the Path-ologists' notes on "the Subject", with a column labelled "cooperative?" filled in with "asks for his mother."
3. The Prince's Old Cell: ten years of tally marks, and a child's four-colour drawing of his family. The player realises they counted every day.
4. The Draining Chamber: where the power was taken (Drain Warden elite).
5. The Rescuer's Cell: the captured Rescuer (the ally from the prologue) is freed and fights beside the player for the rest of the dungeon (+1/+1 to all units, +3 max HP). Freeing them is permanent: afterwards they stand in the forest, hood down.
6. Dr. Ambrose Siphon, Chief Path-ologist: still running experiments, the last person who believes the draining was science.

## Dungeon node list

Format as in `dungeon_list.csv`: `# Name - Type - (x%, y%) -> connects to`.

```
1. The Hidden Hatch - Start - (8%, 55%) -> 2, 3
2. Decontamination Corridor - Battle - (20%, 30%) -> 4
3. Specimen Gallery - Battle - (20%, 78%) -> 5
4. The Path-ologists' Break Room - Event - (32%, 18%) -> 6
5. The Failed Experiments - Elite - (32%, 70%) -> 6, 7
6. The Observation Ward - Battle - (44%, 38%) -> 8
7. The Prince's Old Cell - Event - (44%, 86%) -> 9
8. The Glass Tank Hall - Challenge - (56%, 24%) -> 9, 10
9. The Records Vault - Treasure - (56%, 62%) -> 11
10. The Draining Chamber - Elite - (68%, 18%) -> 12
11. Siphon's Annex - Battle - (68%, 66%) -> 12
12. The Rescuer's Cell - Rescue Event - (79%, 42%) -> 13
13. The Last Quiet Room - Full Heal - (86%, 66%) -> 14
14. The Chief Path-ologist's Laboratory - Boss - (92%, 22%) -> (end)
```

14 nodes: 7 battles (nodes 2, 3, 5, 6, 10, 11 and the boss 14, two of them elites) and 7 non-battle nodes (start, two events, a challenge, a treasure, the rescue and a full heal).

### Foes (today)

| Node | Foe | Deck | HP |
|---|---|---|---|
| 2 | Decontamination Technician | Necrocrat control | 30 |
| 3 | Escaped Specimen | Refusemancer garbage (with Beefcake cards) | 30 |
| 5 | The Failed Experiment (elite) | Beefcake bruisers mixed with Necrocrat and Gourmand | 36 |
| 6 | Observation Ward Orderly | Gourmand control | 32 |
| 10 | The Drain Warden (elite) | Necrocrat control, all four Paths mixed | 38 |
| 11 | Siphon's Research Assistant | Gourmand control with Necrocrat | 34 |
| 14 | Dr. Ambrose Siphon (boss) | Necrocrat control plus one of each Path's legendary and both colourless legendaries | 50 |

Balance has not been tuned: every enemy is built to be far harder than Primm's Castle.

### Events and challenge

- **Node 4, the Break Room** (3 choices): read the notes on the Subject (boon, +1 attack), drink the Path-ologists' tea (heal 4), rifle the lockers (80 gold).
- **Node 7, the Prince's Old Cell** (3 choices): run your fingers along the tally marks (boon, +3 max HP), look at the child's drawing (heal 5), leave quietly.
- **Node 8, the Glass Tank Hall** (challenge): a sensor asks whether your deck can carry more than one Path; success gives a boon (+2 max HP) and 3 healing, failure costs 4 HP.
- **Node 12, the Rescuer's Cell** (rescue): the serious scene; frees the Rescuer.
- **Node 9, the Records Vault** (treasure): 220 gold, 120 XP and a Scroll of Insight.

## Buffs and debuffs

**Today:** none ("PLACEHOLDER: no dungeon-wide rule yet"); the Lab only has the zone effects of the forest.

**Proposal** (both can be built with modifiers that already exist, no new engine work):

- **Four Taps** (both players): start each battle with one Iron, one Red Tape, one Ingredient and one Garbage. The tanks leak all four Paths' power into the room. (`STARTING_RESOURCES` x 4.)
- **Sterile Field** (both players): units enter exhausted. Everything in the Lab is slow and procedural. (`ENTER_EXHAUSTED`, the same rule as Please Wait in the Waiting Room of Eternity.)

## Rewards

- First clear: **Siphon's Lens** (Relic: Max HP +2 and an extra card on your first turn), 400 gold and 400 XP. There is no unique card yet (the sheet row names none); a proposal is to give the dungeon one, for example a colourless legendary.
- Repeat clears: a small amount of gold and a Prismatic Pack.

## Textures the Lab would need

The Lab stage (`DungeonBackdrop`, theme `lab`) is built from simple primitives and the existing KayKit and Kenney furniture, and is currently painted with existing textures (see below). A dedicated set would make it read as its own place. IDs follow the texture CSV (`TEX-` for tileable surfaces, with decals listed in the same series so one prefix covers the Lab); all seamless, 1024 px, albedo only (the game derives normal and roughness).

| ID | Type | Description |
|---|---|---|
| TEX-PLAB-TILE | Ground | Sterile white-grey floor tile with thin grout lines, lightly scuffed; the base floor of every corridor and room. |
| TEX-PLAB-TILE-DARK | Ground | The same tile in slate blue-grey with a faint hazard-yellow edge line; used as the inlay down the middle of corridors. |
| TEX-PLAB-GRATE | Ground | Brushed-steel floor grating over a dark drain, for the Draining Chamber and under the tanks. |
| TEX-PLAB-CELLFLOOR | Ground | Bare pale concrete with faint scratch marks and a few dark stains, for the prince's old cell and the Rescuer's cell. |
| TEX-PLAB-WALL | Wall | Clinical white wall panels with a pale blue stripe and tiny rivets; the plain wall of the corridors. |
| TEX-PLAB-WALL-ROOTED | Wall | The same wall split open by thick tree roots and cracked tile with crumbled plaster; used wherever the forest has broken in. |
| TEX-PLAB-ROOTS | Ground / prop | Dark brown tree roots over damp concrete, for roots crawling across the floor and ceiling. |
| TEX-PLAB-STEEL | Prop | Brushed stainless steel with a cool blue sheen, for tanks' frames, the draining rig, pipes and cradle. |
| TEX-PLAB-GLASS | Prop | Thick green-blue glass with condensation streaks and a faint internal glow; the tanks. |
| TEX-PLAB-BARS | Prop | Bone-pale painted bars with chipped paint, for the cells. |
| TEX-PLAB-DESK | Prop | Pale laminate desk surface with ring stains from mugs, for the Path-ologists' desks. |
| TEX-PLAB-SPILL | Decal | A glossy spill in four colours (red, yellow, purple, green) swirling together, for leaked tank fluid. |
| TEX-PLAB-CRACKS | Decal | Hairline cracks in white tile, branching, with tiny root tips poking through. |
| TEX-PLAB-NOTES | Decal | Scattered handwritten Path-ologist notes and printouts (illegible, with one circled word). |
| TEX-PLAB-TALLY | Decal | Rows of scratched tally marks in groups of five, for the prince's cell wall and floor. |
| TEX-PLAB-HAZARD | Decal | Faded yellow-and-black hazard stripes and a stencilled "SUBJECT 1" for door thresholds. |

## What the stage uses now (existing textures)

Until the dedicated set exists, the Lab stage uses these already-imported textures (preset `lab` in `data/art/texture_presets.json`): `TEX-DNA-LINOLEUM` for the base floor, `TEX-DNA-MARBLE` for the central inlay and the cliff/edge material, `TEX-DNA-PANELING` for painted wall/plaster props, and the shared decals `DEC-CRACKS`, `DEC-MOSS` (roots and moss creeping in), `DEC-PUDDLE` (spilled fluid) and `DEC-ECTOPLASM` (a faint glow-spill). See `docs/design/open_questions.md`, BL-11.
