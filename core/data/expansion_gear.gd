class_name ExpansionGear
extends RefCounted
## Overnight Oct 16, Block 2: 25 new pieces of equipment, every effect through the Modifier pipeline. Five weak early pieces, four resource
## pieces, four strong pieces with real drawbacks, one buff per Path, five keyword pieces, two utility pieces and Gotta-Go Galoshes (overworld
## speed +35%, the Gainlands main quest's midpoint). Where each one comes from: `SOURCES` (docs/design/equipment.md).
## Kept out of `ProgressionContent.equipment()` (the town vendor's original ten) like every zone piece: `ContentSet.equipment_piece` finds them.

const K := Modifier.Kind
const KW := CardEnums.Keyword
const G := CardEnums.TargetKind
const O := CardEnums.EffectOp
const S := EquipmentData.Slot
const R := EquipmentData.Rarity
const B: int = Affinity.Type.BEEFCAKE
const N: int = Affinity.Type.NECROCRAT
const GO: int = Affinity.Type.GOURMAND
const RE: int = Affinity.Type.REFUSEMANCER

## Piece id -> where it comes from (player-facing; the distribution itself lives in the quest, dungeon, vendor and chest tables).
const SOURCES: Dictionary = {
	"lucky_sock": "Hidden chests (tier 1)", "cardboard_cuirass": "Bertram's equipment stall, Crosspath", "pointy_stick": "The Door Under the Well (first clear)",
	"saucepan_helmet": "Bertram's equipment stall, Crosspath", "flip_flops": "Benchley's Protein & Pasteboard (the Gainlands); the Compost Grange (the Dump)",
	"kettlebell_locket": "Quest: Juice the Station (Foreman Gus)", "red_tape_dispenser": "Main quest Take a Number (midpoint)", "doggy_bag": "Main quest Key Ingredients (midpoint)",
	"dumpster_gloves": "Main quest Root Cause (midpoint)", "glass_jaw_gauntlets": "The House of Gains (first clear)", "overdue_library_book": "The Hall of Final Approvals (first clear)",
	"elastic_waistband": "The Test Kitchen (first clear)", "hubris_crown": "The Old Service Tunnels (first clear)", "protein_bandolier": "Benchley's Protein & Pasteboard, once the Gainlands are free",
	"notary_seal": "Clerk Ledgerbone's Requisitions, once the D.N.A. is free", "rolling_pin": "Mirepoix's Dessert & Deckery, once the Buffet is free", "raccoon_crown": "The Rotheart (first clear)",
	"hustle_headband": "Mount Swolympus (first clear, postgame)", "paper_plane_cape": "Sub-Basement 3 (first clear)", "mystery_stain_bib": "The Landfill Depths (first clear)",
	"velvet_rope": "The Walk-In Freezer (first clear)", "sucker_punch_mitts": "Granny Gristle's Compost Grange, once the Dump is free; hidden chests (tier 2)",
	"dog_eared_bookmark": "Mirepoix's Dessert & Deckery; hidden chests (tier 2)", "participation_trophy": "Quest: Meet the Merchants", "gotta_go_galoshes": "Main quest Raise the Bar (midpoint)",
}


static func add_all(result: Dictionary) -> void:
	# -- Five weak early pieces (tier 1, common): small and cheap.
	_add(result, "lucky_sock", "Lucky Sock", S.RELIC, R.COMMON, 1, "Start every duel with 2 extra HP.", "",
		"Unwashed since the tutorial. That's what makes it lucky.", [_mod(K.STARTING_HP, 2)])
	_add(result, "cardboard_cuirass", "Cardboard Cuirass", S.ARMOR, R.COMMON, 1, "Max HP +2.", "",
		"Box-fresh armour. Literally. Do not get it wet.", [_mod(K.MAX_HP, 2)])
	_add(result, "pointy_stick", "A Very Pointy Stick", S.WEAPON, R.COMMON, 1, "When a duel starts, deal 1 damage to the opponent.", "",
		"Found on the ground. Sharpened on a rock. Named with love.", [_eff(K.START_OF_DUEL_EFFECT, O.DEAL_DAMAGE, 1, G.OPPONENT)])
	_add(result, "saucepan_helmet", "Saucepan Helmet", S.HELM, R.COMMON, 1, "Max HP +1, and start every duel with 1 extra HP.", "",
		"Handle in the back, for steering. Smells faintly of soup.", [_mod(K.MAX_HP, 1), _mod(K.STARTING_HP, 1)])
	_add(result, "flip_flops", "Flip-Flops of Fortitude", S.BOOTS, R.COMMON, 1, "Whenever one of your units dies, gain 1 HP.", "",
		"Thwap. Thwap. Thwap. The sound of a hero who has given up on socks.", [_eff(K.ON_ALLY_DEATH_EFFECT, O.GAIN_HP, 1, G.CONTROLLER)])
	# -- Four resource pieces (tier 2): generate Iron, Red Tape, Ingredients and Garbage (the starting-resource pieces already exist).
	_add(result, "kettlebell_locket", "Kettlebell Locket", S.RELIC, R.UNCOMMON, 2, "Whenever you declare attackers, create 1 Iron.", "",
		"Every rep counts. Mostly toward a sore neck.", [_eff_ab(K.ON_ATTACK_DECLARED_EFFECT, O.CREATE_RESOURCE, int(ResourceKind.Kind.IRON), 1, G.CONTROLLER)])
	_add(result, "red_tape_dispenser", "Red Tape Dispenser", S.RELIC, R.UNCOMMON, 2, "At the start of your turn, create 1 Red Tape.", "",
		"Pull here. Then fill out a form explaining why you pulled.", [_eff_ab(K.START_OF_TURN_EFFECT, O.CREATE_RESOURCE, int(ResourceKind.Kind.RED_TAPE), 1, G.CONTROLLER)])
	_add(result, "doggy_bag", "Doggy Bag", S.ARMOR, R.UNCOMMON, 2, "At the end of your turn, create 1 Ingredient.", "",
		"Leftovers are just tomorrow's lunch with better self-esteem.", [_eff_ab(K.END_OF_TURN_EFFECT, O.CREATE_RESOURCE, int(ResourceKind.Kind.INGREDIENT), 1, G.CONTROLLER)])
	_add(result, "dumpster_gloves", "Dumpster Diving Gloves", S.WEAPON, R.UNCOMMON, 2, "Whenever one of your units dies, create 2 Garbage.", "",
		"One person's trash is another person's starting hand.", [_eff_ab(K.ON_ALLY_DEATH_EFFECT, O.CREATE_RESOURCE, int(ResourceKind.Kind.GARBAGE), 2, G.CONTROLLER)])
	# -- Four powerful pieces with real drawbacks (tier 3).
	_add(result, "glass_jaw_gauntlets", "Glass Jaw Gauntlets", S.WEAPON, R.RARE, 3, "Your units get +2 attack.", "You start every duel with 3 less HP.",
		"Hits like a truck. Takes a punch like a soufflé.", [_mod(K.STAT_CHANGE, 2, Modifier.ANY_COLOR, 0), _mod(K.STARTING_HP, -3)])
	_add(result, "overdue_library_book", "Overdue Library Book", S.RELIC, R.RARE, 3, "Draw 2 extra cards each turn.", "Then discard a random card at the start of your turn.",
		"Due back in 1987. The fines are now sentient.", [_mod(K.EXTRA_DRAWS, 2), _eff(K.START_OF_TURN_EFFECT, O.TOSS, 1, G.CONTROLLER)])
	_add(result, "elastic_waistband", "Elastic Waistband of Victory", S.ARMOR, R.RARE, 3, "Your units get +1/+1.", "You can play only 2 non-infrastructure cards per turn.",
		"Built for the Endless Buffet. Stretches to fit any ambition.", [_mod(K.STAT_CHANGE, 1, Modifier.ANY_COLOR, 1), _mod(K.MAX_NON_INFRASTRUCTURE_PLAYS_PER_TURN, 2)])
	_add(result, "hubris_crown", "Crown of Mild Hubris", S.HELM, R.LEGENDARY, 3, "You always go first and draw an extra card on your first turn.", "Max HP -4.",
		"Heavy is the head that wears the crown. Mostly because it's very heavy.", [_mod(K.ALWAYS_FIRST, 1), _mod(K.FIRST_TURN_EXTRA_DRAW, 1), _mod(K.MAX_HP, -4)])
	# -- One buff per Path (tier 2).
	_add(result, "protein_bandolier", "Protein Shaker Bandolier", S.ARMOR, R.UNCOMMON, 2, "Your Beefcake units get +1/+1.", "",
		"Six shakers, one for every meal, and a seventh for emotional support.", [_mod(K.STAT_CHANGE, 1, B, 1)])
	_add(result, "notary_seal", "Notarized Seal of Unlife", S.RELIC, R.UNCOMMON, 2, "Your Necrocrat units get +0/+2.", "",
		"Signed, sealed, deceased. Valid in all known afterlives.", [_mod(K.STAT_CHANGE, 0, N, 2)])
	_add(result, "rolling_pin", "Grandma's Rolling Pin", S.WEAPON, R.UNCOMMON, 2, "Your Gourmand cards cost 1 less generic energy.", "",
		"Rolls dough, flattens arguments. Grandma never lost either.", [_mod(K.COST_CHANGE, -1, GO, 0)])
	_add(result, "raccoon_crown", "Trash Panda Tiara", S.HELM, R.RARE, 2, "Your Refusemancer units get +1/+1.", "",
		"Worn by the true monarch of the bins. All hail. All scavenge.", [_mod(K.STAT_CHANGE, 1, RE, 1)])
	# -- Five keyword pieces (tier 2): a keyword for your units, under a condition.
	_add(result, "hustle_headband", "Side-Hustle Headband", S.HELM, R.UNCOMMON, 2, "Your Beefcake units have Hustle.", "",
		"For when one grind just isn't enough grind.", [_mod(K.GRANT_KEYWORD_TO_UNITS, int(KW.HUSTLE), B, 0)])
	_add(result, "paper_plane_cape", "Paper-Plane Cape", S.ARMOR, R.UNCOMMON, 2, "Your Necrocrat units have Flying.", "",
		"Folded from a rejected appeal. It flies better than it was ever filed.", [_mod(K.GRANT_KEYWORD_TO_UNITS, int(KW.FLYING), N, 0)])
	_add(result, "mystery_stain_bib", "Mystery-Stain Bib", S.ARMOR, R.UNCOMMON, 2, "Your Refusemancer units have Toxic.", "",
		"Nobody knows what the stain is. Nobody wants to. It is load-bearing now.", [_mod(K.GRANT_KEYWORD_TO_UNITS, int(KW.TOXIC), RE, 0)])
	_add(result, "velvet_rope", "Velvet Rope", S.RELIC, R.UNCOMMON, 2, "Your Gourmand units get +0/+3.", "They have Wallflower (they cannot attack).",
		"Sorry, the kitchen is reservation-only. You are not on the list.", [_mod(K.STAT_CHANGE, 0, GO, 3), _mod(K.GRANT_KEYWORD_TO_UNITS, int(KW.WALLFLOWER), GO, 0)])
	_add(result, "sucker_punch_mitts", "Sucker Punch Mitts", S.WEAPON, R.RARE, 2, "Your units have Sucker Punch (they deal combat damage first).", "Your units get -1 defense.",
		"Rule one of the fight club: hit first, apologise never.", [_mod(K.GRANT_KEYWORD_TO_UNITS, int(KW.SUCKER_PUNCH), Modifier.ANY_COLOR, 0), _mod(K.STAT_CHANGE, 0, Modifier.ANY_COLOR, -1)])
	# -- Two utility pieces.
	_add(result, "dog_eared_bookmark", "Dog-Eared Bookmark", S.RELIC, R.UNCOMMON, 2, "When a duel starts, draw 2 cards.", "",
		"Saves your place. And sometimes your life.", [_eff(K.START_OF_DUEL_EFFECT, O.DRAW, 2, G.CONTROLLER)])
	_add(result, "participation_trophy", "Participation Trophy", S.RELIC, R.COMMON, 1, "Gain 25% more XP from everything.", "",
		"You showed up. That's basically winning. The trophy agrees.", [_mod(K.XP_BONUS_PERCENT, 25)])
	# -- Movement.
	_add(result, "gotta_go_galoshes", "Gotta-Go Galoshes", S.BOOTS, R.RARE, 2, "You walk 35% faster in the overworld.", "",
		"For when you absolutely, positively have to be somewhere else. Now.", [_mod(K.OVERWORLD_SPEED_PERCENT, 35)])


static func ids() -> Array[String]:
	var result: Array[String] = []
	for id: Variant in SOURCES.keys():
		result.append(str(id))
	return result


static func _add(result: Dictionary, id: String, title: String, slot: EquipmentData.Slot, rarity: EquipmentData.Rarity, tier: int, effect_text: String, drawback: String, flavor: String, modifiers: Array[Modifier]) -> void:
	var description: String = effect_text if drawback.is_empty() else "%s %s" % [effect_text, drawback]
	var piece: EquipmentData = ProgressionContent._piece(id, title, slot, description, modifiers, tier >= 3)
	piece.flavor_text = flavor
	piece.rarity = rarity
	piece.tier = tier
	piece.drawback = drawback
	piece.source = str(SOURCES.get(id, ""))
	result[id] = piece


static func _mod(kind: Modifier.Kind, value: int, color: int = Modifier.ANY_COLOR, value2: int = 0) -> Modifier:
	return ProgressionContent._mod(kind, value, color, value2)


static func _eff(kind: Modifier.Kind, op: CardEnums.EffectOp, amount: int, target: CardEnums.TargetKind) -> Modifier:
	return ProgressionContent._mod_effect(kind, ProgressionContent._effect(op, amount, target))


static func _eff_ab(kind: Modifier.Kind, op: CardEnums.EffectOp, amount: int, amount2: int, target: CardEnums.TargetKind) -> Modifier:
	return ProgressionContent._mod_effect(kind, ProgressionContent._effect_ab(op, amount, amount2, target))


## The first clear of each dungeon pays one of the new pieces (main dungeons by zone id, side dungeons by dungeon id).
const DUNGEON_GEAR: Dictionary = {
	"beefcake": "glass_jaw_gauntlets", "necrocrat": "overdue_library_book", "gourmand": "elastic_waistband", "refusemancer": "raccoon_crown",
	"S-TOWN": "pointy_stick", "S-NECRO": "paper_plane_cape", "S-GOUR": "velvet_rope", "S-REF": "mystery_stain_bib", "S-CAP": "hubris_crown", "S-BEEF": "hustle_headband",
}


## Each zone's shop stocks two or three pieces: [id, price, Condition or null]. The Path pieces wait until that zone is free.
static func zone_vendor_stock(zone_id: String) -> EquipmentVendorData:
	var data: EquipmentVendorData = EquipmentVendorData.new()
	var freed: Condition = Condition.flag(str(ZoneCompletion.flag_name(zone_id)))
	match zone_id:
		# Overnight Oct 29: prices from the curve (Economy.gear_price, docs/design/economy.md): arrival stock tier 1-2, freed Path pieces tier 2-3.
		"beefcake":
			data.add("flip_flops", Economy.gear_price(R.COMMON, 2))
			data.add("protein_bandolier", Economy.gear_price(R.UNCOMMON, 2), freed)
		"necrocrat":
			data.add("notary_seal", Economy.gear_price(R.UNCOMMON, 2), freed)
			data.add("dog_eared_bookmark", Economy.gear_price(R.UNCOMMON, 2))
		"gourmand":
			data.add("rolling_pin", Economy.gear_price(R.RARE, 3), freed)
			data.add("dog_eared_bookmark", Economy.gear_price(R.UNCOMMON, 2))
			data.add("saucepan_helmet", Economy.gear_price(R.COMMON, 1))
		"refusemancer":
			data.add("flip_flops", Economy.gear_price(R.COMMON, 2))
			data.add("sucker_punch_mitts", Economy.gear_price(R.RARE, 3), freed)
	return data


## Total `value` of every equipped modifier of `kind` (gear effects outside battle: overworld speed, the XP bonus).
static func equipped_total(profile: PlayerProfile, kind: Modifier.Kind) -> int:
	var total: int = 0
	if profile == null:
		return total
	for source: ModifierSource in profile.equipment:
		if source == null:
			continue
		for modifier: Modifier in source.modifiers:
			if modifier != null and modifier.kind == kind:
				total += modifier.value
	return total
