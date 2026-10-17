class_name CapitalScene
extends ZoneScene
## The playable Capital (the final area). The shared zone framework (`ZoneScene`) provides the HP rules, enemies, hidden
## chests, dialogue, the minimap and fog of war; this subclass adds what is unique here: the controlled gate (a challenging card
## battle, or the secret Old Joint Works tunnel past it), the hidden resistance hideout (the Crease) and its service-shaft
## network, Primm's facade town (hollow citizens, painted doors, loudspeakers, portraits to deface), the complaint box, the
## rifts (contact damage, warped light, empowered enemies, sealing for rewards), the broken-service debuffs (shown in the HUD;
## the Beefcake blackout darkens the world and slows you, Famine blocks healing items) and the four Path quests' objects.
## All text is in `data/story/capital_story.tres`.

## Light cull mask that skips layer 2 (the underground hideout) so the sun does not light it.
const SUN_CULL_MASK: int = 0xFFFFF & ~2
const SAFE_CHECK_INTERVAL: float = 0.25
## Brief 16, Group C: set the first time the hero comes through the hidden gap in the left-hand city wall.
const WALL_PASSAGE_SECRET: String = "capital_wall_passage"

var capital: CapitalBuilder
var wasteland: CapitalWasteland
var _inside: bool = false
## The Capital area (`CapitalLayout` id) whose music is playing, and the check timer.
var _music_area: String = ""
var _music_timer: float = 0.0
var _ash_added: bool = false
var _shake: float = 0.0
var _traveling: bool = false
var _dark_light: OmniLight3D
var _inside_timer: float = 0.0
## `--still=true` (paint-over and match shots): the roaming enemies are held at their homes on the first frame.
var _hold_still: bool = false


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
	camera_offset = WorldLookRig.base_offset()
	player.speed_multiplier = CapitalDebuffs.speed_multiplier(Session.flags)
	# Arriving by the Gate Road: the hero faces north, up the road to the great gate and the castle over it.
	if player.position.distance_to(builder.anchor("spawn")) < 1.0:
		player.face(player.position + Vector3(0.0, 0.0, -2.0))
	if CapitalDebuffs.darkness(Session.flags) and not Session.flag(CapitalZone.FLAG_FREED):
		_dark_light = OmniLight3D.new()
		_dark_light.light_color = Color(1.0, 0.85, 0.6)
		_dark_light.light_energy = 2.2
		_dark_light.omni_range = 11.0
		_dark_light.position = Vector3(0, 2.4, 0)
		player.add_child(_dark_light)
	_dress_facade_citizens()
	_mark_empowered_enemies()
	# CAPITAL_HIDE=<name,name>: hide the builder's top-level pieces whose names begin so ("=name" exact), an fps A/B knob like HEAP_HIDE;
	# CAPITAL_NO_SHADOW=1 turns the sun's shadows off
	for prefix: String in OS.get_environment("CAPITAL_HIDE").split(",", false):
		for child: Node in capital.root.get_children():
			if (str(child.name) == prefix.trim_prefix("=") if prefix.begins_with("=") else str(child.name).begins_with(prefix)) and child is Node3D:
				(child as Node3D).visible = false
	if OS.get_environment("CAPITAL_NO_SHADOW") == "1":
		for light: Node in find_children("*", "DirectionalLight3D", true, false):
			(light as DirectionalLight3D).shadow_enabled = false
	# The lost-property posters show a face, not lettering (G-03); using one reads it.
	var poster_key: String = "prop.lost_poster.known" if Session.flag(MemoryDefs.FLAG_REVEALED) else "prop.lost_poster"
	var poster_index: int = 0
	for prop: CapitalLayout.Prop in capital.layout.props:
		if prop.kind == "portrait" and prop.variant == 2:
			_add_spot("lost_poster_%d" % poster_index, "Poster", prop.pos + Vector3(0.0, 0.0, 0.8), 1.4, "Read the poster", false, "plaque", {"hidden": true, "key": poster_key})
			poster_index += 1


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
		if npc is SpriteStroller:
			# Painted citizens: a coat a shade off each (subtle), and once Primm has fallen their own colours - no smile card, the art already smiles.
			var freed_tints: Array[Color] = [Color(1.2, 0.7, 0.6), Color(0.7, 1.0, 0.8), Color(0.8, 0.8, 1.3), Color(1.3, 1.1, 0.6)]
			var coat: Color = freed_tints[index % 4] if freed else NpcSprites.CITIZEN_TINTS[index % NpcSprites.CITIZEN_TINTS.size()]
			(npc as SpriteStroller).sprite.set_tint(coat)
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
	# Sound pass: the first time the hero is back with the gate won, the great gate winds open with a hollow boom (once per save; a cosmetic flag nothing else reads).
	if Session.flag(CapitalZone.FLAG_GATE_OPEN) and not Session.flag(&"sfx_gate_heard"):
		Session.set_flag(&"sfx_gate_heard")
		get_tree().create_timer(1.4).timeout.connect(func() -> void: Audio.sfx(&"gate_big"))


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
		"spotless":
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


# ---- The first return to a freed district (the art pass, Part E) -------------------------------------------------------------------------------

## Each Path's sting and its colours for the welcome.
const WELCOME: Dictionary = {
	"beefcake": {"sting": &"STG-ZONE-BEEF", "colors": [Color("e0503a"), Color("f2c14a")]},
	"gourmand": {"sting": &"STG-ZONE-GOUR", "colors": [Color("c47a3a"), Color("f2e2c0")]},
	"necrocrat": {"sting": &"STG-ZONE-NECRO", "colors": [Color("8af0b0"), Color("c8f0ff")]},
	"refusemancer": {"sting": &"STG-ZONE-REF", "colors": [Color("8ac04a"), Color("f0d050")]},
}


## The flag that marks a district's welcome as seen (cosmetic: nothing else reads it, CAP-34).
static func welcome_flag(district: String) -> StringName:
	return StringName("cap_welcome_%s" % district)


## The first time the hero walks into a district whose Path has been freed (before Primm falls): the district's lights flicker on, the Path's
## sting rings over the district's restored music (which the area music already switches to), a burst of the Path's colours, and four citizens
## in the Path's colours gather round the hero and cheer for a few seconds, then go home. No words, no new story; marked once per save.
func _welcome_district(area_id: String) -> void:
	var path: String = str(MusicDirector.CAPITAL_DISTRICTS.get(area_id, ""))
	if path == "" or not ZoneCompletion.is_completed(Session.flags, path) or Session.flag(CapitalZone.FLAG_FREED):
		return
	if Session.flag(welcome_flag(area_id)):
		return
	Session.set_flag(welcome_flag(area_id))
	var look: Dictionary = WELCOME[path] as Dictionary
	Audio.sting(look["sting"] as StringName)
	for light: Variant in capital.district_lights.get(area_id, []) as Array:
		var lamp: OmniLight3D = light as OmniLight3D
		if lamp == null or not is_instance_valid(lamp):
			continue
		var full: float = lamp.light_energy
		lamp.light_energy = 0.0
		var tween: Tween = lamp.create_tween()
		for step: Vector2 in [Vector2(0.6, 0.12), Vector2(0.05, 0.1), Vector2(0.9, 0.14), Vector2(0.2, 0.08), Vector2(1.0, 0.5)]:
			tween.tween_property(lamp, "light_energy", full * step.x, step.y)
	_welcome_burst(look["colors"] as Array)
	_welcome_crowd(look["colors"] as Array)


func _welcome_burst(colors: Array) -> void:
	for index: int in range(colors.size()):
		var burst: CPUParticles3D = CPUParticles3D.new()
		burst.one_shot = true
		burst.amount = 40
		burst.lifetime = 2.2
		burst.explosiveness = 0.85
		burst.direction = Vector3.UP
		burst.spread = 50.0
		burst.initial_velocity_min = 3.0
		burst.initial_velocity_max = 5.5
		burst.gravity = Vector3(0, -3.5, 0)
		var piece: QuadMesh = QuadMesh.new()
		piece.size = Vector2(0.14, 0.09)
		burst.mesh = piece
		var material: StandardMaterial3D = StandardMaterial3D.new()
		material.albedo_color = colors[index] as Color
		material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
		material.set_meta(StyleToon.META_NO_TOON, true)
		burst.material_override = material
		burst.position = player.position + Vector3(0, 1.4, 0)
		add_child(burst)
		burst.emitting = true
		get_tree().create_timer(3.0).timeout.connect(burst.queue_free)


func _welcome_crowd(colors: Array) -> void:
	var placed: int = 0
	# on the far side of the hero from the camera (north), never between them
	for offset: float in [-0.55, 0.55, -1.2, 1.2, 0.0, -1.7, 1.7]:
		if placed >= 4:
			break
		var angle: float = PI + offset
		var spot: Vector3 = player.position + Vector3(sin(angle), 0, cos(angle)) * 3.2
		if not builder.is_walkable(spot, 0.4):
			continue
		var tint: Color = (colors[placed % colors.size()] as Color).lerp(Color.WHITE, 0.35)
		var citizen: SpriteActor = NpcSprites.make_actor("CITIZEN", tint)
		ModelKit.place(self, citizen, spot, rad_to_deg(atan2(player.position.x - spot.x, player.position.z - spot.z)), TownPlayer.MODEL_SCALE)
		var hop: Tween = citizen.create_tween()
		hop.tween_interval(0.15 * float(placed))
		for jump: int in range(4):
			hop.tween_property(citizen, "position:y", 0.45, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			hop.tween_property(citizen, "position:y", 0.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		hop.tween_interval(2.4)
		hop.tween_property(citizen, "scale", Vector3.ONE * 0.01, 0.4)
		hop.tween_callback(citizen.queue_free)
		placed += 1


## The Capital's music follows the area the hero stands in (`CapitalLayout` areas) and the world state: outside the walls, the facade, each district
## broken or restored by its own Path's completion flag, the Correction Ward, the Crease, the restored city after Primm.
func _play_area_music(fade: float) -> void:
	var area: CapitalLayout.Area = capital.layout.area_at(player.position.x, player.position.z) if capital != null and capital.layout != null else null
	var area_id: String = area.id if area != null else ""
	_music_area = area_id
	Audio.play_music(StringName(MusicDirector.capital_area(area_id, Session.flags, _inside)), fade)
	Audio.set_ambience(ZoneSoundscape.capital_profile(area_id, _inside, Session.flags), maxf(fade, 1.0))
	# every way into a district changes the area music (walking, the gate crossing, the wall passage straight into the Reek, a teleport)
	_welcome_district.call_deferred(area_id)


func _update_area_music(delta: float) -> void:
	_music_timer -= delta
	if _music_timer > 0.0 or capital == null or capital.layout == null:
		return
	_music_timer = 0.5
	var area: CapitalLayout.Area = capital.layout.area_at(player.position.x, player.position.z)
	if area != null and area.id != _music_area:
		_play_area_music(2.0)


func _zone_process(delta: float) -> void:
	capital.animate(delta)
	if _hold_still and not enemies.is_empty():
		_hold_still = false
		for enemy: ZoneEnemy in enemies:
			enemy.process_mode = Node.PROCESS_MODE_DISABLED
	_hide_wall_round_the_lens()
	_update_area_music(delta)
	if not player.airborne and not _fainting and not _traveling and style_rig != null:
		var inside_now: bool = _is_inside(player.position)
		if inside_now != _inside:
			_cross_gate(inside_now)
	if not _ash_added and _camera != null:
		_ash_added = true
		_camera.add_child(CapitalLook.confetti() if Session.flag(CapitalZone.FLAG_FREED) else CapitalLook.ash())
	if _shake > 0.0:
		_camera.position += Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), 0.0) * _shake * 0.12 * Settings.shake_scale()
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
	var passage_x: float = float(CapitalLayout.PASSAGE_X0) + float(CapitalLayout.PASSAGE_W) * 0.5
	if not Session.found_secret(WALL_PASSAGE_SECRET) and z < float(CapitalLayout.WALL_Z0) and z > float(CapitalLayout.WALL_Z0) - 20.0 and absf(player.position.x - passage_x) < 3.0:
		Session.discover_secret(WALL_PASSAGE_SECRET)
		hud.toast("You squeeze through a gap in the wall, right past the gate guards.", Color("ffcf70"))
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
	_camera.position = player.position + CameraRig.shape(camera_offset)
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
		"wren":
			_talk_wren()
		"supplies":
			_open_supplies()
		"ladder":
			_travel_to(builder.anchor("manhole") + Vector3(0, 0, 1.4), "fx.ladder")
		"tunnel_out":
			_travel_to(builder.anchor("tunnel_in") + Vector3(0, 0, 2.2), "fx.tunnel_out")
		"shaft":
			_use_shaft(spot)
		"spotless":
			_talk_spotless()
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
				capital.set_prop_state("family_plot", builder.anchor("pell_plot"), true)
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
		extra += "  (+%d HP)" % int(result["healed"])
	if int(result.get("damage", 0)) > 0:
		extra += "  (-%d HP)" % int(result["damage"])
		_after_self_damage()
	if str(result.get("reward_text", "")) != "":
		extra += "  (%s)" % str(result["reward_text"])
	if lines.size() > 1:
		_say("", lines)
		if not extra.is_empty():
			hud.toast(extra.strip_edges(), color)
	else:
		hud.toast(lines[0] + extra, color)
	EventBus.zone_hp_changed.emit(Session.zone_run.hp, Session.zone_run.max_hp())
	Session.refresh_quests()
	Session.save_game()


func _after_self_damage() -> void:
	if Session.zone_run.is_down():
		_faint("a stern reply from the Complaints Department")


func _talk_wren() -> void:
	_face_npc("wren")
	var lines: Array[String] = _greeting("wren")
	var insights: int = CapitalInteractables.insight_count(Session.flags)
	if insights > 0:
		lines.append_array(story.get_lines("npc.wren.insight.%d" % insights))
	_say("Wren", lines)


func _open_supplies() -> void:
	var data: ItemVendorData = ItemVendorData.new()
	data.vendor_name = "Fig's Crate of Supplies"
	for item_id: String in CapitalZone.BLACK_MARKET_ITEMS.keys():
		data.add(item_id, int(CapitalZone.BLACK_MARKET_ITEMS[item_id]))
	var screen: ItemVendorScreen = ItemVendorScreen.new()
	screen.stock = data
	screen.vendor_screen_id = "VS-FIGSLY"
	screen.screen_title = data.vendor_name
	_open_overlay(screen)
	screen.closed.connect(_close_overlay)


func _use_shaft(spot: ZoneSpot) -> void:
	if not CapitalInteractables.can_travel(Session.flags):
		_say("", story.get_lines("fx.no_travel"))
		return
	var dest: String = str(spot.data["dest"])
	_travel_to(builder.anchor("net_" + dest) + Vector3(0, 0, 1.0), "fx.shaft")


func _talk_spotless() -> void:
	_face_npc("spotless")
	if Session.flag(CapitalZone.FLAG_GATE_OPEN) or Session.flag(CapitalZone.FLAG_FREED):
		_say("Captain Spotless", story.get_lines("npc.spotless.open"))
		return
	_say("Captain Spotless", _greeting("spotless"), _ask_gate_battle)


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
	_say("A Perfectly Happy Citizen", story.get_lines("facade.citizen.%d.%s" % [n, variant]))


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
		Audio.sting(&"STG-RIFT")
		Audio.sfx(&"rift_seal")
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
		_camera.position = player.position + CameraRig.shape(camera_offset)
		_say("Wren", story.get_lines("ending.return"))
		hud.toast(story.text("fx.ending_return"), UIStyle.GOOD)
		for pack_text: String in Session.pending_ending_packs:
			hud.toast(StoryText.shared().text("pack.reward.primm") % pack_text, UIStyle.GOLD)
		Session.pending_ending_packs = []
		return
	if bool(result.get("secret_way", false)) and not bool(result.get("woke_at_hub", false)):
		# Cleared the Old Service Tunnels: the secret way into the Capital comes out in the Crease.
		super()
		_say("", story.get_lines("fx.old_tunnels_way_in"), func() -> void: _travel_to(builder.anchor("crease_spawn")))
		return
	if bool(result.get("gate_opened", false)) and not bool(result.get("woke_at_hub", false)):
		_say("Captain Spotless", story.get_lines("npc.spotless.defeated"))
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
	if str(args.get("still", "false")) == "true":
		# paint-over and match shots: the roaming enemies hold still at their homes (a Tidy-Bot walking up to the hero hid it in the outside shots)
		_hold_still = true


## Outside the wall is the wasteland, inside is the idyllic city (Brief 13): the preset follows where the hero stands.
func _style_preset() -> StringName:
	var state: Dictionary = CapitalBuilder.story_context()
	_inside = _is_inside(player.position)
	capital.set_castle_haze(_inside)
	_play_area_music(0.5)
	if _inside:
		return StylePresets.capital_inside(bool(state["dark"]), bool(state["final"]))
	return StylePresets.capital(bool(state["dark"]), bool(state["final"]))


## Is `pos` north of the city wall (inside the walls)? The gate opening itself counts as outside until the hero is past it.
func _is_inside(pos: Vector3) -> bool:
	var limit: float = float(CapitalLayout.WALL_Z0) + (1.5 if _inside else 0.0)
	return pos.z < limit


func _dress_zone() -> void:
	var quality: int = Settings.graphics_quality
	var layout: CapitalLayout = capital.layout
	# Declutter (the playbook's section 5): inside, the kit's exact rows along the white roads (CapitalDressing), never on a street, a plaza or
	# a route's kerb; outside, the low wasteland scatter only well off the roads and the people. The wasteland's dead trees, ruins and debris
	# stand in the layout's few edge clusters (`CapitalWasteland`).
	var anchors: Array[Vector3] = []
	for key: Variant in layout.anchors.keys():
		anchors.append(layout.anchors[key] as Vector3)
	var clear_of_anchors: Callable = func(pos: Vector3) -> bool:
		for anchor: Vector3 in anchors:
			if absf(anchor.x - pos.x) < 3.0 and absf(anchor.z - pos.z) < 3.0:
				return false
		return true
	var south: Callable = func(pos: Vector3) -> bool:
		return pos.z > float(CapitalLayout.WALL_Z1) + 1.0 and layout.route_edge_distance(pos.x, pos.z) > 2.4 and clear_of_anchors.call(pos)
	# inside, the kit's own exact rows replace the generic facade scatter (unsettling through sameness, CapitalDressing)
	var keep_clear: Array[Vector3] = anchors.duplicate()
	for sign_data: CapitalLayout.Sign in layout.signs:
		keep_clear.append(sign_data.pos)
	for prop: CapitalLayout.Prop in layout.props:
		if prop.radius > 0.0:
			keep_clear.append(prop.pos)
	CapitalDressing.build(self, capital, keep_clear)
	ZoneDressing.build(self, builder, StylePresets.CAPITAL_OUTSKIRTS, quality, [], south, 0.12)
	wasteland = CapitalWasteland.build(self, capital, layout, quality)


## `--at=po_<region>` stands the hero on a recorded paint-over camera spot (`CapitalLayout.PO_CAMERAS`), facing north.
func _teleport(anchor_name: String) -> void:
	if CapitalLayout.PO_CAMERAS.has(anchor_name):
		var at: Vector2 = CapitalLayout.PO_CAMERAS[anchor_name] as Vector2
		player.position = Vector3(at.x, 0.0, at.y)
		player.face(player.position + Vector3(0.0, 0.0, -2.0))
		_camera.position = player.position + CameraRig.shape(camera_offset)
		_spawn_grace = 30.0
		return
	super._teleport(anchor_name)


## The gate crossing: a flash, the whole look and the music change at once.
func _cross_gate(now_inside: bool) -> void:
	_inside = now_inside
	var state: Dictionary = CapitalBuilder.story_context()
	var id: StringName = StylePresets.capital_inside(bool(state["dark"]), bool(state["final"])) if now_inside else StylePresets.capital(bool(state["dark"]), bool(state["final"]))
	var veil: ColorRect = ColorRect.new()
	veil.color = Color(1.0, 0.98, 0.9, 0.0) if now_inside else Color(0.1, 0.1, 0.08, 0.0)
	UIKit.full_rect(veil)
	veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay_layer.add_child(veil)
	var tween: Tween = create_tween()
	tween.tween_property(veil, "color:a", 1.0, 0.25)
	tween.tween_callback(func() -> void:
		style_rig.set_preset(id)
		capital.set_castle_haze(now_inside)
		if look_rig != null:
			look_rig.set_mood(id)
		_play_area_music(0.8)
		Audio.sfx(&"gate_cross")
		hud.toast("Welcome to Primm's Perfection. Everything is perfectly fine." if now_inside else "Back out into the wastes.", UIStyle.GOLD))
	tween.tween_property(veil, "color:a", 0.0, 0.9)
	tween.tween_callback(veil.queue_free)


## When the hero walks just inside the great wall, the camera trails behind it, outside: the fader dims the piece between them to a ghost that still
## covers a third of the screen in the transparent pass (Transit Yards 53 fps, the Reek 56 on Medium). As with the Dump's greenhouse (VD-22), a ghost
## that faint reads as nothing, so once a piece has faded (85 % or more) while it blocks the line from the lens to the hero it is hidden outright, and
## shown again (the fader then fades it back in) when it no longer blocks: no pop, no ghost.
func _hide_wall_round_the_lens() -> void:
	if _camera == null or player == null or capital == null:
		return
	var lens: Vector3 = _camera.global_position
	var hero: Vector3 = player.position + Vector3(0.0, 0.9, 0.0)
	for index: int in range(capital.great_wall.size()):
		var piece: Node3D = capital.great_wall[index]
		var box: AABB = capital.great_wall_boxes[index]
		var blocks: bool = box.has_point(lens)
		for step: int in range(1, 12):
			if blocks:
				break
			blocks = box.has_point(lens.lerp(hero, float(step) / 12.0))
		if blocks and piece.visible and _faded(piece) >= 0.85:
			piece.visible = false
		elif not blocks and not piece.visible:
			piece.visible = true


## How far the occlusion fader has faded a piece (its first mesh's per-instance transparency; the kit pieces hold it one level down).
static func _faded(piece: Node3D) -> float:
	for child: Node in piece.find_children("*", "GeometryInstance3D", true, false):
		return (child as GeometryInstance3D).transparency
	return 0.0
