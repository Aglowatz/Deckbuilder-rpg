class_name PlayScript
extends Node
## Fresh eyes Oct 30: a generic "play script" driver. Plays the real game from the title screen with injected keys, mouse clicks and
## screenshots, following a plain text script, so a reviewer can play like a new player without writing GDScript. Windowed:
##   bash tools/play.sh <script.txt> [run_name]     -> _screenshots/play/<run_name>/<shot>.png + play.log
## One command per line, `#` comments. Coordinates are SCREENSHOT pixels (the window, 1600x900 by default), not canvas units.
##   wait <seconds>                 let the game run
##   key <Name>                     tap a key: E, Space, Escape, Enter, W, Tab, F10, Up, Down, Left, Right, 1 ...
##   hold <Name>[+<Name>] <seconds> hold one or more keys (walking: hold W 2, hold W+A 1.5)
##   click <x> <y>                  left click; rclick <x> <y> right click; move <x> <y> hover
##   pad <a|b|x|y|lb|rb|back|start|up|down|left|right> [s]   tap a controller button; stick <x> <y> <s> hold the left stick (Nov 17)
##   drag <x1> <y1> <x2> <y2>       drag and drop (playing a card)
##   button <text>                  click the first visible button whose text contains <text>
##   shot <name>                    save a screenshot
##   dump                           print every visible label and button (text + screenshot position) to the log
##   scene                          print the current scene and the hero's state (level, gold, hp)
##   pilot <seconds>                let a simple built-in player play the current battle for up to that long (mulligan, plays, attacks, blocks)
##   skip_dialogue [max]            tap E until no dialogue box / story still / popup is open (max taps, default 40)
##   dev <action> ...               debug shortcuts: lowend on|off | textsize 0|1|2 | level N | gold N | hp N | autowin on|off | win | lose | heal | primm 1|2|3 | travel town|forest|capital|arena |
##                                  travel zone <id> | travel dungeon <id> [node] | encounter <spec_id> | quest <id> <step> | freed <zone> |
##                                  gate <zone> | card <id> | item <id> | gear <id> | slots | packs <id> <n> | encounters <query> (list) |
##                                  save <name> / load <name> (a snapshot in user://dev_saves, so a later run can continue where this one stopped) |
##                                  reveal (lift the area's fog for a map shot) |
##                                  goto <spot id> (the hero onto a talk / use spot of the current zone or town; then `key E`)
##   log <text>                     write a note to the log
## The run stops after --limit seconds (default 900) or at the end of the script; every line is echoed to play.log with a timestamp.

const DEFAULT_LIMIT: float = 900.0

var driver: UiDriver
var _out_dir: String = "res://_screenshots/play/run"
var _log_lines: PackedStringArray = []
var _started_msec: int = 0
var _limit: float = DEFAULT_LIMIT
var _lines: PackedStringArray = []
var _log_file: FileAccess = null


func run() -> void:
	_started_msec = Time.get_ticks_msec()
	var args: Dictionary = _parse_args()
	var script_path: String = str(args.get("script", ""))
	_out_dir = str(args.get("out", _out_dir))
	_limit = float(args.get("limit", DEFAULT_LIMIT))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_out_dir))
	var text: String = FileAccess.get_file_as_string(script_path)
	if text.is_empty():
		_say("play: no script at %s" % script_path)
		_finish()
		return
	_lines = text.split("\n")
	driver = UiDriver.new(get_tree())
	Session.save_enabled = false
	await driver.frames(5)
	SceneManager.go_to_title()
	await driver.seconds(1.5)
	for raw: String in _lines:
		if float(Time.get_ticks_msec() - _started_msec) / 1000.0 > _limit:
			_say("play: time limit reached")
			break
		var line: String = raw.strip_edges()
		if line.is_empty() or line.begins_with("#"):
			continue
		_say("> " + line)
		await _run_line(line)
	_finish()


func _parse_args() -> Dictionary:
	var result: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--") and arg.contains("="):
			var parts: PackedStringArray = arg.trim_prefix("--").split("=", true, 1)
			result[parts[0]] = parts[1]
	return result


func _run_line(line: String) -> void:
	var parts: PackedStringArray = line.split(" ", false)
	var command: String = parts[0].to_lower()
	var rest: String = line.substr(parts[0].length()).strip_edges()
	match command:
		"wait":
			await driver.seconds(float(parts[1]) if parts.size() > 1 else 1.0)
		"key":
			var code: Key = _keycode(parts[1] if parts.size() > 1 else "E")
			if code == KEY_NONE:
				_say("  unknown key %s" % rest)
			else:
				await driver.tap_key(code)
				await driver.frames(2)
		"hold":
			var codes: Array[Key] = []
			for name: String in (parts[1] if parts.size() > 1 else "W").split("+", false):
				var code: Key = _keycode(name)
				if code != KEY_NONE:
					codes.append(code)
			for code: Key in codes:
				await driver.key(code, true)
			await driver.seconds(float(parts[2]) if parts.size() > 2 else 1.0)
			for code: Key in codes:
				await driver.key(code, false)
			await driver.frames(2)
		"click":
			await driver.click(_canvas(parts))
		"pad":
			# Overnight Nov 17 (the critics' controller checks): `pad <a|b|x|y|lb|rb|back|start|up|down|left|right> [hold seconds]` taps a
			# game-pad button (device 0, an Xbox layout), as a controller would
			var pad_index: int = _pad_button(parts[1] if parts.size() > 1 else "a")
			if pad_index < 0:
				_say("  unknown pad button %s" % rest)
			else:
				await _pad_event(pad_index, true)
				await driver.seconds(float(parts[2]) if parts.size() > 2 else 0.08)
				await _pad_event(pad_index, false)
				await driver.frames(2)
		"stick":
			# `stick <x> <y> <seconds>`: the left stick held at (x, y) in -1..1 (walking with a controller), then let go
			var sx: float = float(parts[1]) if parts.size() > 1 else 0.0
			var sy: float = float(parts[2]) if parts.size() > 2 else 0.0
			await _stick(sx, sy)
			await driver.seconds(float(parts[3]) if parts.size() > 3 else 1.0)
			await _stick(0.0, 0.0)
			await driver.frames(2)
		"rclick":
			await driver.click(_canvas(parts), MOUSE_BUTTON_RIGHT)
		"move":
			await driver.move_to(_canvas(parts))
		"drag":
			if parts.size() >= 5:
				await driver.drag(_canvas(parts), _canvas(parts, 3))
		"button":
			var found: bool = await driver.click_button(rest)
			_say("  button %s: %s" % [rest, "clicked" if found else "NOT FOUND"])
		"shot":
			await _shot(rest if not rest.is_empty() else "shot")
		"clickcard":
			# Fable Nov 21: `clickcard <card id>` - a real mouse click on that card in the player's hand or on either field (battle only)
			var click_battle: BattleScreen = _find_battle()
			var click_uid: int = 0
			if click_battle != null:
				for seat: int in range(2):
					for candidate: CardInstance in click_battle.game.players[seat].hand + click_battle.game.players[seat].field:
						if candidate.data.id == rest or candidate.data.display_name == rest or str(candidate.uid) == rest:
							click_uid = candidate.uid
			if click_uid == 0:
				_say("  clickcard: %s not found" % rest)
			else:
				var card_at: Vector2 = click_battle.board.center_of(click_uid)
				_say("  clickcard: %s at %s" % [rest, card_at])
				await driver.click(card_at)
				await driver.frames(4)
		"scriptevent":
			# Fable Nov 21: `scriptevent <n>` shows the nth scripted mid-fight event of the current fight as its pop-up (waiting for a click)
			var event_battle: BattleScreen = _find_battle()
			if event_battle == null:
				_say("  scriptevent: no battle")
			else:
				var event_list: Array[EncounterScripts.Trigger] = EncounterScripts.triggers_for_entry(event_battle.context.enemy_name)
				if event_list.is_empty():
					event_list = EncounterScripts.triggers(event_battle.context.enemy_name)
				if event_list.is_empty():
					_say("  scriptevent: %s has no scripted events" % event_battle.context.enemy_name)
				else:
					var event_index: int = clampi(int(parts[1]) if parts.size() > 1 else 0, 0, event_list.size() - 1)
					event_battle.script_banner.show_event(event_list[event_index], event_battle.context.enemy_name, 1.0, true)
					_say("  scriptevent: %s (%d of %d)" % [event_list[event_index].name, event_index + 1, event_list.size()])
					await driver.seconds(0.8)
		"clickportrait":
			# Fable Nov 21: `clickportrait <0|1>` - a real mouse click on the middle of the player's (0) or the opponent's (1) plate as drawn
			var plate_battle: BattleScreen = _find_battle()
			if plate_battle == null:
				_say("  clickportrait: no battle")
			else:
				var plate_rect: Rect2 = plate_battle.hud.plate_rect(int(parts[1]) if parts.size() > 1 else 1)
				_say("  clickportrait: drawn at %s, hit rect %s, mode %d, hp %d / %d" % [plate_rect, plate_battle.hud.portrait_rect(int(parts[1]) if parts.size() > 1 else 1), plate_battle.mode, plate_battle.game.players[0].hp, plate_battle.game.players[1].hp])
				await driver.click(plate_rect.get_center())
				await driver.frames(6)
				_say("  clickportrait: after, mode %d, hp %d / %d" % [plate_battle.mode, plate_battle.game.players[0].hp, plate_battle.game.players[1].hp])
		"dump":
			_dump()
		"scene":
			_scene_info()
		"perf":
			_perf_info()
		"hitch":
			# Fable Nov 21 review (Part 5): `hitch <Key> [seconds]` - taps the key and logs the longest frame of the next seconds (default
			# 1.5): what opening a screen costs the first time and the second time
			var hitch_code: Key = _keycode(parts[1] if parts.size() > 1 else "M")
			var hitch_window: float = float(parts[2]) if parts.size() > 2 else 1.5
			await driver.frames(3)
			var hitch_started: int = Time.get_ticks_usec()
			var hitch_last: int = hitch_started
			var hitch_worst: int = 0
			await driver.key(hitch_code, true)
			await driver.key(hitch_code, false)
			while Time.get_ticks_usec() - hitch_started < int(hitch_window * 1000000.0):
				await get_tree().process_frame
				var hitch_now: int = Time.get_ticks_usec()
				hitch_worst = maxi(hitch_worst, hitch_now - hitch_last)
				hitch_last = hitch_now
			_say("  hitch %s: worst frame %.0f ms in %.1f s" % [parts[1] if parts.size() > 1 else "M", float(hitch_worst) / 1000.0, hitch_window])
		"pilot":
			await _pilot(float(parts[1]) if parts.size() > 1 else 60.0)
		"skip_dialogue":
			await _skip_dialogue(int(parts[1]) if parts.size() > 1 else 40)
		"dev":
			await _dev(parts)
		"log":
			pass
		"hud":
			# Fable Nov 12 (the fixed shot set): `hud off|on` hides / shows the current scene's canvas layers (a clean world shot)
			var scene_now: Node = get_tree().current_scene
			if scene_now != null:
				for child: Node in scene_now.get_children():
					if child is CanvasLayer:
						(child as CanvasLayer).visible = rest != "off"
		"cam":
			# `cam N`: the Settings camera angle (0 Cinematic, the default; 3 Low), never saved in a play run
			Settings.set_camera_angle(int(rest))
			await driver.seconds(0.6)
		"tilt":
			# Fable Nov 21 (Part 6): `tilt N` - the look-down preset (0 = +6, the default ... 4 = +14), never saved in a play run
			Settings.set_camera_tilt(int(rest))
			_say("  tilt: %s" % CameraRig.tilt_toast(Settings.camera_tilt))
			await driver.seconds(0.6)
		"calm":
			# `calm`: the zone's roamers leave the hero alone for ten minutes (shots near a road guard)
			var zone_now: Node = get_tree().current_scene
			if zone_now != null and "_spawn_grace" in zone_now:
				zone_now.set("_spawn_grace", 600.0)
		"spots":
			_spots()
		"edgeshots":
			# Fable Nov 12d (Part 3.2): `edgeshots <prefix>` stands the hero on the eight outermost walkable points of the current place
			# (N, NE, E, SE, S, SW, W, NW of its walkable area) and shoots each at the default and the Low camera.
			await _edge_shots(rest if not rest.is_empty() else "edge")
		"groundscan":
			# Fable Nov 12 (Part 2.5): props floating over or sunk under the ground of the current zone (PropGroundCheck)
			var ground_scene: Node = get_tree().current_scene
			if ground_scene != null and "builder" in ground_scene and ground_scene.get("builder") != null:
				var map: Object = ground_scene.get("builder") as Object
				var found: Array[Dictionary] = PropGroundCheck.scan(ground_scene, func(p: Vector3) -> float: return float(map.call("height_at", p)), 60)
				_say("  groundscan: %d offenders" % found.size())
				for entry: Dictionary in found:
					var at: Vector3 = entry["pos"] as Vector3
					_say("  ground %s %+.2f m  %s at (%.0f, %.0f)" % [str(entry["kind"]), float(entry["gap"]), str(entry["path"]).right(60), at.x, at.z])
			else:
				_say("  groundscan: no zone map here")
		"matscan":
			# Fable Nov 12 (Part 2.2): `matscan [min_size_m]` lists the scene's big untextured surfaces (no albedo texture, no vertex colour),
			# grouped by colour; the pure-white / near-white ones are marked WHITE.
			_matscan(float(rest) if not rest.is_empty() else 2.0)
		"meshscan":
			# Fable Nov 12c (A6): `meshscan <x> <z> [radius]` lists the visible meshes whose box comes within `radius` metres of (x, z):
			# path, box, first material's colour and whether it is textured - to name the thing a screenshot shows.
			_meshscan(float(parts[1]) if parts.size() > 1 else 0.0, float(parts[2]) if parts.size() > 2 else 0.0, float(parts[3]) if parts.size() > 3 else 2.0)
		"fadescan":
			# Fable Nov 19 (Part 1): `fadescan <prefix> [shots]` - what the occlusion fader hides over every walkable cell, at the default
			# and the Low camera; logs the list and shoots the worst spots (default 6) at both cameras.
			await _fade_scan(parts[1] if parts.size() > 1 else "fade", int(parts[2]) if parts.size() > 2 else 6)
		"fadeshot":
			# `fadeshot <name> <x> <z>`: the hero at (x, z), shot at the default and the Low camera, with what the fader hides in the log
			for angle: int in [0, 3]:
				Settings.set_camera_angle(angle)
				_teleport(parts[2], parts[3])
				await driver.seconds(1.5)
				var fader_at: Node = FadeScan.find_fader(get_tree().current_scene)
				var seen: Dictionary = {}
				if fader_at != null:
					for entry: Dictionary in FadeScan.faded_now(fader_at):
						seen["%s[%s %s]" % [str(entry["name"]), str(entry["kind"]), str(entry.get("why", ""))]] = true
				_say("  fadeshot %s cam %d: %s" % [parts[1], angle, ", ".join(PackedStringArray(seen.keys()))])
				if fader_at != null and fader_at.has_method("debug_state"):
					for state_line: String in fader_at.call("debug_state") as PackedStringArray:
						_say("    state: " + state_line)
				await _shot("%s_%s" % [parts[1], "default" if angle == 0 else "low"])
			Settings.set_camera_angle(0)
		"covershot":
			# Fable Nov 21 (Part 7.2): `covershot <name> [nth]` - stands the hero right behind the nth nearest tall batched piece (a tree
			# card, a cabinet) as the camera sees it, and shoots: the round window and the hero's outline should show
			var cover_fader: Node = FadeScan.find_fader(get_tree().current_scene)
			if cover_fader == null:
				_say("  covershot: no fader")
			else:
				cover_fader.call("scan_now")
				var all_pieces: PackedFloat32Array = cover_fader.get("_pieces") as PackedFloat32Array
				var hero_now: Node3D = cover_fader.get("hero") as Node3D
				var camera_now: Camera3D = cover_fader.get("camera") as Camera3D
				var ranked: Array[Array] = []
				for piece_index: int in range(0, all_pieces.size() - 3, 4):
					if all_pieces[piece_index + 3] - hero_now.global_position.y < 3.0:
						continue
					ranked.append([Vector2(all_pieces[piece_index] - hero_now.global_position.x, all_pieces[piece_index + 1] - hero_now.global_position.z).length(), piece_index])
				ranked.sort_custom(func(a: Array, b: Array) -> bool: return float(a[0]) < float(b[0]))
				_say("  covershot: %d pieces, %d tall" % [all_pieces.size() / 4, ranked.size()])
				var nth: int = int(parts[2]) if parts.size() > 2 else 0
				if nth < ranked.size():
					var at_index: int = int(ranked[nth][1])
					var away: Vector3 = hero_now.global_position - camera_now.global_position
					var behind: Vector2 = Vector2(away.x, away.z).normalized() * 3.0
					_teleport(str(all_pieces[at_index] + behind.x), str(all_pieces[at_index + 1] + behind.y))
					await driver.seconds(1.5)
					# the camera has moved with the hero: once more, straight behind the piece from the new lens
					away = hero_now.global_position - camera_now.global_position
					behind = Vector2(away.x, away.z).normalized() * 3.0
					_teleport(str(all_pieces[at_index] + behind.x), str(all_pieces[at_index + 1] + behind.y))
					await driver.seconds(1.5)
					_say("  covershot %s: piece at (%.1f, %.1f) top %.1f; piece_cover %s, hero_hidden %.2f" % [parts[1], all_pieces[at_index], all_pieces[at_index + 1], all_pieces[at_index + 3], str(cover_fader.get("piece_cover")), float(cover_fader.get("hero_hidden"))])
					await _shot(parts[1])
		"camgrid":
			# Fable Nov 19 (Part 2): `camgrid <prefix> <x> <z> <pitches> <dists>` - the hero near (x, z) ("here here" = where he stands), a shot
			# for every pitch bonus x distance (comma lists, e.g. 0,4,6,8 and 0.9,1,1.1): <prefix>_p<pitch>_d<dist>. The place's own default
			# comes back afterwards.
			await _cam_grid(parts)
		"press":
			# Fable Nov 20: `press <node name>` presses the first visible button with that node name (buttons that carry no text)
			var pressed_one: bool = false
			for node: Node in get_tree().root.find_children(parts[1] if parts.size() > 1 else "", "BaseButton", true, false):
				if (node as BaseButton).is_visible_in_tree() and not (node as BaseButton).disabled:
					(node as BaseButton).pressed.emit()
					pressed_one = true
					break
			_say("  press %s: %s" % [parts[1] if parts.size() > 1 else "?", "ok" if pressed_one else "no such button"])
			await driver.seconds(0.4)
		"scrollto":
			# Fable Nov 20: `scrollto <node name>` scrolls the list that holds that control until it shows
			for node: Node in get_tree().root.find_children(parts[1] if parts.size() > 1 else "", "Control", true, false):
				var holder: Node = node.get_parent()
				while holder != null and not (holder is ScrollContainer):
					holder = holder.get_parent()
				if holder != null and (node as Control).is_visible_in_tree():
					(holder as ScrollContainer).ensure_control_visible(node as Control)
					(holder as ScrollContainer).scroll_vertical += 120
					break
			await driver.seconds(0.4)
		"handins":
			# Fable Nov 20 (Part 4.2): `handins [area]` - the quest hand-in probe (tools/run_quest_handin_probe.sh)
			await _handins(parts[1] if parts.size() > 1 else "")
		"fadecat":
			# `fadecat`: every thing the fader knows here, with its type and rule (the fade probe's list)
			var fader_cat: Node = FadeScan.find_fader(get_tree().current_scene)
			if fader_cat != null:
				for row: Dictionary in fader_cat.call("catalogue") as Array[Dictionary]:
					_say("  fadecat | %s | %s | %s | pieces %d" % [str(row["name"]), str(row["type"]), str((row["size"] as Vector3).snapped(Vector3(0.1, 0.1, 0.1))), int(row["pieces"])])
		"fades":
			# `fades`: what the fader hides right now
			var fader_now: Node = FadeScan.find_fader(get_tree().current_scene)
			if fader_now != null:
				for entry: Dictionary in FadeScan.faded_now(fader_now):
					_say("  fades: %s %s %s" % [str(entry["name"]), str(entry["kind"]), str((entry["size"] as Vector3).snapped(Vector3(0.1, 0.1, 0.1)))])
		"at":
			# `at <anchor>`: the hero onto a named anchor of the current zone's map (the Capital's `po_*` camera spots)
			var at_scene: Node = get_tree().current_scene
			if at_scene != null and "builder" in at_scene and (at_scene.get("builder") as Object).call("has_anchor", rest):
				var at_pos: Vector3 = (at_scene.get("builder") as Object).call("anchor", rest) as Vector3
				_say("  " + _teleport(str(at_pos.x), str(at_pos.z)))
			else:
				_say("  at: no anchor %s here" % rest)
		_:
			_say("  unknown command %s" % command)


func _meshscan(x: float, z: float, radius: float) -> void:
	var scene: Node = get_tree().current_scene
	if scene == null:
		return
	var column: AABB = AABB(Vector3(x - radius, -2.0, z - radius), Vector3(radius * 2.0, 40.0, radius * 2.0))
	var count: int = 0
	for node: Node in scene.find_children("*", "GeometryInstance3D", true, false):
		var piece: GeometryInstance3D = node as GeometryInstance3D
		if not piece.is_visible_in_tree():
			continue
		var box: AABB = piece.global_transform * piece.get_aabb()
		if not box.intersects(column) or maxf(box.size.x, box.size.z) > 300.0:
			continue
		var what: String = ""
		if piece is MeshInstance3D and (piece as MeshInstance3D).mesh != null and (piece as MeshInstance3D).mesh.get_surface_count() > 0:
			var material: Material = (piece as MeshInstance3D).get_active_material(0)
			if material is StandardMaterial3D:
				what = "#%s%s" % [(material as StandardMaterial3D).albedo_color.to_html(false), " tex" if (material as StandardMaterial3D).albedo_texture != null else ""]
			elif material is ShaderMaterial:
				what = "shader %s" % (material as ShaderMaterial).shader.resource_path.get_file()
			elif material == null:
				what = "NO MATERIAL"
		count += 1
		_say("  mesh %s  box (%.1f, %.1f, %.1f) + (%.1f, %.1f, %.1f)  transp %.2f  %s" % [str(scene.get_path_to(piece)).right(70), box.position.x, box.position.y, box.position.z, box.size.x, box.size.y, box.size.z, piece.transparency, what])
	_say("  meshscan: %d meshes within %.1f m of (%.0f, %.0f)" % [count, radius, x, z])


## Fable Nov 12 (Part 2.2): the material scan. One line per colour group: how many meshes, the biggest one's size, where one stands.
func _matscan(min_size: float) -> void:
	var scene: Node = get_tree().current_scene
	if scene == null:
		return
	var groups: Dictionary = {}
	for node: Node in scene.find_children("*", "MeshInstance3D", true, false):
		var mesh: MeshInstance3D = node as MeshInstance3D
		if mesh.mesh == null or not mesh.is_visible_in_tree():
			continue
		var box: AABB = mesh.global_transform * mesh.get_aabb()
		var size: float = maxf(box.size.x, maxf(box.size.y, box.size.z))
		if size < min_size:
			continue
		for surface: int in range(mesh.mesh.get_surface_count()):
			var material: Material = mesh.get_active_material(surface)
			var colour: Color = Color(0, 0, 0, 0)
			var textured: bool = true
			if material is ShaderMaterial:
				var shader_material: ShaderMaterial = material as ShaderMaterial
				var uses: Variant = shader_material.get_shader_parameter("use_texture")
				var albedo: Variant = shader_material.get_shader_parameter("albedo")
				if albedo == null or typeof(albedo) != TYPE_COLOR:
					continue
				textured = uses == true or shader_material.get_shader_parameter("use_vertex_color") == true or shader_material.get_shader_parameter("paint_on") == true
				colour = albedo as Color
			elif material is StandardMaterial3D:
				var standard: StandardMaterial3D = material as StandardMaterial3D
				textured = standard.albedo_texture != null or standard.vertex_color_use_as_albedo
				colour = standard.albedo_color
			elif material == null:
				textured = false
				colour = Color.WHITE
			else:
				continue
			if textured or colour.a < 0.5:
				continue
			var key: String = colour.to_html(false)
			if not groups.has(key):
				groups[key] = {"count": 0, "size": 0.0, "where": "", "colour": colour}
			var group: Dictionary = groups[key]
			group["count"] = int(group["count"]) + 1
			if size > float(group["size"]):
				group["size"] = size
				group["where"] = "%s at (%.0f, %.1f, %.0f)" % [str(scene.get_path_to(mesh)).right(70), box.get_center().x, box.get_center().y, box.get_center().z]
	var keys: Array = groups.keys()
	keys.sort_custom(func(x: String, y: String) -> bool: return float(groups[x]["size"]) > float(groups[y]["size"]))
	_say("  matscan: %d untextured colour groups of %.1f m or more" % [keys.size(), min_size])
	for key: String in keys:
		var group: Dictionary = groups[key]
		var colour: Color = group["colour"] as Color
		var white: bool = colour.v > 0.85 and colour.s < 0.12
		_say("  mat #%s%s x%d max %.1f m  %s" % [key, " WHITE" if white else "", int(group["count"]), float(group["size"]), str(group["where"])])


## Fable Nov 12: every spot of the current zone or town with its position (aiming `dev tp` for the fixed shot set).
func _spots() -> void:
	var scene: Node = get_tree().current_scene
	if scene == null or not ("spots" in scene):
		_say("  spots: none here")
		return
	for spot: Variant in scene.get("spots") as Array:
		var pos: Vector3 = spot.get("position") as Vector3
		_say("  spot %s kind=%s (%.1f, %.1f)" % [str(spot.get("id")), str(spot.get("kind")), pos.x, pos.z])
	if "player" in scene:
		var hero: Vector3 = (scene.get("player") as Node3D).position
		_say("  hero (%.1f, %.1f)" % [hero.x, hero.z])


## Screenshot pixels -> canvas units (the window is scaled from the 1920x1080 design canvas).
func _canvas(parts: PackedStringArray, offset: int = 1) -> Vector2:
	var px: Vector2 = Vector2(float(parts[offset]), float(parts[offset + 1])) if parts.size() > offset + 1 else Vector2(800, 450)
	return get_tree().root.get_final_transform().affine_inverse() * px


func _keycode(name: String) -> Key:
	var candidates: Array[String] = [name, name.to_upper(), name.capitalize(), name.to_lower()]
	var aliases: Dictionary = {"esc": "Escape", "return": "Enter", "spacebar": "Space", "pgup": "PageUp", "pgdn": "PageDown"}
	if aliases.has(name.to_lower()):
		candidates.push_front(str(aliases[name.to_lower()]))
	for candidate: String in candidates:
		var code: Key = OS.find_keycode_from_string(candidate)
		if code != KEY_NONE:
			return code
	return KEY_NONE


func _shot(name: String) -> void:
	await RenderingServer.frame_post_draw
	var image: Image = get_tree().root.get_texture().get_image()
	var path: String = "%s/%s.png" % [_out_dir, name.validate_filename()]
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	_say("  shot %s (%s)" % [path, "ok" if error == OK else error_string(error)])


func _dump() -> void:
	var transform: Transform2D = get_tree().root.get_final_transform()
	var count: int = 0
	for node: Node in get_tree().root.find_children("*", "Control", true, false):
		var control: Control = node as Control
		if control == null or not control.is_visible_in_tree():
			continue
		var text: String = ""
		var kind: String = ""
		if control is Button:
			text = (control as Button).text
			kind = "button"
		elif control is Label:
			text = (control as Label).text
			kind = "label"
		elif control is RichTextLabel:
			text = (control as RichTextLabel).get_parsed_text()
			kind = "rich"
		if text.strip_edges().is_empty():
			continue
		var center: Vector2 = transform * control.get_global_rect().get_center()
		var line: String = text.strip_edges().replace("\n", " / ")
		if line.length() > 160:
			line = line.substr(0, 160) + "..."
		_say("  [%s @ %d,%d] %s" % [kind, int(center.x), int(center.y), line])
		count += 1
		if count >= 120:
			_say("  ... (more)")
			break
	if count == 0:
		_say("  (no visible text)")


## Critic pass Nov 6: memory and frame rate right now (for the tech critic): static memory, video memory, FPS, the process frame time.
func _perf_info() -> void:
	var out: Array = []
	OS.execute("tasklist", ["/FI", "PID eq %d" % OS.get_process_id(), "/FO", "CSV", "/NH"], out)
	var working_set: String = str(out[0]).strip_edges().split("\",\"")[-1].replace("\"", "") if out.size() > 0 else "?"
	_say("  perf process_working_set %s" % working_set)
	_say("  perf static_mb %.0f peak_static_mb %.0f video_mb %.0f fps %d frame_ms %.1f objects %d nodes %d" % [OS.get_static_memory_usage() / 1048576.0, OS.get_static_memory_peak_usage() / 1048576.0, Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0, Engine.get_frames_per_second(), Performance.get_monitor(Performance.TIME_PROCESS) * 1000.0, int(Performance.get_monitor(Performance.OBJECT_COUNT)), int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT))])


func _scene_info() -> void:
	var scene: Node = get_tree().current_scene
	var state: String = "no game"
	if Session.profile != null:
		state = "level %d, gold %d" % [Session.profile.level, Session.gold]
		if Session.zone_run != null:
			state += ", run hp %d/%d" % [Session.zone_run.hp, Session.zone_run.max_hp()]
	_say("  scene %s (%s); %s" % [scene.name if scene != null else "-", scene.get_class() if scene != null else "-", state])
	# Fable pass Nov 1: in a zone, where the hero stands and the spots within 4 m (their distance and E reach), so a walk script can be aimed.
	if scene is ZoneScene:
		_say("  " + (scene as ZoneScene).where_am_i())
	elif scene is TownScene:
		_say("  " + (scene as TownScene).where_am_i())


func _find_battle() -> BattleScreen:
	for node: Node in get_tree().root.find_children("*", "BattleScreen", true, false):
		if node is BattleScreen and (node as BattleScreen).is_visible_in_tree():
			return node as BattleScreen
	if get_tree().current_scene is BattleScreen:
		return get_tree().current_scene as BattleScreen
	return null


func _pilot(seconds: float) -> void:
	var battle: BattleScreen = _find_battle()
	if battle == null:
		_say("  pilot: no battle on screen")
		return
	var pilot: BattlePilot = BattlePilot.new(driver, battle)
	var started: int = Time.get_ticks_msec()
	var steps: int = 0
	var last_turn: int = -1
	var stuck: int = 0
	while is_instance_valid(battle) and battle.mode != BattleScreen.Mode.OVER and float(Time.get_ticks_msec() - started) / 1000.0 < seconds:
		if battle.busy or battle.mode == BattleScreen.Mode.WAITING:
			if await BattlePilot.answer_event(driver, battle):
				continue
			await driver.seconds(0.2)
			continue
		# A tutorial tip reads like a player would, then presses Got it; a tip that holds the duel (the tutorial waits for a click the
		# simple player never makes) is skipped once nothing has moved for a while.
		var got_it: Button = driver.find_button("Got it")
		if got_it != null:
			await driver.seconds(0.6)
			await driver.click(driver.button_center(got_it))
			await driver.seconds(0.3)
		var confirm: Button = driver.find_button("End Turn", battle)
		await pilot.act()
		steps += 1
		await driver.seconds(0.25)
		# The end-turn confirm box ("End your turn?" with its own End Turn button, next to the HUD's "End Turn  [Space]"): confirm it.
		for node: Node in get_tree().root.find_children("*", "Button", true, false):
			var dialog: Button = node as Button
			if dialog != confirm and dialog.is_visible_in_tree() and dialog.text.strip_edges() == "End Turn":
				await driver.click(driver.button_center(dialog))
				await driver.seconds(0.2)
				break
		if battle.game != null and battle.game.turn != last_turn:
			last_turn = battle.game.turn
			stuck = 0
		else:
			stuck += 1
		if stuck == 30 or stuck == 70:
			_say("  pilot: the turn is not moving; passing the rest of it")
			pilot.skip_hand()
		if stuck == 40:
			var skip: Button = driver.find_button("Skip tips")
			if skip != null:
				_say("  pilot: the turn is held by a tip; pressing Skip tips")
				await driver.click(driver.button_center(skip))
		if stuck > 120:
			_say("  pilot: stuck on turn %d" % last_turn)
			break
	_say("  pilot: %d decisions, battle %s" % [steps, "over" if not is_instance_valid(battle) or battle.mode == BattleScreen.Mode.OVER else "still running"])


func _skip_dialogue(max_taps: int) -> void:
	var taps: int = 0
	while taps < max_taps:
		var busy: bool = false
		for node: Node in get_tree().root.find_children("*", "", true, false):
			if not (node is CanvasItem) or not (node as CanvasItem).is_visible_in_tree():
				continue
			var cls: String = node.get_class()
			var script_name: String = str(node.get_script().get_global_name()) if node.get_script() != null else ""
			if script_name in ["DialogueBox", "StoryStillScreen", "PopupFrame", "RewardPopup", "CutsceneScreen", "EndingScreen"] or cls == "AcceptDialog":
				busy = true
				break
		if not busy:
			break
		if await driver.dismiss_reward_box(0.05):
			taps += 1
			continue
		await driver.click(Vector2(960, 540))
		await driver.tap_key(KEY_E)
		await driver.seconds(0.35)
		taps += 1
	_say("  skip_dialogue: %d taps" % taps)


func _dev(parts: PackedStringArray) -> void:
	if parts.size() < 2:
		return
	var what: String = parts[1].to_lower()
	var arg: String = parts[2] if parts.size() > 2 else ""
	var arg2: String = parts[3] if parts.size() > 3 else ""
	var battle: BattleScreen = _find_battle()
	var result: String = ""
	match what:
		"newgame":
			# Overnight Oct 31 - Nov 1: a fresh game as the title's New Game starts one, without the campaign slot screen (every slot on the
			# dev PC holds a save; this driver never saves, so no slot is touched).
			Session.save_enabled = false
			Session.new_game()
			SceneManager.go_to_start_area()
			result = "New game started (no slot touched, saving off)"
		"textsize":
			# Nov 13: `dev textsize 0|1|2` - the Text size switch (Normal, Large, Larger) for this run (never saved: --no-save).
			Settings.set_text_master(int(arg))
			Settings.text_changed.emit()
			Settings.apply_tooltip_theme()
			result = "Text size %s" % arg
		"lowend":
			# Fixes Nov 8: `dev lowend on|off` - the Low-end preset (or Medium) for this run, as the Settings row sets it (never saved: --no-save).
			Settings.low_end = arg == "on"
			Settings.graphics_quality = GraphicsQuality.Level.LOW if Settings.low_end or arg == "low" else GraphicsQuality.Level.MEDIUM
			Settings.apply_quality_preset()
			Settings.apply_performance()
			Settings.graphics_changed.emit()
			result = "Low-end %s" % ("on" if Settings.low_end else "off (Medium)")
		"hand":
			# Fable Nov 21: `dev hand <card id>` puts that card in the player's hand in the running battle, with energy of every Path to play it
			if battle == null or Session.content.card(arg) == null:
				result = "hand: no battle or unknown card %s" % arg
			else:
				if battle.game.players[0].infrastructure.size() < 8:
					for path: Affinity.Type in Affinity.colored_types():
						for copy: int in range(3):
							battle.game.players[0].infrastructure.append(battle.game.create_instance(CardBuilder.infra(path), 0))
				var added: CardInstance = battle.game.create_instance(Session.content.card(arg), 0)
				battle.game.players[0].hand.append(added)
				battle.board.sync_state(false)
				battle.call("_refresh_ui")
				result = "hand: %s (uid %d)" % [added.data.display_name, added.uid]
		"field":
			# Fable Nov 21: `dev field <attack> <defense> [0|1]` puts a plain ready unit on the field of the player (0) or the opponent (1)
			if battle == null:
				result = "field: no battle"
			else:
				var seat: int = int(parts[4]) if parts.size() > 4 else 0
				var plain: CardData = CardBuilder.unit("vanilla_%d_%d" % [int(arg), int(arg2)], "Test unit %d/%d" % [int(arg), int(arg2)], Affinity.Type.BEEFCAKE, 1, [] as Array[Affinity.Type], int(arg), int(arg2), [] as Array[CardEnums.Keyword])
				var unit: CardInstance = battle.game.create_instance(plain, seat)
				battle.game.players[seat].field.append(unit)
				unit.just_arrived = false
				unit.exhausted = false
				battle.board.sync_state(false)
				battle.call("_refresh_ui")
				result = "field: %d/%d for seat %d (uid %d)" % [int(arg), int(arg2), seat, unit.uid]
		"level":
			result = DevActions.set_level(int(arg), true)
		"gold":
			result = DevActions.add_gold(int(arg))
		"autowin":
			result = DevActions.set_auto_win(arg == "on")
		"win":
			result = DevActions.end_battle(battle, true) if battle != null else "no battle"
		"lose":
			result = DevActions.end_battle(battle, false) if battle != null else "no battle"
		"find":
			# debugging aid: `dev find <NodeName>` prints where a 3D node is and whether it is drawn
			for found: Node in get_tree().current_scene.find_children(arg, "Node3D", true, false):
				var n3: Node3D = found as Node3D
				var line: String = "  find %s at %s visible %s path %s" % [n3.name, str(n3.global_position), str(n3.is_visible_in_tree()), str(n3.get_path())]
				if n3 is MeshInstance3D:
					var mi: MeshInstance3D = n3 as MeshInstance3D
					line += " layers %d mat %s transparency %.2f basis %s" % [mi.layers, str(mi.material_override), mi.transparency, str(mi.global_transform.basis)]
				_say(line)
			result = "find done"
		"reveal":
			# Fable Nov 20 day: lift the fog of the current area (map shots with every marker on)
			var scene_now: Node = get_tree().current_scene
			var mini: MinimapHud = scene_now.get("minimap") as MinimapHud if scene_now != null else null
			if mini != null:
				mini.reveal_all()
			_say("  reveal: %s" % ("done" if mini != null else "no minimap here"))
		"heal":
			result = DevActions.full_heal(battle)
		"hp":
			# Fable Nov 22 night: `dev hp N` sets the hero's HP (in a battle, or the run's between fights), to show a heal room working
			result = DevActions.set_hp(int(arg), battle)
		"primm":
			# Fix pass Nov 7 (item 10): the checkpoint between Primm's phases - straight to phase 1, 2 or 3 at the castle's boss node
			result = DevActions.travel_primm_phase(int(arg))
			await driver.seconds(3.0)
		"travel":
			match arg:
				"town":
					result = DevActions.travel_town()
				"forest":
					result = DevActions.travel_forest()
				"capital":
					result = DevActions.travel_capital_inside()
				"arena":
					result = DevActions.travel_arena()
				"zone":
					result = DevActions.travel_zone(arg2, parts[4] if parts.size() > 4 else "")  # Import Nov 8: an optional anchor ("quiz")
				"dungeon":
					result = DevActions.travel_dungeon(arg2, int(parts[4]) if parts.size() > 4 else -1)
				"route":
					# Fable Nov 21 castle: `dev travel route <dungeon id> <room,room,...>` - the dungeon with those rooms walked in order
					result = DevActions.travel_route(arg2, parts[4] if parts.size() > 4 else "")
				_:
					result = "unknown travel target %s" % arg
			await driver.seconds(3.0)
		"encounters":
			var found: Array[EncounterSpec] = DevActions.find_encounters(arg, 60)
			for spec: EncounterSpec in found:
				_say("  %s  (%s) %s" % [spec.id, spec.group, spec.enemy_name])
			result = "%d encounters match %s" % [found.size(), arg]
		"encounter":
			var matches: Array[EncounterSpec] = DevActions.find_encounters(arg, 5)
			if matches.is_empty():
				result = "no encounter matches %s" % arg
			else:
				result = DevActions.start_encounter(matches[0].id)
				await driver.seconds(3.0)
		"quest":
			result = DevActions.set_quest_step(arg, int(arg2))
		"freed":
			result = DevActions.set_zone_freed(arg, true)
		"gate":
			result = DevActions.set_gatekeeper(arg, true)
		"card":
			result = DevActions.add_card(arg, false)
		"item":
			result = DevActions.add_item(arg)
		"gear":
			result = DevActions.add_equipment(arg)
		"slots":
			result = DevActions.unlock_deck_slots()
		"packs":
			result = DevActions.add_packs(arg, int(arg2) if not arg2.is_empty() else 1)
		"flag":
			# Fresh eyes round 2 (Oct 31): `dev flag trial_cleared` (or `... off`) - a snapshot taken before the cave was cleared resumes in the
			# forest (`Session.resume_loaded_game`), where the town hotkeys are dead; the mid-game snapshot sets this flag.
			Session.set_flag(StringName(arg), arg2 != "off" and arg2 != "0")
			result = "flag %s = %s" % [arg, str(Session.flag(StringName(arg)))]
		"hand", "energy", "play":
			# Fix pass Nov 4: `dev hand <card id>` puts a card in your battle hand, `dev energy` lays one of every basic infrastructure,
			# `dev play <card id>` plays that hand card as a click would (Peek and other choices then show their real panels).
			if battle == null:
				result = "no battle"
			elif what == "hand":
				var data: CardData = Session.content.card(arg)
				if data == null:
					result = "no card %s" % arg
				else:
					battle.game.players[0].hand.append(battle.game.create_instance(data, 0))
					battle.board.register_all()
					battle.board.sync_state(false)
					battle.board.layout(false)
					result = "%s in hand" % data.display_name
			elif what == "energy":
				for number: int in range(1, 12):
					var infra: CardData = load("res://data/cards/INF-%02d.tres" % number) as CardData
					if infra != null:
						battle.game.players[0].infrastructure.append(battle.game.create_instance(infra, 0))
				battle.board.register_all()
				battle.board.sync_state(false)
				battle.board.layout(false)
				battle.hud.refresh_all()
				result = "energy laid"
			else:
				result = "no %s in hand" % arg
				for card: CardInstance in battle.game.players[0].hand:
					if card.data.id == arg:
						battle._try_play(card.uid)
						result = "played %s" % card.data.display_name
						break
				await driver.seconds(1.5)
		"goto":
			# Batch 11 (Nov 2): `dev goto <spot id>` stands the hero on a talk / use spot of the current zone or town (then `key E` uses it), the
			# walk smokes' shortcut for long legs; the camera follows at once.
			result = _goto_spot(arg)
		"essence":
			# Fix pass Nov 4 (B): `dev essence <path> <n>` sets that Path's essence (Auntie Alembic's crafting check)
			var essence_path: Affinity.Type = Affinity.Type.NEUTRAL
			for candidate: Affinity.Type in Affinity.colored_types():
				if Affinity.display_name(candidate).to_lower() == arg.to_lower():
					essence_path = candidate
			if essence_path == Affinity.Type.NEUTRAL or Session.profile == null:
				result = "essence: unknown Path %s" % arg
			else:
				Session.profile.set_essence(essence_path, int(arg2))
				result = "%s essence = %d" % [arg, Session.profile.essence_of(essence_path)]
		"draft":
			# Draft mode, Phase 1: `dev draft open` opens Trey Pickett's table where you stand; `dev draft start <challenge>`, `dev draft pick <n>`,
			# `dev draft autopick` (every pick, the first option), `dev draft lock`, `dev draft fight`, `dev draft finish`, `dev draft won` (books a win)
			result = DevActions.draft(arg, arg2, get_tree().current_scene)
		"arena":
			# Fable Nov 20 (Part 7): `dev arena <encounter id>` starts that Arena bout or puzzle at once (every tier counted open)
			for tier: int in range(1, ArenaDefs.TIER_COUNT + 1):
				for bout: ArenaEncounter in ArenaDefs.in_tier(tier):
					if bout.tier < (ArenaDefs.find(arg).tier if ArenaDefs.find(arg) != null else 1):
						Session.set_flag(ArenaDefs.flag_name(bout.id))
			Session.set_flag(&"arena_unlocked")
			Session.start_battle(Session.make_arena_battle(arg))
			result = "Arena: %s started" % arg
		"shiro":
			# Fix pass Nov 4 (B): `dev shiro` opens the five giant chests (the hidden quest) and starts the duel with Shiro Swindle
			for chest_id: String in NinjaBoss.CHEST_IDS:
				Session.open_giant_chest(chest_id)
			Session.pending_popups.clear()
			Session.challenge_ninja()
			result = "Shiro: chests opened, duel started"
		"postgame":
			result = DevActions.set_primm_defeated(true)
		"tp":
			# Fix pass Nov 4 (B): `dev tp <x> <z>` stands the hero at a world position (ground height from the map), camera following - for edge shots
			result = _teleport(arg, arg2)
		"secret":
			# Batch 11: `dev secret harbor_chest` - a found secret (the Secret Dealer's alley opens on the next town load)
			Session.discover_secret(arg)
			result = "secret %s found" % arg
		"save":
			result = DevActions.save_snapshot(arg)
		"load":
			result = DevActions.load_snapshot(arg)
			await driver.seconds(3.0)
		_:
			result = "unknown dev action %s" % what
	_say("  dev: %s" % result)
	await driver.seconds(0.5)


## The hero onto the spot `id` of the current scene (a ZoneScene or the TownScene: both keep `spots`, `player`, `_camera`, `camera_offset`).
## Fable Nov 20 (Part 4.2): the quest hand-in probe. For every quest that is handed in to somebody (`QuestData.turn_in_npc`): the quest
## is set to "every step done", the hero is put in the hand-in area on that NPC's spot, E is pressed and the talk is clicked through;
## the quest must then be completed. It fails when the NPC's spot is not in that area in that state, or when the talk does not
## complete the quest (Gatekeeper Brannoch's "Outskirts Watch" could not be handed in). One line per quest: `handin | PASS/FAIL | ...`.
func _handins(only_area: String) -> void:
	var by_area: Dictionary = {}
	var order: Array[String] = []
	for quest: QuestData in QuestCatalog.all():
		if quest.turn_in_npc.is_empty():
			continue
		if quest.turn_in_area.is_empty() or quest.turn_in_spot.is_empty():
			_say("  handin | FAIL | %s | %s | no hand-in place set (area '%s', spot '%s')" % [quest.id, quest.turn_in_npc, quest.turn_in_area, quest.turn_in_spot])
			continue
		if not only_area.is_empty() and quest.turn_in_area != only_area:
			continue
		if not by_area.has(quest.turn_in_area):
			by_area[quest.turn_in_area] = [] as Array[QuestData]
			order.append(quest.turn_in_area)
		(by_area[quest.turn_in_area] as Array[QuestData]).append(quest)
	var passed: int = 0
	var failed: int = 0
	for area: String in order:
		for quest: QuestData in by_area[area] as Array[QuestData]:
			# a fresh game per quest: one quest's forced steps (a zone freed, Primm beaten) never change who stands where for the next
			Session.save_enabled = false
			Session.new_game()
			Session.ensure_game(Affinity.Type.BEEFCAKE)
			DevActions.set_level(12, true)
			Session.set_flag(&"trial_cleared")
			Session.set_flag(&"elder_greeted")
			Session.set_flag(&"maren_met")
			DevActions.set_quest_step(quest.id, quest.objectives.size())
			var ready: bool = Session.quest_log.is_ready_to_turn_in(quest, Session.unlock_state())
			if area == "town":
				DevActions.travel_town()
			else:
				DevActions.travel_zone(area)
			await driver.seconds(14.0 if area == "final" else 9.0)
			await _skip_dialogue(30)
			var scene_now: Node = get_tree().current_scene
			if scene_now != null and "_spawn_grace" in scene_now:
				scene_now.set("_spawn_grace", 600.0)
			var went: String = _goto_spot(quest.turn_in_spot)
			if went.begins_with("goto: no spot") and area == "final":
				DevActions.travel_capital_inside()
				await driver.seconds(12.0)
				await _skip_dialogue(30)
				went = _goto_spot(quest.turn_in_spot)
			if went.begins_with("goto: "):
				failed += 1
				_say("  handin | FAIL | %s | %s | %s/%s | the NPC's spot is not there in this state (%s)" % [quest.id, quest.turn_in_npc, area, quest.turn_in_spot, went])
				continue
			await driver.seconds(0.8)
			var tries: int = 0
			while not Session.quest_log.is_completed(quest.id) and tries < 3:
				await driver.tap_key(KEY_E)
				await driver.seconds(0.6)
				await _skip_dialogue(40)
				await driver.seconds(0.4)
				tries += 1
			if Session.quest_log.is_completed(quest.id):
				passed += 1
				_say("  handin | PASS | %s | %s | %s/%s | talks %d%s" % [quest.id, quest.turn_in_npc, area, quest.turn_in_spot, tries, "" if ready else " (not ready after forcing every step: check the step conditions)"])
			else:
				failed += 1
				_say("  handin | FAIL | %s | %s | %s/%s | talking %d times did not complete it (ready before the talk: %s)" % [quest.id, quest.turn_in_npc, area, quest.turn_in_spot, tries, str(ready)])
			await _skip_dialogue(20)
	_say("  handin: %d passed, %d failed" % [passed, failed])


func _goto_spot(id: String) -> String:
	var scene: Node = get_tree().current_scene
	if scene == null or not ("spots" in scene) or not ("player" in scene):
		return "goto: no spots in this scene"
	for spot: Variant in scene.get("spots") as Array:
		if str(spot.get("id")) != id:
			continue
		var player: Node3D = scene.get("player") as Node3D
		player.position = spot.get("position") as Vector3
		var camera: Camera3D = scene.get("_camera") as Camera3D
		if camera != null:
			camera.position = player.position + CameraRig.shape(scene.get("camera_offset") as Vector3)
		return "goto %s at %s" % [id, str(player.position)]
	return "goto: no spot %s here" % id


func _teleport(x_text: String, z_text: String) -> String:
	var scene: Node = get_tree().current_scene
	if scene == null or not ("player" in scene):
		return "tp: no hero here"
	var x: float = float(x_text)
	var z: float = float(z_text)
	var player: Node3D = scene.get("player") as Node3D
	var map: Variant = scene.get("builder") if "builder" in scene else null
	var y: float = player.position.y
	if map != null and (map as Object).has_method("height_at"):
		y = float((map as Object).call("height_at", Vector3(x, 0.0, z)))
	player.position = Vector3(x, y, z)
	var camera: Camera3D = scene.get("_camera") as Camera3D
	if camera != null:
		camera.position = player.position + CameraRig.shape((scene.get("camera_offset") if "camera_offset" in scene else scene.get("_camera_offset")) as Vector3)
	return "tp to %s" % str(player.position)


## The walkable map of the current scene: a zone's `builder`, Crosspath's `town`, the forest's `area` (each has `is_walkable`).
func _walk_map() -> Object:
	var scene: Node = get_tree().current_scene
	if scene == null:
		return null
	for field: String in ["builder", "town", "area"]:
		if field in scene:
			var map: Object = scene.get(field) as Object
			if map != null and map.has_method("is_walkable"):
				return map
	return null


func _edge_shots(prefix: String) -> void:
	var map: Object = _walk_map()
	var scene: Node = get_tree().current_scene
	if map == null or not ("player" in scene):
		_say("  edgeshots: no walkable map here")
		return
	var dirs: Dictionary = {"n": Vector2(0, -1), "ne": Vector2(1, -1), "e": Vector2(1, 0), "se": Vector2(1, 1), "s": Vector2(0, 1), "sw": Vector2(-1, 1), "w": Vector2(-1, 0), "nw": Vector2(-1, -1)}
	var best: Dictionary = {}
	var score: Dictionary = {}
	var total: Vector3 = Vector3.ZERO
	var cells: int = 0
	for xi: int in range(-60, 261):
		for zi: int in range(-60, 261):
			var at: Vector3 = Vector3(float(xi) + 0.5, 0.0, float(zi) + 0.5)
			if not bool(map.call("is_walkable", at)):
				continue
			total += at
			cells += 1
			for key: String in dirs.keys():
				var value: float = (dirs[key] as Vector2).normalized().dot(Vector2(at.x, at.z))
				if not score.has(key) or value > float(score[key]):
					score[key] = value
					best[key] = at
	var player: Node3D = scene.get("player") as Node3D
	var camera: Camera3D = scene.get("_camera") as Camera3D
	for key: String in dirs.keys():
		if not best.has(key):
			continue
		if get_tree().current_scene != scene or not is_instance_valid(player):
			_say("  edgeshots: the scene changed, stopping")
			return
		var at: Vector3 = best[key] as Vector3
		# 3 m in from the outermost point (toward the middle of the walkable area): the outermost point is often an exit trigger.
		var inward: Vector3 = (total / float(maxi(cells, 1)) - at).normalized()
		for back: float in [3.0, 2.0, 1.0]:
			if bool(map.call("is_walkable", at + inward * back)):
				at += inward * back
				break
		var y: float = player.position.y
		if map.has_method("height_at"):
			y = float(map.call("height_at", at))
		player.position = Vector3(at.x, y, at.z)
		if "_spawn_grace" in scene:
			scene.set("_spawn_grace", 600.0)
		for angle: int in [0, 3]:
			Settings.set_camera_angle(angle)
			if camera != null and ("camera_offset" in scene or "_camera_offset" in scene):
				camera.position = player.position + CameraRig.shape((scene.get("camera_offset") if "camera_offset" in scene else scene.get("_camera_offset")) as Vector3)
			await driver.seconds(1.4)
			if get_tree().current_scene != scene or not is_instance_valid(player):
				_say("  edgeshots: the scene changed, stopping")
				return
			await _shot("%s_%s_%s" % [prefix, key, "default" if angle == 0 else "low"])
		_say("  edgeshots: %s at (%.1f, %.1f)" % [key, at.x, at.z])
	Settings.set_camera_angle(0)


func _cam_grid(parts: PackedStringArray) -> void:
	var scene: Node = get_tree().current_scene
	if scene == null or not ("player" in scene) or parts.size() < 6:
		_say("  camgrid: needs a walkable scene and <prefix> <x> <z> <pitches> <dists>")
		return
	var player: Node3D = scene.get("player") as Node3D
	var map: Object = _walk_map()
	var at: Vector3 = player.position
	if parts[2] != "here":
		at = Vector3(float(parts[2]), 0.0, float(parts[3]))
		# the nearest walkable cell (a ring search, half a metre steps)
		var found: bool = map == null or bool(map.call("is_walkable", at))
		var ring: float = 0.5
		while not found and ring < 8.0:
			for step: int in range(16):
				var probe: Vector3 = at + Vector3(cos(TAU * float(step) / 16.0), 0.0, sin(TAU * float(step) / 16.0)) * ring
				if bool(map.call("is_walkable", probe)):
					at = probe
					found = true
					break
			ring += 0.5
	if "_spawn_grace" in scene:
		scene.set("_spawn_grace", 600.0)
	var keep_pitch: float = CameraRig.zone_pitch_target
	var keep_dist: float = CameraRig.zone_distance_target
	for pitch: String in parts[4].split(","):
		for dist: String in parts[5].split(","):
			if get_tree().current_scene != scene or not is_instance_valid(player):
				return
			CameraRig.zone_pitch_bonus = float(pitch)
			CameraRig.zone_pitch_target = float(pitch)
			CameraRig.zone_distance = float(dist)
			CameraRig.zone_distance_target = float(dist)
			_teleport(str(at.x), str(at.z))
			await driver.seconds(0.9)
			await _shot("%s_p%s_d%s" % [parts[1], pitch, dist])
	CameraRig.zone_pitch_bonus = keep_pitch
	CameraRig.zone_pitch_target = keep_pitch
	CameraRig.zone_distance = keep_dist
	CameraRig.zone_distance_target = keep_dist
	_say("  camgrid %s at (%.1f, %.1f)" % [parts[1], at.x, at.z])


func _fade_scan(prefix: String, shots: int) -> void:
	var scene: Node = get_tree().current_scene
	var map: Object = _walk_map()
	if map == null or not ("player" in scene):
		_say("  fadescan: no walkable map here")
		return
	var spots: Array[Dictionary] = []
	var rows: Array[Dictionary] = FadeScan.scan(scene, map, spots, shots)
	var counts: Dictionary = {}
	for row: Dictionary in rows:
		counts[row["kind"]] = int(counts.get(row["kind"], 0)) + 1
	_say("  fadescan %s: %d things can fade %s" % [prefix, rows.size(), str(counts)])
	for row: Dictionary in rows:
		_say("  fadescan row | %s | %s | %s | %d cells | cams %s" % [str(row["name"]), str(row["kind"]), str((row["size"] as Vector3).snapped(Vector3(0.1, 0.1, 0.1))), int(row["count"]), str((row["cams"] as Dictionary).keys())])
	var player: Node3D = scene.get("player") as Node3D
	if "_spawn_grace" in scene:
		scene.set("_spawn_grace", 600.0)
	var index: int = 0
	for spot: Dictionary in spots:
		index += 1
		var at: Vector3 = spot["pos"] as Vector3
		_say("  fadescan spot %d (%.1f, %.1f) cam %d score %.0f: %s" % [index, at.x, at.z, int(spot["cam"]), float(spot["score"]), ", ".join(spot["names"] as PackedStringArray)])
		for angle: int in [0, 3]:
			if get_tree().current_scene != scene or not is_instance_valid(player):
				return
			Settings.set_camera_angle(angle)
			_teleport(str(at.x), str(at.z))
			await driver.seconds(1.6)
			await _shot("%s_%d_%s" % [prefix, index, "default" if angle == 0 else "low"])
	Settings.set_camera_angle(0)


func _say(text: String) -> void:
	var stamp: String = "%6.1f" % (float(Time.get_ticks_msec() - _started_msec) / 1000.0)
	var line: String = "%s %s" % [stamp, text]
	print("play: " + text)
	_log_lines.append(line)
	# Written as it goes, so a run killed at its time limit keeps its log.
	if _log_file == null:
		_log_file = FileAccess.open("%s/play.log" % _out_dir, FileAccess.WRITE)
	if _log_file != null:
		_log_file.store_line(line)
		_log_file.flush()


func _finish() -> void:
	_say("play: done")
	if _log_file != null:
		_log_file.close()
	get_tree().quit(0)


# ---- Overnight Nov 17: controller input for the critics ------------------------------------------------------------------------------------


func _pad_button(name: String) -> int:
	var table: Dictionary = {"a": JOY_BUTTON_A, "b": JOY_BUTTON_B, "x": JOY_BUTTON_X, "y": JOY_BUTTON_Y, "lb": JOY_BUTTON_LEFT_SHOULDER,
		"rb": JOY_BUTTON_RIGHT_SHOULDER, "back": JOY_BUTTON_BACK, "start": JOY_BUTTON_START, "up": JOY_BUTTON_DPAD_UP,
		"down": JOY_BUTTON_DPAD_DOWN, "left": JOY_BUTTON_DPAD_LEFT, "right": JOY_BUTTON_DPAD_RIGHT}
	return int(table.get(name.to_lower(), -1))


func _pad_event(button: int, pressed: bool) -> void:
	var event: InputEventJoypadButton = InputEventJoypadButton.new()
	event.device = 0
	event.button_index = button as JoyButton
	event.pressed = pressed
	event.pressure = 1.0 if pressed else 0.0
	Input.parse_input_event(event)
	await driver.frames(1)


func _stick(x: float, y: float) -> void:
	for axis: Array in [[JOY_AXIS_LEFT_X, x], [JOY_AXIS_LEFT_Y, y]]:
		var event: InputEventJoypadMotion = InputEventJoypadMotion.new()
		event.device = 0
		event.axis = axis[0] as JoyAxis
		event.axis_value = float(axis[1])
		Input.parse_input_event(event)
	await driver.frames(1)
