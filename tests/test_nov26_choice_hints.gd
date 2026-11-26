extends GutTest
## Nov 26 day (Part D1): no event choice runs past the edge of its panel. A choice too long for one line wraps inside its button
## (EventScreen.fit_choice), and no choice needs more than three lines at the panel's width (long hints were shortened).

const BUTTON_WIDTH: float = 980.0 - 130.0  # EventScreen: the card is 980 wide, a choice button 130 less
const MAX_LINES: int = 3  # the button wraps (EventScreen.fit_choice); three lines still sit inside the panel


func _keys() -> Array[String]:
	var result: Array[String] = ["beefcake", "gourmand", "necrocrat", "refusemancer", "final"]
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		if blueprint.id == DungeonCatalog.TUTORIAL_ID or blueprint.type == DungeonCatalog.TYPE_MAIN or blueprint.type == DungeonCatalog.TYPE_FINAL:
			continue
		result.append(blueprint.id)
	return result


func _font() -> Array:
	var probe: FancyButton = FancyButton.make("x")
	add_child_autofree(probe)
	return [probe.get_theme_font(&"font"), probe.get_theme_font_size(&"font_size")]


func test_no_choice_needs_more_than_three_lines() -> void:
	var measure: Array = _font()
	var font: Font = measure[0] as Font
	var font_size: int = int(measure[1])
	assert_not_null(font)
	var checked: int = 0
	var too_long: PackedStringArray = []
	for key: String in _keys():
		var dungeon: MainDungeonDef = MainDungeons.def(key)
		if dungeon == null:
			continue
		var story: ZoneStoryText = ZoneStoryText.for_zone(dungeon.zone_id)
		for event_id: Variant in dungeon.events.keys():
			var event: DungeonEvent = dungeon.events[event_id] as DungeonEvent
			for index: int in range(event.choices.size()):
				var hint: String = event.choices[index].hint()
				var text: String = "%s%s" % [story.text(event.choice_key(index)), ("   (%s)" % hint) if not hint.is_empty() else ""]
				var width: float = EventScreen.choice_width(text, font, font_size, event.choices[index].gold_cost() > 0)
				checked += 1
				# the words wrap at the button's inner width; allow a little slack for word breaks
				var lines: int = int(ceil(width / ((BUTTON_WIDTH - EventScreen.CHOICE_PADDING) * 0.92)))
				if lines > MAX_LINES:
					too_long.append("%s %s choice %d (%d px): %s" % [key, str(event_id), index, int(width), text])
	assert_gt(checked, 100, "every dungeon's event choices")
	assert_eq(too_long, PackedStringArray(), "\n".join(too_long))


func test_a_long_choice_wraps_inside_its_button() -> void:
	var button: FancyButton = FancyButton.make("Compare the handwriting on the order slips with the head chef's own recipe cards   (a check of your Gourmand units: a boon for the kitchen, or lose HP)", &"", Vector2(BUTTON_WIDTH, 60))
	add_child_autofree(button)
	EventScreen.fit_choice(button)
	assert_ne(button.autowrap_mode, TextServer.AUTOWRAP_OFF, "the long choice wraps")
	await wait_frames(2)
	assert_lte(button.size.x, BUTTON_WIDTH + 1.0, "and stays as wide as the panel allows")
	var short: FancyButton = FancyButton.make("Leave it   (nothing)", &"", Vector2(BUTTON_WIDTH, 60))
	add_child_autofree(short)
	EventScreen.fit_choice(short)
	assert_eq(short.autowrap_mode, TextServer.AUTOWRAP_OFF, "a short one stays on one line")
