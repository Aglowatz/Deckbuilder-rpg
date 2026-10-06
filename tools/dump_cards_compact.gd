extends SceneTree
## Dev helper: prints data/source/card_list.csv as one compact line per card (and its section header).


func _init() -> void:
	var file: FileAccess = FileAccess.open("res://data/source/card_list.csv", FileAccess.READ)
	var out: FileAccess = FileAccess.open("user://cards_compact.txt", FileAccess.WRITE)
	file.get_csv_line()
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() < 15:
			continue
		var id: String = row[14].strip_edges()
		if id == "":
			if row[0].strip_edges() != "" and row[2].strip_edges() == "":
				out.store_line("## SECTION " + row[0])
			continue
		var text: String = row[5].replace("\n", " / ")
		out.store_line("%s|%s|%s|%s|%s|%s|%s|%s" % [id, row[1], row[2], row[3], row[4], row[6], text, row[0]])
	out.close()
	print(ProjectSettings.globalize_path("user://cards_compact.txt"))
	quit()
