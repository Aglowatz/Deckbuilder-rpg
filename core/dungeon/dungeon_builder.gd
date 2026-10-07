class_name DungeonBuilder
extends RefCounted
## Builds the playable dungeon from the designer's list: a `DungeonCatalog.Blueprint` (IDs, node list, types, links, positions) plus the hand-written content block
## (`data/dungeons/dungeon_content.json`: foes, events, challenges, loot, text) become a `MainDungeonDef` (foes, events, challenges, rewards) and a `DungeonMap`.
## The five main dungeons and the six side dungeons all come through here; the dungeon classes (`HouseOfGainsDungeon`...) only add what is special to them.

const K := DungeonMap.Kind
const BOSS_MARKER: String = "PRIMM_BOSS"
const DEFAULT_REWARD_GOLD: int = 200
const DEFAULT_REWARD_XP: int = 150
const SIDE_REWARD_GOLD: int = 30
const MAIN_REPEAT_GOLD: int = 100
const AFFINITY_BY_NAME: Dictionary = {
	"beefcake": Affinity.Type.BEEFCAKE, "gourmand": Affinity.Type.GOURMAND, "necrocrat": Affinity.Type.NECROCRAT, "refusemancer": Affinity.Type.REFUSEMANCER,
}


## The map node kind of a CSV node type.
static func kind_of(type: String) -> DungeonMap.Kind:
	match type:
		"start":
			return K.START
		"elite":
			return K.ELITE
		"boss":
			return K.BOSS
		"treasure":
			return K.TREASURE
		"event":
			return K.EVENT
		"challenge":
			return K.CHALLENGE
		"heal":
			return K.SHRINE
		"rescue":
			return K.RESCUE
	return K.BATTLE


static func event_id_of(blueprint: DungeonCatalog.Blueprint, number: int) -> String:
	return "dg_%s_%d" % [blueprint.id.to_lower().replace("-", "_"), number]


# ---- The definition: foes, events, challenges, rewards -----------------------------------------


static func build_def(blueprint: DungeonCatalog.Blueprint) -> MainDungeonDef:
	var content: Dictionary = DungeonCatalog.content_for(blueprint.id)
	var def: MainDungeonDef = MainDungeonDef.new()
	def.dungeon_id = blueprint.id
	def.zone_id = blueprint.zone_id
	def.dungeon_name = blueprint.dungeon_name
	def.reward_card_id = blueprint.reward_card_id()
	def.reward_gold = SIDE_REWARD_GOLD if blueprint.is_side() else DEFAULT_REWARD_GOLD
	def.reward_xp = 0 if blueprint.is_side() else DEFAULT_REWARD_XP
	var defaults: Dictionary = content.get("defaults", {}) as Dictionary
	var foes: Dictionary = content.get("foes", {}) as Dictionary
	var battle_index: int = 0
	for node: DungeonCatalog.BlueprintNode in blueprint.nodes:
		var kind: DungeonMap.Kind = kind_of(node.type)
		if DungeonMap.is_battle_kind(kind):
			_add_foe(def, blueprint, node, kind, foes.get(str(node.number)), defaults, content, battle_index)
			battle_index += 1
		elif kind == K.EVENT or kind == K.RESCUE:
			_add_event(def, blueprint, node, content)
		elif kind == K.CHALLENGE:
			_add_challenge(def, blueprint, node, content)
	return def


## The name of the foe fought at `node` (the blueprint's name for it).
static func foe_name_of(blueprint: DungeonCatalog.Blueprint, node: DungeonCatalog.BlueprintNode) -> String:
	var spec: Variant = (DungeonCatalog.content_for(blueprint.id).get("foes", {}) as Dictionary).get(str(node.number))
	var name: String = ""
	if spec is Dictionary:
		name = str((spec as Dictionary).get("name", ""))
	elif spec != null:
		name = str(spec)
	if name == BOSS_MARKER:
		return PrimmBoss.BOSS_FOE
	return name if not name.is_empty() else "%s Guard" % node.node_name


static func _add_foe(def: MainDungeonDef, blueprint: DungeonCatalog.Blueprint, node: DungeonCatalog.BlueprintNode, kind: DungeonMap.Kind, spec: Variant, defaults: Dictionary, content: Dictionary, index: int) -> void:
	var name: String = foe_name_of(blueprint, node)
	if def.foes.has(name):
		return
	var archetypes: Array = defaults.get("archetypes", ["colorless_regime"]) as Array
	var icons: Array = defaults.get("icons", ["lorc/imp"]) as Array
	var ais: Array = defaults.get("ais", ["Balanced"]) as Array
	var data: Dictionary = spec as Dictionary if spec is Dictionary else {}
	var deck_key: String = str(data.get("deck", archetypes[index % archetypes.size()]))
	var icon: String = str(data.get("icon", icons[index % icons.size()]))
	var ai: String = str(data.get("ai", ais[index % ais.size()]))
	var hp: int = int(data.get("hp", 14 + (index % 3)))
	var recipe: Dictionary = {}
	if kind == K.BOSS:
		var boss: Dictionary = content.get("boss", {}) as Dictionary
		if name == PrimmBoss.BOSS_FOE:
			def.add_foe(name, PrimmBoss.phase(0).hp, "Balanced", PrimmBoss.phase(0).recipe, "cathelineau/old-king")
			return
		deck_key = str(boss.get("deck", deck_key))
		hp = int(boss.get("hp", 28))
		icon = str(boss.get("icon", icon))
		recipe = EnemyDecks.with_cards(EnemyDecks.recipe(deck_key, 17), (boss.get("extra", {}) as Dictionary).duplicate())
		def.add_foe(name, hp, str(data.get("ai", "Balanced")), recipe, icon)
		return
	var size: int = int(data.get("size", (31 if kind == K.ELITE else 27 + index % 3)))
	if kind == K.ELITE and not data.has("hp"):
		hp = 19
	if data.has("mixed"):
		var paths: Array[Affinity.Type] = []
		for path_name: Variant in data["mixed"] as Array:
			paths.append(AFFINITY_BY_NAME[str(path_name)] as Affinity.Type)
		recipe = EnemyDecks.mixed(deck_key, size, paths, 16)
	else:
		recipe = EnemyDecks.trimmed(deck_key, size, 16)
	if data.has("extra"):
		recipe = EnemyDecks.with_cards(recipe, (data["extra"] as Dictionary).duplicate())
	def.add_foe(name, hp, ai, recipe, icon)


static func _add_event(def: MainDungeonDef, blueprint: DungeonCatalog.Blueprint, node: DungeonCatalog.BlueprintNode, content: Dictionary) -> void:
	var spec: Variant = (content.get("events", {}) as Dictionary).get(str(node.number))
	var data: Dictionary = spec as Dictionary if spec is Dictionary else {}
	if data.has("ref"):
		return
	var id: String = event_id_of(blueprint, node.number)
	var event: DungeonEvent = DungeonEvent.make(id)
	if data.is_empty():
		data = _default_event(node)
	DungeonCatalog.set_text(event.title_key(), [str(data.get("title", node.node_name))])
	DungeonCatalog.set_text(event.body_key(), [str(data.get("body", ""))])
	var choices: Array = data.get("choices", []) as Array
	for index: int in range(choices.size()):
		var choice: Array = choices[index] as Array
		DungeonCatalog.set_text(event.choice_key(index), [str(choice[0])])
		DungeonCatalog.set_text(event.result_key(index), [str(choice[1])])
		var outcomes: Array[DungeonEvent.Outcome] = []
		for token_index: int in range(2, choice.size()):
			var outcome: DungeonEvent.Outcome = event_outcome(str(choice[token_index]), def)
			if outcome != null:
				outcomes.append(outcome)
		if outcomes.is_empty():
			outcomes.append(DungeonEvent.nothing())
		event.choice(outcomes)
	def.add_event(event)


static func _default_event(node: DungeonCatalog.BlueprintNode) -> Dictionary:
	return {
		"title": node.node_name,
		"body": "%s. Something here is worth a closer look." % node.node_name,
		"choices": [
			["Look around", "You find a little something and take it.", "gold:30"],
			["Rest a moment", "You catch your breath.", "heal:3"],
		],
	}


## One effect token of an event choice ("heal:3", "boon:Name|max_hp=2,atk=1", "sever"...) as an outcome (null for an unknown token).
static func event_outcome(token: String, def: MainDungeonDef) -> DungeonEvent.Outcome:
	var parts: PackedStringArray = token.split(":", true, 1)
	var arg: String = parts[1] if parts.size() > 1 else ""
	match parts[0]:
		"heal":
			return DungeonEvent.heal(int(arg))
		"damage":
			return DungeonEvent.damage(int(arg))
		"gold":
			return DungeonEvent.gold(int(arg))
		"pay":
			return DungeonEvent.pay_gold(int(arg))
		"card":
			return DungeonEvent.card(arg)
		"boon":
			return DungeonEvent.boon(boon_from(arg))
		"rescue":
			return DungeonEvent.boon(def.boon)
		"sever":
			return DungeonEvent.boon(RotheartDungeon.severed_boon())
		"nothing":
			return DungeonEvent.nothing()
	return null


## A boon from "Name|max_hp=2,atk=1,def=1,start_hp=1".
static func boon_from(spec: String) -> ModifierSource:
	var halves: PackedStringArray = spec.split("|", true, 1)
	var modifiers: Array[Modifier] = []
	var stats: Dictionary = {}
	if halves.size() > 1:
		for pair: String in halves[1].split(","):
			var kv: PackedStringArray = pair.split("=")
			if kv.size() == 2:
				stats[kv[0].strip_edges()] = int(kv[1])
	if stats.has("max_hp"):
		modifiers.append(CardBuilder.modifier(Modifier.Kind.MAX_HP, int(stats["max_hp"])))
	if stats.has("start_hp"):
		modifiers.append(CardBuilder.modifier(Modifier.Kind.STARTING_HP, int(stats["start_hp"])))
	if stats.has("atk") or stats.has("def"):
		modifiers.append(CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, int(stats.get("atk", 0)), Modifier.ANY_COLOR, int(stats.get("def", 0))))
	if modifiers.is_empty():
		modifiers.append(CardBuilder.modifier(Modifier.Kind.MAX_HP, 0))
	return MainDungeonDef.boon_source(halves[0].strip_edges(), modifiers)


static func _add_challenge(def: MainDungeonDef, blueprint: DungeonCatalog.Blueprint, node: DungeonCatalog.BlueprintNode, content: Dictionary) -> void:
	var spec: Variant = (content.get("challenges", {}) as Dictionary).get(str(node.number))
	var data: Dictionary = spec as Dictionary if spec is Dictionary else {}
	if data.has("ref"):
		return
	var id: String = event_id_of(blueprint, node.number)
	if data.is_empty():
		data = {"title": node.node_name, "text": "Your deck is put to the test.", "kind": "infra", "reveal": 5, "threshold": 2, "success": ["heal:3"], "failure": ["lose:2"]}
	var kind: ChallengeData.Kind = ChallengeData.Kind.TOP_N_INFRASTRUCTURE_COUNT
	match str(data.get("kind", "infra")):
		"first_unit_attack":
			kind = ChallengeData.Kind.FIRST_UNIT_ATTACK
		"type_units":
			kind = ChallengeData.Kind.TOP_N_TYPE_COUNT
		"total_cost":
			kind = ChallengeData.Kind.TOP_N_TOTAL_COST
	var challenge: ChallengeData = MainDungeonDef.make_challenge(id, "", "", kind, int(data.get("reveal", 5)), int(data.get("threshold", 2)))
	if str(data.get("card_type", "")) == "unit":
		challenge.card_type = CardEnums.CardType.UNIT
	DungeonCatalog.set_text("challenge.%s.title" % id, [str(data.get("title", node.node_name))])
	DungeonCatalog.set_text("challenge.%s.text" % id, [str(data.get("text", ""))])
	challenge.on_success = _challenge_outcomes(data.get("success", []) as Array)
	challenge.on_failure = _challenge_outcomes(data.get("failure", []) as Array)
	def.add_challenge(challenge)


static func _challenge_outcomes(tokens: Array) -> Array[ChallengeOutcome]:
	var result: Array[ChallengeOutcome] = []
	for token: Variant in tokens:
		var parts: PackedStringArray = str(token).split(":", true, 1)
		var arg: String = parts[1] if parts.size() > 1 else ""
		match parts[0]:
			"heal":
				result.append(MainDungeonDef.outcome(ChallengeOutcome.Kind.HEAL, int(arg), "Heal %d HP." % int(arg)))
			"lose":
				result.append(MainDungeonDef.outcome(ChallengeOutcome.Kind.LOSE_HP, int(arg), "Lose %d HP." % int(arg)))
			"boon":
				var boon: ModifierSource = boon_from(arg)
				var outcome: ChallengeOutcome = MainDungeonDef.outcome(ChallengeOutcome.Kind.GAIN_BOON, 0, "Gain the boon %s." % boon.source_name)
				outcome.boon = boon
				result.append(outcome)
	return result


# ---- The map -------------------------------------------------------------------------------------


static func build_map(blueprint: DungeonCatalog.Blueprint, def: MainDungeonDef) -> DungeonMap:
	var content: Dictionary = DungeonCatalog.content_for(blueprint.id)
	var map: DungeonMap = DungeonMap.new()
	map.dungeon_name = blueprint.dungeon_name
	var ids: Dictionary = {}
	var has_start: bool = false
	for node: DungeonCatalog.BlueprintNode in blueprint.nodes:
		if node.type == "start":
			has_start = true
	var story: ZoneStoryText = ZoneStoryText.for_zone(blueprint.zone_id)
	# The side dungeons start on their first battle: an invisible entrance node holds the party marker until the first fight is chosen.
	var entrance: DungeonMap.MapNode = null
	if not has_start:
		entrance = DungeonMap.MapNode.new()
		entrance.kind = K.START
		entrance.title = "Entrance"
		entrance.blurb = "The way in."
		entrance.hidden = true
		var first: DungeonCatalog.BlueprintNode = blueprint.nodes[0]
		entrance.position = Vector2(clampf(first.position.x - 0.1, 0.02, 0.98), clampf(first.position.y + 0.08, 0.02, 0.98))
		map.add_node(entrance)
	var battle_index: int = 0
	for node: DungeonCatalog.BlueprintNode in blueprint.nodes:
		var kind: DungeonMap.Kind = kind_of(node.type)
		var added: DungeonMap.MapNode = DungeonMap.MapNode.new()
		added.kind = kind
		added.number = node.number
		added.title = node.node_name
		added.position = node.position
		added.blurb = _blurb(blueprint, node, content)
		match kind:
			K.BATTLE, K.ELITE, K.BOSS:
				var foe_name: String = foe_name_of(blueprint, node)
				var fighter: MainDungeonDef.Foe = def.foe(foe_name)
				added.enemy_name = foe_name
				added.enemy_hp = fighter.hp
				added.ai_name = fighter.ai_name
				match kind:
					K.ELITE:
						added.difficulty = DungeonMap.Difficulty.ELITE
						added.card_choices = 3
					K.BOSS:
						added.difficulty = DungeonMap.Difficulty.BOSS
						added.card_choices = 3 if not blueprint.is_side() else 0
					_:
						added.difficulty = DungeonMap.Difficulty.NORMAL
				added.gold_reward = EncounterRewards.gold_for(added.difficulty) / 2
				battle_index += 1
			K.EVENT, K.RESCUE:
				var event_data: Variant = (content.get("events", {}) as Dictionary).get(str(node.number))
				if event_data is Dictionary and (event_data as Dictionary).has("ref"):
					added.event_id = str((event_data as Dictionary)["ref"])
				else:
					added.event_id = event_id_of(blueprint, node.number)
				if kind == K.RESCUE:
					added.rescue_flag = "rescued"
			K.CHALLENGE:
				var challenge_data: Variant = (content.get("challenges", {}) as Dictionary).get(str(node.number))
				if challenge_data is Dictionary and (challenge_data as Dictionary).has("ref"):
					added.challenge_id = str((challenge_data as Dictionary)["ref"])
				else:
					added.challenge_id = event_id_of(blueprint, node.number)
			K.SHRINE:
				added.heal_amount = 999
			K.TREASURE:
				var loot: Variant = (content.get("loot", {}) as Dictionary).get(str(node.number))
				added.treasure = (loot as Dictionary).duplicate() if loot is Dictionary else {"gold": 60, "xp": 30}
		var key: String = str((content.get("story_keys", {}) as Dictionary).get(str(node.number), ""))
		if not key.is_empty():
			if story.lines.has("dungeon.%s.before" % key) or DungeonCatalog.has_text("dungeon.%s.before" % key):
				added.story_before = "dungeon.%s.before" % key
			if story.lines.has("dungeon.%s.after" % key) or DungeonCatalog.has_text("dungeon.%s.after" % key):
				added.story_after = "dungeon.%s.after" % key
		var scenes: Dictionary = (content.get("scenes", {}) as Dictionary).get(str(node.number), {}) as Dictionary
		added.section = str((content.get("sections", {}) as Dictionary).get(str(node.number), ""))
		added.scene = str(scenes.get("before", ""))
		added.after_scene = str(scenes.get("after", ""))
		added = map.add_node(added)
		ids[node.number] = added.id
	if entrance != null:
		map.connect_nodes(entrance.id, int(ids[blueprint.nodes[0].number]))
	for node: DungeonCatalog.BlueprintNode in blueprint.nodes:
		var from_id: int = int(ids[node.number])
		for target: int in node.next:
			if ids.has(target):
				map.connect_nodes(from_id, int(ids[target]))
		if node.side and node.next.is_empty() and node.return_to > 0 and ids.has(node.return_to):
			map.node(from_id).return_to = int(ids[node.return_to])
	return map


static func _blurb(blueprint: DungeonCatalog.Blueprint, node: DungeonCatalog.BlueprintNode, content: Dictionary) -> String:
	var authored: String = str((content.get("blurbs", {}) as Dictionary).get(str(node.number), ""))
	if not authored.is_empty():
		return authored
	var foe: String = foe_name_of(blueprint, node)
	match node.type:
		"start":
			return "%s begins here." % blueprint.dungeon_name
		"battle":
			return "%s stands in the way." % foe
		"elite":
			return "A tougher fight: %s holds this place." % foe
		"boss":
			return "Boss: %s." % blueprint.boss
		"treasure":
			return "A stash worth a look."
		"event":
			return "Something here is worth a closer look."
		"challenge":
			return "Your deck is put to the test."
		"heal":
			return "A quiet place to recover your strength."
		"rescue":
			return "Someone is being held here. %s." % node.note
	return ""
