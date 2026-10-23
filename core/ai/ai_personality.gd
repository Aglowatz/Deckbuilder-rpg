class_name AIPersonality
extends Resource
## Tunable weights for the heuristic AI. Everything is data so new opponents can be made
## without touching code.

@export var personality_name: String = "Balanced"
## Value of the AI's own HP total.
@export var hp_weight: float = 1.0
## Value of reducing the opponent's HP total (aggression).
@export var enemy_hp_weight: float = 1.0
## Value of the AI's own board / of removing the opponent's board.
@export var board_weight: float = 1.0
@export var enemy_board_weight: float = 1.0
## Value of cards in hand.
@export var hand_weight: float = 0.6
## Value of infrastructure on the field (energy development).
@export var energy_weight: float = 0.5
## How much the AI dislikes leaving itself open to a counter-attack.
@export var threat_weight: float = 0.6
## Flat bonus per attacking unit (positive = more eager to attack).
@export var attack_bias: float = 0.0
## Flat bonus per blocking unit (positive = more eager to block).
@export var block_bias: float = 0.0

# ---- Battle AI upgrade (Oct 23): the planning core's knobs. Defaults reproduce a sound "Balanced" player. ----

## Value of being ahead in the race (turns the foe needs to kill me minus turns I need to kill them), per turn of difference.
@export var race_weight: float = 1.5
## Value of each unit beyond the first (going wide: more blockers, more attackers, token payoffs).
@export var width_weight: float = 0.3
## Multipliers on a unit's attack and defense when valuing boards (Beefcake likes attack, Gourmand likes defense).
@export var attack_value: float = 1.0
@export var defense_value: float = 1.0
## What a held Iron / Red Tape is worth (the use must gain more than this); fuel (Ingredients, Garbage) scales FUEL_VALUE.
@export var iron_hold_value: float = 0.5
@export var red_tape_hold_value: float = 0.8
@export var fuel_value: float = 1.0
## Multiplier on the worth of the FOE's Tools and Wonders (Refusemancers hate them: destroying one scores more).
@export var artifact_weight: float = 1.0
## Skill: 0 = Normal (narrow search, occasional human mistakes), 1 = Elite (competent), 2 = Boss (widest search, signature play).
@export var skill: int = 1
## Chance per attack decision that a Normal-skill AI takes its second-best reasonable option instead of the best (0 for Elite/Boss).
@export var mistake_rate: float = 0.0
## Chance per block decision that a Normal-skill AI forgets to block when the unblocked damage is not lethal (0 for Elite/Boss).
@export var careless_blocks: float = 0.0
## Path profile the eval weights are blended toward: "auto" reads the deck, or "beefcake" / "necrocrat" / "gourmand" /
## "refusemancer" / "none".
@export var path_profile: String = "auto"
## Boss signature behaviour key ("" = none); see AIPlayer.SIGNATURES.
@export var signature: String = ""
## Wall-clock budget per decision in the live game (the sim uses node counts only, so games stay deterministic).
@export var time_budget_ms: int = 700


func duplicate_personality() -> AIPersonality:
	return duplicate(true) as AIPersonality


static func balanced() -> AIPersonality:
	return AIPersonality.new()


static func aggressive() -> AIPersonality:
	var p: AIPersonality = AIPersonality.new()
	p.personality_name = "Aggressive"
	p.hp_weight = 0.7
	p.enemy_hp_weight = 1.5
	p.board_weight = 0.9
	p.enemy_board_weight = 0.8
	p.threat_weight = 0.25
	p.attack_bias = 1.0
	p.block_bias = -0.5
	return p


static func defensive() -> AIPersonality:
	var p: AIPersonality = AIPersonality.new()
	p.personality_name = "Defensive"
	p.hp_weight = 1.4
	p.enemy_hp_weight = 0.7
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
	p.hp_weight = 1.0
	p.enemy_hp_weight = 0.35
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
	p.hp_weight = 1.0
	p.enemy_hp_weight = 1.0
	p.board_weight = 0.7
	p.enemy_board_weight = 0.4
	p.hand_weight = 0.4
	p.threat_weight = 0.05
	p.race_weight = 0.5
	p.attack_bias = 2.0
	p.block_bias = -0.3
	p.skill = 0
	p.careless_blocks = 0.3
	p.path_profile = "none"
	return p


## Battle feel, Part D: the very first duel (Scavenger's Den) only. It still attacks, so blocking can be taught, but it
## hardly ever blocks, so a new player's attacks reach its 3 HP within a few turns. Cards and decks are unchanged.
static func first_duel() -> AIPersonality:
	var p: AIPersonality = aggressive_dumb()
	p.personality_name = "First duel (tutorial)"
	p.attack_bias = 0.8
	p.block_bias = -1.5
	p.board_weight = 0.5
	p.enemy_board_weight = 0.3
	p.skill = 0
	# Part 4: it forgets most blocks (only a lethal one is always made), so a new player's attacks reach its 3 HP within a few turns.
	p.careless_blocks = 0.75
	p.path_profile = "none"
	return p
