class_name ZoneEnemyInfo
extends RefCounted
## Stats, AI ranges, deck recipe, rewards and look of one roaming zone enemy type. Zone data
## classes (`DnaEnemies`, `GainlandsEnemies`) build these; `ZoneEnemy` (the node) reads them. Placeholder
## numbers - balance is out of scope for the proof of concept.

## BATTLE: touching starts a card battle. DAMAGE: touching deals damage with knockback.
enum Kind { BATTLE, DAMAGE }

var id: String = ""
var display_name: String = ""
var kind: Kind = Kind.BATTLE
var patrol_speed: float = 0.0
var chase_speed: float = 0.0
## Starts chasing when the player is this close (metres) ...
var aggro_range: float = 0.0
## ... and gives up once the player is this far from the enemy's patrol home (metres).
var leash_range: float = 0.0
var touch_range: float = 0.55
## DAMAGE types: HP taken per touch.
var damage: int = 2
## Battle opponents only.
var recipe: Dictionary = {}
var hp: int = 10
var ai_name: String = "Balanced"
var gold_reward: int = 0
var xp_reward: int = 0
## Visual: a character model name (`ModelKit.zone_character`), a tint, and a scale.
var model: String = ""
var tint: Color = Color.WHITE
var model_scale: float = 1.0
## Hovers and bobs (ghosts, sprites) / translucent glowing look.
var hover: bool = false
var ghostly: bool = false
var ghost_glow: Color = Color(0.4, 0.9, 1.0)
## Little primitive props that make the design readable: [{offset: Vector3, size: Vector3, color: Color}].
var accessories: Array[Dictionary] = []
## Short flavour line shown in the codex/toasts (story text key is `enemy.<id>`).
var species: String = ""
## Animation names of the model (KayKit characters use "Idle" / "Walking_A" / "Running_A").
var anim_idle: StringName = &"idle"
var anim_walk: StringName = &"walk"
var anim_run: StringName = &"sprint"
