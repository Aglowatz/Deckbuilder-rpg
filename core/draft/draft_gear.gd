class_name DraftGear
extends RefCounted
## Draft mode, Phase 1 (Part 2): the eight pieces of equipment made for the draft quest line. Every one also exists in the main
## game (docs/design/draft_mode.md, point 7): the two weak ones are on Bertram's stall in Crosspath from the start, the six
## strong ones are the draft quests' rewards, and all eight are in the draft pool like every other piece. Every effect goes
## through the Modifier pipeline (no new rules).

const K := Modifier.Kind
const G := CardEnums.TargetKind
const O := CardEnums.EffectOp
const S := EquipmentData.Slot
const R := EquipmentData.Rarity

## Piece id -> where it comes from (player-facing).
const SOURCES: Dictionary = {
	"lucky_pack_wrapper": "Bertram's equipment stall, Crosspath",
	"card_sleeve_gauntlets": "Bertram's equipment stall, Crosspath",
	"first_pick_fedora": "Quest: Pick of Three (Trey Pickett)",
	"curve_topper_boots": "Quest: The Beefcake Draft (Trey Pickett)",
	"sideboard_satchel": "Quest: The Gourmand Draft (Trey Pickett)",
	"booster_wrapper_cape": "Quest: The Necrocrat Draft (Trey Pickett)",
	"the_bomb_rare": "Quest: The Refusemancer Draft (Trey Pickett)",
	"draft_champions_laurels": "Quest: Last Pick, Best Pick (Trey Pickett)",
}
## The reward of each zone draft's quest.
const ZONE_REWARDS: Dictionary = {"beefcake": "curve_topper_boots", "gourmand": "sideboard_satchel", "necrocrat": "booster_wrapper_cape", "refusemancer": "the_bomb_rare"}
const INTRO_REWARD: String = "first_pick_fedora"
const FINALE_REWARD: String = "draft_champions_laurels"
## The two weak pieces on Bertram's stall, with their prices.
const VENDOR_PIECES: Dictionary = {"lucky_pack_wrapper": 90, "card_sleeve_gauntlets": 120}


static func ids() -> Array[String]:
	var result: Array[String] = []
	for id: Variant in SOURCES.keys():
		result.append(str(id))
	return result


static func add_all(result: Dictionary) -> void:
	# -- Two weak, early pieces (tier 1, Common): on Bertram's stall.
	_add(result, "lucky_pack_wrapper", "Lucky Pack Wrapper", S.RELIC, R.COMMON, 1, "Start every duel with 1 extra HP. Gain 10% more XP from everything.", "",
		"The pack it came off had nothing good in it. The wrapper has been apologising ever since.", [_mod(K.STARTING_HP, 1), _mod(K.XP_BONUS_PERCENT, 10)])
	_add(result, "card_sleeve_gauntlets", "Card-Sleeve Gauntlets", S.WEAPON, R.COMMON, 1, "When a duel starts, deal 2 damage to the opponent.", "",
		"Double-sleeved, for protection. Yours, not theirs.", [_eff(K.START_OF_DUEL_EFFECT, O.DEAL_DAMAGE, 2, G.OPPONENT)])
	# -- The introduction's prize (tier 2, Uncommon).
	_add(result, "first_pick_fedora", "First-Pick Fedora", S.HELM, R.UNCOMMON, 2, "Your opening hand has 1 more card.", "",
		"Tip it at the table before you sit down. Nobody takes the card you wanted from a hat like that.", [_mod(K.OPENING_HAND_SIZE, 1)])
	# -- The four zone drafts' prizes (tier 3, Epic): strong, each with a price or a narrow use.
	_add(result, "curve_topper_boots", "Curve-Topper Boots", S.BOOTS, R.RARE, 3, "Your units get +1 attack. You draw an extra card on your first turn.", "Max HP -3.",
		"Every deck needs something big at the top. These are for getting there first.", [_mod(K.STAT_CHANGE, 1, Modifier.ANY_COLOR, 0), _mod(K.FIRST_TURN_EXTRA_DRAW, 1), _mod(K.MAX_HP, -3)])
	_add(result, "sideboard_satchel", "Sideboard Satchel", S.RELIC, R.RARE, 3, "When a duel starts, draw 2 cards and gain 2 HP.", "",
		"Fifteen cards you swore you would never need, and one sandwich.", [_eff(K.START_OF_DUEL_EFFECT, O.DRAW, 2, G.CONTROLLER), _eff(K.START_OF_DUEL_EFFECT, O.GAIN_HP, 2, G.CONTROLLER)])
	_add(result, "booster_wrapper_cape", "Booster-Wrapper Cape", S.ARMOR, R.RARE, 3, "Max HP +3. Whenever one of your units dies, gain 1 HP.", "",
		"Stitched from four hundred foil wrappers. It crinkles when you are winning.", [_mod(K.MAX_HP, 3), _eff(K.ON_ALLY_DEATH_EFFECT, O.GAIN_HP, 1, G.CONTROLLER)])
	_add(result, "the_bomb_rare", "The Bomb Rare", S.WEAPON, R.RARE, 3, "Your units get +1/+1.", "Your opening hand has 1 fewer card.",
		"Somebody passed this. Somebody has regretted it every day since.", [_mod(K.STAT_CHANGE, 1, Modifier.ANY_COLOR, 1), _mod(K.OPENING_HAND_SIZE, -1)])
	# -- The finale's prize (tier 3, Legendary).
	_add(result, "draft_champions_laurels", "Draft Champion's Laurels", S.HELM, R.LEGENDARY, 3, "Your opening hand has 1 more card, and you draw an extra card each turn.", "Max HP -5.",
		"Woven from the corners of first picks. Heavy with other people's second choices.", [_mod(K.OPENING_HAND_SIZE, 1), _mod(K.EXTRA_DRAWS, 1), _mod(K.MAX_HP, -5)])


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
