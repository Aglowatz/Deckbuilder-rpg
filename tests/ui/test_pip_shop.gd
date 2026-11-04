extends GutTest
## Overnight Nov 3-4, Part D: Pip's shop - Preview shows the item alone (no hero sprite), an owned item's button is Equip / Equipped, "No hat"
## takes the hat off, and the plain cloak's dye follows its painted mask on every frame (the hue guess is gone).


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.profile.level = 5
	Session.gold = 5000


func _shop() -> TailorScreen:
	var screen: TailorScreen = TailorScreen.new()
	add_child_autofree(screen)
	await wait_frames(3)
	return screen


func _first_hat() -> CosmeticData:
	for item: CosmeticData in CosmeticCatalog.all():
		if item.slot == CosmeticData.Slot.HAT and item.is_for_sale() and SpriteCosmetics.art_ready(item) and Condition.met(item.unlock, Session.unlock_state()):
			return item
	return null


func test_preview_is_the_item_alone() -> void:
	var screen: TailorScreen = await _shop()
	assert_eq(screen.find_children("*", "HeroPreview", true, false).size(), 0, "no hero sprite in the shop")
	var hat: CosmeticData = _first_hat()
	var button: Button = screen.find_child("Preview_%s" % hat.id, true, false) as Button
	assert_not_null(button, "Try is Preview")
	assert_null(screen.find_child("Try_%s" % hat.id, true, false))
	button.pressed.emit()
	await wait_frames(2)
	assert_eq(screen.previewed(), hat)
	var icon: TextureRect = screen.find_child("PreviewIcon", true, false) as TextureRect
	assert_not_null(icon.texture, "the hat, large")
	assert_gte(icon.custom_minimum_size.x, 300.0)
	assert_eq((screen.find_child("PreviewName", true, false) as Label).text, hat.display_name)
	assert_true(Session.cosmetics.hat_id.is_empty(), "previewing wears nothing")


func test_owned_items_equip_and_no_hat_takes_it_off() -> void:
	var hat: CosmeticData = _first_hat()
	var screen: TailorScreen = await _shop()
	var buy: Button = screen.find_child("Buy_%s" % hat.id, true, false) as Button
	assert_eq(buy.text, "Buy")
	buy.pressed.emit()
	await wait_frames(2)
	assert_true(Session.cosmetics.owns(hat.id))
	assert_eq(Session.cosmetics.hat_id, hat.id, "bought and worn")
	assert_eq(buy.text, "Equipped")
	assert_true(buy.disabled)
	var none: Button = screen.find_child("Equip_none_hat", true, false) as Button
	assert_not_null(none, "a No hat entry")
	none.pressed.emit()
	await wait_frames(2)
	assert_eq(Session.cosmetics.hat_id, "", "the hat comes off")
	assert_eq(buy.text, "Equip", "owned, not worn: Equip")
	assert_eq(none.text, "Equipped")
	buy.pressed.emit()
	await wait_frames(2)
	assert_eq(Session.cosmetics.hat_id, hat.id, "Equip puts it back on without paying again")


func test_every_hero_frame_has_a_cloak_dye_mask() -> void:
	var frames: Array = SpriteLibrary.info("PLAYER")["frames"] as Array
	var walking: int = 0
	for key: Variant in frames:
		var name_text: String = str(key)
		if name_text.ends_with("_TALK"):
			continue
		walking += 1
		assert_not_null(SpriteLibrary.dye_mask("PLAYER", name_text), "%s has its mask" % name_text)
	assert_gte(walking, 25, "five directions, idle and four walk frames")


func test_the_dye_uses_the_mask() -> void:
	var camera: Camera3D = Camera3D.new()
	add_child_autofree(camera)
	var sprite: WorldSprite = WorldSprite.new()
	add_child_autofree(sprite)
	assert_true(sprite.setup("PLAYER", camera))
	sprite.set_dye(Dye.primary(0), 1.0)
	sprite.follow(Vector3.ZERO, 0.016)
	var material: ShaderMaterial = sprite._material
	assert_true(bool(material.get_shader_parameter("use_dye_mask")), "the cloak's own mask, not a hue guess")
	assert_not_null(material.get_shader_parameter("dye_mask"))
	sprite.set_dye(Color.WHITE, 0.0)
	assert_false(bool(material.get_shader_parameter("use_dye_mask")), "no dye, no mask")
