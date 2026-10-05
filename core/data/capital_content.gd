class_name CapitalContent
extends RefCounted
## Brief 10: the cards of the Capital and Primm's Castle. Primm's enforcers and corrupted creatures (neutral), the four
## Path-quest reward cards, Primm's own cards and the unique card for beating him. Placeholder numbers - real cards come
## later (balance is out of scope). The junk card the Refusemancer service debuff shuffles into your deck is a token.

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

const JUNK_ID: String = "junk_rubbish"
## The four quest reward cards (one per Path), by Path.
const QUEST_REWARD_IDS: Array[String] = ["freed_wheel_crew", "odiles_real_recipe", "grandfather_marrow", "rescued_compost_heap"]
const FINAL_REWARD_ID: String = "the_paths_united"
## Sold at Fig Sly's black market (cards that already exist, the rare ones).
const BLACK_MARKET_CARD_IDS: Array[String] = ["hr_reaper", "moss_titan", "cheese_wheel_golem", "max_rep", "tasting_menu", "recycle_bin", "necromancer", "ancient_treant"]


## The junk token (a spell nobody wants): "Heap of Rubbish".
static func add_tokens(tokens: Dictionary) -> void:
	var junk: CardData = CardBuilder.spell(JUNK_ID, "Heap of Rubbish", N, 1, [] as Array[Affinity.Type])
	junk = CardBuilder.with_effect(junk, ContentDefinitions._fx(T.ON_ENTER, G.CONTROLLER, O.LOSE_LIFE, 1))
	junk.rarity = R.COMMON
	junk.is_token = true
	junk.rules_text = "You lose 1 life. Somebody has to take it out."
	junk.flavor_text = "Banished behind the facade for being untidy. It did not go quietly."
	tokens[JUNK_ID] = junk


static func add_cards(cards: Dictionary) -> void:
	# ---- Primm's enforcers and corrupted creatures (neutral) ----
	cards["compliance_officer"] = _make("compliance_officer", "Compliance Officer", N, 2, [], 2, 3, [], R.COMMON, "", "This is a courtesy citation. It is also a warning. It is also your fifth.", [])
	cards["perfection_inspector"] = _make("perfection_inspector", "Perfection Inspector", N, 3, [], 2, 3, [K.FLYING], R.UNCOMMON, "Flying. When this enters, the opponent discards a card.", "Your smile is 0.4 degrees off regulation.",
		[ContentDefinitions._fx(T.ON_ENTER, G.OPPONENT, O.DISCARD, 1)])
	cards["tidy_bot"] = _make("tidy_bot", "Tidy-Bot", N, 1, [], 1, 2, [K.HASTE], R.COMMON, "Haste", "Scrubs the streets. Scrubs the people. Scrubs the memory of the people.", [])
	cards["gate_guard"] = _make("gate_guard", "Gate Guard", N, 3, [], 3, 4, [K.GUARD], R.COMMON, "Guard", "Halt. State your height.", [])
	cards["approved_gate_captain"] = _make("approved_gate_captain", "The Approved Gate Captain", N, 5, [], 5, 6, [K.GUARD, K.VIGILANCE], R.EPIC, "Guard, vigilance. When this enters, your creatures get +1/+1 permanently.", "Has measured eleven thousand visitors. Approved four.",
		[ContentDefinitions._fx(T.ON_ENTER, G.ALL_ALLY_CREATURES, O.BUFF, 1, 1)])
	cards["rift_wretch"] = _make("rift_wretch", "Rift Wretch", N, 3, [], 4, 3, [K.TRAMPLE], R.UNCOMMON, "Trample", "A person-shaped tear in reality. It still remembers its name. It will not say it.", [])
	cards["shard_swarm"] = _make("shard_swarm", "Shard Swarm", N, 2, [], 2, 1, [K.FLYING, K.HASTE], R.COMMON, "Flying, haste", "Glass-bright, hungry, and very sorry about it.", [])
	var citation: CardData = _spell("citation", "Citation", N, 2, ContentDefinitions._fx(T.ON_ENTER, G.CHOSEN_CREATURE_ENEMY, O.DEAL_DAMAGE, 3))
	cards["citation"] = ContentDefinitions._fin(citation, R.COMMON, "Deal 3 damage to target enemy creature.", "Violation 4,112: Existing Without a Permit.")
	var decree: CardData = _spell("decree_of_order", "Decree of Order", N, 3, ContentDefinitions._fx(T.ON_ENTER, G.ALL_ALLY_CREATURES, O.BUFF, 2, 0, CardEnums.Duration.END_OF_TURN))
	cards["decree_of_order"] = ContentDefinitions._fin(decree, R.UNCOMMON, "Your creatures get +2/+0 until end of turn.", "For their own good. Effective immediately. Retroactively.")
	# ---- The four Path-quest rewards ----
	cards["freed_wheel_crew"] = _make("freed_wheel_crew", "The Freed Wheel Crew", A, 3, [A], 4, 3, [K.HASTE], R.EPIC, "Haste. When this enters, your creatures get +1/+0 until end of turn.", "They ran for ten years. Now they are running somewhere on purpose.",
		[ContentDefinitions._fx(T.ON_ENTER, G.ALL_ALLY_CREATURES, O.BUFF, 1, 0, CardEnums.Duration.END_OF_TURN)])
	var recipe: CardData = _spell("odiles_real_recipe", "Odile's Real Recipe", B, 2, ContentDefinitions._fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_LIFE, 6))
	cards["odiles_real_recipe"] = ContentDefinitions._fin(ContentDefinitions._with(recipe, ContentDefinitions._fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 1)), R.EPIC, "Gain 6 life. Draw a card.", "Salt. Actual salt. A pinch of defiance.")
	cards["grandfather_marrow"] = _make("grandfather_marrow", "Grandfather Marrow", D, 3, [D], 3, 4, [K.GUARD], R.EPIC, "Guard. When this dies, gain 4 life.", "At rest at last. He would like it noted that he was never late.",
		[ContentDefinitions._fx(T.ON_DEATH, G.CONTROLLER, O.GAIN_LIFE, 4)])
	cards["rescued_compost_heap"] = _make("rescued_compost_heap", "The Rescued Compost Heap", C, 2, [C], 2, 5, [K.GUARD], R.EPIC, "Guard. When this enters, gain 3 life.", "Banished for being untidy. Returned for being alive.",
		[ContentDefinitions._fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_LIFE, 3)])
	# ---- Primm's own cards (boss decks) and the final reward ----
	cards["primm_perfect_citizen"] = _make("primm_perfect_citizen", "Perfect Citizen", N, 2, [], 3, 3, [], R.UNCOMMON, "", "Identical, to the thread.", [])
	cards["primm_standard_issue"] = _make("primm_standard_issue", "Standard-Issue Soldier", N, 3, [], 3, 3, [K.VIGILANCE], R.UNCOMMON, "Vigilance", "One size fits all. It does not fit anyone.", [])
	var correction: CardData = _spell("primm_correction", "Correction", N, 3, ContentDefinitions._fx(T.ON_ENTER, G.CHOSEN_CREATURE_ENEMY, O.DESTROY))
	cards["primm_correction"] = ContentDefinitions._fin(correction, R.EPIC, "Destroy target enemy creature.", "A small adjustment. It was never going to hurt. It hurt.")
	cards["the_paths_united"] = _make("the_paths_united", "The Paths, United", N, 5, [], 6, 6, [K.VIGILANCE, K.TRAMPLE], R.LEGENDARY, "Vigilance, trample. When this enters, your creatures get +1/+1 permanently and you draw two cards.",
		"Unique reward for toppling Primm. Four ways of doing things, side by side. It is better, and it is messier, and that is the point.",
		[ContentDefinitions._fx(T.ON_ENTER, G.ALL_ALLY_CREATURES, O.BUFF, 1, 1), ContentDefinitions._fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 2)])


static func _make(id: String, title: String, color: Affinity.Type, generic: int, pips: Array, power: int, toughness: int, keywords: Array, rarity: CardEnums.Rarity, rules: String, flavor: String, effects: Array) -> CardData:
	var card: CardData = ContentDefinitions._creature(id, title, color, generic, pips, power, toughness, keywords)
	for effect: EffectData in effects:
		card = ContentDefinitions._with(card, effect)
	return ContentDefinitions._fin(card, rarity, rules, flavor)


static func _spell(id: String, title: String, color: Affinity.Type, generic: int, effect: EffectData) -> CardData:
	return ContentDefinitions._with(ContentDefinitions._spell(id, title, color, generic, []), effect)
