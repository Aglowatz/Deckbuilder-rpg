extends SceneTree
## Prints the Environment Kit status table (markdown): every sheet id, its slot, what stands in for it, whether real art is in assets/art/env_kit/, and where the game uses it.
##   Godot --headless --path . -s res://tools/env_kit_status.gd

const USED_BY: Dictionary = {
	"ENV-GROUND-DIRTPATH": "PathTool dirt paths (grave road, south road), worn patches",
	"ENV-GROUND-COBBLE": "PathTool cobble streets and the plaza",
	"ENV-GROUND-GRASS-CALM": "kit bench ground (the town keeps its painted TEX-TOWN-GRASS ground)",
	"DEC-PATHEDGE": "PathTool edge strips", "DEC-WORNPATCH": "doorsteps, bends (PathTool.patch)", "DEC-IVY": "wall sockets (ivy)", "DEC-WALLSTAIN": "wall sockets (stain)",
	"ENV-TREE-OAK": "TreeCards / tree fields", "ENV-TREE-FRUIT": "TreeCards / tree fields", "ENV-TREE-PINE": "TreeCards / tree fields", "ENV-TREE-BIRCH": "TreeCards / tree fields",
	"ENV-HEDGE": "PropKit hedge, bush", "ENV-PROP-BARREL": "PropKit barrel", "ENV-PROP-CRATE": "PropKit crate", "ENV-PROP-SACK": "PropKit sack, stall, cart",
	"ENV-PROP-FENCE": "PropKit picket fence, bench, planter", "ENV-PROP-FENCE-RAIL": "PropKit rail fence", "ENV-PROP-CANVAS": "PropKit cart hood",
	"ENV-PROP-CLOTHGOODS": "(clothier counter: not built yet)", "ENV-PROP-FLOWERPOTS": "PropKit flowerpot, building pots and window boxes", "ENV-PROP-LANTERN": "(lantern meshes are built; the card is for hung lanterns)",
	"ENV-PROP-WELL": "PropKit well", "ENV-PROP-STALL": "PropKit stall", "ENV-PROP-CART": "PropKit cart",
	"ENV-SIGNPOST": "PropKit signpost (Path crest), passage signs, Rift Express sign",
}


func _initialize() -> void:
	var usage: Dictionary = {}
	for preset_name: String in BuildingPresets.names():
		for id: String in BuildingPresets.kit_ids(preset_name):
			if not usage.has(id):
				usage[id] = []
			(usage[id] as Array).append(preset_name)
	var lines: PackedStringArray = PackedStringArray()
	lines.append("| Kit ID | Slot | Lock / size | Now | Placeholder | Used by |")
	lines.append("|---|---|---|---|---|---|")
	for id: String in EnvKit.ids():
		var entry: Dictionary = EnvKit.entry(id)
		var used: String = str(USED_BY.get(id, ""))
		if usage.has(id):
			var names: Array = usage[id] as Array
			used = "%d building presets (%s)" % [names.size(), ", ".join(PackedStringArray(names.slice(0, 3)))] + (", " + used if used != "" else "")
		lines.append("| `%s` | %s | %s %s | %s | %s | %s |" % [id, EnvKit.slot(id), str(entry.get("lock", "")), str(entry.get("size", "")), EnvKit.status(id), str(entry.get("placeholder", "")), used])
	print("\n".join(lines))
	quit(0)
