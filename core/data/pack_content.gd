class_name PackContent
extends RefCounted
## Pack system: one pack-eligible Legendary per Path. Every other Legendary of the game is a unique reward (mini dungeon, main
## dungeon, quest, Primm) and is flagged `not_in_packs`, so without these a Path Pack could never open a Legendary. Placeholder
## numbers and names - real cards come later (balance is out of scope).

const A: Affinity.Type = Affinity.Type.BEEFCAKE
const B: Affinity.Type = Affinity.Type.GOURMAND
const C: Affinity.Type = Affinity.Type.REFUSEMANCER
const D: Affinity.Type = Affinity.Type.NECROCRAT
const T := CardEnums.Trigger
const G := CardEnums.TargetKind
const O := CardEnums.EffectOp
const K := CardEnums.Keyword
const R := CardEnums.Rarity

const LEGENDARY_IDS: Array[String] = ["deadlift_deity", "grand_banquet", "compost_elder", "grim_auditor"]


static func add_cards(cards: Dictionary) -> void:
	var deity: CardData = ContentDefinitions._unit("deadlift_deity", "The Deadlift Deity", A, 4, [A, A], 7, 5, [K.BULLDOZE, K.HUSTLE])
	cards["deadlift_deity"] = ContentDefinitions._fin(deity, R.LEGENDARY, "Hustle, bulldoze", "Lifts the bar. Lifts the room. Lifts the mood, mostly.")
	var banquet: CardData = ContentDefinitions._spell("grand_banquet", "The Grand Banquet", B, 4, [B, B])
	banquet = ContentDefinitions._with(banquet, ContentDefinitions._fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 3))
	banquet = ContentDefinitions._with(banquet, ContentDefinitions._fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_HP, 5))
	cards["grand_banquet"] = ContentDefinitions._fin(banquet, R.LEGENDARY, "Draw three cards. Gain 5 HP.", "Seven courses, four sauces, and a toast nobody remembers giving.")
	var elder: CardData = ContentDefinitions._unit("compost_elder", "The Compost Elder", C, 4, [C, C], 6, 8, [])
	elder = ContentDefinitions._with(elder, ContentDefinitions._fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_HP, 4))
	cards["compost_elder"] = ContentDefinitions._fin(elder, R.LEGENDARY, "When this enters, gain 4 HP.", "Older than the dump. Ripe, wise and faintly steaming.")
	var auditor: CardData = ContentDefinitions._unit("grim_auditor", "The Grim Auditor", D, 4, [D, D], 5, 5, [K.FLYING, K.NOURISH])
	auditor = ContentDefinitions._with(auditor, ContentDefinitions._fx(T.ON_ENTER, G.OPPONENT, O.TOSS, 1))
	cards["grim_auditor"] = ContentDefinitions._fin(auditor, R.LEGENDARY, "Flying, lifesteal. When this enters, the opponent discards a card.", "Your books are in order. Your soul, regrettably, is not.")
