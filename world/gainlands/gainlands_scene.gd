class_name GainlandsScene
extends ZoneScene
## The playable Gainlands (Beefcake zone). The shared zone framework (`ZoneScene`) provides the hub,
## life rules, enemies, chests, quiz/minigame/puzzle launchers and the minimap; this subclass adds
## what is unique here: the bright look and wind, the TRAVEL NETWORK (Beefcake throwers that hurl you
## in an arc with the camera following, portal rippers that tear open a portal), falling off the
## floating islands (respawn at the last safe spot, 1 damage, logged), and the interactables (hamster
## wheel, protein shake stand, flex mirrors, "spot me" Gary).

const SAFE_INTERVAL: float = 0.2
const RIM_SAFE_DISTANCE: float = 1.8
const GROUND_SAFE_EDGE: float = 2.5

## The layout/map (typed access to the Gainlands' own builder).
var gain: GainlandsBuilder
var dressing: GainlandsDressing
var cloud_fader: CloudFader
## The last place the player stood safely (where a fall puts them back).
var last_safe: Vector3 = Vector3.ZERO
var _safe_timer: float = 0.0
var _falling: bool = false
var _streaks_added: bool = false
var _shake: float = 0.0
var _busy_travel: bool = false


func _zone_id() -> String:
	return GainlandsZone.ID


func _make_map() -> ZoneMap:
	gain = GainlandsBuilder.new()
	return gain


func _build_environment() -> void:
	add_child(GainlandsLook.environment())
	add_child(GainlandsLook.sun())


func _build_zone_extras() -> void:
	camera_offset = Vector3(0.0, 14.5, 8.7)
	last_safe = player.position
	gain.wheel_speed = 1.8 if Session.flag(GainlandsZone.FLAG_WHEEL_POWERED) else 0.45
	dressing = GainlandsDressing.build(self, gain, Settings.graphics_quality)
	cloud_fader = CloudFader.new()
	cloud_fader.camera = _camera
	cloud_fader.target = player
	add_child(cloud_fader)
	for cloud: Node3D in gain.cloud_nodes():
		cloud_fader.adopt(cloud, 6.0)
	for point: GainlandsTravel.Point in GainlandsTravel.points():
		var npc: Node3D = _npcs.get(point.id) as Node3D
		if npc != null:
			npc.rotation.y = deg_to_rad(180.0)


func _make_puzzle_screen() -> OverlayScreen:
	return WheelPuzzleScreen.new()


func _make_minigame_screen() -> OverlayScreen:
	return RepGameScreen.new()


func _hub_spawn() -> Vector3:
	return builder.anchor("spawn")


func _prompt_for(spot: ZoneSpot) -> String:
	if spot.data.has("travel"):
		var point: GainlandsTravel.Point = GainlandsTravel.find(str(spot.data["travel"]))
		if point != null and not GainlandsTravel.is_unlocked(point, Session.unlock_state()):
			return "Ask %s about the ride (locked)" % point.speaker
	return spot.prompt


func _extra_pois() -> Array[MapPoi]:
	var result: Array[MapPoi] = []
	var state: UnlockState = Session.unlock_state()
	for point: GainlandsTravel.Point in GainlandsTravel.points():
		var kind: MapPoi.Kind = MapPoi.Kind.TRAVEL_THROW if point.kind == "throw" else MapPoi.Kind.TRAVEL_PORTAL
		result.append(MapPoi.make(kind, builder.anchor(point.anchor), point.title, false, not GainlandsTravel.is_unlocked(point, state)))
	return result


func _zone_process(delta: float) -> void:
	gain.animate(delta)
	var target_speed: float = 1.8 if Session.flag(GainlandsZone.FLAG_WHEEL_POWERED) else 0.45
	if not player.airborne:
		gain.wheel_speed = lerpf(gain.wheel_speed, target_speed, minf(delta * 1.5, 1.0))
	if not _streaks_added and _camera != null:
		_streaks_added = true
		_camera.add_child(GainlandsLook.wind_streaks())
	if _shake > 0.0:
		_camera.position += Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), 0.0) * _shake * 0.18
		_shake = maxf(0.0, _shake - delta * 2.4)
	if player.airborne or _falling or _fainting:
		return
	var island: GainlandsLayout.Island = gain.fall_island(player.position)
	if island != null and not _locked:
		_fall_off(island)
		return
	_safe_timer -= delta
	if _safe_timer <= 0.0:
		_safe_timer = SAFE_INTERVAL
		_track_safe_spot()


## Remembers where the player is standing safely (well inside the ground or an island).
func _track_safe_spot() -> void:
	var pos: Vector3 = player.position
	var layout: GainlandsLayout = gain.layout
	match layout.surface_at(pos.x, pos.z):
		GainlandsLayout.Surface.GROUND:
			if layout.main_edge_distance(pos.x, pos.z) >= GROUND_SAFE_EDGE:
				last_safe = pos
		GainlandsLayout.Surface.ISLAND:
			var island: GainlandsLayout.Island = layout.island_at(pos.x, pos.z)
			if island != null and Vector2(pos.x - island.center.x, pos.z - island.center.y).length() <= island.radius - RIM_SAFE_DISTANCE:
				last_safe = pos


func _interact_zone(spot: ZoneSpot) -> void:
	if spot.data.has("travel"):
		_use_travel(GainlandsTravel.find(str(spot.data["travel"])))
		return
	match spot.id:
		"protein_stand":
			_use_protein_stand(spot)
		"flex_mirror", "flex_mirror_pec":
			_use_flex_mirror(spot)
		"spot_me":
			_use_spot_me()
		"run_wheel":
			_use_run_wheel(spot)


# ---- Travel: throwers and portal rippers -------------------------------------------------------------


func _use_travel(point: GainlandsTravel.Point) -> void:
	if point == null or _busy_travel:
		return
	_face_npc(point.id)
	if not GainlandsTravel.is_unlocked(point, Session.unlock_state()):
		Audio.sfx(&"ui_error")
		_say(point.speaker, story.get_lines(point.lock_key()))
		return
	_say(point.speaker, story.get_lines("travel.%s.intro" % point.id), func() -> void: _ask_travel(point))


func _ask_travel(point: GainlandsTravel.Point) -> void:
	_locked = true
	var destination: String = story.text("travel.dest.%s" % point.dest_anchor)
	var ask_key: String = "travel.throw.ask" if point.kind == "throw" else "travel.portal.ask"
	var dialog: ConfirmDialog = ConfirmDialog.ask(_overlay_layer, point.title, story.text(ask_key) % destination, "Throw me!" if point.kind == "throw" else "Step through", "Not yet")
	dialog.confirmed.connect(func() -> void:
		if point.kind == "throw":
			_start_throw(point)
		else:
			_start_portal(point))
	dialog.cancelled.connect(func() -> void: _locked = false)


## A satisfying throw: the Beefcake grabs you, winds up, and hurls you in an arc (the camera pulls
## out and follows); you tumble through the air and land with dust, an impact ring and a shake.
func _start_throw(point: GainlandsTravel.Point) -> void:
	_busy_travel = true
	_locked = true
	player.airborne = true
	var thrower: Node3D = _npcs.get(point.id) as Node3D
	var end: Vector3 = builder.anchor(point.dest_anchor)
	var animation: AnimationPlayer = ModelKit.animation_player(thrower) if thrower != null else null
	var grab_point: Vector3 = (thrower.position if thrower != null else player.position) + Vector3(0.0, 1.5, 0.35)
	var grab: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	grab.tween_property(player, "position", grab_point, 0.35)
	Audio.sfx(&"ui_select")
	await grab.finished
	if animation != null and animation.has_animation("Throw"):
		animation.play("Throw")
	await get_tree().create_timer(0.3).timeout
	Audio.sfx(&"attack", -2.0, 0.15)
	Audio.sfx(&"hit_heavy", -4.0, 0.1)
	hud.toast(story.text("fx.thrown"), UIStyle.GOLD)
	var from: Vector3 = player.position
	var distance: float = Vector2(end.x - from.x, end.z - from.z).length()
	var duration: float = clampf(1.0 + distance * 0.045, 1.5, 3.4)
	var apex: float = clampf(3.0 + distance * 0.28, 5.0, 16.0)
	var yaw: float = atan2(end.x - from.x, end.z - from.z)
	var spin_turns: float = 2.0
	var fly: Tween = create_tween()
	fly.tween_method(func(t: float) -> void:
		var p: Vector3 = from.lerp(end, t)
		p.y = lerpf(from.y, end.y, t) + apex * 4.0 * t * (1.0 - t)
		player.position = p
		player.model.rotation = Vector3(t * TAU * spin_turns, yaw, 0.0), 0.0, 1.0, duration)
	var wide: Vector3 = Vector3(0.0, 20.0, 12.0)
	var pull: Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pull.tween_property(self, "camera_offset", wide, duration * 0.45)
	pull.tween_property(self, "camera_offset", Vector3(0.0, 14.5, 8.7), duration * 0.55)
	await fly.finished
	_land(end, yaw)
	if animation != null and animation.has_animation("Idle"):
		animation.play("Idle")
	Session.bump_counter(GainlandsTravel.COUNTER_THROWS)
	Session.refresh_quests()
	await get_tree().create_timer(0.5).timeout
	_busy_travel = false


func _land(pos: Vector3, yaw: float) -> void:
	player.position = pos
	player.model.rotation = Vector3(0.0, yaw, 0.0)
	player.airborne = false
	_locked = false
	last_safe = pos
	_spawn_grace = 1.0
	_invulnerable = 0.5
	_shake = 1.0
	Audio.sfx(&"hit_heavy", 0.0, 0.05)
	Audio.sfx(&"land_play", -2.0)
	hud.toast(story.text("fx.landed"), UIStyle.GOOD)
	_floating_text("THUD!", Color("ffe14d"))
	_dust_burst(pos)
	_impact_ring(pos)
	Session.save_game()


func _dust_burst(pos: Vector3) -> void:
	var dust: CPUParticles3D = CPUParticles3D.new()
	dust.one_shot = true
	dust.amount = 34
	dust.lifetime = 1.0
	dust.explosiveness = 1.0
	dust.direction = Vector3.UP
	dust.spread = 80.0
	dust.initial_velocity_min = 2.0
	dust.initial_velocity_max = 5.0
	dust.gravity = Vector3(0, -1.5, 0)
	dust.scale_amount_min = 0.7
	dust.scale_amount_max = 1.6
	var puff: SphereMesh = SphereMesh.new()
	puff.radius = 0.2
	puff.height = 0.4
	puff.radial_segments = 6
	puff.rings = 3
	dust.mesh = puff
	dust.material_override = GainlandsMaterials.translucent(Color(0.92, 0.85, 0.7), 0.55, 0.15)
	dust.position = pos + Vector3(0, 0.15, 0)
	add_child(dust)
	dust.emitting = true
	get_tree().create_timer(1.6).timeout.connect(dust.queue_free)


func _impact_ring(pos: Vector3) -> void:
	var ring: MeshInstance3D = MeshInstance3D.new()
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = 0.35
	torus.outer_radius = 0.5
	torus.rings = 20
	torus.ring_segments = 4
	ring.mesh = torus
	var material: StandardMaterial3D = GainlandsMaterials.translucent(Color(1.0, 0.95, 0.8), 0.8, 0.6).duplicate() as StandardMaterial3D
	ring.material_override = material
	ring.position = pos + Vector3(0, 0.12, 0)
	add_child(ring)
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(ring, "scale", Vector3(6.0, 1.0, 6.0), 0.55).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(material, "albedo_color:a", 0.0, 0.55)
	tween.chain().tween_callback(ring.queue_free)


## A portal ripper physically tears open a portal; you step in and come out at the linked place.
func _start_portal(point: GainlandsTravel.Point) -> void:
	_busy_travel = true
	_locked = true
	var ripper: Node3D = _npcs.get(point.id) as Node3D
	var animation: AnimationPlayer = ModelKit.animation_player(ripper) if ripper != null else null
	if animation != null and animation.has_animation("Interact"):
		animation.play("Interact")
	var spot_pos: Vector3 = (ripper.position if ripper != null else player.position) + Vector3(0.0, 0.0, 1.9)
	var portal: Node3D = _make_portal(spot_pos + Vector3(0, 1.2, 0))
	Audio.sfx(&"attack", 0.0, 0.3)
	Audio.sfx(&"spell", -2.0, 0.1)
	hud.toast(story.text("fx.portal"), Color("7ff5ea"))
	var open: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	open.tween_property(portal, "scale", Vector3.ONE, 0.8)
	await open.finished
	player.airborne = true
	var walk_in: Tween = create_tween().set_parallel(true)
	walk_in.tween_property(player, "position", spot_pos, 0.55)
	walk_in.tween_property(player.model, "scale", Vector3.ONE * 0.02, 0.55)
	player.face(spot_pos)
	await walk_in.finished
	_flash.color = Color(0.6, 1.0, 0.95, 1.0)
	create_tween().tween_property(_flash, "color:a", 0.0, 0.6)
	var dest: Vector3 = builder.anchor(point.dest_anchor)
	player.position = dest
	player.model.rotation = Vector3(0.0, 0.0, 0.0)
	_camera.position = player.position + camera_offset * Settings.camera_zoom
	var out_portal: Node3D = _make_portal(dest + Vector3(0, 1.2, 0))
	out_portal.scale = Vector3.ONE
	Audio.sfx(&"spell", -3.0, 0.2)
	var step_out: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	step_out.tween_property(player.model, "scale", Vector3.ONE * TownPlayer.MODEL_SCALE, 0.5)
	player.airborne = false
	last_safe = dest
	_spawn_grace = 1.0
	await step_out.finished
	var close: Tween = create_tween()
	close.tween_property(out_portal, "scale", Vector3.ONE * 0.01, 0.5)
	close.parallel().tween_property(portal, "scale", Vector3.ONE * 0.01, 0.5)
	await close.finished
	portal.queue_free()
	out_portal.queue_free()
	_locked = false
	Session.bump_counter(GainlandsTravel.COUNTER_PORTALS)
	Session.refresh_quests()
	Session.save_game()
	if animation != null and animation.has_animation("Idle"):
		animation.play("Idle")
	_busy_travel = false


## A torn-open portal: a glowing ragged ring, a swirling disc and sparks. Starts at scale 0.
func _make_portal(pos: Vector3) -> Node3D:
	var root_node: Node3D = Node3D.new()
	root_node.position = pos
	root_node.scale = Vector3.ONE * 0.01
	add_child(root_node)
	var torus: TorusMesh = TorusMesh.new()
	torus.inner_radius = 1.05
	torus.outer_radius = 1.3
	torus.rings = 6
	torus.ring_segments = 5
	var ring: MeshInstance3D = MeshInstance3D.new()
	ring.mesh = torus
	ring.material_override = GainlandsMaterials.glow(Color(0.35, 1.0, 0.95), 2.8)
	ring.rotation_degrees = Vector3(90, 0, 0)
	ring.scale = Vector3(0.75, 1.0, 1.0)
	root_node.add_child(ring)
	var disc: CylinderMesh = CylinderMesh.new()
	disc.top_radius = 1.0
	disc.bottom_radius = 1.0
	disc.height = 0.04
	disc.radial_segments = 14
	var swirl: MeshInstance3D = MeshInstance3D.new()
	swirl.mesh = disc
	swirl.material_override = GainlandsMaterials.translucent(Color(0.5, 0.2, 0.9), 0.7, 1.4)
	swirl.rotation_degrees = Vector3(90, 0, 0)
	swirl.scale = Vector3(0.72, 1.0, 1.0)
	root_node.add_child(swirl)
	var sparks: CPUParticles3D = CPUParticles3D.new()
	sparks.amount = 24
	sparks.lifetime = 0.8
	sparks.direction = Vector3(0, 0, 1)
	sparks.spread = 180.0
	sparks.initial_velocity_min = 1.0
	sparks.initial_velocity_max = 3.0
	sparks.gravity = Vector3.ZERO
	var spark_mesh: BoxMesh = BoxMesh.new()
	spark_mesh.size = Vector3(0.06, 0.06, 0.3)
	sparks.mesh = spark_mesh
	sparks.material_override = GainlandsMaterials.glow(Color(0.7, 1.0, 1.0), 3.0)
	sparks.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
	sparks.emission_sphere_radius = 1.0
	root_node.add_child(sparks)
	return root_node


# ---- Falling off an island -----------------------------------------------------------------------------


## Fell past an island's rim: tumble down, fade out, respawn at the last safe spot with 1 damage to the
## zone life (logged in the zone log), and wake at the hub instead if that was the last life.
func _fall_off(island: GainlandsLayout.Island) -> void:
	_falling = true
	_locked = true
	player.airborne = true
	var start: Vector3 = player.position
	var drift: Vector3 = (start - Vector3(island.center.x, start.y, island.center.y)).normalized() * 3.0
	Audio.sfx(&"death", -6.0)
	hud.toast("Aaaaaah!", Color("ffcf70"))
	var fall: Tween = create_tween()
	fall.tween_method(func(t: float) -> void:
		player.position = start + drift * t + Vector3(0.0, -t * t * 30.0, 0.0)
		player.model.rotation = Vector3(t * TAU * 2.0, player.model.rotation.y, t * TAU), 0.0, 1.0, 1.0)
	var fade: ColorRect = ColorRect.new()
	fade.color = Color(1, 1, 1, 0)
	UIKit.full_rect(fade)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay_layer.add_child(fade)
	var to_white: Tween = create_tween()
	to_white.tween_interval(0.55)
	to_white.tween_property(fade, "color:a", 1.0, 0.45)
	await fall.finished
	player.model.rotation = Vector3(0.0, 0.0, 0.0)
	player.position = last_safe
	_camera.position = player.position + camera_offset * Settings.camera_zoom
	var run: ZoneRun = Session.zone_run
	GainlandsInteractables.apply_fall(run, island.title, story.text("fx.fall_log"))
	EventBus.zone_life_changed.emit(run.life, run.max_life())
	hud.toast(story.text("fx.fall"), Color("ff8a85"))
	Audio.sfx(&"hit_heavy", -2.0)
	_floating_text("-%d" % GainlandsZone.FALL_DAMAGE, Color("ff6a60"))
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
		_faint("fell off %s" % island.title)


# ---- Interactables ----------------------------------------------------------------------------------------


func _use_protein_stand(spot: ZoneSpot) -> void:
	player.face(spot.position)
	if Session.gold < GainlandsInteractables.SHAKE_COST:
		Audio.sfx(&"ui_error")
		hud.toast(story.text("fx.shake_broke"), UIStyle.MUTED)
		return
	Session.spend_gold(GainlandsInteractables.SHAKE_COST)
	var outcome: String = GainlandsInteractables.shake_outcome(Session.rng.randf())
	var effect: String = GainlandsInteractables.apply_shake(Session.zone_run, outcome)
	Session.bump_counter(GainlandsZone.COUNTER_SHAKES)
	Session.refresh_quests()
	var good: bool = outcome in ["good", "great", "buff", "gold"]
	Audio.sfx(&"heal" if outcome in ["good", "great", "buff"] else (&"coins" if outcome == "gold" else &"hit_light"))
	hud.toast("%s %s" % [story.text("fx.shake_" + outcome), effect], UIStyle.GOOD if good else Color("ff8a85"))
	hud.set_gold(Session.gold)
	EventBus.zone_life_changed.emit(Session.zone_run.life, Session.zone_run.max_life())
	Session.save_game()


func _use_flex_mirror(spot: ZoneSpot) -> void:
	player.face(spot.position)
	var run: ZoneRun = Session.zone_run
	if not GainlandsInteractables.can_flex(run):
		Audio.sfx(&"ui_error")
		hud.toast(story.text("fx.flex_limit"), UIStyle.MUTED)
		return
	var result: Dictionary = GainlandsInteractables.flex(run)
	Session.refresh_quests()
	Audio.sfx(&"heal" if int(result["healed"]) > 0 else &"ui_confirm")
	var key: String = "fx.flex_%d" % int(result["number"]) if int(result["healed"]) > 0 else "fx.flex_full"
	hud.toast(story.text(key), UIStyle.GOOD)
	EventBus.zone_life_changed.emit(run.life, run.max_life())
	Session.save_game()


func _use_spot_me() -> void:
	_face_npc("gary")
	_say("Gary", _greeting("gary"), func() -> void:
		var result: Dictionary = GainlandsInteractables.spot_gary(Session.zone_run)
		if bool(result["ok"]):
			Audio.sfx(&"victory", -6.0)
			hud.toast("Spotted Gary! +%d max life this visit%s" % [GainlandsInteractables.SPOT_MAX_LIFE_BONUS, (", +%d gold" % int(result["gold"])) if int(result["gold"]) > 0 else ""], UIStyle.GOLD)
			hud.set_gold(Session.gold)
			EventBus.zone_life_changed.emit(Session.zone_run.life, Session.zone_run.max_life())
			_say("Gary", story.get_lines("fx.spot_done"))
		else:
			_say("Gary", story.get_lines("fx.spot_again"))
		Session.save_game())


## Running the colossal wheel: you hop in, run, the grid lights up (once ever), then you hop out.
func _use_run_wheel(spot: ZoneSpot) -> void:
	if _busy_travel:
		return
	if Session.flag(GainlandsZone.FLAG_WHEEL_POWERED):
		hud.toast(story.text("fx.wheel_again"), UIStyle.MUTED)
		return
	_busy_travel = true
	_locked = true
	var inside: Vector3 = builder.anchor("run_wheel") + Vector3(0.0, 0.0, -4.4)
	inside.y = builder.height_at(inside) + 0.8
	player.airborne = true
	var hop: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	hop.tween_property(player, "position", inside, 0.7)
	player.face(inside + Vector3(0, 0, -1))
	await hop.finished
	player.model.rotation.y = PI
	player.forced_animation = &"Running_A"
	gain.wheel_speed = 4.5
	Audio.sfx(&"footstep", -4.0, 0.2)
	for beat: int in range(8):
		Audio.sfx(&"footstep", -6.0, 0.25)
		_shake = 0.25
		await get_tree().create_timer(0.38).timeout
	player.forced_animation = &""
	var first: bool = GainlandsInteractables.run_wheel()
	var out: Vector3 = builder.anchor("run_wheel")
	var drop: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	drop.tween_property(player, "position", out, 0.5)
	await drop.finished
	player.airborne = false
	player.model.rotation.y = 0.0
	last_safe = out
	_locked = false
	_busy_travel = false
	Audio.sfx(&"level_up", -4.0)
	hud.toast("The grid is powered!" if first else story.text("fx.wheel_again"), UIStyle.GOLD)
	_say("Narrator", story.get_lines("fx.wheel_run"))
	Session.save_game()


# ---- Screenshot helpers ---------------------------------------------------------------------------------


func _teleport(anchor_name: String) -> void:
	if anchor_name == "wheel_inside":
		var inside: Vector3 = builder.anchor("run_wheel") + Vector3(0.0, 0.0, -4.4)
		inside.y = builder.height_at(inside) + 0.8
		player.position = inside
		player.airborne = true
		player.forced_animation = &"Running_A"
		player.model.rotation.y = PI
		_camera.position = player.position + camera_offset * Settings.camera_zoom
		_spawn_grace = 30.0
		return
	if anchor_name == "wheel_inside":
		return
	super._teleport(anchor_name)
