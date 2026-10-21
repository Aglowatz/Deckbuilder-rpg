class_name Lieutenants
extends RefCounted
## Primm's four lieutenants as encounters (Oct 21 story-content brief; story bible section 6, the design sheet's NPC and Dungeon List rows).
## Each is a one-off elite with its own one-sided rule (data/encounters/modifiers.json, keyed by the battle name), intro and defeat scenes
## (data/story/story_scenes.json) and a unique relic on the first win:
## - Vivienne Quota (Beefcake): the House of Gains' Regime Checkpoint (D-HOG node 6), then a rematch in the Capital's Transit Yards once Rollo
##   Spokes's quest is done and the Gainlands are free (she fled there).
## - Colonel Cornelius Crumb (Gourmand): inspects the Test Kitchen's Prototype Bay (D-TTK node 6, a scene), then the boss of the Paste Works
##   (S-PASTE) in the Capital, reached through Chef Marlo's quest.
## - Percival Plume (Necrocrat): cuts the D.N.A.'s ribbon once it is free, has the Rescuer seized at the castle gate (D-PC node 1), and is the
##   elite of the castle's Necrocrat wing (D-PC node 14).
## - Hortensia Clipwell (Refusemancer): the elite of the Rotheart's Root-Choked Mill (D-ROT node 6); a short scene on the Capital's regulation
##   lawn once Old Fern's quest is done and the Dump is free.
## The "fled" scenes play the first time the hero is in a freed zone (old saves too).

const QUOTA: String = "quota"
const CRUMB: String = "crumb"
const PLUME: String = "plume"
const CLIPWELL: String = "clipwell"

## id -> {foe: battle name, npc, zone, reward (equipment id), fled (scene played in the freed zone)}.
const DEFS: Dictionary = {
	QUOTA: {"foe": "Vivienne Quota, Minister of Efficiency", "npc": "NPC-QUOTA", "zone": "beefcake", "reward": "quotas_stopwatch", "fled": "quota_fled"},
	CRUMB: {"foe": "Colonel Cornelius Crumb, Director of Culinary Defense", "npc": "NPC-CRUMB", "zone": "gourmand", "reward": "colonels_ladle", "fled": "crumb_fled"},
	PLUME: {"foe": "Percival Plume, Deputy Minister of Good News", "npc": "NPC-PLUME", "zone": "necrocrat", "reward": "plumes_quill", "fled": "plume_ribbon"},
	CLIPWELL: {"foe": "Hortensia Clipwell, Royal Groundskeeper", "npc": "NPC-CLIPWELL", "zone": "refusemancer", "reward": "clipwells_shears", "fled": "clipwell_fled"},
}

## Flag set the first time a lieutenant is beaten (anywhere): "lieutenant_<id>_beaten".
static func flag_beaten(id: String) -> StringName:
	return StringName("lieutenant_%s_beaten" % id)


static func foe_name(id: String) -> String:
	return str((DEFS.get(id, {}) as Dictionary).get("foe", ""))


## The lieutenant fought under this battle name, or "".
static func for_enemy(enemy_name: String) -> String:
	for id: String in DEFS.keys():
		if foe_name(id) == enemy_name:
			return id
	return ""


static func reward_id(id: String) -> String:
	return str((DEFS.get(id, {}) as Dictionary).get("reward", ""))


## The "<lieutenant> has fled to the Capital" scene to play in a freed zone, or "" (none for this zone, or already seen).
static func fled_scene(zone_id: String, flags: Dictionary) -> String:
	for id: String in DEFS.keys():
		var entry: Dictionary = DEFS[id] as Dictionary
		if str(entry["zone"]) != zone_id:
			continue
		var scene: String = str(entry["fled"])
		if bool(flags.get(str(ZoneCompletion.flag_name(zone_id)), false)) and StoryScenes.should_play(scene, flags):
			return scene
	return ""


# ---- Quota's rematch in the Transit Yards ----------------------------------------------------------------------------------------

## The Capital spot by the energy wheels (`CapitalZone`), the battle's rule key and its sim group.
const YARDS_SPOT: String = "quota_yards"
const YARDS_RULES_KEY: String = "capital:quota"
const YARDS_SIM_GROUP: String = "capital:lieutenant"
const YARDS_BOARD_KEY: String = "final"
const YARDS_EXPECTED_LEVEL: int = 19
const YARDS_HP: int = 26
const YARDS_AI: String = "Aggressive"
const YARDS_GOLD: int = 120
const YARDS_XP: int = 150


## She is in the Transit Yards once Rollo's quest is done and the Gainlands are free, until she is beaten there.
static func quota_in_yards(flags: Dictionary, wheels_quest_done: bool) -> bool:
	return wheels_quest_done and bool(flags.get(str(ZoneCompletion.flag_name("beefcake")), false)) and not bool(flags.get("quota_beaten", false))


static func yards_recipe() -> Dictionary:
	# The efficiency regime's machine: Beefcake tools and bruisers on a lean Iron base, plus the Capital's colorless regime enforcers.
	return EnemyDecks.with_cards(EnemyDecks.trimmed("beefcake_tools", 30, 13), {"B-12": 2, "B-28": 1, "C-30": 1})


static func yards_setup(content: ContentSet) -> PlayerSetup:
	var setup: PlayerSetup = PlayerSetup.create(ZoneDecks.from_recipe(content, foe_name(QUOTA), yards_recipe()), null, [] as Array[ModifierSource], foe_name(QUOTA))
	setup.starting_hp = YARDS_HP
	setup.profile = PlayerProfile.new()
	setup.profile.max_hp = YARDS_HP
	EncounterModifiers.apply_to_enemy(setup, YARDS_RULES_KEY)
	return setup


# ---- The relics (first win against each lieutenant; never sold) ------------------------------------------------------------------

static func add_equipment(result: Dictionary) -> void:
	_add(result, "quotas_stopwatch", "Quota's Stopwatch", EquipmentData.Slot.RELIC, "You always take the first turn.",
		[_mod(Modifier.Kind.ALWAYS_FIRST, 1)], "It still clicks every second. You never asked it to.", "The House of Gains (a first win)")
	_add(result, "colonels_ladle", "The Colonel's Ladle", EquipmentData.Slot.WEAPON, "Whenever a unit enters the field under your control, gain 1 HP.",
		[_mod_effect(Modifier.Kind.ON_UNIT_ENTER_EFFECT, CardEnums.EffectOp.GAIN_HP, CardEnums.TargetKind.CONTROLLER)],
		"Carried like a sabre for ten years. It has finally been used for soup.", "The Paste Works (a first win)")
	_add(result, "plumes_quill", "Plume's Notary Quill", EquipmentData.Slot.RELIC, "Start every duel with 1 Red Tape. Max HP +2.",
		[_mod(Modifier.Kind.STARTING_RESOURCES, 1, int(ResourceKind.Kind.RED_TAPE)), _mod(Modifier.Kind.MAX_HP, 2)],
		"It has signed away a Path, a kingdom and a friend. It writes beautifully.", "Primm's Castle (a first win)")
	_add(result, "clipwells_shears", "Clipwell's Golden Shears", EquipmentData.Slot.WEAPON, "Whenever the opponent declares attackers, deal 1 damage to each of them.",
		[_mod_effect(Modifier.Kind.RETALIATE_ON_ATTACK, CardEnums.EffectOp.DEAL_DAMAGE, CardEnums.TargetKind.ALL_ATTACKERS)],
		"Trimmed to regulation height. Anything taller gets a polite little snip.", "The Rotheart (a first win)")


static func _add(result: Dictionary, id: String, title: String, slot: EquipmentData.Slot, description: String, modifiers: Array[Modifier], flavor: String, source: String) -> void:
	var piece: EquipmentData = EquipmentData.new()
	piece.id = id
	piece.source_name = title
	piece.source_kind = ModifierSource.SourceKind.EQUIPMENT
	piece.slot = slot
	piece.description = description
	piece.modifiers = modifiers
	piece.advanced = true
	piece.rarity = EquipmentData.Rarity.RARE
	piece.tier = 3
	piece.flavor_text = flavor
	piece.source = source
	result[piece.id] = piece


## value2 carries the resource kind for STARTING_RESOURCES (as `ProgressionContent._mod` does).
static func _mod(kind: Modifier.Kind, value: int, value2: int = 0) -> Modifier:
	var modifier: Modifier = Modifier.new()
	modifier.kind = kind
	modifier.value = value
	modifier.value2 = value2
	return modifier


static func _mod_effect(kind: Modifier.Kind, op: CardEnums.EffectOp, target: CardEnums.TargetKind) -> Modifier:
	var effect: EffectData = EffectData.new()
	effect.op = op
	effect.amount = 1
	effect.target = target
	var modifier: Modifier = Modifier.new()
	modifier.kind = kind
	modifier.effect = effect
	return modifier
