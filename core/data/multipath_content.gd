class_name MultipathContent
extends RefCounted
## Brief 9, Part F: the 24 dual-Path cards (4 for each of the 6 Path pairs). Each needs energy from BOTH of
## its Paths (one pip of each) and counts as both Paths for the deck's Path limit. They cannot be bought or found
## as rewards: they are crafted at the Alchemist from essence (`Alchemy`). One Common unit, one Uncommon
## spell, one Epic and one Legendary unit per pair. Placeholder numbers - real cards come later.

const A: Affinity.Type = Affinity.Type.BEEFCAKE
const B: Affinity.Type = Affinity.Type.GOURMAND
const C: Affinity.Type = Affinity.Type.REFUSEMANCER
const D: Affinity.Type = Affinity.Type.NECROCRAT
const T := CardEnums.Trigger
const G := CardEnums.TargetKind
const O := CardEnums.EffectOp
const K := CardEnums.Keyword
const R := CardEnums.Rarity

## The six Path pairs, in a fixed order (first Path, second Path).
const PAIRS: Array[Array] = [[A, B], [A, C], [A, D], [B, C], [B, D], [C, D]]


## card id -> CardData for all 24.
static func build(tokens: Dictionary) -> Dictionary:
	var cards: Dictionary = {}
	var spirit: CardData = tokens["token_spirit"]
	# ---- Beefcake + Gourmand ----
	_add(cards, _unit("meathead_sous_chef", "Meathead Sous-Chef", A, B, 1, 3, 2, [K.HUSTLE], R.COMMON, "Haste", "Seasons every dish with force. The dish has stopped arguing."))
	_add(cards, _spell("protein_smoothie", "Protein Smoothie", A, B, 1, R.UNCOMMON, "Draw a card. Gain 4 HP.", "Blended with a spatula and a lot of conviction.", [_fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 1), _fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_HP, 4)]))
	_add(cards, _unit("bulking_buffet", "The Bulking Buffet", A, B, 3, 5, 5, [K.BULLDOZE], R.EPIC, "Bulldoze. When this enters, gain 5 HP.", "All you can lift.", [_fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_HP, 5)]))
	_add(cards, _unit("grand_champion_chef", "Grand Champion Chef", A, B, 4, 6, 6, [K.HUSTLE, K.NOURISH], R.LEGENDARY, "Hustle, Nourish. When this enters, draw a card.", "A whisk in one hand, a barbell in the other, and no regrets.", [_fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 1)]))
	# ---- Beefcake + Refusemancer ----
	_add(cards, _unit("rhino_wrangler", "Rhino Wrangler", A, C, 1, 3, 3, [K.BULLDOZE], R.COMMON, "Trample", "Lifts the rhino. Carries the rhino. Is, at this point, the rhino."))
	_add(cards, _spell("compost_pump", "Compost Pump", A, C, 1, R.UNCOMMON, "Your units get +1/+1 permanently. Deal 2 damage to the opponent.", "Pre-workout, organic, and extremely fragrant.", [_fx(T.ON_ENTER, G.ALL_ALLY_UNITS, O.BUFF, 1, 1), _fx(T.ON_ENTER, G.OPPONENT, O.DEAL_DAMAGE, 2)]))
	_add(cards, _unit("hulking_mulch_beast", "Hulking Mulch Beast", A, C, 3, 6, 6, [K.HUSTLE, K.BULLDOZE], R.EPIC, "Hustle, Bulldoze", "It arrived at the gym exactly when it wanted to."))
	_add(cards, _unit("boris_lord_of_the_barn", "Boris, Lord of the Barn", A, C, 4, 8, 8, [K.BULLDOZE], R.LEGENDARY, "Bulldoze. When this enters, your units get +1/+0 permanently.", "The boar has seen things. The boar has lifted things.", [_fx(T.ON_ENTER, G.ALL_ALLY_UNITS, O.BUFF, 1, 0)]))
	# ---- Beefcake + Necrocrat (chaos meets the rulebook) ----
	_add(cards, _unit("late_filing_brawler", "Late Filing Brawler", A, D, 1, 3, 1, [K.HUSTLE], R.COMMON, "Hustle. When this dies, draw a card.", "Arrives there-ish, on-time-ish, and a form is always filed afterwards.", [_fx(T.ON_DEATH, G.CONTROLLER, O.DRAW, 1)]))
	_add(cards, _spell("unauthorized_deadlift", "Unauthorized Deadlift", A, D, 2, R.UNCOMMON, "Destroy target enemy unit. You lose 2 HP.", "Technically a violation. Technically a very good lift.", [_fx(T.ON_ENTER, G.CHOSEN_UNIT_ENEMY, O.DESTROY), _fx(T.ON_ENTER, G.CONTROLLER, O.LOSE_HP, 2)]))
	_add(cards, _unit("compliance_on_steroids", "Compliance Officer on Steroids", A, D, 3, 5, 4, [K.SUCKER_PUNCH], R.EPIC, "First Strike. When this enters, the opponent discards a card.", "Fills in your forms. Fills in your face.", [_fx(T.ON_ENTER, G.OPPONENT, O.TOSS, 1)]))
	var rest: EffectData = _fx(T.ON_DEATH, G.CONTROLLER, O.SUMMON_TOKEN, 2)
	rest.token = spirit
	_add(cards, _unit("rest_in_gains", "Rest In Gains", A, D, 4, 6, 5, [K.HUSTLE], R.LEGENDARY, "Hustle. When this dies, create two 1/1 Spirits and the opponent loses 3 HP.", "Deceased, but never skipped leg day.", [rest, _fx(T.ON_DEATH, G.OPPONENT, O.LOSE_HP, 3)]))
	# ---- Gourmand + Refusemancer (snooty meets "garbage eaters") ----
	_add(cards, _unit("gourmet_garbage_picker", "Gourmet Garbage Picker", B, C, 1, 2, 3, [], R.COMMON, "When this enters, gain 2 HP.", "Insists the dumpster has a very respectable wine list.", [_fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_HP, 2)]))
	_add(cards, _spell("dumpster_bistro", "Dumpster-Diving Bistro", B, C, 2, R.UNCOMMON, "Draw two cards. Gain 2 HP.", "Reservations are required. So is a strong stomach.", [_fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 2), _fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_HP, 2)]))
	_add(cards, _unit("compost_casserole_golem", "Compost Casserole Golem", B, C, 3, 5, 6, [], R.EPIC, "When this enters, gain 4 HP.", "Neither side will admit they made it.", [_fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_HP, 4)]))
	_add(cards, _unit("the_garbage_gourmet", "The Garbage Gourmet", B, C, 4, 5, 7, [], R.LEGENDARY, "When this enters, draw two cards and gain 4 HP.", "A true connoisseur of whatever fell off the table.", [_fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 2), _fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_HP, 4)]))
	# ---- Gourmand + Necrocrat ----
	_add(cards, _unit("deceased_sous_chef", "Deceased Sous-Chef", B, D, 1, 2, 2, [], R.COMMON, "When this dies, draw a card.", "Still plating, in a manner of speaking.", [_fx(T.ON_DEATH, G.CONTROLLER, O.DRAW, 1)]))
	_add(cards, _spell("last_supper_menu", "The Last Supper Menu", B, D, 2, R.UNCOMMON, "Destroy target enemy unit. Gain 3 HP.", "A fine-dining experience, in triplicate.", [_fx(T.ON_ENTER, G.CHOSEN_UNIT_ENEMY, O.DESTROY), _fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_HP, 3)]))
	_add(cards, _unit("banquet_auditor", "Banquet Auditor", B, D, 3, 4, 5, [K.FLYING], R.EPIC, "Flying. When this enters, the opponent discards a card and you draw a card.", "Every course must be itemized.", [_fx(T.ON_ENTER, G.OPPONENT, O.TOSS, 1), _fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 1)]))
	_add(cards, _unit("last_supper_registrar", "The Registrar of Last Suppers", B, D, 4, 6, 6, [K.FLYING, K.NOURISH], R.LEGENDARY, "Flying, Nourish. When this enters, the opponent loses 3 HP.", "Your table is ready. It has been ready for some time.", [_fx(T.ON_ENTER, G.OPPONENT, O.LOSE_HP, 3)]))
	# ---- Refusemancer + Necrocrat ----
	_add(cards, _unit("grave_compost_beetle", "Grave Compost Beetle", C, D, 1, 2, 3, [], R.COMMON, "When this dies, gain 2 HP.", "Turns the dearly departed into the dearly fertilized.", [_fx(T.ON_DEATH, G.CONTROLLER, O.GAIN_HP, 2)]))
	_add(cards, _spell("rot_and_ruin", "Rot and Ruin", C, D, 2, R.UNCOMMON, "Deal 3 damage to target enemy unit. Gain 3 HP.", "Ashes to ashes, compost to compost.", [_fx(T.ON_ENTER, G.CHOSEN_UNIT_ENEMY, O.DEAL_DAMAGE, 3), _fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_HP, 3)]))
	var mulch: EffectData = _fx(T.ON_DEATH, G.CONTROLLER, O.SUMMON_TOKEN, 2)
	mulch.token = spirit
	_add(cards, _unit("mulch_reaper", "Mulch Reaper", C, D, 3, 5, 5, [K.BULLDOZE], R.EPIC, "Bulldoze. When this dies, create two 1/1 Spirits.", "Harvest season never really ends.", [mulch]))
	_add(cards, _unit("eternal_compost_heap", "The Eternal Compost Heap", C, D, 4, 7, 7, [K.BULLDOZE], R.LEGENDARY, "Bulldoze. When this enters, your units get +1/+1 permanently and the opponent discards a card.", "Nothing ever really dies. It just gets composted, filed and reassigned.", [_fx(T.ON_ENTER, G.ALL_ALLY_UNITS, O.BUFF, 1, 1), _fx(T.ON_ENTER, G.OPPONENT, O.TOSS, 1)]))
	return cards


## The four card ids of a pair (either order).
static func ids_for(first: Affinity.Type, second: Affinity.Type, cards: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for card_id: Variant in cards.keys():
		var card: CardData = cards[card_id] as CardData
		if card.is_on_path(first) and card.is_on_path(second):
			result.append(str(card_id))
	result.sort()
	return result


static func _unit(id: String, title: String, first: Affinity.Type, second: Affinity.Type, generic: int, attack: int, defense: int, keywords: Array, rarity: CardEnums.Rarity, rules: String, flavor: String, effects: Array = []) -> CardData:
	var card: CardData = ContentDefinitions._unit(id, title, first, generic, [first, second], attack, defense, keywords)
	card.color2 = second
	for effect: EffectData in effects:
		card = ContentDefinitions._with(card, effect)
	return ContentDefinitions._fin(card, rarity, rules, flavor)


static func _spell(id: String, title: String, first: Affinity.Type, second: Affinity.Type, generic: int, rarity: CardEnums.Rarity, rules: String, flavor: String, effects: Array) -> CardData:
	var card: CardData = ContentDefinitions._spell(id, title, first, generic, [first, second])
	card.color2 = second
	for effect: EffectData in effects:
		card = ContentDefinitions._with(card, effect)
	return ContentDefinitions._fin(card, rarity, rules, flavor)


static func _fx(trigger: CardEnums.Trigger, target: CardEnums.TargetKind, op: CardEnums.EffectOp, amount: int = 0, amount2: int = 0) -> EffectData:
	return ContentDefinitions._fx(trigger, target, op, amount, amount2)


static func _add(cards: Dictionary, card: CardData) -> void:
	cards[card.id] = card
