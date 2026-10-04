class_name ArenaScreen
extends OverlayScreen
## The Grand Clashatorium's UI (Part G): every encounter in three tiers with its kind (battle / puzzle), its rules, its
## first-clear prize and whether it has been cleared, and a Fight button. After a fight the town reopens this screen with a
## banner saying what happened (and what was won). Text: story file `arena.*`; data: `ArenaDefs`.

signal fight_chosen(encounter_id: String)

## Set by the town after a fight: the `Session.pending_arena_result` to announce at the top.
var result: Dictionary = {}
var _rows: Dictionary = {}


func _ready() -> void:
	screen_title = StoryText.shared().text("town.arena.name")
	super._ready()


func _build() -> void:
	var story: StoryText = StoryText.shared()
	var cleared: int = Session.arena_cleared_count()
	header_extra.add_child(UIKit.label("%d of %d cleared" % [cleared, ArenaDefs.all().size()], &"", 28, UIStyle.GOLD))
	if not result.is_empty():
		body.add_child(_result_banner(story))
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var list: VBoxContainer = UIKit.vbox(10)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	for tier: int in range(1, 4):
		var head: HBoxContainer = UIKit.hbox(14)
		list.add_child(head)
		var tier_label: Label = UIKit.label(story.text("arena.tier.%d" % tier), &"HeadingLabel", 32)
		tier_label.name = "Tier%d" % tier
		head.add_child(tier_label)
		var tier_blurb: Label = UIKit.label(story.text("arena.tier.%d.blurb" % tier), &"MutedLabel", 20)
		tier_blurb.size_flags_vertical = Control.SIZE_SHRINK_END
		head.add_child(tier_blurb)
		for encounter: ArenaEncounter in ArenaDefs.in_tier(tier):
			list.add_child(_row(encounter, story))


func _result_banner(story: StoryText) -> Control:
	var panel: PanelContainer = UIKit.panel()
	panel.name = "ArenaResultBanner"
	var column: VBoxContainer = UIKit.vbox(4)
	panel.add_child(column)
	var encounter: ArenaEncounter = ArenaDefs.find(str(result.get("id", "")))
	var won: bool = bool(result.get("won", false))
	var headline: String
	if won:
		headline = story.text("arena.puzzle.won") if encounter != null and encounter.is_puzzle() else story.text("arena.won.first" if bool(result.get("first_clear", false)) else "arena.won.replay")
	else:
		headline = story.text("arena.puzzle.lost") if encounter != null and encounter.is_puzzle() else story.text("arena.lost")
	var head: Label = UIKit.label(headline, &"HeadingLabel", 26, UIStyle.GOOD if won else Color("e8625a"))
	head.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	head.custom_minimum_size = Vector2(1500, 0)
	column.add_child(head)
	if bool(result.get("first_clear", false)):
		var prize: Label = UIKit.label("Prize: %s" % reward_text(result.get("reward", {}) as Dictionary), &"", 24, UIStyle.GOLD)
		prize.name = "ArenaPrizeLine"
		column.add_child(prize)
	elif won and int(result.get("replay_gold", 0)) > 0:
		column.add_child(UIKit.label("+%d gold" % int(result["replay_gold"]), &"", 22, UIStyle.GOLD))
	return panel


func _row(encounter: ArenaEncounter, story: StoryText) -> Control:
	var cleared: bool = Session.is_arena_cleared(encounter.id)
	var panel: PanelContainer = UIKit.panel(&"DarkPanel")
	panel.name = "ArenaRow_%s" % encounter.id
	panel.custom_minimum_size = Vector2(1620, 0)
	var line: HBoxContainer = UIKit.hbox(18)
	panel.add_child(line)
	var icon_key: String = "lorc/crystal-ball" if encounter.is_puzzle() else "lorc/crossed-swords"
	line.add_child(CardIcons.glyph(CardIcons.named(icon_key) if encounter.is_puzzle() else CardIcons.ui("attack"), UIStyle.GOLD if not cleared else UIStyle.GOOD, Vector2(64, 64)))
	var info: VBoxContainer = UIKit.vbox(3)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.add_child(info)
	var title_row: HBoxContainer = UIKit.hbox(12)
	info.add_child(title_row)
	title_row.add_child(UIKit.label(story.text(encounter.title_key()), &"HeadingLabel", 28))
	var kind_tag: Label = UIKit.label(story.text("arena.screen.puzzle" if encounter.is_puzzle() else "arena.screen.battle"), &"", 18, Color("9cc8ff") if encounter.is_puzzle() else Color("ffb08a"))
	title_row.add_child(kind_tag)
	var status: Label = UIKit.label(story.text("arena.screen.cleared" if cleared else "arena.screen.new"), &"", 18, UIStyle.GOOD if cleared else UIStyle.GOLD)
	status.name = "Status"
	title_row.add_child(status)
	var blurb: Label = UIKit.label(story.text(encounter.blurb_key()), &"", 20, UIStyle.PARCHMENT)
	blurb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	blurb.custom_minimum_size = Vector2(1040, 0)
	info.add_child(blurb)
	var rules: Label = UIKit.label(story.text(encounter.rules_key()), &"MutedLabel", 19)
	rules.name = "Rules"
	rules.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rules.custom_minimum_size = Vector2(1040, 0)
	info.add_child(rules)
	var prize_box: VBoxContainer = UIKit.vbox(2)
	prize_box.custom_minimum_size = Vector2(330, 0)
	line.add_child(prize_box)
	prize_box.add_child(UIKit.label(story.text("arena.screen.first_prize"), &"MutedLabel", 17))
	var prize: Label = UIKit.label(reward_text(ArenaScenario.resolve_reward(encounter, Session.profile.primary_affinity)), &"", 21, UIStyle.GOLD)
	prize.name = "PrizeText"
	prize.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	prize.custom_minimum_size = Vector2(320, 0)
	var piece: EquipmentData = Session.content.equipment_piece(str(encounter.reward.get("equipment", "")))
	if piece != null:
		prize.tooltip_text = piece.tooltip_text()
		prize.mouse_filter = Control.MOUSE_FILTER_STOP
	prize_box.add_child(prize)
	var button: FancyButton = FancyButton.make(story.text("arena.screen.replay" if cleared else "arena.screen.fight"), &"" if cleared else &"PrimaryButton", Vector2(220, 60))
	button.name = "Fight_%s" % encounter.id
	button.pressed.connect(func() -> void: fight_chosen.emit(encounter.id))
	line.add_child(button)
	_rows[encounter.id] = panel
	return panel


## "90 gold, 40 XP, 5 Beefcake essence" / "Champion's Laurels (Helm)" - the prize of a (resolved) reward.
static func reward_text(reward: Dictionary) -> String:
	var parts: PackedStringArray = []
	if reward.has("equipment"):
		var piece: EquipmentData = Session.content.equipment_piece(str(reward["equipment"]))
		if piece != null:
			parts.append("%s (%s)" % [piece.source_name, EquipmentData.slot_name(piece.slot)])
	if reward.has("item"):
		var item: ItemData = Session.content.item(str(reward["item"]))
		if item != null:
			parts.append(item.display_name)
	if reward.has("card"):
		var card: CardData = Session.card_by_id(str(reward["card"]))
		if card != null:
			parts.append(card.display_name)
	if reward.has("gold"):
		parts.append("%d gold" % int(reward["gold"]))
	if reward.has("xp"):
		parts.append("%d XP" % int(reward["xp"]))
	if reward.has("essence"):
		var essence: Dictionary = reward["essence"] as Dictionary
		var by_amount: Dictionary = {}
		for path: Variant in essence.keys():
			by_amount[int(essence[path])] = by_amount.get(int(essence[path]), []) as Array
			(by_amount[int(essence[path])] as Array).append(Affinity.display_name(int(path) as Affinity.Type))
		for amount: Variant in by_amount.keys():
			parts.append("%d %s essence" % [int(amount), "/".join(PackedStringArray(by_amount[amount] as Array))])
	return ", ".join(parts)
