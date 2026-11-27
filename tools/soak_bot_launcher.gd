extends Node
## Launches the random-play soak bot (Nov 27 day, Part A): bash tools/soak_bot.sh <seed> [minutes] [WxH]


func _ready() -> void:
	var bot: PlayScript = (load("res://tools/soak_bot.gd") as GDScript).new() as PlayScript
	get_tree().root.add_child.call_deferred(bot)
	bot.ready.connect(bot.run, CONNECT_ONE_SHOT)
