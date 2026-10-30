extends Node
## Launches the play-script driver (`PlayScript`, Fresh eyes Oct 30): bash tools/play.sh <script.txt> [run_name]


func _ready() -> void:
	var bot: PlayScript = PlayScript.new()
	get_tree().root.add_child.call_deferred(bot)
	bot.ready.connect(bot.run, CONNECT_ONE_SHOT)
