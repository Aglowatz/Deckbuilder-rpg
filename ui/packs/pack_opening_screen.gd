class_name PackOpeningScreen
extends Control
## The pack-opening experience: the pack floats in the middle of the screen; click to tear it open; the cards fall face-down in a
## row and are revealed one at a time with a flip. Rarity decides the flair (a puff, a green glint, a purple flash with rays, and a
## big golden moment for a Legendary: screen flash, god rays, banner, fanfare, shake). First-time cards get a NEW badge; extra copies
## beyond four show what they converted into. A summary closes it. The pack has already been taken from the inventory and rolled
## (`Session.open_pack`): this screen only presents the `PackOpening`.

## `again` is true when the player asked to open another pack of the same kind.
signal finished(again: bool)

enum Phase { PACK, TEARING, DEALING, REVEAL, SUMMARY }

const CARD_SCALE: float = 0.88
const GAP: float = 40.0
const ROW_Y: float = 500.0
const RARITY_FLAIR: Array[Color] = [Color("e8e4da"), Color("5fd6a4"), Color("b48cf2"), Color("ffb24a")]

var opening: PackOpening
## How many more packs of this kind are in the inventory (offers "Open another").
var packs_left: int = 0

var _phase: Phase = Phase.PACK
var _stage: Control
var _hint: Label
var _title: Label
var _pack_art: PackArt
var _glow: ColorRect
var _holders: Array[Control] = []
var _views: Array[CardView] = []
var _flipped: Array[bool] = []
var _next: int = 0
var _busy: bool = false
var _skip_all: bool = false
var _shake: float = 0.0
var _shake_origin: Vector2 = Vector2.ZERO
var _banner: Label
var _summary: Control
var _pack_bob: Tween
var _legendary_rays: PackFx.Rays


func _ready() -> void:
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_STOP
	var shade: ColorRect = ColorRect.new()
	shade.color = Color(0.03, 0.02, 0.06, 0.97)
	UIKit.full_rect(shade)
	add_child(shade)
	_glow = UIKit.gradient_background()
	_glow.modulate.a = 0.5
	add_child(_glow)
	_stage = Control.new()
	UIKit.full_rect(_stage)
	_stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_stage)
	_title = UIKit.label(opening.pack.display_name, &"TitleLabel", 54, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	_title.position = Vector2(0, 54)
	_title.size = Vector2(1920, 70)
	add_child(_title)
	_hint = UIKit.label("", &"", 30, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	_hint.add_theme_font_override("font", UIStyle.font_italic())
	_hint.position = Vector2(0, 960)
	_hint.size = Vector2(1920, 44)
	add_child(_hint)
	var skip: FancyButton = FancyButton.make("Skip (Esc)", &"GhostButton", Vector2(170, 48))
	skip.position = Vector2(1700, 50)
	skip.pressed.connect(_skip)
	add_child(skip)
	_show_pack()


func _process(delta: float) -> void:
	if _shake > 0.01:
		_shake = maxf(0.0, _shake - delta * 28.0)
		_stage.position = _shake_origin + Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake
	elif _stage != null and _stage.position != _shake_origin:
		_stage.position = _shake_origin


# ---- The pack ------------------------------------------------------------------------------------------


func _show_pack() -> void:
	_phase = Phase.PACK
	_pack_art = PackArt.create(opening.pack)
	_pack_art.scale = Vector2.ONE * 1.4
	_pack_art.position = Vector2(960, 520) - PackArt.SIZE * 0.5
	_pack_art.modulate.a = 0.0
	_stage.add_child(_pack_art)
	var appear: Tween = create_tween().set_parallel(true)
	appear.tween_property(_pack_art, "modulate:a", 1.0, 0.45)
	appear.tween_property(_pack_art, "scale", Vector2.ONE * 1.5, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	appear.chain().tween_callback(_start_bob)
	_hint.text = "Click the pack to tear it open"
	Audio.sfx(&"card_shuffle", -6.0)


func _start_bob() -> void:
	if _phase != Phase.PACK:
		return
	_pack_bob = create_tween().set_loops()
	var base_y: float = _pack_art.position.y
	_pack_bob.tween_property(_pack_art, "position:y", base_y - 10.0, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_pack_bob.tween_property(_pack_art, "position:y", base_y + 4.0, 1.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _tear() -> void:
	if _phase != Phase.PACK:
		return
	_phase = Phase.TEARING
	if _pack_bob != null and _pack_bob.is_valid():
		_pack_bob.kill()
	_hint.text = ""
	Audio.sfx(&"pack_tear", 0.0, 0.08)
	var rattle: Tween = create_tween()
	for step: int in range(6):
		rattle.tween_property(_pack_art, "rotation", (0.04 if step % 2 == 0 else -0.04), 0.04)
	rattle.tween_property(_pack_art, "rotation", 0.0, 0.04)
	await rattle.finished
	_pack_art.tear()
	Audio.sfx(&"pack_whoosh", -4.0, 0.05)
	_shake = 8.0
	var colour: Color = opening.pack.art_color.lightened(0.3)
	PackFx.flash(self, colour, 0.55, 0.5)
	PackFx.burst(self, Vector2(960, 330), colour, 40, 520.0, 0.9, true)
	PackFx.ring(self, Vector2(960, 420), colour, 520.0, 0.6)
	await _pack_art.torn
	_deal()


func _deal() -> void:
	_phase = Phase.DEALING
	var count: int = opening.entries.size()
	var width: float = CardView.SIZE.x * CARD_SCALE
	var total: float = width * float(count) + GAP * float(count - 1)
	var left: float = (1920.0 - total) * 0.5
	var origin: Vector2 = Vector2(960.0 - width * 0.5, 440.0)
	for index: int in range(count):
		var entry: PackOpening.Entry = opening.entries[index]
		var holder: Control = Control.new()
		holder.custom_minimum_size = CardView.SIZE * CARD_SCALE
		holder.size = CardView.SIZE * CARD_SCALE
		holder.pivot_offset = holder.size * 0.5
		holder.position = origin
		holder.modulate.a = 0.0
		holder.scale = Vector2(0.4, 0.4)
		holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var view: CardView = CardView.create(entry.card, CardView.Mode.BACK)
		view.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(view)
		CardView.fit(view, CARD_SCALE)
		_stage.add_child(holder)
		_holders.append(holder)
		_views.append(view)
		_flipped.append(false)
		var target: Vector2 = Vector2(left + float(index) * (width + GAP), ROW_Y - holder.size.y * 0.5)
		var fly: Tween = create_tween().set_parallel(true)
		fly.tween_property(holder, "position", target, 0.5).set_delay(0.12 * float(index)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		fly.tween_property(holder, "modulate:a", 1.0, 0.2).set_delay(0.12 * float(index))
		fly.tween_property(holder, "scale", Vector2.ONE, 0.5).set_delay(0.12 * float(index)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		get_tree().create_timer(0.12 * float(index)).timeout.connect(func() -> void: Audio.sfx(&"pack_flip", -4.0, 0.12))
	_pack_art.fade_out(0.35)
	await get_tree().create_timer(0.12 * float(count) + 0.55).timeout
	_phase = Phase.REVEAL
	_hint.text = "Click to reveal a card"
	if _skip_all:
		_reveal_rest()


# ---- Reveals --------------------------------------------------------------------------------------------


func _reveal_next() -> void:
	if _phase != Phase.REVEAL or _busy or _next >= _holders.size():
		return
	_busy = true
	var index: int = _next
	_next += 1
	await _flip(index)
	_busy = false
	if _next >= _holders.size():
		_hint.text = "Click to see the summary"
	else:
		_hint.text = "Click to reveal the next card"


func _reveal_rest() -> void:
	_skip_all = true
	while _phase == Phase.REVEAL and _next < _holders.size():
		if not _busy:
			var index: int = _next
			_next += 1
			_busy = true
			await _flip(index, true)
			_busy = false
		else:
			await get_tree().process_frame
	if _phase == Phase.REVEAL:
		_show_summary()


func _flip(index: int, quick: bool = false) -> void:
	var holder: Control = _holders[index]
	var view: CardView = _views[index]
	var entry: PackOpening.Entry = opening.entries[index]
	var rarity: int = int(entry.card.rarity)
	var colour: Color = RARITY_FLAIR[rarity]
	holder.z_index = 5
	Audio.sfx(&"pack_flip", -2.0, 0.1)
	if rarity >= 3 and not quick:
		# The Legendary moment: the room dims and the card hangs, glowing, before it turns.
		_hint.text = ""
		_legendary_buildup(holder)
		await get_tree().create_timer(0.9).timeout
	var squash: Tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	squash.tween_property(holder, "scale:x", 0.0, 0.1 if quick else 0.16)
	await squash.finished
	view.set_mode(CardView.Mode.FULL)
	var open: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	var lift: float = 1.0 + 0.04 * float(rarity)
	open.tween_property(holder, "scale", Vector2.ONE * lift, 0.12 if quick else 0.26)
	await open.finished
	_flipped[index] = true
	_flair(index, holder, colour, quick)
	_add_card_labels(index, holder, entry, colour)
	await get_tree().create_timer(0.1 if quick else (1.5 if rarity >= 3 else 0.45)).timeout
	if rarity < 3:
		holder.z_index = 1


func _centre_of(holder: Control) -> Vector2:
	return holder.position + holder.size * 0.5


func _flair(index: int, holder: Control, colour: Color, quick: bool) -> void:
	var rarity: int = int(opening.entries[index].card.rarity)
	var centre: Vector2 = _centre_of(holder)
	match rarity:
		0:
			PackFx.burst(self, centre, colour, 10, 220.0, 0.6)
		1:
			Audio.sfx(&"pack_chime_uncommon", -6.0)
			PackFx.burst(self, centre, colour, 26, 360.0, 0.9, true)
			PackFx.ring(self, centre, colour, 260.0, 0.6)
		2:
			Audio.sfx(&"pack_chime_epic", -4.0)
			Audio.sfx(&"hit_metal", -8.0)
			_shake = 7.0
			PackFx.flash(self, colour, 0.3, 0.45)
			PackFx.burst(self, centre, colour, 46, 520.0, 1.1, true)
			PackFx.ring(self, centre, colour, 380.0, 0.7)
			PackFx.ring(self, centre, colour.lightened(0.4), 280.0, 0.5)
			_rays_behind(holder, colour, 0.35, 1.4)
		3:
			Audio.sfx(&"pack_fanfare_legendary", -2.0)
			Audio.sfx(&"hit_heavy", -2.0)
			Audio.sfx(&"turn_start", -4.0)
			_shake = 18.0
			PackFx.flash(self, Color(1.0, 0.92, 0.65), 0.85, 1.0)
			PackFx.burst(self, centre, colour, 90, 760.0, 1.6, true)
			PackFx.burst(self, centre, Color(1, 1, 1), 40, 520.0, 1.2)
			PackFx.ring(self, centre, colour, 620.0, 0.9)
			PackFx.ring(self, centre, Color(1, 1, 1), 440.0, 0.7)
			_show_banner("LEGENDARY!", colour)
			_legendary_afterglow(holder, colour)
	if quick and rarity < 3:
		return


func _rays_behind(holder: Control, colour: Color, alpha: float, lifetime: float) -> PackFx.Rays:
	var rays: PackFx.Rays = PackFx.Rays.new()
	rays.color = Color(colour.r, colour.g, colour.b, alpha)
	rays.position = _centre_of(holder)
	rays.z_index = 0
	rays.length = 1100.0
	_stage.add_child(rays)
	_stage.move_child(rays, 0)
	var fade: Tween = create_tween()
	fade.tween_interval(lifetime)
	fade.tween_property(rays, "modulate:a", 0.0, 0.8)
	fade.tween_callback(rays.queue_free)
	return rays


func _legendary_buildup(holder: Control) -> void:
	_shake_origin = Vector2.ZERO
	_shake = 3.0
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0, 0, 0, 0.0)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UIKit.full_rect(dim)
	dim.z_index = 2
	add_child(dim)
	var tween: Tween = create_tween()
	tween.tween_property(dim, "color:a", 0.55, 0.5)
	tween.tween_interval(1.7)
	tween.tween_property(dim, "color:a", 0.0, 0.8)
	tween.tween_callback(dim.queue_free)
	var pulse: Tween = create_tween().set_loops(3)
	pulse.tween_property(holder, "scale", Vector2.ONE * 1.06, 0.15)
	pulse.tween_property(holder, "scale", Vector2.ONE, 0.15)
	var gold: Color = RARITY_FLAIR[3]
	PackFx.ring(self, _centre_of(holder), gold, 300.0, 0.8)
	Audio.sfx(&"pack_whoosh", -2.0, 0.02)


func _legendary_afterglow(holder: Control, colour: Color) -> void:
	_legendary_rays = _rays_behind(holder, colour, 0.55, 3.2)
	PackFx.sparkle_stream(_stage, holder.position + Vector2(holder.size.x * 0.5, holder.size.y), holder.size.x, colour, 30)
	var settle: Tween = create_tween()
	settle.tween_property(holder, "scale", Vector2.ONE * 1.12, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _show_banner(text: String, colour: Color) -> void:
	if _banner != null:
		_banner.queue_free()
	_banner = UIKit.label(text, &"TitleLabel", 110, colour, HORIZONTAL_ALIGNMENT_CENTER)
	_banner.add_theme_color_override("font_outline_color", Color(0.25, 0.1, 0.0, 1.0))
	_banner.add_theme_constant_override("outline_size", 18)
	_banner.position = Vector2(0, 130)
	_banner.size = Vector2(1920, 140)
	_banner.pivot_offset = Vector2(960, 70)
	_banner.scale = Vector2(2.4, 2.4)
	_banner.modulate.a = 0.0
	_banner.z_index = 95
	add_child(_banner)
	var banner: Label = _banner
	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(banner, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(banner, "modulate:a", 1.0, 0.2)
	tween.chain().tween_interval(1.8)
	tween.chain().tween_property(banner, "modulate:a", 0.0, 0.6)
	tween.chain().tween_callback(banner.queue_free)


func _add_card_labels(index: int, holder: Control, entry: PackOpening.Entry, colour: Color) -> void:
	var rarity_name: Label = UIKit.label(CardView.RARITY_NAMES[int(entry.card.rarity)].to_upper(), &"", 24, colour, HORIZONTAL_ALIGNMENT_CENTER)
	rarity_name.add_theme_font_override("font", UIStyle.font_title())
	rarity_name.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	rarity_name.add_theme_constant_override("outline_size", 6)
	rarity_name.position = Vector2(0, holder.size.y + 10.0)
	rarity_name.size = Vector2(holder.size.x, 32)
	holder.add_child(rarity_name)
	if entry.is_new:
		var badge: Label = UIKit.label("NEW!", &"", 34, Color("2b1a00"), HORIZONTAL_ALIGNMENT_CENTER)
		badge.add_theme_font_override("font", UIStyle.font_title())
		badge.add_theme_stylebox_override("normal", UIStyle.box(Color("ffd24a"), Color("fff3b0"), 3, 14, 6))
		badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge.size = Vector2(96, 48)
		badge.position = Vector2(-18, -14)
		badge.pivot_offset = badge.size * 0.5
		badge.rotation = -0.18
		badge.scale = Vector2(2.2, 2.2)
		badge.z_index = 8
		holder.add_child(badge)
		var pop: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		pop.tween_property(badge, "scale", Vector2.ONE, 0.3)
		Audio.sfx(&"coins", -12.0, 0.1)
	if entry.converted:
		var convert: Label = UIKit.label(_conversion_text(entry), &"", 22, Color("ffd9a0"), HORIZONTAL_ALIGNMENT_CENTER)
		convert.add_theme_font_override("font", UIStyle.font_bold())
		convert.add_theme_stylebox_override("normal", UIStyle.box(Color(0.12, 0.08, 0.2, 0.95), Color("8a6d3b"), 2, 10, 0))
		convert.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		convert.position = Vector2(-10, holder.size.y + 46.0)
		convert.size = Vector2(holder.size.x + 20.0, 58)
		convert.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		holder.add_child(convert)


## "Extra copy: +2 Beefcake essence" / "Extra copy: +30 gold".
func _conversion_text(entry: PackOpening.Entry) -> String:
	var parts: PackedStringArray = []
	for path: Variant in entry.essence.keys():
		parts.append("+%d %s essence" % [int(entry.essence[path]), Affinity.display_name(int(path) as Affinity.Type)])
	if entry.gold > 0:
		parts.append("+%d gold" % entry.gold)
	return "Extra copy (you own 4):\n%s" % ", ".join(parts)


# ---- Summary --------------------------------------------------------------------------------------------


func _show_summary() -> void:
	if _phase == Phase.SUMMARY:
		return
	_phase = Phase.SUMMARY
	_hint.text = ""
	_title.text = "%s - opened" % opening.pack.display_name
	var count: int = _holders.size()
	var small: float = 0.66
	var width: float = CardView.SIZE.x * CARD_SCALE * small
	var gap: float = 26.0
	var total: float = width * float(count) + gap * float(count - 1)
	var left: float = (1920.0 - total) * 0.5
	for index: int in range(count):
		var holder: Control = _holders[index]
		var tween: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		tween.tween_property(holder, "scale", Vector2.ONE * small, 0.45)
		var target: Vector2 = Vector2(left + float(index) * (width + gap) - (holder.size.x * (1.0 - small)) * 0.5, 130.0 - (holder.size.y * (1.0 - small)) * 0.5)
		tween.tween_property(holder, "position", target, 0.45)
		for child: Node in holder.get_children():
			if child is Label and child != null:
				var label: Label = child as Label
				if label.text.begins_with("Extra copy"):
					label.visible = false
	_build_summary_panel()


func _build_summary_panel() -> void:
	_summary = Control.new()
	_summary.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_summary.modulate.a = 0.0
	add_child(_summary)
	var panel: PanelContainer = UIKit.panel()
	panel.position = Vector2(460, 520)
	panel.size = Vector2(1000, 440)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_summary.add_child(panel)
	var box: VBoxContainer = UIKit.vbox(8)
	panel.add_child(UIKit.margin(box, 22))
	var headline: Label = UIKit.label("%d new card%s" % [opening.new_count(), "" if opening.new_count() == 1 else "s"], &"TitleLabel", 38, UIStyle.GOLD, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(headline)
	var names: PackedStringArray = []
	for entry: PackOpening.Entry in opening.entries:
		var suffix: String = "  (NEW)" if entry.is_new else ("  (extra copy)" if entry.converted else "")
		names.append("%s - %s%s" % [entry.card.display_name, CardView.RARITY_NAMES[int(entry.card.rarity)], suffix])
	var list: Label = UIKit.label("\n".join(names), &"", 24, UIStyle.PARCHMENT, HORIZONTAL_ALIGNMENT_CENTER)
	box.add_child(list)
	box.add_child(HSeparator.new())
	var converted: int = opening.converted_count()
	if converted > 0:
		var gains: PackedStringArray = []
		var essence: Dictionary = opening.essence_totals()
		for path: Variant in essence.keys():
			gains.append("%d %s essence" % [int(essence[path]), Affinity.display_name(int(path) as Affinity.Type)])
		if opening.gold_total() > 0:
			gains.append("%d gold" % opening.gold_total())
		var text: String = "%d extra cop%s converted (you already own 4):\n%s" % [converted, "y" if converted == 1 else "ies", ", ".join(gains)]
		var conversion: Label = UIKit.label(text, &"", 26, Color("ffd9a0"), HORIZONTAL_ALIGNMENT_CENTER)
		conversion.add_theme_font_override("font", UIStyle.font_bold())
		box.add_child(conversion)
	else:
		box.add_child(UIKit.label("No extra copies: every card joined your collection.", &"", 24, UIStyle.MUTED, HORIZONTAL_ALIGNMENT_CENTER))
	box.add_child(UIKit.filler())
	var buttons: HBoxContainer = UIKit.hbox(18)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_child(buttons)
	if packs_left > 0:
		var again: FancyButton = FancyButton.make("Open another (%d left)" % packs_left, &"PrimaryButton", Vector2(300, 56))
		again.pressed.connect(func() -> void: finished.emit(true))
		buttons.add_child(again)
	var done: FancyButton = FancyButton.make("Done", &"PrimaryButton" if packs_left <= 0 else &"", Vector2(200, 56))
	done.pressed.connect(func() -> void: finished.emit(false))
	buttons.add_child(done)
	var fade: Tween = create_tween()
	fade.tween_property(_summary, "modulate:a", 1.0, 0.4)


# ---- Input ----------------------------------------------------------------------------------------------


func _gui_input(event: InputEvent) -> void:
	var click: InputEventMouseButton = event as InputEventMouseButton
	if click != null and click.pressed and click.button_index == MOUSE_BUTTON_LEFT:
		accept_event()
		_advance()


func _unhandled_key_input(event: InputEvent) -> void:
	var key: InputEventKey = event as InputEventKey
	if key == null or not key.pressed or key.echo:
		return
	if key.keycode == KEY_SPACE or key.keycode == KEY_ENTER or key.keycode == KEY_KP_ENTER:
		get_viewport().set_input_as_handled()
		_advance()
	elif key.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		_skip()


func _advance() -> void:
	match _phase:
		Phase.PACK:
			_tear()
		Phase.REVEAL:
			if _next >= _holders.size():
				_show_summary()
			else:
				_reveal_next()
		_:
			pass


## Skip (Esc): tear the pack, reveal what is left quickly, show the summary. From the summary it just closes.
func _skip() -> void:
	match _phase:
		Phase.SUMMARY:
			finished.emit(false)
		Phase.REVEAL:
			_reveal_rest()
		_:
			_skip_all = true
			if _phase == Phase.PACK:
				_tear()


## Takes one pack of `pack_id` out of the inventory, rolls it and shows the opening on top of `host`. "Open another" chains straight
## into the next pack of the same kind. `on_closed` runs when the player is done. False if there was no such pack.
static func open_from_inventory(host: Node, pack_id: String, on_closed: Callable = Callable()) -> bool:
	var result: PackOpening = Session.open_pack(pack_id)
	if result == null:
		return false
	var screen: PackOpeningScreen = PackOpeningScreen.new()
	screen.opening = result
	screen.packs_left = Session.pack_count(pack_id)
	screen.z_index = 200
	host.add_child(screen)
	screen.finished.connect(func(again: bool) -> void:
		screen.queue_free()
		if again and PackOpeningScreen.open_from_inventory(host, pack_id, on_closed):
			return
		if on_closed.is_valid():
			on_closed.call())
	return true
