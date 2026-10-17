class_name BattleBoard
extends Control
## The card table: creates a CardView per card, lays them out per zone (hands, fields,
## infrastructure rows, trap slots) and animates the rules engine's event log. It never decides anything
## about the rules; it only shows what GameState already did.

signal card_hovered(view: CardView)
signal card_unhovered(view: CardView)
signal card_input(view: CardView, event: InputEvent)

enum Zone { HAND, FIELD, INFRASTRUCTURE, TRAPS, CENTER, RESOURCES, TOKENS }

const CENTER_X: float = 985.0
const ENEMY_HAND_Y: float = 6.0
const ENEMY_INFRASTRUCTURE_Y: float = 152.0
const ENEMY_BF_Y: float = 366.0
const PLAYER_BF_Y: float = 620.0
const PLAYER_INFRASTRUCTURE_Y: float = 806.0
const HAND_Y: float = 985.0
const CENTER_POINT: Vector2 = Vector2(985.0, 500.0)
const BF_SPACING: float = 182.0
const INFRASTRUCTURE_SPACING: float = 86.0
const SCALE_HAND: float = 0.68
const SCALE_ENEMY_HAND: float = 0.3
const SCALE_BF: float = 0.56
const SCALE_INFRASTRUCTURE: float = 0.27
const SCALE_TRAP: float = 0.32
const SCALE_RESOURCE: float = 0.17
## UI art kit: with UI-HUD-RESOURCES the coins are a little smaller so they sit in the tray sockets.
const SCALE_RESOURCE_ART: float = 0.15
## The resource tray lies on its side: top-left x, size, and the socket centres along its length (fractions measured on the image, first kind first).
const ART_TRAY_X: float = 1610.0
const ART_TRAY_SIZE: Vector2 = Vector2(280, 79)
const ART_TRAY_SOCKETS: Array[float] = [0.232, 0.409, 0.586, 0.763]
## Token tray (UI-HUD-TOKENS) centres for you and the enemy; Contract tiles line up inside it.
const ART_TOKEN_TRAY_SIZE: Vector2 = Vector2(100, 97)
const ART_TOKEN_CENTERS: Array[Vector2] = [Vector2(1688, 756), Vector2(1688, 80)]
const SCALE_TOKEN_ART: float = 0.12
## Where the first set trap sits (the next ones 62 px further left): clear of the deck piles in the corner.
const TRAP_X: float = 1430.0
const ART_TRAP_SLOT: Vector2 = Vector2(62, 58)
const SCALE_TOKEN: float = 0.15
## Where each side's resource tray sits (centre of the first coin): the right-hand column, above the turn panel for the enemy and below it for you.
const RESOURCE_ORIGIN: Array[Vector2] = [Vector2(1671, 668), Vector2(1671, 166)]
const RESOURCE_SLOT_PITCH: float = 62.0
const TOKEN_SPAN: float = 56.0
## The separate token area (Contracts): a row below your tray, above the enemy's (always on the far side from the middle).
const TOKEN_ORIGIN: Array[Vector2] = [Vector2(1664, 746), Vector2(1664, 106)]
const SCALE_CENTER: float = 0.85

var game: GameState
var fx: BattleFX
var human: int = 0
var speed: float = 1.0

var views: Dictionary = {}
var zones: Dictionary = {}
var card_data: Dictionary = {}
var order: Array[int] = []
var attacking: Dictionary = {}
var blockers: Dictionary = {}
var hover_uid: int = 0
var drag_uid: int = 0
var drag_center: Vector2 = Vector2.ZERO
var deck_anchor: Array[Vector2] = [Vector2(1720, 858), Vector2(1765, 84)]
var grave_anchor: Array[Vector2] = [Vector2(1830, 858), Vector2(1830, 84)]
var portrait_anchor: Array[Vector2] = [Vector2(180, 960), Vector2(180, 100)]
var _targets: Dictionary = {}
var _center_uid: int = 0
var _last_damage_seq: int = -10
var _hover_zone_lift: bool = true


func setup(game_state: GameState, effects: BattleFX) -> void:
	game = game_state
	fx = effects
	human = 0
	UIKit.full_rect(self)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	register_all()


# ---- Card registry ----------------------------------------------------------------------


func register_all() -> void:
	for player: PlayerState in game.players:
		for zone_cards: Array[CardInstance] in [player.deck, player.hand, player.field, player.infrastructure, player.refuse_pile, player.traps, player.resources, player.tokens]:
			for card: CardInstance in zone_cards:
				card_data[card.uid] = card.data


func register_uid(uid: int) -> void:
	if uid <= 0 or card_data.has(uid):
		return
	var card: CardInstance = game.find_card(uid)
	if card != null:
		card_data[uid] = card.data


func _slot(uid: int) -> int:
	return (game.find_card(uid).owner if game.find_card(uid) != null else _owner_of_view(uid))


func _owner_of_view(uid: int) -> int:
	var view: CardView = views.get(uid) as CardView
	return int(view.get_meta("owner", 0)) if view != null else 0


func owner_of(uid: int) -> int:
	if views.has(uid):
		return _owner_of_view(uid)
	var card: CardInstance = game.find_card(uid)
	return card.owner if card != null else 0


func view_for(uid: int) -> CardView:
	return views.get(uid) as CardView


# ---- View creation ----------------------------------------------------------------------


func ensure_view(uid: int, zone: Zone, owner_index: int, from: Vector2 = Vector2(-1, -1), start_scale: float = 0.0) -> CardView:
	if views.has(uid):
		return views[uid] as CardView
	register_uid(uid)
	var data: CardData = card_data.get(uid) as CardData
	if data == null:
		return null
	var hidden: bool = _is_hidden(owner_index, zone)
	var view: CardView = CardView.create(data, CardView.Mode.BACK if hidden else _mode_for(zone))
	view.instance_uid = uid
	view.set_meta("owner", owner_index)
	view.set_meta("opponent_back", owner_index != human)
	view.set_meta("hidden", hidden)
	view.hovered.connect(func(v: CardView) -> void: _on_hover(v))
	view.unhovered.connect(func(v: CardView) -> void: _on_unhover(v))
	view.gui_event.connect(func(v: CardView, e: InputEvent) -> void: card_input.emit(v, e))
	add_child(view)
	views[uid] = view
	zones[uid] = zone
	order.append(uid)
	var origin: Vector2 = from if from.x >= 0.0 else deck_anchor[owner_index]
	view.scale = Vector2.ONE * (start_scale if start_scale > 0.0 else 0.2)
	view.position = origin - CardView.SIZE * 0.5
	view.modulate.a = 0.0
	return view


## New brief, Part B: X-Ray Goggles (Modifier.Kind.REVEAL_OPPONENT_HAND) reveals the opponent's
## hand to the human - but never a set trap, whatever equipment either side has. TRAPS always
## stays hidden here regardless of any modifier; only HAND is ever affected.
func _is_hidden(owner_index: int, zone: Zone) -> bool:
	if owner_index == human:
		return false
	if zone == Zone.TRAPS:
		return true
	if zone == Zone.HAND:
		return not game.players[human].modifiers.has(Modifier.Kind.REVEAL_OPPONENT_HAND)
	return false


func _mode_for(zone: Zone) -> CardView.Mode:
	match zone:
		Zone.FIELD:
			return CardView.Mode.COMPACT
		Zone.RESOURCES, Zone.TOKENS:
			return CardView.Mode.COIN
		_:
			return CardView.Mode.FULL


func _on_hover(view: CardView) -> void:
	var uid: int = view.instance_uid
	if zones.get(uid, -1) == Zone.HAND and int(view.get_meta("owner", 0)) == human:
		hover_uid = uid
		layout()
	card_hovered.emit(view)


func _on_unhover(view: CardView) -> void:
	if hover_uid == view.instance_uid:
		hover_uid = 0
		layout()
	card_unhovered.emit(view)


func set_zone(uid: int, zone: Zone) -> void:
	var view: CardView = view_for(uid)
	if view == null:
		return
	zones[uid] = zone
	order.erase(uid)
	order.append(uid)
	var hidden: bool = _is_hidden(int(view.get_meta("owner", 0)), zone)
	view.set_meta("hidden", hidden)
	view.set_mode(CardView.Mode.BACK if hidden else _mode_for(zone))
	_refresh_view(uid)


func _refresh_view(uid: int) -> void:
	var view: CardView = view_for(uid)
	var card: CardInstance = game.find_card(uid)
	if view != null and card != null and not bool(view.get_meta("hidden", false)):
		view.apply_instance(card, game)


func refresh_all() -> void:
	for uid: int in views.keys():
		_refresh_view(uid)


# ---- Layout -----------------------------------------------------------------------------


func _cards_in(owner_index: int, zone: Zone) -> Array[int]:
	var result: Array[int] = []
	for uid: int in order:
		if views.has(uid) and zones.get(uid) == zone and int(view_for(uid).get_meta("owner", 0)) == owner_index:
			result.append(uid)
	return result


func layout(animated: bool = true) -> void:
	_targets.clear()
	for owner_index: int in range(2):
		_layout_hand(owner_index)
		_layout_row(owner_index, Zone.FIELD, PLAYER_BF_Y if owner_index == human else ENEMY_BF_Y, SCALE_BF, BF_SPACING, CENTER_X, 1250.0)
		_layout_row(owner_index, Zone.INFRASTRUCTURE, PLAYER_INFRASTRUCTURE_Y if owner_index == human else ENEMY_INFRASTRUCTURE_Y, SCALE_INFRASTRUCTURE, INFRASTRUCTURE_SPACING, CENTER_X - 130.0, 950.0)
		_layout_traps(owner_index)
		_layout_resources(owner_index)
		_layout_tokens(owner_index)
	_place_blockers()
	var center: Array[int] = []
	for uid: int in order:
		if views.has(uid) and zones.get(uid) == Zone.CENTER:
			center.append(uid)
	for index: int in range(center.size()):
		_targets[center[index]] = {"pos": CENTER_POINT + Vector2(float(index) * 60.0, 0.0), "rot": 0.0, "scale": SCALE_CENTER, "z": 120 + index}
	if drag_uid != 0 and views.has(drag_uid):
		_targets[drag_uid] = {"pos": drag_center, "rot": 0.0, "scale": 0.78, "z": 200, "instant": true}
	for uid: int in _targets.keys():
		_apply_target(uid, _targets[uid] as Dictionary, animated)


func _layout_hand(owner_index: int) -> void:
	var cards: Array[int] = _cards_in(owner_index, Zone.HAND)
	var count: int = cards.size()
	if count == 0:
		return
	var mine: bool = owner_index == human
	var spacing: float = minf(200.0 if mine else 62.0, (900.0 if mine else 520.0) / float(maxi(count - 1, 1)))
	for index: int in range(count):
		var offset: float = float(index) - float(count - 1) * 0.5
		var arc: float = offset * offset * (2.2 if mine else 1.0)
		var uid: int = cards[index]
		var center: Vector2 = Vector2(CENTER_X + offset * spacing, (HAND_Y if mine else ENEMY_HAND_Y) + arc)
		var rotation_degrees: float = offset * (2.6 if mine else -1.8)
		var card_scale: float = SCALE_HAND if mine else SCALE_ENEMY_HAND
		var z: int = 10 + index
		if uid == hover_uid and mine and _hover_zone_lift:
			center = Vector2(center.x, HAND_Y - 150.0)
			rotation_degrees = 0.0
			card_scale = 0.86
			z = 100
		_targets[uid] = {"pos": center, "rot": rotation_degrees, "scale": card_scale, "z": z}


func _layout_row(owner_index: int, zone: Zone, y: float, card_scale: float, spacing: float, center_x: float, max_width: float) -> void:
	var cards: Array[int] = _cards_in(owner_index, zone)
	var count: int = cards.size()
	if count == 0:
		return
	var step: float = minf(spacing, max_width / float(count))
	for index: int in range(count):
		var uid: int = cards[index]
		var offset: float = float(index) - float(count - 1) * 0.5
		var pos: Vector2 = Vector2(center_x + offset * step, y)
		var rot: float = 0.0
		var card: CardInstance = game.find_card(uid)
		if zone == Zone.FIELD:
			var dir: float = -1.0 if owner_index == human else 1.0
			if attacking.has(uid):
				pos.y += dir * 70.0
		if card != null and card.exhausted and zone != Zone.FIELD:
			rot = 14.0
		elif card != null and card.exhausted:
			rot = 7.0
		var z: int = 5 + index
		if uid == hover_uid:
			z = 90
		_targets[uid] = {"pos": pos, "rot": rot, "scale": card_scale, "z": z}


## Blockers step up next to the unit they block.
func _place_blockers() -> void:
	for blocker_uid: int in blockers.keys():
		var attacker_uid: int = int(blockers[blocker_uid])
		if not _targets.has(blocker_uid) or not _targets.has(attacker_uid):
			continue
		var blocker_target: Dictionary = _targets[blocker_uid] as Dictionary
		var attacker_pos: Vector2 = (_targets[attacker_uid] as Dictionary)["pos"] as Vector2
		var dy: float = 150.0 if owner_of(blocker_uid) == human else -150.0
		blocker_target["pos"] = attacker_pos + Vector2(38.0, dy)
		blocker_target["z"] = 40


## Empty set-trap slots (UI-HUD-SLOT) at the places set traps sit, one per trap the player may set; a set trap covers its slot.
func _trap_slots(owner_index: int, y: float) -> void:
	if not UiArt.has("UI-HUD-SLOT"):
		return
	var node_name: String = "TrapSlots%d" % owner_index
	var holder: Control = get_node_or_null(node_name) as Control
	if holder == null:
		holder = Control.new()
		holder.name = node_name
		holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.z_index = 3
		add_child(holder)
	var wanted: int = game.players[owner_index].max_traps
	if holder.get_child_count() == wanted:
		return
	for child: Node in holder.get_children():
		child.queue_free()
	for index: int in range(wanted):
		var slot: TextureRect = TextureRect.new()
		slot.texture = UiArt.texture("UI-HUD-SLOT")
		slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		slot.stretch_mode = TextureRect.STRETCH_SCALE
		slot.size = ART_TRAP_SLOT
		slot.position = Vector2(TRAP_X - float(index) * 62.0, y) - ART_TRAP_SLOT * 0.5
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(slot)


func _layout_traps(owner_index: int) -> void:
	var cards: Array[int] = _cards_in(owner_index, Zone.TRAPS)
	var y: float = PLAYER_INFRASTRUCTURE_Y if owner_index == human else ENEMY_INFRASTRUCTURE_Y
	_trap_slots(owner_index, y)
	for index: int in range(cards.size()):
		_targets[cards[index]] = {"pos": Vector2(TRAP_X - float(index) * 62.0, y), "rot": -6.0 + float(index) * 3.0, "scale": SCALE_TRAP, "z": 4 + index}


## The four resources sit in a fixed tray: one slot per kind (Iron, Red Tape, Ingredient, Garbage), each with a faint icon, a
## count and a tooltip. Coins of a kind stack inside their slot with a small offset.
func _layout_resources(owner_index: int) -> void:
	var cards: Array[int] = _cards_in(owner_index, Zone.RESOURCES)
	var counts: Dictionary = {}
	var kinds: Array[ResourceKind.Kind] = ResourceKind.all()
	for uid: int in cards:
		var kind: int = card_data[uid].resource_kind if card_data.has(uid) else 0
		var slot: int = kinds.find(kind as ResourceKind.Kind)
		var stacked: int = int(counts.get(kind, 0))
		counts[kind] = stacked + 1
		var stack_offset: Vector2 = Vector2(minf(float(stacked), 5.0) * 2.5, -minf(float(stacked), 5.0) * 1.5)
		var pos: Vector2 = _socket_center(owner_index, maxi(slot, 0)) + stack_offset + (Vector2.ZERO if _art_resources() else Vector2(-6.0, -4.0))
		_targets[uid] = {"pos": pos, "rot": 0.0, "scale": SCALE_RESOURCE_ART if _art_resources() else SCALE_RESOURCE, "z": 30 + stacked}
	var tray: Control = _tray(owner_index)
	for slot_index: int in range(kinds.size()):
		var count: int = int(counts.get(int(kinds[slot_index]), 0))
		var label: Label = tray.get_node("Count%d" % slot_index) as Label
		label.text = "x%d" % count
		(tray.get_node("Icon%d" % slot_index) as TextureRect).modulate.a = 0.55 if count == 0 else 0.0


func _art_resources() -> bool:
	return UiArt.has("UI-HUD-RESOURCES")


## The centre of resource socket `slot` of a player's tray (the old row of slots without the art).
func _socket_center(owner_index: int, slot: int) -> Vector2:
	if not _art_resources():
		return RESOURCE_ORIGIN[owner_index] + Vector2(float(slot) * RESOURCE_SLOT_PITCH, 0.0)
	var top: float = RESOURCE_ORIGIN[owner_index].y - ART_TRAY_SIZE.y * 0.5
	return Vector2(ART_TRAY_X + ART_TRAY_SIZE.x * ART_TRAY_SOCKETS[slot], top + ART_TRAY_SIZE.y * 0.5)


func _tray(owner_index: int) -> Control:
	var node_name: String = "ResourceTray%d" % owner_index
	var existing: Node = get_node_or_null(node_name)
	if existing is Control:
		return existing as Control
	var tray: Control = Control.new()
	tray.name = node_name
	tray.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tray.z_index = 20
	add_child(tray)
	var kinds: Array[ResourceKind.Kind] = ResourceKind.all()
	if _art_resources():
		var frame: TextureRect = TextureRect.new()
		frame.name = "TrayArt"
		frame.texture = UiSkin.rotated_texture("UI-HUD-RESOURCES", ART_TRAY_SIZE)
		frame.position = Vector2(ART_TRAY_X, RESOURCE_ORIGIN[owner_index].y - ART_TRAY_SIZE.y * 0.5)
		frame.size = ART_TRAY_SIZE
		frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tray.add_child(frame)
	for slot_index: int in range(kinds.size()):
		var kind: ResourceKind.Kind = kinds[slot_index]
		var center: Vector2 = _socket_center(owner_index, slot_index)
		var slot: Panel = Panel.new()
		slot.name = "Slot%d" % slot_index
		slot.position = center - Vector2(RESOURCE_SLOT_PITCH * 0.5 - 3.0, 32.0)
		slot.size = Vector2(RESOURCE_SLOT_PITCH - 6.0, 84.0)
		if _art_resources():
			slot.position = center - Vector2(24.0, 24.0)
			slot.size = Vector2(48.0, 48.0)
			slot.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		else:
			slot.add_theme_stylebox_override("panel", UIStyle.box(Color(0.05, 0.03, 0.09, 0.55), Color(ResourceKind.COLORS[kind] as Color, 0.55), 2, 10))
		slot.mouse_filter = Control.MOUSE_FILTER_PASS
		HoverTip.attach(slot, "%s (resource)" % ResourceKind.display_name(kind), str(ResourceKind.DESCRIPTIONS[kind]), ResourceKind.COLORS[kind] as Color, IconArt.resource_id(kind))
		tray.add_child(slot)
		var icon: TextureRect = IconArt.glyph_or(IconArt.resource_id(kind), CardIcons.named(str(CardIcons.RESOURCE_ICONS[ResourceKind.Kind.keys()[kind]])), ResourceKind.COLORS[kind] as Color, 34.0)
		icon.name = "Icon%d" % slot_index
		icon.position = center - (Vector2(15, 15) if _art_resources() else Vector2(17, 21))
		icon.size = Vector2(30, 30) if _art_resources() else Vector2(34, 34)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tray.add_child(icon)
		var count: Label = Label.new()
		count.name = "Count%d" % slot_index
		count.position = center + (Vector2(-RESOURCE_SLOT_PITCH * 0.5 + 3.0, 14.0) if _art_resources() else Vector2(-RESOURCE_SLOT_PITCH * 0.5 + 3.0, 28.0))
		count.z_index = 45
		count.size = Vector2(RESOURCE_SLOT_PITCH - 6.0, 22.0)
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		count.add_theme_font_size_override("font_size", 15)
		count.add_theme_color_override("font_color", Color("f1e6c8"))
		count.add_theme_color_override("font_outline_color", Color("1b1020"))
		count.add_theme_constant_override("outline_size", 6)
		count.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tray.add_child(count)
	return tray


## Non-resource tokens (Contracts) sit in their own labelled area, apart from the resource tray: parchment tiles stacked tightly,
## a "Tokens" caption with a counter, and a tooltip. A Contract is a token, not a resource.
func _layout_tokens(owner_index: int) -> void:
	var cards: Array[int] = _cards_in(owner_index, Zone.TOKENS)
	cards.sort()
	var art: bool = UiArt.has("UI-HUD-TOKENS")
	var step: float = minf(14.0, TOKEN_SPAN / float(maxi(cards.size(), 1)))
	var origin: Vector2 = TOKEN_ORIGIN[owner_index]
	if art:
		_token_tray(owner_index)
		step = minf(8.0, 24.0 / float(maxi(cards.size(), 1)))
		origin = ART_TOKEN_CENTERS[owner_index] - Vector2(step * float(maxi(cards.size() - 1, 0)) * 0.5, 0.0)
	for index: int in range(cards.size()):
		_targets[cards[index]] = {"pos": origin + Vector2(float(index) * step, 0.0), "rot": 0.0, "scale": SCALE_TOKEN_ART if art else SCALE_TOKEN, "z": 30 + index}
	var badge: Label = _token_badge(owner_index)
	badge.visible = not cards.is_empty()
	badge.text = "TOKENS\nContract x%d" % cards.size()
	badge.position = origin + Vector2(TOKEN_SPAN + 8.0, -17.0)
	if art:
		badge.position = ART_TOKEN_CENTERS[owner_index] + Vector2(ART_TOKEN_TRAY_SIZE.x * 0.5 + 6.0, -17.0)
	if IconArt.has(IconArt.resource_id(ResourceKind.Kind.CONTRACT)):
		badge.position.x += TOKEN_ICON_ROOM
	badge.size = Vector2(150.0, 34.0)
## The token tray (UI-HUD-TOKENS) under a player's Contracts; always drawn, so the area reads as the token area even when empty.
func _token_tray(owner_index: int) -> Control:
	var node_name: String = "TokenTray%d" % owner_index
	var existing: Node = get_node_or_null(node_name)
	if existing is Control:
		return existing as Control
	var tray: TextureRect = TextureRect.new()
	tray.name = node_name
	tray.texture = UiArt.texture("UI-HUD-TOKENS")
	tray.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tray.stretch_mode = TextureRect.STRETCH_SCALE
	tray.size = ART_TOKEN_TRAY_SIZE
	tray.position = ART_TOKEN_CENTERS[owner_index] - ART_TOKEN_TRAY_SIZE * 0.5
	tray.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tray.z_index = 20
	add_child(tray)
	return tray


## Room left of the token caption for the Contract icon.
const TOKEN_ICON_ROOM: float = 28.0


func _token_badge(owner_index: int) -> Label:
	var node_name: String = "TokenBadge%d" % owner_index
	var existing: Node = get_node_or_null(node_name)
	if existing is Label:
		return existing as Label
	var badge: Label = Label.new()
	badge.name = node_name
	badge.add_theme_font_size_override("font_size", 13)
	badge.add_theme_color_override("font_color", Color("f1e6c8"))
	badge.add_theme_color_override("font_outline_color", Color("1b1020"))
	badge.add_theme_constant_override("outline_size", 6)
	badge.mouse_filter = Control.MOUSE_FILTER_PASS
	badge.z_index = 60
	HoverTip.attach(badge, "Contract (token, not a resource)", str(ResourceKind.DESCRIPTIONS[ResourceKind.Kind.CONTRACT]), UIStyle.GOLD, IconArt.resource_id(ResourceKind.Kind.CONTRACT))
	var contract_icon: TextureRect = IconArt.rect(IconArt.resource_id(ResourceKind.Kind.CONTRACT), 26.0)
	if contract_icon != null:
		contract_icon.position = Vector2(-TOKEN_ICON_ROOM, 4.0)
		badge.add_child(contract_icon)
	add_child(badge)
	return badge


func _apply_target(uid: int, target: Dictionary, animated: bool) -> void:
	var view: CardView = view_for(uid)
	if view == null:
		return
	var pos: Vector2 = (target["pos"] as Vector2) - CardView.SIZE * 0.5
	var rot: float = float(target["rot"])
	var card_scale: float = float(target["scale"])
	view.z_index = int(target["z"])
	var previous: Variant = view.get_meta("tween") if view.has_meta("tween") else null
	if previous is Tween and (previous as Tween).is_valid():
		(previous as Tween).kill()
	if not animated or bool(target.get("instant", false)):
		view.position = pos
		view.rotation_degrees = rot
		view.scale = Vector2.ONE * card_scale
		view.modulate.a = 1.0
		return
	var tween: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var duration: float = 0.32 / speed
	tween.tween_property(view, "position", pos, duration)
	tween.tween_property(view, "rotation_degrees", rot, duration)
	tween.tween_property(view, "scale", Vector2.ONE * card_scale, duration)
	tween.tween_property(view, "modulate:a", 1.0, duration * 0.6)
	view.set_meta("tween", tween)


func center_of(uid: int) -> Vector2:
	var view: CardView = view_for(uid)
	if view == null:
		return CENTER_POINT
	return view.position + CardView.SIZE * 0.5


# ---- Reconcile with the real game state -------------------------------------------------


## Makes the views match the rules state exactly (creates missing views, drops stale ones).
func sync_state(animated: bool = true) -> void:
	_flush_center_instant()
	var alive: Dictionary = {}
	for player: PlayerState in game.players:
		_sync_zone(player.hand, player.index, Zone.HAND, alive)
		_sync_zone(player.field, player.index, Zone.FIELD, alive)
		_sync_zone(player.infrastructure, player.index, Zone.INFRASTRUCTURE, alive)
		_sync_zone(player.traps, player.index, Zone.TRAPS, alive)
		_sync_zone(player.resources, player.index, Zone.RESOURCES, alive)
		_sync_zone(player.tokens, player.index, Zone.TOKENS, alive)
	for uid: int in views.keys():
		if not alive.has(uid):
			var view: CardView = views[uid] as CardView
			views.erase(uid)
			zones.erase(uid)
			order.erase(uid)
			if hover_uid == uid:
				hover_uid = 0
			view.queue_free()
	if game.phase != GameState.Phase.COMBAT:
		attacking.clear()
		blockers.clear()
	refresh_all()
	layout(animated)


func _sync_zone(cards: Array[CardInstance], owner_index: int, zone: Zone, alive: Dictionary) -> void:
	for card: CardInstance in cards:
		alive[card.uid] = true
		card_data[card.uid] = card.data
		if not views.has(card.uid):
			var view: CardView = ensure_view(card.uid, zone, owner_index)
			if view != null:
				view.modulate.a = 1.0
		elif zones.get(card.uid) != zone:
			set_zone(card.uid, zone)


## Dissolves every card still on the table (hand, field, infrastructure, traps) away. Used when a
## battle ends, so the result/reward panel never overlaps a frozen board. Fire-and-forget per
## card (matches `_on_died`'s pattern); the caller awaits a fixed settle time.
func clear_board() -> void:
	var uids: Array[int] = order.duplicate()
	for uid: int in uids:
		var view: CardView = views.get(uid) as CardView
		if view == null:
			continue
		views.erase(uid)
		zones.erase(uid)
		order.erase(uid)
		var color: Color = UIStyle.affinity_color(view.data.color) if view.data != null else Color.WHITE
		fx.dissolve(view, color, 0.4)
	hover_uid = 0
	drag_uid = 0
	attacking.clear()
	blockers.clear()
	if not uids.is_empty():
		await _wait(0.55)


func _flush_center_instant() -> void:
	for uid: int in views.keys():
		if zones.get(uid) == Zone.CENTER:
			var card: CardInstance = game.find_card(uid)
			# A card left in the center that is no longer on any live zone is finished.
			if card == null or not (game.players[card.owner].field.has(card) or game.players[card.owner].traps.has(card) or game.players[card.owner].hand.has(card) or game.players[card.owner].infrastructure.has(card)):
				var view: CardView = views[uid] as CardView
				views.erase(uid)
				zones.erase(uid)
				order.erase(uid)
				view.queue_free()


# ---- Event presentation -----------------------------------------------------------------


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds / speed, false).timeout


func flush_center() -> void:
	if _center_uid == 0:
		return
	var uid: int = _center_uid
	_center_uid = 0
	if zones.get(uid) != Zone.CENTER or not views.has(uid):
		return
	var view: CardView = view_for(uid)
	views.erase(uid)
	zones.erase(uid)
	order.erase(uid)
	fx.dissolve(view, UIStyle.affinity_color(view.data.color) if view.data != null else Color.WHITE, 0.55)
	await _wait(0.2)


func present(event: GameEvent) -> void:
	register_uid(event.card)
	if event.other > 0:
		register_uid(event.other)
	# Bug fix (Part A): TRAP_SET must NOT flush the center - it always follows the CARD_CAST for
	# the very same card and only re-homes that same view into the trap row (see _on_trap_set,
	# which already clears _center_uid itself once it does). Flushing here used to dissolve the
	# trap's view out of existence before _on_trap_set could move it, so a set trap never actually
	# appeared in the trap row at all - it just vanished after the play animation.
	var flush_types: Array[GameEvent.Type] = [
		GameEvent.Type.CARD_PLAYED, GameEvent.Type.INFRASTRUCTURE_PLAYED, GameEvent.Type.TURN_STARTED,
		GameEvent.Type.ATTACKERS_DECLARED, GameEvent.Type.PHASE_CHANGED,
	]
	if flush_types.has(event.type):
		await flush_center()
	match event.type:
		GameEvent.Type.CARD_DRAWN:
			await _on_drawn(event)
		GameEvent.Type.MULLIGAN_TAKEN:
			_on_mulligan(event)
		GameEvent.Type.INFRASTRUCTURE_PLAYED:
			await _on_infrastructure_played(event)
		GameEvent.Type.ENERGY_SPENT:
			_refresh_view(event.card)
			_energy_ticks(event.amount)
			layout()
		GameEvent.Type.ENERGY_ADDED:
			_sfx(&"energy_gain")
		GameEvent.Type.UNIT_ATTACHED:
			_sfx(&"tool_attach")
			_pulse(event.other)
		GameEvent.Type.CARD_SHREDDED:
			_sfx(&"card_shred")
		GameEvent.Type.COIN_FLIPPED:
			_sfx(&"coin_flip")
		GameEvent.Type.CARD_PLAYED:
			await _on_cast(event)
		GameEvent.Type.PERMANENT_ENTERED:
			await _on_entered(event)
		GameEvent.Type.TRAP_SET:
			await _on_trap_set(event)
		GameEvent.Type.TRAP_TRIGGERED:
			await _on_trap_triggered(event)
		GameEvent.Type.TOKEN_CREATED:
			await _on_token(event)
		GameEvent.Type.ATTACKERS_DECLARED:
			attacking[event.card] = true
			_sfx(&"attack_declare")
			layout()
			await _wait(0.16)
		GameEvent.Type.BLOCKER_ASSIGNED:
			blockers[event.card] = event.other
			_sfx(&"block")
			layout()
			await _wait(0.3)
		GameEvent.Type.DAMAGE_DEALT:
			await _on_damage(event)
		GameEvent.Type.HP_CHANGED:
			_on_hp(event)
		GameEvent.Type.UNIT_DIED:
			await _on_died(event)
		GameEvent.Type.CARD_SENT_BACK:
			await _on_returned(event)
		GameEvent.Type.CARD_TOSSED:
			await _on_discarded(event)
		GameEvent.Type.EFFECT_TRIGGERED, GameEvent.Type.ABILITY_ACTIVATED:
			_pulse(event.card)
			await _wait(0.16)
		GameEvent.Type.STATS_CHANGED:
			_refresh_view(event.card)
			if event.amount > 0 or event.value > 0:
				_sfx(&"buff")
				fx.burst(center_of(event.card), Color("9be49f"), 10, 120.0)
			else:
				_sfx(&"debuff")
			fx.floating_text(center_of(event.card), "%+d/%+d" % [event.amount, event.value], Color("9be49f"), 36)
			await _wait(0.25)
		GameEvent.Type.KEYWORD_GRANTED:
			_refresh_view(event.card)
			_sfx(&"keyword_gain")
			fx.floating_text(center_of(event.card), KeywordInfo.keyword_name(event.value as CardEnums.Keyword), UIStyle.GOLD, 34)
			await _wait(0.25)
		GameEvent.Type.DAMAGE_HEALED:
			_refresh_view(event.card)
			_sfx(&"heal")
			fx.floating_text(center_of(event.card), "+%d" % event.amount, Color("7be08a"), 40)
			await _wait(0.25)
		GameEvent.Type.RESOURCE_CREATED:
			_on_resource(event, true)
		GameEvent.Type.RESOURCE_USED:
			_on_resource(event, false)
		GameEvent.Type.DAMAGE_CLEARED:
			_refresh_view(event.card)
		GameEvent.Type.PHASE_CHANGED:
			if event.value != int(GameState.Phase.COMBAT):
				attacking.clear()
				blockers.clear()
				layout()
		GameEvent.Type.TURN_STARTED:
			attacking.clear()
			blockers.clear()
			layout()
		_:
			pass


func _pulse(uid: int) -> void:
	var view: CardView = view_for(uid)
	if view == null:
		return
	var color: Color = UIStyle.affinity_color(view.data.color) if view.data != null else Color.WHITE
	fx.flash_ring(center_of(uid), color, 70.0)
	_refresh_view(uid)


func _on_drawn(event: GameEvent) -> void:
	var view: CardView = ensure_view(event.card, Zone.HAND, event.player)
	if view == null:
		return
	var opening: bool = event.detail == "opening"
	_sfx(&"card_draw", -6.0 if opening else (-2.0 if event.player == human else -5.0))
	layout()
	await _wait(0.1 if opening else 0.3)


func _on_mulligan(event: GameEvent) -> void:
	for uid: int in _cards_in(event.player, Zone.HAND):
		var view: CardView = view_for(uid)
		views.erase(uid)
		zones.erase(uid)
		order.erase(uid)
		view.queue_free()
	_sfx(&"card_shuffle")


## Sound pass, Part B: a battle sound on this board's beat; its layer delays shrink with the board's speed so it stays on the animation.
func _sfx(sound: StringName, volume_db: float = 0.0) -> void:
	Audio.play(sound, {"volume": volume_db, "speed": speed})


var _preview_signature: String = ""
var _energy_burst: int = 0
var _energy_burst_at: int = -1000


## One glassy tick per energy point paid, a little apart and rising, so a 4-cost card reads as four ticks (several infrastructure tapped for one card
## arrive as separate events within a frame; they join one run).
func _energy_ticks(points: int) -> void:
	var now: int = Time.get_ticks_msec()
	if now - _energy_burst_at > 300:
		_energy_burst = 0
	_energy_burst_at = now
	for i: int in range(clampi(points, 1, 8)):
		var step: int = mini(_energy_burst, 8)
		_energy_burst += 1
		var delay: float = 0.07 * float(step) / maxf(speed, 0.1)
		var pitch: float = 1.0 + 0.045 * float(step)
		if delay <= 0.0:
			Audio.play(&"energy_tick", {"pitch_scale": pitch})
		else:
			get_tree().create_timer(delay).timeout.connect(func() -> void: Audio.play(&"energy_tick", {"pitch_scale": pitch}))


func _reveal(uid: int) -> void:
	var view: CardView = view_for(uid)
	if view == null:
		return
	if bool(view.get_meta("hidden", false)):
		view.set_meta("hidden", false)
		view.set_mode(CardView.Mode.FULL)
		_refresh_view(uid)


func _on_infrastructure_played(event: GameEvent) -> void:
	if not views.has(event.card):
		ensure_view(event.card, Zone.HAND, event.player, Vector2(CENTER_X, ENEMY_HAND_Y), SCALE_ENEMY_HAND)
	_reveal(event.card)
	set_zone(event.card, Zone.INFRASTRUCTURE)
	_sfx(&"land_play")
	layout()
	await _wait(0.35)


func _on_cast(event: GameEvent) -> void:
	if not views.has(event.card):
		ensure_view(event.card, Zone.HAND, event.player, Vector2(CENTER_X, ENEMY_HAND_Y), SCALE_ENEMY_HAND)
	var data: CardData = card_data.get(event.card) as CardData
	# Bug fix (Part A): setting a trap is still a CARD_CAST event before the TRAP_SET event that
	# actually moves it into the (hidden) trap row. An opponent's trap must never hit the
	# face-up center reveal in between - it goes straight from a hidden hand card to a hidden
	# trap slot. The player's own traps are unaffected: playing them is meant to be visible to
	# the player who is setting them.
	if data != null and data.type == CardEnums.CardType.TRAP and event.player != human:
		layout()
		_sfx(&"card_play_cheap", -2.0)
		await _wait(0.2)
		return
	_reveal(event.card)
	var view: CardView = view_for(event.card)
	if view == null:
		return
	if _lift(view):
		await _wait(0.08)
	zones[event.card] = Zone.CENTER
	view.set_mode(CardView.Mode.FULL)
	_center_uid = event.card
	_sfx(BattleSounds.play(view.data))
	layout()
	await _wait(0.55)


func _on_entered(event: GameEvent) -> void:
	if not views.has(event.card):
		ensure_view(event.card, Zone.FIELD, event.player, CENTER_POINT, SCALE_CENTER)
	if _center_uid == event.card:
		_center_uid = 0
	_reveal(event.card)
	set_zone(event.card, Zone.FIELD)
	layout()
	var view: CardView = view_for(event.card)
	if view != null:
		await _wait(0.24)
		_land(view, SCALE_BF)
		fx.flash_ring(center_of(event.card), UIStyle.affinity_color(view.data.color), 60.0)
	await _wait(0.16)


## Battle feel, Part C: a card about to fly to the middle lifts off first (hand cards only; an enemy card is already up top).
func _lift(view: CardView) -> bool:
	if zones.get(view.instance_uid) != Zone.HAND or int(view.get_meta("owner", 0)) != human:
		return false
	var previous: Variant = view.get_meta("tween") if view.has_meta("tween") else null
	if previous is Tween and (previous as Tween).is_valid():
		(previous as Tween).kill()
	var tween: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(view, "position:y", view.position.y - 46.0, 0.07 / speed)
	tween.tween_property(view, "scale", view.scale * 1.08, 0.07 / speed)
	tween.tween_property(view, "rotation_degrees", 0.0, 0.07 / speed)
	return true


## Battle feel, Part C: a unit lands on the field: a quick squash and settle, a puff of dust and a thud.
func _land(view: CardView, rest_scale: float) -> void:
	if not is_instance_valid(view):
		return
	var previous: Variant = view.get_meta("tween") if view.has_meta("tween") else null
	if previous is Tween and (previous as Tween).is_valid():
		(previous as Tween).kill()
	var tween: Tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(view, "scale", Vector2(rest_scale * 1.1, rest_scale * 0.94), 0.05 / speed)
	tween.tween_property(view, "scale", Vector2.ONE * rest_scale, 0.12 / speed)
	view.set_meta("tween", tween)
	_sfx(BattleSounds.summon(view.data))
	var foot: Vector2 = view.position + Vector2(CardView.SIZE.x * 0.5, CardView.SIZE.y) * rest_scale
	fx.burst(foot, Color("d8c8a8"), 10, 110.0)


## Battle feel, Part C: a resource coin is gained (a gold pop and coins) or spent (a ring and a click) at its tray socket.
func _on_resource(event: GameEvent, gained: bool) -> void:
	var kinds: Array[ResourceKind.Kind] = ResourceKind.all()
	var slot: int = kinds.find(event.value as ResourceKind.Kind)
	var owner_index: int = clampi(event.player, 0, 1)
	var spot: Vector2 = _socket_center(owner_index, maxi(slot, 0)) if slot >= 0 else TOKEN_ORIGIN[owner_index]
	var color: Color = ResourceKind.COLORS[event.value] as Color if ResourceKind.COLORS.has(event.value) else UIStyle.GOLD
	if gained:
		_sfx(BattleSounds.resource(event.value, true))
		fx.burst(spot, color, 10, 140.0)
		fx.floating_text(spot + Vector2(0, -30), "+%d" % maxi(event.amount, 1), color.lightened(0.3), 28)
	else:
		_sfx(BattleSounds.resource(event.value, false))
		fx.flash_ring(spot, color, 44.0)


func _on_trap_set(event: GameEvent) -> void:
	if _center_uid == event.card:
		_center_uid = 0
	set_zone(event.card, Zone.TRAPS)
	_sfx(&"trap_set")
	layout()
	await _wait(0.3)


func _on_trap_triggered(event: GameEvent) -> void:
	_reveal(event.card)
	var view: CardView = view_for(event.card)
	if view == null:
		return
	zones[event.card] = Zone.CENTER
	view.set_mode(CardView.Mode.FULL)
	_center_uid = event.card
	# Battle feel, Part C: the trap flips up dramatically: it swings up edge-on from its slot and turns face-up in the middle.
	view.pivot_offset = CardView.SIZE * 0.5
	view.rotation_degrees = -28.0
	view.scale = Vector2(0.04, SCALE_TRAP)
	_sfx(&"trap_spring")
	layout()
	fx.flash_ring(CENTER_POINT, UIStyle.GOLD, 160.0)
	await _wait(0.12)
	fx.flash_ring(CENTER_POINT, Color("ff9c4a"), 230.0)
	fx.floating_text(CENTER_POINT + Vector2(0, -230), "TRAP!", UIStyle.GOLD, 64)
	fx.shake(6.0, 0.22)
	await _wait(0.68)


func _on_token(event: GameEvent) -> void:
	var view: CardView = ensure_view(event.card, Zone.FIELD, event.player, CENTER_POINT, 0.3)
	if view == null:
		return
	set_zone(event.card, Zone.FIELD)
	_sfx(&"token_create")
	layout()
	fx.burst(center_of(event.card), UIStyle.affinity_color(view.data.color), 14, 160.0)
	await _wait(0.3)


func _on_damage(event: GameEvent) -> void:
	_last_damage_seq = event.sequence
	var heavy: bool = event.amount >= 3
	var attacker_view: CardView = view_for(event.card)
	var target_center: Vector2 = Vector2.ZERO
	var on_player: bool = event.other < 0
	if on_player:
		target_center = portrait_anchor[Targets.player_index(event.other)]
	else:
		target_center = center_of(event.other)
	# The attacking unit lunges at its target before the hit lands.
	if attacker_view != null and attacking.has(event.card) and zones.get(event.card) == Zone.FIELD:
		var origin: Vector2 = attacker_view.position
		var lunge: Vector2 = (target_center - center_of(event.card)).limit_length(120.0)
		var tween: Tween = create_tween().set_trans(Tween.TRANS_QUAD)
		_sfx(&"attack_lunge")
		tween.tween_property(attacker_view, "position", origin + lunge, 0.09 / speed).set_ease(Tween.EASE_IN)
		tween.tween_property(attacker_view, "position", origin, 0.16 / speed).set_ease(Tween.EASE_OUT)
		await tween.finished
	elif attacker_view != null and zones.get(event.card) == Zone.CENTER:
		fx.flash_ring(target_center, UIStyle.affinity_color(attacker_view.data.color), 90.0)
	# A blow that does nothing (all of it prevented) clanks like a block.
	_sfx(BattleSounds.hit(event.amount, on_player) if event.amount > 0 else &"block")
	if event.amount > 0:
		fx.floating_text(target_center, "-%d" % event.amount, Color("ff6a5a"), 52 if heavy else 44)
		fx.burst(target_center, Color("ff8a5a"), 12 + event.amount * 3, 240.0)
	if event.amount >= 4 or (on_player and event.amount >= 3):
		fx.shake(minf(4.0 + float(event.amount) * 2.0, 18.0), 0.26)
	if not on_player:
		var target_view: CardView = view_for(event.other)
		if target_view != null:
			if not Settings.reduce_flashing:
				var flash: Tween = create_tween()
				flash.tween_property(target_view, "modulate", Color(1.6, 0.6, 0.6), 0.06)
				flash.tween_property(target_view, "modulate", Color.WHITE, 0.2)
		_refresh_view(event.other)
	await _wait(0.28)


func _on_hp(event: GameEvent) -> void:
	if event.amount > 0:
		_sfx(&"heal")
		fx.floating_text(portrait_anchor[event.player], "+%d" % event.amount, Color("7be08a"), 48)
		fx.burst(portrait_anchor[event.player], Color("7be08a"), 14, 200.0)
	elif event.sequence != _last_damage_seq + 1 and event.amount < 0:
		fx.floating_text(portrait_anchor[event.player], "%d" % event.amount, Color("ff6a5a"), 48)
		_sfx(&"hit_player", -3.0)


func _on_died(event: GameEvent) -> void:
	var view: CardView = view_for(event.card)
	if view == null:
		return
	views.erase(event.card)
	zones.erase(event.card)
	order.erase(event.card)
	_sfx(BattleSounds.death(view.data))
	var color: Color = UIStyle.affinity_color(view.data.color) if view.data != null else Color.WHITE
	var pile_owner: int = int(view.get_meta("owner", 0))
	var dead: CardInstance = game.find_card(event.card)
	if dead != null:
		pile_owner = dead.real_owner
	var to_pile: bool = view.data != null and not view.data.is_token
	var crack: Tween = create_tween()
	view.pivot_offset = CardView.SIZE * 0.5
	crack.tween_property(view, "rotation_degrees", view.rotation_degrees + 5.0, 0.04 / speed)
	crack.parallel().tween_property(view, "modulate", Color(1.7, 0.55, 0.5, view.modulate.a), 0.04 / speed)
	crack.tween_property(view, "rotation_degrees", view.rotation_degrees - 5.0, 0.05 / speed)
	crack.tween_property(view, "rotation_degrees", view.rotation_degrees, 0.04 / speed)
	await crack.finished
	fx.burst(center_of(event.card), Color("ffd2b0"), 16, 220.0)
	fx.dissolve(view, color, 0.55 / speed)
	if to_pile:
		var slide: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		var pile_scale: float = RefusePileWidget.CARD_SCALE
		slide.tween_property(view, "global_position", grave_anchor[pile_owner] - CardView.SIZE * 0.5 * pile_scale, 0.45 / speed)
		slide.tween_property(view, "scale", Vector2.ONE * pile_scale, 0.45 / speed)
		slide.tween_property(view, "rotation_degrees", 0.0, 0.45 / speed)
		_sfx(&"card_discard", -7.0)
	layout()
	await _wait(0.4)


func _on_returned(event: GameEvent) -> void:
	if not views.has(event.card):
		ensure_view(event.card, Zone.FIELD, event.player)
	set_zone(event.card, Zone.HAND)
	_sfx(&"card_return")
	layout()
	await _wait(0.3)


func _on_discarded(event: GameEvent) -> void:
	var view: CardView = view_for(event.card)
	if view == null:
		return
	_reveal(event.card)
	views.erase(event.card)
	zones.erase(event.card)
	order.erase(event.card)
	_sfx(&"card_discard")
	fx.dissolve(view, UIStyle.affinity_color(view.data.color) if view.data != null else Color.WHITE, 0.45)
	layout()
	await _wait(0.25)


# ---- Highlights -------------------------------------------------------------------------


## `glows` maps card uid -> CardView.Glow. Cards not listed lose their glow.
func set_glows(glows: Dictionary) -> void:
	for uid: int in views.keys():
		var view: CardView = views[uid] as CardView
		view.set_glow(int(glows.get(uid, CardView.Glow.NONE)) as CardView.Glow)


## Battle feel, Part A: cards in `dims` (uid -> true) are shown slightly darker (unplayable hand cards, cards that are not a
## legal target). Only the colour changes; the alpha the layout tweens is kept.
const DIM_COLOR: Color = Color(0.55, 0.53, 0.6)


func set_dims(dims: Dictionary) -> void:
	for uid: int in views.keys():
		var view: CardView = views[uid] as CardView
		var wanted: Color = DIM_COLOR if dims.has(uid) else Color.WHITE
		view.modulate = Color(wanted.r, wanted.g, wanted.b, view.modulate.a)
		view.set_meta("dimmed", dims.has(uid))


## Battle feel, Part A: the combat preview from CombatPreview.predict - a badge on every unit that would take damage (a skull when
## it would die) and, by each player's plate, how much damage reaches that player. `note` is the line under the player number
## ("if unblocked" while attackers are chosen). An empty or invalid preview clears everything.
func show_combat_preview(preview: Dictionary, note: String = "") -> void:
	var units: Dictionary = preview.get("units", {}) as Dictionary
	var valid: bool = bool(preview.get("valid", false))
	for uid: int in views.keys():
		var view: CardView = views[uid] as CardView
		var badge: Control = view.get_node_or_null("PreviewBadge") as Control
		var entry: Dictionary = units.get(uid, {}) as Dictionary
		if not valid or entry.is_empty() or zones.get(uid) != Zone.FIELD:
			if badge != null:
				badge.queue_free()
			continue
		if badge != null:
			badge.free()
		view.add_child(_preview_badge(int(entry["damage"]), bool(entry["dies"])))
	var players: Array = preview.get("players", [0, 0]) as Array
	# Sound pass, Part B: a soft paper tick when a new preview appears, a low knock and a heartbeat when it shows a lethal blow.
	var signature: String = ""
	var any_lethal: bool = false
	if valid:
		for uid: Variant in units.keys():
			signature += "%s:%s;" % [uid, str(units[uid])]
		signature += str(players)
		for index: int in range(2):
			any_lethal = any_lethal or (int(players[index]) > 0 and int(players[index]) >= game.players[index].hp)
	if signature != _preview_signature:
		_preview_signature = signature
		if not signature.is_empty():
			_sfx(&"preview_lethal" if any_lethal else &"preview_tick")
	for index: int in range(2):
		var plate: Label = _player_preview_label(index)
		var amount: int = int(players[index]) if valid else 0
		plate.visible = amount > 0
		if amount > 0:
			var lethal: bool = amount >= game.players[index].hp
			plate.text = "-%d HP%s%s" % [amount, " " + note if not note.is_empty() else "", "  LETHAL!" if lethal else ""]
			plate.add_theme_font_size_override("font_size", 28 if plate.text.length() < 18 else 19)
			plate.add_theme_color_override("font_color", Color("ff4a3a") if lethal else Color("ff8a6a"))


func clear_combat_preview() -> void:
	show_combat_preview({})


func _preview_badge(damage: int, dies: bool) -> Control:
	var badge: PanelContainer = PanelContainer.new()
	badge.name = "PreviewBadge"
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	badge.add_theme_stylebox_override("panel", UIStyle.box(Color(0.12, 0.02, 0.03, 0.92), Color("ff5a4a") if dies else Color("f1b04a"), 4, 22))
	badge.z_index = 30
	var row: HBoxContainer = UIKit.hbox(6)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	badge.add_child(row)
	if dies:
		var skull: TextureRect = CardIcons.glyph(load(CardIcons.BASE + "lorc/skull-crossed-bones.svg") as Texture2D, Color("ffd9cf"), Vector2(54, 54))
		skull.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(skull)
	var label: Label = UIKit.label("-%d" % damage, &"", 52, Color("ffd9cf") if dies else Color("ffcf7a"), HORIZONTAL_ALIGNMENT_CENTER)
	label.add_theme_font_override("font", UIStyle.font_title())
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(label)
	badge.reset_size()
	badge.custom_minimum_size = Vector2(150, 72) if dies else Vector2(110, 72)
	badge.size = badge.custom_minimum_size
	badge.position = Vector2((CardView.SIZE.x - badge.size.x) * 0.5, -36.0)
	return badge


## The damage line over a player's HP bar (the HP it would lose sits on the bar it comes off).
func _player_preview_label(index: int) -> Label:
	var node_name: String = "PreviewHit%d" % index
	var existing: Label = get_node_or_null(node_name) as Label
	if existing != null:
		return existing
	var label: Label = UIKit.label("", &"", 28, Color("ff8a6a"), HORIZONTAL_ALIGNMENT_CENTER)
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_stylebox_override("normal", UIStyle.box(Color(0.1, 0.02, 0.03, 0.88), Color("ff5a4a"), 3, 12))
	label.name = node_name
	label.add_theme_font_override("font", UIStyle.font_title())
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	label.add_theme_constant_override("outline_size", 10)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.z_index = 160
	label.size = Vector2(330, 46)
	label.position = portrait_anchor[index] + Vector2(-165.0, 26.0)
	label.visible = false
	add_child(label)
	return label
