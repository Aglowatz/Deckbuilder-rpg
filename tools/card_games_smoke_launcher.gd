extends Node
## Main scene for the card games smoke (Fable Nov 16c, Part 5): starts CardGamesSmoke on the root so it survives the zone changes.


func _ready() -> void:
	var smoke: CardGamesSmoke = CardGamesSmoke.new()
	smoke.name = "CardGamesSmoke"
	get_tree().root.add_child.call_deferred(smoke)
	smoke.run.call_deferred()
