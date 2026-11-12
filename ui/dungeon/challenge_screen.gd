class_name ChallengeScreen
extends Control
## A deck challenge: reveal cards from your deck, see whether you passed and what it cost or gave - or an offer to take or leave (the
## Hollow Well: a random card for the rest of the dungeon, for healing). All resolution is done by core (ChallengeResolver).
## Fable Nov 12c (Part B): built on `NodeCard` - the room's corner of the dungeon map as the banner, the rule as icon rows, the HP outcome
## as a ghost segment with "HP 9 → 13", the cost as a chip, a primary and a secondary button, the well swallowing the card.

signal finished

var challenge: ChallengeData
var card: NodeCard
var _cards_row: HBoxContainer
var _reveal_button: FancyButton
var _leave_button: FancyButton
var _resolved: bool = false
var _preview: NodeCard.HpPreview


func _ready() -> void:
	PadFocus.register(self)  # controller support (Oct 26): the pad focuses this screen's buttons
	UIKit.full_rect(self)
	challenge = _pick_challenge()
	var node: DungeonMap.MapNode = Session.dungeon_map.node(int(get_meta("node_id", 0))) if Session.dungeon_map != null else null
	card = NodeCard.make(NodeCard.Kind.WELL if is_offer() else NodeCard.Kind.CHALLENGE, challenge.display_name, 940.0)
	add_child(card)
	card.set_banner_for_node(node)
	if is_offer():
		_build_offer()
	else:
		_build_test()
	Audio.sfx(&"ui_open")
	_leave_button.call_deferred(&"grab_focus")


## Fresh eyes round 2 (Oct 31): E / Enter / Space / the pad's A answer the well (the HUD under it says "E: interact"). Overnight Nov 4-5,
## Part 8 (fresh critic #2): before the test they press the safe "Leave it" - a player tapping through text no longer gambles a card away
## (Reveal takes a click, or the pad's focus) - and after it Continue. A short guard keeps the press that opened the well from answering it.
const GUARD_TIME: float = 0.4
var _age: float = 0.0


func _process(delta: float) -> void:
	_age += delta


func _unhandled_input(event: InputEvent) -> void:
	if _age < GUARD_TIME or not is_visible_in_tree() or _reveal_button == null:
		return
	# Fable Nov 12c (A1): an offer that is closed (full HP, the smallest deck) still answers the confirm key with "Leave it" (Esc is the
	# card's: `NodeCard.back_button`).
	var leave_open: bool = _leave_button != null and _leave_button.visible
	if _reveal_button.disabled and not (is_offer() and leave_open):
		return
	if UiInput.is_confirm(event):
		get_viewport().set_input_as_handled()
		confirm_target().pressed.emit()


## True when every reward of a passed test is a heal.
static func only_heals(test: ChallengeData) -> bool:
	if test == null or test.on_success.is_empty():
		return false
	for outcome: ChallengeOutcome in test.on_success:
		if outcome.kind != ChallengeOutcome.Kind.HEAL:
			return false
	return true


## The button a confirm press answers: "Leave it" while the test is still on offer, then Reveal's Continue.
func confirm_target() -> FancyButton:
	return _leave_button if _leave_button != null and _leave_button.visible else _reveal_button


func _pick_challenge() -> ChallengeData:
	if Session.main_dungeon_active or Session.mini_active:
		var node: DungeonMap.MapNode = Session.dungeon_map.node(int(get_meta("node_id", 0)))
		var themed: ChallengeData = MainDungeons.def(Session.dungeon_key).challenge(node.challenge_id)
		if themed != null:
			return themed
	for candidate: ChallengeData in Session.content.challenges:
		if candidate.id == TrialOfTheHollow.CHALLENGE_ID:
			return candidate
	return Session.content.challenges[0]


func _leave() -> void:
	Audio.sfx(&"ui_back")
	finished.emit()


# ---- A deck test: reveal cards, pass or fail ----------------------------------------------------------------------------------


## "The test: draw 5 cards from your deck - 2+ must be Unit cards. Your deck: about 64 % to pass."
func test_text() -> String:
	var rule: String = ChallengeResolver.rule_text(challenge)
	if rule.is_empty() or Session.run == null:
		return rule
	return "%s  Your deck: about %d %% to pass." % [rule, roundi(ChallengeResolver.odds(challenge, Session.run.current_deck().cards) * 100.0)]


func _stakes_text() -> String:
	var win: PackedStringArray = []
	for outcome: ChallengeOutcome in challenge.on_success:
		win.append(outcome.description)
	var lose: PackedStringArray = []
	for outcome: ChallengeOutcome in challenge.on_failure:
		lose.append(outcome.description)
	return "Pass: %s      Fail: %s" % [", ".join(win), ", ".join(lose)]


static func _joined(outcomes: Array[ChallengeOutcome]) -> String:
	var parts: PackedStringArray = []
	for outcome: ChallengeOutcome in outcomes:
		parts.append(outcome.description.trim_suffix("."))
	return ", ".join(parts) if not parts.is_empty() else "nothing"


func _build_test() -> void:
	card.flavour(challenge.description)
	# Overnight Oct 31 - Nov 1 (mid-game critic #9): the test in numbers and your deck's chance, before you reveal.
	var test: Label = card.line(test_text(), NodeCard.GOLD_INK, 22, true)
	test.name = "TestRule"
	card.effect([["ICON-CHECK", "Pass: %s" % _joined(challenge.on_success)], ["ICON-NODE-CHALLENGE", "Fail: %s" % _joined(challenge.on_failure)]])
	_cards_row = UIKit.hbox(14)
	_cards_row.name = "Revealed"
	_cards_row.alignment = BoxContainer.ALIGNMENT_CENTER
	card.content.add_child(_cards_row)
	_reveal_button = card.button("Reveal", true, "ICON-NODE-CHALLENGE", 260.0)
	_reveal_button.name = "Reveal"
	_reveal_button.pressed.connect(_on_reveal)
	# Fix pass Nov 7 (Part 5, C1 F6): a test that can only heal is not offered at full HP (all risk, no reward).
	if Session.run != null and Session.run.hp >= Session.run.max_hp() and only_heals(challenge):
		_reveal_button.disabled = true
		_reveal_button.text = "You're at full HP"
		_reveal_button.tooltip_text = "Passing would only heal you. Come back hurt, or leave it."
	# Fable pass Nov 1 (Part 7): a deck test can be declined - the node is passed with nothing won or lost.
	_leave_button = card.button("Leave it (no test)", false, "", 260.0)
	_leave_button.name = "Leave"
	_leave_button.pressed.connect(_leave)
	card.back_button = _leave_button


func _on_reveal() -> void:
	if _leave_button != null:
		_leave_button.visible = false
		card.back_button = null
	if _resolved:
		Audio.sfx(&"ui_close")
		finished.emit()
		return
	_resolved = true
	_reveal_button.disabled = true
	# Cards Oct 27, Part 3: a won card goes to the collection (the Deck Station builds it in); only the tutorial cave adds it to the run's deck.
	var result: ChallengeResult = ChallengeResolver.resolve(challenge, Session.run, Session.rng, null, Session.rewards_go_to_deck())
	if not result.gained_cards.is_empty():
		Session.add_cards(result.gained_cards)
		Session.save_game()
	_cards_row.custom_minimum_size = Vector2(0, 250)
	for shown: CardData in result.revealed:
		var holder: Control = CardView.wrapped(shown, 0.5)
		_cards_row.add_child(holder)
		holder.modulate.a = 0.0
		Audio.sfx(&"card_draw")
		create_tween().tween_property(holder, "modulate:a", 1.0, 0.25)
		await get_tree().create_timer(0.3).timeout
	await get_tree().create_timer(0.3).timeout
	_show_outcome(result)


## The well's own words only at the well (the tutorial cave); every other deck test says plainly how it went.
func headline_text(passed: bool) -> String:
	if challenge != null and challenge.id == TrialOfTheHollow.CHALLENGE_ID:
		return "The well answers." if passed else "The well stays silent."
	return "Passed!" if passed else "Not this time."


func _show_outcome(result: ChallengeResult) -> void:
	var passed: bool = result.success
	Audio.sfx(&"victory" if passed else &"defeat", -6.0)
	card.line(headline_text(passed), NodeCard.GOOD_INK if passed else NodeCard.BAD_INK, 32, true)
	var lines: PackedStringArray = []
	# Fresh eyes Oct 30: the rule in numbers first ("3 of the 5 were Infrastructure; 3 were needed."), and why a passed well at full
	# HP changes nothing - the critic pressed Reveal and could not tell whether it had passed.
	var why: String = ChallengeResolver.explain(challenge, result) if challenge != null else ""
	if not why.is_empty():
		lines.append(why)
	if passed and result.hp_healed == 0 and challenge != null and ChallengeResolver.heals_on_success(challenge):
		lines.append("You were already at full HP, so there was nothing to mend.")
	if result.hp_healed > 0:
		lines.append("You recover %d HP." % result.hp_healed)
	if result.hp_lost > 0:
		lines.append("You lose %d HP." % result.hp_lost)
	for lost: CardData in result.lost_cards:
		lines.append("%s is lost for this dungeon." % lost.display_name)
	for gained: CardData in result.gained_cards:
		lines.append(("%s joins your deck." if Session.rewards_go_to_deck() else "%s: added to your collection.") % gained.display_name)
	if not result.gained_cards.is_empty() and Session.take_collection_tip():
		lines.append("Cards you win go to your collection. Build them into a deck at the Deck Station.")
	for boon: ModifierSource in result.boons:
		lines.append("%s: %s. %s" % [BoonText.kind_word(boon), boon.source_name, BoonText.describe(boon)])  # Fixes Oct 27: what it does, not just its name
	if lines.is_empty():
		lines.append("Nothing changes.")
	for text: String in lines:
		card.line(text, NodeCard.INK, 22)
	if result.hp_healed > 0 or result.hp_lost > 0:
		var after: int = Session.run.hp
		var before: int = after - result.hp_healed + result.hp_lost
		var bar: NodeCard.HpPreview = card.hp_preview(before, after, Session.run.max_hp())
		bar.apply()
		if result.hp_healed > 0:
			card.heal_shimmer()
	_reveal_button.text = "Continue"
	_reveal_button.icon = null
	_reveal_button.disabled = false
	_reveal_button.call_deferred(&"grab_focus")


# ---- Fable Nov 12c (A1): the Hollow Well's offer ------------------------------------------------------------------------------


## True for an offer the player takes or leaves (`ChallengeData.Kind.RANDOM_SACRIFICE`): nothing is drawn or tested.
func is_offer() -> bool:
	return challenge != null and challenge.kind == ChallengeData.Kind.RANDOM_SACRIFICE


func _offer_heal() -> int:
	var heal: int = 0
	for outcome: ChallengeOutcome in challenge.on_success:
		if outcome.kind == ChallengeOutcome.Kind.HEAL:
			heal += outcome.amount
	return heal


## "Sacrifice a random card from your deck for the rest of this dungeon: heal 4 HP."
func offer_rule_text() -> String:
	return "Sacrifice a random card from your deck for the rest of this dungeon: heal %d HP." % _offer_heal()


## "The well takes Card Name. It returns when you leave the cave."
func taken_text(taken: CardData) -> String:
	var place: String = "the cave" if challenge.id == TrialOfTheHollow.CHALLENGE_ID else "this dungeon"
	return "The well takes %s. It returns when you leave %s." % [taken.display_name, place]


var _offer_block: ChallengeResolver.Block = ChallengeResolver.Block.NONE


func _build_offer() -> void:
	card.flavour(challenge.description)
	var rule: HFlowContainer = card.effect([["ICON-STAT-HP", "Heal %d HP" % _offer_heal()], ["ICON-UI-DECK", "lose a random card for this dungeon"]])
	rule.name = "OfferRule"
	rule.tooltip_text = offer_rule_text()
	var hp: int = Session.run.hp
	var max_hp: int = Session.run.max_hp()
	_preview = card.hp_preview(hp, mini(max_hp, hp + _offer_heal()), max_hp)
	_cards_row = UIKit.hbox(14)
	_cards_row.name = "Taken"
	_cards_row.alignment = BoxContainer.ALIGNMENT_CENTER
	card.content.add_child(_cards_row)
	_offer_block = ChallengeResolver.offer_block(challenge, Session.run)
	_reveal_button = card.button("Give a card", true, "ICON-NODE-CHALLENGE", 280.0)
	_reveal_button.name = "OfferAccept"
	_reveal_button.pressed.connect(_on_offer_accept)
	if _offer_block != ChallengeResolver.Block.NONE:
		_reveal_button.disabled = true
		_reveal_button.text = ChallengeResolver.block_button_text(_offer_block)
		_reveal_button.icon = null
		var why: Label = card.line(ChallengeResolver.block_reason(_offer_block, Session.run), NodeCard.INK_SOFT, 21)
		why.name = "OfferBlocked"
	else:
		card.chip("ICON-UI-DECK", "Cost: 1 random card, back when you leave", NodeCard.BAD_INK)
	_leave_button = card.button("Leave it", false, "", 240.0)
	_leave_button.name = "OfferLeave"
	_leave_button.pressed.connect(_leave)
	card.back_button = _leave_button


func _on_offer_accept() -> void:
	if _resolved:
		Audio.sfx(&"ui_close")
		finished.emit()
		return
	var choice: ChallengeChoice = ChallengeChoice.new()
	choice.accept = true
	var result: ChallengeResult = ChallengeResolver.resolve(challenge, Session.run, Session.rng, choice, false)
	if result.declined or result.lost_cards.is_empty():
		return
	_resolved = true
	_leave_button.visible = false
	card.back_button = null
	for chip: Node in card.find_children("Chip", "PanelContainer", true, false):
		chip.visible = false
	# the lines of the offer have done their job: the result takes their place (and the card still fits a 720p screen)
	for done: String in ["OfferBlocked", "Flavour", "OfferRule"]:
		var old: Node = card.content.get_node_or_null(done)
		if old != null:
			card.content.remove_child(old)
			old.queue_free()
	var taken: CardData = result.lost_cards[0]
	# the well swallows the card: it shows face up, then sinks a little and dims, and the water gives the HP back
	var holder: Control = CardView.wrapped(taken, 0.5)
	holder.name = "TakenCard"
	_cards_row.add_child(holder)
	Audio.sfx(&"splash")
	if not NodeCard.still():
		holder.modulate.a = 0.0
		var sink: Tween = create_tween()
		sink.tween_property(holder, "modulate:a", 1.0, 0.25)
		sink.tween_interval(0.55)
		sink.tween_property(holder, "modulate", Color(0.86, 0.91, 1.0, 0.94), 0.5)
	var words: Label = card.line(taken_text(taken), NodeCard.INK, 25, true)
	words.name = "OfferTaken"
	var healed: Label = card.line("You recover %d HP." % result.hp_healed, NodeCard.GOOD_INK, 22)
	healed.name = "OfferHealed"
	# the lines sit under the card; the HP bar plays the heal
	card.content.move_child(_cards_row, card.content.get_child_count() - 3)
	Audio.sfx(&"heal")
	_preview.after = Session.run.hp
	_preview.apply()
	card.heal_shimmer()
	_reveal_button.text = "Continue"
	_reveal_button.icon = null
	_reveal_button.call_deferred(&"grab_focus")
