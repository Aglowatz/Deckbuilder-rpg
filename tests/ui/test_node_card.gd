extends GutTest
## Fable Nov 12c (Part B): the illustrated card every non-combat dungeon pop-up and the pre-fight rules panel are built on.


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.dungeon_map = TrialOfTheHollow.build_map()
	Session.run = DungeonRun.enter(Session.profile, Session.deck, [TrialOfTheHollow.deck_size_waiver()] as Array[ModifierSource])
	Settings.reduce_motion = false
	Settings.text_dialogue = 1


func after_each() -> void:
	Settings.text_dialogue = 1
	Settings.reduce_motion = false


func after_all() -> void:
	Session.new_game()


func _card(kind: NodeCard.Kind, title: String = "A Room") -> NodeCard:
	var card: NodeCard = NodeCard.make(kind, title)
	add_child_autofree(card)
	return card


func test_every_kind_has_its_label_icon_wash_and_particles() -> void:
	assert_eq(NodeCard.KIND_LABEL.size(), NodeCard.Kind.size())
	assert_eq(NodeCard.KIND_ICON.size(), NodeCard.Kind.size())
	assert_eq(NodeCard.KIND_WASH.size(), NodeCard.Kind.size())
	assert_eq(NodeCard.KIND_PARTICLES.size(), NodeCard.Kind.size())
	for id: String in NodeCard.KIND_ICON:
		assert_true(IconArt.has(id), "%s is an icon the game already has" % id)
	assert_eq(NodeCard.KIND_PARTICLES[NodeCard.Kind.SHRINE], "motes")
	assert_eq(NodeCard.KIND_PARTICLES[NodeCard.Kind.WELL], "mist")
	assert_eq(NodeCard.KIND_PARTICLES[NodeCard.Kind.TREASURE], "sparkles")


func test_the_card_is_a_banner_over_a_vellum_body_in_the_gold_frame() -> void:
	var card: NodeCard = _card(NodeCard.Kind.SHRINE, "Whispering Shrine")
	assert_not_null(card.frame, "the ornate frame")
	assert_not_null(card.banner)
	assert_eq(card.banner.custom_minimum_size.y, NodeCard.BANNER_HEIGHT)
	assert_not_null(card.find_child("BannerArt", true, false))
	assert_not_null(card.find_child("IconGlow", true, false), "a glow behind the icon")
	assert_not_null(card.icon.texture, "the large kind icon")
	assert_not_null(card.find_child("BannerParticles", true, false), "drifting particles")
	var body: PanelContainer = card.find_child("Body", true, false) as PanelContainer
	assert_eq((body.get_theme_stylebox("panel") as StyleBoxFlat).bg_color, NodeCard.VELLUM)
	assert_eq(card.title_label.text, "Whispering Shrine")
	assert_eq(card.kicker_label.text.replace(" ", ""), "SHRINE", "the kind in small caps over the name")
	var banner_index: int = card.banner.get_index()
	assert_lt(banner_index, body.get_index(), "the banner is above the body")


func test_the_banner_uses_the_dungeons_own_map_round_the_room() -> void:
	var card: NodeCard = _card(NodeCard.Kind.SHRINE)
	assert_false(card.has_banner_art() and not UiArt.has(NodeCard.BANNER_ART_ID), "no picture until one is set")
	var shrine: DungeonMap.MapNode = null
	for node: DungeonMap.MapNode in Session.dungeon_map.nodes:
		if node.kind == DungeonMap.Kind.SHRINE:
			shrine = node
	card.set_banner_for_node(shrine)
	assert_true(card.has_banner_art(), "the Forgotten Cave's painted map is the banner")
	var material: ShaderMaterial = (card.find_child("BannerArt", true, false) as ColorRect).material as ShaderMaterial
	var center: Vector2 = material.get_shader_parameter("center") as Vector2
	var span: Vector2 = material.get_shader_parameter("span") as Vector2
	if not UiArt.has(NodeCard.BANNER_ART_ID):
		assert_almost_eq(center.x, clampf(shrine.position.x, span.x * 0.5, 1.0 - span.x * 0.5), 0.001, "cropped round the room's spot on the map")
	assert_between(center.x - span.x * 0.5, 0.0, 1.0, "the crop stays inside the picture")
	assert_between(center.y + span.y * 0.5, 0.0, 1.0)
	assert_gt(float(material.get_shader_parameter("blur")) + (1.0 if UiArt.has(NodeCard.BANNER_ART_ID) else 0.0), 0.0, "blurred")


func test_the_hp_preview_shows_the_heal_as_before_and_after() -> void:
	var card: NodeCard = _card(NodeCard.Kind.SHRINE)
	var preview: NodeCard.HpPreview = card.hp_preview(9, 15, 15)
	assert_eq(preview.text(), "HP  9  →  15  (full)")
	assert_eq(card.hp_preview(9, 13, 15).text(), "HP  9  →  13")
	assert_eq(card.hp_preview(15, 15, 15).text(), "HP  15 / 15  ·  already full", "at full HP it says so plainly")
	assert_eq(card.hp_preview(9, 6, 15).text(), "HP  9  →  6", "a cost in HP")
	Settings.reduce_motion = true
	preview.apply()
	assert_eq(preview.current, 15)
	assert_eq(preview.label.text, "HP  15 / 15  ·  already full")


func test_text_helpers() -> void:
	assert_eq(NodeCard.spaced_caps("Well").replace(" ", ""), "WELL")
	assert_eq(NodeCard.no_orphan("A quiet light gathers in the stone."), "A quiet light gathers in the stone.", "the last two words stay together")
	assert_eq(NodeCard.no_orphan("Two words"), "Two words")
	var font: Font = UIStyle.font_body()
	var long: String = "A ring of old stone around a spring that ran dry long ago. Something down there still listens, and still trades."
	var one_line: float = font.get_string_size(long, HORIZONTAL_ALIGNMENT_LEFT, -1, 23).x
	var width: float = NodeCard.balanced_width(long, font, 23, 760.0)
	assert_lt(width, 760.0, "a two-line paragraph wraps narrower than the room")
	assert_gt(width, one_line * 0.5, "so both lines are about the same length (no orphan)")
	assert_almost_eq(NodeCard.balanced_width("Short.", font, 23, 760.0), font.get_string_size("Short.", HORIZONTAL_ALIGNMENT_LEFT, -1, 23).x + 8.0, 0.5)


func test_body_text_follows_the_text_size_setting() -> void:
	Settings.text_dialogue = 1
	assert_eq(NodeCard.text_px(23), 23)
	Settings.text_dialogue = 3
	assert_gt(NodeCard.text_px(23), 30, "Large text")


func test_buttons_are_pad_usable_and_escape_leaves() -> void:
	var card: NodeCard = _card(NodeCard.Kind.WELL)
	var give: FancyButton = card.button("Give a card", true, "ICON-NODE-CHALLENGE")
	var leave: FancyButton = card.button("Leave it", false)
	card.back_button = leave
	assert_eq(give.focus_mode, Control.FOCUS_ALL)
	assert_eq(leave.focus_mode, Control.FOCUS_ALL)
	assert_not_null(give.icon, "the primary button carries an icon")
	assert_true(card.is_in_group(PadFocus.GROUP), "the pad finds the card")
	var pressed: Array[int] = [0]
	leave.pressed.connect(func() -> void: pressed[0] += 1)
	card._age = 1.0
	var escape: InputEventAction = InputEventAction.new()
	escape.action = &"ui_cancel"
	escape.pressed = true
	card._unhandled_input(escape)
	assert_eq(pressed[0], 1, "Esc (and the pad's B) means Leave it")


func test_reduce_motion_stills_the_card() -> void:
	Settings.reduce_motion = true
	var card: NodeCard = _card(NodeCard.Kind.TREASURE)
	assert_null(card.find_child("BannerParticles", true, false), "no particles")
	assert_eq(card.frame.scale, Vector2.ONE)
	assert_eq(card.frame.modulate.a, 1.0)


func test_the_shrine_on_the_card() -> void:
	Session.run.lose_hp(6)
	var screen: ShrineScreen = ShrineScreen.new()
	var shrine_id: int = -1
	for node: DungeonMap.MapNode in Session.dungeon_map.nodes:
		if node.kind == DungeonMap.Kind.SHRINE:
			shrine_id = node.id
	screen.set_meta("node_id", shrine_id)
	add_child_autofree(screen)
	assert_eq(screen.card.kind, NodeCard.Kind.SHRINE)
	assert_eq(screen.card.title_label.text, Session.dungeon_map.node(shrine_id).title)
	assert_eq(ShrineScreen.effect_text(999, 15), "Heal to full HP")
	assert_eq(ShrineScreen.effect_text(4, 15), "Heal 4 HP")
	var rest: FancyButton = screen.find_child("ShrineRest", true, false) as FancyButton
	var leave: FancyButton = screen.find_child("ShrineLeave", true, false) as FancyButton
	assert_eq(rest.text, "Rest")
	assert_eq(leave.text, "Leave it")
	assert_eq(screen.card.back_button, leave, "Esc leaves the shrine")
	var hp: int = Session.run.hp
	rest.pressed.emit()
	assert_gt(Session.run.hp, hp, "Rest heals")
	assert_eq(rest.text, "Continue")
	assert_false(leave.visible)


func test_the_well_on_the_card() -> void:
	Session.run.lose_hp(6)
	var screen: ChallengeScreen = ChallengeScreen.new()
	screen.set_meta("node_id", 2)
	add_child_autofree(screen)
	assert_true(screen.is_offer())
	assert_eq(screen.card.kind, NodeCard.Kind.WELL)
	var give: FancyButton = screen.find_child("OfferAccept", true, false) as FancyButton
	var leave: FancyButton = screen.find_child("OfferLeave", true, false) as FancyButton
	assert_eq(give.text, "Give a card")
	assert_false(give.disabled)
	assert_eq(screen.card.back_button, leave)
	assert_eq(screen.confirm_target(), leave, "a confirm tap takes the safe choice")
	assert_not_null(screen.find_child("Chip", true, false), "the cost as a chip")
	var deck: int = Session.run.current_deck().size()
	var hp: int = Session.run.hp
	Settings.reduce_motion = true
	give.pressed.emit()
	assert_eq(Session.run.current_deck().size(), deck - 1)
	assert_eq(Session.run.hp, hp + 4)
	assert_not_null(screen.find_child("TakenCard", true, false), "the sacrificed card is shown face up")
	var words: Label = screen.find_child("OfferTaken", true, false) as Label
	assert_string_contains(words.text.replace(" ", " "), "It returns when you leave the cave.")
	assert_eq(give.text, "Continue")
	assert_false(leave.visible)


func test_the_well_at_full_hp() -> void:
	var screen: ChallengeScreen = ChallengeScreen.new()
	screen.set_meta("node_id", 2)
	add_child_autofree(screen)
	var give: FancyButton = screen.find_child("OfferAccept", true, false) as FancyButton
	assert_true(give.disabled)
	assert_eq(give.text, "You're at full HP")
	assert_not_null(screen.find_child("OfferBlocked", true, false), "and says why")


func test_the_pre_fight_panel_is_rows_of_icon_name_and_text() -> void:
	var badges: Array[RuleBadges.Badge] = []
	for index: int in range(3):
		var badge: RuleBadges.Badge = RuleBadges.Badge.new()
		badge.name = "Rule %d" % index
		badge.text = "It does thing %d." % index
		badge.kind = "encounter"
		badges.append(badge)
	var hidden: RuleBadges.Badge = RuleBadges.Badge.new()
	hidden.name = "Hidden trait ?"
	hidden.text = "Something happens in this fight you haven't seen yet."
	hidden.kind = "scripted"
	hidden.hidden = true
	badges.append(hidden)
	var holder: Control = Control.new()
	add_child_autofree(holder)
	var called: Array[int] = [0]
	var brief: RulesBrief = RulesBrief.open(holder, badges, "Before the fight: Cave Scavenger", func() -> void: called[0] += 1, false)
	assert_eq(brief.name, "RulesBrief")
	assert_eq(brief.card.kind, NodeCard.Kind.FIGHT)
	assert_eq(brief.card.title_label.text, "Cave Scavenger")
	assert_eq(brief.card.kicker_label.text.replace(" ", ""), "BEFORE THE FIGHT")
	assert_eq(brief.find_children("Rule_*", "HBoxContainer", true, false).size(), 4, "a row per rule")
	assert_eq(brief.find_children("RuleName", "Label", true, false).size(), 4)
	assert_eq(brief.find_children("RuleText", "Label", true, false).size(), 4)
	assert_not_null(brief.find_child("HiddenMark", true, false), "a hidden trait is a ? row with its explanation")
	assert_not_null(brief.find_child("ScriptedHeading", true, false))
	var go: FancyButton = brief.find_child("BriefContinue", true, false) as FancyButton
	assert_eq(go.text, "Continue")
	go.pressed.emit()
	assert_eq(called[0], 1)
	assert_eq(RulesBrief.split_title("Before the fight: Mortimer Grimsby"), ["Before the fight", "Mortimer Grimsby", "Mortimer Grimsby"] as Array[String])
	assert_eq(RulesBrief.split_title("Entering the Hall")[0], "Dungeon rules")


func test_many_rules_take_two_columns() -> void:
	var badges: Array[RuleBadges.Badge] = []
	for index: int in range(8):
		var badge: RuleBadges.Badge = RuleBadges.Badge.new()
		badge.name = "Rule %d" % index
		badge.text = "It does thing %d." % index
		badges.append(badge)
	var holder: Control = Control.new()
	add_child_autofree(holder)
	var brief: RulesBrief = RulesBrief.open(holder, badges, "Before the fight: Mortimer Grimsby, CE-No", Callable(), false)
	assert_eq((brief.find_child("RuleRows", true, false) as GridContainer).columns, 2)
	assert_lt(brief.card.banner_height, NodeCard.BANNER_HEIGHT, "and a lower banner, so the card fits the screen")


func test_treasure_and_event_rows() -> void:
	var rows: Array[Array] = TreasureScreen.loot_rows({"gold": 40, "xp": 20, "item": "Healing Salve"})
	assert_eq(rows.size(), 3)
	assert_eq(rows[0], ["ICON-GOLD", "+40 gold"])
	assert_eq(TreasureScreen.loot_rows({})[0][1], "The chest is empty. Someone got here first.")
	var result: EventResolver.Result = EventResolver.Result.new()
	result.hp_delta = -3
	result.gold_delta = 25
	var chips: Array[Array] = EventScreen.summary_chips(result)
	assert_eq(chips.size(), 2)
	assert_eq(chips[0][1], "-3 HP")
	assert_eq(chips[0][2], NodeCard.BAD_INK)
	assert_eq(chips[1][1], "+25 gold")
