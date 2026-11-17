extends Node
## Main scene for the story playthrough bot (Oct 16, Block 5a): starts StoryPlaythrough on the root so it survives every scene change it walks through.


func _ready() -> void:
	# Overnight Nov 17: `--strict=1` plays the same story with no debug shortcuts (StrictPlaythrough)
	var smoke: StoryPlaythrough = StrictPlaythrough.new() if OS.get_cmdline_user_args().has("--strict=1") else StoryPlaythrough.new()
	smoke.name = "StoryPlaythrough"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
