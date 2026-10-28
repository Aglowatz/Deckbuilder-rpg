extends CardTestBase
## Overnight Oct 27-28, Part 1: the Necrocrat Common / Uncommon unit changes (bodies) and the new Hazmat Intern (N-38, Toxic).

const KW := CardEnums.Keyword


func _stats(id: String) -> String:
	CardSet.load_all()
	var data: CardData = CardSet.card(id)
	return "%d/%d" % [data.attack, data.defense]


func test_necrocrat_bodies_after_oct28() -> void:
	assert_eq(_stats("N-03"), "3/4", "Post-Human Resources Ghoul is a real 3-drop")
	assert_eq(_stats("N-04"), "2/3", "Body-builder survives to use its ability")
	assert_eq(_stats("N-05"), "2/4", "Corpseified Public Accountant is the wall that farms Red Tape")
	assert_eq(_stats("N-07"), "3/4", "Grave Shift Worker")
	assert_eq(_stats("N-23"), "3/5", "Middle Management Zombie (Uncommon)")


func test_hazmat_intern_is_a_toxic_common_blocker() -> void:
	var game: GameState = _game()
	var data: CardData = CardSet.card("N-38")
	assert_not_null(data, "N-38 exists")
	assert_eq(data.display_name, "Hazmat Intern")
	assert_eq(_stats("N-38"), "1/3")
	assert_eq(data.rarity, CardEnums.Rarity.COMMON)
	assert_eq(data.color, Affinity.Type.NECROCRAT)
	var intern: CardInstance = _field(game, 0, "N-38")
	assert_true(game.unit_has_keyword(intern, KW.TOXIC), "Toxic: any damage it deals destroys a unit")
