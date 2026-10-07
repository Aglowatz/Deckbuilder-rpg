class_name VaultLeverEvent
extends RefCounted
## Brief 16, Group G: pulling a hidden vault lever. A heavy mechanical clunk, a short screen shake, then a cutaway card over the world - four seal discs (one per Path) with
## the newly broken one flashing, and "Far away, a great lock grinds open... (n/4)" - so it is clear something happened far away. Works in any ZoneScene (`player`, `hud`,
## `set_world_locked`, `shake_camera`, `_overlay_layer`).

const CUTAWAY_SECONDS: float = 3.0


## The colour of zone `zone_id`'s seal.
static func seal_color(zone_id: String) -> Color:
	match zone_id:
		"beefcake":
			return UIStyle.affinity_color(Affinity.Type.BEEFCAKE)
		"gourmand":
			return UIStyle.affinity_color(Affinity.Type.GOURMAND)
		"refusemancer":
			return UIStyle.affinity_color(Affinity.Type.REFUSEMANCER)
		"necrocrat":
			return UIStyle.affinity_color(Affinity.Type.NECROCRAT)
	return UIStyle.GOLD


static func play(host: Node3D, zone_id: String, lever: Node3D) -> void:
	var player: TownPlayer = host.get("player") as TownPlayer
	var hud: TownHud = host.get("hud") as TownHud
	var tree: SceneTree = host.get_tree()
	if Session.vault_lever_pulled(zone_id):
		hud.toast("The lever is stuck fast. It has already done its work.", UIStyle.MUTED)
		return
	host.call("set_world_locked", true)
	player.input_enabled = false
	player.face(lever.global_position)
	var result: Dictionary = Session.pull_vault_lever(zone_id)
	Audio.sfx(&"lever_clunk")
	LeverKit.pull_animated(lever)
	host.call("shake_camera", 0.7, 0.35)
	await tree.create_timer(0.55).timeout
	Audio.sfx(&"vault_grind", -2.0, 0.02)
	host.call("shake_camera", 1.0, 1.6)
	var layer: Control = host.get("_overlay_layer") as Control
	var cutaway: Control = _cutaway(int(result.get("count", Session.vault_levers_pulled())), zone_id)
	layer.add_child(cutaway)
	await tree.create_timer(CUTAWAY_SECONDS).timeout
	var fade: Tween = cutaway.create_tween()
	fade.tween_property(cutaway, "modulate:a", 0.0, 0.5)
	await fade.finished
	cutaway.queue_free()
	Session.save_game()
	host.call("set_world_locked", false)
	player.input_enabled = true


## The cutaway card: letterbox bars, the four seals and the message.
static func _cutaway(count: int, new_zone: String) -> Control:
	var root: Control = Control.new()
	root.name = "VaultCutaway"
	UIKit.full_rect(root)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.z_index = 50
	for bar_y: float in [0.0, 1080.0 - 150.0]:
		var bar: ColorRect = ColorRect.new()
		bar.color = Color(0.02, 0.01, 0.04, 0.88)
		bar.position = Vector2(0, bar_y)
		bar.size = Vector2(1920, 150)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		root.add_child(bar)
	var panel: PanelContainer = UIKit.panel(&"DarkPanel")
	panel.position = Vector2(460, 380)
	panel.custom_minimum_size = Vector2(1000, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(panel)
	var column: VBoxContainer = UIKit.vbox(14)
	panel.add_child(column)
	var row: HBoxContainer = UIKit.hbox(34)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(row)
	var broken: int = 0
	for zone_id: String in VaultGuardian.ZONE_IDS:
		var lit: bool = Session.vault_lever_pulled(zone_id)
		row.add_child(_seal(seal_color(zone_id), lit, zone_id == new_zone))
		if lit:
			broken += 1
	var text: Label = UIKit.label(VaultGuardian.pulled_message(maxi(count, broken)), &"HeadingLabel", 34, Color(0, 0, 0, 0), HORIZONTAL_ALIGNMENT_CENTER)
	text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text.custom_minimum_size = Vector2(920, 0)
	column.add_child(text)
	root.modulate.a = 0.0
	root.create_tween().tween_property(root, "modulate:a", 1.0, 0.35)
	return root


static func _seal(color: Color, lit: bool, is_new: bool) -> Control:
	var holder: Control = Control.new()
	holder.custom_minimum_size = Vector2(150, 150)
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var disc: TextureRect = TextureRect.new()
	disc.texture = UIStyle.circle_texture(140, color.lerp(Color(0.08, 0.07, 0.1), 0.0 if lit else 0.82), color.darkened(0.3) if lit else Color(0.25, 0.24, 0.3), 6)
	disc.position = Vector2(5, 5)
	disc.size = Vector2(140, 140)
	disc.pivot_offset = Vector2(70, 70)
	disc.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(disc)
	if not lit:
		var cross: Label = UIKit.label("+", &"", 90, Color(0.3, 0.28, 0.36), HORIZONTAL_ALIGNMENT_CENTER)
		cross.size = Vector2(150, 150)
		cross.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		holder.add_child(cross)
	if is_new:
		var pop: Tween = disc.create_tween().set_loops(3)
		pop.tween_property(disc, "scale", Vector2(1.18, 1.18), 0.22)
		pop.tween_property(disc, "scale", Vector2.ONE, 0.22)
	return holder


## Screenshot/dev helper (`--lever=1`): pulls this zone's lever once the scene has settled.
static func screenshot_run(host: Node3D, zone_id: String, lever: Node3D) -> void:
	await host.get_tree().create_timer(1.0).timeout
	play(host, zone_id, lever)
