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
## New brief, Part E: set for a corrupted-NPC town challenge ("beefcake"/"gourmand"/"refusemancer"/"necrocrat"),
## empty otherwise. See Session.make_npc_challenge_battle/_complete_npc_challenge.
var town_npc_id: String = ""
## Fourth brief, Part F: set for the Graveyard's scripted battle (The Restless Cairn). See
## Session.make_graveyard_battle/_complete_graveyard_challenge.
var is_graveyard_boss: bool = false
## Brief 16: set for the duel against Shiro Swindle (the original giant chest). See Session.make_ninja_battle/_complete_ninja_challenge.
var is_ninja_boss: bool = false
## Brief 16: set for the duel against the Warden of the Four Seals (the town's Four-Seal Vault). See Session.make_vault_battle/_complete_vault_challenge.
var is_vault_boss: bool = false
var gold_reward: int = 0
var xp_reward: int = 0
var card_choices: int = 0
var won: bool = false
## Brief 5: set for a duel against a roaming zone enemy (see Session.make_zone_battle/
## _complete_zone_battle) - the id is a DnaEnemies id plus which spawn it was.
var zone_battle: bool = false
## Brief 9, Part G: set for a Grand Clashatorium fight (`ArenaEncounter` id, "" otherwise). The result is judged by
## `ArenaEncounter.player_won` and pays its first-clear prize (`Session.complete_battle`).
var arena_id: String = ""
## The zone (or zone dungeon) this duel is fought in, "" elsewhere: its buff/debuff apply to both sides and
## the battle UI shows them (`ZoneEffects`).
var zone_id: String = ""
var zone_enemy_id: String = ""
var zone_enemy_type: String = ""
## Brief 10: the final boss's phase (0-based, -1 = not a boss phase), the rule text of that phase and the music of the duel.
var boss_phase: int = -1
var rules_text: String = ""
var music: StringName = &"battle"
## Which battleboard backdrop the duel is fought on: a key of `data/battleboards.json` ("zone:beefcake", "capital:in", "arena"...). "" = the neutral board.
var board_key: String = ""
