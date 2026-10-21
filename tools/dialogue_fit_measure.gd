extends RefCounted
## Oct 21 (ChatGPT dialogue pass): measures candidate lines in the real dialogue box. Reads res://_logs/dialogue_fit_in.json ([{id, text}]),
## writes res://_logs/dialogue_fit_out.json ({id: [lines at default size, lines at the largest]}), the same measurement as
## tests/test_dialogue_fit.gd (tokens filled first). Run through tools/dialogue_fit_check.gd.

const IN_PATH: String = "res://_logs/dialogue_fit_in.json"
const OUT_PATH: String = "res://_logs/dialogue_fit_out.json"


func run(root: Window) -> void:
	var box: DialogueBox = DialogueBox.new()
	root.add_child(box)
	var rows: Variant = JSON.parse_string(FileAccess.get_file_as_string(IN_PATH))
	var result: Dictionary = {}
	if rows is Array:
		for row: Variant in rows as Array:
			var text: String = Villain.fill(str((row as Dictionary).get("text", "")))
			result[str((row as Dictionary).get("id", ""))] = [box.wrapped_lines(text, 1.0), box.wrapped_lines(text, 1.4)]
	var file: FileAccess = FileAccess.open(OUT_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(result))
	file.close()
	print("dialogue_fit_check: %d lines measured" % result.size())
	box.queue_free()
