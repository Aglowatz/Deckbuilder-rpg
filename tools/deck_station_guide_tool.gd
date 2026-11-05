extends RefCounted
## Fix pass Nov 4 (B), Part F: the Deck Station layout guide for the new background art. Opens the real Deck Station at the window size, takes a
## screenshot, outlines the ten deck slot frames in bright magenta and shades the card grid and the Your Deck panel, and saves it to
## docs/art/paintover_inputs/deck_station_slots_guide.png. Windowed (needs a renderer):
##   Godot --path . --resolution 1600x900 -s res://tools/deck_station_guide.gd
## Loaded by tools/deck_station_guide.gd after the first frame (the autoloads must exist before the screens compile).

const OUT: String = "res://docs/art/paintover_inputs/deck_station_slots_guide.png"


var root: Window
var tree: SceneTree


func run(scene_tree: SceneTree) -> void:
	tree = scene_tree
	root = scene_tree.root
	var session: Node = root.get_node("/root/Session")
	session.set("save_enabled", false)
	session.call("new_game")
	session.call("ensure_game", Affinity.Type.BEEFCAKE)
	var screen_script: GDScript = load("res://ui/town/deckbuilder_screen.gd") as GDScript
	var screen: Control = screen_script.new() as Control
	root.add_child(screen)
	for i: int in range(40):
		await tree.process_frame
	# hide the once-ever tip and any toast layers so the grid and the racks show
	for node: Node in screen.find_children("*", "Control", true, false):
		var script: Script = node.get_script() as Script
		if script != null and script.get_global_name() == &"TipPanel":
			(node as Control).visible = false
	for layer: Node in root.find_children("*", "CanvasLayer", true, false):
		if not layer.is_ancestor_of(screen):
			(layer as CanvasLayer).visible = false
	for i: int in range(10):
		await tree.process_frame
	var image: Image = root.get_texture().get_image()
	var factor: Vector2 = Vector2(image.get_width(), image.get_height()) / root.get_visible_rect().size
	var shade: Color = Color(0.0, 0.9, 1.0, 0.28)
	for node_name: String in ["_grid_scroll", "_deck_panel"]:
		var control: Control = screen.get(node_name) as Control
		if control != null:
			_fill(image, Rect2(control.get_global_rect().position * factor, control.get_global_rect().size * factor), shade)
	var view: Vector2 = screen.size
	var screen_scale: Vector2 = screen.scale
	for slot: int in range(DeckSlots.SLOT_COUNT):
		var cell: Rect2 = DeckRack.cell_rect(slot, view)
		var rect: Rect2 = Rect2((screen.global_position + cell.position * screen_scale) * factor, cell.size * screen_scale * factor)
		_outline(image, rect, Color(1.0, 0.0, 1.0), 4)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://docs/art/paintover_inputs"))
	image.save_png(OUT)
	print("deck_station_guide: wrote %s (%dx%d)" % [OUT, image.get_width(), image.get_height()])


static func _fill(image: Image, rect: Rect2, color: Color) -> void:
	var area: Rect2i = Rect2i(rect).intersection(Rect2i(0, 0, image.get_width(), image.get_height()))
	for y: int in range(area.position.y, area.end.y):
		for x: int in range(area.position.x, area.end.x):
			image.set_pixel(x, y, image.get_pixel(x, y).blend(color))


static func _outline(image: Image, rect: Rect2, color: Color, width: int) -> void:
	var r: Rect2i = Rect2i(rect)
	for k: int in range(width):
		image.fill_rect(Rect2i(r.position.x, r.position.y + k, r.size.x, 1), color)
		image.fill_rect(Rect2i(r.position.x, r.end.y - 1 - k, r.size.x, 1), color)
		image.fill_rect(Rect2i(r.position.x + k, r.position.y, 1, r.size.y), color)
		image.fill_rect(Rect2i(r.end.x - 1 - k, r.position.y, 1, r.size.y), color)
