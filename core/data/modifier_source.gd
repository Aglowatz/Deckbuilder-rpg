class_name ModifierSource
extends Resource
## Anything that contributes Modifiers: an equipment piece, item, zone, dungeon or boon.

enum SourceKind { EQUIPMENT, ITEM, ZONE, DUNGEON, BOON }

@export var source_name: String = ""
@export var source_kind: SourceKind = SourceKind.EQUIPMENT
@export var modifiers: Array[Modifier] = []
## Overnight Nov 19 (Part 5): a dungeon choice's boon or drawback that lasts only this many more fights (0 = the rest of the dungeon).
@export var fights_left: int = 0
## Overnight Nov 19 (Part 5): a drawback that strengthens the ENEMY (its modifiers go to seat 1 of the dungeon's fights).
@export var for_enemy: bool = false
