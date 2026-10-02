class_name BattleContext
extends RefCounted
## Everything the battle screen needs: the duel, who the opponent is and how the result flows
## back into the campaign. Built by the dungeon flow (or a practice match) and stored on Session.

var game: GameState
var ai: AIPlayer
var enemy_name: String = "Opponent"
var enemy_icon: String = "lorc/imp"
## Dungeon map node id this battle belongs to (-1 for practice matches).
var node_id: int = -1
var tutorial: bool = false
var is_boss: bool = false
var practice: bool = false
## New brief, Part E: set for a corrupted-NPC town challenge ("beefcake"/"tide"/"root"/"necrocrat"),
## empty otherwise. See Session.make_npc_challenge_battle/_complete_npc_challenge.
var town_npc_id: String = ""
## Fourth brief, Part F: set for the Graveyard's scripted battle (The Restless Cairn). See
## Session.make_graveyard_battle/_complete_graveyard_challenge.
var is_graveyard_boss: bool = false
var gold_reward: int = 0
var xp_reward: int = 0
var card_choices: int = 0
var won: bool = false
## Brief 5: set for a duel against a roaming zone enemy (see Session.make_zone_battle/
## _complete_zone_battle) - the id is a DnaEnemies id plus which spawn it was.
var zone_battle: bool = false
var zone_enemy_id: String = ""
var zone_enemy_type: String = ""
