class_name ModifierSource
extends Resource
## Anything that contributes Modifiers: an equipment piece, item, zone, dungeon or boon.

enum SourceKind { EQUIPMENT, ITEM, ZONE, DUNGEON, BOON }

@export var source_name: String = ""
@export var source_kind: SourceKind = SourceKind.EQUIPMENT
@export var modifiers: Array[Modifier] = []
