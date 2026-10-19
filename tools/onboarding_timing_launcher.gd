extends Node
## Main scene for the onboarding timing bot (Daytime Oct 19, Part 3): starts OnboardingTiming on the root, then opens the title screen.


func _ready() -> void:
	var bot: OnboardingTiming = OnboardingTiming.new()
	bot.name = "OnboardingTiming"
	get_tree().root.add_child.call_deferred(bot)
	get_tree().change_scene_to_file.call_deferred("res://scenes/title.tscn")
	bot.run.call_deferred()
