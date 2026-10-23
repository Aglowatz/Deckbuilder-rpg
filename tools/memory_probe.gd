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
