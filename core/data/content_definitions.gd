class_name ContentDefinitions
extends RefCounted
## The placeholder content set, defined in code with typed helpers. tools/generate_content.gd
## writes it out as .tres files in data/; tests validate it. Names and numbers are placeholders.
##
## Color identities:
##   Neutral  - generic cards that fit any deck
##   A        - aggressive: haste, Sucker Punch, burn, combat tricks
##   B        - control: card draw, removal, bounce, fliers/reach, snare traps
##   C        - big units: large bodies, bulldoze, guard, growth, HP gain
##   D        - sacrifice/value: death triggers, tokens, drain, lifesteal

const N: Affinity.Type = Affinity.Type.NEUTRAL
const A: Affinity.Type = Affinity.Type.BEEFCAKE
const B: Affinity.Type = Affinity.Type.GOURMAND
const C: Affinity.Type = Affinity.Type.REFUSEMANCER
const D: Affinity.Type = Affinity.Type.NECROCRAT

const T := CardEnums.Trigger
const G := CardEnums.TargetKind
const O := CardEnums.EffectOp
const K := CardEnums.Keyword
const R := CardEnums.Rarity

const DECK_SIZE: int = 45


static func build() -> ContentSet:
	var content: ContentSet = ContentSet.new()
	content.tokens = build_tokens()
	content.infrastructure = build_infrastructure()
	content.cards = build_cards(content.tokens)
	content.zone_cards = build_zone_cards(content.tokens)
	content.multipath_cards = MultipathContent.build(content.tokens)
	PackRules.apply_flags(content.cards)
	PackRules.apply_flags(content.zone_cards)
	content.zone_equipment = ProgressionContent.zone_equipment()
	content.decks = build_decks(content)
	content.challenges = ChallengeExamples.all(reward_pool(content.cards))
	content.personalities = [AIPersonality.balanced(), AIPersonality.aggressive(), AIPersonality.defensive(), AIPersonality.passive(), AIPersonality.aggressive_dumb()] as Array[AIPersonality]
	content.equipment = ProgressionContent.equipment()
	content.items = ProgressionContent.items(content.tokens)
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


static func _unit(id: String, title: String, color: Affinity.Type, generic: int, pips: Array, attack: int, defense: int, keywords: Array = []) -> CardData:
	return CardBuilder.unit(id, title, color, generic, _pips(pips), attack, defense, _kw(keywords))


static func _spell(id: String, title: String, color: Affinity.Type, generic: int, pips: Array) -> CardData:
	return CardBuilder.spell(id, title, color, generic, _pips(pips))


static func _trap(id: String, title: String, color: Affinity.Type, generic: int, pips: Array) -> CardData:
	return CardBuilder.trap(id, title, color, generic, _pips(pips))


# ---- Tokens and infrastructure ----------------------------------------------------------------


static func build_tokens() -> Dictionary:
	var tokens: Dictionary = {}
	var spirit: CardData = CardBuilder.token("token_spirit", "Spirit", 1, 1)
	spirit.rules_text = "A 1/1 spirit."
	tokens[spirit.id] = spirit
	CapitalContent.add_tokens(tokens)
	return tokens


static func build_infrastructure() -> Dictionary:
	var infrastructure: Dictionary = {}
	for color: Affinity.Type in Affinity.colored_types():
		var infra: CardData = CardBuilder.infra(color)
		infra.rules_text = "Activate: add one %s energy." % Affinity.display_name(color)
		infrastructure[int(color)] = infra
	return infrastructure


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
	_add(cards, _fin(_unit("apprentice_blade", "Apprentice Blade", N, 1, [], 1, 2), R.COMMON, "", "Everyone starts somewhere."))
	_add(cards, _fin(_unit("scrappy_recruit", "Scrappy Recruit", N, 1, [], 2, 1), R.COMMON, "", "Braver than trained."))
	_add(cards, _fin(_unit("sellsword", "Sellsword", N, 2, [], 2, 2), R.COMMON, "", "Coin first, questions never."))
	_add(cards, _fin(_unit("cave_bat", "Cave Bat", N, 2, [], 1, 2, [K.FLYING]), R.COMMON, "Flying"))
	_add(cards, _fin(_unit("stone_sentinel", "Stone Sentinel", N, 3, [], 2, 4, []), R.COMMON, ""))
	_add(cards, _fin(_with(_unit("field_medic", "Field Medic", N, 3, [], 2, 2), _fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_HP, 3)), R.COMMON, "When this enters, gain 3 HP."))
	_add(cards, _fin(_with(_unit("merchant", "Traveling Merchant", N, 3, [], 2, 2), _fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 1)), R.UNCOMMON, "When this enters, draw a card."))
	_add(cards, _fin(_unit("ironclad", "Ironclad", N, 4, [], 3, 4, [K.OVERTIME]), R.COMMON, "Vigilance"))
	_add(cards, _fin(_with(CardBuilder.wonder("healing_idol", "Healing Idol", N, 2, _pips([])), _fx(T.START_OF_TURN, G.CONTROLLER, O.GAIN_HP, 1)), R.UNCOMMON, "At the start of your turn, gain 1 HP."))
	_add(cards, _fin(_with(_spell("rusty_curse", "Rusty Curse", N, 2, []), _fx(T.ON_ENTER, G.CHOSEN_UNIT_ENEMY, O.BUFF, -2, -2)), R.COMMON, "Target enemy unit gets -2/-2."))
	_add(cards, _fin(_with(_trap("pitfall", "Pitfall", N, 2, []), _fx(T.TRAP_OPPONENT_ATTACKS, G.TRIGGERING_CARD, O.DESTROY)), R.UNCOMMON, "Trap: when the opponent attacks, destroy their strongest attacker."))
	_add(cards, _fin(_with(_spell("supply_cache", "Supply Cache", N, 2, []), _fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 2)), R.COMMON, "Draw two cards."))


static func _add_affinity_a(cards: Dictionary) -> void:
	_add(cards, _fin(_unit("beefcake_imp", "Beefcake Imp", A, 0, [A], 2, 1, [K.HUSTLE]), R.COMMON, "Haste"))
	_add(cards, _fin(_unit("blade_dancer", "Blade Dancer", A, 1, [A], 2, 1, [K.SUCKER_PUNCH]), R.COMMON, "First Strike"))
	_add(cards, _fin(_with(_unit("raider", "Raider", A, 2, [A], 3, 2), _fx(T.ON_ATTACK, G.SELF, O.BUFF, 1, 0, CardEnums.Duration.END_OF_TURN)), R.COMMON, "Whenever this attacks, it gets +1/+0 until end of turn."))
	_add(cards, _fin(_unit("blazing_charger", "Blazing Charger", A, 3, [A], 4, 3, [K.HUSTLE]), R.UNCOMMON, "Haste"))
	_add(cards, _fin(_with(_spell("firebolt", "Firebolt", A, 0, [A]), _fx(T.ON_ENTER, G.CHOSEN_UNIT_ENEMY, O.DEAL_DAMAGE, 2)), R.COMMON, "Deal 2 damage to target enemy unit."))
	_add(cards, _fin(_with(_spell("flame_burst", "Flame Burst", A, 1, [A]), _fx(T.ON_ENTER, G.OPPONENT, O.DEAL_DAMAGE, 3)), R.COMMON, "Deal 3 damage to the opponent."))
	_add(cards, _fin(_with(_spell("warcry", "Warcry", A, 1, [A]), _fx(T.ON_ENTER, G.ALL_ALLY_UNITS, O.BUFF, 2, 0, CardEnums.Duration.END_OF_TURN)), R.UNCOMMON, "Your units get +2/+0 until end of turn."))
	_add(cards, _fin(_with(_trap("scorching_ward", "Scorching Ward", A, 1, [A]), _fx(T.TRAP_OPPONENT_ATTACKS, G.ALL_ATTACKERS, O.DEAL_DAMAGE, 2)), R.UNCOMMON, "Trap: when the opponent attacks, deal 2 damage to each attacker."))


static func _add_affinity_b(cards: Dictionary) -> void:
	_add(cards, _fin(_unit("frost_sentry", "Frost Sentry", B, 1, [B], 1, 4, [K.SWAT, K.WALLFLOWER]), R.COMMON, "Defender, Reach"))
	_add(cards, _fin(_with(_unit("sage", "Sage", B, 2, [B], 2, 2), _fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 1)), R.COMMON, "When this enters, draw a card."))
	_add(cards, _fin(_with(_unit("whispering_shade", "Whispering Shade", B, 2, [B], 2, 2, [K.FLYING]), _fx(T.ON_ENTER, G.OPPONENT, O.TOSS, 1)), R.UNCOMMON, "Flying. When this enters, the opponent discards a card."))
	_add(cards, _fin(_with(_spell("dissolve", "Dissolve", B, 2, [B]), _fx(T.ON_ENTER, G.CHOSEN_UNIT_ENEMY, O.DESTROY)), R.UNCOMMON, "Destroy target enemy unit."))
	_add(cards, _fin(_with(_spell("recall", "Recall", B, 0, [B]), _fx(T.ON_ENTER, G.CHOSEN_UNIT_ANY, O.SEND_BACK)), R.COMMON, "Return target unit to its owner's hand."))
	_add(cards, _fin(_with(_spell("deep_insight", "Deep Insight", B, 1, [B]), _fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 2)), R.COMMON, "Draw two cards."))
	_add(cards, _fin(_with(_trap("snare", "Snare", B, 1, [B]), _fx(T.TRAP_OPPONENT_UNIT, G.TRIGGERING_CARD, O.DESTROY)), R.UNCOMMON, "Trap: when the opponent plays a unit, destroy it."))
	_add(cards, _fin(_unit("sea_warden", "Sea Warden", B, 4, [B], 3, 5, [K.FLYING]), R.EPIC, "Flying"))


static func _add_affinity_c(cards: Dictionary) -> void:
	_add(cards, _fin(_unit("mossback_bear", "Mossback Bear", C, 2, [C], 3, 3), R.COMMON))
	_add(cards, _fin(_unit("rampaging_boar", "Rampaging Boar", C, 3, [C], 4, 3, [K.BULLDOZE]), R.COMMON, "Trample"))
	_add(cards, _fin(_unit("stag_warden", "Stag Warden", C, 3, [C], 3, 4, []), R.UNCOMMON, ""))
	_add(cards, _fin(_unit("ancient_treant", "Ancient Treant", C, 3, [C, C], 5, 5), R.UNCOMMON))
	_add(cards, _fin(_unit("thornback_colossus", "Thornback Colossus", C, 4, [C, C], 7, 7, [K.BULLDOZE]), R.EPIC, "Trample"))
	_add(cards, _fin(_with(_spell("growth", "Growth", C, 1, [C]), _fx(T.ON_ENTER, G.CHOSEN_UNIT_ALLY, O.BUFF, 2, 2)), R.COMMON, "Target ally unit gets +2/+2 permanently."))
	_add(cards, _fin(_with(_spell("rejuvenate", "Rejuvenate", C, 1, [C]), _fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_HP, 4)), R.COMMON, "Gain 4 HP."))


static func _add_affinity_d(cards: Dictionary, spirit: CardData) -> void:
	_add(cards, _fin(_with(_unit("bone_servant", "Bone Servant", D, 1, [D], 2, 1), _fx(T.ON_DEATH, G.CONTROLLER, O.DRAW, 1)), R.COMMON, "When this dies, draw a card."))
	var summon_one: EffectData = _fx(T.ON_DEATH, G.CONTROLLER, O.SUMMON_TOKEN, 1)
	summon_one.token = spirit
	_add(cards, _fin(_with(_unit("grave_tender", "Necrocrat Tender", D, 2, [D], 2, 2), summon_one), R.COMMON, "When this dies, create a 1/1 Spirit."))
	_add(cards, _fin(_with(_unit("martyr", "Martyr", D, 0, [D], 1, 1), _fx(T.ON_DEATH, G.OPPONENT, O.LOSE_HP, 3)), R.COMMON, "When this dies, the opponent loses 3 HP."))
	var drain: CardData = _with(_spell("soul_drain", "Soul Drain", D, 2, [D]), _fx(T.ON_ENTER, G.OPPONENT, O.DEAL_DAMAGE, 3))
	_add(cards, _fin(_with(drain, _fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_HP, 3)), R.UNCOMMON, "Deal 3 damage to the opponent and gain 3 HP."))
	_add(cards, _fin(_unit("bloodthirst_wolf", "Bloodthirst Wolf", D, 2, [D], 3, 2, [K.NOURISH]), R.COMMON, "Lifesteal"))
	var bargain: CardData = _with(_spell("dark_bargain", "Dark Bargain", D, 0, [D]), _fx(T.ON_ENTER, G.CHOSEN_UNIT_ALLY, O.DESTROY))
	_add(cards, _fin(_with(bargain, _fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 2)), R.UNCOMMON, "Destroy target ally unit. Draw two cards."))
	var summon_two: EffectData = _fx(T.ON_ENTER, G.CONTROLLER, O.SUMMON_TOKEN, 2)
	summon_two.token = spirit
	_add(cards, _fin(_with(_unit("necromancer", "Necromancer", D, 3, [D], 2, 3), summon_two), R.EPIC, "When this enters, create two 1/1 Spirits."))


## Brief 5: the D.N.A. zone's Necrocrat cards (Afterlife Services and Labor). 9 sold by the zone vendor
## (`ZoneCards.VENDOR_IDS`), 1 unique mini-dungeon reward. Placeholder numbers - real cards come later.
static func build_zone_cards(tokens: Dictionary) -> Dictionary:
	var cards: Dictionary = {}
	var spirit: CardData = tokens["token_spirit"]
	_add(cards, _fin(_with(_unit("cubicle_zombie", "Cubicle Zombie", D, 1, [D], 2, 2), _fx(T.ON_DEATH, G.CONTROLLER, O.GAIN_HP, 2)), R.COMMON, "When this dies, gain 2 HP.", "Has not left his desk since 1987."))
	_add(cards, _fin(_with(_unit("overdue_intern", "Overdue Intern", D, 0, [D], 1, 1, [K.HUSTLE]), _fx(T.ON_DEATH, G.CONTROLLER, O.DRAW, 1)), R.COMMON, "Hustle. When this dies, draw a card.", "Unpaid, undead, unbothered."))
	_add(cards, _fin(_with(_unit("middle_manager", "Middle Manager", D, 3, [D], 3, 3, []), _fx(T.ON_ENTER, G.ALL_ALLY_UNITS, O.BUFF, 1, 0, CardEnums.Duration.END_OF_TURN)), R.UNCOMMON, "When this enters, your units get +1/+0 until end of turn.", "Let's circle back. Forever."))
	_add(cards, _fin(_with(_unit("soul_auditor", "Soul Auditor", D, 2, [D], 2, 3, [K.FLYING]), _fx(T.ON_ENTER, G.OPPONENT, O.TOSS, 1)), R.UNCOMMON, "Flying. When this enters, the opponent discards a card.", "Your soul is missing a signature."))
	var review: CardData = _with(_spell("performance_review", "Performance Review", D, 2, [D]), _fx(T.ON_ENTER, G.CHOSEN_UNIT_ENEMY, O.DESTROY))
	_add(cards, _fin(_with(review, _fx(T.ON_ENTER, G.CONTROLLER, O.LOSE_HP, 2)), R.UNCOMMON, "Destroy target enemy unit. You lose 2 HP.", "Does not meet expectations. Or exist."))
	_add(cards, _fin(_with(_spell("mandatory_fun_day", "Mandatory Fun Day", D, 1, [D]), _fx(T.ON_ENTER, G.ALL_UNITS, O.BUFF, -1, -1)), R.UNCOMMON, "Each unit gets -1/-1 permanently.", "Attendance is compulsory. So is the cake."))
	var benefits: CardData = _with(_spell("death_benefits", "File for Death Benefits", D, 1, [D]), _fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_HP, 4))
	_add(cards, _fin(_with(benefits, _fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 1)), R.COMMON, "Gain 4 HP. Draw a card.", "Form 27-B, in triplicate. Processing time: eternity."))
	_add(cards, _fin(_with(_trap("take_a_number", "Take a Number", D, 1, [D]), _fx(T.TRAP_OPPONENT_ATTACKS, G.ALL_ATTACKERS, O.DEAL_DAMAGE, 3)), R.UNCOMMON, "Trap: when the opponent attacks, deal 3 damage to each attacker.", "Now serving: nobody. Ever."))
	var hr: CardData = _unit("hr_reaper", "HR Reaper", D, 3, [D, D], 5, 4, [K.NOURISH])
	_add(cards, _fin(_with(hr, _fx(T.ON_ENTER, G.OPPONENT, O.LOSE_HP, 2)), R.EPIC, "Nourish. When this enters, the opponent loses 2 HP.", "We're letting you go. Literally."))
	var ceo: CardData = _unit("deceased_ceo", "The Deceased CEO", D, 4, [D, D], 6, 6, [K.FLYING])
	var summon_two: EffectData = _fx(T.ON_ENTER, G.CONTROLLER, O.SUMMON_TOKEN, 2)
	summon_two.token = spirit
	_add(cards, _fin(_with(ceo, summon_two), R.LEGENDARY, "Flying. When this enters, create two 1/1 Spirits.", "Unique reward of the mini dungeon. Still takes credit for everything."))
	_add_gainlands_cards(cards)
	_add_buffet_cards(cards)
	HeapContent.add_cards(cards)
	DungeonContent.add_cards(cards)
	CapitalContent.add_cards(cards)
	PackContent.add_cards(cards)
	return cards


static func reward_pool(cards: Dictionary) -> Array[CardData]:
	var pool: Array[CardData] = []
	for id: String in ["merchant", "ironclad", "supply_cache", "pitfall"]:
		pool.append(cards[id] as CardData)
	return pool


# ---- Decks ---------------------------------------------------------------------------


## Each recipe: name, infrastructure counts by color, and spell counts by card id (28 spells + 17 infrastructure).
static func deck_recipes() -> Array[Dictionary]:
	return [
		{
			"name": "Beefcake & Gourmand",
			"infrastructure": {A: 9, B: 8},
			"spells": {
				"beefcake_imp": 3, "blade_dancer": 3, "raider": 2, "blazing_charger": 2, "firebolt": 3,
				"flame_burst": 2, "warcry": 1, "whispering_shade": 2, "dissolve": 2, "snare": 1,
				"sellsword": 3, "cave_bat": 2, "supply_cache": 2,
			},
		},
		{
			"name": "Gourmand & Refusemancer",
			"infrastructure": {B: 8, C: 9},
			"spells": {
				"frost_sentry": 1, "sage": 2, "whispering_shade": 2, "dissolve": 2, "recall": 1,
				"deep_insight": 2, "snare": 1, "sea_warden": 1, "mossback_bear": 3, "rampaging_boar": 3,
				"stag_warden": 2, "ancient_treant": 2, "growth": 1, "rejuvenate": 1, "merchant": 2,
				"rusty_curse": 2,
			},
		},
		{
			"name": "Refusemancer & Necrocrat",
			"infrastructure": {C: 9, D: 8},
			"spells": {
				"mossback_bear": 3, "rampaging_boar": 3, "stag_warden": 2, "ancient_treant": 1,
				"thornback_colossus": 1, "growth": 2, "rejuvenate": 1, "bone_servant": 2,
				"grave_tender": 2, "martyr": 2, "bloodthirst_wolf": 2, "soul_drain": 1,
				"dark_bargain": 1, "necromancer": 1, "field_medic": 2, "healing_idol": 2,
			},
		},
		{
			"name": "Necrocrat & Beefcake",
			"infrastructure": {D: 9, A: 8},
			"spells": {
				"bone_servant": 2, "grave_tender": 2, "martyr": 2, "bloodthirst_wolf": 3, "soul_drain": 2,
				"dark_bargain": 2, "necromancer": 1, "beefcake_imp": 2, "blade_dancer": 2, "raider": 2, "blazing_charger": 1,
				"firebolt": 2, "flame_burst": 2, "scorching_ward": 1, "warcry": 1, "sellsword": 1,
			},
		},
		{
			# The tutorial-dungeon starter template (docs/design/starting_deck_and_affinity.md):
			# 19 infrastructure + 23 neutral spells = 42 cards, NOT the normal 45-card minimum - the
			# `TrialOfTheHollow` MIN_DECK_SIZE waiver covers the gap until the 3 tutorial reward
			# picks fill it back out. Its infrastructure color here (A) is irrelevant: CampaignStart.
			# starter_deck() replaces every infrastructure with the player's actually-chosen color.
			"name": "Wanderer's Pack",
			"infrastructure": {A: 19},
			"spells": {
				"apprentice_blade": 3, "scrappy_recruit": 3, "sellsword": 2, "cave_bat": 2,
				"stone_sentinel": 2, "field_medic": 2, "merchant": 2, "ironclad": 1,
				"healing_idol": 1, "rusty_curse": 2, "pitfall": 1, "supply_cache": 2,
			},
		},
	]


static func build_decks(content: ContentSet) -> Array[Deck]:
	var decks: Array[Deck] = []
	for recipe: Dictionary in deck_recipes():
		var deck: Deck = Deck.new()
		deck.deck_name = str(recipe["name"])
		var infrastructure: Dictionary = recipe["infrastructure"]
		for color: Variant in infrastructure.keys():
			for i: int in range(int(infrastructure[color])):
				deck.cards.append(content.infrastructure[int(color)] as CardData)
		var spells: Dictionary = recipe["spells"]
		for id: Variant in spells.keys():
			for i: int in range(int(spells[id])):
				deck.cards.append(content.cards[str(id)] as CardData)
		decks.append(deck)
	return decks


## Brief 6: the Gainlands' Beefcake cards. 10 sold by Tiny Tony (`ZoneCards.GAINLANDS_VENDOR_IDS`), plus
## "max_rep" (a chest/enemy card) and the mini dungeon's unique "iron_titan". Placeholder numbers.
static func _add_gainlands_cards(cards: Dictionary) -> void:
	_add(cards, _fin(_with(_unit("gym_rat", "Gym Rat", A, 1, [A], 2, 2), _fx(T.ON_ATTACK, G.SELF, O.BUFF, 1, 0, CardEnums.Duration.END_OF_TURN)), R.COMMON, "Whenever this attacks, it gets +1/+0 until end of turn.", "Lives here. Pays rent in reps."))
	_add(cards, _fin(_unit("protein_golem", "Protein Shake Golem", A, 3, [A], 3, 5, []), R.UNCOMMON, "", "Chalky, lumpy and deeply supportive."))
	_add(cards, _fin(_unit("pump_chaser", "Pump Chaser", A, 2, [A], 3, 2, [K.HUSTLE]), R.UNCOMMON, "Haste", "Always one set away from the pump."))
	_add(cards, _fin(_unit("wheel_runner", "Wheel Runner", A, 1, [A], 2, 1, [K.HUSTLE, K.SUCKER_PUNCH]), R.COMMON, "Hustle, First Strike", "Goes nowhere. Very fast."))
	_add(cards, _fin(_with(_unit("mill_hand", "Mill Hand", A, 2, [A], 2, 3), _fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_HP, 2)), R.COMMON, "When this enters, gain 2 HP.", "Pushes the mill. Pushes his luck."))
	_add(cards, _fin(_with(_unit("courtesy_chucker", "Courtesy Chucker", A, 3, [A], 3, 3), _fx(T.ON_ENTER, G.OPPONENT, O.DEAL_DAMAGE, 2)), R.UNCOMMON, "When this enters, deal 2 damage to the opponent.", "Free throws. Spotter mandatory."))
	var flex: CardData = _with(_spell("flex_off", "Flex-Off", A, 1, [A]), _fx(T.ON_ENTER, G.ALL_ALLY_UNITS, O.BUFF, 2, 0, CardEnums.Duration.END_OF_TURN))
	_add(cards, _fin(_with(flex, _fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 1)), R.UNCOMMON, "Your units get +2/+0 until end of turn. Draw a card.", "Judged by the mirror, and the mirror approves."))
	_add(cards, _fin(_with(_spell("leg_day", "Leg Day", A, 2, [A]), _fx(T.ON_ENTER, G.CHOSEN_UNIT_ENEMY, O.DEAL_DAMAGE, 4)), R.UNCOMMON, "Deal 4 damage to target enemy unit.", "No skipping. Not even for you."))
	_add(cards, _fin(_with(_spell("cheat_day", "Cheat Day", A, 1, [A]), _fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_HP, 5)), R.COMMON, "Gain 5 HP.", "Calories do not count on Sundays."))
	_add(cards, _fin(_with(_spell("pre_workout", "Pre-Workout Jitters", A, 0, [A]), _fx(T.ON_ENTER, G.CHOSEN_UNIT_ALLY, O.BUFF, 2, 2)), R.COMMON, "Target ally unit gets +2/+2 permanently.", "Heart: racing. Eyes: also racing."))
	_add(cards, _fin(_unit("max_rep", "Max Rep", A, 4, [A, A], 5, 4, [K.BULLDOZE]), R.EPIC, "Trample", "One more. Always one more."))
	var titan: CardData = _unit("iron_titan", "The Iron Titan", A, 4, [A, A], 7, 6, [K.BULLDOZE])
	_add(cards, _fin(_with(titan, _fx(T.ON_ENTER, G.ALL_ALLY_UNITS, O.BUFF, 1, 1)), R.LEGENDARY, "Bulldoze. When this enters, your units get +1/+1 permanently.", "Unique reward of the Iron Cavern. Has never once skipped leg day."))


## Brief 7: the Endless Buffet's Gourmand cards. 10 sold by Dolcetta Crumb (`ZoneCards.BUFFET_VENDOR_IDS`), plus
## "tasting_menu" and "cheese_wheel_golem" (chest cards) and the Walk-In Freezer's unique "buffet_colossus".
## Gourmand = bounce, card draw and food-golem defenders. Placeholder numbers.
static func _add_buffet_cards(cards: Dictionary) -> void:
	_add(cards, _fin(_unit("breadstick_sentry", "Breadstick Sentry", B, 1, [B], 1, 3, []), R.COMMON, "", "Stands firm. Gets dunked."))
	_add(cards, _fin(_with(_unit("gravy_courier", "Gravy Boat Courier", B, 2, [B], 2, 2), _fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 1)), R.UNCOMMON, "When this enters, draw a card.", "Hot, brown and always running late."))
	_add(cards, _fin(_unit("meatloaf_golem", "Meatloaf Golem", B, 3, [B], 3, 5, []), R.UNCOMMON, "", "Has strong opinions about seasoning."))
	_add(cards, _fin(_with(_unit("gelatin_sentinel", "Gelatin Sentinel", B, 2, [B], 1, 4, []), _fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_HP, 2)), R.COMMON, "When this enters, gain 2 HP.", "Wobbles when threatened. Sets when cornered."))
	var soup: CardData = _with(_spell("soup_of_the_day", "Soup of the Day", B, 1, [B]), _fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_HP, 3))
	_add(cards, _fin(_with(soup, _fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 1)), R.COMMON, "Gain 3 HP. Draw a card.", "Ask the chef what it is. The chef does not know."))
	_add(cards, _fin(_with(_spell("sous_assist", "Sous-Chef's Assist", B, 2, [B]), _fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 2)), R.COMMON, "Draw two cards.", "Yes, Chef! Right away, Chef! Which one is the whisk, Chef?"))
	var fight: CardData = _with(_spell("food_fight", "Food Fight", B, 2, [B]), _fx(T.ON_ENTER, G.CHOSEN_UNIT_ENEMY, O.SEND_BACK))
	_add(cards, _fin(_with(fight, _fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 1)), R.UNCOMMON, "Return target enemy unit to its owner's hand. Draw a card.", "It started with a single pea."))
	_add(cards, _fin(_unit("runaway_meatball", "Runaway Meatball", B, 2, [B], 3, 1, [K.HUSTLE]), R.UNCOMMON, "Haste", "Rolls first. Apologizes never."))
	_add(cards, _fin(_with(_unit("souffle_sprite", "Souffle Sprite", B, 3, [B], 2, 2, [K.FLYING]), _fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 1)), R.UNCOMMON, "Flying. When this enters, draw a card.", "Do not open the oven door. Do not even look at it."))
	var guard: CardData = _with(_trap("sneeze_guard", "Sneeze Guard", B, 1, [B]), _fx(T.TRAP_OPPONENT_ATTACKS, G.ALL_ATTACKERS, O.DEAL_DAMAGE, 2))
	_add(cards, _fin(_with(guard, _fx(T.TRAP_OPPONENT_ATTACKS, G.CONTROLLER, O.GAIN_HP, 2)), R.UNCOMMON, "Trap: when the opponent attacks, deal 2 damage to each attacker and gain 2 HP.", "Protects the food. Mostly from you."))
	var menu: CardData = _with(_spell("tasting_menu", "Tasting Menu", B, 2, [B]), _fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 3))
	_add(cards, _fin(_with(menu, _fx(T.ON_ENTER, G.CONTROLLER, O.LOSE_HP, 2)), R.UNCOMMON, "Draw three cards. You lose 2 HP.", "Seventeen courses. Each one is a single bean."))
	_add(cards, _fin(_with(_unit("cheese_wheel_golem", "Cheese Wheel Golem", B, 4, [B, B], 4, 6, []), _fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_HP, 3)), R.EPIC, "When this enters, gain 3 HP.", "Rolls downhill at any sign of a cracker."))
	var colossus: CardData = _unit("buffet_colossus", "Colossus of the Endless Buffet", B, 5, [B, B], 6, 6, [])
	_add(cards, _fin(_with(_with(colossus, _fx(T.ON_ENTER, G.ALL_ALLY_UNITS, O.BUFF, 1, 1)), _fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_HP, 4)), R.LEGENDARY, "When this enters, your units get +1/+1 permanently and you gain 4 HP.", "Unique reward of the Walk-In Freezer. Seconds? Thirds? It is the Endless Buffet."))
