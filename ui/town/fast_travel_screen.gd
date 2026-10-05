class_name FastTravelScreen
extends OverlayScreen
## The Beefcake Rift Express menu (brief 10b): every station with its blurb. Unlocked ones have a "Rip me there!" button, the one
## you stand at is marked, the rest are ??? until their town has been reached. Text: `travel.*` in the shared story file.

signal destination_chosen(station_id: String)

## The station the player is standing at (`FastTravel.TOWN` or a zone id).
var here: String = FastTravel.TOWN


func _ready() -> void:
	screen_title = StoryText.shared().text("travel.title")
	close_text = StoryText.shared().text("travel.close")
	super._ready()


func _build() -> void:
	var story: StoryText = StoryText.shared()
	var subtitle: Label = UIKit.label(story.text("travel.subtitle"), &"MutedLabel", 24)
	body.add_child(subtitle)
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(scroll)
	var list: VBoxContainer = UIKit.vbox(10)
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(list)
	for station_id: String in FastTravel.station_ids():
		list.add_child(_row(station_id, story))
	var warning: Label = UIKit.label(story.text("travel.warning"), &"MutedLabel", 19)
	warning.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	warning.custom_minimum_size = Vector2(1500, 0)
	body.add_child(warning)


func _row(station_id: String, story: StoryText) -> Control:
	var unlocked: bool = FastTravel.is_unlocked(Session.flags, station_id)
	var is_here: bool = station_id == here
	var panel: PanelContainer = UIKit.panel(&"DarkPanel")
	panel.name = "Station_%s" % station_id
	panel.custom_minimum_size = Vector2(1620, 0)
	var line: HBoxContainer = UIKit.hbox(18)
	panel.add_child(line)
	line.add_child(CardIcons.glyph(CardIcons.named("lorc/magic-portal") if unlocked else CardIcons.named("lorc/padlock"), UIStyle.GOLD if unlocked else UIStyle.MUTED, Vector2(64, 64)))
	var info: VBoxContainer = UIKit.vbox(3)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	line.add_child(info)
	var title: String = story.text("travel.station.%s.name" % station_id) if unlocked else story.text("travel.locked.name")
	var title_row: HBoxContainer = UIKit.hbox(12)
	info.add_child(title_row)
	title_row.add_child(UIKit.label(title, &"HeadingLabel", 28))
	if is_here:
		title_row.add_child(UIKit.label(story.text("travel.here"), &"", 18, UIStyle.GOOD))
	var blurb: Label = UIKit.label(story.text("travel.station.%s.blurb" % station_id) if unlocked else story.text("travel.locked.blurb"), &"", 20, UIStyle.PARCHMENT)
	blurb.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	blurb.custom_minimum_size = Vector2(1120, 0)
	info.add_child(blurb)
	if unlocked and not is_here:
		var button: FancyButton = FancyButton.make(story.text("travel.button"), &"PrimaryButton", Vector2(240, 60))
		button.name = "Rip_%s" % station_id
		button.pressed.connect(func() -> void: destination_chosen.emit(station_id))
		line.add_child(button)
	return panel
