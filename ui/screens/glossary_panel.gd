class_name GlossaryPanel
extends PanelContainer
## Overnight Oct 23, Part 5: the Glossary page of the pause menu - every keyword, resource, status, card type and rule icon in plain
## words, one tab each. The texts come from the same places the battle's tooltips use (KeywordInfo, ResourceKind.DESCRIPTIONS), plus
## the statuses and rule colours explained here.

signal closed

const TABS: Array[String] = ["Keywords", "Resources", "Statuses", "Card types", "Rule icons", "Zones", "Terms"]

const STATUSES: Array[Array] = [
	["Exhausted", "Spent for this turn: it attacked, used an ability or entered exhausted. It can't attack or block until it refreshes at the start of its controller's turn. Some effects make it skip one refresh."],
	["Summoning sickness", "A unit that just entered can't attack until your next turn, unless it has Hustle. It can still block."],
	["Red Tape (-2/-0)", "A Necrocrat Resource used on a unit: -2 attack until the start of its user's next turn, so it stays shrunk through the other side's turn. Hover the unit to see how long is left."],
	["Until end of turn", "A pump that fades when the turn ends, like Iron's +1/+1."],
	["Buff", "+1/+1 for good, for as long as the unit stays on the field. Several buffs stack."],
	["The fight's rules", "Some fights give one side's units extra stats (\"its units get +1/+1\"). Hover a unit to see what it gets from the rules."],
	["Token", "A unit or object made by an effect instead of drawn from a deck. It plays like a normal card; when it leaves the field it is gone for good."],
	["Equipped", "A Tool attached to a unit gives its bonus for as long as it stays attached."],
	["Shield", "Some bosses absorb the next few points of damage dealt to them. Hover their portrait to see it."],
	["Can't block", "The unit can't be declared as a blocker (for good, or this turn only)."],
]

const CARD_TYPES: Array[Array] = [
	["Infrastructure", "One per turn. Gives energy every turn; a basic Infrastructure also makes its Path's Resource when it enters."],
	["Unit", "Stays on the field. Attacks, blocks, and is destroyed when its damage reaches its defense."],
	["Spell", "Resolves once, then goes to the Refuse Pile."],
	["Trap", "Set face-down on your turn. It springs by itself on your opponent's turn when its condition is met. You see the enemy's traps only as card backs."],
	["Tool", "Stays on the table. Its ability attaches it to one of your units, which then gets its bonus."],
	["Wonder", "A permanent with an ongoing effect. It stays until something destroys it."],
	["Resource", "A token in its own tray (Iron, Red Tape, Contract, Ingredient, Garbage). It waits until a card or its own ability spends it."],
]

const RULE_ICONS: Array[Array] = [
	["Red icons", "A rule that helps the enemy or binds you: \"its units get +1/+1\", \"you take 1 damage each turn\". It applies to the enemy only unless it says otherwise."],
	["Green icons", "A rule on your side: a boon from a dungeon, an ally's help."],
	["Gold icons", "A rule for both sides: the zone's buff and debuff, a dungeon's rules (Overgrowth, Rot...)."],
	["Amber icons", "A boss's or elite's scripted events: what CAN happen during the fight (\"at half health...\", \"on its 5th turn...\"). Each happens once. A timed one is announced the turn before. Once it has happened the icon dims."],
	["Where they are", "Under the enemy's portrait in battle, on the dungeon map's node info and in the brief before a fight. Hover an icon for its text; click one for the full list."],
	["What is never shown", "The enemy's next move. Rules and scripted events are announced; what the AI plans is not."],
]

var _tab_bar: HBoxContainer
var _list: VBoxContainer
var _current: int = 0


static func make() -> GlossaryPanel:
	var panel: GlossaryPanel = GlossaryPanel.new()
	panel.name = "GlossaryPanel"
	panel.theme_type_variation = &"DarkPanel"
	panel.custom_minimum_size = Vector2(980, 760)
	panel._build()
	return panel


func _build() -> void:
	var column: VBoxContainer = UIKit.vbox(10)
	add_child(column)
	var head: HBoxContainer = UIKit.hbox(10)
	column.add_child(head)
	head.add_child(UIKit.label("Glossary", &"HeadingLabel", 36))
	head.add_child(UIKit.filler())
	var back: FancyButton = FancyButton.make("Back", &"GhostButton", Vector2(140, 44))
	back.name = "GlossaryBack"
	back.pressed.connect(func() -> void: closed.emit())
	head.add_child(back)
	_tab_bar = UIKit.hbox(8)
	column.add_child(_tab_bar)
	for index: int in range(TABS.size()):
		var tab: FancyButton = FancyButton.make(TABS[index], &"GhostButton", Vector2(0, 40))
		tab.name = "Tab_%s" % TABS[index].replace(" ", "_")
		tab.add_theme_font_size_override("font_size", 19)
		var which: int = index
		tab.pressed.connect(func() -> void: show_tab(which))
		_tab_bar.add_child(tab)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(940, 620)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	_list = UIKit.vbox(10)
	_list.custom_minimum_size = Vector2(910, 0)
	scroll.add_child(_list)
	show_tab(0)


func show_tab(index: int) -> void:
	_current = clampi(index, 0, TABS.size() - 1)
	for i: int in range(_tab_bar.get_child_count()):
		var tab: FancyButton = _tab_bar.get_child(i) as FancyButton
		tab.modulate = Color(1, 1, 1, 1) if i == _current else Color(1, 1, 1, 0.6)
	for child: Node in _list.get_children():
		child.queue_free()
	for entry: Array in entries(_current):
		_list.add_child(_row(str(entry[0]), str(entry[1]), str(entry[2]) if entry.size() > 2 else ""))


func current_tab() -> int:
	return _current


## The [title, text, icon id] rows of one tab.
static func entries(index: int) -> Array[Array]:
	var result: Array[Array] = []
	match TABS[clampi(index, 0, TABS.size() - 1)]:
		"Keywords":
			for keyword: Variant in KeywordInfo.KEYWORD_TEXT.keys():
				var pair: Array = KeywordInfo.KEYWORD_TEXT[keyword] as Array
				result.append([str(pair[0]), str(pair[1]), IconArt.keyword_id(keyword as CardEnums.Keyword)])
		"Resources":
			for kind: Variant in ResourceKind.DESCRIPTIONS.keys():
				result.append([ResourceKind.display_name(kind as ResourceKind.Kind), str(ResourceKind.DESCRIPTIONS[kind]), ""])
		"Statuses":
			for entry: Array in STATUSES:
				result.append([entry[0], entry[1], ""])
		"Card types":
			for entry: Array in CARD_TYPES:
				result.append([entry[0], entry[1], ""])
		"Rule icons":
			for entry: Array in RULE_ICONS:
				result.append([entry[0], entry[1], ""])
		"Zones":  # Fixes Oct 25, Part 8: rival Paths and each zone's buff and debuff, with the real numbers (PathDirection)
			for entry: Array in PathDirection.glossary_entries():
				result.append([entry[0], entry[1], ""])
		"Terms":
			for term: Variant in KeywordInfo.GLOSSARY.keys():
				result.append([str(term), str(KeywordInfo.GLOSSARY[term]), ""])
	return result


func _row(title: String, text: String, icon_id: String) -> HBoxContainer:
	var row: HBoxContainer = UIKit.hbox(12)
	if not icon_id.is_empty() and IconArt.has(icon_id):
		row.add_child(IconArt.rect(icon_id, 34.0))
	var box: VBoxContainer = UIKit.vbox(2)
	var head: Label = UIKit.label(title, &"", 22, UIStyle.GOLD)
	head.add_theme_font_override("font", UIStyle.font_bold())
	box.add_child(head)
	var body: Label = UIKit.label(text, &"", 18, UIStyle.PARCHMENT)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(840, 0)
	box.add_child(body)
	row.add_child(box)
	return row
