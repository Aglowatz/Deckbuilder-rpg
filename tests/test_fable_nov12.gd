extends GutTest
## Fable Nov 12 (Part 6.3): the pins for this pass.
## - Primm's phase restart (owner decision on inbox 13: no change): a lost castle run starts Primm over at Phase 1; winning a phase moves
##   to the next; and the dev checkpoint grants the four leaders' boons like a real run.
## - The gear offer order (owner decision on inbox 12: no change): the Armory offers its pieces in the order it always did - no
##   attack-first reshuffle.
## - The Capital after Primm: the freed preset keeps the inside's grade and is not blown out, the cloths over his face are the Paths'
##   colours, the celebration builds its crowd and one decor mesh, and Low-end halves the crowd.
## - The max hand size cap (owner decision), the mirror tell, the finale vignette's steps, the flat wash's colour range.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func after_each() -> void:
	Session.save_enabled = true


# ---- Primm's phases ---------------------------------------------------------------------------------------------------------------


func _in_the_castle() -> void:
	Session.begin_zone_visit(CapitalZone.ID)
	Session.dungeon_key = CapitalZone.ID
	Session.dungeon_map = MainDungeons.build_map(CapitalZone.ID)
	Session.run = DungeonRun.enter(Session.profile, Session.deck, Session.zone_run.run.dungeon_sources)
	Session.main_dungeon_active = true


func test_a_lost_castle_run_starts_primm_over_at_phase_one() -> void:
	_in_the_castle()
	Session.boss_phase = 2
	Session.boss_phase_pending = true
	Session.resolve_main_dungeon(false, true)
	assert_eq(Session.boss_phase, 0, "a loss in Phase 3 restarts at Phase 1 (owner: Primm's defeat flow stays as it is)")
	assert_false(Session.boss_phase_pending)
	assert_null(Session.run, "the run is over")


func test_the_phases_are_three_and_only_the_second_is_the_mirror() -> void:
	assert_eq(PrimmBoss.PHASES, 3)
	assert_false(PrimmBoss.phase(0).mirror)
	assert_true(PrimmBoss.phase(1).mirror, "Reflection copies the player's deck")
	assert_false(PrimmBoss.phase(2).mirror)


func test_the_four_leaders_boons_are_what_the_dev_checkpoint_grants() -> void:
	# `DevActions.travel_primm_phase` adds PrimmBoss.leader_boon for every key of LEADERS: all four must build, each with +2 max HP
	_in_the_castle()
	var before: int = Session.run.max_hp()
	var granted: int = 0
	for zone_id: String in PrimmBoss.LEADERS.keys():
		var boon: ModifierSource = PrimmBoss.leader_boon(zone_id)
		assert_not_null(boon, "%s's leader lends a boon" % zone_id)
		if boon != null:
			Session.run.add_dungeon_source(boon)
			granted += 1
	assert_eq(granted, 4)
	assert_eq(Session.run.max_hp(), before + 8, "four boons: +2 max HP each (23 -> 31 at the critic's level)")


# ---- The gear offer order ---------------------------------------------------------------------------------------------------------


func test_the_armory_offers_its_pieces_in_the_same_order() -> void:
	var stock: EquipmentVendorData = EquipmentVendorScreen.default_stock()
	var ids: Array[String] = []
	for entry: EquipmentVendorEntry in stock.entries:
		ids.append(entry.equipment_id)
	assert_eq(ids, [
		"wicked_dagger", "extra_pocket", "travelers_boots", "solid_plate", "xray_goggles", "cardboard_cuirass", "saucepan_helmet",
		"flamethrower", "earned_blade", "cheaters_dice", "hover_boots", "thorned_loincloth", "big_brain_beret",
	] as Array[String], "inbox 12, owner: no change - the offer order is not reshuffled toward attack pieces")


# ---- The Capital after Primm ------------------------------------------------------------------------------------------------------


func test_the_freed_preset_is_the_insides_grade_and_not_blown_out() -> void:
	var inside: ZonePreset = StylePresets.get_preset(StylePresets.CAPITAL_INSIDE)
	var freed: ZonePreset = StylePresets.get_preset(StylePresets.CAPITAL_FREED)
	assert_eq(freed.tonemap, inside.tonemap, "the freed city keeps the inside's tonemapper (it fell back to ACES and blew the white city out)")
	assert_eq(freed.tonemap, "agx")
	assert_lte(freed.exposure, inside.exposure, "no brighter than the inside")
	assert_gte(freed.shadow_opacity, 0.5, "a golden afternoon has real shadows")
	assert_lt(freed.sun_pitch, 0.0)
	assert_gt(freed.sun_pitch, inside.sun_pitch, "a lower sun (pitch nearer the horizon)")
	assert_gt(freed.sun_color.r, freed.sun_color.b, "a warm key")


func test_the_cloths_over_primms_face_are_the_paths_colours() -> void:
	var cloths: Array[String] = []
	cloths.assign(preload("res://world/capital/capital_kit.gd").FREED_CLOTHS)
	assert_eq(cloths.size(), 5, "five strips cover the emblem")
	assert_false(cloths.has("canvas_navy"), "not the one dark sheet that read as a hole in the palace")
	for wanted: String in ["canvas_red", "canvas_copper", "canvas_green", "canvas_teal"]:
		assert_true(cloths.has(wanted), "%s hangs there" % wanted)


func test_the_celebration_builds_one_decor_mesh_and_a_crowd() -> void:
	var scene: Node3D = Node3D.new()
	add_child_autofree(scene)
	var blockers: Array[Vector3] = []
	var crowd: Array[Node3D] = CapitalCelebration.build(scene, func(_p: Vector3) -> bool: return true, func(p: Vector3, _r: float) -> void: blockers.append(p), false)
	var root: Node = scene.get_node_or_null("Celebration")
	assert_not_null(root)
	var decor: MeshInstance3D = root.get_node_or_null("CelebrationDecor") as MeshInstance3D
	assert_not_null(decor, "bunting, posts and confetti are one mesh")
	assert_eq(decor.cast_shadow, GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	assert_gt(decor.mesh.surface_get_array_len(0), 1000, "eight fountain lines, five avenue lines and the confetti")
	var spots: int = 0
	for group: Dictionary in CapitalCelebration.CROWD_GROUPS:
		spots += (group["spots"] as Array).size()
	var has_sets: bool = false
	for character: String in CapitalCelebration.CROWD_SETS:
		has_sets = has_sets or SpriteLibrary.has_character(character)
	if has_sets:
		assert_eq(crowd.size(), spots, "every spot is taken when all of them are walkable")
		assert_eq(blockers.size(), crowd.size(), "each reveller is a small blocker")
	else:
		assert_eq(crowd.size(), 0, "no townsfolk sprite sets in this build: no crowd, no error")
	assert_gte(CapitalCelebration.CROWD_LINES.size(), 4, "the crowd has things to say")


func test_low_end_halves_the_crowd_and_drops_the_confetti() -> void:
	var full_scene: Node3D = Node3D.new()
	add_child_autofree(full_scene)
	var low_scene: Node3D = Node3D.new()
	add_child_autofree(low_scene)
	var always: Callable = func(_p: Vector3) -> bool: return true
	var nothing: Callable = func(_p: Vector3, _r: float) -> void: pass
	var full: Array[Node3D] = CapitalCelebration.build(full_scene, always, nothing, false)
	var low: Array[Node3D] = CapitalCelebration.build(low_scene, always, nothing, true)
	var full_decor: MeshInstance3D = full_scene.get_node("Celebration/CelebrationDecor") as MeshInstance3D
	var low_decor: MeshInstance3D = low_scene.get_node("Celebration/CelebrationDecor") as MeshInstance3D
	assert_lt(low_decor.mesh.surface_get_array_len(0), full_decor.mesh.surface_get_array_len(0), "no confetti on Low-end")
	if not full.is_empty():
		assert_lt(low.size(), full.size(), "fewer revellers on Low-end")


func test_nobody_stands_where_the_map_says_no() -> void:
	var scene: Node3D = Node3D.new()
	add_child_autofree(scene)
	var crowd: Array[Node3D] = CapitalCelebration.build(scene, func(_p: Vector3) -> bool: return false, func(_p: Vector3, _r: float) -> void: pass, false)
	assert_eq(crowd.size(), 0, "an unwalkable spot is skipped")


# ---- The other owner decisions and tells ------------------------------------------------------------------------------------------


func test_nothing_raises_the_max_hand_size_over_ten() -> void:
	assert_eq(GameState.MAX_HAND_CAP, 10)
	assert_eq(ProgressionTable.row(30).max_hand_size, 10, "levels 14 and 28 no longer add a card")
	var profile: PlayerProfile = PlayerProfile.new()
	var boost: ModifierSource = CardBuilder.modifier_source("Old Lanyard", ModifierSource.SourceKind.EQUIPMENT, [CardBuilder.modifier(Modifier.Kind.MAX_HAND_SIZE, 3)] as Array[Modifier])
	var game: GameState = GameState.new()
	game.options.rng_seed = 5
	game.add_player(PlayerSetup.create(GameFactory.make_deck(), profile, [boost] as Array[ModifierSource]))
	game.add_player(PlayerSetup.create(GameFactory.make_deck()))
	assert_eq(game.players[0].max_hand_size, 10, "+3 from an old save's gear still ends at ten")
	var squeeze: ModifierSource = CardBuilder.modifier_source("Bog", ModifierSource.SourceKind.ZONE, [CardBuilder.modifier(Modifier.Kind.MAX_HAND_SIZE, -3)] as Array[Modifier])
	var low: GameState = GameState.new()
	low.options.rng_seed = 5
	low.add_player(PlayerSetup.create(GameFactory.make_deck(), PlayerProfile.new(), [squeeze] as Array[ModifierSource]))
	low.add_player(PlayerSetup.create(GameFactory.make_deck()))
	assert_eq(low.players[0].max_hand_size, 7, "a rule may still lower it")


func test_no_piece_of_gear_still_promises_a_bigger_hand() -> void:
	for id: String in ["courier_lanyard", "quotas_stopwatch"]:
		var piece: EquipmentData = Session.content.equipment_piece(id)
		assert_not_null(piece, id)
		if piece == null:
			continue
		assert_false(piece.description.to_lower().contains("hand size"), "%s: %s" % [id, piece.description])
		for modifier: Modifier in piece.modifiers:
			assert_ne(modifier.kind, Modifier.Kind.MAX_HAND_SIZE, "%s no longer carries a max-hand modifier" % id)


func test_the_finale_vignette_deepens_and_each_phase_has_its_own() -> void:
	var early: Dictionary = BattleScreen.finale_values(-1, 0.0)
	var late: Dictionary = BattleScreen.finale_values(-1, 1.0)
	assert_gt(float(late["strength"]), float(early["strength"]), "the castle's rooms close in as they are cleared")
	var last: float = float(late["strength"])
	for phase: int in range(3):
		var values: Dictionary = BattleScreen.finale_values(phase, 1.0)
		assert_gt(float(values["strength"]), last, "phase %d is stronger than what came before" % (phase + 1))
		last = float(values["strength"])
	assert_gt(float(BattleScreen.finale_values(2, 1.0)["cracks"]), float(BattleScreen.finale_values(0, 1.0)["cracks"]), "the last phase cracks")
	var plain: BattleContext = BattleContext.new()
	plain.board_key = "town"
	assert_null(BattleScreen.finale_overlay(plain, null), "an ordinary fight has no finale vignette")
	var castle: BattleContext = BattleContext.new()
	castle.board_key = "boss:final"
	castle.boss_phase = 2
	var overlay: ColorRect = BattleScreen.finale_overlay(castle, null)
	assert_not_null(overlay)
	if overlay != null:
		assert_eq(overlay.mouse_filter, Control.MOUSE_FILTER_IGNORE, "never in the way of a click")
		overlay.free()


func test_a_flat_colour_is_never_pure_white_or_black() -> void:
	var white: Color = StyleToon.wash_colour(Color(1, 1, 1))
	assert_lt(white.b, 0.9, "white becomes cream stone")
	assert_gt(white.r, white.b)
	var black: Color = StyleToon.wash_colour(Color(0, 0, 0))
	assert_gt(black.v, 0.08, "black becomes a deep colour")
	var red: Color = Color(0.8, 0.2, 0.2)
	assert_eq(StyleToon.wash_colour(red), red, "a real colour is left alone")


func test_the_scene_fade_takes_the_zones_colour() -> void:
	ZoneStyles.use_area("gainlands")
	var fade: Color = SceneManager.fade_colour()
	assert_lt(fade.v, 0.12, "deep")
	assert_gt(fade.s, 0.2, "but a colour, not black")
	ZoneStyles.use_area("")
	assert_eq(SceneManager.fade_colour(), SceneManager.FADE_DEFAULT)


func test_a_reflected_card_wears_the_sheen() -> void:
	var data: CardData = GameFactory.vanilla(2, 2)
	var view: CardView = CardView.create(data, CardView.Mode.FULL)
	add_child_autofree(view)
	assert_null(view.get_node_or_null("MirrorFinish"), "an ordinary card is plain")
	view.show_as_mirror_copy()
	assert_not_null(view.get_node_or_null("MirrorFinish"), "Primm's copy shines silver")
	view.show_as_mirror_copy()
	var count: int = 0
	for child: Node in view.get_children():
		if child.name.begins_with("MirrorFinish"):
			count += 1
	assert_eq(count, 1, "only one sheen however often it is asked for")


# ---- Part 4.4: the RC5 late-game critic's small items -------------------------------------------------------------------------------


func test_the_setup_countdown_still_reads_in_full() -> void:
	# the line is set smaller in the turn panel (BattleHud._fit_turn_sub), never shortened
	assert_eq(BossTempo.countdown_text(2), "Setting Up: 2 turns left")
	assert_lt(BattleHud.TURN_SUB_SIZE_LONG, BattleHud.TURN_SUB_SIZE, "with the countdown the line is smaller, so the panel keeps its width")


func test_phase_three_hint_does_not_promise_a_timeout() -> void:
	var text: String = FileAccess.get_file_as_string("res://data/story/capital_story.tres")
	assert_false(text.contains("runs out of time"), "1 HP a turn from 50 HP is not a clock")
	assert_true(text.contains("every turn you hold the line wears him down"))


func test_the_funeral_fits_in_the_where_to_list() -> void:
	# quest givers come before exits and interactables in the list, so the entry is not cut by WHERE_TO_MAX
	var points: Array[MapPoi] = []
	for i: int in range(FullMapScreen.WHERE_TO_MAX + 4):
		points.append(MapPoi.make(MapPoi.Kind.INTERACTABLE, Vector3(i, 0, 0), "Thing %d" % i))
	points.append(MapPoi.make(MapPoi.Kind.QUEST_GIVER, Vector3.ZERO, "Old Hob at Grave Row (the city is gathering)"))
	var names: Array[String] = []
	for poi: MapPoi in FullMapScreen.where_to_places(points):
		names.append(poi.label)
	assert_has(names, "Old Hob at Grave Row (the city is gathering)")
