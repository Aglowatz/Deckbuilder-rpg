class_name EncounterScripts
extends RefCounted
## Overnight Oct 23, Part 1: mid-fight scripted events for bosses and elites, as data in `data/encounters/encounter_scripts.json`, keyed
## like `modifiers.json` (a dungeon foe's name, "zone:<zone>:<id>", "town:npc:<id>", "arena:<id>", Primm's phase keys...).
##
## Each trigger fires once per duel when its condition is met:
##   hp_below {pct}            the foe's HP is at or below pct% of what it started the duel with
##   turn {turn}               the start of the foe's own Nth turn (a one-line warning shows the turn before)
##   units_died {count, side?, card?}  that many units died ("own" = the foe's, "foe" = yours, "any"; `card` = only that card id)
##   foe_units_at_least {count}        you control that many units
##   own_units_at_most {count}         the foe controls that many units or fewer (checked at the start of its turns, from its 2nd)
##   foe_hp_below {pct}         your HP is at or below pct% of your starting HP
## Effects (in order): rule {a modifiers.json rule spec: adds a one-sided rule for the rest of the duel} | remove_rule {name} |
## summon {token, count?, token_name?, token_keywords?} | card {card, to: hand/deck/field, count?} | heal {amount} | shield {amount} |
## damage {amount} (to you) | resources {resource, count} | buff {atk, def} (the foe's units, for good) |
## debuff_foes {atk, def} (your units, until the foe's next turn) | exhaust_foes {count?, skip_refresh?} (your strongest ready units) |
## draw {count} | foe_heal {amount} (you heal: a gentle foe's moment of mercy) | exhaust_own {skip_refresh? = true} (its units stand down: exhausted, and by default
## they skip their next refresh).
##
## The triggers are telegraphed from the start: `EncounterModifiers.rules(key)` lists each one as a "scripted" rule (what can happen,
## never when the AI will act), and the battle HUD marks a trigger once it has fired. They are carried into a duel by a
## `Modifier.Kind.ENCOUNTER_SCRIPT` modifier on the foe's seat (added by `EncounterModifiers.source`), so every place that already
## applies an encounter's rules - the game and the balance simulation - gets its script too. The runtime state lives on the
## `GameState` (`script_runs`) and is copied by `GameState.clone`, so the AI's look-ahead sees what crossing a threshold will do.

const PATH: String = "res://data/encounters/encounter_scripts.json"
const DEFAULT_ICON: String = "lorc/fire-bowl"
const WHEN_TYPES: Array[String] = ["hp_below", "turn", "units_died", "foe_units_at_least", "own_units_at_most", "foe_hp_below"]
const EFFECT_KINDS: Array[String] = [
	"rule", "remove_rule", "summon", "card", "heal", "shield", "damage", "resources", "buff", "debuff_foes", "exhaust_foes", "draw",
	"foe_heal", "exhaust_own",
]


class Trigger:
	extends RefCounted
	var id: String = ""
	var name: String = ""
	var icon: String = DEFAULT_ICON
	## What can happen, shown under the rule icons from the start ("At half health: ...").
	var text: String = ""
	## The foe's line when it fires (may be empty).
	var line: String = ""
	## A short "what just happened" line for the banner and the log (defaults to the name).
	var banner: String = ""
	## The one-line warning the turn before a timed event ("Next turn: ...").
	var warn: String = ""
	var when_type: String = "hp_below"
	var value: int = 50
	var side: String = "own"
	var card_id: String = ""
	var effects: Array[Dictionary] = []

	func when_line() -> String:
		match when_type:
			"hp_below":
				return "At %d%% health" % value
			"turn":
				return "On its turn %d" % value
			"units_died":
				var whose: String = {"own": "of its units", "foe": "of your units", "any": "units"}.get(side, "units")
				return "When %d %s %s died" % [value, whose, "has" if value == 1 else "have"]
			"foe_units_at_least":
				return "When you have %d units" % value
			"own_units_at_most":
				return "When its side is down to %d units" % value
			"foe_hp_below":
				return "When you drop to %d%% health" % value
		return ""


## One trigger list's runtime state in one duel.
class Run:
	extends RefCounted
	var key: String = ""
	var owner: int = 1
	var start_hp: int = 1
	var foe_start_hp: int = 1
	var triggers: Array = []
	## trigger id -> the turn it fired.
	var fired: Dictionary = {}
	var warned: Dictionary = {}
	## Units that died, by controller seat; and by card id.
	var deaths: Array[int] = [0, 0]
	var deaths_by_card: Dictionary = {}

	func clone() -> Run:
		var copy: Run = Run.new()
		copy.key = key
		copy.owner = owner
		copy.start_hp = start_hp
		copy.foe_start_hp = foe_start_hp
		copy.triggers = triggers
		copy.fired = fired.duplicate()
		copy.warned = warned.duplicate()
		copy.deaths = deaths.duplicate()
		copy.deaths_by_card = deaths_by_card.duplicate()
		return copy

	func trigger(id: String) -> Trigger:
		for each: Trigger in triggers:
			if each.id == id:
				return each
		return null


static var _scripts: Dictionary = {}
static var _loaded: bool = false
static var _problems: Array[String] = []


static func reset() -> void:
	_scripts = {}
	_loaded = false
	_problems = []


static func _load() -> void:
	if _loaded:
		return
	_loaded = true
	_scripts = {}
	if not FileAccess.file_exists(PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if not (parsed is Dictionary):
		_problems.append("encounter_scripts.json is not an object")
		return
	for key: Variant in (parsed as Dictionary).keys():
		if str(key).begins_with("_"):
			continue
		var list: Array[Trigger] = []
		var index: int = 0
		for spec: Variant in (parsed as Dictionary)[key] as Array:
			var made: Trigger = build_trigger(spec as Dictionary, str(key), index)
			if made != null:
				list.append(made)
			index += 1
		if not list.is_empty():
			_scripts[str(key)] = list


static func build_trigger(spec: Dictionary, key: String = "", index: int = 0) -> Trigger:
	var made: Trigger = Trigger.new()
	made.id = str(spec.get("id", "t%d" % index))
	made.name = str(spec.get("name", ""))
	made.icon = str(spec.get("icon", DEFAULT_ICON))
	made.text = str(spec.get("text", ""))
	made.line = str(spec.get("line", ""))
	made.banner = str(spec.get("banner", made.name))
	made.warn = str(spec.get("warn", ""))
	var when: Dictionary = spec.get("when", {}) as Dictionary
	made.when_type = str(when.get("type", ""))
	if not WHEN_TYPES.has(made.when_type):
		_problems.append("%s/%s: unknown condition '%s'" % [key, made.id, made.when_type])
		return null
	made.value = int(when.get("pct", when.get("turn", when.get("count", 1))))
	made.side = str(when.get("side", "own"))
	made.card_id = str(when.get("card", ""))
	for effect: Variant in spec.get("effects", []) as Array:
		var entry: Dictionary = effect as Dictionary
		var kind: String = str(entry.get("kind", ""))
		if not EFFECT_KINDS.has(kind):
			_problems.append("%s/%s: unknown effect '%s'" % [key, made.id, kind])
			continue
		if kind == "summon" and TokenRegistry.data(str(entry.get("token", ""))) == null:
			_problems.append("%s/%s: unknown token %s" % [key, made.id, str(entry.get("token", ""))])
			continue
		if kind == "card" and card_data(str(entry.get("card", ""))) == null:
			_problems.append("%s/%s: unknown card %s" % [key, made.id, str(entry.get("card", ""))])
			continue
		if kind == "rule" and EncounterModifiers.build_rule(entry.get("rule", {}) as Dictionary, key) == null:
			_problems.append("%s/%s: bad rule" % [key, made.id])
			continue
		made.effects.append(entry)
	if made.name.is_empty() or made.effects.is_empty():
		_problems.append("%s/%s: needs a name and at least one effect" % [key, made.id])
		return null
	return made


## Adds (or replaces) a key's triggers in memory - tests and tools; the game reads the JSON.
static func register(key: String, list: Array[Trigger]) -> void:
	_load()
	_scripts[key] = list


static func keys() -> Array[String]:
	_load()
	var result: Array[String] = []
	for key: Variant in _scripts.keys():
		result.append(str(key))
	result.sort()
	return result


static func problems() -> Array[String]:
	_load()
	return _problems


static func has_script(key: String) -> bool:
	_load()
	return _scripts.has(key)


static func triggers(key: String) -> Array[Trigger]:
	_load()
	var result: Array[Trigger] = []
	if _scripts.has(key):
		result.append_array(_scripts[key] as Array[Trigger])
	return result


## Bestiary entries whose fights are keyed differently from their name (town fights, zone elites, the arena, Primm's phases, the four
## corrupted wanderers sharing one entry).
const ENTRY_KEYS: Dictionary = {
	"The Restless Dead": ["town:graveyard"], "Shiro Swindle": ["town:ninja"], "The Warden of the Four Seals": ["town:vault"],
	"The Wellspring's Echo": ["town:old_well"], "Colonel Casserole": ["zone:gourmand:casserole"], "Captain Spotless": ["zone:final:spotless"],
	"Announcer Grand Bellows": ["arena:arena_marshal"], "Cardboard Colossus": ["arena:arena_spells_only"],
	"Champion of the Four Fists": ["arena:arena_four_fists"],
	"Primm, His Perfection": ["Primm (standardization)", "Primm (reflection)", "Primm (unraveling)"],
	"Corrupted Wanderers": ["town:npc:beefcake", "town:npc:gourmand", "town:npc:refusemancer", "town:npc:necrocrat"],
}


## The scripted events a Bestiary entry's fights have (its "signature moves"), in order.
static func triggers_for_entry(entry_name: String) -> Array[Trigger]:
	var result: Array[Trigger] = []
	var keys: Array = ENTRY_KEYS.get(entry_name, [entry_name]) as Array
	for key: Variant in keys:
		result.append_array(triggers(str(key)))
	if entry_name == "Vivienne Quota, Minister of Efficiency":
		result.append_array(triggers("capital:quota"))
	return result


## A card by id (cards and tokens).
static func card_data(id: String) -> CardData:
	if id.is_empty():
		return null
	return TokenRegistry.data(id)


## The modifier that carries `key`'s script onto the foe's seat.
static func carrier(key: String) -> Modifier:
	var modifier: Modifier = Modifier.new()
	modifier.kind = Modifier.Kind.ENCOUNTER_SCRIPT
	modifier.label = key
	return modifier


## The scripted triggers of `key` as display rules (EncounterModifiers.rules appends these): one per trigger, no modifiers.
static func display_rules(key: String) -> Array[EncounterModifiers.Rule]:
	var result: Array[EncounterModifiers.Rule] = []
	for each: Trigger in triggers(key):
		var rule: EncounterModifiers.Rule = EncounterModifiers.Rule.new()
		rule.name = each.name
		rule.text = each.text
		rule.icon = each.icon
		rule.scripted = true
		result.append(rule)
	return result


# ---- Runtime (called by GameState; pure logic) -------------------------------------------------------------------------------


## Starts a Run for every script carried by the seat's modifiers (GameState.add_player).
static func attach(state: GameState, player: PlayerState) -> void:
	for modifier: Modifier in player.modifiers.modifiers:
		if modifier.kind != Modifier.Kind.ENCOUNTER_SCRIPT or not has_script(modifier.label):
			continue
		var run: Run = Run.new()
		run.key = modifier.label
		run.owner = player.index
		run.start_hp = maxi(1, player.hp)
		run.triggers = triggers(modifier.label)
		state.script_runs.append(run)


## Both seats are in: the foe's starting HP is known (for foe_hp_below).
static func on_start(state: GameState) -> void:
	for run: Run in state.script_runs:
		var foe: int = 1 - run.owner
		if foe >= 0 and foe < state.players.size():
			run.foe_start_hp = maxi(1, state.players[foe].hp)


static func note_death(state: GameState, card: CardInstance) -> void:
	if not card.data.is_unit():
		return
	for run: Run in state.script_runs:
		if card.owner >= 0 and card.owner < 2:
			run.deaths[card.owner] += 1
		run.deaths_by_card[card.data.id] = int(run.deaths_by_card.get(card.data.id, 0)) + 1


## The active player's turn has begun (after its draws and timed summons): turn triggers fire, warnings for the next turn go out.
static func on_turn_start(state: GameState) -> void:
	for run: Run in state.script_runs:
		if state.is_over():
			return
		var owner: PlayerState = state.players[run.owner]
		for each: Trigger in run.triggers:
			if run.fired.has(each.id):
				continue
			if run.owner == state.active and each.when_type == "turn" and owner.turns_taken >= each.value:
				fire(state, run, each)
			elif run.owner == state.active and each.when_type == "own_units_at_most" and owner.turns_taken >= 2 and _unit_count(owner) <= each.value:
				fire(state, run, each)
			elif run.owner != state.active and each.when_type == "turn" and owner.turns_taken + 1 == each.value and not run.warned.has(each.id):
				run.warned[each.id] = true
				var text: String = each.warn if not each.warn.is_empty() else "Next turn: %s." % each.name
				state.emit_event(GameEvent.Type.SCRIPT_WARNING, run.owner, 0, 0, 0, 0, text)
		if state.is_over():
			return
		# The rules' own timers (TIMED_SUMMON) get the same warning the turn before they fire.
		if run.owner != state.active:
			for modifier: Modifier in owner.modifiers.modifiers:
				if modifier.kind == Modifier.Kind.TIMED_SUMMON and not modifier.tokens.is_empty() and modifier.value > 1 and (owner.turns_taken + 1) % modifier.value == 0:
					var token: CardData = modifier.tokens[0]
					state.emit_event(GameEvent.Type.SCRIPT_WARNING, run.owner, 0, 0, 0, 0,
						"Next turn: %s (%d/%d) arrives - %s." % [token.display_name, token.attack, token.defense, modifier.label])
	check(state)


## Thresholds and conditions (GameState.check_state, after deaths and losses are resolved).
static func check(state: GameState) -> void:
	if state.is_over():
		return
	for run: Run in state.script_runs:
		for each: Trigger in run.triggers:
			if state.is_over():
				return
			if run.fired.has(each.id):
				continue
			if _condition_met(state, run, each):
				fire(state, run, each)


static func _condition_met(state: GameState, run: Run, each: Trigger) -> bool:
	var owner: PlayerState = state.players[run.owner]
	var foe: PlayerState = state.players[1 - run.owner]
	match each.when_type:
		"hp_below":
			return owner.hp > 0 and owner.hp * 100 <= run.start_hp * each.value
		"foe_hp_below":
			return foe.hp > 0 and foe.hp * 100 <= run.foe_start_hp * each.value
		"units_died":
			if not each.card_id.is_empty():
				return int(run.deaths_by_card.get(each.card_id, 0)) >= each.value
			match each.side:
				"foe":
					return run.deaths[1 - run.owner] >= each.value
				"any":
					return run.deaths[0] + run.deaths[1] >= each.value
			return run.deaths[run.owner] >= each.value
		"foe_units_at_least":
			return _unit_count(foe) >= each.value
	return false


static func _unit_count(player: PlayerState) -> int:
	var count: int = 0
	for card: CardInstance in player.field:
		if card.data.is_unit():
			count += 1
	return count


## Fires one trigger: marks it, announces it, then resolves its effects in order.
static func fire(state: GameState, run: Run, each: Trigger) -> void:
	if run.fired.has(each.id):
		return
	run.fired[each.id] = state.turn
	state.emit_event(GameEvent.Type.SCRIPT_TRIGGERED, run.owner, 0, 0, state.turn, run.triggers.find(each), "%s|%s" % [run.key, each.id])
	state.script_busy += 1
	for effect: Dictionary in each.effects:
		if state.is_over():
			break
		_resolve(state, run, effect)
	state.script_busy -= 1
	state.check_state()


static func _resolve(state: GameState, run: Run, effect: Dictionary) -> void:
	var owner: int = run.owner
	var foe: int = 1 - owner
	var player: PlayerState = state.players[owner]
	match str(effect.get("kind", "")):
		"rule":
			var rule: EncounterModifiers.Rule = EncounterModifiers.build_rule(effect.get("rule", {}) as Dictionary, run.key)
			if rule != null:
				var target: PlayerState = player if rule.is_enemy_side() else state.players[foe]
				for modifier: Modifier in rule.modifiers:
					target.modifiers.add(modifier)
		"remove_rule":
			var label: String = str(effect.get("name", ""))
			var kept: Array[Modifier] = []
			for modifier: Modifier in player.modifiers.modifiers:
				if modifier.label != label:
					kept.append(modifier)
			player.modifiers.modifiers = kept
		"summon":
			var token: CardData = EncounterModifiers._token_of(effect, run.key)
			if token != null:
				for i: int in range(maxi(1, int(effect.get("count", 1)))):
					if state.is_over():
						return
					state.create_token(owner, token)
		"card":
			var data: CardData = card_data(str(effect.get("card", "")))
			if data == null:
				return
			for i: int in range(maxi(1, int(effect.get("count", 1)))):
				var card: CardInstance = state.create_instance(data, owner)
				match str(effect.get("to", "hand")):
					"deck":
						player.deck.insert(state.rng.randi_range(0, player.deck.size()), card)
					"field":
						if data.is_unit() and state.put_onto_field(card, owner, false):
							pass
						else:
							player.hand.append(card)
					_:
						player.hand.append(card)
						state.emit_event(GameEvent.Type.CARD_TO_HAND, owner, card.uid)
		"heal":
			var cap: int = maxi(player.max_hp, run.start_hp)
			var gained: int = mini(int(effect.get("amount", 0)), cap - player.hp)
			if gained > 0:
				player.hp += gained
				state.emit_event(GameEvent.Type.HP_CHANGED, owner, 0, 0, gained, player.hp)
		"shield":
			player.shield += maxi(0, int(effect.get("amount", 0)))
		"damage":
			state.deal_damage_to_player(0, foe, int(effect.get("amount", 1)))
		"resources":
			var kind: int = ResourceKind.from_word(str(effect.get("resource", "")))
			if kind >= 0:
				ResourceRules.create(state, owner, kind as ResourceKind.Kind, maxi(1, int(effect.get("count", 1))))
		"buff":
			for card: CardInstance in player.field.duplicate():
				if card.data.is_unit():
					state.change_stats(card, int(effect.get("atk", 0)), int(effect.get("def", 0)), false)
		"debuff_foes":
			for card: CardInstance in state.players[foe].field.duplicate():
				if card.data.is_unit():
					state.change_stats_until_turn_of(card, -int(effect.get("atk", 0)), -int(effect.get("def", 0)), owner)
		"exhaust_foes":
			var ready: Array[CardInstance] = []
			for card: CardInstance in state.players[foe].field:
				if card.data.is_unit() and not card.exhausted:
					ready.append(card)
			ready.sort_custom(func(a: CardInstance, b: CardInstance) -> bool: return state.get_attack(a) > state.get_attack(b))
			var count: int = int(effect.get("count", 99))
			for card: CardInstance in ready.slice(0, count):
				state.exhaust_unit(card, bool(effect.get("skip_refresh", false)))
		"draw":
			state.draw_cards(owner, maxi(1, int(effect.get("count", 1))))
		"foe_heal":
			state.gain_hp(foe, int(effect.get("amount", 1)))
		"exhaust_own":
			for card: CardInstance in player.field.duplicate():
				if card.data.is_unit():
					state.exhaust_unit(card, bool(effect.get("skip_refresh", true)))


## The trigger behind a SCRIPT_TRIGGERED event's detail ("key|id"), for the UI and the log.
static func trigger_for_event(detail: String) -> Trigger:
	var parts: PackedStringArray = detail.split("|")
	if parts.size() < 2:
		return null
	for each: Trigger in triggers(parts[0]):
		if each.id == parts[1]:
			return each
	return null
