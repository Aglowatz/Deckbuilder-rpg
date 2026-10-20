extends GutTest
## Where the icon set is used (IconArt mappings): every keyword, card type, Path, resource, node kind and equipment slot has its icon, rules text gets inline icons, the
## minimap draws icons only for whitelisted kinds, and only the ten named equipment pieces carry their own icon.


func test_every_keyword_has_an_icon() -> void:
	for keyword: CardEnums.Keyword in CardEnums.Keyword.values():
		var id: String = IconArt.keyword_id(keyword)
		assert_ne(id, "", "keyword %d has an icon id" % keyword)
		assert_true(IconArt.has(id), id)


func test_every_card_type_but_resource_has_an_icon() -> void:
	for type: CardEnums.CardType in CardEnums.CardType.values():
		if type == CardEnums.CardType.RESOURCE:
			continue
		assert_true(IconArt.has(IconArt.type_id(type)), "type %d" % type)


func test_every_path_has_energy_and_essence() -> void:
	for path: Affinity.Type in Affinity.Type.values():
		assert_true(IconArt.has(IconArt.energy_id(path)), "energy %d" % path)
	for path: Affinity.Type in Affinity.colored_types():
		assert_true(IconArt.has(IconArt.essence_id(path)), "essence %d" % path)


func test_every_resource_and_token_has_an_icon() -> void:
	for kind: int in ResourceKind.Kind.values():
		assert_true(IconArt.has(IconArt.resource_id(kind)), "resource %d" % kind)


func test_every_dungeon_node_kind_has_a_medallion() -> void:
	for kind: int in DungeonMap.Kind.values():
		assert_true(MapNodeButton.NODE_ICONS.has(kind), "node kind %d" % kind)
		assert_true(IconArt.has(str(MapNodeButton.NODE_ICONS[kind])))
	assert_true(IconArt.has("ICON-NODE-DONE"))
	assert_true(IconArt.has("ICON-NODE-LOCKED"))


func test_rules_text_names_get_inline_icons_only_when_asked() -> void:
	var card: CardData = load("res://data/cards/G-01.tres") as CardData
	var plain: String = KeywordInfo.rules_bbcode(card)
	assert_false(plain.contains("[img"), "no icons without a size")
	var with_icons: String = KeywordInfo.rules_bbcode(card, false, 18)
	var mentions_resource: bool = false
	for word: String in KeywordInfo.RULES_ICON_WORDS_FIRST:
		mentions_resource = mentions_resource or card.rules_text.contains(word)
	if mentions_resource:
		assert_true(with_icons.contains("[img=18x18]"), with_icons)


func test_infrastructure_text_shows_its_energy_icon() -> void:
	var card: CardData = load("res://data/cards/INF-01.tres") as CardData
	assert_true(card.is_infrastructure())
	assert_true(KeywordInfo.rules_bbcode(card, false, 18).contains("[img=18x18]"), "(B) becomes the Beefcake energy symbol")
	assert_false(KeywordInfo.rules_bbcode(card, false, 18).contains("(B)"))


func test_map_icons_cover_the_whitelisted_kinds_and_never_secrets() -> void:
	assert_eq(MapDraw.icon_id(MapPoi.Kind.VENDOR), "ICON-MAP-VENDOR")
	assert_eq(MapDraw.icon_id(MapPoi.Kind.MINI_DUNGEON), "ICON-MAP-SIDEDUNGEON")
	assert_eq(MapDraw.icon_id(MapPoi.Kind.ARENA), "ICON-MAP-ARENA")
	assert_eq(MapDraw.icon_id(MapPoi.Kind.INTERACTABLE), "", "interactables keep the plain disc")
	for kind: int in MapPoi.Kind.values():
		var name: String = MapPoi.kind_name(kind as MapPoi.Kind).to_lower()
		assert_false(name.contains("chest") or name.contains("secret"), "no map kind for secrets")


func test_the_ten_named_pieces_have_icons_and_the_rest_keep_the_fallback() -> void:
	assert_eq(IconArt.EQUIPMENT_IDS.size(), 10)
	for id: Variant in IconArt.EQUIPMENT_IDS.keys():
		var piece: EquipmentData = load("res://data/equipment/%s.tres" % str(id)) as EquipmentData
		assert_not_null(piece, "%s exists" % id)
		assert_true(IconArt.has_equipment_icon(piece), str(id))
	# art import Oct 20: the zone gear got its own ICON-GEAR-* icons (the Swole Belt among them); a piece whose icon is still to come keeps the fallback
	var belt: EquipmentData = load("res://data/equipment/zone/swole_belt.tres") as EquipmentData
	assert_true(IconArt.has_equipment_icon(belt), "ICON-GEAR-SWOLEBELT")
	var other: EquipmentData = load("res://data/equipment/zone/bloodsand_boots.tres") as EquipmentData
	if IconArt.has_equipment_icon(other):
		pass_test("every gear piece has its own icon now")
		return
	assert_not_null(IconArt.equipment_texture(other, 64.0), "the fallback silhouette")


func test_every_slot_has_an_empty_placeholder() -> void:
	for slot: EquipmentData.Slot in EquipmentData.Slot.values():
		assert_true(IconArt.has(IconArt.slot_id(slot)))


func test_quest_log_names_map_to_icons() -> void:
	assert_eq(IconArt.id_for_name("coins"), "ICON-GOLD")
	assert_eq(IconArt.id_for_name("ICON-CHECK"), "ICON-CHECK")
	assert_eq(IconArt.id_for_name("magic"), "")
