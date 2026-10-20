extends GutTest
## Overnight Oct 19-20: GearCatalog - every equipment piece once, in slot order, and the "where it comes from" hints (secrets not spoiled).


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_every_piece_once_in_slot_order() -> void:
	var pieces: Array[EquipmentData] = GearCatalog.all_pieces(Session.content)
	var ids: Array[String] = []
	for piece: EquipmentData in pieces:
		assert_false(ids.has(piece.id), "%s listed once" % piece.id)
		ids.append(piece.id)
	for pool: Dictionary in [Session.content.equipment, Session.content.zone_equipment]:
		for key: Variant in pool.keys():
			assert_true(ids.has((pool[key] as EquipmentData).id), "%s is listed" % str(key))
	for id: String in [OldWellQuest.REWARD_EQUIPMENT_ID, VaultGuardian.REWARD_EQUIPMENT_ID, PathologyLab.REWARD_EQUIPMENT_ID, EquipmentRarity.STARTER_BLADE, "wicked_dagger", "champions_laurels"]:
		assert_true(ids.has(id), id)
	var last: int = -1
	for piece: EquipmentData in pieces:
		var order: int = GearCatalog.SLOT_ORDER.find(piece.slot)
		assert_true(order >= last, "%s is in slot order" % piece.id)
		last = order
	assert_eq(GearCatalog.SLOT_ORDER[0], EquipmentData.Slot.HELM)
	assert_eq(GearCatalog.SLOT_ORDER[4], EquipmentData.Slot.RELIC)


func test_secret_pieces_are_not_spoiled() -> void:
	var quests: Array[QuestData] = QuestCatalog.all()
	for id: String in GearCatalog.secret_piece_ids():
		var piece: EquipmentData = Session.content.equipment_piece(id)
		assert_not_null(piece, id)
		assert_eq(GearCatalog.source_hint(piece, Session.content, quests), GearCatalog.SECRET_HINT, id)


func test_known_sources() -> void:
	var quests: Array[QuestData] = QuestCatalog.all()
	var content: ContentSet = Session.content
	assert_eq(GearCatalog.source_hint(content.equipment_piece("wicked_dagger"), content, quests), GearCatalog.VENDOR_HINT)
	assert_eq(GearCatalog.source_hint(content.equipment_piece("cardboard_cuirass"), content, quests), str(ExpansionGear.SOURCES["cardboard_cuirass"]))
	assert_true(GearCatalog.source_hint(content.equipment_piece("compliance_clipboard"), content, quests).begins_with("Quest: "))
	assert_eq(GearCatalog.source_hint(content.equipment_piece("champions_laurels"), content, quests), GearCatalog.ARENA_HINT)
	assert_ne(GearCatalog.source_hint(content.equipment_piece("swole_belt"), content, quests), GearCatalog.UNKNOWN_HINT)
	var stray: EquipmentData = EquipmentData.new()
	stray.id = "nowhere_hat"
	assert_eq(GearCatalog.source_hint(stray, content, quests), GearCatalog.UNKNOWN_HINT)
	for piece: EquipmentData in GearCatalog.all_pieces(content):
		assert_false(GearCatalog.source_hint(piece, content, quests).is_empty(), piece.id)


func test_progress_counts_owned_ids() -> void:
	var pieces: Array[EquipmentData] = GearCatalog.all_pieces(Session.content)
	assert_eq(GearCatalog.progress(pieces, [] as Array[String]), Vector2i(0, pieces.size()))
	assert_eq(GearCatalog.progress(pieces, ["wicked_dagger", "not_a_piece"] as Array[String]), Vector2i(1, pieces.size()))
	assert_eq(GearCatalog.of_slot(pieces, EquipmentData.Slot.WEAPON).filter(func(p: EquipmentData) -> bool: return p.slot != EquipmentData.Slot.WEAPON).size(), 0)
