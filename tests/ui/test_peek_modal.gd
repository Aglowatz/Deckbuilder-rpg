extends GutTest
## Overnight Nov 7-8, Part 1.1: the Peek choice is a modal on its own CanvasLayer above every other layer of the battle screen (board, hand,
## tooltips, toasts, banners), with the table dimmed behind it; its Top / Bottom / Done buttons are on top and work.

var _screen: BattleScreen


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	_screen = (load("res://scenes/battle.tscn") as PackedScene).instantiate() as BattleScreen
	_screen.screenshot_prepare({"no_tutorial": "true", "no_intro": "true", "fast": "true"})
	add_child_autofree(_screen)
	await _until(func() -> bool: return _screen.mode == BattleScreen.Mode.MULLIGAN, 8.0)


func _until(condition: Callable, limit: float) -> bool:
	var waited: float = 0.0
	while waited < limit:
		if bool(condition.call()):
			return true
		await get_tree().process_frame
		waited += get_process_delta_time()
	return bool(condition.call())


func _layers(node: Node, out: Array[int]) -> void:
	for child: Node in node.get_children():
		if child is CanvasLayer and child.name != "BattlePadLayer":  # the controller's cursor ring (hidden while a modal has focus)
			out.append((child as CanvasLayer).layer)
		_layers(child, out)


func test_the_peek_sits_above_every_other_layer() -> void:
	_screen._mulligan_choice(true)
	await _until(func() -> bool: return _screen.mode == BattleScreen.Mode.MAIN and not _screen.busy, 10.0)
	_screen.game.peek_requests.append({"player": 0, "count": 1, "ctx": null, "rest": [] as Array[CardAbility.Fx]})
	_screen._show_peek()
	await get_tree().process_frame
	assert_not_null(_screen.peek_panel)
	var layer: CanvasLayer = _screen.peek_panel.get_parent() as CanvasLayer
	assert_not_null(layer, "the Peek lives on its own CanvasLayer")
	var others: Array[int] = []
	_layers(_screen, others)
	others.erase(layer.layer)
	for other: int in others:
		assert_lt(other, layer.layer, "layer %d is under the Peek" % other)
	assert_not_null(layer.get_node_or_null("PeekDim"), "the table is dimmed behind it")
	var uid: int = _screen.peek_panel.cards[0].uid
	_screen.peek_panel.pick(uid, true)
	assert_true(_screen.peek_panel.is_complete(), "Top answers the one-card Peek")
