class_name ChallengeResult
extends RefCounted
## What happened when a challenge was resolved (for the UI to present).

var challenge_id: String = ""
var success: bool = false
## PAY_LIFE offer that was declined or could not be afforded: nothing happens at all.
var declined: bool = false
var revealed: Array[CardData] = []
var outcomes: Array[ChallengeOutcome] = []
var lost_cards: Array[CardData] = []
var gained_cards: Array[CardData] = []
var hp_lost: int = 0
var hp_healed: int = 0
var boons: Array[ModifierSource] = []
