class_name DungeonContent
extends RefCounted
## Brief 9, Part E: the unique card each zone's final dungeon drops (once, with the boss). Placeholder
## numbers - real cards come later. Each is Legendary and of its zone's Path.

const A: Affinity.Type = Affinity.Type.BEEFCAKE
const B: Affinity.Type = Affinity.Type.GOURMAND
const C: Affinity.Type = Affinity.Type.REFUSEMANCER
const D: Affinity.Type = Affinity.Type.NECROCRAT
const T := CardEnums.Trigger
const G := CardEnums.TargetKind
const O := CardEnums.EffectOp
const K := CardEnums.Keyword
const R := CardEnums.Rarity

const REWARD_IDS: Array[String] = ["aurelio_the_true", "heartlift_the_unbroken", "the_final_approval", "heart_of_the_dump"]


static func add_cards(cards: Dictionary) -> void:
	var heartlift: CardData = ContentDefinitions._unit("heartlift_the_unbroken", "Heartlift, the Unbroken", A, 3, [A, A], 6, 6, [K.OVERTIME])
	cards["heartlift_the_unbroken"] = ContentDefinitions._fin(ContentDefinitions._with(heartlift, ContentDefinitions._fx(T.ON_ENTER, G.ALL_ALLY_UNITS, O.BUFF, 1, 1)), R.LEGENDARY,
		"Overtime. When this enters, your units get +1/+1 permanently.", "Unique reward of the House of Gains. True strength comes from the heart and the mind. The legs help.")
	var aurelio: CardData = ContentDefinitions._unit("aurelio_the_true", "Aurelio, the True Chef", B, 4, [B, B], 4, 6, [])
	aurelio = ContentDefinitions._with(aurelio, ContentDefinitions._fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_HP, 6))
	cards["aurelio_the_true"] = ContentDefinitions._fin(ContentDefinitions._with(aurelio, ContentDefinitions._fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 1)), R.LEGENDARY,
		"When this enters, gain 6 HP and draw a card.", "Unique reward of the Test Kitchen. The real thing. You can tell by the chin.")
	var approval: CardData = ContentDefinitions._unit("the_final_approval", "The Final Approval", D, 3, [D, D], 5, 5, [K.NOURISH])
	approval = ContentDefinitions._with(approval, ContentDefinitions._fx(T.ON_ENTER, G.OPPONENT, O.TOSS, 2))
	cards["the_final_approval"] = ContentDefinitions._fin(ContentDefinitions._with(approval, ContentDefinitions._fx(T.ON_ENTER, G.OPPONENT, O.LOSE_HP, 3)), R.LEGENDARY,
		"Nourish. When this enters, the opponent discards two cards and loses 3 HP.", "Unique reward of the Hall of Final Approvals. Stamped, notarized and filed. The authorization is valid.")
	var heart: CardData = ContentDefinitions._unit("heart_of_the_dump", "Heart of the Dump", C, 4, [C, C], 7, 7, [K.BULLDOZE])
	cards["heart_of_the_dump"] = ContentDefinitions._fin(ContentDefinitions._with(heart, ContentDefinitions._fx(T.ON_ENTER, G.ALL_ALLY_UNITS, O.BUFF, 2, 2)), R.LEGENDARY,
		"Bulldoze. When this enters, your units get +2/+2 permanently.", "Unique reward of the Rotheart. It beats once more, slowly, and everything nearby grows a little.")
