class_name AIPersonality
extends Resource
## Tunable weights for the heuristic AI. Everything is data so new opponents can be made
## without touching code.

@export var personality_name: String = "Balanced"
## Value of the AI's own life total.
@export var life_weight: float = 1.0
## Value of reducing the opponent's life total (aggression).
@export var enemy_life_weight: float = 1.0
## Value of the AI's own board / of removing the opponent's board.
@export var board_weight: float = 1.0
@export var enemy_board_weight: float = 1.0
## Value of cards in hand.
@export var hand_weight: float = 0.6
## Value of lands on the battlefield (mana development).
@export var mana_weight: float = 0.5
## How much the AI dislikes leaving itself open to a counter-attack.
@export var threat_weight: float = 0.6
## Flat bonus per attacking creature (positive = more eager to attack).
@export var attack_bias: float = 0.0
## Flat bonus per blocking creature (positive = more eager to block).
@export var block_bias: float = 0.0


static func balanced() -> AIPersonality:
	return AIPersonality.new()


static func aggressive() -> AIPersonality:
	var p: AIPersonality = AIPersonality.new()
	p.personality_name = "Aggressive"
	p.life_weight = 0.7
	p.enemy_life_weight = 1.5
	p.board_weight = 0.9
	p.enemy_board_weight = 0.8
	p.threat_weight = 0.25
	p.attack_bias = 1.0
	p.block_bias = -0.5
	return p


static func defensive() -> AIPersonality:
	var p: AIPersonality = AIPersonality.new()
	p.personality_name = "Defensive"
	p.life_weight = 1.4
	p.enemy_life_weight = 0.7
	p.board_weight = 1.2
	p.enemy_board_weight = 1.2
	p.hand_weight = 0.8
	p.threat_weight = 1.2
	p.attack_bias = -0.75
	p.block_bias = 1.0
	return p


## A deliberately weak, forgiving opponent: rarely attacks, is very cautious about trades, and
## undervalues actually hurting the player. Still a real, legal AI (never passes when it has a
## clearly good play) - just an easy one. No longer used by the tutorial dungeon (see
## `aggressive_dumb`, docs/design/open_questions.md D50) since an AI this passive never attacks,
## which made the player's own traps (Pitfall etc.) untestable; kept as a general-purpose easy
## opponent for later content.
static func passive() -> AIPersonality:
	var p: AIPersonality = AIPersonality.new()
	p.personality_name = "Passive"
	p.life_weight = 1.0
	p.enemy_life_weight = 0.35
	p.board_weight = 0.8
	p.enemy_board_weight = 0.5
	p.hand_weight = 0.6
	p.threat_weight = 1.6
	p.attack_bias = -1.3
	p.block_bias = 0.3
	return p


## The tutorial dungeon's non-boss opponent (Part D): eager to attack (so the player's traps and
## blocks are actually tested) but does not think ahead about counter-attacks or protecting its
## own board - "aggressive but dumb". Paired with deliberately weak, vanilla-only decks
## (`TrialOfTheHollow.enemy_recipe`), not a smart AI playing bad cards well.
static func aggressive_dumb() -> AIPersonality:
	var p: AIPersonality = AIPersonality.new()
	p.personality_name = "Aggressive (tutorial)"
	p.life_weight = 1.0
	p.enemy_life_weight = 1.0
	p.board_weight = 0.7
	p.enemy_board_weight = 0.4
	p.hand_weight = 0.4
	p.threat_weight = 0.05
	p.attack_bias = 1.5
	p.block_bias = -0.3
	return p
