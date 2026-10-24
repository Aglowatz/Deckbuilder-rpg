extends Node
## Overnight Oct 22, Phase 2: does video memory plateau? Crosspath -> each zone -> Crosspath, twice round (-- --short: Gainlands x2;
## -- --orphans lists stray nodes at the end); texture / buffer / video memory, object and resource counts and
## the session-long art caches (CardArt, IconArt, UiArt, Portraits, SpriteLibrary) at each return to town. A plateau on the second loop
## = bounded caches, not a leak. Windowed, alone: Godot --path . --resolution 1280x720 res://tools/memory_probe.tscn

const ZONES: Array[String] = ["beefcake", "necrocrat", "gourmand", "refusemancer", "final"]


var worker: bool = false


func _ready() -> void:
	# The launcher scene is freed by the first scene change: run from a copy under the root (as tools/tour_bot_launcher.gd does).
	if not worker:
		var copy: Node = (get_script() as GDScript).new()
		copy.set("worker", true)
		get_tree().root.add_child.call_deferred(copy)
		return
	_run.call_deferred()


func _run() -> void:
	Session.save_enabled = false
	SceneManager.show_loading_screens = false
	Session.ensure_game()
	await _arrive("town", TownScene, func() -> void: SceneManager.change_scene("res://scenes/town.tscn"))
	var loop: int = 0
	var route: Array[String] = ZONES + ZONES
	if OS.get_cmdline_user_args().has("--short"):
		route = ["beefcake", "beefcake"] as Array[String]
	# Oct 23: `--townloop` reloads Crosspath only (no zone in between) / `--zoneloop` goes Gainlands -> Gainlands - which side keeps memory.
	if OS.get_cmdline_user_args().has("--townloop"):
		for i: int in range(3):
			await _arrive("town", TownScene, func() -> void: SceneManager.change_scene("res://scenes/town.tscn"))
		route = [] as Array[String]
	if OS.get_cmdline_user_args().has("--zoneloop"):
		for i: int in range(3):
			await _arrive("beefcake", ZoneScene, func() -> void: Session.enter_zone("beefcake"))
		route = [] as Array[String]
	for zone_id: String in route:
		await _arrive(zone_id, ZoneScene, func() -> void: Session.enter_zone(zone_id))
		await _arrive("town", TownScene, func() -> void: SceneManager.change_scene("res://scenes/town.tscn"))
		loop += 1
	if OS.get_cmdline_user_args().has("--orphans"):
		print("memory_probe: orphan nodes ----")
		Node.print_orphan_nodes()
	print("memory_probe: done")
	get_tree().quit()


func _arrive(label: String, kind: Variant, go: Callable) -> void:
	var before: Node = get_tree().current_scene
	go.call()
	var waited: float = 0.0
	while waited < 45.0:
		var scene: Node = get_tree().current_scene
		if scene != null and scene != before and is_instance_of(scene, kind):
			break
		await get_tree().create_timer(0.25).timeout
		waited += 0.25
	await get_tree().create_timer(3.0).timeout
	print("memory_probe: %-12s textures %4d MB, buffers %3d MB, video %4d MB, objects %d, resources %d, caches card art %d, icons %d, UI art %d, portraits %d, sprites %d" % [label,
		int(Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / 1048576.0),
		int(Performance.get_monitor(Performance.RENDER_BUFFER_MEM_USED) / 1048576.0),
		int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0),
		int(Performance.get_monitor(Performance.OBJECT_COUNT)), int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)),
		CardArt._cache.size(), IconArt._textures.size(), UiArt._textures.size(), Portraits._textures.size(), SpriteLibrary._textures.size()])
	# Oct 23: who holds the per-load objects - nodes in the tree, each autoload's descendants and signal connections.
	var census: PackedStringArray = ["nodes %d" % int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))]
	for holder: Node in get_tree().root.get_children():
		if holder == get_tree().current_scene:
			continue
		var connections: int = 0
		for sig: Dictionary in holder.get_signal_list():
			connections += holder.get_signal_connection_list(str(sig["name"])).size()
		census.append("%s %d/%d" % [holder.name, holder.get_child_count(true) + _descendants(holder), connections])
	print("memory_probe:   census ", ", ".join(census))
	print("memory_probe:   statics foliage %d/%d/%d, decals %d, painted specials %d used %d missing %d, patches %d, clusters %d, toon %d/%d, card rules %d" % [
		KitFoliage._materials.size() + KitFoliage._clumps.size(), KitFoliage._card_materials.size(), KitFoliage._card_cache.size(), GroundDecals._added.size(),
		PaintedClasses._specials.size(), PaintedLibrary.used.size(), PaintedLibrary.missing.size(), PathTool._patch_cache.size(),
		ZoneClusters._clusters.size(), StyleToon._cache.size(), StyleToon._haze_shaders.size(), CardView._rules_size_cache.size()])


func _descendants(node: Node) -> int:
	var total: int = 0
	for child: Node in node.get_children(true):
		total += 1 + _descendants(child)
	return total
