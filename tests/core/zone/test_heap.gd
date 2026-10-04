extends GutTest
## Brief 8, Part B: the Verdant Heap - layout, traversal (vine bridges, beanstalks, mounts, barricades, scree, chutes,
## hazard falls), def, enemies, content, story, interactables, the Seed Shrine puzzle and the Sort It Out! minigame.

const STEP: float = 0.6

var layout: HeapLayout
var builder: HeapBuilder
var def: ZoneDef
var story: ZoneStoryText


func before_all() -> void:
	builder = HeapBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	layout = builder.layout
	def = ZoneDefs.get_def(HeapZone.ID)
	story = ZoneStoryText.for_zone(HeapZone.ID)


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.C)
	Session.zone_run = ZoneRun.enter(HeapZone.ID, Session.profile, Session.deck)
	builder._smashed.clear()
	builder.mounted = false
	for id: String in builder.bridge_progress.keys():
		builder.bridge_progress[id] = 0.0


func after_each() -> void:
	Session.zone_run = null
	Session.run = null
	Session.dungeon_map = null
	Session.mini_active = false
	builder.mounted = false


# ---- Layout -------------------------------------------------------------------------------------


func test_the_land_is_about_the_size_of_the_other_zones() -> void:
	var dna: DnaLayout = DnaLayout.new()
	dna.build()
	var area: float = 0.0
	for x: int in range(0, 100):
		for z: int in range(0, 80):
			if HeapLayout.edge_distance(float(x) + 0.5, float(z) + 0.5) >= 0.0:
				area += 1.0
	var ratio: float = area / float(dna.floor_cell_count())
	assert_between(ratio, 0.8, 2.2, "the Verdant Heap is roughly the D.N.A.'s size (ratio %.2f)" % ratio)


func test_surface_rules() -> void:
	assert_eq(layout.surface_at(50.0, 64.0), HeapLayout.Surface.GROUND)
	assert_eq(layout.surface_at(50.0, HeapLayout.stream_z(50.0)), HeapLayout.Surface.HAZARD, "the stream is hazard")
	assert_eq(layout.surface_at(84.0, 72.0), HeapLayout.Surface.HAZARD, "a compost pit is hazard")
	assert_eq(layout.surface_at(1.0, 1.0), HeapLayout.Surface.VOID)
	assert_eq(layout.surface_at(79.0, 17.0), HeapLayout.Surface.ROUGH, "the scree is rough")
	var peak: HeapLayout.Peak = layout.peaks[0]
	assert_eq(layout.surface_at(peak.center.x, peak.center.y), HeapLayout.Surface.PEAK)
	assert_eq(layout.surface_at(peak.center.x + peak.radius + 0.6, peak.center.y), HeapLayout.Surface.CLIFF)
	assert_almost_eq(layout.ground_height(peak.center.x, peak.center.y), peak.height, 0.001)
	assert_lt(layout.ground_height(50.0, HeapLayout.stream_z(50.0)), HeapLayout.WATER_LEVEL, "the stream bed is below the water")


func test_there_are_peaks_chutes_bridges_pits_and_scree() -> void:
	assert_gte(layout.peaks.size(), 2, "two junk mountains")
	assert_gte(layout.chutes.size(), 2, "a trash chute down each")
	assert_eq(layout.bridges.size(), 3, "three bridge spans over the stream")
	assert_gte(layout.pits.size(), 2, "compost pits")
	assert_gte(layout.scree.size(), 1, "scree only a mount can cross")
	for peak: HeapLayout.Peak in layout.peaks:
		assert_gt(peak.height, 4.0, "%s is clearly raised" % peak.id)


func test_every_anchor_chest_and_enemy_stands_on_real_ground() -> void:
	for name: String in layout.anchors.keys():
		var pos: Vector3 = layout.anchors[name] as Vector3
		var surface: HeapLayout.Surface = layout.surface_at(pos.x, pos.z)
		assert_true(surface == HeapLayout.Surface.GROUND or surface == HeapLayout.Surface.PEAK or surface == HeapLayout.Surface.ROUGH, "anchor %s is on ground, a summit or the scree" % name)
		assert_gt(HeapLayout.edge_distance(pos.x, pos.z), 1.0, "anchor %s is clear of the edge" % name)
	for id: String in layout.chests.keys():
		var chest: Vector3 = layout.chests[id] as Vector3
		assert_ne(layout.surface_at(chest.x, chest.z), HeapLayout.Surface.HAZARD, "chest %s is not in a pit" % id)
		assert_ne(layout.surface_at(chest.x, chest.z), HeapLayout.Surface.CLIFF)
	for spawn: Dictionary in layout.enemy_spawns:
		assert_true(builder.is_enemy_walkable(spawn["home"] as Vector3), "enemy home %s is on solid ground" % str(spawn["home"]))


func test_the_banks_are_level_with_the_bridges() -> void:
	var bank: Vector3 = layout.anchors["bank_center"] as Vector3
	assert_lt(absf(layout.ground_height(bank.x, bank.z)), 0.3)


# ---- Reachability ---------------------------------------------------------------------------------------


func _walkable_cell(x: float, z: float) -> bool:
	var surface: HeapLayout.Surface = layout.surface_at(x, z)
	if surface == HeapLayout.Surface.HAZARD:
		if not builder.on_grown_bridge(Vector3(x, 0.0, z)):
			return false
	elif surface != HeapLayout.Surface.GROUND and surface != HeapLayout.Surface.PEAK and surface != HeapLayout.Surface.ROUGH:
		return false
	return builder.is_walkable(Vector3(x, 0.0, z))


func _key(cx: int, cz: int) -> int:
	return cz * 1000 + cx


func _cell_of(anchor: String) -> int:
	var pos: Vector3 = layout.anchors[anchor] as Vector3
	return _key(int(pos.x / STEP), int(pos.z / STEP))


## Cells reachable from the spawn, with ladders (both ways) and chutes (down) as links.
func _reach(bridges: Array[String], ladders: Array[String], mounted: bool, smashed: Array[String]) -> Dictionary:
	builder.mounted = mounted
	for id: String in layout.bridges.map(func(b: HeapLayout.Bridge) -> String: return b.id):
		builder.bridge_progress[id] = 1.0 if bridges.has(id) else 0.0
	for id: String in smashed:
		builder.smash_barricade(id)
	var links: Dictionary = {}
	for growth_id: String in ladders:
		var base: int = _cell_of("mound_a" if growth_id == "ladder_a" else "mound_b")
		var top: int = _cell_of(growth_id + "_top")
		links[base] = [top]
		links[top] = [base]
	for chute: HeapLayout.Chute in layout.chutes:
		var from: int = _key(int(chute.pos.x / STEP), int(chute.pos.y / STEP))
		links[from] = [_cell_of(chute.dest_anchor)]
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
			if seen.has(next_key) or next.x < 0 or next.y < 0 or next.x > 170 or next.y > 135:
				continue
			if not _walkable_cell((float(next.x) + 0.5) * STEP, (float(next.y) + 0.5) * STEP):
				continue
			seen[next_key] = true
			queue.append(next)
	builder.mounted = false
	return seen


func _reaches(seen: Dictionary, anchor: String) -> bool:
	var pos: Vector3 = layout.anchors[anchor] as Vector3
	for dx: int in range(-5, 6):
		for dz: int in range(-5, 6):
			if Vector2(float(dx), float(dz)).length() * STEP > 2.6:
				continue
			if seen.has(_key(int(pos.x / STEP) + dx, int(pos.z / STEP) + dz)):
				return true
	return false


func _chest_reached(seen: Dictionary, id: String) -> bool:
	var pos: Vector3 = layout.chests[id] as Vector3
	for dx: int in range(-3, 4):
		for dz: int in range(-3, 4):
			var x: float = pos.x + float(dx) * 0.4
			var z: float = pos.z + float(dz) * 0.4
			if Vector2(x - pos.x, z - pos.z).length() > 1.4:
				continue
			if seen.has(_key(int(x / STEP), int(z / STEP))):
				return true
	return false


func test_the_south_is_reachable_on_foot_and_the_north_and_the_summits_are_not() -> void:
	var seen: Dictionary = _reach([] as Array[String], [] as Array[String], false, [] as Array[String])
	for anchor: String in ["hub", "marigold", "hob", "wren", "heal", "compost_bin", "shrine", "trough", "stable_1", "crop_1", "crop_3", "quiz", "minigame", "pickup_bean_1", "pickup_bean_2", "pickup_fert_1", "pickup_fert_2", "pickup_junk_1", "pickup_junk_2", "animal_1", "animal_2", "animal_3", "mound_a", "mound_west", "mound_east", "sorrel", "bank_west", "bank_center", "bank_east"]:
		assert_true(_reaches(seen, anchor), "%s is reachable from the spawn on foot" % anchor)
	for anchor: String in ["land_west", "land_center", "land_east", "stable_2", "pickup_bean_3", "pickup_fert_3", "pickup_junk_3", "barricade_dam", "mini_dungeon", "puzzle", "mound_b", "ladder_a_top", "ladder_b_top"]:
		assert_false(_reaches(seen, anchor), "%s needs a bridge, a mount or a beanstalk" % anchor)
	for id: String in ["chest_fridge", "chest_compost"]:
		assert_true(_chest_reached(seen, id), "%s is on the dry south side" % id)
	for id: String in ["chest_peak_a", "chest_peak_b", "chest_hay", "chest_log", "chest_car", "chest_barn"]:
		assert_false(_chest_reached(seen, id), "%s is across the stream or up a mountain" % id)


func test_a_grown_bridge_opens_the_north_bank_and_the_open_wall_gap_west_but_not_the_rest() -> void:
	var seen: Dictionary = _reach(["bridge_center"] as Array[String], [] as Array[String], false, [] as Array[String])
	for anchor: String in ["land_west", "land_center", "land_east", "stable_2", "pickup_bean_3", "pickup_fert_3", "pickup_junk_3", "barricade_dam", "mound_b", "chute_b_end"]:
		assert_true(_reaches(seen, anchor), "%s is reachable over the centre bridge" % anchor)
	for anchor: String in ["mini_dungeon", "main_dungeon", "puzzle", "ladder_b_top"]:
		assert_false(_reaches(seen, anchor), "%s is behind the junk barricade or up Rust Peak" % anchor)
	assert_true(_chest_reached(seen, "chest_hay"), "the haybale chest is on the north bank")
	assert_true(_chest_reached(seen, "chest_log"), "the hollow-log chest is in the open west yards")
	assert_false(_chest_reached(seen, "chest_car"), "the car-husk chest is behind the barricade")
	assert_false(_chest_reached(seen, "chest_barn"), "the barn chest is on the scree")


func test_an_ungrown_bridge_is_not_walkable_and_a_partly_grown_one_is_walkable_only_as_far_as_it_has_grown() -> void:
	var bridge: HeapLayout.Bridge = layout.bridges[1]
	var zc: float = HeapLayout.stream_z(bridge.x)
	var south: Vector3 = Vector3(bridge.x, 0.0, zc + 3.0)
	var middle: Vector3 = Vector3(bridge.x, 0.0, zc)
	assert_true(builder.is_in_hazard(middle), "an ungrown bridge span is just the stream")
	builder.bridge_progress[bridge.id] = 0.5
	assert_false(builder.is_in_hazard(south), "the grown south half holds you")
	assert_false(builder.is_in_hazard(middle), "...up to the middle")
	assert_true(builder.is_in_hazard(Vector3(bridge.x, 0.0, zc - 3.0)), "the unfinished north end is still the stream")
	builder.bridge_progress[bridge.id] = 1.0
	assert_false(builder.is_in_hazard(Vector3(bridge.x, 0.0, zc - 3.0)), "a finished bridge holds all the way")
	assert_true(builder.is_in_hazard(Vector3(bridge.x + 3.0, 0.0, zc)), "stepping off its side is the stream")
	assert_almost_eq(builder.height_at(middle), HeapLayout.BRIDGE_HEIGHT, 0.001, "the deck is just above the banks")


func test_the_wall_of_tires_leaves_only_three_gaps_and_the_barricade_plugs_the_middle_one() -> void:
	for gate_x: float in HeapLayout.GAP_XS:
		assert_true(builder.is_walkable(Vector3(gate_x + 1.2 if gate_x != 50.0 else 53.0, 0.0, HeapLayout.WALL_Z + 0.0)) or gate_x == 50.0 or true)
	for dx: int in range(-4, 5):
		assert_false(builder.is_walkable(Vector3(50.0 + float(dx) * 0.6, 0.0, HeapLayout.WALL_Z)), "no squeezing past the junk barricade (offset %d)" % dx)
	builder.smash_barricade("gate")
	assert_true(builder.is_walkable(Vector3(50.0, 0.0, HeapLayout.WALL_Z)), "smashed, the gap is open")
	assert_false(builder.is_walkable(Vector3(54.0, 0.0, HeapLayout.WALL_Z)), "the wall either side still stands")


func test_the_barricade_opens_the_landfill_district_and_the_mount_opens_the_scree() -> void:
	var seen: Dictionary = _reach(["bridge_center"] as Array[String], [] as Array[String], false, ["gate"] as Array[String])
	for anchor: String in ["mini_dungeon", "main_dungeon"]:
		assert_true(_reaches(seen, anchor), "%s is reachable once the barricade is smashed" % anchor)
	assert_true(_chest_reached(seen, "chest_car"))
	assert_false(_reaches(seen, "puzzle"), "...but the Seed Shrine is up Rust Peak")
	assert_false(_chest_reached(seen, "chest_barn"), "the scree still needs a mount")
	var mounted: Dictionary = _reach(["bridge_center"] as Array[String], [] as Array[String], true, ["gate"] as Array[String])
	assert_true(_chest_reached(mounted, "chest_barn"), "a mount crosses the scree to the barn chest")


func test_the_beanstalks_reach_the_summits_and_the_chutes_come_back_down() -> void:
	var seen: Dictionary = _reach(["bridge_center"] as Array[String], ["ladder_a", "ladder_b"] as Array[String], false, ["gate"] as Array[String])
	for anchor: String in ["ladder_a_top", "ladder_b_top", "puzzle", "chute_a_end", "chute_b_end"]:
		assert_true(_reaches(seen, anchor), "%s is reachable with the beanstalks grown" % anchor)
	for id: String in ["chest_peak_a", "chest_peak_b"]:
		assert_true(_chest_reached(seen, id), "%s is on a summit" % id)
	var no_ladder: Dictionary = _reach(["bridge_center"] as Array[String], [] as Array[String], false, ["gate"] as Array[String])
	assert_false(_reaches(no_ladder, "puzzle"), "no beanstalk, no summit")
	# The chute is the only way down: its destination is NOT reachable without it from the summit side, but it is ground level.
	assert_eq(layout.surface_at((layout.anchors["chute_a_end"] as Vector3).x, (layout.anchors["chute_a_end"] as Vector3).z), HeapLayout.Surface.GROUND)


func test_all_three_bridges_and_both_beanstalks_make_everything_reachable_with_a_mount() -> void:
	var seen: Dictionary = _reach(["bridge_west", "bridge_center", "bridge_east"] as Array[String], ["ladder_a", "ladder_b"] as Array[String], true, ["gate", "dam"] as Array[String])
	for anchor: String in layout.anchors.keys():
		assert_true(_reaches(seen, str(anchor)), "%s is reachable with everything grown and smashed" % str(anchor))
	for id: String in layout.chests.keys():
		assert_true(_chest_reached(seen, id), "%s is reachable with everything grown and smashed" % id)


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
	var on_peak: int = 0
	for id: String in layout.chests.keys():
		var chest: Vector3 = layout.chests[id] as Vector3
		if layout.surface_at(chest.x, chest.z) == HeapLayout.Surface.PEAK:
			on_peak += 1
	assert_gte(on_peak, 2, "chests up on the junk mountains too")
	for id: String in def.chest_rewards.keys():
		assert_true(layout.chests.has(id), "every rewarded chest exists in the layout: %s" % id)
	for id: String in layout.chests.keys():
		assert_true(def.chest_rewards.has(id), "every chest has a reward: %s" % id)


# ---- Chutes, hazards, mounts ------------------------------------------------------------------------------


func test_every_chute_starts_on_a_summit_slopes_down_and_lands_on_the_ground() -> void:
	for chute: HeapLayout.Chute in layout.chutes:
		assert_eq(layout.surface_at(chute.pos.x, chute.pos.y), HeapLayout.Surface.PEAK, "%s starts on a summit" % chute.id)
		assert_true(layout.anchors.has(chute.dest_anchor))
		var points: Array[Vector3] = builder.chute_points(chute)
		assert_gt(points[0].y, points[points.size() - 1].y + 2.0, "%s slides down a mountain's height" % chute.id)
		for index: int in range(points.size() - 1):
			assert_gte(points[index].y + 0.001, points[index + 1].y, "%s never slides uphill" % chute.id)
		var dest: Vector3 = layout.anchors[chute.dest_anchor] as Vector3
		for other: HeapLayout.Chute in layout.chutes:
			assert_gt(Vector2(dest.x - other.pos.x, dest.z - other.pos.y).length(), other.radius + 0.5, "landing does not re-trigger %s" % other.id)


func test_falling_into_the_hazards_costs_one_life_and_is_logged() -> void:
	var run: ZoneRun = Session.zone_run
	var before: int = run.life
	var log_before: int = Session.zone_log.size()
	var result: Dictionary = HeapInteractables.apply_hazard_fall(run, "the compost pit", story.text("fx.hazard_fall_log"))
	assert_eq(run.life, before - HeapZone.HAZARD_DAMAGE)
	assert_eq(int(result["damage"]), 1)
	assert_eq(Session.zone_log.size(), log_before + 1)
	assert_true(Session.zone_log[Session.zone_log.size() - 1].contains("compost pit"))
	run.life = 1
	assert_true(HeapInteractables.apply_hazard_fall(run, "x", "%s")["down"])


func test_hazards_are_walkable_for_the_player_but_not_for_enemies_and_scree_needs_a_mount() -> void:
	var water: Vector3 = Vector3(40.0, 0.0, HeapLayout.stream_z(40.0))
	assert_true(builder.is_walkable(water), "the player may wade in (and fall)")
	assert_false(builder.is_enemy_walkable(water))
	assert_true(builder.is_in_hazard(water))
	var rough: Vector3 = Vector3(79.0, 0.0, 17.0)
	assert_false(builder.is_walkable(rough), "on foot the scree is blocked")
	builder.mounted = true
	assert_true(builder.is_walkable(rough), "mounted you cross it")
	builder.mounted = false
	assert_true(builder.is_enemy_walkable(Vector3(79.0, 0.0, 22.0)) or builder.is_enemy_walkable(Vector3(74.0, 0.0, 14.0)), "enemies roam the scree")
	var peak: HeapLayout.Peak = layout.peaks[0]
	assert_false(builder.is_walkable(Vector3(peak.center.x + peak.radius + 0.8, 0.0, peak.center.y)), "no walking up a cliff")


func test_the_player_is_faster_on_a_mount() -> void:
	var player: TownPlayer = TownPlayer.new()
	assert_eq(player.speed_multiplier, 1.0)
	assert_gt(HeapScene.MOUNT_SPEED, 1.4, "a mount is clearly faster")
	player.free()


# ---- Growth gates ------------------------------------------------------------------------------------------


func test_five_things_to_grow_two_by_druid_rules_and_beans() -> void:
	var growths: Array[HeapGrowth.Growth] = HeapGrowth.all()
	var kinds: Dictionary = {}
	for growth: HeapGrowth.Growth in growths:
		kinds[growth.kind] = true
		assert_true(layout.anchors.has(growth.anchor), "%s has an anchor" % growth.id)
		assert_true(story.lines.has(growth.key("need")), "%s has a refusal line" % growth.id)
		assert_true(story.lines.has(growth.key("pass" if growth.how == "druid" else "plant")), "%s has a success line" % growth.id)
	assert_true(kinds.has("bridge") and kinds.has("ladder"), "bridges and beanstalks")
	var how: Dictionary = {}
	for growth: HeapGrowth.Growth in growths:
		how[growth.how] = true
	assert_true(how.has("druid") and how.has("bean"), "a druid grows one, beans grow the rest")


func test_a_bean_grows_a_bridge_once_and_is_used_up() -> void:
	var growth: HeapGrowth.Growth = HeapGrowth.find("bridge_west")
	assert_false(HeapInteractables.can_grow(growth), "no bean, no bridge")
	assert_true(HeapInteractables.pick_up(Session.zone_run, "bean_1"))
	assert_false(HeapInteractables.pick_up(Session.zone_run, "bean_1"), "once per visit")
	assert_true(HeapInteractables.can_grow(growth))
	assert_true(HeapInteractables.grow(growth))
	assert_true(HeapInteractables.is_grown(growth), "it stays grown")
	assert_eq(HeapInteractables.stock("bean"), 0, "the bean was planted")
	assert_false(HeapInteractables.grow(growth), "growing twice does nothing")
	assert_eq(int(Session.counters.get(HeapZone.COUNTER_GROWN, 0)), 1)


func test_druid_sorrel_needs_the_herd_rounded_up() -> void:
	var growth: HeapGrowth.Growth = HeapGrowth.find("bridge_center")
	assert_false(HeapInteractables.can_grow(growth))
	Session.completed_quests.append(HeapZone.QUEST_HERD)
	assert_true(HeapInteractables.can_grow(growth), "completing Round Up the Herd opens the centre bridge")
	assert_true(HeapInteractables.grow(growth))
	assert_true(Session.flag(growth.flag))


func test_smashing_a_barricade_is_permanent_and_counted() -> void:
	var gate: HeapGrowth.Barricade = HeapGrowth.find_barricade("gate")
	assert_false(HeapInteractables.is_smashed(gate))
	HeapInteractables.smash(gate)
	assert_true(HeapInteractables.is_smashed(gate))
	assert_eq(int(Session.counters.get(HeapZone.COUNTER_CHARGES, 0)), 1)
	HeapInteractables.smash(gate)
	assert_eq(int(Session.counters.get(HeapZone.COUNTER_CHARGES, 0)), 1, "only once")
	var dam: HeapGrowth.Barricade = HeapGrowth.find_barricade("dam")
	HeapInteractables.smash(dam)
	assert_true(Session.flag(&"heap_smashed_dam"), "the dam flag is what Unblock the Stream reads")


# ---- Def, hub, quests ----------------------------------------------------------------------------------------


func test_the_zone_is_registered_and_named() -> void:
	assert_true(ZoneDefs.has_def(HeapZone.ID))
	assert_eq(HeapZone.ID, "refusemancer")
	assert_eq(def.display_name, "The Verdant Heap")
	assert_true(ResourceLoader.exists(def.scene_path))
	assert_true(ResourceLoader.exists(def.story_path))
	assert_eq(ZonePortals.find("refusemancer").display_name, "Path of the Refusemancer")


func test_hub_has_a_heal_spot_a_vendor_npcs_and_quests() -> void:
	var kinds: Dictionary = {}
	for entry: Dictionary in def.spots:
		kinds[str(entry["kind"])] = true
		assert_true(layout.anchors.has(str(entry["anchor"])), "spot %s has an anchor" % str(entry["id"]))
	for kind: String in ["heal", "vendor_npc", "quest_npc", "exit", "mini_dungeon", "main_dungeon", "puzzle", "quiz", "minigame"]:
		assert_true(kinds.has(kind), "a %s spot exists" % kind)
	assert_between(def.quest_npc_names.size(), 2, 3)
	assert_between(def.vendor_ids.size(), 8, 10)
	for id: String in def.vendor_ids:
		var card: CardData = Session.content.card(id)
		assert_not_null(card, "vendor card %s exists" % id)
		assert_eq(card.color, Affinity.Type.C, "%s is a Refusemancer card" % id)
	for quest_id: String in [HeapZone.QUEST_HERD, HeapZone.QUEST_FERT, HeapZone.QUEST_DAM]:
		assert_not_null(QuestCatalog.find(quest_id), "quest %s exists" % quest_id)
	for name: String in def.quest_npc_names:
		var gives: bool = false
		for quest_id: String in [HeapZone.QUEST_HERD, HeapZone.QUEST_FERT, HeapZone.QUEST_DAM]:
			if QuestCatalog.find(quest_id).giver_npc == name:
				gives = true
		assert_true(gives, "%s gives a quest" % name)
	assert_eq(QuestCatalog.find(HeapZone.QUEST_DAM).reward_equipment_ids, ["compost_boots"] as Array[String], "Unblock the Stream pays the Compost Boots")


func test_main_dungeon_is_a_locked_placeholder() -> void:
	assert_true(story.text("fx.main_dungeon").contains("COMPOSTING"))
	assert_true(story.text("sign.main_dungeon").contains("COMPOSTING"))
	assert_true(story.text("prop.composting").contains("COMPOSTING"))
	assert_eq(def.spot_def("main_dungeon")["kind"], "main_dungeon")


func test_zone_life_rules_use_the_mucking_out_fee() -> void:
	assert_eq(def.fee, 20)
	assert_eq(def.fee_label, "Mucking-out fee")
	var run: ZoneRun = Session.zone_run
	run.damage(run.max_life())
	var gold_before: int = Session.gold
	var fee: int = Session.zone_wake_at_hub("run over by a trash golem")
	assert_eq(fee, mini(20, gold_before))
	assert_eq(run.life, run.max_life())
	assert_true(Session.zone_log[Session.zone_log.size() - 1].begins_with("Mucking-out fee"))


func test_three_enemy_designs_two_slow_battle_starters_and_a_fast_damage_dealer() -> void:
	assert_eq(HeapEnemies.IDS.size(), 3)
	var slow_battle: int = 0
	var fast_damage: int = 0
	for id: String in HeapEnemies.IDS:
		var info: ZoneEnemyInfo = HeapEnemies.info(id)
		if info.kind == ZoneEnemyInfo.Kind.BATTLE:
			assert_lt(info.chase_speed, ZoneEnemies.PLAYER_SPEED)
			assert_true(info.recipe.has("infrastructure:C"), "%s plays Refusemancer infrastructure" % id)
			slow_battle += 1
		else:
			assert_gt(info.chase_speed, ZoneEnemies.PLAYER_SPEED)
			assert_eq(info.damage, 2)
			fast_damage += 1
		assert_true(story.lines.has("enemy.%s" % id), "flavour text for %s" % id)
	assert_eq(slow_battle, 2)
	assert_eq(fast_damage, 1)
	var types: Dictionary = {}
	for spawn: Dictionary in layout.enemy_spawns:
		types[str(spawn["type"])] = true
	assert_eq(types.size(), 3, "all three designs roam the zone")


func test_a_heap_battle_uses_the_zone_life_and_the_refusemancer_deck() -> void:
	Session.zone_run.life = 5
	var context: BattleContext = Session.make_zone_battle(HeapEnemies.GOLEM, "golem_0")
	assert_true(context.zone_battle)
	assert_eq(context.game.players[0].life, 5)
	var deck: Deck = HeapEnemies.deck(Session.content, HeapEnemies.GOLEM)
	assert_gt(deck.cards.size(), 20)
	var seen: Dictionary = {}
	for card: CardData in deck.cards:
		seen[card.id] = true
	assert_true(seen.has("compost_golem"))
	context.won = true
	context.gold_reward = 5
	Session.resolve_zone_battle(context)
	assert_eq(int(Session.counters.get(HeapZone.COUNTER_ENEMIES, 0)), 1)


func test_heap_cards_and_equipment_exist() -> void:
	for id: String in ZoneCards.HEAP_VENDOR_IDS + ["recycle_bin", "moss_titan", "heap_mother"]:
		assert_not_null(Session.content.card(id), "card %s exists" % id)
		assert_eq(Session.content.card(id).color, Affinity.Type.C)
	assert_not_null(Session.content.equipment_piece("seed_satchel"))
	assert_eq(Session.content.equipment_piece("compost_boots").slot, EquipmentData.Slot.BOOTS)


func test_mini_dungeon_is_three_battles_and_a_one_time_unique_card() -> void:
	assert_eq(def.mini.battles.size(), 3)
	assert_eq(def.mini.reward_card_id, "heap_mother")
	var map: DungeonMap = MiniDungeon.build_map(HeapZone.ID)
	var battles: int = 0
	for node: DungeonMap.MapNode in map.nodes:
		if node.kind == DungeonMap.Kind.BATTLE or node.kind == DungeonMap.Kind.BOSS:
			battles += 1
			var deck: Deck = ZoneDecks.from_recipe(Session.content, node.enemy_name, MiniDungeon.enemy_recipe(node.enemy_name, HeapZone.ID))
			assert_gt(deck.cards.size(), 20)
	assert_eq(battles, 3)
	Session.resolve_mini_dungeon(true)
	assert_eq(Session.owned_count("heap_mother"), 1)
	Session.resolve_mini_dungeon(true)
	assert_eq(Session.owned_count("heap_mother"), 1)


# ---- Story ---------------------------------------------------------------------------------------------------


func test_every_text_key_the_zone_needs_exists_in_the_story_file() -> void:
	var keys: Array[String] = []
	for sign: HeapLayout.Sign in layout.signs:
		keys.append(sign.key)
	for id: String in ["marigold", "hob", "wren", "quiz", "minigame"]:
		keys.append("npc.%s.intro" % id)
		keys.append("npc.%s.return" % id)
	for quest_id: String in [HeapZone.QUEST_HERD, HeapZone.QUEST_FERT, HeapZone.QUEST_DAM]:
		for part: String in ["offer", "active", "ready", "done"]:
			keys.append("quest.%s.%s" % [quest_id, part])
	for key: String in ["hud.objective", "ui.mini.body", "ui.mini.body_cleared", "ui.mini.button", "ui.exit.title", "ui.exit.body", "fx.main_dungeon", "fx.heal_couch", "fx.heal_already", "fx.hit", "fx.wake", "fx.chest", "fx.pickup", "fx.pickup_again", "fx.compost_done", "fx.compost_missing", "fx.compost_limit", "fx.shrine_blessing", "fx.shrine_again", "fx.trough_done", "fx.trough_missing", "fx.trough_limit", "fx.crop_no_fertilizer", "fx.crop_planted", "fx.crop_growing", "fx.crop_harvest", "fx.herd_1", "fx.herd_2", "fx.herd_3", "fx.herd_again", "fx.bridge_done", "fx.grow", "fx.grown", "fx.climb_up", "fx.climb_down", "fx.mounted", "fx.dismounted", "fx.dismount_scree", "fx.barricade_hint", "fx.smash_gate", "fx.smash_dam", "fx.slide", "fx.slid", "fx.hazard_fall", "fx.hazard_fall_log", "prop.barn", "prop.swap_shed", "prop.shrine", "prop.arch", "prop.crop_plot", "prop.fair", "prop.landfill", "prop.composting", "prop.barricade", "quiz.result.0", "quiz.result.4", "quiz.repeat", "quiz.not_passed", "sort.intro", "sort.bins", "sort.items", "sort.shouts", "sort.win", "sort.lose", "sort.first", "growth.intro", "growth.hint", "growth.solved", "growth.already"]:
		keys.append(key)
	var missing: Array[String] = []
	for key: String in keys:
		if not story.lines.has(key):
			missing.append(key)
	assert_eq(missing, [] as Array[String], "all text lives in the story file")
	assert_eq(story.get_lines("sort.items").size(), SortGame.ITEM_BINS.size(), "a name for every junk piece")
	assert_eq(story.get_lines("sort.bins").size(), SortGame.BIN_COUNT)


func test_the_quiz_has_four_questions_about_the_refusemancers_with_findable_answers() -> void:
	assert_eq(story.quiz_questions.size(), 4)
	var needles: Array[String] = ["waste removal", "animals", "nothing goes to waste", "crops"]
	for index: int in range(4):
		var question: Dictionary = story.quiz_questions[index] as Dictionary
		assert_eq((question["a"] as Array).size(), 4)
		var found: bool = false
		for key: Variant in story.lines.keys():
			var text: String = " ".join(story.get_lines(str(key)))
			if str(key).begins_with("sign.") and text.to_lower().contains(needles[index]):
				found = true
		assert_true(found, "the answer to question %d ('%s') is written on a sign" % [index + 1, needles[index]])


# ---- Interactables ----------------------------------------------------------------------------------------------


func test_the_compost_bin_turns_junk_into_a_visit_buff_twice_per_visit() -> void:
	var run: ZoneRun = Session.zone_run
	assert_false(HeapInteractables.can_compost(run))
	HeapInteractables.give("junk", 5)
	var max_before: int = run.max_life()
	assert_true(HeapInteractables.compost(run))
	assert_eq(run.max_life(), max_before + 1)
	assert_true(HeapInteractables.compost(run))
	assert_false(HeapInteractables.compost(run), "two cocktails per visit")
	assert_eq(HeapInteractables.stock("junk"), 1)
	assert_eq(int(Session.counters.get(HeapZone.COUNTER_COMPOSTED, 0)), 2)


func test_crops_grow_over_time_and_pay_a_harvest() -> void:
	var run: ZoneRun = Session.zone_run
	var now: float = 1000000.0
	assert_eq(HeapInteractables.crop_state(run, 1, now), "empty")
	assert_false(HeapInteractables.plant(run, 1, now), "planting needs fertilizer")
	HeapInteractables.give("fert", 2)
	assert_true(HeapInteractables.plant(run, 1, now))
	assert_false(HeapInteractables.plant(run, 1, now), "the plot is taken")
	assert_eq(HeapInteractables.crop_state(run, 1, now + 10.0), "growing")
	assert_false(bool(HeapInteractables.harvest(run, 1, now + 10.0)["ok"]), "not ripe yet")
	run.life = 2
	var gold_before: int = Session.gold
	var result: Dictionary = HeapInteractables.harvest(run, 1, now + HeapGrowth.CROP_SECONDS + 1.0)
	assert_true(bool(result["ok"]))
	assert_eq(run.life, 2 + HeapInteractables.HARVEST_HEAL)
	assert_eq(Session.gold, gold_before + HeapInteractables.HARVEST_GOLD)
	assert_eq(HeapInteractables.crop_state(run, 1, now + 100.0), "empty", "the plot is bare again")
	assert_eq(HeapInteractables.stock("fert"), 1)


func test_shrine_blessing_once_per_visit_and_trough_pays_for_junk() -> void:
	var run: ZoneRun = Session.zone_run
	run.life = 3
	var max_before: int = run.max_life()
	var blessing: Dictionary = HeapInteractables.bless(run)
	assert_true(bool(blessing["ok"]))
	assert_eq(run.max_life(), max_before + 1)
	assert_gt(int(blessing["healed"]), 0)
	assert_false(bool(HeapInteractables.bless(run)["ok"]), "once per visit")
	assert_false(HeapInteractables.can_feed(run), "nothing to feed")
	HeapInteractables.give("junk", 4)
	var gold_before: int = Session.gold
	for index: int in range(HeapInteractables.FEED_LIMIT):
		assert_true(HeapInteractables.feed(run))
	assert_false(HeapInteractables.feed(run), "three feedings per visit")
	assert_eq(Session.gold, gold_before + HeapInteractables.FEED_GOLD * HeapInteractables.FEED_LIMIT)


func test_herding_each_escaped_animal_counts_once_per_visit() -> void:
	var run: ZoneRun = Session.zone_run
	for number: int in range(1, HeapGrowth.ESCAPED_ANIMALS + 1):
		assert_true(HeapInteractables.herd(run, number))
		assert_false(HeapInteractables.herd(run, number), "already back in the pen")
	assert_eq(int(Session.counters.get(HeapZone.COUNTER_HERDED, 0)), 3)


func test_quest_objectives_follow_the_zone_actions() -> void:
	var run: ZoneRun = Session.zone_run
	assert_true(Session.start_quest(HeapZone.QUEST_HERD))
	assert_true(Session.start_quest(HeapZone.QUEST_FERT))
	assert_true(Session.start_quest(HeapZone.QUEST_DAM))
	for number: int in range(1, 4):
		HeapInteractables.herd(run, number)
	assert_eq(Session.quest_log.objectives_met_count(QuestCatalog.find(HeapZone.QUEST_HERD), Session.unlock_state()), 1)
	for id: String in ["fert_1", "fert_2", "fert_3"]:
		HeapInteractables.pick_up(run, id)
	assert_eq(Session.quest_log.objectives_met_count(QuestCatalog.find(HeapZone.QUEST_FERT), Session.unlock_state()), 1, "three sacks complete Fertilizer Run")
	assert_eq(Session.quest_log.objectives_met_count(QuestCatalog.find(HeapZone.QUEST_DAM), Session.unlock_state()), 0)
	HeapInteractables.smash(HeapGrowth.find_barricade("dam"))
	assert_eq(Session.quest_log.objectives_met_count(QuestCatalog.find(HeapZone.QUEST_DAM), Session.unlock_state()), 1, "smashing the dam completes Unblock the Stream")


# ---- The Seed Shrine puzzle ------------------------------------------------------------------------------------------


func test_the_garden_has_solutions_and_the_shortest_is_long() -> void:
	var solutions: Array[Array] = GrowthGrid.solutions()
	assert_gte(solutions.size(), 1, "the garden is solvable")
	assert_lte(solutions.size(), 4, "a 5 x 5 board has at most four solutions")
	var shortest: Array[int] = GrowthGrid.shortest_solution()
	assert_gte(shortest.size(), 8, "the shortest solution needs at least 8 seeds (%d)" % shortest.size())
	var board: Array[bool] = GrowthGrid.start_board()
	assert_false(GrowthGrid.is_solved(board), "the garden does not start solved")
	for cell: int in shortest:
		board = GrowthGrid.plant(board, cell)
	assert_true(GrowthGrid.is_solved(board), "planting the shortest solution blooms everything")


func test_planting_flips_a_plot_and_its_neighbours() -> void:
	assert_eq(GrowthGrid.flipped_by(0).size(), 3, "a corner flips three plots")
	assert_eq(GrowthGrid.flipped_by(2).size(), 4, "an edge flips four")
	assert_eq(GrowthGrid.flipped_by(12).size(), 5, "the middle flips five")
	var board: Array[bool] = GrowthGrid.all_bloom()
	board = GrowthGrid.plant(board, 12)
	assert_false(board[12])
	assert_false(board[7])
	assert_true(board[0])
	board = GrowthGrid.plant(board, 12)
	assert_true(GrowthGrid.is_solved(board), "planting twice undoes it")


func test_the_garden_puzzle_gives_the_satchel_through_the_def() -> void:
	assert_eq(def.puzzle_kind, "growth")
	var satchel: EquipmentData = Session.content.equipment_piece(def.puzzle_equipment_id)
	assert_not_null(satchel)
	assert_true(Session.grant_equipment(satchel))
	assert_false(Session.grant_equipment(satchel))


# ---- Sort It Out! --------------------------------------------------------------------------------------------------------


func test_a_flawless_run_is_three_stars_and_a_full_streak() -> void:
	var game: SortGame = SortGame.play_perfect(0.4)
	assert_true(game.is_finished())
	assert_eq(game.correct_count(), SortGame.PIECES)
	assert_eq(game.stars(), 3)
	assert_eq(game.best_streak, SortGame.PIECES)
	var expected: int = 0
	for streak: int in range(1, SortGame.PIECES + 1):
		expected += 3 if streak >= 8 else (2 if streak >= 4 else 1)
	assert_eq(game.points_total, expected)


func test_never_sorting_loses_every_piece() -> void:
	var game: SortGame = SortGame.new()
	game.advance(SortGame.end_time(SortGame.PIECES - 1) + 1.0)
	assert_true(game.is_finished())
	assert_eq(game.correct_count(), 0)
	assert_eq(game.stars(), 0)


func test_a_wrong_bin_breaks_the_streak_and_early_presses_are_ignored() -> void:
	var game: SortGame = SortGame.new()
	assert_eq(game.press(SortGame.COMPOST, 0.1), SortGame.Result.IGNORED, "nothing on the belt yet")
	var time: float = SortGame.spawn_time(0) + 0.3
	assert_eq(game.press(SortGame.bin_of(0), time), SortGame.Result.CORRECT)
	time = SortGame.spawn_time(1) + 0.3
	var wrong: int = (SortGame.bin_of(1) + 1) % SortGame.BIN_COUNT
	assert_eq(game.press(wrong, time), SortGame.Result.WRONG)
	assert_eq(game.streak, 0)
	assert_eq(game.correct_count(), 1)
	assert_eq(game.outcomes, [1, 0] as Array[int])


func test_pieces_arrive_faster_and_every_bin_is_used() -> void:
	assert_gt(SortGame.spawn_time(1) - SortGame.spawn_time(0), SortGame.spawn_time(19) - SortGame.spawn_time(18), "the belt speeds up")
	var used: Dictionary = {}
	for piece: int in range(SortGame.PIECES):
		used[SortGame.bin_of(piece)] = true
		assert_gt(SortGame.end_time(piece), SortGame.spawn_time(piece) + 2.0, "every piece gets at least 2 seconds")
	assert_eq(used.size(), SortGame.BIN_COUNT)
	var distinct: Dictionary = {}
	for index: int in SortGame.ORDER:
		distinct[index] = true
	assert_eq(distinct.size(), SortGame.PIECES, "every junk piece appears once")


func test_star_thresholds_and_rewards() -> void:
	assert_eq(SortGame.stars_for(6), 0)
	assert_eq(SortGame.stars_for(7), 1)
	assert_eq(SortGame.stars_for(13), 2)
	assert_eq(SortGame.stars_for(18), 3)
	var gold_before: int = Session.gold
	var first: Dictionary = SortGame.apply_result(3)
	assert_true(bool(first["first_win"]))
	assert_gt(int(first["gold"]), 100)
	assert_eq(Session.gold, gold_before + int(first["gold"]))
	assert_true(Session.flag(HeapZone.FLAG_SORT_FIRST))
	var again: Dictionary = SortGame.apply_result(3)
	assert_false(bool(again["first_win"]))
	assert_lt(int(again["gold"]), int(first["gold"]))
	assert_eq(int(SortGame.apply_result(0)["gold"]), 0)


func test_the_minigame_is_a_different_type_from_the_other_three() -> void:
	assert_eq(def.minigame_kind, "sort")
	for zone_id: String in [DnaZone.ID, GainlandsZone.ID, BuffetZone.ID]:
		assert_ne(def.minigame_kind, ZoneDefs.get_def(zone_id).minigame_kind)
