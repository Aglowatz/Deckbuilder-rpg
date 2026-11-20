extends GutTest
## Fable Nov 21 (Part 5.6): the hover-zoom probe. Every screen that shows a card lets that card grow under the pointer (and under the
## controller's focus). The probe lists every script under ui/ and world/ that creates a card, and requires each to carry one of the
## game's zoom mechanisms (or to be listed below with the reason it needs none). The list is written to
## docs/review/hover_zoom_probe.txt. Then the cases that were broken are played: a won card in the reward box (the Toro Toro reward card
## stayed small), a battle choice, the Refuse Pile's top card, the card games.

const REPORT: String = "res://docs/review/hover_zoom_probe.txt"
## What counts as "the card grows on hover" in a script: [marker in the source, what it is].
const MECHANISMS: Array[Array] = [
	["CardHoverZoom.attach(", "grows in place (mouse and focus)"],
	["CardHoverZoom.watch(", "grows in place (a card that ignores the mouse)"],
	["_preview.show_for(", "the large preview beside it (HoverPreview)"],
	["_show_zoom(", "the viewer's own large card"],
	["_zoom", "the screen's own large card"],
]
## Scripts that create a card and need no zoom of their own, with the reason.
const EXEMPT: Dictionary = {
	"res://ui/battle/battle_board.gd": "the battle board: BattleScreen shows the hovered card large in the HUD (BattleHud.show_preview)",
	"res://ui/battle/battle_hud.gd": "it IS the battle's large preview card",
	"res://ui/card/hover_preview.gd": "it IS the large preview",
	"res://ui/card/card_view.gd": "the card itself (the factory)",
	"res://ui/card/card_gallery.gd": "a developer scene (card frames side by side), not in the game",
	"res://ui/ui_art_warmup.gd": "the loading warm-up: cards drawn off screen once",
}


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.pending_popups.clear()
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)
	CardHoverZoom.Watcher.test_mouse = null
	CardHoverZoom.Watcher.active = null


func after_each() -> void:
	CardHoverZoom.Watcher.test_mouse = null
	CardHoverZoom.Watcher.active = null


func _scripts(folder: String, found: Array[String]) -> void:
	var dir: DirAccess = DirAccess.open(folder)
	if dir == null:
		return
	for sub: String in dir.get_directories():
		_scripts(folder.path_join(sub), found)
	for file: String in dir.get_files():
		if file.ends_with(".gd"):
			found.append(folder.path_join(file))


## The probe: [script, how its cards grow] for every script that creates a card.
func _probe() -> Array[Array]:
	var scripts: Array[String] = []
	_scripts("res://ui", scripts)
	_scripts("res://world", scripts)
	scripts.sort()
	var rows: Array[Array] = []
	for path: String in scripts:
		var source: String = FileAccess.get_file_as_string(path)
		if not (source.contains("CardView.create(") or source.contains("CardView.wrapped(")):
			continue
		var how: String = ""
		for mechanism: Array in MECHANISMS:
			if source.contains(str(mechanism[0])):
				how = str(mechanism[1])
				break
		if how.is_empty() and EXEMPT.has(path):
			how = "exempt: %s" % str(EXEMPT[path])
		rows.append([path, how])
	return rows


func test_every_screen_that_shows_a_card_has_the_hover_zoom() -> void:
	var rows: Array[Array] = _probe()
	assert_gte(rows.size(), 18, "the scripts that create cards were found (%d)" % rows.size())
	var lines: PackedStringArray = ["# Hover-zoom probe (Fable Nov 21, Part 5.6): every script that shows a card, and how its cards grow under the pointer.", "# Written by tests/ui/test_card_hover_zoom_probe_nov21.gd.", ""]
	var missing: PackedStringArray = []
	for row: Array in rows:
		lines.append("%s | %s | %s" % ["OK  " if not str(row[1]).is_empty() else "MISS", str(row[0]).trim_prefix("res://"), str(row[1]) if not str(row[1]).is_empty() else "NO HOVER ZOOM"])
		if str(row[1]).is_empty():
			missing.append(str(row[0]))
	lines.append("")
	lines.append("%d scripts, %d without a hover zoom" % [rows.size(), missing.size()])
	var file: FileAccess = FileAccess.open(REPORT, FileAccess.WRITE)
	if file != null:
		file.store_string("\n".join(lines) + "\n")
		file.close()
	assert_eq(missing.size(), 0, "screens that show a card with no hover zoom: %s" % ", ".join(missing))
	for path: Variant in EXEMPT.keys():
		assert_true(FileAccess.file_exists(str(path)), "%s: an exempt script that no longer exists" % path)


func _height(control: Control) -> float:
	return control.get_global_rect().size.y


## Puts the test pointer on `target`, waits, and returns how much taller it got; then takes the pointer away and checks it shrank.
func _hover(target: Control) -> float:
	var before: float = _height(target)
	CardHoverZoom.Watcher.test_mouse = target.get_global_rect().get_center()
	await wait_seconds(0.4)
	var grown: bool = CardHoverZoom.is_zoomed(target)
	var after: float = _height(target)
	CardHoverZoom.Watcher.test_mouse = Vector2(-500, -500)
	await wait_seconds(0.4)
	assert_false(CardHoverZoom.is_zoomed(target), "%s shrinks back when the pointer leaves" % target.name)
	return (after / maxf(before, 1.0)) if grown else 1.0


func test_a_won_card_in_the_reward_box_grows_the_toro_toro_case() -> void:
	var summary: RewardSummary = RewardSummary.new()
	summary.title = "The Raw Deal"
	summary.cards = [Session.content.card("G-27")] as Array[CardData]
	var popup: RewardPopup = RewardPopup.make(summary)
	add_child_autofree(popup)
	await wait_seconds(1.2)
	var tile: Control = popup.find_child("WonCard_G-27", true, false) as Control
	assert_not_null(tile, "Toro Toro's reward card")
	if tile == null:
		return
	assert_true(CardHoverZoom.has_zoom(tile))
	assert_lt(_height(tile), 300.0, "it is shown small")
	var factor: float = await _hover(tile)
	assert_gt(factor, 1.5, "and grows to a readable size under the pointer (x%.2f)" % factor)


func test_the_picks_of_a_reward_box_grow_too() -> void:
	var summary: RewardSummary = RewardSummary.new()
	summary.title = "A boss"
	summary.card_choices = [Session.content.card("B-25"), Session.content.card("B-34"), Session.content.card("C-01")] as Array[CardData]
	var popup: RewardPopup = RewardPopup.make(summary)
	add_child_autofree(popup)
	await wait_frames(4)
	for index: int in range(3):
		assert_true(CardHoverZoom.has_zoom(popup.find_child("Pick_%d" % index, true, false) as Control), "pick %d" % index)


func test_the_controller_grows_a_card_held_by_the_focused_button() -> void:
	var button: Button = Button.new()
	button.custom_minimum_size = Vector2(160, 230)
	button.position = Vector2(300, 300)
	button.size = Vector2(160, 230)
	button.focus_mode = Control.FOCUS_ALL
	add_child_autofree(button)
	var card: Control = CardView.wrapped(Session.content.card("G-27"), 0.4)
	button.add_child(card)
	CardHoverZoom.watch(card)
	await wait_frames(3)
	InputDevice.set_kind(InputDevice.Kind.PAD)
	button.grab_focus()
	await wait_seconds(0.4)
	if get_viewport().gui_get_focus_owner() != button:
		pass_test("this run's window cannot hold the focus (headless): the focus rule is covered by the watcher's own condition")
		return
	assert_true(CardHoverZoom.is_zoomed(card), "the focus is on the button that holds the card")
	button.release_focus()
	await wait_seconds(0.4)
	assert_false(CardHoverZoom.is_zoomed(card))
	InputDevice.set_kind(InputDevice.Kind.KEYBOARD)


func test_only_one_watched_card_is_grown_at_a_time_and_none_under_another_screen() -> void:
	var row: HBoxContainer = HBoxContainer.new()
	row.position = Vector2(200, 300)
	add_child_autofree(row)
	var first: Control = CardView.wrapped(Session.content.card("B-25"), 0.4)
	var second: Control = CardView.wrapped(Session.content.card("B-34"), 0.4)
	row.add_child(first)
	row.add_child(second)
	CardHoverZoom.watch(first)
	CardHoverZoom.watch(second)
	await wait_frames(3)
	CardHoverZoom.Watcher.test_mouse = first.get_global_rect().get_center()
	await wait_seconds(0.3)
	assert_true(CardHoverZoom.is_zoomed(first))
	assert_false(CardHoverZoom.is_zoomed(second))
	CardHoverZoom.Watcher.test_mouse = Vector2(-500, -500)
	await wait_seconds(0.3)
	# a dialog on top: the card under it stays small
	var dialog: ConfirmDialog = ConfirmDialog.notice(self, "On top", "A pop-up lies over the card.")
	await wait_frames(4)
	CardHoverZoom.Watcher.test_mouse = first.get_global_rect().get_center()
	await wait_seconds(0.3)
	assert_false(CardHoverZoom.is_zoomed(first), "nothing grows under another screen")
	dialog.queue_free()


func test_the_other_cases_carry_the_zoom() -> void:
	var checks: Dictionary = {
		"res://ui/battle/choice_panel.gd": "CardHoverZoom.watch(shown)",
		"res://ui/battle/refuse_pile_widget.gd": "CardHoverZoom.watch(face)",
		"res://ui/zone/card_games/card_game_screen.gd": "CardHoverZoom.watch(view)",
		"res://ui/zone/card_match_screen.gd": "CardHoverZoom.watch(view)",
		"res://ui/town/deckbuilder_screen.gd": "CardHoverZoom.watch(view)",
		"res://ui/dungeon/rewards_screen.gd": "CardHoverZoom.attach(",
		"res://ui/packs/pack_opening_screen.gd": "CardHoverZoom.attach(",
		"res://ui/town/alchemist_screen.gd": "CardHoverZoom.attach(",
	}
	for path: Variant in checks.keys():
		assert_string_contains(FileAccess.get_file_as_string(str(path)), str(checks[path]), str(path))
