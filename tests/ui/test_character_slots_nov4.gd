extends GutTest
## Fix pass Nov 4 (Part 3.2): the Character page's equipment slots sit on the silhouette - helm over the head, armor mid-chest, weapon
## and relic on the hands, boots between the feet - computed from the poster rect, and they never cover each other's captions.

const CAPTION_HEIGHT: float = 34.0


func test_slots_follow_the_poster_rect() -> void:
	for slot: EquipmentData.Slot in CharacterScreen.SLOT_ORDER:
		var expected: Vector2 = CharacterScreen.POSTER_POS + (CharacterScreen.SILHOUETTE_POINTS[slot] as Vector2) * CharacterScreen.POSTER_SCALE
		assert_eq(CharacterScreen.equip_center(slot), expected)
	var helm: Vector2 = CharacterScreen.equip_center(EquipmentData.Slot.HELM)
	var armor: Vector2 = CharacterScreen.equip_center(EquipmentData.Slot.ARMOR)
	var boots: Vector2 = CharacterScreen.equip_center(EquipmentData.Slot.BOOTS)
	assert_almost_eq(helm.x, armor.x, 0.5, "helm and armor on the body's centre line")
	assert_almost_eq(helm.x, boots.x, 0.5, "boots too")
	var weapon: Vector2 = CharacterScreen.equip_center(EquipmentData.Slot.WEAPON)
	var relic: Vector2 = CharacterScreen.equip_center(EquipmentData.Slot.RELIC)
	assert_almost_eq(weapon.y, relic.y, 0.5, "the two hands at one height")
	assert_almost_eq(helm.x - weapon.x, relic.x - helm.x, 3.0, "the hands mirror each other around the body")


func test_slots_and_captions_do_not_overlap() -> void:
	var rects: Array[Rect2] = []
	for slot: EquipmentData.Slot in CharacterScreen.SLOT_ORDER:
		var size: Vector2 = Vector2(CharacterScreen.SLOT_SIZE, CharacterScreen.SLOT_SIZE + CAPTION_HEIGHT)
		rects.append(Rect2(CharacterScreen.equip_center(slot) - Vector2(CharacterScreen.SLOT_SIZE, CharacterScreen.SLOT_SIZE) * 0.5, size))
	for i: int in rects.size():
		for j: int in range(i + 1, rects.size()):
			assert_false(rects[i].intersects(rects[j]), "slot %d and %d overlap" % [i, j])
	var poster: Rect2 = Rect2(CharacterScreen.POSTER_POS, CharacterScreen.POSTER_REGION.size * CharacterScreen.POSTER_SCALE)
	for rect: Rect2 in rects:
		assert_true(poster.encloses(rect), "every slot and caption stays on the poster")
