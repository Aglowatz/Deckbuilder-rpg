class_name CapitalScene
extends ZoneScene
## The playable Capital (the final area). The shared zone framework (`ZoneScene`) provides the life rules, enemies, hidden
## chests, dialogue, the minimap and fog of war; this subclass adds what is unique here: the controlled gate (a challenging card
## battle, or the secret Old Joint Works tunnel past it), the hidden resistance hideout (the Crease) and its service-shaft
## network, Primm's facade town (hollow citizens, painted doors, loudspeakers, portraits to deface), the complaint box, the
## rifts (contact damage, warped light, empowered enemies, sealing for rewards), the broken-service debuffs (shown in the HUD;
## the Beefcake blackout darkens the world and slows you, Famine blocks healing items) and the four Path quests' objects.
## All text is in `data/story/capital_story.tres`.

const CAMERA_NORMAL: Vector3 = Vector3(0.0, 13.5, 9.2)
## Light cull mask that skips layer 2 (the underground hideout) so the sun does not light it.
const SUN_CULL_MASK: int = 0xFFFFF & ~2
const SAFE_CHECK_INTERVAL: float = 0.25

var capital: CapitalBuilder
var _ash_added: bool = false
var _shake: float = 0.0
var _traveling: bool = false
var _dark_light: OmniLight3D
var _inside_timer: float = 0.0


func _zone_id() -> String:
	return CapitalZone.ID


func _make_map() -> ZoneMap:
	capital = CapitalBuilder.new()
	return capital


func _build_environment() -> void:
	var state: Dictionary = CapitalBuilder.story_context()
	var dark: bool = bool(state["dark"])
	var final_state: bool = bool(state["final"])
	add_child(CapitalLook.environment(dark, final_state))
	var sun: DirectionalLight3D = CapitalLook.sun(dark, final_state)
	sun.light_cull_mask = SUN_CULL_MASK
	add_child(sun)


func _build_zone_extras() -> void:
	camera_offset = CAMERA_NORMAL
	player.speed_multiplier = CapitalDebuffs.speed_multiplier(Session.flags)
	if CapitalDebuffs.darkness(Session.flags) and not Session.flag(CapitalZone.FLAG_FREED):
		_dark_light = OmniLight3D.new()
		_dark_light.light_color = Color(1.0, 0.85, 0.6)
		_dark_light.light_energy = 2.2
		_dark_light.omni_range = 11.0
		_dark_light.position = Vector3(0, 2.4, 0)
		player.add_child(_dark_light)
	_dress_facade_citizens()
	_mark_empowered_enemies()


## The facade's citizens: identical clothes and a fixed smile; once Primm falls they are free (their own colours, no smile).
func _dress_facade_citizens() -> void:
	var freed: bool = Session.flag(CapitalZone.FLAG_FREED)
	var index: int = 0
	for entry: Dictionary in def.npcs:
		if not bool(entry.get("facade", false)):
			continue
		var npc: Node3D = _npcs.get(str(entry["id"])) as Node3D
		index += 1
		if npc == null:
			continue
		if freed:
			ModelKit.tint(npc, [Color(1.2, 0.7, 0.6), Color(0.7, 1.0, 0.8), Color(0.8, 0.8, 1.3), Color(1.3, 1.1, 0.6)][index % 4])
			continue
		var smile: Label3D = Label3D.new()
		smile.text = ":)"
		smile.font = UIStyle.font_title()
		smile.font_size = 64
		smile.pixel_size = 0.0075
		smile.modulate = Color(0.15, 0.1, 0.1)
		smile.outline_size = 0
		smile.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		smile.position = Vector3(0, 0.9 / TownPlayer.MODEL_SCALE / maxf(float(entry.get("scale", 1.0)), 0.1) * 0.62, 0.3)
		npc.add_child(smile)


## Roaming enemies near an unsealed rift glow violet (they fight empowered).
func _mark_empowered_enemies() -> void:
	for enemy: ZoneEnemy in enemies:
		if enemy.info.kind != ZoneEnemyInfo.Kind.BATTLE:
			continue
		if not CapitalRifts.empowers(Session.flags, Vector2(enemy.home.x, enemy.home.z)):
			continue
		var aura: MeshInstance3D = MeshInstance3D.new()
		var mesh: SphereMesh = SphereMesh.new()
		mesh.radius = 0.8
		mesh.height = 1.6
		mesh.radial_segments = 12
		mesh.rings = 6
		aura.mesh = mesh
		aura.material_override = CapitalMaterials.translucent(CapitalMaterials.RIFT_VIOLET, 0.22, 1.2)
		aura.position = Vector3(0, 0.9, 0)
		enemy.add_child(aura)


## The Capital grades itself (see `CapitalLook`); the freed leaders appear in the Crease once Primm has fallen.
func _build_completion_state() -> void:
	if Session.flag(CapitalZone.FLAG_FREED):
		var hub: Vector3 = builder.anchor("crease_spawn")
		_build_freed_npcs(hub)


func _station_layer() -> int:
	return CapitalBuilder.CREASE_LAYER


func _hub_spawn() -> Vector3:
	if Session.flag(CapitalZone.FLAG_HUB_KNOWN):
		return builder.anchor("crease_spawn")
	return builder.anchor("spawn")


# ---- Prompts and the map -----------------------------------------------------------------------------------


func _prompt_for(spot: ZoneSpot) -> String:
	match str(spot.data.get("act", "")):
		"shaft":
			if not CapitalInteractables.can_travel(Session.flags):
				return "The network is down (no travel)"
			return "Take the service shaft to %s" % _destination_name(str(spot.data["dest"]))
		"deface":
			if Session.found_secret(CapitalZone.secret_id("deface", spot.id)):
				return "Already defaced"
		"pickup":
			if Session.found_secret(CapitalZone.secret_id("pick", str(spot.data["pickup"]))):
				return "Already taken"
		"seal":
			if CapitalRifts.is_sealed(Session.flags, str(spot.data["rift"])):
				return "The rift is sealed"
		"wheel":
			if Session.found_secret(CapitalZone.secret_id("wheel", str(spot.data["n"]))):
				return "The crew is free"
		"complaint":
			if Session.zone_run != null and Session.zone_run.visit_count("complaints") >= CapitalInteractables.COMPLAINT_LIMIT:
				return "The box is full of complaints"
		"cable":
			if Session.flag(CapitalZone.FLAG_CABLE_CUT):
				return "The cable is cut"
		"dispenser":
			if Session.flag(CapitalZone.FLAG_PASTE_SPOILED):
				return "The paste is spoiled"
		"gate_captain":
			if Session.flag(CapitalZone.FLAG_GATE_OPEN):
				return "Talk"
	return spot.prompt


func _destination_name(dest: String) -> String:
	match dest:
		"plaza":
			return "Checkpoint Plaza"
		"reek":
			return "the Reek"
		"grave":
			return "Grave Row"
		"hungry":
			return "the Hungry Quarter"
		"transit":
			return "the Transit Yards"
	return "the Castle Approach"


# ---- Per-frame -------------------------------------------------------------------------------------------------------


func _zone_process(delta: float) -> void:
	capital.animate(delta)
	if not _ash_added and _camera != null:
		_ash_added = true
		_camera.add_child(CapitalLook.confetti() if Session.flag(CapitalZone.FLAG_FREED) else CapitalLook.ash())
	if _shake > 0.0:
		_camera.position += Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), 0.0) * _shake * 0.12
		_shake = maxf(0.0, _shake - delta * 1.6)
	if player.airborne or _fainting or _traveling:
		return
	_inside_timer -= delta
	if _inside_timer <= 0.0:
		_inside_timer = SAFE_CHECK_INTERVAL
		_track_progress()
	if _locked or dialogue.active:
		return
	_rift_contact()


## Standing in a rift tears you: damage with knockback and a short invulnerability window (like any damaging touch); near one the
## world wobbles.
func _rift_contact() -> void:
	var flat: Vector2 = Vector2(player.position.x, player.position.z)
	var touching: Dictionary = CapitalRifts.touching(Session.flags, flat)
	for entry: Dictionary in CapitalRifts.all():
		if CapitalRifts.is_sealed(Session.flags, str(entry["id"])):
			continue
		var distance: float = flat.distance_to(Vector2(float(entry["x"]), float(entry["z"])))
		if distance < float(entry["radius"]) * 2.0 + 1.0:
			_shake = maxf(_shake, 0.35 if distance < float(entry["radius"]) + 1.0 else 0.12)
	if touching.is_empty() or _invulnerable > 0.0:
		return
	hit_player(CapitalRifts.damage_of(touching), Vector3(float(touching["x"]), 0.0, float(touching["z"])), "torn apart by a rift")


func _track_progress() -> void:
	var z: float = player.position.z
	if z >= capital_crease_z():
		if not Session.flag(CapitalZone.FLAG_HUB_KNOWN):
			Session.set_flag(CapitalZone.FLAG_HUB_KNOWN)
		return
	if not Session.flag(CapitalZone.FLAG_INSIDE) and z < float(CapitalLayout.WALL_Z0) and z > 2.0:
		Session.set_flag(CapitalZone.FLAG_INSIDE)
		hud.toast(story.text("fx.inside"), Color("ffcf70"))


static func capital_crease_z() -> float:
	return CapitalBuilder.CREASE_Z


# ---- Teleporting (ladders, shafts, the tunnel) -----------------------------------------------------------------------------


func _travel_to(target: Vector3, message_key: String = "") -> void:
	if _traveling:
		return
	_traveling = true
	_locked = true
	var fade: ColorRect = ColorRect.new()
	fade.color = Color(0, 0, 0, 0)
	UIKit.full_rect(fade)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay_layer.add_child(fade)
	var out: Tween = create_tween()
	out.tween_property(fade, "color:a", 1.0, 0.3)
	await out.finished
	player.position = target
	player.position.y = builder.height_at(target)
	_camera.position = player.position + camera_offset
	_invulnerable = 1.0
	_spawn_grace = 2.0
	var back: Tween = create_tween()
	back.tween_property(fade, "color:a", 0.0, 0.3)
	await back.finished
	fade.queue_free()
	_traveling = false
	_locked = false
	if not message_key.is_empty():
		hud.toast(story.text(message_key), Color("ffcf70"))


# ---- Interactions (kind "zone") -----------------------------------------------------------------------------------------------


func _interact_zone(spot: ZoneSpot) -> void:
	var act: String = str(spot.data.get("act", ""))
	match act:
		"mabbit":
			_talk_mabbit()
		"supplies":
			_open_supplies()
		"ladder":
			_travel_to(builder.anchor("manhole") + Vector3(0, 0, 1.4), "fx.ladder")
		"tunnel_out":
			_travel_to(builder.anchor("tunnel_in") + Vector3(0, 0, 2.2), "fx.tunnel_out")
		"shaft":
			_use_shaft(spot)
		"gate_captain":
			_talk_gate_captain()
		"guard":
			var npc_id: String = str(spot.data["npc"])
			_face_npc(npc_id)
			_say(str(spot.data["speaker"]), _greeting(npc_id))
		"tunnel_in":
			_use_tunnel_in()
		"manhole":
			_use_manhole()
		"exit_booth":
			_face_npc("exit_clerk")
			var visits: int = Session.counter("cap_exit_booth")
			Session.bump_counter("cap_exit_booth")
			_say("Exit Clerk", story.get_lines("npc.exit_clerk.%s" % ("intro" if visits == 0 else "return")))
		"complaint":
			_use_complaint()
		"citizen":
			_talk_citizen(spot)
		"door":
			_say("", story.get_lines("facade.door.%d" % int(spot.data["n"])))
		"speaker":
			_use_speaker(int(spot.data["n"]))
		"deface":
			_deface(spot)
		"permit":
			_report(CapitalInteractables.permit_loop())
		"plot":
			var plot: Dictionary = CapitalInteractables.lay_to_rest()
			if bool(plot["ok"]):
				capital.set_prop_state("family_plot", builder.anchor("marrow_plot"), true)
			_report(plot)
		"patch":
			var patch: Dictionary = CapitalInteractables.plant_seed()
			if bool(patch["ok"]):
				capital.set_prop_state("sick_patch", builder.anchor("sick_patch"), true)
			_report(patch)
		"dispenser":
			var paste: Dictionary = CapitalInteractables.spoil_paste()
			if bool(paste["ok"]):
				capital.set_prop_state("paste_dispenser", builder.anchor("dispenser"), true)
			_report(paste)
		"cable":
			var cable: Dictionary = CapitalInteractables.cut_cable()
			if bool(cable["ok"]):
				capital.set_prop_state("power_cable", builder.anchor("cable"), true)
				_flicker_lights()
			_report(cable)
		"wheel":
			_report(CapitalInteractables.free_wheel(int(spot.data["n"])))
		"pickup":
			_take_pickup(spot)
		"seal":
			_seal_rift(spot)
		"ward_window":
			_say("", story.get_lines("fx.ward_window"))
		"patient":
			_face_npc("patient")
			_say(str(spot.data["speaker"]), _greeting("patient"))


## Shows what an interactable result says: one line as a toast, several as a short dialogue.
func _report(result: Dictionary, color: Color = Color("ffcf70")) -> void:
	var lines: Array[String] = story.get_lines(str(result["key"]))
	var extra: String = ""
	if int(result.get("gold", 0)) > 0:
		extra = "  (+%d gold)" % int(result["gold"])
		hud.set_gold(Session.gold)
	if int(result.get("healed", 0)) > 0:
		extra += "  (+%d life)" % int(result["healed"])
	if int(result.get("damage", 0)) > 0:
		extra += "  (-%d life)" % int(result["damage"])
		_after_self_damage()
	if str(result.get("reward_text", "")) != "":
		extra += "  (%s)" % str(result["reward_text"])
	if lines.size() > 1:
		_say("", lines)
		if not extra.is_empty():
			hud.toast(extra.strip_edges(), color)
	else:
		hud.toast(lines[0] + extra, color)
	EventBus.zone_life_changed.emit(Session.zone_run.life, Session.zone_run.max_life())
	Session.refresh_quests()
	Session.save_game()


func _after_self_damage() -> void:
	if Session.zone_run.is_down():
		_faint("a stern reply from the Complaints Department")


func _talk_mabbit() -> void:
	_face_npc("mabbit")
	var lines: Array[String] = _greeting("mabbit")
	var insights: int = CapitalInteractables.insight_count(Session.flags)
	if insights > 0:
		lines.append_array(story.get_lines("npc.mabbit.insight.%d" % insights))
	_say("Mabbit Quill", lines)


func _open_supplies() -> void:
	var data: ItemVendorData = ItemVendorData.new()
	data.vendor_name = "Fig's Crate of Supplies"
	for item_id: String in CapitalZone.BLACK_MARKET_ITEMS.keys():
		data.add(item_id, int(CapitalZone.BLACK_MARKET_ITEMS[item_id]))
	var screen: ItemVendorScreen = ItemVendorScreen.new()
	screen.stock = data
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


func _use_shaft(spot: ZoneSpot) -> void:
	if not CapitalInteractables.can_travel(Session.flags):
		_say("", story.get_lines("fx.no_travel"))
		return
	var dest: String = str(spot.data["dest"])
	_travel_to(builder.anchor("net_" + dest) + Vector3(0, 0, 1.0), "fx.shaft")


func _talk_gate_captain() -> void:
	_face_npc("gate_captain")
	if Session.flag(CapitalZone.FLAG_GATE_OPEN) or Session.flag(CapitalZone.FLAG_FREED):
		_say("Gate Captain", story.get_lines("npc.gate_captain.open"))
		return
	_say("Gate Captain", _greeting("gate_captain"), _ask_gate_battle)


func _ask_gate_battle() -> void:
	_locked = true
	var dialog: ConfirmDialog = ConfirmDialog.ask(_overlay_layer, story.text("ui.gate.title"), story.text("ui.gate.body"), story.text("ui.gate.button"), "Not yet")
	dialog.confirmed.connect(func() -> void:
		var run: ZoneRun = Session.zone_run
		run.return_position = player.position + Vector3(0, 0, 1.2)
		run.has_return_position = true
		Audio.sfx(&"turn_start")
		Session.start_gate_battle())
	dialog.cancelled.connect(func() -> void: _locked = false)


## The hidden service shaft in the Outskirts: found only by exploring (no marker, a prompt up close), it leads past the gate into
## the Crease.
func _use_tunnel_in() -> void:
	var first: bool = not Session.found_secret(CapitalZone.SECRET_TUNNEL)
	if first:
		Session.discover_secret(CapitalZone.SECRET_TUNNEL)
		capital.set_prop_state("tunnel_hatch_cover", builder.anchor("tunnel_in"), true)
	Session.set_flag(CapitalZone.FLAG_TUNNEL_FOUND)
	Session.set_flag(CapitalZone.FLAG_HUB_KNOWN)
	Session.set_flag(CapitalZone.FLAG_INSIDE)
	if first:
		_say("", story.get_lines("fx.tunnel_found"), func() -> void: _travel_to(builder.anchor("crease_spawn")))
	else:
		_travel_to(builder.anchor("crease_spawn"), "fx.tunnel_in")


## The manhole by the gate (inside): a Wrinkle's knock lets you down to the Crease.
func _use_manhole() -> void:
	if not Session.flag(CapitalZone.FLAG_HUB_KNOWN):
		Session.set_flag(CapitalZone.FLAG_HUB_KNOWN)
		_say("", story.get_lines("fx.manhole_first"), func() -> void: _travel_to(builder.anchor("crease_spawn")))
		return
	_travel_to(builder.anchor("crease_spawn"), "fx.manhole")


func _use_complaint() -> void:
	_report(CapitalInteractables.complaint(Session.zone_run))


func _talk_citizen(spot: ZoneSpot) -> void:
	var n: int = int(spot.data["n"])
	var npc_id: String = str(spot.data["npc"])
	_face_npc(npc_id)
	var key: String = "cap_citizen_%d" % n
	var count: int = Session.counter(key)
	Session.bump_counter(key)
	var variant: String = "approved" if count % 3 != 2 else "slip"
	if count == 1:
		variant = "approved2"
	_say("Citizen", story.get_lines("facade.citizen.%d.%s" % [n, variant]))


func _use_speaker(n: int) -> void:
	var key: String = "cap_speaker_%d" % n
	var count: int = Session.counter(key)
	Session.bump_counter(key)
	_say("The Loudspeaker", story.get_lines("facade.speaker.%d.%d" % [n, count % 3]))


func _deface(spot: ZoneSpot) -> void:
	var result: Dictionary = CapitalInteractables.deface(spot.id)
	if bool(result["ok"]):
		var anchor_pos: Vector3 = builder.anchor(spot.id)
		capital.set_prop_state("portrait", anchor_pos, true)
		Audio.sfx(&"coins", 0.0, 0.05)
	_report(result)


func _take_pickup(spot: ZoneSpot) -> void:
	var pickup_id: String = str(spot.data["pickup"])
	var result: Dictionary = CapitalInteractables.pick_up(pickup_id)
	if bool(result["ok"]):
		var node: Node3D = null
		for kind: String in ["compost_heap", "recipe_card", "seed_jar"]:
			node = capital.prop_at_anchor(kind, pickup_id)
			if node != null:
				node.visible = false
		Audio.sfx(&"coins", 0.0, 0.05)
	_report(result)


func _seal_rift(spot: ZoneSpot) -> void:
	var rift_id: String = str(spot.data["rift"])
	var result: Dictionary = CapitalInteractables.seal_rift(Session.zone_run, rift_id)
	if bool(result["ok"]):
		capital.close_rift(rift_id)
		Audio.sfx(&"chest_open")
		hud.set_gold(Session.gold)
		_shake = 0.6
	_report(result)


## Cutting the power: the facade's lights flicker for a moment.
func _flicker_lights() -> void:
	var tween: Tween = create_tween()
	for step: int in range(3):
		tween.tween_property(_flash, "color", Color(0, 0, 0, 0.6), 0.08)
		tween.tween_property(_flash, "color", Color(0, 0, 0, 0.0), 0.12)
	tween.tween_callback(func() -> void: _flash.color = Color(0.9, 0.05, 0.05, 0.0))


# ---- Battles, results, the HUD --------------------------------------------------------------------------------------------------------


func _start_enemy_battle(enemy: ZoneEnemy) -> void:
	Session.zone_empower_next = CapitalRifts.empowers(Session.flags, Vector2(enemy.home.x, enemy.home.z))
	super(enemy)


func _apply_pending_result() -> void:
	_add_service_panel()
	_update_objective()
	var result: Dictionary = Session.pending_zone_result
	if str(result.get("kind", "")) == "ending_return":
		# Back from the ending: the Capital has changed (facade down, rifts sealed, citizens free). Stand at the castle approach.
		Session.pending_zone_result = {}
		player.position = builder.anchor("net_approach") + Vector3(0, 0, 3.0)
		_camera.position = player.position + camera_offset
		_say("Mabbit Quill", story.get_lines("ending.return"))
		hud.toast(story.text("fx.ending_return"), UIStyle.GOOD)
		return
	if bool(result.get("gate_opened", false)) and not bool(result.get("woke_at_hub", false)):
		_say("Gate Captain", story.get_lines("npc.gate_captain.defeated"))
	super()


func _add_service_panel() -> void:
	hud.add_panel(ServiceDebuffsPanel.make(Session.flags))


func _update_objective() -> void:
	var key: String = "hud.objective"
	if Session.flag(CapitalZone.FLAG_FREED):
		key = "hud.objective.freed"
	elif Session.flag(CapitalZone.FLAG_INSIDE):
		key = "hud.objective.inside"
	hud.set_objective(story.text(key))


func _show_wake_dialogue(fee_override: int) -> void:
	var fee: int = _last_fee if fee_override == 0 else fee_override
	dialogue.start(def.wake_speaker if Session.flag(CapitalZone.FLAG_HUB_KNOWN) else "Gate Guard", story.get_lines("fx.wake" if Session.flag(CapitalZone.FLAG_HUB_KNOWN) else "fx.wake_outside"))
	hud.toast("%s: -%d gold (logged)." % [def.fee_label, fee], Color("ffcf70"))


# ---- Screenshot / dev helpers ----------------------------------------------------------------------------------------------------


## `--paths=N` frees the first N Path zones (all four with `--paths`), `--gate` opens the gate, `--hub` marks the Crease as known,
## `--flags=a,b` sets flags; `--at=<anchor>` then teleports (see `ZoneScene._teleport`).
func screenshot_prepare(args: Dictionary) -> void:
	super(args)
	Session.ensure_game()
	if args.has("paths"):
		var count: int = ZoneDefs.ids().size() if str(args["paths"]) == "true" else int(args["paths"])
		for zone_id: String in ZoneDefs.ids().slice(0, count):
			Session.complete_zone(zone_id)
	if args.has("gate"):
		Session.set_flag(CapitalZone.FLAG_GATE_OPEN)
		Session.set_flag(CapitalZone.FLAG_INSIDE)
	if args.has("hub"):
		Session.set_flag(CapitalZone.FLAG_HUB_KNOWN)
	if args.has("flags"):
		for flag_name: String in str(args["flags"]).split(","):
			Session.set_flag(StringName(flag_name))
