extends SceneTree
## Performance pass Oct 25, Part 1 (docs/perf/perf_state.md): builds every area once so BuildCache writes its results into `res://build_cache/`
## with a manifest holding the source hash; the export ships them and the game loads them instead of working them out on each visit.
## Godot --path . -s res://tools/bake_build_cache.gd   (windowed: headless runs crash in the dummy renderer on the second town build; tools/export_windows.sh runs it via tools/build_cache.sh bake)
## Each area is built at every quality level and in its freed state where the zone has one (the cached results that depend on either say so in their key).

const AREAS: Array[Array] = [
	["res://scenes/town.tscn", {"quiet": "true"}],
	["res://scenes/starting_area.tscn", {"quiet": "true"}],
	["res://scenes/gainlands_zone.tscn", {}],
	["res://scenes/gainlands_zone.tscn", {"freed": "true"}],
	["res://scenes/buffet_zone.tscn", {}],
	["res://scenes/buffet_zone.tscn", {"freed": "true"}],
	["res://scenes/dna_zone.tscn", {}],
	["res://scenes/dna_zone.tscn", {"freed": "true"}],
	["res://scenes/heap_zone.tscn", {}],
	["res://scenes/heap_zone.tscn", {"freed": "true"}],
	["res://scenes/capital_zone.tscn", {}],
]

var _index: int = 0
var _quality: int = 0
var _scene: Node
var _frames: int = 0
var _started_usec: int = 0


func _initialize() -> void:
	BuildCache.baking = true
	_remove_old()
	_started_usec = Time.get_ticks_usec()


func _remove_old() -> void:
	var dir: DirAccess = DirAccess.open(BuildCache.BAKED_ROOT)
	if dir == null:
		return
	for file_name: String in dir.get_files():
		dir.remove(file_name)


func _process(_delta: float) -> bool:
	if _scene != null:
		_frames += 1
		if _frames < 3:
			return false
		_scene.queue_free()
		_scene = null
		return false
	if _index >= AREAS.size() * 3:
		BuildCache.write_manifest()
		print("bake_build_cache: done, %d results in %s (%.1f s), hash %s" % [BuildCache.misses, BuildCache.BAKED_ROOT, float(Time.get_ticks_usec() - _started_usec) / 1000000.0, BuildCache.source_hash()])
		quit(0)
		return true
	var entry: Array = AREAS[_index / 3]
	_quality = _index % 3
	_index += 1
	root.get_node("Session").set("save_enabled", false)
	root.get_node("Settings").set("graphics_quality", _quality)
	var args: Dictionary = (entry[1] as Dictionary).duplicate()
	args["bake"] = "true"
	_scene = (load(str(entry[0])) as PackedScene).instantiate()
	if _scene.has_method("screenshot_prepare"):
		_scene.call("screenshot_prepare", args)
	root.add_child(_scene)
	_frames = 0
	print("bake_build_cache: %s %s quality %d" % [entry[0], str(entry[1]), _quality])
	return false
