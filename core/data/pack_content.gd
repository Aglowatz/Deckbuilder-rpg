class_name PackContent
extends RefCounted
## Pack system: one pack-eligible Legendary per Path. Every other Legendary of the game is a unique reward (mini dungeon, main
## dungeon, quest, Primm) and is flagged `not_in_packs`, so without these a Path Pack could never open a Legendary. Placeholder
## numbers and names - real cards come later (balance is out of scope).

const A: Affinity.Type = Affinity.Type.A
const B: Affinity.Type = Affinity.Type.B
const C: Affinity.Type = Affinity.Type.C
const D: Affinity.Type = Affinity.Type.D
const T := CardEnums.Trigger
const G := CardEnums.TargetKind
const O := CardEnums.EffectOp
const K := CardEnums.Keyword
const R := CardEnums.Rarity

const LEGENDARY_IDS: Array[String] = ["deadlift_deity", "grand_banquet", "compost_elder", "grim_auditor"]


static func add_cards(cards: Dictionary) -> void:
	var deity: CardData = ContentDefinitions._creature("deadlift_deity", "The Deadlift Deity", A, 4, [A, A], 7, 5, [K.TRAMPLE, K.HASTE])
	cards["deadlift_deity"] = ContentDefinitions._fin(deity, R.LEGENDARY, "Haste, trample", "Lifts the bar. Lifts the room. Lifts the mood, mostly.")
	var banquet: CardData = ContentDefinitions._spell("grand_banquet", "The Grand Banquet", B, 4, [B, B])
	banquet = ContentDefinitions._with(banquet, ContentDefinitions._fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 3))
	banquet = ContentDefinitions._with(banquet, ContentDefinitions._fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_LIFE, 5))
	cards["grand_banquet"] = ContentDefinitions._fin(banquet, R.LEGENDARY, "Draw three cards. Gain 5 life.", "Seven courses, four sauces, and a toast nobody remembers giving.")
	var elder: CardData = ContentDefinitions._creature("compost_elder", "The Compost Elder", C, 4, [C, C], 6, 8, [K.GUARD])
	elder = ContentDefinitions._with(elder, ContentDefinitions._fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_LIFE, 4))
	cards["compost_elder"] = ContentDefinitions._fin(elder, R.LEGENDARY, "Guard. When this enters, gain 4 life.", "Older than the dump. Ripe, wise and faintly steaming.")
	var auditor: CardData = ContentDefinitions._creature("grim_auditor", "The Grim Auditor", D, 4, [D, D], 5, 5, [K.FLYING, K.LIFESTEAL])
	auditor = ContentDefinitions._with(auditor, ContentDefinitions._fx(T.ON_ENTER, G.OPPONENT, O.DISCARD, 1))
	cards["grim_auditor"] = ContentDefinitions._fin(auditor, R.LEGENDARY, "Flying, lifesteal. When this enters, the opponent discards a card.", "Your books are in order. Your soul, regrettably, is not.")
