class_name SealTooltips
extends Control
## Fable Nov 16c (Part 1, the owner's answer to inbox 19): what the Four Seals say about themselves. The mouse over a seal shows that
## seal's line ("Gourmand seal: locked"); the hero standing at the cellar door (keyboard or controller: no mouse needed) shows all four
## lines in the fixed Path order above the door. Screen UI, never lettering in the world.

## The mouse counts as over a seal within this many pixels of it (at 1080p).
const HOVER_PIXELS: float = 30.0
## The hero stands this close (metres) to the foot of the doors and all four lines show.
const NEAR_METRES: float = 3.4

var vault: Node3D
var hero: Node3D
var blocked: Callable = Callable()
var _panel: PanelContainer
var _label: Label
## What is shown right now: "" (nothing), "all", or a zone id (tests).
var showing: String = ""


static func install(host: Node, vault_root: Node3D, hero_node: Node3D, is_blocked: Callable = Callable()) -> SealTooltips:
	var layer: CanvasLayer = CanvasLayer.new()
	layer.name = "SealTooltipLayer"
	layer.layer = 4
	host.add_child(layer)
	var tips: SealTooltips = SealTooltips.new()
	tips.name = "SealTooltips"
	tips.vault = vault_root
	tips.hero = hero_node
	tips.blocked = is_blocked
	layer.add_child(tips)
	return tips


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# After the look rig: `WorldLookRig` re-aims the camera in its own _process, and a point projected before that lands
	# well off the picture (about 170 px at the default camera).
	process_priority = 1000
	_panel = PanelContainer.new()
	_panel.name = "Tip"
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var box: StyleBoxFlat = UIStyle.box(Color(0.07, 0.05, 0.1, 0.9), UIStyle.GOLD_DIM, 2, 8)
	box.content_margin_left = 12.0
	box.content_margin_right = 12.0
	box.content_margin_top = 6.0
	box.content_margin_bottom = 6.0
	_panel.add_theme_stylebox_override("panel", box)
	_panel.visible = false
	add_child(_panel)
	_label = UIKit.label("", &"", 20, UIStyle.PARCHMENT)
	_label.name = "Text"
	_panel.add_child(_label)


## The four lines, in the fixed Path order.
static func all_lines() -> String:
	var lines: PackedStringArray = []
	for zone_id: String in VaultGuardian.ZONE_IDS:
		lines.append(FourSealVault.tooltip(zone_id))
	return "\n".join(lines)


## The seal under `screen_point`, or "".
func seal_at(camera: Camera3D, screen_point: Vector2) -> String:
	if vault == null or camera == null:
		return ""
	var reach: float = HOVER_PIXELS * maxf(get_viewport_rect().size.y / 1080.0, 0.5)
	var best: String = ""
	var best_distance: float = reach
	for zone_id: String in VaultGuardian.ZONE_IDS:
		var seal: Node3D = vault.find_child(FourSealVault.SEAL_PREFIX + zone_id, true, false) as Node3D
		if seal == null or camera.is_position_behind(seal.global_position):
			continue
		var distance: float = camera.unproject_position(seal.global_position).distance_to(screen_point)
		if distance < best_distance:
			best_distance = distance
			best = zone_id
	return best


func _process(_delta: float) -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	if vault == null or not is_instance_valid(vault) or camera == null or (blocked.is_valid() and bool(blocked.call())):
		_show("", Vector2.ZERO, "")
		return
	var mouse: Vector2 = get_viewport().get_mouse_position()
	var hovered: String = seal_at(camera, mouse) if not InputDevice.using_pad() else ""
	if not hovered.is_empty():
		_show(FourSealVault.tooltip(hovered), mouse + Vector2(18, -34), hovered)
		return
	if hero != null and Vector2(hero.global_position.x - vault.global_position.x, hero.global_position.z - vault.global_position.z).length() <= NEAR_METRES:
		# Above the top seal (the doors' own height on screen changes with the camera preset).
		var top_seal: Node3D = vault.find_child(FourSealVault.SEAL_PREFIX + VaultGuardian.ZONE_IDS[0], true, false) as Node3D
		var top: Vector3 = top_seal.global_position if top_seal != null else vault.global_position + Vector3(0.0, FourSealVault.DOOR_HEIGHT, 0.0)
		if not camera.is_position_behind(top):
			_panel.reset_size()
			_show(all_lines(), camera.unproject_position(top) - Vector2(_panel.size.x * 0.5, _panel.size.y + 44.0), "all")
			return
	_show("", Vector2.ZERO, "")


func _show(text: String, at: Vector2, what: String) -> void:
	showing = what
	_panel.visible = not text.is_empty()
	if text.is_empty():
		return
	if _label.text != text:
		_label.text = text
		_panel.reset_size()
	var area: Vector2 = get_viewport_rect().size
	_panel.position = Vector2(clampf(at.x, 8.0, maxf(area.x - _panel.size.x - 8.0, 8.0)), clampf(at.y, 8.0, maxf(area.y - _panel.size.y - 8.0, 8.0)))
