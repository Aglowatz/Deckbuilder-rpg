class_name DungeonContent
extends RefCounted
## Brief 9, Part E: the unique card each zone's final dungeon drops (once, with the boss). Placeholder
## numbers - real cards come later. Each is Legendary and of its zone's Path.

const A: Affinity.Type = Affinity.Type.A
const B: Affinity.Type = Affinity.Type.B
const C: Affinity.Type = Affinity.Type.C
const D: Affinity.Type = Affinity.Type.D
const T := CardEnums.Trigger
const G := CardEnums.TargetKind
const O := CardEnums.EffectOp
const K := CardEnums.Keyword
const R := CardEnums.Rarity

const REWARD_IDS: Array[String] = ["aurelio_the_true", "heartlift_the_unbroken", "the_final_approval", "heart_of_the_dump"]


static func add_cards(cards: Dictionary) -> void:
	var heartlift: CardData = ContentDefinitions._creature("heartlift_the_unbroken", "Heartlift, the Unbroken", A, 3, [A, A], 6, 6, [K.VIGILANCE])
	cards["heartlift_the_unbroken"] = ContentDefinitions._fin(ContentDefinitions._with(heartlift, ContentDefinitions._fx(T.ON_ENTER, G.ALL_ALLY_CREATURES, O.BUFF, 1, 1)), R.LEGENDARY,
		"Vigilance. When this enters, your creatures get +1/+1 permanently.", "Unique reward of the House of Gains. True strength comes from the heart and the mind. The legs help.")
	var aurelio: CardData = ContentDefinitions._creature("aurelio_the_true", "Aurelio, the True Chef", B, 4, [B, B], 4, 6, [K.GUARD])
	aurelio = ContentDefinitions._with(aurelio, ContentDefinitions._fx(T.ON_ENTER, G.CONTROLLER, O.GAIN_LIFE, 6))
	cards["aurelio_the_true"] = ContentDefinitions._fin(ContentDefinitions._with(aurelio, ContentDefinitions._fx(T.ON_ENTER, G.CONTROLLER, O.DRAW, 1)), R.LEGENDARY,
		"Guard. When this enters, gain 6 life and draw a card.", "Unique reward of the Test Kitchen. The real thing. You can tell by the chin.")
	var approval: CardData = ContentDefinitions._creature("the_final_approval", "The Final Approval", D, 3, [D, D], 5, 5, [K.LIFESTEAL])
	approval = ContentDefinitions._with(approval, ContentDefinitions._fx(T.ON_ENTER, G.OPPONENT, O.DISCARD, 2))
	cards["the_final_approval"] = ContentDefinitions._fin(ContentDefinitions._with(approval, ContentDefinitions._fx(T.ON_ENTER, G.OPPONENT, O.LOSE_LIFE, 3)), R.LEGENDARY,
		"Lifesteal. When this enters, the opponent discards two cards and loses 3 life.", "Unique reward of the Hall of Final Approvals. Stamped, notarized and filed. The authorization is valid.")
	var heart: CardData = ContentDefinitions._creature("heart_of_the_dump", "Heart of the Dump", C, 4, [C, C], 7, 7, [K.TRAMPLE])
	cards["heart_of_the_dump"] = ContentDefinitions._fin(ContentDefinitions._with(heart, ContentDefinitions._fx(T.ON_ENTER, G.ALL_ALLY_CREATURES, O.BUFF, 2, 2)), R.LEGENDARY,
		"Trample. When this enters, your creatures get +2/+2 permanently.", "Unique reward of the Rotheart. It beats once more, slowly, and everything nearby grows a little.")
