extends Node
## Writes QuestDefinitions to data/quests/*.tres from inside the project (autoloads available), because the SceneTree-script
## version (`tools/generate_quests.gd`) cannot compile once `ZoneDefs` is involved. Run from the project root:
##   Godot --headless --path . res://tools/generate_quests.tscn


func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://data/quests/"))
	var saved: int = 0
	for quest: QuestData in QuestDefinitions.build_all():
		var path: String = "res://data/quests/%s.tres" % quest.id
		quest.take_over_path(path)
		if ResourceSaver.save(quest, path) == OK:
			saved += 1
		else:
			push_error("Failed to save %s" % path)
	print("Generated %d quest files." % saved)
	get_tree().quit(0)
