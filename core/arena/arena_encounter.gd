class_name ArenaEncounter
extends RefCounted
## One fight of the Grand Clashatorium (Part G): a challenging battle with the player's own deck, a battle with a
## RESTRICTED (preset) deck or rule, or a PUZZLE with a preset board ("win this turn", "survive 3 turns"). Pure data;
## `ArenaScenario` builds the duel and judges the outcome. All names, blurbs and rules text live in the story file
## (`arena.<id>.title`, `.blurb`, `.rules`).

enum Kind { BATTLE, PUZZLE }
## What counts as winning: WIN = reduce the enemy to 0 (the normal rule); WIN_THIS_TURN = lethal on the very first turn
## (the game ends in a loss when that turn does); SURVIVE_TURNS = still alive after the enemy's Nth turn.
enum Goal { WIN, WIN_THIS_TURN, SURVIVE_TURNS }

var id: String = ""
## 1 = Bronze Sand, 2 = Silver Sand, 3 = Gold Sand.
var tier: int = 1
var kind: Kind = Kind.BATTLE
var goal: Goal = Goal.WIN
## SURVIVE_TURNS: how many of the enemy's turns must be survived.
var turns: int = 0
## 0 = the player goes first, 1 = the enemy does.
var first_player: int = 0
## The opponent's name, HP, AI personality and deck recipe (`ZoneDecks.from_recipe` convention).
var enemy_name: String = ""
var enemy_hp: int = 15
var enemy_ai: String = "Balanced"
var enemy_recipe: Dictionary = {}
## A preset deck the player MUST use ("restricted deck"); empty = the player's own deck. Same recipe convention.
var player_recipe: Dictionary = {}
## The player's HP for the duel; -1 = their normal maximum HP.
var player_hp: int = -1
## Rule modifiers applied to the player for this fight (e.g. NO_CREATURE_CASTS).
var player_rules: Array[Modifier] = []
## A preset board: {"player": {...}, "enemy": {...}}, each with optional "HP", "hand", "field", "infrastructure"
## ({"A": 4}) and "graveyard" (card id -> copies). Empty = a normal start.
var preset: Dictionary = {}
## First-clear prizes: gold, xp, essence ({path letter or "primary": amount}), equipment (id), item (id), card (id).
var reward: Dictionary = {}
## What the first-clear prize of a replayed fight is: a flat consolation (gold) so repeats are for glory.
var replay_gold: int = 15


func is_puzzle() -> bool:
	return kind == Kind.PUZZLE


func uses_restricted_deck() -> bool:
	return not player_recipe.is_empty()


func title_key() -> String:
	return "arena.%s.title" % id


func blurb_key() -> String:
	return "arena.%s.blurb" % id


func rules_key() -> String:
	return "arena.%s.rules" % id


## The game's turn limit that implements the goal (0 = the normal limit).
func turn_limit() -> int:
	match goal:
		Goal.WIN_THIS_TURN:
			return 1
		Goal.SURVIVE_TURNS:
			# The enemy moves first: its Nth turn is game turn 2N-1; the game is drawn when turn 2N would start...
			# the player must still be standing after it.
			return 2 * turns - 1 if first_player == 1 else 2 * turns
	return 0


## Whether the player won, judged from the finished game: WIN/WIN_THIS_TURN need the enemy dead; SURVIVE_TURNS is also
## won when the clock ran out (a "draw") with the player alive.
func player_won(game: GameState) -> bool:
	if game.winner == 0:
		return true
	if goal == Goal.SURVIVE_TURNS and game.is_draw and game.players[0].hp > 0:
		return true
	return false
