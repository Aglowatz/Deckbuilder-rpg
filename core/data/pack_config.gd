class_name PackConfig
extends Resource
## Pack-system numbers that are not about one pack (`data/packs/pack_config.tres`). All placeholders: tune freely.

## General Pack tier 2 (and the card vendor's expanded selection) unlocks at this player level...
@export var tier2_level: int = 10
## ...or after this many zones are freed, whichever comes first.
@export var tier2_zones: int = 2
## How many Path Packs a zone's main dungeon awards on EVERY clear.
@export var dungeon_pack_count: int = 1
## Extra rewards on the FIRST clear of a zone's main dungeon.
@export var first_clear_gilded_packs: int = 1
@export var first_clear_bonus_gold: int = 120  # Fixes Nov 8: restored at 150; Fable pass Nov 10 (Part 4.3): x 0.8
@export var first_clear_bonus_xp: int = 80  # Fable pass Nov 10 (Part 4.3): 100 x 0.8
## Prismatic Packs granted for beating Primm (the first time).
@export var primm_prismatic_packs: int = 1
