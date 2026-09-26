class_name ContentDefinitions
extends RefCounted
## The placeholder content set, defined in code with typed helpers. tools/generate_content.gd
## writes it out as .tres files in data/; tests validate it. Names and numbers are placeholders.
##
## Color identities:
##   Neutral  - generic cards that fit any deck
##   A        - aggressive: haste, first strike, burn, combat tricks
##   B        - control: card draw, removal, bounce, fliers/reach, snare traps
##   C        - big creatures: large bodies, trample, guard, growth, life gain
##   D        - sacrifice/value: death triggers, tokens, drain, lifesteal

const N: Affinity.Type = Affinity.Type.NEUTRAL
const A: Affinity.Type = Affinity.Type.A
const B: Affinity.Type = Affinity.Type.B
const C: Affinity.Type = Affinity.Type.C
const D: Affinity.Type = Affinity.Type.D

const T := CardEnums.Trigger
const G := CardEnums.TargetKind
const O := CardEnums.EffectOp
const K := CardEnums.Keyword
const R := CardEnums.Rarity

const DECK_SIZE: int = 45


static func build() -> ContentSet:
	var content: ContentSet = ContentSet.new()
	content.tokens = build_tokens()
	content.lands = build_lands()
	content.cards = build_cards(content.tokens)
	content.decks = build_decks(content)
	content.challenges = ChallengeExamples.all(reward_pool(content.cards))
	content.personalities = [AIPersonality.balanced(), AIPersonality.aggressive(), AIPersonality.defensive()] as Array[AIPersonality]
	return content


# ---- Helpers -------------------------------------------------------------------------


static func _pips(colors: Array) -> Array[Affinity.Type]:
	var result: Array[Affinity.Type] = []
	for color: Variant in colors:
		result.append(int(color) as Affinity.Type)
	return result


static func _kw(keywords: Array) -> Array[CardEnums.Keyword]:
	var result: Array[CardEnums.Keyword] = []
	for keyword: Variant in keywords:
		result.append(int(keyword) as CardEnums.Keyword)
	return result


static func _fx(trigger: CardEnums.Trigger, target: CardEnums.TargetKind, op: CardEnums.EffectOp, amount: int = 0, amount2: int = 0, duration: CardEnums.Duration = CardEnums.Duration.PERMANENT) -> EffectData:
	return CardBuilder.effect(trigger, target, op, amount, amount2, duration)


static func _fin(card: CardData, rarity: CardEnums.Rarity, rules: String = "", flavor: String = "") -> CardData:
	card.rarity = rarity
	card.rules_text = rules
	card.flavor_text = flavor
	return card


static func _with(card: CardData, effect: EffectData) -> CardData:
	return CardBuilder.with_effect(card, effect)


static func _add(cards: Dictionary, card: CardData) -> void:
	cards[card.id] = card


static func _creature(id: String, title: String, color: Affinity.Type, generic: int, pips: Array, power: int, toughness: int, keywords: Array = []) -> CardData:
	return CardBuilder.creature(id, title, color, generic, _pips(pips), power, toughness, _kw(keywords))


static func _spell(id: String, title: String, color: Affinity.Type, generic: int, pips: Array) -> CardData:
	return CardBuilder.spell(id, title, color, generic, _pips(pips))


static func _trap(id: String, title: String, color: Affinity.Type, generic: int, pips: Array) -> CardData:
	return CardBuilder.trap(id, title, color, generic, _pips(pips))


# ---- Tokens and lands ----------------------------------------------------------------


static func build_tokens() -> Dictionary:
	var tokens: Dictionary = {}
	var spirit: CardData = CardBuilder.token("token_spirit", "Spirit", 1, 1)
	spirit.rules_text = "A 1/1 spirit."
	tokens[spirit.id] = spirit
	return tokens


static func build_lands() -> Dictionary:
	var lands: Dictionary = {}
	for color: Affinity.Type in [N, A, B, C, D]:
		var land: CardData = CardBuilder.land(color)
		land.rules_text = "Tap: add one %s mana." % Affinity.display_name(color)
		lands[int(color)] = land
	return lands


# ---- The 40 cards --------------------------------------------------------------------


static func build_cards(tokens: Dictionary) -> Dictionary:
	var cards: Dictionary = {}
	var spirit: CardData = tokens["token_spirit"]
	_add_neutral(cards)
	_add_affinity_a(cards)
	_add_affinity_b(cards)
	_add_affinity_c(cards)
	_add_affinity_d(cards, spirit)
	return cards


static func _add_neutral(cards: Dictionary) -> void:
	_add(cards, _fin(_creature("sellsword", "Sellsword", N, 2, [], 2, 2), R.COMMON, "", "Coin first, questions never."))
	_add(cards, _fin(_creature("cave_bat", "Cave Bat", N, 2, [], 1, 2, [K.FLYING]), R.COMMON, "Flying"))
	_add(cards, _fin(_creature("stone_sentinel", "Stone Sentinel", N, 3, [], 3, 4, [K.GUARD]), R.COMMON, "Guard"))
	_add(cards, _fin(_with(_creature("field_medic", "Field Medic", N, 3, [], 2, 2), _fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_LIFE, 3)), R.COMMON, "When this enters, gain 3 life."))
	_add(cards, _fin(_with(_creature("merchant", "Traveling Merchant", N, 3, [], 2, 2), _fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 1)), R.UNCOMMON, "When this enters, draw a card."))
	_add(cards, _fin(_creature("ironclad", "Ironclad", N, 4, [], 4, 4), R.COMMON))
	_add(cards, _fin(_with(CardBuilder.artifact("healing_idol", "Healing Idol", N, 2, _pips([])), _fx(T.START_OF_TURN, G.CONTROLLER, O.GAIN_LIFE, 1)), R.UNCOMMON, "At the start of your turn, gain 1 life."))
	_add(cards, _fin(_with(_spell("rusty_curse", "Rusty Curse", N, 2, []), _fx(T.ON_ENTER, G.CHOSEN_CREATURE_ENEMY, O.BUFF, -2, -2)), R.COMMON, "Target enemy creature gets -2/-2."))
	_add(cards, _fin(_with(_trap("pitfall", "Pitfall", N, 2, []), _fx(T.TRAP_OPPONENT_ATTACKS, G.TRIGGERING_CARD, O.DESTROY)), R.UNCOMMON, "Trap: when the opponent attacks, destroy their strongest attacker."))
	_add(cards, _fin(_with(_spell("supply_cache", "Supply Cache", N, 2, []), _fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 2)), R.COMMON, "Draw two cards."))


static func _add_affinity_a(cards: Dictionary) -> void:
	_add(cards, _fin(_creature("ember_imp", "Ember Imp", A, 0, [A], 2, 1, [K.HASTE]), R.COMMON, "Haste"))
	_add(cards, _fin(_creature("blade_dancer", "Blade Dancer", A, 1, [A], 2, 1, [K.FIRST_STRIKE]), R.COMMON, "First Strike"))
	_add(cards, _fin(_with(_creature("raider", "Raider", A, 2, [A], 3, 2), _fx(T.ON_ATTACK, G.SELF, O.BUFF, 1, 0, CardEnums.Duration.END_OF_TURN)), R.COMMON, "Whenever this attacks, it gets +1/+0 until end of turn."))
	_add(cards, _fin(_creature("blazing_charger", "Blazing Charger", A, 3, [A], 4, 3, [K.HASTE]), R.UNCOMMON, "Haste"))
	_add(cards, _fin(_with(_spell("firebolt", "Firebolt", A, 0, [A]), _fx(T.ON_ENTER, G.CHOSEN_CREATURE_ENEMY, O.DEAL_DAMAGE, 2)), R.COMMON, "Deal 2 damage to target enemy creature."))
	_add(cards, _fin(_with(_spell("flame_burst", "Flame Burst", A, 1, [A]), _fx(T.ON_ENTER, G.OPPONENT, O.DEAL_DAMAGE, 3)), R.COMMON, "Deal 3 damage to the opponent."))
	_add(cards, _fin(_with(_spell("warcry", "Warcry", A, 1, [A]), _fx(T.ON_ENTER, G.ALL_ALLY_CREATURES, O.BUFF, 2, 0, CardEnums.Duration.END_OF_TURN)), R.UNCOMMON, "Your creatures get +2/+0 until end of turn."))
	_add(cards, _fin(_with(_trap("scorching_ward", "Scorching Ward", A, 1, [A]), _fx(T.TRAP_OPPONENT_ATTACKS, G.ALL_ATTACKERS, O.DEAL_DAMAGE, 2)), R.UNCOMMON, "Trap: when the opponent attacks, deal 2 damage to each attacker."))


static func _add_affinity_b(cards: Dictionary) -> void:
	_add(cards, _fin(_creature("frost_sentry", "Frost Sentry", B, 1, [B], 1, 4, [K.REACH, K.DEFENDER]), R.COMMON, "Defender, Reach"))
	_add(cards, _fin(_with(_creature("sage", "Sage", B, 2, [B], 2, 2), _fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 1)), R.COMMON, "When this enters, draw a card."))
	_add(cards, _fin(_with(_creature("whispering_shade", "Whispering Shade", B, 2, [B], 2, 2, [K.FLYING]), _fx(T.ON_ENTER, G.OPPONENT, O.DISCARD, 1)), R.UNCOMMON, "Flying. When this enters, the opponent discards a card."))
	_add(cards, _fin(_with(_spell("dissolve", "Dissolve", B, 2, [B]), _fx(T.ON_ENTER, G.CHOSEN_CREATURE_ENEMY, O.DESTROY)), R.UNCOMMON, "Destroy target enemy creature."))
	_add(cards, _fin(_with(_spell("recall", "Recall", B, 0, [B]), _fx(T.ON_ENTER, G.CHOSEN_CREATURE_ANY, O.RETURN_TO_HAND)), R.COMMON, "Return target creature to its owner's hand."))
	_add(cards, _fin(_with(_spell("deep_insight", "Deep Insight", B, 1, [B]), _fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 2)), R.COMMON, "Draw two cards."))
	_add(cards, _fin(_with(_trap("snare", "Snare", B, 1, [B]), _fx(T.TRAP_OPPONENT_CREATURE, G.TRIGGERING_CARD, O.DESTROY)), R.UNCOMMON, "Trap: when the opponent casts a creature, destroy it."))
	_add(cards, _fin(_creature("sea_warden", "Sea Warden", B, 4, [B], 3, 5, [K.FLYING]), R.RARE, "Flying"))


static func _add_affinity_c(cards: Dictionary) -> void:
	_add(cards, _fin(_creature("mossback_bear", "Mossback Bear", C, 2, [C], 3, 3), R.COMMON))
	_add(cards, _fin(_creature("rampaging_boar", "Rampaging Boar", C, 3, [C], 4, 3, [K.TRAMPLE]), R.COMMON, "Trample"))
	_add(cards, _fin(_creature("stag_warden", "Stag Warden", C, 3, [C], 3, 4, [K.GUARD]), R.UNCOMMON, "Guard"))
	_add(cards, _fin(_creature("ancient_treant", "Ancient Treant", C, 3, [C, C], 5, 5), R.UNCOMMON))
	_add(cards, _fin(_creature("thornback_colossus", "Thornback Colossus", C, 4, [C, C], 7, 7, [K.TRAMPLE]), R.RARE, "Trample"))
	_add(cards, _fin(_with(_spell("growth", "Growth", C, 1, [C]), _fx(T.ON_ENTER, G.CHOSEN_CREATURE_ALLY, O.BUFF, 2, 2)), R.COMMON, "Target ally creature gets +2/+2 permanently."))
	_add(cards, _fin(_with(_spell("rejuvenate", "Rejuvenate", C, 1, [C]), _fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_LIFE, 4)), R.COMMON, "Gain 4 life."))


static func _add_affinity_d(cards: Dictionary, spirit: CardData) -> void:
	_add(cards, _fin(_with(_creature("bone_servant", "Bone Servant", D, 1, [D], 2, 1), _fx(T.ON_DEATH, G.CONTROLLER, O.DRAW, 1)), R.COMMON, "When this dies, draw a card."))
	var summon_one: EffectData = _fx(T.ON_DEATH, G.CONTROLLER, O.SUMMON_TOKEN, 1)
	summon_one.token = spirit
	_add(cards, _fin(_with(_creature("grave_tender", "Grave Tender", D, 2, [D], 2, 2), summon_one), R.COMMON, "When this dies, create a 1/1 Spirit."))
	_add(cards, _fin(_with(_creature("martyr", "Martyr", D, 0, [D], 1, 1), _fx(T.ON_DEATH, G.OPPONENT, O.LOSE_LIFE, 3)), R.COMMON, "When this dies, the opponent loses 3 life."))
	var drain: CardData = _with(_spell("soul_drain", "Soul Drain", D, 2, [D]), _fx(T.ON_ENTER, G.OPPONENT, O.DEAL_DAMAGE, 3))
	_add(cards, _fin(_with(drain, _fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_LIFE, 3)), R.UNCOMMON, "Deal 3 damage to the opponent and gain 3 life."))
	_add(cards, _fin(_creature("bloodthirst_wolf", "Bloodthirst Wolf", D, 2, [D], 3, 2, [K.LIFESTEAL]), R.COMMON, "Lifesteal"))
	var bargain: CardData = _with(_spell("dark_bargain", "Dark Bargain", D, 0, [D]), _fx(T.ON_ENTER, G.CHOSEN_CREATURE_ALLY, O.DESTROY))
	_add(cards, _fin(_with(bargain, _fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 2)), R.UNCOMMON, "Destroy target ally creature. Draw two cards."))
	var summon_two: EffectData = _fx(T.ON_ENTER, G.CONTROLLER, O.SUMMON_TOKEN, 2)
	summon_two.token = spirit
	_add(cards, _fin(_with(_creature("necromancer", "Necromancer", D, 3, [D], 2, 3), summon_two), R.RARE, "When this enters, create two 1/1 Spirits."))


static func reward_pool(cards: Dictionary) -> Array[CardData]:
	var pool: Array[CardData] = []
	for id: String in ["merchant", "ironclad", "supply_cache", "pitfall"]:
		pool.append(cards[id] as CardData)
	return pool


# ---- Decks ---------------------------------------------------------------------------


## Each recipe: name, land counts by color, and spell counts by card id (28 spells + 17 lands).
static func deck_recipes() -> Array[Dictionary]:
	return [
		{
			"name": "Ember & Tide",
			"lands": {A: 9, B: 8},
			"spells": {
				"ember_imp": 3, "blade_dancer": 3, "raider": 2, "blazing_charger": 2, "firebolt": 3,
				"flame_burst": 2, "warcry": 1, "whispering_shade": 2, "dissolve": 2, "snare": 1,
				"sellsword": 3, "cave_bat": 2, "supply_cache": 2,
			},
		},
		{
			"name": "Tide & Root",
			"lands": {B: 8, C: 9},
			"spells": {
				"frost_sentry": 1, "sage": 2, "whispering_shade": 2, "dissolve": 2, "recall": 1,
				"deep_insight": 2, "snare": 1, "sea_warden": 1, "mossback_bear": 3, "rampaging_boar": 3,
				"stag_warden": 2, "ancient_treant": 2, "growth": 1, "rejuvenate": 1, "merchant": 2,
				"rusty_curse": 2,
			},
		},
		{
			"name": "Root & Grave",
			"lands": {C: 9, D: 8},
			"spells": {
				"mossback_bear": 3, "rampaging_boar": 3, "stag_warden": 1, "ancient_treant": 2,
				"thornback_colossus": 1, "growth": 2, "rejuvenate": 1, "bone_servant": 2,
				"grave_tender": 2, "martyr": 2, "bloodthirst_wolf": 2, "soul_drain": 1,
				"dark_bargain": 1, "necromancer": 1, "field_medic": 2, "healing_idol": 2,
			},
		},
		{
			"name": "Grave & Ember",
			"lands": {D: 9, A: 8},
			"spells": {
				"bone_servant": 2, "grave_tender": 2, "martyr": 2, "bloodthirst_wolf": 3, "soul_drain": 2,
				"dark_bargain": 2, "necromancer": 1, "ember_imp": 2, "blade_dancer": 2, "raider": 2, "blazing_charger": 1,
				"firebolt": 2, "flame_burst": 2, "scorching_ward": 1, "warcry": 1, "sellsword": 1,
			},
		},
		{
			"name": "Wanderer's Pack",
			"lands": {N: 17},
			"spells": {
				"sellsword": 3, "cave_bat": 3, "stone_sentinel": 3, "field_medic": 3, "merchant": 3,
				"ironclad": 3, "healing_idol": 2, "rusty_curse": 3, "pitfall": 2, "supply_cache": 3,
			},
		},
	]


static func build_decks(content: ContentSet) -> Array[Deck]:
	var decks: Array[Deck] = []
	for recipe: Dictionary in deck_recipes():
		var deck: Deck = Deck.new()
		deck.deck_name = str(recipe["name"])
		var lands: Dictionary = recipe["lands"]
		for color: Variant in lands.keys():
			for i: int in range(int(lands[color])):
				deck.cards.append(content.lands[int(color)] as CardData)
		var spells: Dictionary = recipe["spells"]
		for id: Variant in spells.keys():
			for i: int in range(int(spells[id])):
				deck.cards.append(content.cards[str(id)] as CardData)
		decks.append(deck)
	return decks
