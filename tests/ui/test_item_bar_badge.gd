extends GutTest
## Overnight Nov 3-4, Part A2: the battle item slot shows its icon unobstructed and the charge count as a small badge in the
## bottom-right corner (it used to stretch into a dark bar across the icon).


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_badge_sits_in_the_bottom_right_corner_for_every_item() -> void:
	for item_id: Variant in Session.content.items.keys():
		var item: ItemData = Session.content.item(str(item_id))
		Session.profile.equipped_item_ids.clear()
		Session.add_item(item)
		assert_true(Session.profile.equip_item_id(item), str(item_id))
		var bar: ItemBar = ItemBar.new()
		add_child_autofree(bar)
		bar.setup(null, Session.profile)
		await get_tree().process_frame
		var badge: Label = bar._badges[0]
		var icon: TextureRect = bar._icons[0]
		assert_true(badge.visible, str(item_id))
		assert_eq(badge.text, "x%d" % Session.profile.item_uses_left(item))
		assert_lte(badge.size.x, ItemBar.SLOT_SIZE.x * 0.5, "a small badge, not a bar")
		assert_lte(badge.size.y, ItemBar.SLOT_SIZE.y * 0.35)
		assert_gte(badge.position.x, ItemBar.SLOT_SIZE.x * 0.5, "right half")
		assert_gte(badge.position.y, ItemBar.SLOT_SIZE.y * 0.6, "bottom")
		assert_true(icon.texture != null, "%s has an icon" % item_id)
		assert_gt(icon.size.x, ItemBar.SLOT_SIZE.x * 0.6, "the icon keeps its size")
		assert_gt(badge.get_theme_constant(&"outline_size"), 0, "outlined text")
		Session.profile.unequip_item_id(item)
