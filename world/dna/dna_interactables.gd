class_name DnaInteractables
extends RefCounted
## The D.N.A.'s small interactable objects and what they do (all effects are real):
##  - Coffee machine (5 gold): random outcome - heal 2, heal 4, a bad cup (-1 HP), a coin back,
##    or an empty cup. Counts for the Onboarding quest.
##  - Time clock: "punch in" once per visit for +2 max HP (and +2 HP) until you leave.
##  - Haunted printer (40 gold): prints a random Necrocrat card from the vendor's list - or jams
##    (20%) and keeps your money.
##  - Suggestion box: the first suggestion pays 25 gold and a card; afterwards it is empty.

const COFFEE_COST: int = 5
const PRINTER_COST: int = 40
const PRINTER_JAM_CHANCE: float = 0.2
const PUNCH_IN_BONUS: int = 2
const SUGGESTION_GOLD: int = 25
const SUGGESTION_CARD: String = "N-02"
const SUGGESTION_SECRET: String = "dna_suggestion_box"


static func coffee(scene: DnaScene) -> void:
	scene.player.face(scene.builder.anchor("coffee"))
	if Session.gold < COFFEE_COST:
		scene.hud.toast("The machine wants %d gold. You are broke." % COFFEE_COST, UIStyle.MUTED)
		Audio.sfx(&"ui_error")
		return
	Session.spend_gold(COFFEE_COST)
	var roll: float = Session.rng.randf()
	var run: ZoneRun = Session.zone_run
	var story: ZoneStoryText = scene.story
	var outcome: String = coffee_outcome(roll)
	match outcome:
		"good":
			run.heal(2)
			scene.hud.toast(story.text("fx.coffee_good"), UIStyle.GOOD)
			Audio.sfx(&"heal")
		"great":
			run.heal(4)
			scene.hud.toast(story.text("fx.coffee_great"), UIStyle.GOOD)
			Audio.sfx(&"heal")
		"bad":
			run.hp = maxi(1, run.hp - 1)
			scene.hud.toast(story.text("fx.coffee_bad"), Color("ff8a85"))
			Audio.sfx(&"hit_light")
		"gold":
			Session.add_gold(COFFEE_COST * 3)
			scene.hud.toast(story.text("fx.coffee_gold"), UIStyle.GOLD)
			Audio.sfx(&"coins")
		_:
			scene.hud.toast("An empty cup. It is very hot. It is also empty.", UIStyle.MUTED)
	Session.bump_counter(DnaZone.COUNTER_COFFEE)
	scene.hud.set_gold(Session.gold)
	EventBus.zone_hp_changed.emit(run.hp, run.max_hp())


## Outcome for a roll in [0, 1): kept separate so tests can pin every branch.
static func coffee_outcome(roll: float) -> String:
	if roll < 0.3:
		return "good"
	if roll < 0.45:
		return "great"
	if roll < 0.65:
		return "bad"
	if roll < 0.8:
		return "gold"
	return "empty"


static func time_clock(scene: DnaScene) -> void:
	scene.player.face(scene.builder.anchor("time_clock"))
	var run: ZoneRun = Session.zone_run
	if run.punched_in:
		scene.hud.toast(scene.story.text("fx.punch_again"), UIStyle.MUTED)
		Audio.sfx(&"ui_error")
		return
	run.punched_in = true
	run.add_buff(punch_in_buff())
	Session.bump_counter(DnaZone.COUNTER_PUNCHED_IN)
	scene.hud.toast(scene.story.text("fx.punch_in"), UIStyle.GOOD)
	Audio.sfx(&"ui_confirm")
	EventBus.zone_hp_changed.emit(run.hp, run.max_hp())


static func punch_in_buff() -> ModifierSource:
	var source: ModifierSource = ModifierSource.new()
	source.source_name = "Punched in"
	source.source_kind = ModifierSource.SourceKind.ZONE
	var modifier: Modifier = Modifier.new()
	modifier.kind = Modifier.Kind.MAX_HP
	modifier.value = PUNCH_IN_BONUS
	modifier.label = "Punched in: +%d max HP this visit" % PUNCH_IN_BONUS
	source.modifiers = [modifier] as Array[Modifier]
	return source


static func printer(scene: DnaScene) -> void:
	scene.player.face(scene.builder.anchor("printer"))
	if Session.gold < PRINTER_COST:
		scene.hud.toast("The printer wants %d gold. It can smell you are short." % PRINTER_COST, UIStyle.MUTED)
		Audio.sfx(&"ui_error")
		return
	Session.spend_gold(PRINTER_COST)
	scene.hud.set_gold(Session.gold)
	var card: CardData = print_card(Session.rng.randf(), Session.rng.randi())
	if card == null:
		scene.hud.toast(scene.story.text("fx.printer_poor"), Color("ff8a85"))
		Audio.sfx(&"ui_error")
		return
	Session.add_cards([card] as Array[CardData])
	Session.record_seen(card.id)
	scene.hud.toast("%s  -> %s" % [scene.story.text("fx.printer_ok"), card.display_name], UIStyle.GOLD)
	Audio.sfx(&"card_draw")
	Session.save_game()


## The card a print produces for a jam roll in [0, 1) and a pick seed; null = paper jam.
static func print_card(jam_roll: float, pick: int) -> CardData:
	if jam_roll < PRINTER_JAM_CHANCE:
		return null
	var id: String = ZoneCards.VENDOR_IDS[absi(pick) % ZoneCards.VENDOR_IDS.size()]
	return Session.card_by_id(id)


static func suggestion_box(scene: DnaScene) -> void:
	scene.player.face(scene.builder.anchor("suggestion"))
	if Session.found_secret(SUGGESTION_SECRET):
		scene.hud.toast(scene.story.text("fx.suggestion_empty"), UIStyle.MUTED)
		return
	Session.discover_secret(SUGGESTION_SECRET)
	Session.add_gold(SUGGESTION_GOLD)
	var card: CardData = Session.card_by_id(SUGGESTION_CARD)
	if card != null:
		Session.add_cards([card] as Array[CardData])
	scene.hud.set_gold(Session.gold)
	scene.hud.toast("%s +%d gold, %s" % [scene.story.text("fx.suggestion"), SUGGESTION_GOLD, card.display_name if card != null else "a card"], UIStyle.GOLD)
	Audio.sfx(&"coins")
	Audio.sfx(&"card_draw")
	Session.save_game()
