extends GutTest
## Fable big pass Nov 23 (Parts 5 and 6): the world and the item list, rule by rule.
##   Part 5: Trey Pickett stands near each zone's entrance (not at Dex's elbow), the freed cast keeps the Crease's rift clear and
##           Primm stands in his cell, the farm hands walk.
##   Part 6: Participation Trophy 15 %, Global Gains Platinum Membership, Let Them Eat Cake, one display order for equipment and
##           items, the dye preview's cloak icon, the Pantry Mimic's 28 HP, keywords of one Path in that Path's colour.

var content: ContentSet


func before_all() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game()
	content = Session.content


# ---- Part 5 ------------------------------------------------------------------------------------------------------------------------


func test_trey_stands_by_the_entrance_and_dex_by_the_trivia_corner() -> void:
	for zone_id: String in DraftChallenges.ZONES:
		assert_true(DraftHost.ZONE_SPOTS.has(zone_id), "%s has a spot of its own for Trey" % zone_id)
		assert_eq(DraftHost.anchor_for(zone_id), "spawn", "measured from where the hero arrives")
		var offset: Vector3 = DraftHost.offset_for(zone_id)
		assert_lt(offset.length(), 20.0, "%s: within twenty metres of the entrance" % zone_id)
		assert_gt(absf(offset.x), 3.0, "%s: off the entrance's own line, so he blocks nobody" % zone_id)
		assert_lt(offset.z, 0.0, "%s: inside the zone, not behind the hero" % zone_id)
		var def: ZoneDef = ZoneDefs.get_def(zone_id)
		var trey: Dictionary = {}
		var dex: Dictionary = {}
		for entry: Dictionary in def.npcs:
			if str(entry["id"]) == DraftHost.SPOT_ID:
				trey = entry
			elif str(entry["id"]) == "cardsharp":
				dex = entry
		assert_eq(str(trey.get("anchor", "")), "spawn")
		assert_ne(str(trey.get("anchor", "")), str(dex.get("anchor", "")), "%s: not at Dex's table" % zone_id)
	assert_lt(DraftHost.offset_for("refusemancer").x, 0.0, "the Verdant Dump: on the left of the entrance")
	assert_eq(DraftHost.anchor_for("no_such_zone"), DraftHost.FALLBACK_ANCHOR)


func test_treys_spot_in_the_dump_is_open_ground_on_the_first_tier() -> void:
	var holder: Node3D = Node3D.new()
	add_child_autofree(holder)
	var heap: HeapBuilder = HeapBuilder.new()
	heap.build(holder)
	var at: Vector3 = heap.anchor("spawn") + DraftHost.offset_for("refusemancer")
	assert_true(heap.is_walkable(at, 0.4), "Trey stands on walkable ground")
	for i: int in range(8):
		var angle: float = TAU * float(i) / 8.0
		assert_true(heap.is_walkable(at + Vector3(cos(angle), 0.0, sin(angle)) * 1.2, 0.3), "with room round him (%d)" % i)
	var talk: Vector3 = at + Vector3(0.0, 0.0, 0.6)
	assert_true(heap.is_walkable(talk + Vector3(0.0, 0.0, 0.8), 0.3), "and the hero can stand in front of him")


func test_the_freed_cast_keeps_the_rift_clear_and_primm_is_in_his_cell() -> void:
	var layout: CapitalLayout = CapitalLayout.new()
	layout.build()
	var hub: Vector3 = layout.anchors["crease_spawn"] as Vector3
	var rift: Vector3 = layout.anchors["rift_station"] as Vector3
	var def: ZoneDef = ZoneDefs.get_def(CapitalZone.ID)
	var seen: Array[Vector3] = []
	for entry: Dictionary in def.freed_npcs:
		var at: Vector3 = hub + (entry["offset"] as Vector3)
		assert_gt(Vector2(at.x - rift.x, at.z - rift.z).length(), CapitalZone.RIFT_CLEARANCE, "%s stands clear of the Rift Express" % entry["id"])
		assert_gt(Vector2(at.x - hub.x, at.z - hub.z).length(), 2.5, "%s does not stand on the arrival spot" % entry["id"])
		for other: Vector3 in seen:
			assert_gt(at.distance_to(other), 1.6, "%s has room" % entry["id"])
		seen.append(at)
		if str(entry["id"]) == "primm":
			assert_lt(((entry["offset"] as Vector3) - CapitalZone.PRIMM_CELL_OFFSET).length(), 0.6, "Primm stands inside the cell")
			assert_string_contains(str(entry["name"]), "cell")
	var cell: Vector3 = hub + CapitalZone.PRIMM_CELL_OFFSET
	assert_gt(Vector2(cell.x - rift.x, cell.z - rift.z).length(), 6.0, "the cell is well away from the rift")
	assert_true(ResourceLoader.exists(CapitalScene.PRIMM_CELL_BARS), "the bars layer (tools/art/primm_cell_bars.py)")
	assert_true(EnvKit.has(CapitalScene.PRIMM_CELL_ID), "the painted cell")


func test_the_store_room_ghosts_have_a_picture_on_their_battle_plate() -> void:
	assert_not_null(Bestiary.art(StoreroomGhosts.ENEMY_NAME), "the ghosts wear the Hungry Ghost's card picture")
	assert_true(ResourceLoader.exists(str(Bestiary.CARD_ART_STAND_INS[StoreroomGhosts.ENEMY_NAME])))
	# the Ghost tokens of their rule keep the Hungry Ghost's id, so their card art shows on the table
	var setup: PlayerSetup = StoreroomGhosts.enemy_setup(content)
	assert_not_null(setup)
	assert_true(ResourceLoader.exists("res://assets/art/cards_thumb/T-19.webp"))


# ---- Part 6 ------------------------------------------------------------------------------------------------------------------------


func test_participation_trophy_gives_fifteen_percent() -> void:
	var trophy: EquipmentData = content.equipment_piece("participation_trophy")
	assert_not_null(trophy)
	assert_string_contains(GearText.effect(trophy), "15%")
	var found: bool = false
	for modifier: Modifier in trophy.modifiers:
		if modifier.kind == Modifier.Kind.XP_BONUS_PERCENT:
			found = true
			assert_eq(modifier.value, 15)
	assert_true(found, "an XP modifier")


func test_platinum_membership_and_let_them_eat_cake() -> void:
	var membership: CardData = content.card("B-33")
	assert_eq(membership.energy_value(), 2, "Global Gains Platinum Membership costs 2 less (it was 4)")
	assert_string_contains(membership.rules_text, "Hustle")
	assert_string_contains(membership.rules_text, "Overtime")
	assert_string_contains(membership.rules_text, "Bulldoze")
	assert_string_contains(membership.rules_text, "pay 1")
	assert_false(membership.rules_text.to_lower().contains("return"), "no return to hand")
	var cake: CardData = content.card("R-21")
	assert_eq(cake.display_name, "Let Them Eat Cake")
	assert_eq(cake.energy_value(), 2, "Let Them Eat Cake costs 1 less (it was 3)")


func test_equipment_and_items_read_in_one_order() -> void:
	var pieces: Array = content.equipment.values() + content.zone_equipment.values()
	assert_gt(pieces.size(), 80)
	for value: Variant in pieces:
		var piece: EquipmentData = value as EquipmentData
		var lines: PackedStringArray = GearText.tooltip(piece).split("\n", false)
		assert_gte(lines.size(), 3, "%s: name, kind, effect" % piece.id)
		assert_eq(lines[0], GearText.name_of(piece), "%s: the name first" % piece.id)
		assert_eq(lines[1], GearText.kind_line(piece), "%s: then the slot and the rarity" % piece.id)
		assert_string_contains(lines[1], EquipmentRarity.display_name(int(piece.rarity)))
		assert_eq(lines[2], GearText.effect(piece).split("\n", false)[0], "%s: then what it does" % piece.id)
		if not GearText.flavour(piece).is_empty():
			assert_eq(lines[lines.size() - 1], GearText.flavour(piece).split("\n", false)[-1], "%s: the flavour last" % piece.id)
			assert_false(GearText.effect(piece).contains(GearText.flavour(piece)), "%s: the flavour is not in the effect" % piece.id)
	for id: String in ["healing_salve", "scroll_of_insight"]:
		var item: ItemData = content.item(id)
		if item == null:
			continue
		var lines: PackedStringArray = GearText.item_tooltip(item).split("\n", false)
		assert_eq(lines[0], item.display_name)
		assert_eq(lines[1], GearText.item_kind_line(item))


func test_no_effect_line_opens_with_a_story_any_more() -> void:
	# the sixteen older pieces whose description began with a line of story ("A glass lens from the draining chamber... You draw...")
	var lens: EquipmentData = content.equipment_piece("siphons_lens")
	assert_true(GearText.effect(lens).begins_with("You draw"), "the lens says what it does first: %s" % GearText.effect(lens))
	assert_string_contains(GearText.flavour(lens), "glass lens")


func test_the_dye_preview_is_the_tinted_cloak_icon() -> void:
	assert_true(IconArt.has(IconArt.PLAIN_CLOAK_ICON), "ICON-COS-PLAINCLOAK is imported")
	assert_not_null(IconArt.plain_cloak_texture(256.0))
	var red: Color = IconArt.plain_cloak_tint(1)
	var natural: Color = IconArt.plain_cloak_tint(Dye.NATURAL)
	assert_ne(red, natural, "a dye tints the icon its own colour")
	var screen: TailorScreen = TailorScreen.new()
	add_child_autofree(screen)
	await get_tree().process_frame
	screen.preview_dye(1, false)
	assert_eq(screen._preview_icon.texture, IconArt.plain_cloak_texture(TailorScreen.PREVIEW_SIZE), "the preview shows the cloak icon")
	assert_eq(screen._preview_icon.modulate, red, "in the dye's colour")
	assert_true(screen._preview_icon.visible, "and not the hero's whole body")


func test_the_pantry_mimic_has_28_hp() -> void:
	var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/dungeons/dungeon_content.json")) as Dictionary
	var found: bool = false
	for key: Variant in (data["dungeons"] as Dictionary).keys():
		var foes: Variant = ((data["dungeons"] as Dictionary)[key] as Dictionary).get("foes", {})
		if not foes is Dictionary:
			continue
		for foe: Variant in (foes as Dictionary).values():
			if foe is Dictionary and str((foe as Dictionary).get("name", "")) == "The Pantry Mimic":
				found = true
				assert_eq(int((foe as Dictionary)["hp"]), 28)
	assert_true(found, "the Mimic is in the castle")


func test_keywords_of_one_path_wear_its_colour() -> void:
	var paths: Dictionary = KeywordInfo.keyword_paths(content)
	var coloured: int = 0
	var neutral: int = 0
	for keyword: Variant in paths.keys():
		if int(paths[keyword]) == int(Affinity.Type.NEUTRAL):
			neutral += 1
		else:
			coloured += 1
			# the rule itself: every one-Path card that carries it is of that Path, and no Pathless card carries it
			for card: CardData in content.all_collectible():
				if not card.keywords.has(keyword as CardEnums.Keyword) or card.paths().size() > 1:
					continue
				assert_eq(card.paths().size(), 1, "%s carries a one-Path keyword, so it is not Pathless" % card.id)
				assert_eq(int(card.paths()[0]), int(paths[keyword]), "%s is of the keyword's Path" % card.id)
			assert_ne(KeywordInfo.keyword_color(keyword as CardEnums.Keyword, content), UIStyle.GOLD)
	assert_gt(coloured, 0, "some keywords belong to one Path")
	assert_gt(neutral, 0, "and the shared ones stay neutral")
	assert_eq(KeywordInfo.keyword_color(CardEnums.Keyword.FLYING, content), UIStyle.GOLD, "Flying is on cards of several Paths")


func test_a_quest_npc_gives_the_introduction_and_the_quest_in_one_talk() -> void:
	# the split first talk (Oct 22: the introduction first, "Talk again" for the favour) is gone from the quest NPC's conversation
	var source: String = FileAccess.get_file_as_string("res://world/zone/zone_scene.gd")
	var start: int = source.find("func _talk_quest_npc(")
	var end: int = source.find("\nfunc ", start + 10)
	var body: String = source.substr(start, end - start)
	assert_false(body.contains("_hint_talk_again"), "no second talk for the favour")
	assert_true(body.contains("greeting + offer"), "the introduction and the offer are one conversation")
	assert_true(body.contains("Session.start_quest(quest.id)"), "and the quest is taken when it ends")
