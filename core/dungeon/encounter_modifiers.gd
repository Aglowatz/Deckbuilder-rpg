class_name EncounterModifiers
extends RefCounted
## Rebalance Part E (Oct 18 2026): one-sided encounter rules - starting tokens on the field, tokens summoned on a timer, one-sided
## buffs ("its units enter +1/+1"), extra starting resources, unique boss abilities - as data in `data/encounters/modifiers.json`,
## keyed by encounter: a dungeon foe's name ("Chancellor Clench, Iron Regent"), a zone roamer ("zone:beefcake:golem"), a town fight
## ("town:npc:beefcake", "town:graveyard"), an arena fight ("arena:<id>"). Every rule goes through the normal Modifier pipeline on the
## enemy's seat (`side: "enemy"`, the default) or the player's (`side: "player"`), and is shown to the player as an icon with a
## tooltip before the battle (the dungeon map's node info, the zone HUD's toast) and during it (`EncounterRulesPanel` in the battle
## HUD). The balance simulation (`EncounterCatalog`) reads the same registry, so it plays exactly what the player meets.
##
## Rule vocabulary (JSON `kind`): starting_resources {resource, count} | stat {atk, def, path?} | starting_tokens {token, count} |
## timed_summon {token, every, count?} | escalating_summon {tokens: [...]} | keyword {keyword, path?} | extra_draws {count} |
## cost_change {amount, path?} | enter_exhausted {path?} | token_stats {atk, def} | start_of_turn_damage {amount} |
## start_of_turn_heal {amount} | retaliate {amount} | max_hp {amount} | max_traps {amount} | resource_bonus {resource, count} |
## first_turn_draw {count} | always_first | max_plays {count} | block_resource {resource} | keyword_stat {keyword, atk} |
## first_card_cost {amount} | start_of_turn_resources {resource, count} (Oct 21, Siphon's Protocols) | hp_gain_bonus {amount} (Oct 21, the Old Well).

const PATH: String = "res://data/encounters/modifiers.json"
const DEFAULT_ICON: String = "lorc/crossed-swords"


class Rule:
	extends RefCounted
	var name: String = ""
	var text: String = ""
	var icon: String = DEFAULT_ICON
	## "enemy" (the default) or "player".
	var side: String = "enemy"
	## Oct 21: a player-side rule that hurts the player (Siphon's Containment), shown as a bad badge.
	var harmful: bool = false
	var modifiers: Array[Modifier] = []

	func is_enemy_side() -> bool:
		return side != "player"

	func tooltip() -> String:
		return "%s\n\n%s" % [text, "Applies to the enemy only." if is_enemy_side() else "Applies to you only."]


static var _rules: Dictionary = {}
static var _loaded: bool = false
static var _problems: Array[String] = []


static func reset() -> void:
	_rules = {}
	_loaded = false
	_problems = []


static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	_rules = {}
	if not FileAccess.file_exists(PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if not (parsed is Dictionary):
		_problems.append("modifiers.json is not an object")
		return
	for key: Variant in (parsed as Dictionary).keys():
		if str(key).begins_with("_"):
			continue
		var list: Array[Rule] = []
		for spec: Variant in (parsed as Dictionary)[key] as Array:
			var rule: Rule = build_rule(spec as Dictionary, str(key))
			if rule != null:
				list.append(rule)
		_rules[str(key)] = list


## Every encounter key that has rules.
static func keys() -> Array[String]:
	_load()
	var result: Array[String] = []
	for key: Variant in _rules.keys():
		result.append(str(key))
	result.sort()
	return result


## Problems found while loading (unknown kinds, unknown tokens); empty when the data is clean.
static func problems() -> Array[String]:
	_load()
	return _problems


static func has_rules(key: String) -> bool:
	_load()
	return _rules.has(key) and not (_rules[key] as Array).is_empty()


static func rules(key: String) -> Array[Rule]:
	_load()
	var result: Array[Rule] = []
	if _rules.has(key):
		result.append_array(_rules[key] as Array[Rule])
	return result


static func zone_key(zone_id: String, enemy_id: String) -> String:
	return "zone:%s:%s" % [zone_id, enemy_id]


## The rules of one side as a ModifierSource (null when that side has none).
static func source(key: String, enemy_side: bool) -> ModifierSource:
	var modifiers: Array[Modifier] = []
	var names: PackedStringArray = []
	for rule: Rule in rules(key):
		if rule.is_enemy_side() != enemy_side:
			continue
		modifiers.append_array(rule.modifiers)
		names.append(rule.name)
	if modifiers.is_empty():
		return null
	var made: ModifierSource = ModifierSource.new()
	made.source_name = "Encounter rules: %s" % ", ".join(names)
	made.source_kind = ModifierSource.SourceKind.DUNGEON
	made.modifiers = modifiers
	return made


static func enemy_source(key: String) -> ModifierSource:
	return source(key, true)


static func player_source(key: String) -> ModifierSource:
	return source(key, false)


## Adds the enemy-side rules of `key` to an enemy seat (no-op without rules).
static func apply_to_enemy(setup: PlayerSetup, key: String) -> void:
	var made: ModifierSource = enemy_source(key)
	if made != null and setup != null:
		setup.modifiers.add_source(made)


## `base` plus the player-side rules of `key` as one source (either may be null).
static func merge_player_rules(base: ModifierSource, key: String) -> ModifierSource:
	var extra: ModifierSource = player_source(key)
	if extra == null:
		return base
	if base == null:
		return extra
	var merged: ModifierSource = ModifierSource.new()
	merged.source_name = "%s + %s" % [base.source_name, extra.source_name]
	merged.source_kind = base.source_kind
	merged.modifiers = base.modifiers.duplicate()
	merged.modifiers.append_array(extra.modifiers)
	return merged


## "Iron Regent, Reinforcements" - the rule names, for a toast or a node blurb.
static func names_line(key: String) -> String:
	var names: PackedStringArray = []
	for rule: Rule in rules(key):
		names.append(rule.name)
	return ", ".join(names)


# ---- Building rules from the JSON vocabulary -------------------------------------------------------------------------------------


static func build_rule(spec: Dictionary, key: String = "") -> Rule:
	var rule: Rule = Rule.new()
	rule.name = str(spec.get("name", ""))
	rule.text = str(spec.get("text", ""))
	rule.icon = str(spec.get("icon", DEFAULT_ICON))
	rule.side = str(spec.get("side", "enemy"))
	rule.harmful = bool(spec.get("harmful", false))
	var kind: String = str(spec.get("kind", ""))
	var path: int = _path_of(spec)
	var made: Array[Modifier] = []
	match kind:
		"starting_resources":
			made.append(CardBuilder.modifier(Modifier.Kind.STARTING_RESOURCES, int(spec.get("count", 1)), Modifier.ANY_COLOR, _resource_of(spec)))
		"stat":
			made.append(CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, int(spec.get("atk", 0)), path, int(spec.get("def", 0))))
		"starting_tokens":
			var token: CardData = _token_of(spec, key)
			if token != null:
				made.append(_effect_modifier(Modifier.Kind.START_OF_DUEL_EFFECT, CardEnums.EffectOp.SUMMON_TOKEN, int(spec.get("count", 1)), CardEnums.TargetKind.CONTROLLER, token))
		"timed_summon":
			var token: CardData = _token_of(spec, key)
			if token != null:
				var timed: Modifier = CardBuilder.modifier(Modifier.Kind.TIMED_SUMMON, maxi(1, int(spec.get("every", 2))), Modifier.ANY_COLOR, maxi(1, int(spec.get("count", 1))))
				timed.tokens = [token] as Array[CardData]
				made.append(timed)
		"escalating_summon":
			var stages: Array[CardData] = []
			for id: Variant in spec.get("tokens", []) as Array:
				var token: CardData = TokenRegistry.data(str(id))
				if token == null:
					_problems.append("%s: unknown token %s" % [key, str(id)])
				else:
					stages.append(token)
			if not stages.is_empty():
				var escalating: Modifier = CardBuilder.modifier(Modifier.Kind.SCRIPTED_ESCALATING_SUMMON, 1)
				escalating.tokens = stages
				made.append(escalating)
		"keyword":
			var keyword: int = ScriptParser.keyword_from_word(str(spec.get("keyword", "")))
			if keyword < 0:
				_problems.append("%s: unknown keyword %s" % [key, str(spec.get("keyword", ""))])
			else:
				made.append(CardBuilder.modifier(Modifier.Kind.GRANT_KEYWORD_TO_UNITS, keyword, path, 0))
		"keyword_stat":
			var keyword: int = ScriptParser.keyword_from_word(str(spec.get("keyword", "")))
			if keyword < 0:
				_problems.append("%s: unknown keyword %s" % [key, str(spec.get("keyword", ""))])
			else:
				made.append(CardBuilder.modifier(Modifier.Kind.KEYWORD_STAT_CHANGE, int(spec.get("atk", 1)), Modifier.ANY_COLOR, keyword))
		"extra_draws":
			made.append(CardBuilder.modifier(Modifier.Kind.EXTRA_DRAWS, int(spec.get("count", 1))))
		"cost_change":
			made.append(CardBuilder.modifier(Modifier.Kind.COST_CHANGE, int(spec.get("amount", 1)), path, 0))
		"enter_exhausted":
			made.append(CardBuilder.modifier(Modifier.Kind.ENTER_EXHAUSTED, 1, path, 0))
		"token_stats":
			made.append(CardBuilder.modifier(Modifier.Kind.TOKEN_STAT_CHANGE, int(spec.get("atk", 1)), Modifier.ANY_COLOR, int(spec.get("def", 1))))
		"start_of_turn_damage":
			made.append(_effect_modifier(Modifier.Kind.START_OF_TURN_EFFECT, CardEnums.EffectOp.DEAL_DAMAGE, int(spec.get("amount", 1)), CardEnums.TargetKind.OPPONENT))
		"start_of_turn_heal":
			made.append(_effect_modifier(Modifier.Kind.START_OF_TURN_EFFECT, CardEnums.EffectOp.GAIN_HP, int(spec.get("amount", 1)), CardEnums.TargetKind.CONTROLLER))
		"retaliate":
			made.append(_effect_modifier(Modifier.Kind.RETALIATE_ON_ATTACK, CardEnums.EffectOp.DEAL_DAMAGE, int(spec.get("amount", 1)), CardEnums.TargetKind.ALL_ATTACKERS))
		"max_hp":
			made.append(CardBuilder.modifier(Modifier.Kind.MAX_HP, int(spec.get("amount", 0))))
		"max_traps":
			made.append(CardBuilder.modifier(Modifier.Kind.MAX_TRAPS, int(spec.get("amount", 1))))
		"resource_bonus":
			made.append(CardBuilder.modifier(Modifier.Kind.RESOURCE_BONUS, int(spec.get("count", 1)), Modifier.ANY_COLOR, _resource_of(spec)))
		"first_turn_draw":
			made.append(CardBuilder.modifier(Modifier.Kind.FIRST_TURN_EXTRA_DRAW, int(spec.get("count", 1))))
		"always_first":
			made.append(CardBuilder.modifier(Modifier.Kind.ALWAYS_FIRST, 1))
		"max_plays":
			made.append(CardBuilder.modifier(Modifier.Kind.MAX_NON_INFRASTRUCTURE_PLAYS_PER_TURN, int(spec.get("count", 2))))
		"block_resource":
			made.append(CardBuilder.modifier(Modifier.Kind.BLOCK_RESOURCE_USE, _resource_of(spec)))
		"hp_gain_bonus":
			made.append(CardBuilder.modifier(Modifier.Kind.HP_GAIN_BONUS, int(spec.get("amount", 1))))
		"first_card_cost":
			made.append(CardBuilder.modifier(Modifier.Kind.FIRST_CARD_COST_CHANGE, int(spec.get("amount", 1))))
		"start_of_turn_resources":
			made.append(CardBuilder.modifier(Modifier.Kind.START_OF_TURN_RESOURCES, int(spec.get("count", 1)), Modifier.ANY_COLOR, _resource_of(spec)))
		_:
			_problems.append("%s: unknown rule kind '%s'" % [key, kind])
			return null
	if made.is_empty():
		return null
	for modifier: Modifier in made:
		modifier.label = rule.name
	rule.modifiers = made
	return rule


static func _path_of(spec: Dictionary) -> int:
	var word: String = str(spec.get("path", "")).to_lower()
	match word:
		"beefcake", "b":
			return int(Affinity.Type.BEEFCAKE)
		"necrocrat", "n":
			return int(Affinity.Type.NECROCRAT)
		"gourmand", "g":
			return int(Affinity.Type.GOURMAND)
		"refusemancer", "r":
			return int(Affinity.Type.REFUSEMANCER)
		"neutral", "colorless":
			return int(Affinity.Type.NEUTRAL)
	return Modifier.ANY_COLOR


static func _resource_of(spec: Dictionary) -> int:
	var kind: int = ResourceKind.from_word(str(spec.get("resource", "")))
	return kind if kind >= 0 else int(ResourceKind.Kind.IRON)


static func _token_of(spec: Dictionary, key: String) -> CardData:
	var id: String = str(spec.get("token", ""))
	var token: CardData = TokenRegistry.data(id)
	if token == null:
		_problems.append("%s: unknown token %s" % [key, id])
		return null
	# Oct 20: a rule may rename a token and set its keywords ("token_name", "token_keywords": [] = none) - the store room's plain 1/1 Ghost is
	# the Hungry Ghost (its art) without Flying. The copy keeps the token's id, so its art and its bestiary entry still match.
	if spec.has("token_name") or spec.has("token_keywords"):
		token = token.duplicate() as CardData
		if spec.has("token_name"):
			token.display_name = str(spec["token_name"])
		if spec.has("token_keywords"):
			var keywords: Array[CardEnums.Keyword] = []
			for word: Variant in spec["token_keywords"] as Array:
				keywords.append(CardEnums.Keyword.get(str(word).to_upper()) as CardEnums.Keyword)
			token.keywords = keywords
			token.rules_text = "" if keywords.is_empty() else token.rules_text
			token.script_text = "" if keywords.is_empty() else token.script_text
	return token


static func _effect_modifier(kind: Modifier.Kind, op: CardEnums.EffectOp, amount: int, target: CardEnums.TargetKind, token: CardData = null) -> Modifier:
	var effect: EffectData = EffectData.new()
	effect.op = op
	effect.amount = amount
	effect.target = target
	if token != null:
		effect.token = token
	var modifier: Modifier = Modifier.new()
	modifier.kind = kind
	modifier.effect = effect
	return modifier
