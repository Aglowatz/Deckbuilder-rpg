extends GutTest
## Fable Nov 14 (the owner's playtest list): the pins for this pass.
## Part 1 - story: the Old Service Tunnels' boss is one of Spotless's officers and no longer cuts to Primm; the cell has bars; Maren
## taught at the castle, never made the bars, is going blind and no longer says she knew all along.


const TUNNELS: String = "S-CAP"
const OFFICER: String = "Enforcer Sergeant Scuff"


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func after_each() -> void:
	Session.save_enabled = true


func _all_text(lines: Array[String]) -> String:
	return " ".join(lines)


# ---- 1.1 The Old Service Tunnels ----------------------------------------------------------------------------------------------------


func test_the_primm_scenes_play_at_his_own_door_only() -> void:
	assert_true(DungeonMapScreen.is_primm_boss_node(DungeonMap.Kind.BOSS, PrimmsCastleDungeon.ZONE_ID), "the castle's boss room")
	assert_false(DungeonMapScreen.is_primm_boss_node(DungeonMap.Kind.BOSS, TUNNELS), "the Old Service Tunnels lie in the Capital's zone but are not his room")
	assert_false(DungeonMapScreen.is_primm_boss_node(DungeonMap.Kind.BOSS, PasteWorks.DUNGEON_ID), "nor are the Paste Works")
	assert_false(DungeonMapScreen.is_primm_boss_node(DungeonMap.Kind.BATTLE, PrimmsCastleDungeon.ZONE_ID), "nor an ordinary room of the castle")


func test_the_tunnels_boss_is_spotless_officer() -> void:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find(TUNNELS)
	assert_eq(plan.boss, OFFICER)
	var map: DungeonMap = MainDungeons.build_map(TUNNELS)
	assert_eq(map.boss().enemy_name, OFFICER)
	assert_true(BossIntros.keys().has(OFFICER), "he has a boss intro")
	assert_false(BossIntros.keys().has("Enforcer Captain Spotless"), "the second Spotless is gone")
	assert_true(BossIntros.keys().has("Captain Spotless"), "the Captain still keeps the Capital Gate")
	assert_eq(Bestiary.canonical("Enforcer Captain Spotless"), OFFICER, "an old save's met / won counts carry over")
	assert_eq(NpcRegistry.story_speaker("dungeon.dg_s_cap_boss.before"), "NPC-SCUFF")
	assert_not_null(Portraits.texture_for("NPC-SCUFF"), "the dialogue box borrows the Correction Officer's talk frame until Batch 16")
	assert_not_null(Bestiary.art(OFFICER), "and the Bestiary borrows the Correction Officer's square")


func test_the_officer_says_who_sent_him_and_keeps_the_tunnels_heart() -> void:
	var story: ZoneStoryText = ZoneStoryText.for_zone(CapitalZone.ID)
	var before: String = _all_text(story.get_lines("dungeon.dg_s_cap_boss.before"))
	assert_string_contains(before, "Captain Spotless sent me to check the service tunnels")
	assert_string_contains(before, "sneak into the city")
	var after: String = _all_text(story.get_lines("dungeon.dg_s_cap_boss.after"))
	assert_string_contains(after, "All four Paths, shoulder to shoulder")
	assert_string_contains(after, "The grate isn't locked")


# ---- 1.2 Fragment 2 -----------------------------------------------------------------------------------------------------------------


func test_fragment_two_has_bars_and_nothing_calls_the_cell_glass() -> void:
	var story: StoryText = StoryText.shared()
	assert_eq(story.get_lines("memory.2.fragment")[1], "There are bars on every side of me, and behind the bars there are faces in white coats, taking notes.")
	for key: String in ["memory.2.fragment", "memory.2.after", "memory.3.after", "memory.4.after", "memory.4.after_known", "memory.4.reply"]:
		assert_false(_all_text(story.get_lines(key)).to_lower().contains("glass"), "%s: no glass" % key)
	var capital: ZoneStoryText = ZoneStoryText.for_zone(CapitalZone.ID)
	assert_string_contains(_all_text(capital.get_lines("cutscene.primm_end.3")), "behind bars for ten years")


# ---- 1.3 Elder Maren ----------------------------------------------------------------------------------------------------------------


func test_maren_never_made_the_cell_and_never_knew_all_along() -> void:
	var story: StoryText = StoryText.shared()
	for key: String in story.texts.keys():
		if not (key.begins_with("memory.") or key.begins_with("town.elder") or key.begins_with("cave_mouth.maren")):
			continue
		var text: String = _all_text(story.get_lines(key))
		assert_false(text.contains("blow it") or text.contains("built the glass"), "%s: she never blew glass" % key)
		assert_false(text.contains("The Warden opens that tunnel"), "%s: no 'the Warden opens for one family'" % key)
		assert_false(text.contains("I knew, you see") or text.contains("I knew as well") or text.contains("knew who you were the moment"), "%s: she did not know all along" % key)


func test_maren_taught_at_the_castle_and_her_eyes_are_going() -> void:
	var story: StoryText = StoryText.shared()
	assert_string_contains(_all_text(story.get_lines("cave_mouth.maren")), "my eyes aren't what they were")
	var second: String = _all_text(story.get_lines("memory.2.after"))
	assert_string_contains(second, "I taught the royal children at the castle")
	assert_string_contains(second, "That boy is ten years dead", "she talks herself out of it")
	assert_string_contains(second, "A woman called Wren leads it", "the resistance instruction is unchanged")
	var third: String = _all_text(story.get_lines("memory.3.after"))
	assert_string_contains(third, "I worked at the castle once, studying the Paths")
	assert_string_contains(third, "I never forged a bar of them")
	var fourth: String = _all_text(story.get_lines("memory.4.after"))
	assert_string_contains(fourth, "My eyes have been going for years")
	assert_string_contains(fourth, "So that we are never far from home", "the tortoise's answer stays")


# ---- Part 2: Fig Sly's shop ---------------------------------------------------------------------------------------------------------


func test_the_supply_crate_is_gone_from_the_crease() -> void:
	var def: ZoneDef = CapitalZone.build_def()
	for spot: Dictionary in def.spots:
		assert_ne(str(spot.get("id", "")), "fig_crate", "no second shop beside Fig Sly")
		assert_false(str(spot.get("title", "")).contains("Crate of Supplies"))
	var layout: CapitalLayout = CapitalLayout.new()
	layout.build()
	assert_false(layout.anchors.has("fig_crate"))
	var fig: Vector3 = layout.anchors["fig"] as Vector3
	for prop: CapitalLayout.Prop in layout.props:
		if prop.kind == "crease_crate":
			assert_false(prop.pos.x > fig.x + 3.0 and prop.pos.z > fig.z + 1.5, "no crate stands where the supply crate was")


func test_fig_sells_his_items_beside_his_cards() -> void:
	var stock: ItemVendorData = CapitalZone.black_market_items("Fig Sly")
	assert_eq(stock.entries.size(), CapitalZone.BLACK_MARKET_ITEMS.size())
	for entry: ItemVendorEntry in stock.entries:
		assert_null(entry.unlock, "%s: nothing on his shelf is locked or hidden" % entry.item_id)
		assert_not_null(Session.content.item(entry.item_id), entry.item_id)
	var kinds: Array[VendorCategories.Kind] = VendorCategories.list(true, true, false, false, true)
	assert_eq(kinds[0], VendorCategories.Kind.CARDS)
	assert_eq(kinds[1], VendorCategories.Kind.ITEMS, "Items sits beside Cards")
	assert_eq(VendorCategories.label(VendorCategories.Kind.ITEMS), "Items")
	assert_true(IconArt.has(VendorCategories.icon(VendorCategories.Kind.ITEMS)))
	assert_eq(VendorCategories.list(true, true, true).size(), 3, "a shop with no items gets no Items tile")


func test_no_item_tile_hides_behind_a_door() -> void:
	var source: String = FileAccess.get_file_as_string("res://ui/town/item_vendor_screen.gd")
	assert_false(source.contains("add_compartment("), "the hover-to-reveal doors are gone from the item shop")
	assert_false(FileAccess.get_file_as_string("res://ui/town/vendor_fx.gd").contains("func add_compartment"))
	var screen: ItemVendorScreen = ItemVendorScreen.new()
	screen.stock = CapitalZone.black_market_items("Fig Sly")
	screen.vendor_screen_id = ""
	add_child_autofree(screen)
	await wait_frames(3)
	var shown: int = 0
	for label: Node in screen.find_children("*", "Label", true, false):
		var text: String = (label as Label).text
		assert_ne(text, "???", "no mystery tile")
		if text == Session.content.item("iron_ration").display_name:
			shown += 1
	assert_eq(shown, 1, "the item's name is on its tile without hovering")
	assert_eq(screen.find_children("Compartment", "", true, false).size(), 0)


# ---- Part 3: the world --------------------------------------------------------------------------------------------------------------


func test_the_two_capital_signs_are_gone_and_the_shafts_show_their_path() -> void:
	var layout: CapitalLayout = CapitalLayout.new()
	layout.build()
	for sign: CapitalLayout.Sign in layout.signs:
		assert_ne(sign.key, "sign.crease_network", "the dark board between the Crease's shafts")
		assert_ne(sign.key, "sign.net_plaza", "the small sign beside the plaza's manhole")
	var want: Dictionary = {"reek": "ICON-ENERGY-R", "grave": "ICON-ENERGY-N", "hungry": "ICON-ENERGY-G", "transit": "ICON-ENERGY-B"}
	for index: int in range(CapitalLayout.NETWORK_DESTINATIONS.size()):
		var destination: String = CapitalLayout.NETWORK_DESTINATIONS[index]
		assert_eq(CapitalProps.shaft_icon(index), str(want.get(destination, "ICON-MAP-TRAVEL")), "the shaft to %s" % destination)


func test_the_lake_is_drawn_as_a_curve_that_still_meets_the_waterfall() -> void:
	var shape: PackedVector2Array = BoundaryKit.lake_shape()
	assert_gt(shape.size(), TownBounds.LAKE.size() * 4, "many more points than the outline")
	for index: int in BoundaryKit.LAKE_SHARP:
		assert_true(shape.has(TownBounds.LAKE[index]), "the gorge-lip corner %d is kept" % index)
	var sharpest: float = 0.0
	for index: int in range(shape.size()):
		var a: Vector2 = shape[(index - 1 + shape.size()) % shape.size()]
		var b: Vector2 = shape[index]
		var c: Vector2 = shape[(index + 1) % shape.size()]
		if BoundaryKit.LAKE_SHARP.any(func(i: int) -> bool: return TownBounds.LAKE[i] == b):
			continue
		sharpest = maxf(sharpest, absf((b - a).angle_to(c - b)))
	assert_lt(rad_to_deg(sharpest), 25.0, "no corner sharper than 25 degrees anywhere else")
	assert_true(TownBounds.shore_grass(Vector3(56.2, 0, 47.0)), "the town's grass runs to the west shore")
	assert_false(TownBounds.shore_grass(Vector3(63.0, 0, 55.0)), "not out over the open lake")
	assert_false(TownBounds.shore_grass(Vector3(80.0, 0, 40.0)), "nor on the far shore")


func _heap_flood(mounted: bool) -> Dictionary:
	var builder: HeapBuilder = HeapBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	builder.mounted = mounted
	var start: Vector3 = builder.anchor("spawn")
	var first: Vector2i = Vector2i(roundi(start.x * 2.0), roundi(start.z * 2.0))
	var seen: Dictionary = {first: true}
	var queue: Array[Vector2i] = [first]
	while not queue.is_empty():
		var cell: Vector2i = queue.pop_back()
		for step: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var next: Vector2i = cell + step
			if not seen.has(next) and builder.is_walkable_through_barricades(Vector3(float(next.x) * 0.5, 0.0, float(next.y) * 0.5)):
				seen[next] = true
				queue.append(next)
	return {"seen": seen, "chests": builder.layout.chests, "props": builder.layout.props}


func _near(seen: Dictionary, at: Vector3) -> bool:
	for dz: int in range(-4, 5):
		for dx: int in range(-4, 5):
			if seen.has(Vector2i(roundi(at.x * 2.0) + dx, roundi(at.z * 2.0) + dz)):
				return true
	return false


func test_the_dumps_top_right_is_a_treasure_field_reached_on_the_mount_only() -> void:
	var foot: Dictionary = _heap_flood(false)
	var ride: Dictionary = _heap_flood(true)
	var field: Array[String] = ["chest_scree_ne", "chest_barn"]
	field.append_array(HeapLayout.TREASURE_CHESTS)
	assert_eq(HeapLayout.TREASURE_CHESTS.size(), 4, "four more chests")
	for id: String in field:
		var at: Vector3 = (foot["chests"] as Dictionary)[id] as Vector3
		assert_false(_near(foot["seen"] as Dictionary, at), "%s cannot be reached on foot, even with the barricade smashed" % id)
		assert_true(_near(ride["seen"] as Dictionary, at), "%s is reached on the mount" % id)
	# nobody walks into the pocket at all: no cell north of the scree and east of the tree wall
	for cell: Variant in (foot["seen"] as Dictionary).keys():
		var p: Vector2 = Vector2(cell as Vector2i) * 0.5
		assert_false(p.x > 70.0 and p.y < 11.0, "a walker stands at (%.1f, %.1f) in the treasure field" % [p.x, p.y])
		if p.x > 70.0 and p.y < 11.0:
			break
	for id: String in HeapLayout.TREASURE_CHESTS:
		var reward: Dictionary = HeapZone.CHEST_REWARDS[id] as Dictionary
		assert_gte(Economy.chest_gold(int(reward["gold"])), 120, "%s pays well" % id)
		assert_eq(str(reward["title"]), "Treasure chest")
		assert_true(reward.has("item") or reward.has("pack") or reward.has("equipment"), "%s holds more than gold" % id)
		if reward.has("item"):
			assert_not_null(Session.content.item(str(reward["item"])), id)
		if reward.has("or_item"):
			assert_not_null(Session.content.item(str(reward["or_item"])), id)
		if reward.has("equipment"):
			assert_not_null(Session.content.equipment_piece(str(reward["equipment"])), id)
		if reward.has("pack"):
			assert_not_null(PackCatalog.find(str(reward["pack"])), id)


func test_the_dumps_walk_through_block_and_floating_bale_are_gone() -> void:
	var layout: HeapLayout = HeapLayout.new()
	layout.build()
	for prop: HeapLayout.Prop in layout.props:
		assert_ne(prop.kind, "hollow_log", "the walk-through log block")
		assert_false(prop.kind == "haybale" and prop.pos.x > 70.0 and prop.pos.z < 20.0, "the hay bale that read as a floating door beside the barn")


func test_a_treasure_chest_never_comes_up_empty() -> void:
	var piece: EquipmentData = Session.content.equipment_piece("sucker_punch_mitts")
	Session.grant_equipment(piece)
	var summary: RewardSummary = Session.grant_chest_reward(HeapZone.CHEST_REWARDS["chest_field_c"] as Dictionary, "Treasure chest")
	assert_eq(summary.equipment.size(), 0, "the piece is already owned")
	assert_eq(summary.items.size(), 1, "so the chest holds its stand-in item")
	assert_gt(summary.gold, 0)


func test_the_buffets_entrance_has_a_bank_and_a_forest_nobody_walks_through() -> void:
	var builder: BuffetBuilder = BuffetBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	var forest: Rect2 = BuffetLayout.ENTRANCE_FOREST
	var trees: int = 0
	for prop: BuffetLayout.Prop in builder.layout.props:
		if prop.kind in ["broccoli", "cauliflower"] and forest.has_point(Vector2(prop.pos.x, prop.pos.z)):
			trees += 1
	assert_gte(trees, 18, "a dense stand of broccoli and cauliflower")
	# nobody crosses it: no walkable cell on its middle line, and none behind it
	var x: float = forest.position.x + 1.6
	while x < forest.end.x - 1.0:
		assert_false(builder.is_walkable(Vector3(x, 0.0, 73.9)), "the forest is solid at x %.1f" % x)
		x += 0.5
	assert_true(builder.is_walkable(Vector3(BuffetLayout.BRIDGE_X, 0.0, 73.0)), "the way in stays open")
	assert_true(builder.is_walkable(builder.anchor("plaza")), "and so does the plaza")
	assert_true(BuffetBuilder.BANK_RINGS[BuffetBuilder.BANK_RINGS.size() - 1].y > 1.0, "the bank ends under the gravy")
	assert_true(FileAccess.get_file_as_string("res://world/buffet/buffet_builder.gd").contains("_build_south_bank()"))


func test_the_dna_apron_is_an_organised_wasteland_off_the_map() -> void:
	var kinds: Dictionary = {}
	for row: Array in DnaDressing.WASTELAND_ROWS:
		kinds[str(row[0])] = true
		assert_gt(float(row[3]), float(row[2]), "a row runs west to east")
	for kind: String in ["cabinets", "queue", "crates", "towers", "trees", "rubble"]:
		assert_true(kinds.has(kind), "a row of %s" % kind)
	for kind: Variant in DnaDressing.WASTELAND_PIECES.keys():
		assert_true(EnvKit.has_art(str((DnaDressing.WASTELAND_PIECES[kind] as Array)[0])), "%s has its art" % kind)
	var builder: DnaBuilder = DnaBuilder.new()
	builder.layout.build()
	builder._index_obstacles()
	var holder: Node3D = Node3D.new()
	add_child_autofree(holder)
	var dressing: DnaDressing = DnaDressing.build(holder, builder, 1)
	var total: int = 0
	for kind: Variant in dressing.wasteland_placed.keys():
		total += int(dressing.wasteland_placed[kind])
	assert_gt(total, 120, "the apron is dressed (%d pieces)" % total)
	for piece: Node in holder.find_child("Wasteland", true, false).get_children():
		if piece is Node3D and not piece is MultiMeshInstance3D:
			assert_false(builder.is_floor_at((piece as Node3D).position), "%s stands off the walkable map" % piece.name)
	assert_true(FileAccess.get_file_as_string("res://world/dna/dna_scene.gd").contains("DnaPaperDrift.build"), "the floating paper stays")


# ---- Part 4: the Path icons ---------------------------------------------------------------------------------------------------------


func test_one_canonical_icon_per_path_everywhere_in_code() -> void:
	for path: Affinity.Type in PathIcons.ORDER:
		assert_eq(IconArt.energy_id(path), PathIcons.icon(path), "the energy orb is the Path icon")
		assert_true(IconArt.has(PathIcons.icon(path)), "%s exists" % PathIcons.icon(path))
		assert_false(PathIcons.shape(path).is_empty())
	assert_eq(PathIcons.icon(Affinity.Type.NEUTRAL), "ICON-ENERGY-GENERIC")
	assert_eq(PathIcons.four(), ["ICON-ENERGY-B", "ICON-ENERGY-G", "ICON-ENERGY-R", "ICON-ENERGY-N"] as Array[String])
	# the ending, the fountain and the crest plinths
	for index: int in range(EndingDefs.PATH_ICONS.size()):
		assert_eq(str(EndingDefs.PATH_ICONS[index]["art"]), PathIcons.four()[index], "the ending's Path %d" % index)
		assert_true(TownStreets.path_icon_material(EndingDefs.PATH_ICONS[index], Color.WHITE) is StandardMaterial3D, "drawn as the painted icon")
	# the feats' one-Path groups, the Capital's camp
	for group: String in ["Beefcake", "Gourmand", "Necrocrat", "Refusemancer"]:
		var def: FeatDefs.Def = FeatDefs.Def.new()
		def.group = group
		assert_true(FeatDefs.icon_for(def, true).begins_with("ICON-ENERGY-"), "%s feats" % group)
	for id: String in CapitalLandmarks.PATH_ICONS:
		assert_true(id.begins_with("ICON-ENERGY-"), "the camp shows Path icons, not flasks")


func test_the_guide_the_sheet_and_the_inventory_exist() -> void:
	assert_true(FileAccess.file_exists("res://docs/art/path_icon_style_guide.md"))
	assert_true(FileAccess.file_exists("res://docs/art/path_icon_sheet.png"))
	var rows: PackedStringArray = FileAccess.get_file_as_string("res://docs/art/path_icon_inventory.csv").split("\n", false)
	assert_gt(rows.size(), 50, "every place is listed")
	assert_string_contains(_all_text(StoryText.shared().get_lines("memory.4.fragment")), "an arm, a chef's hat, a leaf and a skull, four signs in a ring")


# ---- Part 5: Dex's matching game ----------------------------------------------------------------------------------------------------


func test_dex_is_beaten_in_twenty_moves_and_the_table_allows_twenty_six() -> void:
	assert_eq(CardMatchCircuit.TARGET_MOVES, 20)
	assert_eq(CardMatchCircuit.FINAL_TARGET_MOVES, 19, "the final table stays one harder")
	assert_eq(CardMatchCircuit.TABLE_MAX_MOVES, 26)
	var flags: Dictionary = {}
	assert_false(CardMatchCircuit.record(flags, "beefcake", true, 21), "21 moves does not beat Dex")
	assert_true(CardMatchCircuit.record(flags, "beefcake", true, 20), "20 does")
	var steps: String = ""
	for objective: QuestObjective in CardMatchCircuit.quest().objectives:
		steps += objective.text + "\n"
	assert_string_contains(steps, "(20 moves or fewer)")
	assert_false(steps.contains("15 moves"), "no old number in the quest")
