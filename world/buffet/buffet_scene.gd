class_name BuffetScene
extends ZoneScene
## The playable Endless Buffet (Gourmand zone). The shared zone framework (`ZoneScene`) provides the hub,
## HP rules, enemies, chests, quiz/minigame/puzzle launchers and the minimap; this subclass adds what is
## unique here: the warm look and drifting sprinkles, the jelly BOUNCE PADS (step on one and get launched to a
## higher mesa), the crouton RAFTS and the rotating LAZY SUSAN that carry you across the gravy river, falling into
## the soup (respawn at the last safe spot for 1 zone HP, logged), the golem GATES (ingredient / quest / battle),
## the ingredient pickups and the interactables (oven, taste test, soup fountain, fortune cookies, Old Meatloaf).

const SAFE_INTERVAL: float = 0.2
const SOUP_SAFE_DISTANCE: float = 2.0
const PAD_COOLDOWN: float = 1.2
const CAMERA_NORMAL: Vector3 = Vector3(0.0, 14.0, 9.4)

## The layout/map (typed access to the Buffet's own builder).
var buf: BuffetBuilder
## The last place the player stood safely (where a fall into the soup puts them back).
var last_safe: Vector3 = Vector3.ZERO
var _safe_timer: float = 0.0
var _falling: bool = false
var _sprinkles_added: bool = false
var _shake: float = 0.0
var _busy: bool = false
var _pad_cooldown: float = 0.0
var _riding: Dictionary = {}
var _gate_dialogue_open: bool = false


func _zone_id() -> String:
	return BuffetZone.ID


func _make_map() -> ZoneMap:
	buf = BuffetBuilder.new()
	return buf


func _build_environment() -> void:
	add_child(BuffetLook.environment())
	add_child(BuffetLook.sun())


func _build_zone_extras() -> void:
	camera_offset = CAMERA_NORMAL
	last_safe = player.position
	_add_chef_hats()
	_restore_gates()
	for gate: BuffetGates.Gate in BuffetGates.gates():
		var golem: Node3D = buf.gate_nodes.get(gate.id) as Node3D
		if golem != null and not buf.is_gate_open(gate.id):
			golem.rotation.y = 0.0


func _make_puzzle_screen() -> OverlayScreen:
	return RecipePuzzleScreen.new()


func _make_minigame_screen() -> OverlayScreen:
	return OrderGameScreen.new()


func _hub_spawn() -> Vector3:
	return builder.anchor("spawn")


func _prompt_for(spot: ZoneSpot) -> String:
	if spot.data.has("gate"):
		var gate: BuffetGates.Gate = BuffetGates.find(str(spot.data["gate"]))
		if gate != null and BuffetInteractables.gate_is_open(gate):
			return "Chat with %s" % gate.speaker
		if gate != null and gate.kind == "battle":
			return "Challenge %s to a card battle" % gate.speaker
		return "Speak to %s" % (gate.speaker if gate != null else "the golem")
	if spot.data.has("pickup"):
		var id: String = str(spot.data["pickup"])
		if BuffetInteractables.picked_this_visit(Session.zone_run, id):
			return "Already picked up this visit"
	return spot.prompt




func _extra_pois() -> Array[MapPoi]:
	var result: Array[MapPoi] = []
	for pad: BuffetLayout.Pad in buf.layout.pads:
		if pad.id.ends_with("_back"):
			continue
		result.append(MapPoi.make(MapPoi.Kind.BOUNCE_PAD, Vector3(pad.pos.x, 0.0, pad.pos.y), pad.title))
	for raft: BuffetLayout.Raft in buf.layout.rafts:
		var mid: Vector2 = (raft.a + raft.b) * 0.5
		result.append(MapPoi.make(MapPoi.Kind.FERRY, Vector3(mid.x, 0.0, mid.y), raft.title))
	for susan: BuffetLayout.Susan in buf.layout.susans:
		result.append(MapPoi.make(MapPoi.Kind.FERRY, Vector3(susan.center.x, 0.0, susan.center.y), susan.title))
	return result


# ---- Per-frame -----------------------------------------------------------------------------------


func _zone_process(delta: float) -> void:
	_pad_cooldown = maxf(0.0, _pad_cooldown - delta)
	if not player.airborne and not _fainting:
		_find_ride()
	buf.animate(delta)
	if not player.airborne and not _fainting:
		_carry_rider()
	if not _sprinkles_added and _camera != null:
		_sprinkles_added = true
		_camera.add_child(BuffetLook.sprinkles())
	if _shake > 0.0:
		_camera.position += Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), 0.0) * _shake * 0.18
		_shake = maxf(0.0, _shake - delta * 2.4)
	if player.airborne or _falling or _fainting:
		return
	if buf.is_in_soup(player.position) and not _locked:
		_fall_into_soup()
		return
	if not _locked and not _busy and _pad_cooldown <= 0.0:
		_check_pads()
	_safe_timer -= delta
	if _safe_timer <= 0.0:
		_safe_timer = SAFE_INTERVAL
		_track_safe_spot()


## Works out which raft or the susan the player is riding (before the platforms move this frame).
func _find_ride() -> void:
	var here: Dictionary = buf.platform_under(player.position, 0.0)
	if _riding.is_empty():
		_riding = here
		if not _riding.is_empty():
			Session.bump_counter(BuffetZone.COUNTER_RIDES)
			Session.refresh_quests()
		return
	var still: Dictionary = buf.platform_under(player.position, 0.35)
	if still.is_empty() or str(still["id"]) != str(_riding["id"]):
		_riding = here


## Moves the rider along with the platform they stand on.
func _carry_rider() -> void:
	if _riding.is_empty():
		return
	var carried: Vector3 = player.position
	if str(_riding["kind"]) == "raft":
		var shift: Vector2 = buf.raft_delta.get(str(_riding["id"]), Vector2.ZERO) as Vector2
		carried += Vector3(shift.x, 0.0, shift.y)
	else:
		var center: Vector2 = buf.layout.susans[0].center
		var offset: Vector3 = Vector3(carried.x - center.x, 0.0, carried.z - center.y).rotated(Vector3.UP, -buf.susan_delta)
		carried = Vector3(center.x + offset.x, carried.y, center.y + offset.z)
	if builder.is_walkable(carried):
		player.position = carried


## Remembers where the player is standing safely (well away from the soup, on dry ground or a mesa top).
func _track_safe_spot() -> void:
	var pos: Vector3 = player.position
	if not buf.platform_under(pos, 0.5).is_empty():
		return
	match buf.layout.surface_at(pos.x, pos.z):
		BuffetLayout.Surface.GROUND:
			if buf.layout.soup_depth(pos.x, pos.z) <= -SOUP_SAFE_DISTANCE:
				last_safe = pos
		BuffetLayout.Surface.MESA:
			var mesa: BuffetLayout.Mesa = buf.layout.mesa_at(pos.x, pos.z)
			if mesa != null and Vector2(pos.x - mesa.center.x, pos.z - mesa.center.y).length() <= mesa.radius - 0.8:
				last_safe = pos


# ---- Interactions -----------------------------------------------------------------------------------


func _interact_zone(spot: ZoneSpot) -> void:
	if spot.data.has("gate"):
		_use_gate(BuffetGates.find(str(spot.data["gate"])))
		return
	if spot.data.has("pickup"):
		_use_pickup(spot, str(spot.data["pickup"]))
		return
	match spot.id:
		"oven":
			_use_oven(spot)
		"taste_test":
			_use_taste_test(spot)
		"soup_fountain":
			_use_fountain(spot)
		"fortune_cookie":
			_use_cookie(spot)
		"old_meatloaf":
			_use_old_meatloaf(spot)


func _use_pickup(spot: ZoneSpot, ingredient_id: String) -> void:
	player.face(spot.position)
	var name: String = str(BuffetZone.INGREDIENTS[ingredient_id])
	if not BuffetInteractables.pick_up(Session.zone_run, ingredient_id):
		Audio.sfx(&"ui_error")
		hud.toast(story.text("fx.pickup_again"), UIStyle.MUTED)
		return
	Audio.sfx(&"coins", -4.0, 0.2)
	hud.toast("%s %s" % [story.text("fx.pickup"), name], UIStyle.GOLD)
	_floating_text("+1 %s" % name, UIStyle.GOLD)
	var node: Node3D = _pickup_nodes.get(ingredient_id) as Node3D
	if node != null:
		node.visible = false
	Session.save_game()


func _use_oven(spot: ZoneSpot) -> void:
	player.face(spot.position)
	if not BuffetInteractables.can_bake():
		Audio.sfx(&"ui_error")
		_say("The Grand Oven", story.get_lines("fx.oven_missing"))
		return
	BuffetInteractables.bake()
	Audio.sfx(&"turn_start", -4.0)
	Audio.sfx(&"heal", -2.0)
	hud.toast(story.text("fx.oven_done"), UIStyle.GOOD)
	_floating_text("Pot Pie!", UIStyle.GOLD)
	Session.save_game()


func _use_taste_test(spot: ZoneSpot) -> void:
	player.face(spot.position)
	if Session.gold < BuffetInteractables.TASTE_COST:
		Audio.sfx(&"ui_error")
		hud.toast(story.text("fx.taste_broke"), UIStyle.MUTED)
		return
	Session.spend_gold(BuffetInteractables.TASTE_COST)
	var outcome: String = BuffetInteractables.taste_outcome(Session.rng.randf())
	var effect: String = BuffetInteractables.apply_taste(Session.zone_run, outcome)
	Session.bump_counter(BuffetZone.COUNTER_TASTES)
	Session.refresh_quests()
	var good: bool = outcome in ["good", "great", "buff", "tip"]
	Audio.sfx(&"heal" if outcome in ["good", "great", "buff"] else (&"coins" if outcome == "tip" else &"hit_light"))
	hud.toast("%s %s" % [story.text("fx.taste_" + outcome), effect], UIStyle.GOOD if good else Color("ff8a85"))
	hud.set_gold(Session.gold)
	EventBus.zone_hp_changed.emit(Session.zone_run.hp, Session.zone_run.max_hp())
	Session.save_game()


func _use_fountain(spot: ZoneSpot) -> void:
	player.face(spot.position)
	var run: ZoneRun = Session.zone_run
	if not BuffetInteractables.can_ladle(run):
		Audio.sfx(&"ui_error")
		hud.toast(story.text("fx.fountain_limit"), UIStyle.MUTED)
		return
	var result: Dictionary = BuffetInteractables.ladle(run)
	Audio.sfx(&"heal" if int(result["healed"]) > 0 else &"ui_confirm")
	var key: String = "fx.fountain_%d" % int(result["number"]) if int(result["healed"]) > 0 else "fx.fountain_full"
	hud.toast(story.text(key), UIStyle.GOOD)
	EventBus.zone_hp_changed.emit(run.hp, run.max_hp())
	Session.save_game()


func _use_cookie(spot: ZoneSpot) -> void:
	player.face(spot.position)
	if Session.gold < BuffetInteractables.COOKIE_COST:
		Audio.sfx(&"ui_error")
		hud.toast(story.text("fx.cookie_broke"), UIStyle.MUTED)
		return
	Session.spend_gold(BuffetInteractables.COOKIE_COST)
	var hints: Array[String] = story.get_lines("fortune.hints")
	var cracked: int = int(Session.counters.get(BuffetZone.COUNTER_COOKIES, 0))
	var index: int = BuffetInteractables.fortune_index(cracked, hints.size())
	Session.bump_counter(BuffetZone.COUNTER_COOKIES)
	Session.refresh_quests()
	hud.set_gold(Session.gold)
	Audio.sfx(&"book", -2.0)
	_say("Fortune Cookie", [story.text("fx.cookie_crack"), hints[index]] as Array[String])
	Session.save_game()


func _use_old_meatloaf(spot: ZoneSpot) -> void:
	player.face(spot.position)
	if Session.flag(BuffetZone.FLAG_MENDED):
		_say("Old Meatloaf", story.get_lines("npc.old_meatloaf.mended"))
		return
	if not BuffetInteractables.can_mend():
		Audio.sfx(&"ui_error")
		_say("Old Meatloaf", story.get_lines("npc.old_meatloaf.broken"))
		return
	_say("Old Meatloaf", story.get_lines("npc.old_meatloaf.fix"), func() -> void:
		BuffetInteractables.mend()
		Audio.sfx(&"level_up", -4.0)
		hud.toast(story.text("fx.mend_done"), UIStyle.GOLD)
		Session.save_game())


# ---- Golem gates ---------------------------------------------------------------------------------------


func _use_gate(gate: BuffetGates.Gate) -> void:
	if gate == null or _gate_dialogue_open:
		return
	var golem: Node3D = buf.gate_nodes.get(gate.id) as Node3D
	if golem != null:
		var offset: Vector3 = player.position - golem.position
		golem.rotation.y = atan2(offset.x, offset.z)
	player.face(golem.position if golem != null else player.position)
	if BuffetInteractables.gate_is_open(gate):
		_say(gate.speaker, story.get_lines(gate.key("open")))
		return
	if gate.kind == "battle":
		_say(gate.speaker, story.get_lines(gate.key("intro")), func() -> void: _ask_gate_battle(gate))
		return
	if BuffetGates.requirement_met(gate, Session.unlock_state()):
		_say(gate.speaker, story.get_lines(gate.key("pass")), func() -> void: _open_gate(gate))
	else:
		Audio.sfx(&"ui_error")
		_say(gate.speaker, story.get_lines(gate.key("need")))


func _ask_gate_battle(gate: BuffetGates.Gate) -> void:
	_locked = true
	var dialog: ConfirmDialog = ConfirmDialog.ask(_overlay_layer, gate.title, story.text("gate.battle.ask"), "Battle!", "Not yet")
	dialog.confirmed.connect(func() -> void:
		var run: ZoneRun = Session.zone_run
		var back: Vector3 = player.position + Vector3(0, 0, 0.8)
		run.return_position = back if builder.is_walkable(back) else player.position
		run.has_return_position = true
		hud.toast("%s draws a ladle..." % gate.speaker, Color("ff8a85"))
		Audio.sfx(&"turn_start")
		await get_tree().create_timer(0.6).timeout
		Session.start_zone_battle(BuffetGates.ENEMY_CASSEROLE, BuffetGates.INSTANCE_BATTLE))
	dialog.cancelled.connect(func() -> void: _locked = false)


## Opens a gate for good: the golem steps aside and the way is clear.
func _open_gate(gate: BuffetGates.Gate) -> void:
	BuffetInteractables.open_gate(gate)
	buf.open_gate(gate.id)
	Audio.sfx(&"door")
	Audio.sfx(&"hit_heavy", -6.0, 0.1)
	hud.toast(story.text("fx.gate_open"), UIStyle.GOOD)
	_shake = 0.6
	var golem: Node3D = buf.gate_nodes.get(gate.id) as Node3D
	if golem == null:
		return
	var target: Vector3 = buf.gate_open_position(gate.id)
	var tween: Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(golem, "position", target, 1.3)
	create_tween().tween_property(golem, "rotation:y", 0.0, 1.0)
	Session.save_game()


## Gates opened on an earlier visit (or by winning the battle) start the visit open.
func _restore_gates() -> void:
	if Session.zone_run.is_defeated(BuffetGates.INSTANCE_BATTLE) and not Session.flag(BuffetZone.FLAG_GATE_BATTLE):
		Session.set_flag(BuffetZone.FLAG_GATE_BATTLE)
		Session.refresh_quests()
	for gate: BuffetGates.Gate in BuffetGates.gates():
		if not Session.flag(gate.flag):
			continue
		buf.open_gate(gate.id)
		var golem: Node3D = buf.gate_nodes.get(gate.id) as Node3D
		if golem != null:
			golem.position = buf.gate_open_position(gate.id)


# ---- Jelly bounce pads -------------------------------------------------------------------------------------


func _check_pads() -> void:
	for pad: BuffetLayout.Pad in buf.layout.pads:
		if Vector2(player.position.x - pad.pos.x, player.position.z - pad.pos.y).length() <= pad.radius:
			_bounce(pad)
			return


## BOING: the pad squashes, you rocket up in an arc (the camera pulls out and follows), tumble, and land
## squashily on the higher (or lower) ground.
func _bounce(pad: BuffetLayout.Pad) -> void:
	_busy = true
	_locked = true
	player.airborne = true
	var node: Node3D = buf.pad_nodes.get(pad.id) as Node3D
	var end: Vector3 = builder.anchor(pad.dest_anchor)
	var from: Vector3 = Vector3(pad.pos.x, buf.layout.ground_height(pad.pos.x, pad.pos.y), pad.pos.y)
	player.position = from
	Audio.sfx(&"boing", 0.0, 0.08)
	hud.toast(story.text("fx.bounce"), pad.color.lightened(0.3))
	if node != null:
		var squash: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		squash.tween_property(node, "scale", Vector3(1.3, 0.35, 1.3), 0.12)
		squash.tween_property(node, "scale", Vector3(0.85, 1.4, 0.85), 0.14)
		squash.tween_property(node, "scale", Vector3.ONE, 0.35)
	await get_tree().create_timer(0.12).timeout
	var distance: float = Vector2(end.x - from.x, end.z - from.z).length()
	var duration: float = clampf(1.0 + distance * 0.05, 1.2, 1.9)
	var apex: float = clampf(maxf(end.y, from.y) - minf(end.y, from.y) + 4.0 + distance * 0.15, 5.0, 11.0)
	var yaw: float = atan2(end.x - from.x, end.z - from.z)
	var fly: Tween = create_tween()
	fly.tween_method(func(t: float) -> void:
		var p: Vector3 = from.lerp(end, t)
		p.y = lerpf(from.y, end.y, t) + apex * 4.0 * t * (1.0 - t)
		player.position = p
		player.model.rotation = Vector3(t * TAU * 1.0, yaw, 0.0), 0.0, 1.0, duration)
	var wide: Vector3 = Vector3(0.0, 18.0, 11.0)
	var pull: Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	pull.tween_property(self, "camera_offset", wide, duration * 0.45)
	pull.tween_property(self, "camera_offset", CAMERA_NORMAL, duration * 0.55)
	await fly.finished
	_land(end, yaw)
	Session.bump_counter(BuffetZone.COUNTER_BOUNCES)
	Session.refresh_quests()
	await get_tree().create_timer(0.4).timeout
	_busy = false
	_pad_cooldown = PAD_COOLDOWN


func _land(pos: Vector3, yaw: float) -> void:
	player.position = pos
	player.model.rotation = Vector3(0.0, yaw, 0.0)
	player.airborne = false
	_locked = false
	last_safe = pos
	_spawn_grace = 1.0
	_invulnerable = 0.5
	_shake = 0.8
	Audio.sfx(&"boing", -6.0, 0.1)
	Audio.sfx(&"land_play", -2.0)
	hud.toast(story.text("fx.landed"), UIStyle.GOOD)
	_floating_text("SPLAT!", Color("ff9ad0"))
	_crumb_burst(pos)
	var squash: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	squash.tween_property(player.model, "scale", Vector3(1.35, 0.6, 1.35) * TownPlayer.MODEL_SCALE, 0.1)
	squash.tween_property(player.model, "scale", Vector3.ONE * TownPlayer.MODEL_SCALE, 0.25)
	Session.save_game()


func _crumb_burst(pos: Vector3) -> void:
	var crumbs: CPUParticles3D = CPUParticles3D.new()
	crumbs.one_shot = true
	crumbs.amount = 30
	crumbs.lifetime = 0.9
	crumbs.explosiveness = 1.0
	crumbs.direction = Vector3.UP
	crumbs.spread = 80.0
	crumbs.initial_velocity_min = 2.0
	crumbs.initial_velocity_max = 5.0
	crumbs.gravity = Vector3(0, -6.0, 0)
	crumbs.scale_amount_min = 0.5
	crumbs.scale_amount_max = 1.2
	var crumb: BoxMesh = BoxMesh.new()
	crumb.size = Vector3(0.14, 0.14, 0.14)
	crumbs.mesh = crumb
	crumbs.material_override = BuffetMaterials.flat(BuffetMaterials.TOAST)
	crumbs.position = pos + Vector3(0, 0.15, 0)
	add_child(crumbs)
	crumbs.emitting = true
	get_tree().create_timer(1.6).timeout.connect(crumbs.queue_free)


# ---- Falling into the soup ------------------------------------------------------------------------------------


## Stepped off a raft or the susan into the gravy: splash, sink, respawn at the last safe spot with 1 damage to
## the zone HP (logged in the zone log), and wake at the hub instead if that was the last HP.
func _fall_into_soup() -> void:
	_falling = true
	_locked = true
	player.airborne = true
	_riding = {}
	var start: Vector3 = player.position
	Audio.sfx(&"splash", 0.0, 0.1)
	hud.toast("Glug!", Color("ffcf70"))
	_splash(start)
	var sink: Tween = create_tween()
	sink.tween_method(func(t: float) -> void:
		player.position = start + Vector3(0.0, -t * 1.2, 0.0)
		player.model.scale = Vector3.ONE * TownPlayer.MODEL_SCALE * (1.0 - t * 0.5), 0.0, 1.0, 0.7)
	var fade: ColorRect = ColorRect.new()
	fade.color = Color(0.74, 0.38, 0.12, 0)
	UIKit.full_rect(fade)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay_layer.add_child(fade)
	var to_brown: Tween = create_tween()
	to_brown.tween_interval(0.35)
	to_brown.tween_property(fade, "color:a", 1.0, 0.4)
	await sink.finished
	player.model.scale = Vector3.ONE * TownPlayer.MODEL_SCALE
	player.model.rotation = Vector3.ZERO
	player.position = last_safe
	_camera.position = player.position + camera_offset * Settings.camera_zoom
	var run: ZoneRun = Session.zone_run
	BuffetInteractables.apply_soup_fall(run, buf.layout.area_at(start.x, start.z).title if buf.layout.area_at(start.x, start.z) != null else "the soup", story.text("fx.soup_fall_log"))
	EventBus.zone_hp_changed.emit(run.hp, run.max_hp())
	hud.toast(story.text("fx.soup_fall"), Color("ff8a85"))
	Audio.sfx(&"hit_heavy", -2.0)
	_floating_text("-%d" % BuffetZone.SOUP_DAMAGE, Color("ff6a60"))
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
		_faint("fell into the Gravy River")


func _splash(pos: Vector3) -> void:
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
	drops.material_override = BuffetMaterials.flat(BuffetMaterials.GRAVY)
	drops.position = Vector3(pos.x, BuffetLayout.SOUP_LEVEL + 0.1, pos.z)
	add_child(drops)
	drops.emitting = true
	get_tree().create_timer(1.8).timeout.connect(drops.queue_free)


# ---- Dressing: chef hats and pickups ------------------------------------------------------------------------


var _pickup_nodes: Dictionary = {}


## Every hub chef gets a toque (tall, short, pastry puff or a scholar's cap) so the play reads as cooks at a glance.
func _add_chef_hats() -> void:
	for entry: Dictionary in def.npcs:
		var npc: Node3D = _npcs.get(str(entry["id"])) as Node3D
		if npc == null or not entry.has("hat"):
			continue
		var hat: Node3D = Node3D.new()
		var kind: String = str(entry["hat"])
		var white: StandardMaterial3D = BuffetMaterials.flat(Color(1, 1, 1))
		match kind:
			"tall":
				BuffetProps.cylinder(hat, 0.36, 0.34, 0.6, white, Vector3(0, 0.3, 0), 12)
				BuffetProps.ball(hat, 0.5, white, Vector3(0, 0.78, 0), Vector3(1.0, 0.75, 1.0))
			"short":
				BuffetProps.cylinder(hat, 0.4, 0.38, 0.22, white, Vector3(0, 0.11, 0), 12)
				BuffetProps.ball(hat, 0.48, BuffetMaterials.flat(Color(0.88, 0.97, 0.85)), Vector3(0, 0.3, 0), Vector3(1.0, 0.5, 1.0))
			"pastry":
				BuffetProps.cylinder(hat, 0.38, 0.36, 0.3, BuffetMaterials.flat(BuffetMaterials.PINK), Vector3(0, 0.15, 0), 12)
				BuffetProps.ball(hat, 0.56, BuffetMaterials.flat(BuffetMaterials.PINK.lightened(0.3)), Vector3(0, 0.6, 0), Vector3(1.0, 0.8, 1.0))
				BuffetProps.ball(hat, 0.13, BuffetMaterials.glow(Color(0.9, 0.1, 0.2), 0.6), Vector3(0, 1.12, 0))
			_:
				BuffetProps.box(hat, Vector3(0.9, 0.08, 0.9), BuffetMaterials.flat(Color(0.12, 0.1, 0.16)), Vector3(0, 0.1, 0))
				BuffetProps.cylinder(hat, 0.34, 0.34, 0.2, BuffetMaterials.flat(Color(0.12, 0.1, 0.16)), Vector3(0, -0.02, 0), 10)
				BuffetProps.ball(hat, 0.07, BuffetMaterials.glow(Color(1.0, 0.85, 0.2), 0.8), Vector3(0.4, 0.0, 0.4))
		hat.position = Vector3(0, 2.0, 0.0)
		npc.add_child(hat)


func _build_spots() -> void:
	super._build_spots()
	# Pickups get a little glowing model so they can be spotted; they vanish once picked this visit.
	for ingredient_id: String in BuffetZone.INGREDIENTS.keys():
		var pos: Vector3 = builder.anchor("pickup_" + ingredient_id)
		var node: Node3D = _pickup_model(ingredient_id)
		add_child(node)
		node.position = pos
		node.visible = not BuffetInteractables.picked_this_visit(Session.zone_run, ingredient_id)
		_pickup_nodes[ingredient_id] = node


func _pickup_model(ingredient_id: String) -> Node3D:
	var holder: Node3D = Node3D.new()
	var models: Dictionary = {
		"saffron": ["pepper", 4.0], "truffle": ["mushroom", 6.0], "sea_salt": ["shaker-salt", 7.0],
		"basil": ["cabbage", 2.4], "hot_pepper": ["paprika", 6.0], "honey": ["honey", 3.4],
	}
	var entry: Array = models[ingredient_id] as Array
	var food: Node3D = BuffetModels.food(str(entry[0]))
	holder.add_child(food)
	food.scale = Vector3.ONE * float(entry[1])
	if ingredient_id == "saffron":
		ModelKit.tint(food, Color(1.0, 0.7, 0.2))
	if ingredient_id == "basil":
		ModelKit.tint(food, Color(0.6, 1.0, 0.5))
	var ring: MeshInstance3D = BuffetProps.cylinder(holder, 0.55, 0.55, 0.03, BuffetMaterials.glow(Color(1.0, 0.9, 0.4), 0.8), Vector3(0, 0.03, 0), 16)
	ring.name = "Ring"
	return holder


# ---- Screenshot helpers ------------------------------------------------------------------------------------------


func _teleport(anchor_name: String) -> void:
	if anchor_name == "raft_ride":
		var raft: BuffetLayout.Raft = buf.layout.rafts[0]
		var pos: Vector2 = buf.layout.raft_position(raft, buf.time)
		player.position = Vector3(pos.x, 0.0, pos.y)
		_camera.position = player.position + camera_offset * Settings.camera_zoom
		_spawn_grace = 30.0
		return
	if anchor_name == "susan_ride":
		var susan: BuffetLayout.Susan = buf.layout.susans[0]
		player.position = Vector3(susan.center.x + 2.8, 0.0, susan.center.y + 1.2)
		_camera.position = player.position + camera_offset * Settings.camera_zoom
		_spawn_grace = 30.0
		return
	super._teleport(anchor_name)
