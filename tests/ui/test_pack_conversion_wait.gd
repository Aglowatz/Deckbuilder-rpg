extends GutTest
## Overnight Nov 3-4, Part A1: a pack with duplicates. The "extra copies became essence" notices (the toasts and each card's
## "Extra copy" label) wait until every card in the pack has been revealed.

const A: Affinity.Type = Affinity.Type.BEEFCAKE

var _host: Control


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(A)
	Session.profile.level = 1
	# Own every card up to its cap: whatever the pack rolls is an extra copy.
	for card: Variant in Session.content.cards.values():
		var data: CardData = card as CardData
		if data == null or data.is_unlimited():
			continue
		while not Session.at_copy_cap(data):
			Session.add_cards([data] as Array[CardData])
	_host = Control.new()
	add_child_autofree(_host)


func after_each() -> void:
	while Session.toasts != null and Session.toasts.is_held():
		Session.toasts.release()


func _conversion_labels(screen: PackOpeningScreen) -> Array[Control]:
	var labels: Array[Control] = []
	for holder: Control in screen._holders:
		var label: Control = holder.get_node_or_null(^"Conversion") as Control
		if label != null:
			labels.append(label)
	return labels


func test_conversion_notices_wait_for_the_last_card() -> void:
	Session.add_pack(PackCatalog.path_pack(A).id)
	assert_true(PackOpeningScreen.open_from_inventory(_host, PackCatalog.path_pack(A).id))
	var screen: PackOpeningScreen = _host.get_node(^"PackOpeningScreen") as PackOpeningScreen
	assert_gt(screen.opening.converted_count(), 0, "the pack has duplicates")
	assert_true(Session.toasts.is_held(), "the essence toasts wait while the pack is shut")
	screen._tear()
	await wait_until(func() -> bool: return screen._phase == PackOpeningScreen.Phase.REVEAL and not screen._busy, 8.0)
	# Reveal all but the last card: nothing is announced yet.
	while screen._next < screen._holders.size() - 1:
		screen._reveal_next()
		await wait_until(func() -> bool: return not screen._busy, 5.0)
	assert_true(Session.toasts.is_held(), "still held with one card face down")
	for label: Control in _conversion_labels(screen):
		assert_false(label.visible, "an Extra copy label stays hidden until every card is up")
	screen._advance()  # the last card
	assert_true(screen._busy)
	screen._advance()  # a click during the last flip must not jump to the summary
	assert_eq(screen._phase, PackOpeningScreen.Phase.REVEAL)
	await wait_until(func() -> bool: return not screen._busy, 5.0)
	assert_false(Session.toasts.is_held(), "the toasts show once the last card is revealed")
	var labels: Array[Control] = _conversion_labels(screen)
	assert_false(labels.is_empty())
	for label: Control in labels:
		assert_true(label.visible)


func test_closing_early_releases_the_toasts() -> void:
	Session.add_pack(PackCatalog.path_pack(A).id)
	PackOpeningScreen.open_from_inventory(_host, PackCatalog.path_pack(A).id)
	var screen: PackOpeningScreen = _host.get_node(^"PackOpeningScreen") as PackOpeningScreen
	assert_true(Session.toasts.is_held())
	screen.free()
	assert_false(Session.toasts.is_held(), "a screen that goes away never leaves the toast layer hidden")
