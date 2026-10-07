extends GutTest
## Polish round, Group D: the new hidden chests (rules, rewards that scale, saved open state) and the reward box family.

## The chests this round added, per zone id (the zones' older chests are covered by their own tests).
const NEW_ZONE_CHESTS: Dictionary = {
	"dna": ["chest_maze_3", "chest_maze_4", "chest_maze_5", "chest_records_2", "chest_exec_2", "chest_farm_c"],
	"gainlands": ["chest_pec_2", "chest_delt_2", "chest_glute_2", "chest_calf_2", "chest_ground_3", "chest_ground_4"],
	"buffet": ["chest_pancake_2", "chest_cheddar_2", "chest_meadow_ne", "chest_cliffs_w", "chest_crust", "chest_edge_sw"],
	"heap": ["chest_peak_c", "chest_peak_d", "chest_scree_ne", "chest_corner_nw", "chest_back_edge", "chest_thicket_s"],
	"capital": ["chest_facade_back", "chest_facade_west", "chest_crease_e", "chest_crease_w", "chest_ward_n", "chest_yard_corner"],
}
const NEW_TOWN_CHESTS: Array[String] = ["clashatorium_west", "harbor_pier", "southeast_shore", "northeast_ridge"]


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.pending_popups.clear()
	Session.pending_level_ups.clear()


func _def_rewards(zone_id: String) -> Dictionary:
	match zone_id:
		"dna":
			return DnaZone.CHEST_REWARDS
		"gainlands":
			return GainlandsZone.CHEST_REWARDS
		"buffet":
			return BuffetZone.CHEST_REWARDS
		"heap":
			return HeapZone.CHEST_REWARDS
	return CapitalZone.CHEST_REWARDS


func _layout_chests(zone_id: String) -> Dictionary:
	match zone_id:
		"dna":
			var dna: DnaLayout = DnaLayout.new()
			dna.build()
			return dna.chests
		"gainlands":
			var gain: GainlandsLayout = GainlandsLayout.new()
			gain.build()
			return gain.chests
		"buffet":
			var buffet: BuffetLayout = BuffetLayout.new()
			buffet.build()
			return buffet.chests
		"heap":
			var heap: HeapLayout = HeapLayout.new()
			heap.build()
			return heap.chests
	var capital: CapitalLayout = CapitalLayout.new()
	capital.build()
	return capital.chests


func _layout_anchors(zone_id: String) -> Dictionary:
	match zone_id:
		"dna":
			var dna: DnaLayout = DnaLayout.new()
			dna.build()
			return dna.anchors
		"gainlands":
			var gain: GainlandsLayout = GainlandsLayout.new()
			gain.build()
			return gain.anchors
		"buffet":
			var buffet: BuffetLayout = BuffetLayout.new()
			buffet.build()
			return buffet.anchors
		"heap":
			var heap: HeapLayout = HeapLayout.new()
			heap.build()
			return heap.anchors
	var capital: CapitalLayout = CapitalLayout.new()
	capital.build()
	return capital.anchors


## A rough "how good is this" number for a chest's contents (gold plus what else it holds), used to check that harder chests pay more.
func _value(reward: Dictionary) -> int:
	var total: int = int(reward.get("gold", 0))
	if str(reward.get("item", "")) != "":
		total += 60
	if str(reward.get("card", "")) != "":
		var card: CardData = Session.card_by_id(str(reward["card"]))
		total += [40, 80, 160, 260][clampi(int(card.rarity), 0, 3)]
	if str(reward.get("equipment", "")) != "":
		var piece: EquipmentData = Session.content.equipment_piece(str(reward["equipment"]))
		total += 200 if piece.advanced else 110
	if str(reward.get("cosmetic", "")) != "":
		total += 130
	var pack_id: String = str(reward.get("pack", ""))
	if pack_id != "":
		total += 230 if pack_id.begins_with("gilded") else 110
	return total


func test_every_zone_got_four_to_six_new_chests_with_valid_rewards() -> void:
	for zone_id: String in NEW_ZONE_CHESTS.keys():
		var ids: Array = NEW_ZONE_CHESTS[zone_id] as Array
		assert_between(ids.size(), 4, 6, "%s: 4 to 6 new chests" % zone_id)
		var rewards: Dictionary = _def_rewards(zone_id)
		var chests: Dictionary = _layout_chests(zone_id)
		for id: String in ids:
			assert_true(chests.has(id), "%s: %s is in the layout" % [zone_id, id])
			assert_true(rewards.has(id), "%s: %s has a reward" % [zone_id, id])
			var reward: Dictionary = rewards.get(id, {}) as Dictionary
			if str(reward.get("item", "")) != "":
				assert_not_null(Session.content.item(str(reward["item"])), "%s: item %s exists" % [id, reward["item"]])
			if str(reward.get("card", "")) != "":
				assert_not_null(Session.card_by_id(str(reward["card"])), "%s: card %s exists" % [id, reward["card"]])
			if str(reward.get("equipment", "")) != "":
				assert_not_null(Session.content.equipment_piece(str(reward["equipment"])), "%s: equipment %s exists" % [id, reward["equipment"]])
			if str(reward.get("cosmetic", "")) != "":
				assert_not_null(CosmeticCatalog.find(str(reward["cosmetic"])), "%s: cosmetic %s exists" % [id, reward["cosmetic"]])
			if str(reward.get("pack", "")) != "":
				assert_not_null(PackCatalog.find(str(reward["pack"])), "%s: pack %s exists" % [id, reward["pack"]])
			assert_gt(_value(reward), 50, "%s pays something worth the trip" % id)


func test_new_chests_keep_their_distance_from_spots_and_each_other() -> void:
	for zone_id: String in NEW_ZONE_CHESTS.keys():
		var chests: Dictionary = _layout_chests(zone_id)
		var anchors: Dictionary = _layout_anchors(zone_id)
		for id: String in NEW_ZONE_CHESTS[zone_id] as Array:
			var pos: Vector3 = chests[id] as Vector3
			for anchor_name: String in anchors.keys():
				var anchor: Vector3 = anchors[anchor_name] as Vector3
				assert_gt(Vector2(pos.x - anchor.x, pos.z - anchor.z).length(), 2.4, "%s is not inside the %s spot" % [id, anchor_name])
			for other: String in chests.keys():
				if other != id:
					var other_pos: Vector3 = chests[other] as Vector3
					assert_gt(Vector2(pos.x - other_pos.x, pos.z - other_pos.z).length(), 3.0, "%s is not stacked on %s" % [id, other])


func test_the_hardest_to_reach_chests_pay_the_most() -> void:
	# The floating islands / mesa tops / summits / deep maze ends are the "hard" chests: they must out-earn the easy ground chests of the same zone.
	var hard: Dictionary = {
		"gainlands": ["chest_glute_2", "chest_calf_2"], "buffet": ["chest_pancake_2", "chest_cheddar_2"], "heap": ["chest_peak_c", "chest_peak_d"],
		"dna": ["chest_maze_3", "chest_maze_4"], "capital": ["chest_ward_n", "chest_yard_corner"],
	}
	var easy: Dictionary = {
		"gainlands": ["chest_ground_3"], "buffet": ["chest_edge_sw"], "heap": ["chest_thicket_s"],
		"dna": ["chest_farm_c"], "capital": ["chest_crease_w"],
	}
	for zone_id: String in hard.keys():
		var rewards: Dictionary = _def_rewards(zone_id)
		for hard_id: String in hard[zone_id] as Array:
			for easy_id: String in easy[zone_id] as Array:
				assert_gt(_value(rewards[hard_id] as Dictionary), _value(rewards[easy_id] as Dictionary), "%s (hard) pays more than %s (easy)" % [hard_id, easy_id])


func test_gainlands_island_chests_stand_on_the_island_tops() -> void:
	var layout: GainlandsLayout = GainlandsLayout.new()
	layout.build()
	var on_islands: int = 0
	for id: String in layout.chests.keys():
		var pos: Vector3 = layout.chests[id] as Vector3
		var surface: GainlandsLayout.Surface = layout.surface_at(pos.x, pos.z)
		assert_true(surface == GainlandsLayout.Surface.GROUND or surface == GainlandsLayout.Surface.ISLAND, "%s is on ground or an island top, never the falling rim" % id)
		if surface == GainlandsLayout.Surface.ISLAND:
			on_islands += 1
			var island: GainlandsLayout.Island = layout.island_at(pos.x, pos.z)
			assert_lt(Vector2(pos.x - island.center.x, pos.z - island.center.y).length(), island.radius - 1.0, "%s is a step inside the island's edge" % id)
	assert_gte(on_islands, 8, "two chests on each of the four floating islands")


func test_new_town_chests_have_rewards_cells_and_secrets_docs() -> void:
	var doc: String = FileAccess.get_file_as_string("res://docs/design/secrets.md")
	for id: String in NEW_TOWN_CHESTS:
		assert_true(TownBuilder.HIDDEN_CHEST_CELLS.has(id), "%s has a cell" % id)
		assert_true(TownBuilder.HIDDEN_CHEST_OFFSETS.has(id), "%s has an offset" % id)
		assert_true(TownScene.HIDDEN_CHEST_REWARDS.has(id), "%s has a reward" % id)
		assert_true(doc.contains("`%s`" % id), "%s is in secrets.md" % id)
	for id: String in StartingAreaBuilder.HIDDEN_CHESTS.keys():
		assert_true(doc.contains("`%s`" % id), "%s is in secrets.md" % id)
	for zone_id: String in NEW_ZONE_CHESTS.keys():
		for id: String in NEW_ZONE_CHESTS[zone_id] as Array:
			assert_true(doc.contains("`%s`" % id), "%s is in secrets.md" % id)
	assert_gte(TownBuilder.HIDDEN_CHEST_CELLS.size(), 11, "the town now has 11 hidden chests")


func test_starting_area_chests_are_gold_only_and_reachable() -> void:
	var area: StartingAreaBuilder = StartingAreaBuilder.new()
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	area.build(root)
	assert_eq(StartingAreaBuilder.HIDDEN_CHESTS.size(), 3)
	var gold: Array[int] = []
	for id: String in StartingAreaBuilder.HIDDEN_CHESTS.keys():
		assert_true(area.anchors.has("hidden_chest_%s" % id))
		assert_not_null(area.chest_nodes.get(id), "%s has a chest model" % id)
		gold.append(int((StartingAreaBuilder.HIDDEN_CHESTS[id] as Dictionary)["gold"]))
	assert_gte(gold.max(), 70)


# ---- the open state --------------------------------------------------------------------------------------------------------------------


func test_the_chest_model_has_a_lid_that_stays_open() -> void:
	var chest: Node3D = ModelKit.dungeon_prop("chest_gold")
	add_child_autofree(chest)
	assert_not_null(ChestKit.lid_of(chest), "the KayKit chest has a separate lid")
	assert_false(ChestKit.is_open(chest))
	assert_true(ChestKit.set_open(chest, true))
	assert_true(ChestKit.is_open(chest))
	assert_almost_eq(ChestKit.lid_of(chest).rotation_degrees.x, ChestKit.OPEN_ANGLE, 0.01, "lid swung up and back")
	ChestKit.set_open(chest, false)
	assert_eq(ChestKit.lid_of(chest).rotation_degrees.x, 0.0)


func test_chests_found_in_the_save_are_shown_open_after_loading() -> void:
	var nodes: Dictionary = {}
	for id: String in ["a", "b"]:
		var chest: Node3D = ModelKit.dungeon_prop("chest_gold")
		add_child_autofree(chest)
		nodes[id] = chest
	Session.discover_secret("test_chest_a")
	var opened: int = ChestKit.apply_saved(nodes, func(id: String) -> String: return "test_chest_%s" % id)
	assert_eq(opened, 1)
	assert_true(ChestKit.is_open(nodes["a"] as Node3D))
	assert_false(ChestKit.is_open(nodes["b"] as Node3D))
	# Round trip through the save data: the secret survives, so the chest is open again in a fresh scene.
	var saved: Dictionary = Session.to_dict()
	Session.new_game()
	Session.ensure_game()
	assert_true(Session.from_dict(saved))
	assert_true(Session.found_secret("test_chest_a"))


# ---- rewards and the boxes ---------------------------------------------------------------------------------------------------------------


func test_a_chest_reward_is_paid_and_described() -> void:
	var gold_before: int = Session.gold
	var reward: Dictionary = {"gold": 70, "item": "healing_draught", "card": "C-22", "equipment": "hover_boots", "cosmetic": "hat_chef", "pack": "path_beefcake"}
	var summary: RewardSummary = Session.grant_chest_reward(reward, "Test chest")
	assert_eq(Session.gold, gold_before + 70)
	assert_eq(summary.gold, 70)
	assert_eq(summary.items.size(), 1)
	assert_eq(summary.cards.size(), 1)
	assert_eq(summary.equipment.size(), 1)
	assert_eq(summary.cosmetics, ["Chef's Toque"] as Array[String])
	assert_eq(summary.packs.size(), 1)
	assert_eq(Session.pack_count("path_beefcake"), 1)
	assert_false(summary.is_empty())
	assert_eq(summary.lines().size(), 6)


func test_the_chest_box_shows_the_contents_and_waits_for_a_confirm() -> void:
	var summary: RewardSummary = Session.grant_chest_reward({"gold": 55, "item": "healing_draught", "card": "B-28", "pack": "gilded_beefcake", "equipment": "hover_boots"}, "Hidden chest")
	var popup: RewardPopup = RewardPopup.make(summary)
	add_child_autofree(popup)
	await get_tree().process_frame
	var texts: PackedStringArray = PackedStringArray()
	for label: Node in popup.find_children("*", "Label", true, false):
		texts.append((label as Label).text)
	var joined: String = " | ".join(texts)
	assert_true(joined.contains("CHEST OPENED"), "header")
	assert_true(joined.contains("+55 gold"), "gold shown")
	assert_true(joined.contains(Session.content.item("healing_draught").display_name), "item shown")
	assert_true(joined.contains("Gilded"), "pack shown")
	assert_gt(_count_of(popup, CardView), 0, "the card is drawn as a real card with its art")
	var finished: Array[bool] = [false]
	popup.finished.connect(func() -> void: finished[0] = true)
	popup.frame._confirm()
	assert_false(finished[0], "ignored during the guard time: the E press that opened the chest cannot also close the box")
	await get_tree().create_timer(PopupFrame.GUARD_TIME + 0.1).timeout
	popup.frame._confirm()
	assert_true(finished[0], "confirmed once the guard time has passed")


func test_completing_a_quest_queues_a_quest_complete_box_with_rewards_and_unlocks() -> void:
	Session.quest_log.reset()
	Session.flags = {}
	Session.counters = {}
	Session.offer_auto_quests()
	var gold_before: int = Session.gold
	Session.set_flag(&"vendor_seen")
	Session.set_flag(&"item_vendor_seen")
	Session.set_flag(&"equipment_vendor_seen")
	assert_eq(Session.pending_popups.size(), 1, "one Quest Complete box is waiting")
	var summary: RewardSummary = Session.pending_popups[0]
	assert_eq(summary.kind, RewardSummary.Kind.QUEST)
	assert_eq(summary.title, "Meet the Merchants")
	assert_eq(summary.gold, 50)
	assert_eq(summary.xp, 40)
	assert_eq(Session.gold, gold_before + 50)


func test_a_level_up_from_a_quest_is_reported_after_the_quest_box() -> void:
	var real: QuestData = QuestCatalog.find(QuestDefinitions.MERCHANTS)
	Session.quest_log.reset()
	Session.quest_log.active.append(real.id)
	Session.profile.xp = ProgressionTable.xp_to_reach(2) - 1
	assert_true(Session.complete_quest(real.id))
	var summary: RewardSummary = Session.pending_popups[0]
	assert_false(summary.levels_reached.is_empty(), "the quest's XP levelled the hero up")
	assert_false(Session.pending_level_ups.is_empty(), "and the level-up popup is still queued, to follow the quest box")


func test_unlock_digest_names_what_a_level_or_a_zone_opens() -> void:
	var before: UnlockDigest = UnlockDigest.capture({}, 1)
	var flags: Dictionary = {}
	flags[str(CorruptedNpcs.unlock_flag("beefcake"))] = true
	flags[str(ZoneCompletion.flag_name("beefcake"))] = true
	var after: UnlockDigest = UnlockDigest.capture(flags, 1)
	var lines: Array[String] = after.lines_since(before)
	var joined: String = " | ".join(lines)
	assert_true(joined.contains("entrance is now open"), "a zone entrance opened: %s" % joined)
	assert_true(joined.contains("Arena"), "the first freed zone opens the Arena: %s" % joined)
	var found_equipment_level: bool = false
	for level: int in range(2, ProgressionTable.MAX_LEVEL + 1):
		var level_lines: Array[String] = UnlockDigest.level_unlocks(level)
		if level_lines.has("New stock at the Equipment Vendor"):
			found_equipment_level = true
	assert_true(found_equipment_level, "one level opens new stock at the Equipment Vendor")
	var two_zones: Dictionary = flags.duplicate()
	two_zones[str(ZoneCompletion.flag_name("gourmand"))] = true
	assert_true(UnlockDigest.capture(two_zones, 1).lines_since(after).has("The Alchemist is now available"))


func test_the_three_boxes_share_one_frame() -> void:
	var chest: RewardPopup = RewardPopup.make(Session.grant_chest_reward({"gold": 5}, "Chest"))
	add_child_autofree(chest)
	var quest_summary: RewardSummary = RewardSummary.new()
	quest_summary.kind = RewardSummary.Kind.QUEST
	quest_summary.title = "A Quest"
	var quest: RewardPopup = RewardPopup.make(quest_summary)
	add_child_autofree(quest)
	var level: LevelUpScreen = LevelUpScreen.new()
	level.setup([ProgressionTable.row(2)] as Array[LevelData])
	add_child_autofree(level)
	await get_tree().process_frame
	assert_eq(_count_of(chest, PopupFrame), 1, "the chest box is built on PopupFrame")
	assert_eq(_count_of(quest, PopupFrame), 1, "the quest box is built on PopupFrame")
	assert_eq(_count_of(level, PopupFrame), 1, "the level-up box is built on PopupFrame")
	var headers: PackedStringArray = PackedStringArray()
	for screen: Control in [chest, quest, level]:
		for label: Node in screen.find_children("*", "Label", true, false):
			headers.append((label as Label).text)
	var joined: String = " | ".join(headers)
	assert_true(joined.contains("CHEST OPENED") and joined.contains("QUEST COMPLETE") and joined.contains("LEVEL UP!"))


func _count_of(root: Node, script_class: Variant) -> int:
	var count: int = 0
	for node: Node in root.find_children("*", "", true, false):
		if is_instance_of(node, script_class):
			count += 1
	return count


func test_an_opened_chest_is_empty() -> void:
	var chest: Node3D = ModelKit.dungeon_prop("chest_gold")
	add_child_autofree(chest)
	var body: MeshInstance3D = chest.find_child(ChestKit.BODY_NODE, true, false) as MeshInstance3D
	var full_tris: int = body.mesh.get_faces().size() / 3
	ChestKit.set_open(chest, true)
	var empty_tris: int = body.mesh.get_faces().size() / 3
	assert_lt(empty_tris, full_tris, "the gold pile is gone from the open chest")
	assert_gt(empty_tris, 150, "but the box itself is still there")
	var highest: float = 0.0
	for point: Vector3 in body.mesh.get_faces():
		highest = maxf(highest, point.y)
	assert_lt(highest, 0.7, "nothing heaped above the rim")
	ChestKit.set_open(chest, false)
	assert_eq(body.mesh.get_faces().size() / 3, full_tris, "closing it again restores the gold")
