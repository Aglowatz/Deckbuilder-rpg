class_name ZoneSpot
extends RefCounted
## One interactable place or person in a zone: where it is, its prompt, and (once the scene has
## built it) the floating marker and name plate. `kind` picks the generic handler (see `ZoneDef.spots`).

var id: String = ""
var title: String = ""
var position: Vector3 = Vector3.ZERO
var radius: float = 1.5
var prompt: String = ""
var is_npc: bool = false
var kind: String = "zone"
var data: Dictionary = {}
var marker: Node3D
var plate: Label3D
