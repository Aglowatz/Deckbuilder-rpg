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
