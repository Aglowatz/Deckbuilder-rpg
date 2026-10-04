class_name HeapContent
extends RefCounted
## Brief 8: the Verdant Dump's Refusemancer cards. 10 sold by Farmer Hob (`ZoneCards.HEAP_VENDOR_IDS`), plus
## "recycle_bin" and "moss_titan" (chest cards) and the Landfill Depths' unique "heap_mother". Refusemancer =
## big sturdy creatures, life gain and growth. Placeholder numbers - real cards come later.

const C: Affinity.Type = Affinity.Type.C
const T := CardEnums.Trigger
const G := CardEnums.TargetKind
const O := CardEnums.EffectOp
const K := CardEnums.Keyword
const R := CardEnums.Rarity


static func add_cards(cards: Dictionary) -> void:
	cards["scrap_goat"] = _make("scrap_goat", "Scrap Goat", 1, [C], 2, 2, [], R.COMMON, "When this enters, gain 2 life.", "Eats the garbage, thrives on it, and has been told off for eating the sign.",
		[ContentDefinitions._fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_LIFE, 2)])
	cards["tin_can_raccoon"] = _make("tin_can_raccoon", "Tin Can Raccoon", 2, [C], 2, 3, [], R.COMMON, "When this dies, draw a card.", "One person's trash is another raccoon's entire personality.",
		[ContentDefinitions._fx(T.ON_DEATH, G.CONTROLLER, O.DRAW, 1)])
	cards["compost_golem"] = _make("compost_golem", "Compost Golem", 3, [C], 3, 4, [K.GUARD], R.UNCOMMON, "Guard. When this enters, gain 2 life.", "Warm to the touch. Smells like a promise.",
		[ContentDefinitions._fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_LIFE, 2)])
	cards["dung_beetle"] = _make("dung_beetle", "Giant Dung Beetle", 2, [C], 2, 4, [K.GUARD], R.COMMON, "Guard", "Rolls the whole kingdom's problems into one ball. Happily.", [])
	cards["landfill_hog"] = _make("landfill_hog", "Landfill Hog", 3, [C], 5, 4, [K.TRAMPLE], R.UNCOMMON, "Trample", "Has never met a pile it did not want to be on top of.", [])
	var snare: CardData = _spell("vine_snare", "Vine Snare", 2, [C], ContentDefinitions._fx(T.ON_ENTER, G.CHOSEN_CREATURE_ENEMY, O.DEAL_DAMAGE, 3))
	cards["vine_snare"] = ContentDefinitions._fin(snare, R.UNCOMMON, "Deal 3 damage to target enemy creature.", "The vines are not malicious. They are just very, very enthusiastic.")
	var burst: CardData = _spell("fertilizer_burst", "Fertilizer Burst", 2, [C], ContentDefinitions._fx(T.ON_ENTER, G.ALL_ALLY_CREATURES, O.BUFF, 1, 1))
	cards["fertilizer_burst"] = ContentDefinitions._fin(burst, R.UNCOMMON, "Your creatures get +1/+1 permanently.", "Everything grows better with a little dung. Everything.")
	var moon: CardData = _spell("harvest_moon", "Harvest Moon", 2, [C], ContentDefinitions._fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_LIFE, 5))
	cards["harvest_moon"] = ContentDefinitions._fin(ContentDefinitions._with(moon, ContentDefinitions._fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 1)), R.COMMON, "Gain 5 life. Draw a card.", "The crops come in under a golden light. So do the raccoons.")
	var sprout: CardData = _spell("sprout_surge", "Sprout Surge", 1, [C], ContentDefinitions._fx(T.ON_ENTER, G.CHOSEN_CREATURE_ALLY, O.BUFF, 2, 2))
	cards["sprout_surge"] = ContentDefinitions._fin(sprout, R.COMMON, "Target ally creature gets +2/+2 permanently.", "Overnight. Roughly overnight. Some of it is still sprouting.")
	var trap: CardData = ContentDefinitions._trap("bramble_trap", "Bramble Trap", C, 1, ContentDefinitions._pips([C]))
	cards["bramble_trap"] = ContentDefinitions._fin(ContentDefinitions._with(trap, ContentDefinitions._fx(T.TRAP_OPPONENT_ATTACKS, G.ALL_ATTACKERS, O.DEAL_DAMAGE, 3)), R.UNCOMMON, "Trap: when the opponent attacks, deal 3 damage to each attacker.", "Please do not feed the brambles. They will eat the sign.")
	var bin: CardData = _spell("recycle_bin", "Recycle Bin", 1, [C], ContentDefinitions._fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 2))
	cards["recycle_bin"] = ContentDefinitions._fin(ContentDefinitions._with(bin, ContentDefinitions._fx(T.ON_ENTER, G.CONTROLLER, O.LOSE_LIFE, 1)), R.UNCOMMON, "Draw two cards. You lose 1 life.", "Blue bin: bottles. Green bin: leaves. Gold bin: you, apparently.")
	cards["moss_titan"] = _make("moss_titan", "Moss Titan", 4, [C, C], 6, 6, [K.GUARD], R.EPIC, "Guard. When this enters, gain 3 life.", "A junk mountain that got up and decided to garden.",
		[ContentDefinitions._fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_LIFE, 3)])
	var mother: CardData = _make("heap_mother", "Mother of the Dump", 5, [C, C], 7, 7, [K.TRAMPLE], R.LEGENDARY, "Trample. When this enters, your creatures get +1/+1 permanently and you gain 5 life.", "Unique reward of the Landfill Depths. Everything thrown away ends up in her care.",
		[ContentDefinitions._fx(T.ON_ENTER, G.ALL_ALLY_CREATURES, O.BUFF, 1, 1), ContentDefinitions._fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_LIFE, 5)])
	cards["heap_mother"] = mother


static func _make(id: String, title: String, generic: int, pips: Array, power: int, toughness: int, keywords: Array, rarity: CardEnums.Rarity, rules: String, flavor: String, effects: Array) -> CardData:
	var card: CardData = ContentDefinitions._creature(id, title, C, generic, pips, power, toughness, keywords)
	for effect: EffectData in effects:
		card = ContentDefinitions._with(card, effect)
	return ContentDefinitions._fin(card, rarity, rules, flavor)


static func _spell(id: String, title: String, generic: int, pips: Array, effect: EffectData) -> CardData:
	return ContentDefinitions._with(ContentDefinitions._spell(id, title, C, generic, pips), effect)
