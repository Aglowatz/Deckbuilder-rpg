extends SceneTree
## Prints every card as `ID | name | cost | type | atk/def | paths | rules` for deck design:
##   Godot --headless --path . -s res://tools/dump_cards.gd


func _init() -> void:
	var content: ContentSet = ContentLibrary.load_all()
	var ids: Array[String] = []
	for key: Variant in content.cards.keys():
		ids.append(str(key))
	ids.sort()
	for id: String in ids:
		var card: CardData = content.card(id)
		print("%s | %s | %d | %d | %d/%d | %d,%d | %s" % [card.id, card.display_name, card.energy_value(), card.type, card.attack, card.defense, card.color, card.color2, card.rules_text.replace("\n", " ")])
	quit(0)
