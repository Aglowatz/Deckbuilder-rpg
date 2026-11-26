extends CardTestBase
## Overnight Nov 19 (Part 5): every choice node of the main and side dungeons (Primm's Castle left as it was: the owner's castle rule) -
## no option is purely good (a boon carries a drawback; doing nothing is fine), early drawbacks are short, and the Hall of Final Approvals'
## Processing Time applies in three fights only (the Intake Clerk, the Executive Elevator Operator, Mortimer), spells only.

## Fable Nov 19 (Part 5.1): the castle follows the rule too now (the owner said yes).
const SKIPPED: Array[String] = []


func _is_good(token: String) -> bool:
	var kind: String = token.split(":")[0]
	if kind in ["heal", "gold", "card", "rescue", "sever"]:
		return true
	if kind == "boon":
		return not BoonText.is_curse(DungeonBuilder.boon_from(token.substr(5)))
	return false


func _is_bad(token: String) -> bool:
	var kind: String = token.split(":")[0]
	# Nov 25 night (Part G): a patrol's shredding (every card of a type gone for the run) is a drawback
	if kind in ["damage", "pay", "lose", "shred_type"]:
		return true
	if kind == "curse" or kind == "boon":
		return BoonText.is_curse(DungeonBuilder.boon_from(token.substr(5)))
	return token == "gold:0"


func test_no_option_is_purely_good() -> void:
	var content: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/dungeons/dungeon_content.json")) as Dictionary
	var checked: int = 0
	for dungeon_id: String in (content["dungeons"] as Dictionary).keys():
		if SKIPPED.has(dungeon_id):
			continue
		var events: Dictionary = ((content["dungeons"] as Dictionary)[dungeon_id] as Dictionary).get("events", {}) as Dictionary
		for node: String in events.keys():
			var event: Dictionary = events[node] as Dictionary
			if event.has("ref"):
				continue
			for choice: Variant in event.get("choices", []) as Array:
				var row: Array = choice as Array
				var tokens: Array = row.slice(2)
				var good: bool = false
				var bad: bool = false
				for token: Variant in tokens:
					good = good or _is_good(str(token))
					bad = bad or _is_bad(str(token))
				checked += 1
				assert_true(not good or bad, "%s node %s '%s': a boon needs a drawback (%s)" % [dungeon_id, node, row[0], str(tokens)])
	assert_gt(checked, 40)


func test_the_kiosk_follows_the_brief() -> void:
	var content: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/dungeons/dungeon_content.json")) as Dictionary
	var kiosk: Array = ((((content["dungeons"] as Dictionary)["D-HFA"] as Dictionary)["events"] as Dictionary)["2"] as Dictionary)["choices"] as Array
	assert_eq((kiosk[0] as Array).slice(2), ["nothing"], "Take a number and wait does nothing")
	assert_true(str((kiosk[1] as Array)[2]).begins_with("gold:"))
	# Fable Nov 21 (Part 4.3): the price of taking every number is a drawback in the next fight now (it was 2 damage)
	assert_true(str((kiosk[1] as Array)[3]).begins_with("curse:Lost Your Place|first_draw=-1"))
	var boon: ModifierSource = DungeonBuilder.boon_from(str((kiosk[2] as Array)[2]).substr(5))
	assert_eq(boon.fights_left, 1, "the next encounter only")


func test_a_next_fight_boon_lasts_one_fight() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	var run: DungeonRun = DungeonRun.enter(Session.profile, Session.deck, [] as Array[ModifierSource])
	var template: ModifierSource = DungeonBuilder.boon_from("Cut the Line|atk=1,next=1")
	run.add_dungeon_source(template)
	assert_eq(run.dungeon_sources.size(), 1)
	assert_eq(BoonText.short(run.dungeon_sources[0]), "your units get +1 attack in the next fight")
	run.tick_timed_sources()
	assert_true(run.dungeon_sources.is_empty(), "gone after one fight")
	assert_eq(template.fights_left, 1, "the event's own template is untouched")


func test_an_enemy_drawback_goes_to_the_enemy() -> void:
	var source: ModifierSource = DungeonBuilder.boon_from("Watched|foe_atk=1")
	assert_true(source.for_enemy)
	assert_true(BoonText.is_curse(source))
	assert_string_contains(BoonText.short(source), "the enemy's units get +1 attack")
	var mods: ModifierSet = ModifierPipeline.build(null, null, [source] as Array[ModifierSource])
	assert_eq(mods.sum(Modifier.Kind.STAT_CHANGE), 0, "not on the player's side")


func test_processing_time_is_three_fights_and_spells_only() -> void:
	for node: int in [3, 13, 14]:
		var source: ModifierSource = DungeonRules.shared_source("necrocrat", node)
		assert_not_null(source, "node %d" % node)
		var found: bool = false
		for modifier: Modifier in source.modifiers:
			found = found or modifier.kind == Modifier.Kind.FIRST_SPELL_COST_CHANGE
		assert_true(found, "Processing Time in node %d" % node)
	for node: int in [4, 7, 9, 11]:
		var other: ModifierSource = DungeonRules.shared_source("necrocrat", node)
		var found_other: bool = false
		if other != null:
			for modifier: Modifier in other.modifiers:
				found_other = found_other or modifier.kind == Modifier.Kind.FIRST_SPELL_COST_CHANGE
		assert_false(found_other, "not in node %d" % node)
	var badges: Array[RuleBadges.Badge] = RuleBadges.for_dungeon("necrocrat", 13)
	var shown: bool = false
	for badge: RuleBadges.Badge in badges:
		shown = shown or badge.name == "Processing Time"
	assert_true(shown, "shown in Rules of this fight for the Elevator Operator")
	# Spells only: a unit costs the same, a spell costs 1 more (first one each turn).
	var game: GameState = _game()
	var modifier: Modifier = CardBuilder.modifier(Modifier.Kind.FIRST_SPELL_COST_CHANGE, 1)
	game.players[0].modifiers.add_source(CardBuilder.modifier_source("Processing Time", ModifierSource.SourceKind.DUNGEON, [modifier] as Array[Modifier]))
	var spell: CardData = CardSet.card("B-03")
	var unit: CardData = CardSet.card("B-11")
	assert_eq(game.generic_cost_for(0, spell), spell.generic_cost + 1)
	assert_eq(game.generic_cost_for(0, unit), unit.generic_cost)
