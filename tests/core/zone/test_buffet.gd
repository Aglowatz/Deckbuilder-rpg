extends GutTest
## Brief 7, Part B: the Endless Buffet - layout, traversal (pads, rafts, the lazy susan, soup falls, gates), def,
## enemies, content, story, interactables, the recipe puzzle and the Order Up! minigame.

const STEP: float = 0.6

var layout: BuffetLayout
var builder: BuffetBuilder
var def: ZoneDef
var story: ZoneStoryText


func before_all() -> void:
	builder = BuffetBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	layout = builder.layout
	def = ZoneDefs.get_def(BuffetZone.ID)
	story = ZoneStoryText.for_zone(BuffetZone.ID)


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.GOURMAND)
	Session.zone_run = ZoneRun.enter(BuffetZone.ID, Session.profile, Session.deck)
	builder._open_gates.clear()


func after_each() -> void:
	Session.zone_run = null
	Session.run = null
	Session.dungeon_map = null
	Session.mini_active = false


# ---- Layout -------------------------------------------------------------------------------------


func _land_area() -> float:
	var area: float = 0.0
	for x: int in range(0, 100):
		for z: int in range(0, 80):
			if BuffetLayout.edge_distance(float(x) + 0.5, float(z) + 0.5) >= 0.0:
				area += 1.0
	return area


func test_the_table_is_about_the_size_of_the_d_n_a() -> void:
	var dna: DnaLayout = DnaLayout.new()
	dna.build()
	var ratio: float = _land_area() / float(dna.floor_cell_count())
	assert_between(ratio, 0.8, 2.2, "the Endless Buffet is roughly the D.N.A.'s size (ratio %.2f)" % ratio)


func test_surface_rules() -> void:
	assert_eq(layout.surface_at(50.0, 64.0), BuffetLayout.Surface.GROUND, "the hub is ground")
	assert_eq(layout.surface_at(50.0, BuffetLayout.river_z(50.0)), BuffetLayout.Surface.SOUP, "the river is soup")
	assert_eq(layout.surface_at(1.0, 1.0), BuffetLayout.Surface.VOID, "outside the table is void")
	var butte: BuffetLayout.Mesa = layout.mesas[0]
	assert_eq(layout.surface_at(butte.center.x, butte.center.y), BuffetLayout.Surface.MESA)
	assert_eq(layout.surface_at(butte.center.x + butte.radius + 0.6, butte.center.y), BuffetLayout.Surface.CLIFF, "a mesa has a cliff wall you cannot walk up")
	assert_almost_eq(layout.ground_height(butte.center.x, butte.center.y), butte.height, 0.001)
	assert_lt(layout.ground_height(50.0, BuffetLayout.river_z(50.0)), BuffetLayout.SOUP_LEVEL, "the river bed is below the soup surface")


func test_there_are_mesas_pads_rafts_and_a_susan() -> void:
	assert_gte(layout.mesas.size(), 3, "pancake, cheese and butter mesas")
	assert_gte(layout.pads.size(), 6, "an up pad and a down pad for each mesa")
	assert_gte(layout.rafts.size(), 2, "crouton rafts")
	assert_gte(layout.susans.size(), 1, "a rotating lazy susan")
	var styles: Dictionary = {}
	for mesa: BuffetLayout.Mesa in layout.mesas:
		styles[mesa.style] = true
		assert_gt(mesa.height, 2.5, "%s is clearly raised" % mesa.id)
	assert_true(styles.has("pancake") and styles.has("cheese"), "pancake-stack and cheese mesas")


func test_every_anchor_chest_and_enemy_stands_on_real_ground() -> void:
	for name: String in layout.anchors.keys():
		var pos: Vector3 = layout.anchors[name] as Vector3
		var surface: BuffetLayout.Surface = layout.surface_at(pos.x, pos.z)
		assert_true(surface == BuffetLayout.Surface.GROUND or surface == BuffetLayout.Surface.MESA, "anchor %s is on ground or a mesa top" % name)
		assert_gt(BuffetLayout.edge_distance(pos.x, pos.z), 1.0, "anchor %s is clear of the table edge" % name)
	for id: String in layout.chests.keys():
		var chest: Vector3 = layout.chests[id] as Vector3
		var surface: BuffetLayout.Surface = layout.surface_at(chest.x, chest.z)
		assert_true(surface == BuffetLayout.Surface.GROUND or surface == BuffetLayout.Surface.MESA, "chest %s is on ground or a mesa top" % id)
	for spawn: Dictionary in layout.enemy_spawns:
		var home: Vector3 = spawn["home"] as Vector3
		assert_true(builder.is_enemy_walkable(home), "enemy home %s is on dry ground" % str(home))


func test_ground_is_hilly_and_flat_at_the_hub_and_the_banks() -> void:
	var lowest: float = 99.0
	var highest: float = -99.0
	for x: int in range(10, 90, 3):
		for z: int in range(52, 72, 3):
			var h: float = layout.ground_height(float(x), float(z))
			lowest = minf(lowest, h)
			highest = maxf(highest, h)
	assert_gt(highest - lowest, 1.0, "rolling hills in the south")
	assert_almost_eq(layout.ground_height(50.0, 64.0), layout.ground_height(48.0, 66.0), 0.15, "the hub is flat")
	var bank: Vector3 = layout.anchors["bank_center"] as Vector3
	assert_lt(absf(layout.ground_height(bank.x, bank.z)), 0.25, "the river banks are level with the rafts")


# ---- Reachability -------------------------------------------------------------------------------------


func _walkable_cell(x: float, z: float) -> bool:
	var surface: BuffetLayout.Surface = layout.surface_at(x, z)
	if surface != BuffetLayout.Surface.GROUND and surface != BuffetLayout.Surface.MESA:
		return false
	return builder.is_walkable(Vector3(x, 0.0, z))


func _key(cx: int, cz: int) -> int:
	return cz * 1000 + cx


## Cells (by key) reachable from the spawn on foot, plus the crossings: rafts and the susan (both ways) and the
## jelly pads (one way), as `links`.
func _reach(use_links: bool) -> Dictionary:
	var links: Dictionary = {}
	if use_links:
		for side: String in ["west", "center", "east"]:
			var bank: Vector3 = layout.anchors["bank_%s" % side] as Vector3
			var land: Vector3 = layout.anchors["land_%s" % side] as Vector3
			var a: int = _key(int(bank.x / STEP), int(bank.z / STEP))
			var b: int = _key(int(land.x / STEP), int(land.z / STEP))
			links[a] = [b]
			links[b] = [a]
		for pad: BuffetLayout.Pad in layout.pads:
			var from: int = _key(int(pad.pos.x / STEP), int(pad.pos.y / STEP))
			var dest: Vector3 = layout.anchors[pad.dest_anchor] as Vector3
			links[from] = [_key(int(dest.x / STEP), int(dest.z / STEP))]
	var spawn: Vector3 = layout.anchors["spawn"] as Vector3
	var start: Vector2i = Vector2i(int(spawn.x / STEP), int(spawn.z / STEP))
	var seen: Dictionary = {_key(start.x, start.y): true}
	var queue: Array[Vector2i] = [start]
	var head: int = 0
	while head < queue.size():
		var cell: Vector2i = queue[head]
		head += 1
		var neighbours: Array[Vector2i] = [cell + Vector2i(1, 0), cell + Vector2i(-1, 0), cell + Vector2i(0, 1), cell + Vector2i(0, -1)]
		var cell_key: int = _key(cell.x, cell.y)
		if links.has(cell_key):
			for target: int in (links[cell_key] as Array):
				neighbours.append(Vector2i(target % 1000, target / 1000))
		for next: Vector2i in neighbours:
			var next_key: int = _key(next.x, next.y)
			if seen.has(next_key):
				continue
			if next.x < 0 or next.y < 0 or next.x > 170 or next.y > 135:
				continue
			if not _walkable_cell((float(next.x) + 0.5) * STEP, (float(next.y) + 0.5) * STEP):
				continue
			seen[next_key] = true
			queue.append(next)
	return seen


func _reaches(seen: Dictionary, anchor: String) -> bool:
	var pos: Vector3 = layout.anchors[anchor] as Vector3
	# Anchors are the places props stand, so "reached" means: any reachable cell within 2 m.
	for dx: int in range(-5, 6):
		for dz: int in range(-5, 6):
			if Vector2(float(dx), float(dz)).length() * STEP > 2.6:
				continue
			if seen.has(_key(int(pos.x / STEP) + dx, int(pos.z / STEP) + dz)):
				return true
	return false


func _chest_reached(seen: Dictionary, id: String) -> bool:
	var pos: Vector3 = layout.chests[id] as Vector3
	# The hidden chest is reached when any walkable cell within the prompt radius is.
	for dx: int in range(-3, 4):
		for dz: int in range(-3, 4):
			var x: float = pos.x + float(dx) * 0.4
			var z: float = pos.z + float(dz) * 0.4
			if Vector2(x - pos.x, z - pos.z).length() > 1.4:
				continue
			if seen.has(_key(int(x / STEP), int(z / STEP))):
				return true
	return false


func test_the_south_is_reachable_on_foot_and_the_north_is_not() -> void:
	var seen: Dictionary = _reach(false)
	for anchor: String in ["hub", "odalys", "tarragon", "dolcetta", "heal", "oven", "soup_fountain", "fortune_cookie", "old_meatloaf", "quiz", "minigame", "taste_test", "pickup_saffron", "pickup_truffle", "pickup_basil", "pickup_sea_salt", "land_butte_down", "bank_west", "bank_center", "bank_east"]:
		assert_true(_reaches(seen, anchor), "%s is reachable from the spawn on foot" % anchor)
	for anchor: String in ["land_west", "land_center", "land_east", "mini_dungeon", "puzzle", "land_butte", "land_cheddar", "land_pancake", "pickup_hot_pepper", "pickup_honey"]:
		assert_false(_reaches(seen, anchor), "%s needs a raft, the susan or a jelly pad" % anchor)
	for id: String in ["chest_loaf", "chest_candy", "chest_salt"]:
		assert_true(_chest_reached(seen, id), "%s is on the dry south side" % id)
	for id: String in ["chest_butte", "chest_cheddar", "chest_pancake", "chest_cake", "chest_wheel"]:
		assert_false(_chest_reached(seen, id), "%s is across the river or up a mesa" % id)


func test_crossings_and_pads_reach_the_gravy_bank_and_the_mesas_but_gates_still_block_the_districts() -> void:
	var seen: Dictionary = _reach(true)
	for anchor: String in ["land_west", "land_center", "land_east", "pickup_hot_pepper", "land_butte", "pickup_honey"]:
		assert_true(_reaches(seen, anchor), "%s is reachable with the crossings and pads" % anchor)
	for anchor: String in ["mini_dungeon", "main_dungeon", "puzzle", "land_cheddar", "land_pancake", "land_cheddar_down", "land_pancake_down"]:
		assert_false(_reaches(seen, anchor), "%s is behind a golem gate while the gates are closed" % anchor)
	for id: String in ["chest_cake", "chest_wheel", "chest_cheddar", "chest_pancake"]:
		assert_false(_chest_reached(seen, id), "%s is behind a gate" % id)


func test_with_every_gate_open_the_whole_zone_is_reachable() -> void:
	for gate_id: String in ["ingredient", "quest", "battle"]:
		builder.open_gate(gate_id)
	var seen: Dictionary = _reach(true)
	for anchor: String in layout.anchors.keys():
		assert_true(_reaches(seen, str(anchor)), "%s is reachable with every gate open" % str(anchor))
	for id: String in layout.chests.keys():
		assert_true(_chest_reached(seen, id), "%s is reachable with every gate open" % id)


func test_each_gate_leads_to_its_own_district() -> void:
	builder.open_gate("quest")
	var seen: Dictionary = _reach(true)
	assert_true(_reaches(seen, "mini_dungeon"), "Sir Loin's gate opens Layer-Cake Town (the mini dungeon)")
	assert_false(_reaches(seen, "puzzle"), "...but not the Pancake Plateau")
	assert_true(_chest_reached(seen, "chest_cake"))
	assert_false(_chest_reached(seen, "chest_wheel"), "...nor the Cheddar Cliffs")
	builder.open_gate("battle")
	builder.open_gate("ingredient")
	seen = _reach(true)
	assert_true(_reaches(seen, "puzzle") and _reaches(seen, "land_cheddar_down"), "the other two gates open the other two districts")


func test_the_hidden_chests_are_at_least_six_and_nowhere_near_a_marked_spot() -> void:
	assert_gte(layout.chests.size(), 6)
	var spot_positions: Array[Vector3] = []
	for entry: Dictionary in def.spots:
		var anchor: Vector3 = layout.anchors.get(str(entry["anchor"]), Vector3.ZERO) as Vector3
		spot_positions.append(anchor + (entry["offset"] as Vector3))
	for id: String in layout.chests.keys():
		var chest: Vector3 = layout.chests[id] as Vector3
		for spot: Vector3 in spot_positions:
			assert_gt(Vector2(chest.x - spot.x, chest.z - spot.z).length(), 2.4, "%s is not inside any interact spot" % id)
	var on_mesa: int = 0
	for id: String in layout.chests.keys():
		var chest: Vector3 = layout.chests[id] as Vector3
		if layout.surface_at(chest.x, chest.z) == BuffetLayout.Surface.MESA:
			on_mesa += 1
	assert_gte(on_mesa, 3, "chests up on the mesas too")
	for id: String in def.chest_rewards.keys():
		assert_true(layout.chests.has(id), "every rewarded chest id exists in the layout: %s" % id)
	for id: String in layout.chests.keys():
		assert_true(def.chest_rewards.has(id), "every chest has a reward: %s" % id)


# ---- Traversal: pads, rafts, susan, soup ------------------------------------------------------------------


func test_every_pad_has_a_destination_that_does_not_retrigger_it() -> void:
	for pad: BuffetLayout.Pad in layout.pads:
		assert_true(layout.anchors.has(pad.dest_anchor), "%s has a destination anchor" % pad.id)
		var dest: Vector3 = layout.anchors[pad.dest_anchor] as Vector3
		var surface: BuffetLayout.Surface = layout.surface_at(pad.pos.x, pad.pos.y)
		assert_true(surface == BuffetLayout.Surface.GROUND or surface == BuffetLayout.Surface.MESA, "%s stands on solid ground" % pad.id)
		for other: BuffetLayout.Pad in layout.pads:
			assert_gt(Vector2(dest.x - other.pos.x, dest.z - other.pos.y).length(), other.radius + 0.5, "landing from %s does not trigger %s" % [pad.id, other.id])
	# Up pads go up, the others come back down.
	for pad: BuffetLayout.Pad in layout.pads:
		var dest: Vector3 = layout.anchors[pad.dest_anchor] as Vector3
		var up: bool = layout.ground_height(dest.x, dest.z) > layout.ground_height(pad.pos.x, pad.pos.y) + 2.0
		var down: bool = layout.ground_height(dest.x, dest.z) < layout.ground_height(pad.pos.x, pad.pos.y) - 2.0
		assert_true(up or down, "%s changes level by a mesa's height" % pad.id)


func test_rafts_dock_against_both_banks() -> void:
	for raft: BuffetLayout.Raft in layout.rafts:
		for end: Vector2 in [raft.a, raft.b]:
			var touches_land: bool = false
			for angle: int in range(0, 360, 20):
				var p: Vector2 = end + Vector2(cos(deg_to_rad(float(angle))), sin(deg_to_rad(float(angle)))) * (BuffetLayout.RAFT_RADIUS - 0.1)
				if layout.surface_at(p.x, p.y) == BuffetLayout.Surface.GROUND:
					touches_land = true
			assert_true(touches_land, "%s docks so a rider can step on from the bank (%s)" % [raft.id, str(end)])
		assert_eq(layout.surface_at(raft.a.x, raft.a.y), BuffetLayout.Surface.SOUP, "the raft's resting point is over the soup")


func test_rafts_wait_at_the_banks_and_cross_in_between() -> void:
	var raft: BuffetLayout.Raft = layout.rafts[0]
	assert_eq(layout.raft_position(raft, 0.0), raft.a, "docked at the south bank at the start")
	assert_eq(layout.raft_position(raft, BuffetLayout.RAFT_PAUSE * 0.5), raft.a, "waits")
	var mid: Vector2 = layout.raft_position(raft, BuffetLayout.RAFT_PAUSE + BuffetLayout.RAFT_MOVE * 0.5)
	assert_gt(mid.distance_to(raft.a), 1.0, "mid-crossing it is away from the dock")
	assert_lt(mid.distance_to(raft.a), raft.a.distance_to(raft.b))
	var other_end: Vector2 = layout.raft_position(raft, BuffetLayout.RAFT_PAUSE + BuffetLayout.RAFT_MOVE + 0.5)
	assert_eq(other_end, raft.b, "docked at the north bank after the crossing")
	var cycle: float = 2.0 * (BuffetLayout.RAFT_MOVE + BuffetLayout.RAFT_PAUSE)
	assert_almost_eq(layout.raft_position(raft, cycle).x, raft.a.x, 0.001, "it comes back")
	assert_ne(layout.rafts[0].offset, layout.rafts[1].offset, "the two ferries are not in sync")
	var speed: float = layout.raft_position(raft, BuffetLayout.RAFT_PAUSE + 2.6).distance_to(layout.raft_position(raft, BuffetLayout.RAFT_PAUSE + 2.5)) / 0.1
	assert_lt(speed, 3.4, "a raft is slower than the player, so you can always step on")


func test_the_lazy_susan_spans_the_river_and_has_a_pillar() -> void:
	var susan: BuffetLayout.Susan = layout.susans[0]
	var north_bank: bool = false
	var south_bank: bool = false
	for angle: int in range(0, 360, 10):
		var p: Vector2 = susan.center + Vector2(cos(deg_to_rad(float(angle))), sin(deg_to_rad(float(angle)))) * (susan.radius - 0.1)
		if layout.surface_at(p.x, p.y) == BuffetLayout.Surface.GROUND:
			if p.y < susan.center.y:
				north_bank = true
			else:
				south_bank = true
	assert_true(north_bank and south_bank, "the platter touches both banks")
	assert_not_null(layout.susan_under(susan.center.x + 2.5, susan.center.y), "you can stand on it")
	assert_null(layout.susan_under(susan.center.x, susan.center.y), "...but not on its pillar")
	assert_false(builder.is_walkable(Vector3(susan.center.x, 0.0, susan.center.y)), "the pillar blocks the middle")
	assert_gt(BuffetLayout.SUSAN_OMEGA, 0.2, "it visibly turns")


func test_a_rider_is_safe_on_a_platform_and_falls_without_one() -> void:
	var raft: BuffetLayout.Raft = layout.rafts[0]
	builder.time = 0.0
	var on: Vector3 = Vector3(raft.a.x, 0.0, raft.a.y)
	assert_false(builder.is_in_soup(on), "standing on the docked raft is safe")
	assert_almost_eq(builder.height_at(on), 0.0, 0.001, "...at bank level")
	builder.time = BuffetLayout.RAFT_PAUSE + BuffetLayout.RAFT_MOVE * 0.5
	assert_true(builder.is_in_soup(on), "the same spot is soup once the raft has left")
	var susan: BuffetLayout.Susan = layout.susans[0]
	assert_false(builder.is_in_soup(Vector3(susan.center.x + 2.0, 0.0, susan.center.y)), "the susan carries you")
	var open_soup: Vector3 = Vector3(40.0, 0.0, BuffetLayout.river_z(40.0))
	assert_true(builder.is_in_soup(open_soup), "open soup swallows you")


func test_enemies_never_enter_the_soup_or_climb_cliffs() -> void:
	assert_false(builder.is_enemy_walkable(Vector3(40.0, 0.0, BuffetLayout.river_z(40.0))))
	var butte: BuffetLayout.Mesa = layout.mesas[0]
	assert_false(builder.is_enemy_walkable(Vector3(butte.center.x + butte.radius + 0.8, 0.0, butte.center.y)), "no walking up a cliff")
	assert_true(builder.is_walkable(Vector3(40.0, 0.0, BuffetLayout.river_z(40.0) + 2.0)), "the player may wade in (and fall)")


func test_falling_into_the_soup_costs_one_hp_and_is_logged() -> void:
	var run: ZoneRun = Session.zone_run
	var before: int = run.hp
	var log_before: int = Session.zone_log.size()
	var result: Dictionary = BuffetInteractables.apply_soup_fall(run, "The Gravy River", story.text("fx.soup_fall_log"))
	assert_eq(run.hp, before - BuffetZone.SOUP_DAMAGE)
	assert_eq(int(result["damage"]), 1)
	assert_eq(BuffetZone.SOUP_DAMAGE, 1)
	assert_eq(Session.zone_log.size(), log_before + 1)
	assert_true(Session.zone_log[Session.zone_log.size() - 1].contains("The Gravy River"))
	run.hp = 1
	assert_true(BuffetInteractables.apply_soup_fall(run, "x", "%s")["down"], "the last HP means waking at the hub")


# ---- Gates --------------------------------------------------------------------------------------------


func test_three_gates_one_of_each_kind() -> void:
	var kinds: Array[String] = []
	for gate: BuffetGates.Gate in BuffetGates.gates():
		kinds.append(gate.kind)
		assert_true(layout.anchors.has(gate.anchor), "%s has an anchor" % gate.id)
		assert_true(layout.gate_positions.has(gate.id), "%s has a guardian position" % gate.id)
	kinds.sort()
	assert_eq(kinds, ["battle", "ingredient", "quest"] as Array[String])


func test_the_ingredient_gate_needs_saffron_and_uses_it_up() -> void:
	var gate: BuffetGates.Gate = BuffetGates.find("ingredient")
	assert_false(BuffetGates.requirement_met(gate, Session.unlock_state()), "no saffron, no entry")
	assert_true(BuffetInteractables.pick_up(Session.zone_run, "saffron"))
	assert_true(BuffetGates.requirement_met(gate, Session.unlock_state()), "with saffron in the bag")
	assert_false(BuffetInteractables.gate_is_open(gate))
	BuffetInteractables.open_gate(gate)
	assert_true(BuffetInteractables.gate_is_open(gate), "the gate stays open for good")
	assert_eq(BuffetInteractables.stock("saffron"), 0, "the saffron was handed over")


func test_the_quest_gate_needs_the_mend_quest_completed() -> void:
	var gate: BuffetGates.Gate = BuffetGates.find("quest")
	assert_false(BuffetGates.requirement_met(gate, Session.unlock_state()))
	Session.completed_quests.append(BuffetZone.QUEST_MEND)
	assert_true(BuffetGates.requirement_met(gate, Session.unlock_state()), "completing Mend the Meatloaf opens Sir Loin's gate")


func test_the_battle_gate_is_opened_only_by_a_fight() -> void:
	var gate: BuffetGates.Gate = BuffetGates.find("battle")
	assert_false(BuffetGates.requirement_met(gate, Session.unlock_state()), "talking never opens it")
	assert_eq(BuffetGates.INSTANCE_BATTLE, "gate_casserole")
	var info: ZoneEnemyInfo = ZoneEnemies.info(BuffetZone.ID, BuffetGates.ENEMY_CASSEROLE)
	assert_eq(info.kind, ZoneEnemyInfo.Kind.BATTLE)
	var context: BattleContext = Session.make_zone_battle(BuffetGates.ENEMY_CASSEROLE, BuffetGates.INSTANCE_BATTLE)
	assert_true(context.zone_battle)
	assert_eq(context.zone_enemy_id, BuffetGates.INSTANCE_BATTLE)
	context.won = true
	context.gold_reward = 10
	Session.resolve_zone_battle(context)
	assert_true(Session.zone_run.is_defeated(BuffetGates.INSTANCE_BATTLE), "winning marks the gate's golem as beaten")


func test_gate_blockers_leave_no_gap_and_open_gates_let_you_through() -> void:
	for gate: BuffetGates.Gate in BuffetGates.gates():
		var pos: Vector3 = layout.gate_positions[gate.id] as Vector3
		for dx: int in range(-4, 5):
			assert_false(builder.is_walkable(Vector3(pos.x + float(dx) * 0.6, 0.0, pos.z)), "no squeezing past the %s golem (offset %d)" % [gate.id, dx])
		builder.open_gate(gate.id)
		assert_true(builder.is_walkable(Vector3(pos.x, 0.0, pos.z)), "the %s gate is passable once open" % gate.id)
		assert_false(builder.is_walkable(Vector3(pos.x + 4.0, 0.0, pos.z)), "the fence either side still stands")


# ---- Def, hub, quests ---------------------------------------------------------------------------------------


func test_the_zone_is_registered_and_named() -> void:
	assert_true(ZoneDefs.has_def(BuffetZone.ID))
	assert_eq(BuffetZone.ID, "gourmand")
	assert_eq(def.display_name, "The Endless Buffet")
	assert_eq(def.scene_path, "res://scenes/buffet_zone.tscn")
	assert_true(ResourceLoader.exists(def.scene_path))
	assert_true(ResourceLoader.exists(def.story_path))
	assert_eq(ZonePortals.find("gourmand").display_name, "Path of the Gourmand")


func test_hub_has_a_heal_spot_a_vendor_chefs_and_quests() -> void:
	var kinds: Dictionary = {}
	for entry: Dictionary in def.spots:
		kinds[str(entry["kind"])] = true
		assert_true(layout.anchors.has(str(entry["anchor"])), "spot %s has an anchor" % str(entry["id"]))
	for kind: String in ["heal", "vendor_npc", "quest_npc", "exit", "mini_dungeon", "main_dungeon", "puzzle", "quiz", "minigame"]:
		assert_true(kinds.has(kind), "a %s spot exists" % kind)
	assert_between(def.quest_npc_names.size(), 2, 3, "2-3 NPC chefs give quests")
	assert_between(def.vendor_ids.size(), 8, 10, "the vendor sells 8-10 cards")
	for id: String in def.vendor_ids:
		var card: CardData = Session.content.card(id)
		assert_not_null(card, "vendor card %s exists" % id)
		assert_eq(card.color, Affinity.Type.GOURMAND, "%s is a Gourmand card" % id)
	for quest_id: String in [BuffetZone.QUEST_PANTRY, BuffetZone.QUEST_PIE, BuffetZone.QUEST_MEND]:
		assert_not_null(QuestCatalog.find(quest_id), "quest %s exists" % quest_id)
	for name: String in def.quest_npc_names:
		var gives: bool = false
		for quest_id: String in [BuffetZone.QUEST_PANTRY, BuffetZone.QUEST_PIE, BuffetZone.QUEST_MEND]:
			if QuestCatalog.find(quest_id).giver_npc == name:
				gives = true
		assert_true(gives, "%s gives a quest" % name)


func test_main_dungeon_signs_name_the_test_kitchen() -> void:
	assert_true(story.text("fx.main_dungeon").contains("Test Kitchen"))
	assert_true(story.text("sign.main_dungeon").contains("TEST KITCHEN"))
	assert_true(def.spot_def("main_dungeon")["kind"] == "main_dungeon")


func test_zone_hp_rules_use_the_dish_duty_fee() -> void:
	assert_eq(def.fee, 20)
	assert_eq(def.fee_label, "Dish duty fee")
	var run: ZoneRun = Session.zone_run
	run.damage(run.max_hp())
	var gold_before: int = Session.gold
	var fee: int = Session.zone_wake_at_hub("beat up by a meatloaf")
	assert_eq(fee, mini(20, gold_before))
	assert_eq(run.hp, run.max_hp(), "waking at the hub restores full HP")
	assert_true(Session.zone_log[Session.zone_log.size() - 1].begins_with("Dish duty fee"))


func test_three_enemy_designs_two_slow_battle_starters_and_a_fast_damage_dealer() -> void:
	assert_eq(BuffetEnemies.IDS.size(), 3)
	var slow_battle: int = 0
	var fast_damage: int = 0
	for id: String in BuffetEnemies.IDS:
		var info: ZoneEnemyInfo = BuffetEnemies.info(id)
		if info.kind == ZoneEnemyInfo.Kind.BATTLE:
			assert_lt(info.chase_speed, ZoneEnemies.PLAYER_SPEED, "%s is slower than the player" % id)
			assert_false(info.recipe.is_empty(), "%s has a Gourmand deck" % id)
			assert_true(info.recipe.has("BAS-G"), "%s plays Gourmand infrastructure" % id)
			slow_battle += 1
		else:
			assert_gt(info.chase_speed, ZoneEnemies.PLAYER_SPEED, "%s is faster than the player" % id)
			assert_eq(info.damage, 2, "%s deals 2 damage on touch" % id)
			fast_damage += 1
		assert_true(story.lines.has("enemy.%s" % id), "enemy flavour text for %s" % id)
	assert_eq(slow_battle, 2)
	assert_eq(fast_damage, 1)
	var types: Dictionary = {}
	for spawn: Dictionary in layout.enemy_spawns:
		types[str(spawn["type"])] = true
	assert_eq(types.size(), 3, "all three designs roam the zone")


func test_a_buffet_battle_uses_the_zone_hp_and_the_gourmand_deck() -> void:
	Session.zone_run.hp = 4
	var context: BattleContext = Session.make_zone_battle(BuffetEnemies.LOAF, "loaf_0")
	assert_true(context.zone_battle)
	assert_eq(context.game.players[0].hp, 4, "the duel starts at the zone's persistent HP")
	var deck: Deck = BuffetEnemies.deck(Session.content, BuffetEnemies.LOAF)
	assert_gt(deck.cards.size(), 20)
	var enemy_cards: Dictionary = {}
	for card: CardData in deck.cards:
		enemy_cards[card.id] = true
	assert_true(enemy_cards.has("G-02"), "the Meatloaf Golem plays Gourmand food golems")
	context.won = true
	context.gold_reward = 5
	Session.resolve_zone_battle(context)
	assert_eq(int(Session.counters.get(BuffetZone.COUNTER_ENEMIES, 0)), 1, "beating one bumps the zone's counter")


func test_buffet_cards_equipment_and_items_exist() -> void:
	for id: String in ZoneCards.BUFFET_VENDOR_IDS + ["G-21", "G-29", "G-27"]:
		assert_not_null(Session.content.card(id), "card %s exists" % id)
		assert_eq(Session.content.card(id).color, Affinity.Type.GOURMAND)
	var ladle: EquipmentData = Session.content.equipment_piece("head_chef_ladle")
	assert_not_null(ladle)
	assert_eq(ladle.slot, EquipmentData.Slot.WEAPON)
	assert_not_null(Session.content.item(BuffetZone.PIE_ITEM_ID), "the Hearty Pot Pie item exists")


func test_mini_dungeon_is_three_battles_and_a_one_time_unique_gourmand_card() -> void:
	assert_eq(def.mini.battles.size(), 3)
	assert_eq(def.mini.reward_card_id, "G-27")
	var map: DungeonMap = MiniDungeon.build_map(BuffetZone.ID)
	var battles: int = 0
	for node: DungeonMap.MapNode in map.nodes:
		if node.kind == DungeonMap.Kind.BATTLE or node.kind == DungeonMap.Kind.BOSS:
			battles += 1
			var deck: Deck = ZoneDecks.from_recipe(Session.content, node.enemy_name, MiniDungeon.enemy_recipe(node.enemy_name, BuffetZone.ID))
			assert_gt(deck.cards.size(), 20, "%s has a deck" % node.enemy_name)
	assert_eq(battles, 3)
	assert_eq(Session.owned_count("G-27"), 0)
	Session.resolve_mini_dungeon(true)
	assert_eq(Session.owned_count("G-27"), 1, "the first clear grants the unique card")
	Session.resolve_mini_dungeon(true)
	assert_eq(Session.owned_count("G-27"), 1, "...once")


# ---- Story ----------------------------------------------------------------------------------------------


func test_every_sign_npc_gate_and_quest_text_exists_in_the_story_file() -> void:
	var missing: Array[String] = []
	var keys: Array[String] = []
	for sign: BuffetLayout.Sign in layout.signs:
		keys.append(sign.key)
	for id: String in ["odalys", "tarragon", "dolcetta", "quiz", "minigame"]:
		keys.append("npc.%s.intro" % id)
		keys.append("npc.%s.return" % id)
	for gate: BuffetGates.Gate in BuffetGates.gates():
		keys.append(gate.key("open"))
		if gate.kind == "battle":
			keys.append(gate.key("intro"))
			keys.append(gate.key("ask"))
		else:
			keys.append(gate.key("pass"))
			keys.append(gate.key("need"))
	for quest_id: String in [BuffetZone.QUEST_PANTRY, BuffetZone.QUEST_PIE, BuffetZone.QUEST_MEND]:
		for part: String in ["offer", "active", "ready", "done"]:
			keys.append("quest.%s.%s" % [quest_id, part])
	for key: String in ["hud.objective", "ui.mini.body", "ui.mini.body_cleared", "ui.mini.button", "ui.exit.title", "ui.exit.body", "fx.main_dungeon", "fx.heal_couch", "fx.heal_already", "fx.hit", "fx.wake", "fx.chest", "fx.bounce", "fx.landed", "fx.soup_fall", "fx.soup_fall_log", "fx.gate_open", "fx.pickup", "fx.pickup_again", "fx.oven_done", "fx.oven_missing", "fx.taste_good", "fx.taste_great", "fx.taste_buff", "fx.taste_tip", "fx.taste_spicy", "fx.taste_bland", "fx.taste_broke", "fx.fountain_1", "fx.fountain_2", "fx.fountain_3", "fx.fountain_full", "fx.fountain_limit", "fx.cookie_broke", "fx.cookie_crack", "fortune.hints", "fx.mend_done", "prop.arch", "prop.dispenser", "prop.broken_golem", "prop.stage", "prop.freezer", "prop.kitchen", "prop.stew", "npc.old_meatloaf.broken", "npc.old_meatloaf.fix", "npc.old_meatloaf.mended", "quiz.result.0", "quiz.result.4", "quiz.repeat", "quiz.not_passed", "order.intro", "order.stations", "order.dishes", "order.shouts", "order.win", "order.lose", "order.first", "recipe.intro", "recipe.ingredients", "recipe.hint", "recipe.solved", "recipe.already", "recipe.incomplete", "recipe.wrong"]:
		keys.append(key)
	for index: int in range(RecipePuzzle.clues().size()):
		keys.append("recipe.clue.%d" % (index + 1))
	for key: String in keys:
		if not story.lines.has(key):
			missing.append(key)
	assert_eq(missing, [] as Array[String], "all text lives in the story file")


func test_the_quiz_has_four_questions_about_the_gourmands_with_findable_answers() -> void:
	assert_eq(story.quiz_questions.size(), 4)
	var needles: Array[String] = ["feed the kingdom", "food golems", "Yes, Chef", "Nobody leaves hungry"]
	for index: int in range(4):
		var question: Dictionary = story.quiz_questions[index] as Dictionary
		assert_eq((question["a"] as Array).size(), 4)
		assert_between(int(question["correct"]), 0, 3)
		var found: bool = false
		for key: Variant in story.lines.keys():
			var text: String = " ".join(story.get_lines(str(key)))
			if str(key).begins_with("sign.") and text.to_lower().contains(needles[index].to_lower()):
				found = true
		assert_true(found, "the answer to question %d ('%s') is written on a sign" % [index + 1, needles[index]])
	assert_true(story.text("sign.golem_oath").contains("feed the kingdom") or story.text("sign.golem_oath").contains("We feed the kingdom"))


# ---- Interactables --------------------------------------------------------------------------------------


func test_taste_test_outcomes_have_real_effects() -> void:
	var run: ZoneRun = Session.zone_run
	run.hp = 3
	assert_eq(BuffetInteractables.taste_outcome(0.1), "good")
	assert_eq(BuffetInteractables.taste_outcome(0.3), "great")
	assert_eq(BuffetInteractables.taste_outcome(0.5), "buff")
	assert_eq(BuffetInteractables.taste_outcome(0.6), "tip")
	assert_eq(BuffetInteractables.taste_outcome(0.75), "spicy")
	assert_eq(BuffetInteractables.taste_outcome(0.95), "bland")
	BuffetInteractables.apply_taste(run, "good")
	assert_eq(run.hp, 6, "good heals 3")
	BuffetInteractables.apply_taste(run, "great")
	assert_eq(run.hp, run.max_hp(), "great heals up to full")
	var max_before: int = run.max_hp()
	BuffetInteractables.apply_taste(run, "buff")
	assert_eq(run.max_hp(), max_before + 1, "the buff raises max HP for the visit")
	var gold_before: int = Session.gold
	BuffetInteractables.apply_taste(run, "tip")
	assert_eq(Session.gold, gold_before + BuffetInteractables.TASTE_TIP)
	var hp_before: int = run.hp
	BuffetInteractables.apply_taste(run, "spicy")
	assert_eq(run.hp, hp_before - 1, "spicy costs 1 HP")
	run.hp = 1
	BuffetInteractables.apply_taste(run, "spicy")
	assert_eq(run.hp, 1, "never below 1")
	BuffetInteractables.apply_taste(run, "bland")
	assert_eq(run.hp, 1, "bland does nothing")


func test_pickups_are_once_per_visit_and_the_oven_bakes_a_pie_from_them() -> void:
	var run: ZoneRun = Session.zone_run
	assert_false(BuffetInteractables.can_bake())
	for id: String in BuffetZone.OVEN_RECIPE:
		assert_true(BuffetInteractables.pick_up(run, id))
		assert_false(BuffetInteractables.pick_up(run, id), "only once per visit: %s" % id)
	assert_eq(int(Session.counters.get(BuffetZone.COUNTER_GATHERED, 0)), 3)
	assert_true(BuffetInteractables.can_bake())
	assert_true(BuffetInteractables.bake())
	assert_eq(BuffetInteractables.stock("honey"), 0, "baking uses the ingredients up")
	assert_eq(int(Session.counters.get(BuffetZone.COUNTER_BAKED, 0)), 1)
	assert_gt(Session.profile.item_uses_remaining.get(BuffetZone.PIE_ITEM_ID, 0), 0, "a Hearty Pot Pie is in the bag")
	assert_false(BuffetInteractables.bake(), "no more ingredients, no more pie")
	var next_visit: ZoneRun = ZoneRun.enter(BuffetZone.ID, Session.profile, Session.deck)
	assert_true(BuffetInteractables.pick_up(next_visit, "honey"), "the pantry restocks on the next visit")


func test_soup_fountain_heals_up_to_three_times_per_visit() -> void:
	var run: ZoneRun = Session.zone_run
	run.hp = 1
	for number: int in range(1, 4):
		var result: Dictionary = BuffetInteractables.ladle(run)
		assert_true(bool(result["ok"]))
		assert_eq(int(result["number"]), number)
		assert_eq(int(result["healed"]), BuffetInteractables.FOUNTAIN_HEAL)
	assert_false(BuffetInteractables.can_ladle(run))
	assert_false(bool(BuffetInteractables.ladle(run)["ok"]))


func test_fortune_cookies_cycle_through_secret_hints() -> void:
	var hints: Array[String] = story.get_lines("fortune.hints")
	assert_gte(hints.size(), 6, "enough hints for the secrets")
	assert_eq(BuffetInteractables.fortune_index(0, hints.size()), 0)
	assert_eq(BuffetInteractables.fortune_index(hints.size(), hints.size()), 0, "the hints cycle")
	assert_eq(BuffetInteractables.fortune_index(3, hints.size()), 3)


func test_old_meatloaf_is_mended_with_sea_salt_and_a_truffle() -> void:
	var run: ZoneRun = Session.zone_run
	assert_false(BuffetInteractables.can_mend())
	BuffetInteractables.pick_up(run, "sea_salt")
	assert_false(BuffetInteractables.can_mend(), "salt alone is not enough")
	BuffetInteractables.pick_up(run, "truffle")
	assert_true(BuffetInteractables.mend())
	assert_true(Session.flag(BuffetZone.FLAG_MENDED))
	assert_false(BuffetInteractables.can_mend(), "he only needs mending once")
	assert_eq(BuffetInteractables.stock("sea_salt"), 0)


func test_quest_objectives_follow_the_zone_actions() -> void:
	var pantry: QuestData = QuestCatalog.find(BuffetZone.QUEST_PANTRY)
	assert_true(Session.start_quest(BuffetZone.QUEST_PANTRY))
	var run: ZoneRun = Session.zone_run
	for id: String in ["saffron", "truffle", "sea_salt"]:
		BuffetInteractables.pick_up(run, id)
	assert_true(Session.quest_log.objectives_met_count(pantry, Session.unlock_state()) >= 1, "gathering three ingredients completes Pantry Run")
	var mend: QuestData = QuestCatalog.find(BuffetZone.QUEST_MEND)
	assert_true(Session.start_quest(BuffetZone.QUEST_MEND))
	assert_eq(Session.quest_log.objectives_met_count(mend, Session.unlock_state()), 0)
	BuffetInteractables.mend()
	assert_eq(Session.quest_log.objectives_met_count(mend, Session.unlock_state()), 1, "mending Old Meatloaf completes his quest")


# ---- The recipe puzzle -------------------------------------------------------------------------------------


func test_the_recipe_puzzle_has_exactly_one_solution() -> void:
	var solutions: Array[Array] = RecipePuzzle.solutions()
	assert_eq(solutions.size(), 1, "exactly one of the 360 stews satisfies every clue")
	assert_eq(solutions[0], RecipePuzzle.SOLUTION as Array)
	assert_true(RecipePuzzle.is_solved(RecipePuzzle.SOLUTION))
	assert_eq(RecipePuzzle.clues().size(), 7)


func test_no_single_clue_is_enough_and_wrong_stews_never_solve() -> void:
	var clues: Array[RecipePuzzle.Clue] = RecipePuzzle.clues()
	# Dropping any clue must leave more than one possibility (so every clue matters), except the redundant last.
	var needed: int = 0
	for skip: int in range(clues.size()):
		var count: int = 0
		for a: int in range(6):
			for b: int in range(6):
				for c: int in range(6):
					for d: int in range(6):
						var order: Array[int] = [a, b, c, d]
						if not RecipePuzzle.is_complete(order):
							continue
						var ok: bool = true
						for index: int in range(clues.size()):
							if index != skip and not RecipePuzzle.satisfies(order, clues[index]):
								ok = false
								break
						if ok:
							count += 1
		if count > 1:
			needed += 1
	assert_gte(needed, 5, "most clues are load-bearing (%d of 7)" % needed)
	assert_false(RecipePuzzle.is_solved([RecipePuzzle.ONION, RecipePuzzle.MUSHROOM, RecipePuzzle.PAPRIKA, RecipePuzzle.LEEK]))
	assert_false(RecipePuzzle.is_solved([RecipePuzzle.ONION, RecipePuzzle.ONION, RecipePuzzle.LEEK, RecipePuzzle.PAPRIKA]), "no duplicates")
	assert_false(RecipePuzzle.is_solved([RecipePuzzle.ONION, RecipePuzzle.MUSHROOM, RecipePuzzle.LEEK]), "needs four")
	assert_eq(RecipePuzzle.SLOTS * 90, 360, "a 360-stew search space")


func test_the_recipe_puzzle_gives_the_ladle_through_the_def() -> void:
	assert_eq(def.puzzle_kind, "recipe")
	var ladle: EquipmentData = Session.content.equipment_piece(def.puzzle_equipment_id)
	assert_not_null(ladle)
	assert_true(Session.grant_equipment(ladle))
	assert_false(Session.grant_equipment(ladle), "one time only")


# ---- Order Up! ------------------------------------------------------------------------------------------------------


func test_a_flawless_shift_is_18_points_and_three_stars() -> void:
	var game: OrderGame = OrderGame.play_perfect(0.4)
	assert_true(game.is_finished())
	assert_eq(game.points(), OrderGame.max_points())
	assert_eq(game.stars(), 3)
	assert_eq(game.mistakes, 0)


func test_never_cooking_is_six_timeouts_and_no_stars() -> void:
	var game: OrderGame = OrderGame.new()
	game.start(0.0)
	var time: float = 0.0
	while not game.is_finished() and time < 400.0:
		time += 0.25
		game.advance(time)
	assert_true(game.is_finished())
	assert_eq(game.points(), 0)
	assert_eq(game.stars(), 0)


func test_a_wrong_ingredient_tosses_the_plate_and_costs_time() -> void:
	var game: OrderGame = OrderGame.new()
	game.start(0.0)
	var recipe: Array = game.recipe()
	var left_before: float = game.time_left(1.0)
	assert_eq(game.press(int(recipe[0]), 1.0), OrderGame.Result.ADDED)
	var wrong: int = OrderGame.PATTY if int(recipe[1]) != OrderGame.PATTY else OrderGame.CHEESE
	assert_eq(game.press(wrong, 1.5), OrderGame.Result.WRONG)
	assert_eq(game.plate.size(), 0, "the stack restarts")
	assert_eq(game.mistakes, 1)
	assert_almost_eq(game.time_left(1.5), left_before - 0.5 - OrderGame.PENALTY, 0.001, "and costs time")


func test_faster_service_scores_more_and_the_gap_ignores_presses() -> void:
	var fast: OrderGame = OrderGame.new()
	fast.start(0.0)
	var slow: OrderGame = OrderGame.new()
	slow.start(0.0)
	var recipe: Array = fast.recipe()
	for index: int in range(recipe.size()):
		fast.press(int(recipe[index]), 0.5 + 0.2 * float(index))
		slow.press(int(recipe[index]), 6.0 + 0.5 * float(index))
	assert_eq(fast.points_per_ticket[0], 3)
	assert_lt(slow.points_per_ticket[0], 3)
	assert_true(fast.in_gap(1.0), "a short pause between tickets")
	assert_eq(fast.press(OrderGame.BUN, 1.0), OrderGame.Result.IGNORED)


func test_star_thresholds_and_rewards() -> void:
	assert_eq(OrderGame.stars_for(3), 0)
	assert_eq(OrderGame.stars_for(4), 1)
	assert_eq(OrderGame.stars_for(9), 2)
	assert_eq(OrderGame.stars_for(14), 3)
	var gold_before: int = Session.gold
	var first: Dictionary = OrderGame.apply_result(3)
	assert_true(bool(first["first_win"]))
	assert_gt(int(first["gold"]), 100, "the first clear pays big plus the one-time bonus")
	assert_eq(Session.gold, gold_before + int(first["gold"]))
	assert_true(Session.flag(BuffetZone.FLAG_ORDER_FIRST))
	var again: Dictionary = OrderGame.apply_result(3)
	assert_false(bool(again["first_win"]))
	assert_lt(int(again["gold"]), int(first["gold"]), "later shifts pay little")
	assert_eq(int(OrderGame.apply_result(0)["gold"]), 0, "a failed shift pays nothing")


func test_the_minigame_is_a_different_type_from_the_memory_and_timing_games() -> void:
	assert_eq(def.minigame_kind, "order")
	assert_ne(def.minigame_kind, ZoneDefs.get_def(DnaZone.ID).minigame_kind)
	assert_ne(def.minigame_kind, ZoneDefs.get_def(GainlandsZone.ID).minigame_kind)
	assert_eq(OrderGame.TICKET_COUNT, OrderGame.TICKETS.size())
	for dish: Array in OrderGame.DISHES:
		assert_gte(dish.size(), 3)
		for station: int in dish:
			assert_between(station, 0, OrderGame.STATION_COUNT - 1)


func test_every_spot_can_be_stood_at_and_reached_from_the_spawn_side() -> void:
	for gate_id: String in ["ingredient", "quest", "battle"]:
		builder.open_gate(gate_id)
	var seen: Dictionary = _reach(true)
	for entry: Dictionary in def.spots:
		var anchor: Vector3 = layout.anchors[str(entry["anchor"])] as Vector3
		var center: Vector3 = anchor + (entry["offset"] as Vector3)
		var radius: float = float(entry["radius"])
		var found: bool = false
		for angle: int in range(0, 360, 15):
			for fraction: float in [0.0, 0.5, 0.85]:
				var p: Vector3 = center + Vector3(cos(deg_to_rad(float(angle))), 0.0, sin(deg_to_rad(float(angle)))) * radius * fraction
				if seen.has(_key(int(p.x / STEP), int(p.z / STEP))):
					found = true
		assert_true(found, "a player can reach spot %s" % str(entry["id"]))
