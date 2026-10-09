extends Node3D
## Shows one dungeon stage (`DungeonBackdrop`) on its own, for screenshots: `bash tools/shot.sh res://tools/backdrop_preview.tscn <name> --theme=castle [--cam=x,y,z]`.
## (In the game the stages sit behind the painted dungeon maps and only show for a dungeon without map art.)

var _args: Dictionary = {}


func screenshot_prepare(args: Dictionary) -> void:
	_args = args


func _ready() -> void:
	var backdrop: DungeonBackdrop = DungeonBackdrop.make(str(_args.get("theme", "castle")))
	if _args.has("cam"):
		var parts: PackedStringArray = str(_args["cam"]).split(",")
		backdrop.camera_offset = Vector3(float(parts[0]), float(parts[1]), float(parts[2]))
	add_child(backdrop)
