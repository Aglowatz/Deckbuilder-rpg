class_name HeapScene
extends ZoneScene
## The playable Verdant Heap (Refusemancer zone). The shared zone framework (`ZoneScene`) provides the hub, life rules,
## enemies, chests, quiz/minigame/puzzle launchers and the minimap; this subclass adds what is unique here: the
## golden-hour look and fireflies, GROWING (a druid or a Magic Bean grows a vine bridge across the recycling stream or a
## beanstalk up a junk mountain), RIDEABLE ANIMALS (a giant boar or goat from a stable: faster, crosses the scree and
## charges through junk barricades; Q dismounts), TRASH CHUTES down the junk mountains, falling into the stream or a
## compost pit (respawn at the last safe spot for 1 zone life, logged), and the interactables (compost bin, crop plots,
## druid shrine, animal trough, escaped animals, ingredient-style pickups).

const SAFE_INTERVAL: float = 0.2
const HAZARD_SAFE_DISTANCE: float = 2.0
const CHUTE_COOLDOWN: float = 1.2
const MOUNT_SPEED: float = 1.8
const CAMERA_NORMAL: Vector3 = Vector3(0.0, 14.0, 9.4)

var heap: HeapBuilder
var last_safe: Vector3 = Vector3.ZERO
var _safe_timer: float = 0.0
var _falling: bool = false
var _fireflies_added: bool = false
var _shake: float = 0.0
var _busy: bool = false
var _chute_cooldown: float = 0.0
var _riding: String = ""
var _mount_node: Node3D
var _mount_stable: int = 0
var _barricade_hint_cooldown: float = 0.0
var _crop_timer: float = 0.0
var _pickup_nodes: Dictionary = {}
var _animal_nodes: Dictionary = {}


func _zone_id() -> String:
	return HeapZone.ID


func _make_map() -> ZoneMap:
	heap = HeapBuilder.new()
	return heap


func _build_environment() -> void:
	add_child(HeapLook.environment())
	add_child(HeapLook.sun())


func _build_zone_extras() -> void:
	camera_offset = CAMERA_NORMAL
	last_safe = player.position
	_add_hats()
	_restore_growth_and_barricades()
	_refresh_crops()


func _make_puzzle_screen() -> OverlayScreen:
	return GrowthGridScreen.new()


func _make_minigame_screen() -> OverlayScreen:
	return SortGameScreen.new()


func _hub_spawn() -> Vector3:
	return builder.anchor("spawn")


func is_riding() -> bool:
	return not _riding.is_empty()


# ---- Prompts and the map ---------------------------------------------------------------------------


func _prompt_for(spot: ZoneSpot) -> String:
	if spot.data.has("grow"):
		var growth: HeapGrowth.Growth = HeapGrowth.find(str(spot.data["grow"]))
		if growth != null and HeapInteractables.is_grown(growth):
			return "Climb the beanstalk" if growth.kind == "ladder" else "Admire the vine bridge"
		if growth != null and growth.how == "druid":
			return "Talk to %s" % growth.speaker
		return "Plant a Magic Bean"
	if spot.data.has("pickup"):
		if HeapInteractables.picked_this_visit(Session.zone_run, str(spot.data["pickup"])):
			return "Already picked up this visit"
	if spot.data.has("animal"):
		if HeapInteractables.herded_this_visit(Session.zone_run, int(spot.data["animal"])):
			return "Already back in the pen"
	if spot.data.has("crop"):
		var state: String = HeapInteractables.crop_state(Session.zone_run, int(spot.data["crop"]), Time.get_unix_time_from_system())
		return {"empty": "Plant a crop (a sack of fertilizer)", "growing": "The crop is still growing", "ripe": "Harvest the crop"}[state]
	if spot.data.has("stable"):
		return "Dismount first" if is_riding() else spot.prompt
	return spot.prompt


func _extra_pois() -> Array[MapPoi]:
	var result: Array[MapPoi] = []
	for chute: HeapLayout.Chute in heap.layout.chutes:
		result.append(MapPoi.make(MapPoi.Kind.BOUNCE_PAD, Vector3(chute.pos.x, 0.0, chute.pos.y), chute.title))
	return result


# ---- Per-frame -----------------------------------------------------------------------------------------


func _zone_process(delta: float) -> void:
	_chute_cooldown = maxf(0.0, _chute_cooldown - delta)
	_barricade_hint_cooldown = maxf(0.0, _barricade_hint_cooldown - delta)
	heap.animate(delta)
	_update_mount()
	_crop_timer -= delta
	if _crop_timer <= 0.0:
		_crop_timer = 1.0
		_refresh_crops()
	if not _fireflies_added and _camera != null:
		_fireflies_added = true
		_camera.add_child(HeapLook.fireflies())
	if _shake > 0.0:
		_camera.position += Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), 0.0) * _shake * 0.18
		_shake = maxf(0.0, _shake - delta * 2.4)
	if player.airborne or _falling or _fainting:
		return
	if heap.is_in_hazard(player.position) and not _locked:
		_fall_into_hazard()
		return
	if not _locked and not _busy:
		_check_barricades()
		if _chute_cooldown <= 0.0:
			_check_chutes()
	_safe_timer -= delta
	if _safe_timer <= 0.0:
		_safe_timer = SAFE_INTERVAL
		_track_safe_spot()


func _track_safe_spot() -> void:
	var pos: Vector3 = player.position
	match heap.layout.surface_at(pos.x, pos.z):
		HeapLayout.Surface.GROUND:
			if heap.layout.hazard_depth(pos.x, pos.z) <= -HAZARD_SAFE_DISTANCE:
				last_safe = pos
		HeapLayout.Surface.PEAK:
			var peak: HeapLayout.Peak = heap.layout.peak_at(pos.x, pos.z)
			if peak != null and Vector2(pos.x - peak.center.x, pos.z - peak.center.y).length() <= peak.radius - 0.8:
				last_safe = pos
		HeapLayout.Surface.ROUGH:
			if is_riding() and heap.layout.hazard_depth(pos.x, pos.z) <= -HAZARD_SAFE_DISTANCE:
				last_safe = pos


# ---- Interactions ------------------------------------------------------------------------------------------


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo and (event as InputEventKey).keycode == KEY_Q:
		if is_riding() and not _locked and not dialogue.active and not _fainting:
			get_viewport().set_input_as_handled()
			_dismount(true)
			return
	super._unhandled_input(event)


func _interact_zone(spot: ZoneSpot) -> void:
	if spot.data.has("grow"):
		_use_growth(HeapGrowth.find(str(spot.data["grow"])), spot)
		return
	if spot.data.has("climb_down"):
		_climb(HeapGrowth.find(str(spot.data["climb_down"])), false)
		return
	if spot.data.has("pickup"):
		_use_pickup(spot, str(spot.data["pickup"]))
		return
	if spot.data.has("crop"):
		_use_crop(spot, int(spot.data["crop"]))
		return
	if spot.data.has("animal"):
		_use_animal(spot, int(spot.data["animal"]))
		return
	if spot.data.has("stable"):
		_mount(str(spot.data["stable"]))
		return
	match spot.id:
		"compost_bin":
			_use_compost_bin(spot)
		"shrine":
			_use_shrine(spot)
		"trough":
			_use_trough(spot)


func _use_pickup(spot: ZoneSpot, pickup_id: String) -> void:
	player.face(spot.position)
	var name: String = str(HeapZone.PICKUPS[pickup_id])
	if not HeapInteractables.pick_up(Session.zone_run, pickup_id):
		Audio.sfx(&"ui_error")
		hud.toast(story.text("fx.pickup_again"), UIStyle.MUTED)
		return
	Audio.sfx(&"coins", -4.0, 0.2)
	hud.toast("%s %s" % [story.text("fx.pickup"), name], UIStyle.GOLD)
	_floating_text("+1 %s" % name, UIStyle.GOLD)
	var node: Node3D = _pickup_nodes.get(pickup_id) as Node3D
	if node != null:
		node.visible = false
	Session.save_game()


func _use_compost_bin(spot: ZoneSpot) -> void:
	player.face(spot.position)
	if not HeapInteractables.can_compost(Session.zone_run):
		Audio.sfx(&"ui_error")
		var key: String = "fx.compost_limit" if HeapInteractables.stock("junk") >= HeapInteractables.COMPOST_COST else "fx.compost_missing"
		_say("The Compost Bin", story.get_lines(key))
		return
	HeapInteractables.compost(Session.zone_run)
	Audio.sfx(&"heal", -2.0)
	hud.toast(story.text("fx.compost_done"), UIStyle.GOOD)
	_floating_text("+1 max life", UIStyle.GOOD)
	EventBus.zone_life_changed.emit(Session.zone_run.life, Session.zone_run.max_life())
	Session.save_game()


func _use_shrine(spot: ZoneSpot) -> void:
	player.face(spot.position)
	var result: Dictionary = HeapInteractables.bless(Session.zone_run)
	if not bool(result["ok"]):
		Audio.sfx(&"ui_error")
		hud.toast(story.text("fx.shrine_again"), UIStyle.MUTED)
		return
	Audio.sfx(&"level_up", -4.0)
	hud.toast(story.text("fx.shrine_blessing"), UIStyle.GOLD)
	_floating_text("Blessed!", Color("ff9ad0"))
	EventBus.zone_life_changed.emit(Session.zone_run.life, Session.zone_run.max_life())
	Session.save_game()


func _use_trough(spot: ZoneSpot) -> void:
	player.face(spot.position)
	if not HeapInteractables.can_feed(Session.zone_run):
		Audio.sfx(&"ui_error")
		var key: String = "fx.trough_limit" if HeapInteractables.stock("junk") >= 1 else "fx.trough_missing"
		hud.toast(story.text(key), UIStyle.MUTED)
		return
	HeapInteractables.feed(Session.zone_run)
	Audio.sfx(&"coins", -2.0)
	hud.toast(story.text("fx.trough_done"), UIStyle.GOLD)
	hud.set_gold(Session.gold)
	Session.save_game()


func _use_crop(spot: ZoneSpot, plot: int) -> void:
	player.face(spot.position)
	var run: ZoneRun = Session.zone_run
	var now: float = Time.get_unix_time_from_system()
	match HeapInteractables.crop_state(run, plot, now):
		"empty":
			if not HeapInteractables.plant(run, plot, now):
				Audio.sfx(&"ui_error")
				hud.toast(story.text("fx.crop_no_fertilizer"), UIStyle.MUTED)
				return
			Audio.sfx(&"land_play", -2.0)
			hud.toast(story.text("fx.crop_planted"), UIStyle.GOOD)
		"growing":
			Audio.sfx(&"ui_error", -6.0)
			hud.toast(story.text("fx.crop_growing"), UIStyle.MUTED)
		"ripe":
			var result: Dictionary = HeapInteractables.harvest(run, plot, now)
			Audio.sfx(&"heal")
			Audio.sfx(&"coins", -2.0)
			hud.toast("%s +%d life, +%d gold" % [story.text("fx.crop_harvest"), int(result["healed"]), int(result["gold"])], UIStyle.GOLD)
			hud.set_gold(Session.gold)
			EventBus.zone_life_changed.emit(run.life, run.max_life())
	_refresh_crops()
	Session.save_game()


## Crop plots show their state: bare soil, sprouts (growing) or ripe pumpkins and melons.
func _refresh_crops() -> void:
	var now: float = Time.get_unix_time_from_system()
	for plot: int in heap.crop_nodes.keys():
		var node: Node3D = heap.crop_nodes[plot] as Node3D
		var state: String = HeapInteractables.crop_state(Session.zone_run, int(plot), now)
		(node.get_meta("sprout") as Node3D).visible = state == "growing"
		(node.get_meta("ripe") as Node3D).visible = state == "ripe"


func _use_animal(spot: ZoneSpot, number: int) -> void:
	player.face(spot.position)
	if not HeapInteractables.herd(Session.zone_run, number):
		Audio.sfx(&"ui_error")
		hud.toast(story.text("fx.herd_again"), UIStyle.MUTED)
		return
	Audio.sfx(&"hit_light", -6.0, 0.3)
	hud.toast(story.text("fx.herd_%d" % number), UIStyle.GOOD)
	var node: Node3D = _animal_nodes.get(number) as Node3D
	if node != null:
		var pen: Vector3 = builder.anchor("stable_1")
		var run_tween: Tween = create_tween()
		run_tween.tween_property(node, "position", Vector3(pen.x, node.position.y, pen.z + 2.6), 2.2)
		run_tween.tween_callback(func() -> void: node.visible = false)
	Session.save_game()


# ---- Growing --------------------------------------------------------------------------------------------


func _use_growth(growth: HeapGrowth.Growth, spot: ZoneSpot) -> void:
	if growth == null or _busy:
		return
	player.face(spot.position)
	if HeapInteractables.is_grown(growth):
		if growth.kind == "ladder":
			_climb(growth, true)
		else:
			hud.toast(story.text("fx.bridge_done"), UIStyle.MUTED)
		return
	if growth.how == "druid":
		_face_npc("sorrel")
		if HeapInteractables.can_grow(growth):
			_say(growth.speaker, story.get_lines(growth.key("pass")), func() -> void: _grow(growth))
		else:
			Audio.sfx(&"ui_error")
			_say(growth.speaker, story.get_lines(growth.key("need")))
		return
	if not HeapInteractables.can_grow(growth):
		Audio.sfx(&"ui_error")
		_say("The Sprout Mound", story.get_lines(growth.key("need")))
		return
	_say("The Sprout Mound", story.get_lines(growth.key("plant")), func() -> void: _grow(growth))


## Grows a bridge or beanstalk: the flag is set (and a bean used up) first, then it sprouts, twists and blooms.
func _grow(growth: HeapGrowth.Growth) -> void:
	if not HeapInteractables.grow(growth):
		return
	_busy = true
	_locked = true
	Audio.sfx(&"spell", -2.0, 0.1)
	Audio.sfx(&"heal", -4.0)
	hud.toast(story.text("fx.grow"), Color("7fe05a"))
	var tween: Tween = create_tween()
	tween.tween_method(func(progress: float) -> void:
		if growth.kind == "bridge":
			heap.set_bridge_progress(growth.id, progress)
		else:
			heap.set_ladder_progress(growth.id, progress), 0.0, 1.0, 3.2)
	await tween.finished
	_shake = 0.5
	Audio.sfx(&"level_up", -6.0)
	hud.toast(story.text("fx.grown"), UIStyle.GOOD)
	_locked = false
	_busy = false
	Session.save_game()


## Gets everything the player already grew (flags) and smashed back into its finished state.
func _restore_growth_and_barricades() -> void:
	for growth: HeapGrowth.Growth in HeapGrowth.all():
		if Session.flag(growth.flag):
			if growth.kind == "bridge":
				heap.set_bridge_progress(growth.id, 1.0)
			else:
				heap.set_ladder_progress(growth.id, 1.0)
	for barricade: HeapGrowth.Barricade in HeapGrowth.barricades():
		if Session.flag(barricade.flag):
			heap.smash_barricade(barricade.id)
			var node: Node3D = heap.barricade_nodes.get(barricade.id) as Node3D
			if node != null:
				node.visible = false


## Climbs a grown beanstalk: up to the summit (from its mound) or down again, hand over hand along the stalk.
func _climb(growth: HeapGrowth.Growth, up: bool) -> void:
	if growth == null or _busy or not HeapInteractables.is_grown(growth):
		return
	_busy = true
	_locked = true
	player.airborne = true
	var base: Vector3 = builder.anchor("mound_a" if growth.id == "ladder_a" else "mound_b")
	var top: Vector3 = builder.anchor(growth.id + "_top")
	var start: Vector3 = base if up else top
	var finish: Vector3 = top if up else base
	finish.y = builder.height_at(finish)
	player.face(finish)
	player.forced_animation = &""
	Audio.sfx(&"footstep", -4.0, 0.2)
	hud.toast(story.text("fx.climb_up" if up else "fx.climb_down"), UIStyle.GOOD)
	var climb: Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	climb.tween_method(func(t: float) -> void:
		var p: Vector3 = start.lerp(finish, t * t * (3.0 - 2.0 * t))
		p.y = lerpf(start.y, finish.y, t) + sin(t * PI * 6.0) * 0.12
		player.position = p, 0.0, 1.0, 2.6)
	var wide: Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	wide.tween_property(self, "camera_offset", Vector3(0.0, 17.0, 10.5), 1.2)
	wide.tween_property(self, "camera_offset", CAMERA_NORMAL, 1.4)
	await climb.finished
	player.position = finish
	player.airborne = false
	last_safe = finish
	_locked = false
	_busy = false
	_spawn_grace = 1.0
	Session.refresh_quests()
	Session.save_game()


# ---- Mounts and barricades ------------------------------------------------------------------------------


func _mount(kind: String) -> void:
	if is_riding() or _busy:
		return
	var index: int = 1 if kind == "boar" else 2
	var stable: Node3D = heap.stable_nodes.get(index) as Node3D
	player.face(stable.position if stable != null else player.position)
	if stable != null and stable.has_meta("animal"):
		(stable.get_meta("animal") as Node3D).visible = false
	_mount_node = HeapMobs.animal(kind)
	add_child(_mount_node)
	_mount_node.scale = Vector3.ONE * 1.35
	_riding = kind
	_mount_stable = index
	heap.mounted = true
	player.speed_multiplier = MOUNT_SPEED
	player.model.position.y = 1.15
	Audio.sfx(&"hit_light", -4.0, 0.1)
	Audio.sfx(&"turn_start", -8.0)
	Session.bump_counter(HeapZone.COUNTER_RIDES)
	Session.refresh_quests()
	hud.toast(story.text("fx.mounted"), UIStyle.GOLD)
	_update_mount()


## Dismounts (Q): the animal trots home to its stable. Not allowed on the scree or in front of a barricade.
func _dismount(announce: bool) -> void:
	if not is_riding():
		return
	if announce and heap.layout.surface_at(player.position.x, player.position.z) == HeapLayout.Surface.ROUGH:
		Audio.sfx(&"ui_error")
		hud.toast(story.text("fx.dismount_scree"), UIStyle.MUTED)
		return
	heap.mounted = false
	player.speed_multiplier = 1.0
	player.model.position.y = 0.0
	if _mount_node != null:
		_puff(_mount_node.position)
		_mount_node.queue_free()
		_mount_node = null
	var stable: Node3D = heap.stable_nodes.get(_mount_stable) as Node3D
	if stable != null and stable.has_meta("animal"):
		(stable.get_meta("animal") as Node3D).visible = true
	_riding = ""
	if announce:
		hud.toast(story.text("fx.dismounted"), UIStyle.MUTED)


func _update_mount() -> void:
	if _mount_node == null:
		return
	_mount_node.position = player.position
	_mount_node.rotation.y = player.model.rotation.y
	var animation: AnimationPlayer = ModelKit.animation_player(_mount_node)
	if animation != null:
		var wanted: String = "run" if player.moving else "idle"
		if animation.has_animation(wanted) and animation.current_animation != wanted:
			animation.play(wanted, 0.15)


## A charging mount smashes the junk barricade it runs into; on foot you just bounce off (with a hint).
func _check_barricades() -> void:
	for barricade: HeapGrowth.Barricade in HeapGrowth.barricades():
		if not heap.is_barricade_standing(barricade.id):
			continue
		var pos: Vector3 = heap.layout.barricade_positions[barricade.id] as Vector3
		var reach: float = heap.barricade_radius(barricade.id) + 0.8
		if Vector2(player.position.x - pos.x, player.position.z - pos.z).length() > reach:
			continue
		if is_riding() and player.moving:
			_smash(barricade)
			return
		if not is_riding() and _barricade_hint_cooldown <= 0.0:
			_barricade_hint_cooldown = 4.0
			hud.toast(story.text("fx.barricade_hint"), UIStyle.MUTED)
			Audio.sfx(&"hit_metal", -10.0)


func _smash(barricade: HeapGrowth.Barricade) -> void:
	HeapInteractables.smash(barricade)
	heap.smash_barricade(barricade.id)
	Audio.sfx(&"hit_heavy", 0.0, 0.1)
	Audio.sfx(&"hit_metal", -2.0, 0.2)
	hud.toast(story.text("fx.smash_%s" % barricade.id), UIStyle.GOLD)
	_floating_text("CRASH!", Color("ffb040"))
	_shake = 1.0
	var node: Node3D = heap.barricade_nodes.get(barricade.id) as Node3D
	if node != null:
		_debris_burst(node.position)
		var tween: Tween = create_tween()
		tween.tween_property(node, "scale", Vector3(1.4, 0.05, 1.4), 0.25)
		tween.tween_callback(func() -> void: node.visible = false)
	Session.save_game()


func _debris_burst(pos: Vector3) -> void:
	var bits: CPUParticles3D = CPUParticles3D.new()
	bits.one_shot = true
	bits.amount = 36
	bits.lifetime = 1.1
	bits.explosiveness = 1.0
	bits.direction = Vector3.UP
	bits.spread = 70.0
	bits.initial_velocity_min = 3.0
	bits.initial_velocity_max = 7.0
	bits.gravity = Vector3(0, -12.0, 0)
	bits.scale_amount_min = 0.6
	bits.scale_amount_max = 1.6
	var chunk: BoxMesh = BoxMesh.new()
	chunk.size = Vector3(0.22, 0.22, 0.22)
	bits.mesh = chunk
	bits.material_override = HeapMaterials.flat(HeapMaterials.RUST)
	bits.position = pos + Vector3(0, 0.8, 0)
	add_child(bits)
	bits.emitting = true
	get_tree().create_timer(1.8).timeout.connect(bits.queue_free)


func _puff(pos: Vector3) -> void:
	var dust: CPUParticles3D = CPUParticles3D.new()
	dust.one_shot = true
	dust.amount = 14
	dust.lifetime = 0.7
	dust.explosiveness = 1.0
	dust.direction = Vector3.UP
	dust.spread = 80.0
	dust.initial_velocity_min = 1.0
	dust.initial_velocity_max = 2.5
	dust.gravity = Vector3(0, -2.0, 0)
	var puff: SphereMesh = SphereMesh.new()
	puff.radius = 0.12
	puff.height = 0.24
	puff.radial_segments = 6
	puff.rings = 3
	dust.mesh = puff
	dust.material_override = HeapMaterials.translucent(Color(0.9, 0.85, 0.7), 0.6, 0.2)
	dust.position = pos + Vector3(0, 0.3, 0)
	add_child(dust)
	dust.emitting = true
	get_tree().create_timer(1.2).timeout.connect(dust.queue_free)


# ---- Trash chutes -------------------------------------------------------------------------------------------


func _check_chutes() -> void:
	for chute: HeapLayout.Chute in heap.layout.chutes:
		if Vector2(player.position.x - chute.pos.x, player.position.z - chute.pos.y).length() <= chute.radius:
			_slide(chute)
			return


## WHEEEE: the chute grabs you and you whoosh down the junk mountain along the metal trough, tumble out at the bottom.
func _slide(chute: HeapLayout.Chute) -> void:
	_busy = true
	_locked = true
	_dismount(false)
	player.airborne = true
	var points: Array[Vector3] = heap.chute_points(chute)
	var end: Vector3 = builder.anchor(chute.dest_anchor)
	Audio.sfx(&"spell", -4.0, 0.3)
	Audio.sfx(&"hit_metal", -4.0, 0.2)
	hud.toast(story.text("fx.slide"), UIStyle.GOLD)
	var total: float = 0.0
	for index: int in range(points.size() - 1):
		total += points[index].distance_to(points[index + 1])
	var duration: float = clampf(total / 7.0, 1.6, 3.2)
	var slide: Tween = create_tween()
	slide.tween_method(func(t: float) -> void:
		var distance: float = t * total
		var walked: float = 0.0
		for index: int in range(points.size() - 1):
			var segment: float = points[index].distance_to(points[index + 1])
			if distance <= walked + segment or index == points.size() - 2:
				var u: float = clampf((distance - walked) / maxf(segment, 0.001), 0.0, 1.0)
				var pos: Vector3 = points[index].lerp(points[index + 1], u)
				player.position = pos + Vector3(0, 0.25, 0)
				var heading: Vector3 = points[index + 1] - points[index]
				player.model.rotation = Vector3(-0.9, atan2(heading.x, heading.z), sin(t * 30.0) * 0.12)
				break
			walked += segment, 0.0, 1.0, duration)
	var wide: Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	wide.tween_property(self, "camera_offset", Vector3(0.0, 18.0, 11.5), duration * 0.4)
	wide.tween_property(self, "camera_offset", CAMERA_NORMAL, duration * 0.6)
	await slide.finished
	player.position = end
	player.model.rotation = Vector3.ZERO
	player.airborne = false
	last_safe = end
	_locked = false
	_busy = false
	_chute_cooldown = CHUTE_COOLDOWN
	_spawn_grace = 1.0
	_shake = 0.7
	Audio.sfx(&"land_play", -2.0)
	hud.toast(story.text("fx.slid"), UIStyle.GOOD)
	_floating_text("WHEEE!", Color("9be05a"))
	_puff(end)
	Session.bump_counter(HeapZone.COUNTER_SLIDES)
	Session.refresh_quests()
	Session.save_game()


# ---- Falling into the stream or a compost pit ------------------------------------------------------------------


## Stepped off a bridge (or waded in): splash, sink, respawn at the last safe spot with 1 damage to the zone life
## (logged in the zone log), and wake at the hub instead if that was the last life.
func _fall_into_hazard() -> void:
	_falling = true
	_locked = true
	player.airborne = true
	_dismount(false)
	var start: Vector3 = player.position
	var in_pit: bool = false
	for pit: Vector3 in heap.layout.pits:
		if Vector2(start.x - pit.x, start.z - pit.y).length() <= pit.z + 0.2:
			in_pit = true
	Audio.sfx(&"splash", 0.0, 0.1)
	hud.toast("Splorch!" if in_pit else "Splash!", Color("ffcf70"))
	_splash(start, in_pit)
	var sink: Tween = create_tween()
	sink.tween_method(func(t: float) -> void:
		player.position = start + Vector3(0.0, -t * 1.2, 0.0)
		player.model.scale = Vector3.ONE * TownPlayer.MODEL_SCALE * (1.0 - t * 0.5), 0.0, 1.0, 0.7)
	var fade: ColorRect = ColorRect.new()
	fade.color = Color(0.2, 0.3, 0.1, 0) if in_pit else Color(0.2, 0.55, 0.55, 0)
	UIKit.full_rect(fade)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay_layer.add_child(fade)
	var to_color: Tween = create_tween()
	to_color.tween_interval(0.35)
	to_color.tween_property(fade, "color:a", 1.0, 0.4)
	await sink.finished
	player.model.scale = Vector3.ONE * TownPlayer.MODEL_SCALE
	player.model.rotation = Vector3.ZERO
	player.position = last_safe
	_camera.position = player.position + camera_offset
	var run: ZoneRun = Session.zone_run
	var place: String = "the compost pit" if in_pit else "the Recycling Stream"
	HeapInteractables.apply_hazard_fall(run, place, story.text("fx.hazard_fall_log"))
	EventBus.zone_life_changed.emit(run.life, run.max_life())
	hud.toast(story.text("fx.hazard_fall"), Color("ff8a85"))
	Audio.sfx(&"hit_heavy", -2.0)
	_floating_text("-%d" % HeapZone.HAZARD_DAMAGE, Color("ff6a60"))
	var back: Tween = create_tween()
	back.tween_property(fade, "color:a", 0.0, 0.5)
	await back.finished
	fade.queue_free()
	player.airborne = false
	_locked = false
	_falling = false
	_invulnerable = 1.5
	_spawn_grace = 1.0
	_safe_timer = 0.5
	Session.save_game()
	if run.is_down():
		_faint("fell into %s" % place)


func _splash(pos: Vector3, sludge: bool) -> void:
	var drops: CPUParticles3D = CPUParticles3D.new()
	drops.one_shot = true
	drops.amount = 40
	drops.lifetime = 1.0
	drops.explosiveness = 1.0
	drops.direction = Vector3.UP
	drops.spread = 55.0
	drops.initial_velocity_min = 3.0
	drops.initial_velocity_max = 6.0
	drops.gravity = Vector3(0, -10.0, 0)
	drops.scale_amount_min = 0.6
	drops.scale_amount_max = 1.4
	var drop: SphereMesh = SphereMesh.new()
	drop.radius = 0.13
	drop.height = 0.26
	drop.radial_segments = 6
	drop.rings = 3
	drops.mesh = drop
	drops.material_override = HeapMaterials.flat(HeapMaterials.SLUDGE if sludge else HeapMaterials.RECYCLED_WATER)
	drops.position = Vector3(pos.x, HeapLayout.WATER_LEVEL + 0.1, pos.z)
	add_child(drops)
	drops.emitting = true
	get_tree().create_timer(1.8).timeout.connect(drops.queue_free)


# ---- Dressing: hats, pickups, escaped animals ----------------------------------------------------------------------


func _add_hats() -> void:
	for entry: Dictionary in def.npcs:
		var npc: Node3D = _npcs.get(str(entry["id"])) as Node3D
		if npc == null or not entry.has("hat"):
			continue
		var hat: Node3D = Node3D.new()
		match str(entry["hat"]):
			"wreath":
				for index: int in range(10):
					var angle: float = TAU * float(index) / 10.0
					BuffetProps.ball(hat, 0.1, HeapMaterials.flat(HeapMaterials.MOSS if index % 2 == 0 else HeapMaterials.BLOOM), Vector3(cos(angle) * 0.42, 0.05, sin(angle) * 0.42))
			"straw":
				BuffetProps.cylinder(hat, 0.75, 0.75, 0.06, HeapMaterials.flat(HeapMaterials.STRAW), Vector3(0, 0.05, 0), 14)
				BuffetProps.cylinder(hat, 0.36, 0.42, 0.34, HeapMaterials.flat(HeapMaterials.STRAW.darkened(0.1)), Vector3(0, 0.22, 0), 12)
			"cap":
				BuffetProps.ball(hat, 0.42, HeapMaterials.flat(Color(0.3, 0.45, 0.3)), Vector3(0, 0.05, 0), Vector3(1.0, 0.7, 1.0), true)
				BuffetProps.box(hat, Vector3(0.5, 0.05, 0.4), HeapMaterials.flat(Color(0.25, 0.4, 0.25)), Vector3(0, 0.05, 0.45))
			_:
				BuffetProps.cylinder(hat, 0.3, 0.3, 0.1, HeapMaterials.flat(Color(0.2, 0.35, 0.8)), Vector3(0.4, 0.1, 0.3), 12)
				BuffetProps.ball(hat, 0.1, HeapMaterials.glow(Color(1.0, 0.85, 0.2), 0.8), Vector3(0.4, 0.15, 0.3))
				BuffetProps.cylinder(hat, 0.34, 0.38, 0.28, HeapMaterials.flat(Color(0.18, 0.3, 0.7)), Vector3(0, 0.14, 0), 12)
		hat.position = Vector3(0, 2.0, 0.0)
		npc.add_child(hat)


func _build_spots() -> void:
	super._build_spots()
	for pickup_id: String in HeapZone.PICKUPS.keys():
		var pos: Vector3 = builder.anchor("pickup_" + pickup_id)
		var node: Node3D = _pickup_model(HeapZone.pickup_kind(pickup_id))
		add_child(node)
		node.position = pos
		node.visible = not HeapInteractables.picked_this_visit(Session.zone_run, pickup_id)
		_pickup_nodes[pickup_id] = node
	var kinds: Array[String] = ["goat", "pig", "raccoon"]
	for number: int in range(1, HeapGrowth.ESCAPED_ANIMALS + 1):
		var animal: Node3D = HeapMobs.animal(kinds[number - 1])
		add_child(animal)
		animal.scale = Vector3.ONE * 0.95
		animal.position = builder.anchor("animal_%d" % number)
		animal.rotation_degrees.y = float(number) * 80.0
		var animation: AnimationPlayer = ModelKit.animation_player(animal)
		if animation != null and animation.has_animation("eat"):
			animation.play("eat")
		animal.visible = not HeapInteractables.herded_this_visit(Session.zone_run, number)
		_animal_nodes[number] = animal
		builder.add_blocker(animal.position, 0.5)


func _pickup_model(kind: String) -> Node3D:
	var holder: Node3D = Node3D.new()
	match kind:
		"bean":
			BuffetProps.ball(holder, 0.22, HeapMaterials.glow(Color(0.6, 1.0, 0.35), 1.2), Vector3(0, 0.3, 0), Vector3(0.7, 1.0, 0.7))
			BuffetProps.ball(holder, 0.1, HeapMaterials.glow(Color(1.0, 1.0, 0.7), 1.5), Vector3(-0.05, 0.42, 0.1))
		"fert":
			BuffetProps.cylinder(holder, 0.32, 0.4, 0.55, HeapMaterials.flat(Color(0.55, 0.4, 0.22)), Vector3(0, 0.28, 0), 10)
			BuffetProps.ball(holder, 0.16, HeapMaterials.flat(Color(0.5, 0.35, 0.18)), Vector3(0, 0.62, 0))
			BuffetProps.box(holder, Vector3(0.4, 0.14, 0.04), HeapMaterials.flat(Color(0.3, 0.7, 0.3)), Vector3(0, 0.32, 0.36))
		_:
			HeapModels.put(holder, HeapModels.survival("box"), Vector3(0, 0, 0), 20.0, 2.4)
			HeapModels.put(holder, HeapModels.survival("bucket"), Vector3(0.3, 0, 0.2), 0.0, 2.6)
			BuffetProps.ball(holder, 0.08, HeapMaterials.glow(Color(1.0, 0.9, 0.4), 1.5), Vector3(0, 0.9, 0))
	var ring: MeshInstance3D = BuffetProps.cylinder(holder, 0.55, 0.55, 0.03, HeapMaterials.glow(Color(1.0, 0.9, 0.4), 0.8), Vector3(0, 0.03, 0), 16)
	ring.name = "Ring"
	return holder


# ---- Screenshot helpers ---------------------------------------------------------------------------------------------


func _teleport(anchor_name: String) -> void:
	if anchor_name == "bridge_center_mid":
		var zc: float = HeapLayout.stream_z(50.0)
		player.position = Vector3(50.0, 0.12, zc)
		_camera.position = player.position + camera_offset
		_spawn_grace = 30.0
		return
	super._teleport(anchor_name)
