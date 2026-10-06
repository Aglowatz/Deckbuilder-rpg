extends GutTest
## Brief 6, Part D: the Gainlands - layout, travel network, falling, def, enemies, content, story,
## interactables, the power-routing puzzle and the Rep Counter minigame.

var layout: GainlandsLayout
var def: ZoneDef
var story: ZoneStoryText


func before_all() -> void:
	layout = GainlandsLayout.new()
	layout.build()
	def = ZoneDefs.get_def(GainlandsZone.ID)
	story = ZoneStoryText.for_zone(GainlandsZone.ID)


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.zone_run = ZoneRun.enter(GainlandsZone.ID, Session.profile, Session.deck)


func after_each() -> void:
	Session.zone_run = null
	Session.run = null
	Session.dungeon_map = null
	Session.mini_active = false


# ---- Layout -------------------------------------------------------------------------------------


func _main_ground_area() -> float:
	var area: float = 0.0
	for x: int in range(-10, 120):
		for z: int in range(-10, 100):
			if GainlandsLayout.is_main_ground(float(x) + 0.5, float(z) + 0.5):
				area += 1.0
	return area


func test_main_land_is_about_the_size_of_the_d_n_a() -> void:
	var dna: DnaLayout = DnaLayout.new()
	dna.build()
	var ratio: float = _main_ground_area() / float(dna.floor_cell_count())
	assert_between(ratio, 0.8, 1.7, "the Gainlands' ground is roughly the D.N.A.'s size (ratio %.2f)" % ratio)


func test_there_are_several_floating_islands_clear_of_the_main_land() -> void:
	assert_gte(layout.islands.size(), 4)
	for island: GainlandsLayout.Island in layout.islands:
		assert_gt(island.height, 5.0, "%s floats high above the ground" % island.id)
		for angle: int in range(0, 360, 15):
			var rim: Vector2 = island.center + Vector2(cos(deg_to_rad(float(angle))), sin(deg_to_rad(float(angle)))) * (island.radius + GainlandsLayout.FALL_MARGIN)
			assert_false(GainlandsLayout.is_main_ground(rim.x, rim.y), "%s does not overlap the main land" % island.id)
	for a: GainlandsLayout.Island in layout.islands:
		for b: GainlandsLayout.Island in layout.islands:
			if a != b:
				assert_gt(a.center.distance_to(b.center), a.radius + b.radius + 4.0, "%s and %s do not overlap" % [a.id, b.id])


func test_surface_rules_ground_island_rim_void() -> void:
	var island: GainlandsLayout.Island = layout.islands[0]
	assert_eq(layout.surface_at(52.0, 64.0), GainlandsLayout.Surface.GROUND)
	assert_eq(layout.surface_at(island.center.x, island.center.y), GainlandsLayout.Surface.ISLAND)
	assert_eq(layout.surface_at(island.center.x + island.radius + 0.4, island.center.y), GainlandsLayout.Surface.RIM, "just past the edge you fall")
	assert_eq(layout.surface_at(island.center.x + island.radius + 3.0, island.center.y), GainlandsLayout.Surface.VOID)
	assert_almost_eq(layout.ground_height(island.center.x, island.center.y), island.height, 0.001)


func test_every_anchor_chest_and_enemy_stands_on_real_ground() -> void:
	for name: String in layout.anchors.keys():
		var pos: Vector3 = layout.anchors[name] as Vector3
		var surface: GainlandsLayout.Surface = layout.surface_at(pos.x, pos.z)
		assert_true(surface == GainlandsLayout.Surface.GROUND or surface == GainlandsLayout.Surface.ISLAND, "anchor %s is on ground or an island" % name)
		if surface == GainlandsLayout.Surface.GROUND:
			assert_gt(GainlandsLayout.main_edge_distance(pos.x, pos.z), 1.0, "anchor %s is clear of the cliff edge" % name)
		else:
			var island: GainlandsLayout.Island = layout.island_at(pos.x, pos.z)
			assert_lt(Vector2(pos.x - island.center.x, pos.z - island.center.y).length(), island.radius - 0.8, "anchor %s is well inside its island" % name)
	for id: String in layout.chests.keys():
		var chest: Vector3 = layout.chests[id] as Vector3
		assert_eq(layout.surface_at(chest.x, chest.z) == GainlandsLayout.Surface.VOID, false, "chest %s is on ground" % id)
		assert_ne(layout.surface_at(chest.x, chest.z), GainlandsLayout.Surface.RIM, "chest %s is not on the rim" % id)
	for spawn: Dictionary in layout.enemy_spawns:
		var home: Vector3 = spawn["home"] as Vector3
		assert_eq(layout.surface_at(home.x, home.z), GainlandsLayout.Surface.GROUND, "enemies roam the main land")


func test_main_land_is_hilly_and_flat_at_the_hub() -> void:
	var lowest: float = 99.0
	var highest: float = -99.0
	for x: int in range(10, 95, 3):
		for z: int in range(15, 78, 3):
			if GainlandsLayout.main_edge_distance(float(x), float(z)) > 6.0:
				var h: float = layout.ground_height(float(x), float(z))
				lowest = minf(lowest, h)
				highest = maxf(highest, h)
	assert_gt(highest - lowest, 1.5, "rolling hills, not a billiard table")
	assert_almost_eq(layout.ground_height(52.0, 64.0), 0.0, 0.01, "the hub is level")


# ---- Reachability on the real map ---------------------------------------------------------------------


func _flood(builder: GainlandsBuilder, start: Vector3) -> Dictionary:
	var seen: Dictionary = {}
	var queue: Array[Vector2i] = [Vector2i(int(floorf(start.x)), int(floorf(start.z)))]
	seen[queue[0]] = true
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_back()
		for d: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var next: Vector2i = cell + d
			if seen.has(next):
				continue
			if builder.is_walkable(Vector3(float(next.x) + 0.5, 0.0, float(next.y) + 0.5), 0.3):
				seen[next] = true
				queue.append(next)
	return seen


func test_everything_on_the_main_land_is_reachable_from_the_spawn() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.build(host)
	var reach: Dictionary = _flood(builder, builder.anchor("spawn"))
	for spot: Dictionary in def.spots:
		var pos: Vector3 = builder.anchor(str(spot["anchor"]))
		if layout.island_at(pos.x, pos.z) != null and not GainlandsLayout.is_main_ground(pos.x, pos.z):
			continue
		var near: bool = false
		for dx: int in range(-2, 3):
			for dz: int in range(-2, 3):
				if reach.has(Vector2i(int(floorf(pos.x)) + dx, int(floorf(pos.z)) + dz)):
					near = true
		assert_true(near, "spot %s is reachable on foot (or within a step of reachable ground)" % str(spot["id"]))
	for id: String in layout.chests.keys():
		var chest: Vector3 = layout.chests[id] as Vector3
		if GainlandsLayout.is_main_ground(chest.x, chest.z):
			var ok: bool = false
			for dx: int in range(-2, 3):
				for dz: int in range(-2, 3):
					if reach.has(Vector2i(int(floorf(chest.x)) + dx, int(floorf(chest.z)) + dz)):
						ok = true
			assert_true(ok, "chest %s can be reached on foot" % id)
	assert_gt(reach.size(), 2500, "a big walkable main land")
	for island: GainlandsLayout.Island in layout.islands:
		assert_false(reach.has(Vector2i(int(island.center.x), int(island.center.y))), "%s is NOT reachable on foot" % island.id)


func test_islands_are_walkable_once_you_are_on_them() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var builder: GainlandsBuilder = GainlandsBuilder.new()
	builder.build(host)
	for point: GainlandsTravel.Point in GainlandsTravel.points():
		var arrival: Vector3 = builder.anchor(point.dest_anchor)
		assert_true(builder.is_walkable(arrival, 0.3), "%s lands somewhere you can stand" % point.id)
	var island: GainlandsLayout.Island = layout.islands[0]
	assert_true(builder.is_walkable(Vector3(island.center.x, 0.0, island.center.y + 0.5)))
	var past_edge: Vector3 = Vector3(island.center.x + island.radius + 0.5, island.height, island.center.y)
	assert_true(builder.is_walkable(past_edge), "the rim is walkable (so you can step off)")
	assert_not_null(builder.fall_island(past_edge), "...and stepping there is a fall")
	assert_null(builder.fall_island(Vector3(island.center.x, island.height, island.center.y)))
	assert_false(builder.is_walkable(Vector3(island.center.x + island.radius + 4.0, island.height, island.center.y)), "far past the edge is void")


func test_the_hidden_chests_are_at_least_six_quarter_size_and_on_islands_too() -> void:
	assert_gte(layout.chests.size(), 6)
	assert_eq(def.chest_rewards.size(), layout.chests.size())
	var on_islands: int = 0
	for id: String in layout.chests.keys():
		assert_true(def.chest_rewards.has(id), "reward defined for %s" % id)
		var chest: Vector3 = layout.chests[id] as Vector3
		if not GainlandsLayout.is_main_ground(chest.x, chest.z):
			on_islands += 1
	assert_gte(on_islands, 2, "some chests are on floating islands")


# ---- Travel network ------------------------------------------------------------------------------------


func test_every_travel_point_and_destination_exists() -> void:
	var points: Array[GainlandsTravel.Point] = GainlandsTravel.points()
	assert_gte(points.size(), 8)
	var throwers: int = 0
	var rippers: int = 0
	for point: GainlandsTravel.Point in points:
		assert_true(layout.anchors.has(point.anchor), "%s anchor" % point.id)
		assert_true(layout.anchors.has(point.dest_anchor), "%s destination" % point.id)
		assert_false(def.spot_def("travel_" + point.id).is_empty(), "%s has an interact spot" % point.id)
		if point.kind == "throw":
			throwers += 1
		else:
			rippers += 1
	assert_gte(throwers, 3)
	assert_gte(rippers, 3)


func test_every_island_has_an_always_open_way_back() -> void:
	for island: GainlandsLayout.Island in layout.islands:
		var open_exit: bool = false
		for point: GainlandsTravel.Point in GainlandsTravel.points():
			var here: Vector3 = layout.anchors[point.anchor] as Vector3
			var dest: Vector3 = layout.anchors[point.dest_anchor] as Vector3
			var on_this: bool = layout.island_at(here.x, here.z) == island and not GainlandsLayout.is_main_ground(here.x, here.z)
			var leaves: bool = GainlandsLayout.is_main_ground(dest.x, dest.z) or layout.island_at(dest.x, dest.z) != island
			if on_this and leaves and point.lock == null:
				open_exit = true
		assert_true(open_exit, "%s can always be left (no stranding)" % island.id)


func test_some_islands_are_only_reachable_by_chains_and_some_points_are_locked() -> void:
	var locked: int = 0
	for point: GainlandsTravel.Point in GainlandsTravel.points():
		if point.lock != null:
			locked += 1
	assert_gte(locked, 3, "several travel points are locked behind conditions")
	# Calf Cove is reached only from Pec Perch; Glute Garden only from Delt Deck.
	for point: GainlandsTravel.Point in GainlandsTravel.points():
		var dest: Vector3 = layout.anchors[point.dest_anchor] as Vector3
		var island: GainlandsLayout.Island = layout.island_at(dest.x, dest.z)
		if island == null or GainlandsLayout.is_main_ground(dest.x, dest.z):
			continue
		var origin: Vector3 = layout.anchors[point.anchor] as Vector3
		var origin_island: GainlandsLayout.Island = layout.island_at(origin.x, origin.z)
		var from_main: bool = GainlandsLayout.is_main_ground(origin.x, origin.z)
		if island.id in ["calf", "glute"]:
			assert_false(from_main, "%s cannot be entered straight from the main land" % island.id)
			assert_not_null(origin_island)


func test_travel_locks_open_with_their_conditions() -> void:
	var wheel: GainlandsTravel.Point = GainlandsTravel.find("ripper_delt")
	assert_false(GainlandsTravel.is_unlocked(wheel, Session.unlock_state()))
	GainlandsInteractables.run_wheel()
	assert_true(GainlandsTravel.is_unlocked(wheel, Session.unlock_state()), "running the wheel opens the Delt Deck portal")
	var glute: GainlandsTravel.Point = GainlandsTravel.find("thrower_glute")
	assert_false(GainlandsTravel.is_unlocked(glute, Session.unlock_state()))
	Session.bump_counter(GainlandsZone.COUNTER_ENEMIES, 2)
	assert_true(GainlandsTravel.is_unlocked(glute, Session.unlock_state()), "defeating enemies opens Glute Garden")
	var calf: GainlandsTravel.Point = GainlandsTravel.find("ripper_calf")
	assert_false(GainlandsTravel.is_unlocked(calf, Session.unlock_state()))
	Session.quest_log.completed.append(GainlandsZone.QUEST_SPOT_ME)
	assert_true(GainlandsTravel.is_unlocked(calf, Session.unlock_state()), "Coach Brenda's quest opens Calf Cove")
	var across: GainlandsTravel.Point = GainlandsTravel.find("thrower_east")
	assert_false(GainlandsTravel.is_unlocked(across, Session.unlock_state()))
	Session.add_cards([Session.card_by_id("B-27")] as Array[CardData])
	assert_true(GainlandsTravel.is_unlocked(across, Session.unlock_state()), "owning a Gym Rat card opens the cross-country throw")


func test_falling_costs_one_hp_and_is_logged() -> void:
	var run: ZoneRun = Session.zone_run
	var before: int = run.hp
	var logged: int = Session.zone_log.size()
	var result: Dictionary = GainlandsInteractables.apply_fall(run, "Pec Perch", story.text("fx.fall_log"))
	assert_eq(run.hp, before - GainlandsZone.FALL_DAMAGE)
	assert_eq(int(result["damage"]), 1)
	assert_eq(Session.zone_log.size(), logged + 1)
	assert_true(Session.zone_log[Session.zone_log.size() - 1].contains("Pec Perch"))
	run.hp = 1
	var last: Dictionary = GainlandsInteractables.apply_fall(run, "Delt Deck", story.text("fx.fall_log"))
	assert_true(bool(last["down"]), "the last HP lost sends you to the hub")


# ---- The def: hub, vendor, NPCs, quests -----------------------------------------------------------------


func test_hub_has_a_heal_spot_vendor_npcs_and_quests() -> void:
	for kind: String in ["heal", "exit", "mini_dungeon", "main_dungeon", "puzzle", "quiz", "minigame", "vendor_npc"]:
		var found: bool = false
		for spot: Dictionary in def.spots:
			if str(spot["kind"]) == kind:
				found = true
		assert_true(found, "a %s spot exists" % kind)
	var quest_npcs: int = 0
	for spot: Dictionary in def.spots:
		if str(spot["kind"]) in ["quest_npc", "vendor_npc"]:
			quest_npcs += 1
	assert_between(quest_npcs, 2, 3)
	assert_between(def.vendor_ids.size(), 8, 10)
	for id: String in def.vendor_ids:
		assert_not_null(Session.card_by_id(id), "vendor card %s exists" % id)
		assert_eq(Session.card_by_id(id).color, Affinity.Type.BEEFCAKE, "%s is a Beefcake card" % id)
	var zone_quests: int = 0
	for quest: QuestData in QuestCatalog.all():
		if quest.id.begins_with("gain_"):
			zone_quests += 1
			assert_true(def.quest_npc_names.has(quest.giver_npc), "%s is given by a hub NPC" % quest.id)
			assert_eq(quest.giver_npc, quest.turn_in_npc)
			for suffix: String in ["offer", "active", "ready", "done"]:
				assert_true(story.lines.has("quest.%s.%s" % [quest.id, suffix]), "%s.%s dialogue exists" % [quest.id, suffix])
	assert_between(zone_quests, 2, 3)


func test_main_dungeon_signs_name_the_house_of_gains() -> void:
	assert_true(story.text("sign.main_dungeon").contains("HOUSE OF GAINS"))
	assert_true(story.text("fx.main_dungeon").contains("House of Gains"))
	assert_true(story.text("sign.main_dungeon").to_lower().contains("leg day"), "the quiz answer is still on the sign")


func test_zone_hp_rules_use_the_gainlands_fee() -> void:
	var run: ZoneRun = Session.zone_run
	run.damage(run.hp)
	Session.add_gold(100)
	var gold: int = Session.gold
	var fee: int = Session.zone_wake_at_hub("beaten by a Flexing Brute")
	assert_eq(fee, 20)
	assert_eq(Session.gold, gold - 20)
	assert_eq(run.hp, run.max_hp(), "wake at the hub at full HP")
	assert_true(Session.zone_log[Session.zone_log.size() - 1].begins_with("Protein tab"))


# ---- Enemies -----------------------------------------------------------------------------------------------


func test_three_enemy_designs_two_slow_battle_starters_and_a_fast_damage_dealer() -> void:
	assert_eq(GainlandsEnemies.IDS.size(), 3)
	for id: String in [GainlandsEnemies.BRUTE, GainlandsEnemies.GOLEM]:
		var info: ZoneEnemyInfo = GainlandsEnemies.info(id)
		assert_eq(info.kind, ZoneEnemyInfo.Kind.BATTLE)
		assert_lt(info.chase_speed, TownPlayer.SPEED, "%s is slower than the player" % id)
		assert_true(ZoneEnemies.is_slow(GainlandsZone.ID, id))
		var deck: Deck = ZoneEnemies.deck(Session.content, GainlandsZone.ID, id)
		assert_gte(deck.size(), 24, "%s has a real deck" % id)
		for card: CardData in deck.cards:
			assert_true(card.type == CardEnums.CardType.INFRASTRUCTURE or card.color == Affinity.Type.BEEFCAKE or card.color == Affinity.Type.NEUTRAL, "%s uses Beefcake cards" % id)
	var sprite: ZoneEnemyInfo = GainlandsEnemies.info(GainlandsEnemies.SPRITE)
	assert_eq(sprite.kind, ZoneEnemyInfo.Kind.DAMAGE)
	assert_eq(sprite.damage, 2)
	assert_gt(sprite.chase_speed, TownPlayer.SPEED)


func test_a_gainlands_battle_uses_the_zone_hp_and_the_beefcake_deck() -> void:
	Session.zone_run.damage(3)
	var context: BattleContext = Session.make_zone_battle(GainlandsEnemies.GOLEM, "golem_0")
	assert_eq(context.enemy_name, "Protein Shake Golem")
	assert_eq(context.game.players[0].hp, Session.zone_run.max_hp() - 3, "no heal on entry")
	Session.zone_run.finish_battle(context.game)
	assert_eq(Session.zone_run.hp, context.game.players[0].hp, "HP carries over, no post-battle heal")


func test_defeating_a_gainlands_enemy_bumps_the_zone_counter() -> void:
	var context: BattleContext = Session.make_zone_battle(GainlandsEnemies.BRUTE, "brute_0")
	context.won = true
	Session.add_gold(0)
	Session.resolve_zone_battle(context)
	assert_eq(int(Session.counters.get(GainlandsZone.COUNTER_ENEMIES, 0)), 1)
	assert_true(Session.zone_run.is_defeated("brute_0"))


# ---- Content: cards, equipment, mini dungeon ------------------------------------------------------------------


func test_gainlands_cards_and_equipment_exist() -> void:
	for id: String in ZoneCards.GAINLANDS_VENDOR_IDS + ["B-06", "B-28"]:
		assert_not_null(Session.card_by_id(id), id)
	var belt: EquipmentData = Session.content.equipment_piece("swole_belt")
	assert_not_null(belt)
	assert_eq(belt.slot, EquipmentData.Slot.ARMOR)


func test_mini_dungeon_is_three_battles_and_a_one_time_unique_beefcake_card() -> void:
	var map: DungeonMap = MiniDungeon.build_map(GainlandsZone.ID)
	var battles: int = 0
	for node: DungeonMap.MapNode in map.nodes:
		if node.kind == DungeonMap.Kind.BATTLE or node.kind == DungeonMap.Kind.BOSS:
			battles += 1
			assert_false(MiniDungeon.enemy_recipe(node.enemy_name, GainlandsZone.ID).is_empty(), node.enemy_name)
			assert_gte(MiniDungeon.enemy_setup(Session.content, node, GainlandsZone.ID).deck.size(), 24)
	assert_eq(battles, 3)
	Session.dungeon_map = MiniDungeon.build_map(GainlandsZone.ID)
	Session.run = DungeonRun.enter(Session.profile, Session.deck, Session.zone_run.run.dungeon_sources)
	Session.mini_active = true
	var before: int = Session.owned_count("B-28")
	var first: Dictionary = Session.resolve_mini_dungeon(true)
	assert_true(bool(first.get("first_clear", false)))
	assert_eq(Session.owned_count("B-28"), before + 1)
	assert_true(Session.flag(GainlandsZone.FLAG_MINI_CLEARED))
	Session.run = DungeonRun.enter(Session.profile, Session.deck, Session.zone_run.run.dungeon_sources)
	Session.mini_active = true
	var second: Dictionary = Session.resolve_mini_dungeon(true)
	assert_false(second.has("first_clear"))
	assert_eq(Session.owned_count("B-28"), before + 1, "the card is a one-time reward")


# ---- Story text ------------------------------------------------------------------------------------------------


func test_every_sign_npc_and_travel_text_exists_in_the_story_file() -> void:
	for sign: GainlandsLayout.Sign in layout.signs:
		assert_true(story.lines.has(sign.key), "sign text %s" % sign.key)
	for entry: Dictionary in def.npcs:
		var id: String = str(entry["id"])
		if GainlandsTravel.find(id) != null:
			assert_true(story.lines.has("travel.%s.intro" % id), "%s intro" % id)
			assert_true(story.lines.has("travel.%s.locked" % id), "%s locked line" % id)
		else:
			assert_true(story.lines.has("npc.%s.intro" % id) or id == "quiz" or id == "gary", "intro for %s" % id)
	for key: String in ["npc.brenda.return", "npc.gus.return", "npc.tony.return", "npc.quiz.return", "npc.minigame.return", "npc.gary.return", "fx.fall", "fx.fall_log", "fx.thrown", "fx.landed", "fx.portal", "fx.wake", "ui.exit.body", "hud.objective", "enemy.brute", "enemy.golem", "enemy.sprite"]:
		assert_true(story.lines.has(key), key)
	for point: GainlandsTravel.Point in GainlandsTravel.points():
		assert_true(story.lines.has("travel.dest.%s" % point.dest_anchor), "destination name for %s" % point.dest_anchor)


func test_the_quiz_has_four_questions_about_energy_and_transport_with_findable_answers() -> void:
	assert_eq(story.quiz_questions.size(), 4)
	var haystack: String = ""
	for value: Variant in story.lines.values():
		haystack += " ".join(PackedStringArray(value as Array)).to_lower() + "\n"
	for question: Dictionary in story.quiz_questions:
		assert_eq((question["a"] as Array).size(), 4)
		var answer: String = str((question["a"] as Array)[int(question["correct"])]).to_lower().replace("\"", "").trim_suffix(".")
		assert_true(haystack.contains(answer), "answer '%s' is on a sign or in the dialogue" % answer)
	for key: String in ["quiz.result.0", "quiz.result.4", "quiz.not_passed"]:
		assert_true(story.lines.has(key))


# ---- Interactables -----------------------------------------------------------------------------------------------


func test_protein_shake_outcomes_have_real_effects() -> void:
	var run: ZoneRun = Session.zone_run
	run.damage(5)
	var hp: int = run.hp
	GainlandsInteractables.apply_shake(run, GainlandsInteractables.shake_outcome(0.0))
	assert_eq(run.hp, hp + 3, "a good shake heals")
	var max_before: int = run.max_hp()
	GainlandsInteractables.apply_shake(run, "buff")
	assert_eq(run.max_hp(), max_before + 1, "the buff raises max HP for the visit")
	var gold: int = Session.gold
	GainlandsInteractables.apply_shake(run, "gold")
	assert_eq(Session.gold, gold + GainlandsInteractables.SHAKE_REFUND)
	run.hp = 1
	GainlandsInteractables.apply_shake(run, "bad")
	assert_eq(run.hp, 1, "a bad shake never kills")
	assert_eq(GainlandsInteractables.shake_outcome(0.99), "empty")
	var seen: Dictionary = {}
	for step: int in range(100):
		seen[GainlandsInteractables.shake_outcome(float(step) / 100.0)] = true
	assert_eq(seen.size(), 6, "all six outcomes are reachable")


func test_flex_mirror_heals_up_to_three_times_per_visit() -> void:
	var run: ZoneRun = Session.zone_run
	run.damage(6)
	var hp: int = run.hp
	for flex: int in range(3):
		var result: Dictionary = GainlandsInteractables.flex(run)
		assert_true(bool(result["ok"]))
		assert_eq(int(result["healed"]), 1)
	assert_eq(run.hp, hp + 3)
	assert_false(bool(GainlandsInteractables.flex(run)["ok"]), "the pump peaks after three flexes")
	assert_eq(int(Session.counters.get(GainlandsZone.COUNTER_FLEXES, 0)), 3)
	var fresh: ZoneRun = ZoneRun.enter(GainlandsZone.ID, Session.profile, Session.deck)
	assert_true(bool(GainlandsInteractables.flex(fresh)["ok"]), "a new visit resets the limit")


func test_spotting_gary_gives_a_buff_each_visit_and_gold_only_once() -> void:
	var run: ZoneRun = Session.zone_run
	var max_before: int = run.max_hp()
	var gold: int = Session.gold
	var first: Dictionary = GainlandsInteractables.spot_gary(run)
	assert_true(bool(first["ok"]) and bool(first["first_time"]))
	assert_eq(run.max_hp(), max_before + 2)
	assert_eq(Session.gold, gold + GainlandsInteractables.SPOT_GOLD)
	assert_true(Session.flag(GainlandsZone.FLAG_SPOTTED))
	assert_false(bool(GainlandsInteractables.spot_gary(run)["ok"]), "once per visit")
	var again: ZoneRun = ZoneRun.enter(GainlandsZone.ID, Session.profile, Session.deck)
	var result: Dictionary = GainlandsInteractables.spot_gary(again)
	assert_true(bool(result["ok"]))
	assert_eq(int(result["gold"]), 0, "the gold is a one-time reward")


func test_running_the_wheel_powers_the_grid_once() -> void:
	assert_true(GainlandsInteractables.run_wheel())
	assert_false(GainlandsInteractables.run_wheel())
	assert_true(Session.flag(GainlandsZone.FLAG_WHEEL_POWERED))


# ---- The power-routing puzzle ---------------------------------------------------------------------------------------


func test_the_power_puzzle_has_exactly_one_solution() -> void:
	var found: Array[Array] = WheelPuzzle.solutions()
	assert_eq(found.size(), 1, "exactly one of the 729 switch settings powers all three machines")
	var all_off: Array[int] = [0, 0, 0, 0, 0, 0]
	assert_false(WheelPuzzle.is_solved(all_off))
	var solution: Array[int] = []
	solution.assign(found[0] as Array)
	assert_true(WheelPuzzle.is_solved(solution))
	assert_eq(WheelPuzzle.delivered(solution), WheelPuzzle.TARGET)
	assert_lte(WheelPuzzle.running(solution), WheelPuzzle.MAX_RUNNING)


func test_every_wheel_feeds_two_different_machines() -> void:
	for wheel: int in range(WheelPuzzle.WHEELS):
		assert_ne(WheelPuzzle.WIRING[wheel][0], WheelPuzzle.WIRING[wheel][1])
		assert_eq(WheelPuzzle.machine_of(wheel, 0), -1)


func test_running_too_many_wheels_never_solves_it() -> void:
	var solution: Array[int] = []
	solution.assign(WheelPuzzle.solutions()[0] as Array)
	var lazy: Array[int] = solution.duplicate()
	for wheel: int in range(WheelPuzzle.WHEELS):
		if lazy[wheel] == 0:
			lazy[wheel] = 1
	assert_false(WheelPuzzle.is_solved(lazy))


func test_the_puzzle_gives_the_gainlands_equipment_through_the_def() -> void:
	assert_eq(def.puzzle_kind, "wheels")
	assert_eq(def.puzzle_equipment_id, "swole_belt")
	assert_not_null(Session.content.equipment_piece(def.puzzle_equipment_id))
	assert_ne(def.flag_puzzle_solved, DnaZone.FLAG_PUZZLE_SOLVED, "a separate one-time flag from the D.N.A.'s")


# ---- The Rep Counter minigame --------------------------------------------------------------------------------------


func test_rep_game_judges_by_timing() -> void:
	assert_eq(RepGame.rate(0.0), RepGame.Rating.PERFECT)
	assert_eq(RepGame.rate(-0.05), RepGame.Rating.PERFECT)
	assert_eq(RepGame.rate(0.15), RepGame.Rating.GOOD)
	assert_eq(RepGame.rate(0.3), RepGame.Rating.OK)
	assert_eq(RepGame.rate(0.5), RepGame.Rating.MISS)


func test_a_flawless_set_is_24_points_and_three_stars() -> void:
	var presses: Array[float] = []
	for beat: float in RepGame.BEATS:
		presses.append(beat)
	var game: RepGame = RepGame.play(presses)
	assert_eq(game.points(), RepGame.max_points())
	assert_eq(game.points(), 24)
	assert_eq(game.stars(), 3)
	assert_true(game.is_finished())


func test_never_pressing_is_eight_misses_and_no_stars() -> void:
	var game: RepGame = RepGame.play([] as Array[float])
	assert_eq(game.points(), 0)
	assert_eq(game.stars(), 0)
	assert_eq(game.ratings.size(), RepGame.REPS)


func test_star_thresholds_and_stray_taps() -> void:
	assert_eq(RepGame.stars_for(19), 2)
	assert_eq(RepGame.stars_for(20), 3)
	assert_eq(RepGame.stars_for(14), 2)
	assert_eq(RepGame.stars_for(13), 1)
	assert_eq(RepGame.stars_for(8), 1)
	assert_eq(RepGame.stars_for(7), 0)
	var game: RepGame = RepGame.new()
	assert_eq(game.press(0.2), -1, "a tap far before the first beat is ignored")
	assert_eq(game.next_rep, 0)


func test_rewards_depend_on_stars_and_the_first_clear_bonus_is_one_time() -> void:
	var gold: int = Session.gold
	var first: Dictionary = RepGame.apply_result(3)
	assert_true(bool(first["first_win"]))
	assert_eq(str(first["item"]), "healing_salve")
	assert_gt(Session.gold, gold + 100, "first clear pays big")
	var second: Dictionary = RepGame.apply_result(3)
	assert_false(bool(second["first_win"]))
	assert_eq(str(second["item"]), "")
	assert_lt(int(second["gold"]), int(first["gold"]), "repeats pay less")
	var better: Dictionary = RepGame.apply_result(3)
	var worse: Dictionary = RepGame.apply_result(1)
	assert_gt(int(better["gold"]), int(worse["gold"]), "better performance pays more")
	assert_eq(int(RepGame.apply_result(0)["gold"]), 0, "a failed set pays nothing")
	assert_true(Session.flag(GainlandsZone.FLAG_REPS_FIRST))


func test_the_minigame_is_a_different_type_from_the_memory_game() -> void:
	assert_eq(def.minigame_kind, "reps")
	assert_ne(def.minigame_kind, ZoneDefs.get_def(DnaZone.ID).minigame_kind)
	assert_ne(def.flag_minigame_first, DnaZone.FLAG_MATCH_FIRST)
