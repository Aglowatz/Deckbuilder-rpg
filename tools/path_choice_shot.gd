extends Control
## Overnight Oct 22, Part 3: the Path choice screen on its own, for screenshots.
## bash tools/shot.sh res://tools/path_choice_shot.tscn <name> [--hover=beefcake] [--more=true] [--pick=gourmand]


func _ready() -> void:
	var screen: ElementChoiceScreen = ElementChoiceScreen.new()
	add_child(screen)
	var args: Dictionary = {}
	for arg: String in OS.get_cmdline_user_args():
		var parts: PackedStringArray = arg.trim_prefix("--").split("=", true, 1)
		args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	await get_tree().process_frame
	for path: Affinity.Type in Affinity.colored_types():
		var name_lower: String = Affinity.display_name(path).to_lower()
		if str(args.get("pick", "")) == name_lower:
			screen._select(path)
		if str(args.get("hover", "")) == name_lower and screen.has_method("_show"):
			screen.call("_show", path)
	if str(args.get("more", "")) == "true" and screen.has_method("_toggle_more"):
		screen.call("_toggle_more")
