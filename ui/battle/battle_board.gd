class_name BattleBoard
extends Control
## The card table: creates a CardView per card, lays them out per zone (hands, battlefields,
## land rows, trap slots) and animates the rules engine's event log. It never decides anything
## about the rules; it only shows what GameState already did.

signal card_hovered(view: CardView)
signal card_unhovered(view: CardView)
signal card_input(view: CardView, event: InputEvent)

enum Zone { HAND, BATTLEFIELD, LANDS, TRAPS, CENTER }

const CENTER_X: float = 985.0
const ENEMY_HAND_Y: float = 6.0
const ENEMY_LAND_Y: float = 152.0
const ENEMY_BF_Y: float = 366.0
const PLAYER_BF_Y: float = 620.0
const PLAYER_LAND_Y: float = 806.0
const HAND_Y: float = 985.0
const CENTER_POINT: Vector2 = Vector2(985.0, 500.0)
const BF_SPACING: float = 182.0
const LAND_SPACING: float = 86.0
const SCALE_HAND: float = 0.68
const SCALE_ENEMY_HAND: float = 0.3
const SCALE_BF: float = 0.56
const SCALE_LAND: float = 0.27
const SCALE_TRAP: float = 0.32
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
		for zone_cards: Array[CardInstance] in [player.library, player.hand, player.battlefield, player.lands, player.graveyard, player.traps]:
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
	var hidden: bool = owner_index != human and (zone == Zone.HAND or zone == Zone.TRAPS)
	var view: CardView = CardView.create(data, CardView.Mode.BACK if hidden else _mode_for(zone))
	view.instance_uid = uid
	view.set_meta("owner", owner_index)
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


func _mode_for(zone: Zone) -> CardView.Mode:
	match zone:
		Zone.BATTLEFIELD:
			return CardView.Mode.COMPACT
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
	var hidden: bool = int(view.get_meta("owner", 0)) != human and (zone == Zone.HAND or zone == Zone.TRAPS)
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
		_layout_row(owner_index, Zone.BATTLEFIELD, PLAYER_BF_Y if owner_index == human else ENEMY_BF_Y, SCALE_BF, BF_SPACING, CENTER_X, 1250.0)
		_layout_row(owner_index, Zone.LANDS, PLAYER_LAND_Y if owner_index == human else ENEMY_LAND_Y, SCALE_LAND, LAND_SPACING, CENTER_X - 130.0, 950.0)
		_layout_traps(owner_index)
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
		if zone == Zone.BATTLEFIELD:
			var dir: float = -1.0 if owner_index == human else 1.0
			if attacking.has(uid):
				pos.y += dir * 70.0
		if card != null and card.tapped and zone != Zone.BATTLEFIELD:
			rot = 14.0
		elif card != null and card.tapped:
			rot = 7.0
		var z: int = 5 + index
		if uid == hover_uid:
			z = 90
		_targets[uid] = {"pos": pos, "rot": rot, "scale": card_scale, "z": z}


## Blockers step up next to the creature they block.
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


func _layout_traps(owner_index: int) -> void:
	var cards: Array[int] = _cards_in(owner_index, Zone.TRAPS)
	var y: float = PLAYER_LAND_Y if owner_index == human else ENEMY_LAND_Y
	for index: int in range(cards.size()):
		_targets[cards[index]] = {"pos": Vector2(1500.0 - float(index) * 62.0, y), "rot": -6.0 + float(index) * 3.0, "scale": SCALE_TRAP, "z": 4 + index}


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
		_sync_zone(player.battlefield, player.index, Zone.BATTLEFIELD, alive)
		_sync_zone(player.lands, player.index, Zone.LANDS, alive)
		_sync_zone(player.traps, player.index, Zone.TRAPS, alive)
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


## Dissolves every card still on the table (hand, battlefield, lands, traps) away. Used when a
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
			if card == null or not (game.players[card.owner].battlefield.has(card) or game.players[card.owner].traps.has(card) or game.players[card.owner].hand.has(card) or game.players[card.owner].lands.has(card)):
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
	# appeared in the trap row at all - it just vanished after the cast animation.
	var flush_types: Array[GameEvent.Type] = [
		GameEvent.Type.CARD_CAST, GameEvent.Type.LAND_PLAYED, GameEvent.Type.TURN_STARTED,
		GameEvent.Type.ATTACKERS_DECLARED, GameEvent.Type.PHASE_CHANGED,
	]
	if flush_types.has(event.type):
		await flush_center()
	match event.type:
		GameEvent.Type.CARD_DRAWN:
			await _on_drawn(event)
		GameEvent.Type.MULLIGAN_TAKEN:
			_on_mulligan(event)
		GameEvent.Type.LAND_PLAYED:
			await _on_land_played(event)
		GameEvent.Type.MANA_SPENT:
			_refresh_view(event.card)
			layout()
		GameEvent.Type.CARD_CAST:
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
			Audio.sfx(&"attack")
			layout()
			await _wait(0.16)
		GameEvent.Type.BLOCKER_ASSIGNED:
			blockers[event.card] = event.other
			Audio.sfx(&"card_play", -4.0)
			layout()
			await _wait(0.3)
		GameEvent.Type.DAMAGE_DEALT:
			await _on_damage(event)
		GameEvent.Type.LIFE_CHANGED:
			_on_life(event)
		GameEvent.Type.CREATURE_DIED:
			await _on_died(event)
		GameEvent.Type.CARD_RETURNED_TO_HAND:
			await _on_returned(event)
		GameEvent.Type.CARD_DISCARDED:
			await _on_discarded(event)
		GameEvent.Type.EFFECT_TRIGGERED, GameEvent.Type.ABILITY_ACTIVATED:
			_pulse(event.card)
			await _wait(0.16)
		GameEvent.Type.STATS_CHANGED:
			_refresh_view(event.card)
			fx.floating_text(center_of(event.card), "%+d/%+d" % [event.amount, event.value], Color("9be49f"), 36)
			await _wait(0.25)
		GameEvent.Type.KEYWORD_GRANTED:
			_refresh_view(event.card)
			fx.floating_text(center_of(event.card), KeywordInfo.keyword_name(event.value as CardEnums.Keyword), UIStyle.GOLD, 34)
			await _wait(0.25)
		GameEvent.Type.DAMAGE_HEALED:
			_refresh_view(event.card)
			fx.floating_text(center_of(event.card), "+%d" % event.amount, Color("7be08a"), 40)
			await _wait(0.25)
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
	Audio.sfx(&"card_draw", -4.0)
	var opening: bool = event.detail == "opening"
	layout()
	await _wait(0.1 if opening else 0.3)


func _on_mulligan(event: GameEvent) -> void:
	for uid: int in _cards_in(event.player, Zone.HAND):
		var view: CardView = view_for(uid)
		views.erase(uid)
		zones.erase(uid)
		order.erase(uid)
		view.queue_free()
	Audio.sfx(&"card_shuffle")


func _reveal(uid: int) -> void:
	var view: CardView = view_for(uid)
	if view == null:
		return
	if bool(view.get_meta("hidden", false)):
		view.set_meta("hidden", false)
		view.set_mode(CardView.Mode.FULL)
		_refresh_view(uid)


func _on_land_played(event: GameEvent) -> void:
	if not views.has(event.card):
		ensure_view(event.card, Zone.HAND, event.player, Vector2(CENTER_X, ENEMY_HAND_Y), SCALE_ENEMY_HAND)
	_reveal(event.card)
	set_zone(event.card, Zone.LANDS)
	Audio.sfx(&"land_play")
	layout()
	await _wait(0.35)


func _on_cast(event: GameEvent) -> void:
	if not views.has(event.card):
		ensure_view(event.card, Zone.HAND, event.player, Vector2(CENTER_X, ENEMY_HAND_Y), SCALE_ENEMY_HAND)
	var data: CardData = card_data.get(event.card) as CardData
	# Bug fix (Part A): setting a trap is still a CARD_CAST event before the TRAP_SET event that
	# actually moves it into the (hidden) trap row. An opponent's trap must never hit the
	# face-up center reveal in between - it goes straight from a hidden hand card to a hidden
	# trap slot. The player's own traps are unaffected: casting them is meant to be visible to
	# the player who is setting them.
	if data != null and data.type == CardEnums.CardType.TRAP and event.player != human:
		layout()
		Audio.sfx(&"card_play")
		await _wait(0.2)
		return
	_reveal(event.card)
	var view: CardView = view_for(event.card)
	if view == null:
		return
	zones[event.card] = Zone.CENTER
	view.set_mode(CardView.Mode.FULL)
	_center_uid = event.card
	Audio.sfx(&"card_play")
	if view.data != null and view.data.type == CardEnums.CardType.SPELL:
		Audio.sfx(&"spell", -6.0)
	layout()
	await _wait(0.55)


func _on_entered(event: GameEvent) -> void:
	if not views.has(event.card):
		ensure_view(event.card, Zone.BATTLEFIELD, event.player, CENTER_POINT, SCALE_CENTER)
	if _center_uid == event.card:
		_center_uid = 0
	_reveal(event.card)
	set_zone(event.card, Zone.BATTLEFIELD)
	layout()
	var view: CardView = view_for(event.card)
	if view != null:
		fx.flash_ring(center_of(event.card), UIStyle.affinity_color(view.data.color), 60.0)
	await _wait(0.3)


func _on_trap_set(event: GameEvent) -> void:
	if _center_uid == event.card:
		_center_uid = 0
	set_zone(event.card, Zone.TRAPS)
	Audio.sfx(&"trap", -6.0)
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
	Audio.sfx(&"trap")
	fx.flash_ring(CENTER_POINT, UIStyle.GOLD, 160.0)
	fx.shake(8.0, 0.25)
	layout()
	await _wait(0.8)


func _on_token(event: GameEvent) -> void:
	var view: CardView = ensure_view(event.card, Zone.BATTLEFIELD, event.player, CENTER_POINT, 0.3)
	if view == null:
		return
	set_zone(event.card, Zone.BATTLEFIELD)
	Audio.sfx(&"card_play", -4.0)
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
	# The attacking creature lunges at its target before the hit lands.
	if attacker_view != null and attacking.has(event.card) and zones.get(event.card) == Zone.BATTLEFIELD:
		var origin: Vector2 = attacker_view.position
		var lunge: Vector2 = (target_center - center_of(event.card)).limit_length(120.0)
		var tween: Tween = create_tween().set_trans(Tween.TRANS_QUAD)
		tween.tween_property(attacker_view, "position", origin + lunge, 0.09 / speed).set_ease(Tween.EASE_IN)
		tween.tween_property(attacker_view, "position", origin, 0.16 / speed).set_ease(Tween.EASE_OUT)
		await tween.finished
	elif attacker_view != null and zones.get(event.card) == Zone.CENTER:
		fx.flash_ring(target_center, UIStyle.affinity_color(attacker_view.data.color), 90.0)
	Audio.sfx(&"hit_heavy" if heavy else &"hit_light")
	if event.amount > 0:
		fx.floating_text(target_center, "-%d" % event.amount, Color("ff6a5a"), 52 if heavy else 44)
		fx.burst(target_center, Color("ff8a5a"), 12 + event.amount * 3, 240.0)
	if heavy or (on_player and event.amount >= 2):
		fx.shake(minf(8.0 + float(event.amount) * 3.0, 26.0), 0.32)
	if not on_player:
		var target_view: CardView = view_for(event.other)
		if target_view != null:
			var flash: Tween = create_tween()
			flash.tween_property(target_view, "modulate", Color(1.6, 0.6, 0.6), 0.06)
			flash.tween_property(target_view, "modulate", Color.WHITE, 0.2)
		_refresh_view(event.other)
	await _wait(0.28)


func _on_life(event: GameEvent) -> void:
	if event.amount > 0:
		Audio.sfx(&"heal")
		fx.floating_text(portrait_anchor[event.player], "+%d" % event.amount, Color("7be08a"), 48)
		fx.burst(portrait_anchor[event.player], Color("7be08a"), 14, 200.0)
	elif event.sequence != _last_damage_seq + 1 and event.amount < 0:
		fx.floating_text(portrait_anchor[event.player], "%d" % event.amount, Color("ff6a5a"), 48)
		Audio.sfx(&"hit_light")


func _on_died(event: GameEvent) -> void:
	var view: CardView = view_for(event.card)
	if view == null:
		return
	views.erase(event.card)
	zones.erase(event.card)
	order.erase(event.card)
	Audio.sfx(&"death")
	var color: Color = UIStyle.affinity_color(view.data.color) if view.data != null else Color.WHITE
	fx.dissolve(view, color, 0.6)
	layout()
	await _wait(0.4)


func _on_returned(event: GameEvent) -> void:
	if not views.has(event.card):
		ensure_view(event.card, Zone.BATTLEFIELD, event.player)
	set_zone(event.card, Zone.HAND)
	Audio.sfx(&"card_draw", -4.0)
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
	Audio.sfx(&"card_discard")
	fx.dissolve(view, UIStyle.affinity_color(view.data.color) if view.data != null else Color.WHITE, 0.45)
	layout()
	await _wait(0.25)


# ---- Highlights -------------------------------------------------------------------------


## `glows` maps card uid -> CardView.Glow. Cards not listed lose their glow.
func set_glows(glows: Dictionary) -> void:
	for uid: int in views.keys():
		var view: CardView = views[uid] as CardView
		view.set_glow(int(glows.get(uid, CardView.Glow.NONE)) as CardView.Glow)
