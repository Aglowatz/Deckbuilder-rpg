extends SceneTree
## One-off: writes the D.N.A.'s story text (the defaults baked into ZoneStoryText) into
## data/story/dna_story.tres so all zone story text lives in data files.

func _initialize() -> void:
	var story: ZoneStoryText = ZoneStoryText.new()
	var out: String = "[gd_resource type=\"Resource\" script_class=\"ZoneStoryText\" format=3]\n\n"
	out += "[ext_resource type=\"Script\" path=\"res://core/data/zone_story_text.gd\" id=\"1_dna\"]\n\n[resource]\nscript = ExtResource(\"1_dna\")\n"
	out += "lines = " + var_to_str(story.lines) + "\n"
	out += "quiz_questions = " + var_to_str(story.quiz_questions) + "\n"
	var file: FileAccess = FileAccess.open("res://data/story/dna_story.tres", FileAccess.WRITE)
	file.store_string(out)
	file.close()
	print("wrote dna_story.tres")
	quit(0)
