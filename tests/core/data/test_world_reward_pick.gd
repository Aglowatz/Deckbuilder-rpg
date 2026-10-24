extends GutTest
## Overnight Oct 23, Part 4: after an elite or boss in the world (a gatekeeper, a town boss, a zone elite, the arena's upper tiers) the
## player gets a "choose a card" box; a repeat win offers a smaller one; ordinary fights offer none; the chosen card joins the collection.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.GOURMAND)
	Session.pending_popups.clear()


func after_each() -> void:
	Session.pending_popups.clear()
	Session.save_enabled = true


func _context(npc_id: String) -> BattleContext:
	var context: BattleContext = BattleContext.new()
	context.game = GameFactory.new_game(5, null, ZoneDecks.from_recipe(Session.content, "foe", EnemyDecks.recipe("beefcake_rush", 16)))
	context.enemy_name = "Brick Bronson"
	context.town_npc_id = npc_id
	context.won = true
	return context


func test_a_gatekeeper_win_queues_a_pick_of_three_and_a_repeat_two() -> void:
	var context: BattleContext = _context("beefcake")
	assert_eq(Session.world_pick_kind(context), "elite")
	Session.queue_world_pick(context)
	assert_eq(Session.pending_popups.size(), 1)
	var summary: RewardSummary = Session.pending_popups[0] as RewardSummary
	assert_eq(summary.card_choices.size(), RewardPicks.COUNT)
	assert_false(summary.is_empty())
	Session.queue_world_pick(context)
	assert_eq((Session.pending_popups[1] as RewardSummary).card_choices.size(), RewardPicks.REPEAT_COUNT, "a repeat win offers less")


func test_an_ordinary_fight_offers_no_pick() -> void:
	var context: BattleContext = _context("")
	assert_eq(Session.world_pick_kind(context), "")
	Session.queue_world_pick(context)
	assert_true(Session.pending_popups.is_empty())


func test_the_taken_card_joins_the_collection() -> void:
	var context: BattleContext = _context("beefcake")
	Session.queue_world_pick(context)
	var summary: RewardSummary = Session.pending_popups[0] as RewardSummary
	var card: CardData = summary.card_choices[0]
	var before: int = Session.profile.owned_copies(card.id)
	Session.take_reward_pick(card)
	var after: int = Session.profile.owned_copies(card.id)
	assert_true(after == before + 1 or after == Session.copy_cap(card), "a new copy, or (at the cap) it converted")
	Session.take_reward_pick(null)


func test_the_foe_deck_paths_come_from_its_cards() -> void:
	var context: BattleContext = _context("beefcake")
	var paths: Array[Affinity.Type] = RewardPicks.deck_paths(Session.foe_deck_of(context.game))
	assert_true(paths.has(Affinity.Type.BEEFCAKE))
