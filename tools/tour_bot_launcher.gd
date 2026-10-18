extends Node
## Launches the playthrough bot (`TourBot`, Overnight Oct 17 Part 13): bash tools/run_tour_bot.sh


func _ready() -> void:
	var bot: TourBot = TourBot.new()
	get_tree().root.add_child.call_deferred(bot)
	bot.ready.connect(bot.run, CONNECT_ONE_SHOT)
