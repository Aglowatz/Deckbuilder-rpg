extends GutTest
## Oct 20, Part 2: the Rescuer's opening conversation carries the requested beats - the Wanderer asks "...Who are you?", the question
## "Tell me: which Path resonates the strongest within you?", the cave leads to town where someone waits, the pursuers are close and the
## Rescuer draws them away so the Wanderer goes on alone; no line about carrying only one Path.


func _joined(key: String) -> String:
	return " ".join(StoryText.shared().get_lines(key))


func test_the_wanderer_asks_who_the_rescuer_is() -> void:
	assert_string_contains(_joined("prologue.wanderer.1"), "...Who are you?")


func test_the_path_question_is_asked_word_for_word() -> void:
	assert_string_contains(_joined("prologue.rescuer.3"), "Tell me: which Path resonates the strongest within you?")


func test_the_send_off_names_the_cave_the_town_the_pursuers_and_going_alone() -> void:
	var text: String = _joined("prologue.rescuer.4")
	assert_string_contains(text, "Forgotten Cave")
	assert_string_contains(text, "waiting for you")
	assert_string_contains(text, "draw them off")
	assert_string_contains(text, "alone")


func test_no_line_says_the_wanderer_can_carry_only_one_path() -> void:
	for key: String in ["prologue.rescuer.1", "prologue.rescuer.2", "prologue.rescuer.3", "prologue.rescuer.4"]:
		var text: String = _joined(key).to_lower()
		assert_false(text.contains("only one path") or text.contains("carry only") or text.contains("one will have to do") or text.contains("carry one"), "%s: %s" % [key, text])


func test_every_box_stays_short() -> void:
	for key: String in ["prologue.rescuer.1", "prologue.wanderer.1", "prologue.rescuer.2", "prologue.wanderer.2", "prologue.rescuer.3", "prologue.rescuer.4", "prologue.wanderer.3"]:
		for line: String in StoryText.shared().get_lines(key):
			assert_lt(line.length(), 160, "%s: %s" % [key, line])
