class_name GiantChestEvent
extends RefCounted
## Brief 16, Group B: the giant chests and the con artist inside them. `make_chest` builds the (big, joke) chest, `apply_look` shows it open or, for
## the original chest once all five were opened, closed and faintly glowing. `play` is the whole scene when the player opens one: the lid swings up,
## Shiro Swindle pops out, mocks the player with that chest's own taunt, steals 50 gold (or all of it) and shows the amount, shouts SMOKE BOMB!!! and
## vanishes in a puff of smoke. It works in any scene with a `player` (TownPlayer), `hud` (TownHud), `dialogue` (DialogueBox) and
## `set_world_locked(bool)`: the town and every ZoneScene.

const CHEST_SCALE: float = 0.9
## How close the hero has to be for the [E] prompt.
const PROMPT_RADIUS: float = 1.9
const NINJA_TINT: Color = Color(0.32, 0.29, 0.42)
## He is a boss: a bit bigger than the hero.
const NINJA_SCALE: float = 1.3
const GLOW_COLOR: Color = Color("ffd76a")


static func make_chest(parent: Node3D, position: Vector3, yaw_degrees: float) -> Node3D:
	var chest: Node3D = ModelKit.dungeon_prop("chest_gold")
	ModelKit.place(parent, chest, position, yaw_degrees, CHEST_SCALE)
	return chest


## The chest as the save says it should look: opened chests stay open; the original chest is closed and glowing once all five were opened
## (until he is beaten, after which it stays open for good).
static func apply_look(chest: Node3D, chest_id: String) -> void:
	if chest == null:
		return
	var opened: bool = Session.ninja_chest_opened(chest_id)
	var glowing: bool = chest_id == NinjaBoss.ORIGINAL_CHEST and Session.ninja_ready()
	ChestKit.set_open(chest, opened and not glowing)
	set_glow(chest, glowing)


static func set_glow(chest: Node3D, on: bool) -> void:
	var existing: Node = chest.get_node_or_null("NinjaGlow")
	if existing != null:
		existing.queue_free()
	if not on:
		return
	var glow: Node3D = Node3D.new()
	glow.name = "NinjaGlow"
	chest.add_child(glow)
	var light: OmniLight3D = OmniLight3D.new()
	light.light_color = GLOW_COLOR
	light.light_energy = 0.8
	light.omni_range = 3.2
	light.position = Vector3(0.0, 0.55, 0.0)
	glow.add_child(light)
	var tween: Tween = light.create_tween().set_loops()
	tween.tween_property(light, "light_energy", 1.6, 1.4).set_trans(Tween.TRANS_SINE)
	tween.tween_property(light, "light_energy", 0.5, 1.4).set_trans(Tween.TRANS_SINE)
	var sparkles: CPUParticles3D = CPUParticles3D.new()
	sparkles.amount = 10
	sparkles.lifetime = 2.2
	sparkles.direction = Vector3.UP
	sparkles.spread = 25.0
	sparkles.initial_velocity_min = 0.15
	sparkles.initial_velocity_max = 0.4
	sparkles.gravity = Vector3.ZERO
	sparkles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	sparkles.emission_box_extents = Vector3(0.45, 0.05, 0.3)
	sparkles.position = Vector3(0.0, 0.5, 0.0)
	var mote: SphereMesh = SphereMesh.new()
	mote.radius = 0.025
	mote.height = 0.05
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = GLOW_COLOR
	material.emission_enabled = true
	material.emission = GLOW_COLOR
	material.emission_energy_multiplier = 2.5
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mote.material = material
	sparkles.mesh = mote
	glow.add_child(sparkles)


## Opens giant chest `chest_id` (a node of the scene at `chest_position`): the whole scene described above. The scene is locked until it ends.
static func play(host: Node3D, chest_id: String, chest: Node3D) -> void:
	var player: TownPlayer = host.get("player") as TownPlayer
	var hud: TownHud = host.get("hud") as TownHud
	var dialogue: DialogueBox = host.get("dialogue") as DialogueBox
	var tree: SceneTree = host.get_tree()
	if Session.ninja_chest_opened(chest_id):
		hud.toast(NinjaBoss.OPEN_AGAIN_LINES[0], UIStyle.MUTED)
		return
	host.call("set_world_locked", true)
	player.input_enabled = false
	player.face(chest.global_position)
	# The result is decided up front (state is saved at once) but shown as the scene plays out.
	var result: Dictionary = Session.open_giant_chest(chest_id)
	Audio.sfx(&"chest_open")
	ChestKit.open_animated(chest)
	await tree.create_timer(0.55).timeout
	var ninja: Node3D = _pop_out(host, chest, player.global_position)
	await tree.create_timer(0.85).timeout
	dialogue.start(NinjaBoss.DISPLAY_NAME, NinjaBoss.taunt_lines(chest_id, bool(result.get("is_fifth", false))), NinjaBoss.NPC_ID)
	await dialogue.finished
	var stolen: int = int(result.get("stolen", 0))
	_steal_effect(host, player, ninja, stolen)
	hud.set_gold(Session.gold)
	await tree.create_timer(1.5).timeout
	_say_smoke(host, ninja)
	await tree.create_timer(0.35).timeout
	smoke_puff(host, ninja.global_position + Vector3(0, 0.35, 0))
	ninja.queue_free()
	await tree.create_timer(0.9).timeout
	if bool(result.get("is_fifth", false)):
		host.call("on_ninja_ready")
	Session.save_game()
	host.call("set_world_locked", false)
	player.input_enabled = true


## The ninja leaps out of the open chest towards the hero and turns to face them.
static func _pop_out(host: Node3D, chest: Node3D, hero_position: Vector3) -> Node3D:
	var ninja: Node3D = ModelKit.character("Rogue_Hooded")
	ModelKit.tint(ninja, NINJA_TINT)
	var start: Vector3 = chest.global_position + Vector3(0.0, 0.15, 0.0)
	var toward: Vector3 = hero_position - chest.global_position
	toward.y = 0.0
	toward = toward.normalized() if toward.length() > 0.01 else Vector3(0, 0, 1)
	var landing: Vector3 = chest.global_position + toward * 1.05
	landing.y = chest.global_position.y
	ModelKit.place(host, ninja, start, rad_to_deg(atan2(toward.x, toward.z)), 0.05)
	var animation: AnimationPlayer = ModelKit.animation_player(ninja)
	if animation != null:
		for candidate: StringName in [&"Jump_Full_Short", &"Jump_Idle", &"Cheer", &"Idle"]:
			if animation.has_animation(candidate):
				animation.play(candidate)
				break
	Audio.sfx(&"boing", -6.0)
	var tween: Tween = ninja.create_tween()
	tween.set_parallel(true)
	tween.tween_property(ninja, "scale", Vector3.ONE * TownPlayer.MODEL_SCALE * NINJA_SCALE, 0.3)
	tween.tween_property(ninja, "position:x", landing.x, 0.55).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(ninja, "position:z", landing.z, 0.55).set_trans(Tween.TRANS_QUAD)
	var arc: Tween = ninja.create_tween()
	arc.tween_property(ninja, "position:y", start.y + 1.15, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	arc.tween_property(ninja, "position:y", landing.y, 0.27).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	arc.tween_callback(func() -> void:
		if animation != null and animation.has_animation(&"Cheer"):
			animation.play(&"Cheer"))
	return ninja


## The theft: a floating "-50 gold" over the hero, a coin burst flying to the ninja and the toast.
static func _steal_effect(host: Node3D, player: TownPlayer, ninja: Node3D, stolen: int) -> void:
	var hud: TownHud = host.get("hud") as TownHud
	var text: String = "-%d gold" % stolen if stolen > 0 else "Nothing to steal!"
	floating_text(host, text, Color("ffd76a") if stolen > 0 else UIStyle.MUTED, player.global_position + Vector3(0, 1.3, 0), 1.6)
	if stolen > 0:
		Audio.sfx(&"coins", 0.0, 0.05)
		hud.toast("Shiro Swindle stole %d gold!" % stolen, Color("ff8a85"))
		_coin_burst(host, player.global_position + Vector3(0, 0.8, 0), ninja.global_position + Vector3(0, 0.6, 0))
	else:
		hud.toast("You had no gold. Shiro Swindle is unimpressed.", UIStyle.MUTED)


static func _coin_burst(host: Node3D, from: Vector3, to: Vector3) -> void:
	for i: int in range(6):
		var coin: MeshInstance3D = MeshInstance3D.new()
		var mesh: CylinderMesh = CylinderMesh.new()
		mesh.top_radius = 0.09
		mesh.bottom_radius = 0.09
		mesh.height = 0.03
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = UIStyle.GOLD
		material.emission_enabled = true
		material.emission = UIStyle.GOLD
		material.emission_energy_multiplier = 1.8
		mesh.material = material
		coin.mesh = mesh
		host.add_child(coin)
		coin.global_position = from + Vector3(randf_range(-0.2, 0.2), randf_range(0.0, 0.3), randf_range(-0.2, 0.2))
		var tween: Tween = coin.create_tween()
		tween.tween_interval(0.08 * float(i))
		tween.tween_property(coin, "global_position", to, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_callback(coin.queue_free)


## "SMOKE BOMB!!!" in big letters over his head.
static func _say_smoke(host: Node3D, ninja: Node3D) -> void:
	floating_text(host, NinjaBoss.SMOKE_SHOUT, Color("ff5a4a"), ninja.global_position + Vector3(0, 1.1, 0), 0.9, 120)
	var animation: AnimationPlayer = ModelKit.animation_player(ninja)
	if animation != null and animation.has_animation(&"Jump_Idle"):
		animation.play(&"Jump_Idle")


## A grey puff that swells and fades, with a flash and the smoke-bomb sound.
static func smoke_puff(host: Node3D, at: Vector3) -> void:
	Audio.sfx(&"smoke_bomb", -2.0, 0.03)
	var puff: CPUParticles3D = CPUParticles3D.new()
	puff.position = at
	puff.amount = 46
	puff.one_shot = true
	puff.explosiveness = 0.96
	puff.lifetime = 1.6
	puff.direction = Vector3.UP
	puff.spread = 180.0
	puff.initial_velocity_min = 0.6
	puff.initial_velocity_max = 2.0
	puff.gravity = Vector3(0, 0.25, 0)
	puff.damping_min = 0.8
	puff.damping_max = 1.6
	puff.scale_amount_min = 0.7
	puff.scale_amount_max = 1.5
	var curve: Curve = Curve.new()
	curve.add_point(Vector2(0.0, 0.35))
	curve.add_point(Vector2(0.3, 1.0))
	curve.add_point(Vector2(1.0, 1.4))
	puff.scale_amount_curve = curve
	var fade: Gradient = Gradient.new()
	fade.set_color(0, Color(0.82, 0.82, 0.86, 0.85))
	fade.set_color(1, Color(0.55, 0.55, 0.6, 0.0))
	puff.color_ramp = fade
	var ball: SphereMesh = SphereMesh.new()
	ball.radius = 0.32
	ball.height = 0.64
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.85, 0.85, 0.9)
	ball.material = material
	puff.mesh = ball
	host.add_child(puff)
	puff.emitting = true
	var flash: OmniLight3D = OmniLight3D.new()
	flash.position = at
	flash.light_color = Color("fff4d8")
	flash.light_energy = 6.0
	flash.omni_range = 5.0
	host.add_child(flash)
	var flash_tween: Tween = flash.create_tween()
	flash_tween.tween_property(flash, "light_energy", 0.0, 0.5)
	flash_tween.tween_callback(flash.queue_free)
	host.get_tree().create_timer(2.4).timeout.connect(puff.queue_free)


## A billboard label that rises and fades.
static func floating_text(host: Node3D, text: String, color: Color, at: Vector3, seconds: float, font_size: int = 72) -> void:
	var label: Label3D = Label3D.new()
	label.text = text
	label.font = UIStyle.font_title()
	label.font_size = font_size
	label.pixel_size = 0.008
	label.modulate = color
	label.outline_size = 18
	label.outline_modulate = Color(0.05, 0.03, 0.08, 0.95)
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	host.add_child(label)
	label.global_position = at
	var tween: Tween = label.create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y + 1.0, seconds)
	tween.tween_property(label, "modulate:a", 0.0, seconds).set_delay(seconds * 0.45)
	tween.chain().tween_callback(label.queue_free)


## Screenshot/dev helper (`--ninja=<chest id>`; `--ninja_skip=true` skips his dialogue after a moment): plays the scene on its own once the world has settled.
static func screenshot_run(host: Node3D, chest_id: String, chest: Node3D, args: Dictionary) -> void:
	var tree: SceneTree = host.get_tree()
	await tree.create_timer(1.0).timeout
	play(host, chest_id, chest)
	if str(args.get("ninja_skip", "false")) != "true":
		return
	var dialogue: DialogueBox = host.get("dialogue") as DialogueBox
	while not dialogue.active:
		await tree.process_frame
	await tree.create_timer(0.8).timeout
	dialogue.active = false
	dialogue.visible = false
	dialogue.finished.emit()
