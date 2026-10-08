extends SceneTree
## Story v2 Part H: draws the PLACEHOLDER painted map (MAP-LAB, 3:2) and battleboard (BB-LAB, 16:9) of the Path-ology Lab so the dungeon is playable until the art
## pipeline delivers the real images under the same IDs. Run from the project root:  Godot --headless --path . -s res://tools/make_lab_placeholder_art.gd
## Output: assets/art/maps/MAP-LAB.webp and assets/art/battleboards/BB-LAB.webp (then re-import).

const MAP_SIZE: Vector2i = Vector2i(1536, 1024)
const BOARD_SIZE: Vector2i = Vector2i(1536, 864)
const TANK_COLORS: Array[Color] = [Color("e2553f"), Color("f2c14e"), Color("7bc86c"), Color("a870d8")]


func _init() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/art/maps"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://assets/art/battleboards"))
	_draw_map().save_webp(ProjectSettings.globalize_path("res://assets/art/maps/MAP-LAB.webp"), true, 0.9)
	_draw_board().save_webp(ProjectSettings.globalize_path("res://assets/art/battleboards/BB-LAB.webp"), true, 0.9)
	print("placeholder lab art written")
	quit()


func _draw_map() -> Image:
	var image: Image = Image.create(MAP_SIZE.x, MAP_SIZE.y, false, Image.FORMAT_RGB8)
	for y: int in range(MAP_SIZE.y):
		var t: float = float(y) / float(MAP_SIZE.y)
		var base: Color = Color("1f3a40").lerp(Color("0f1c24"), t)
		for x: int in range(MAP_SIZE.x):
			var color: Color = base
			# Sterile white tile grid, cracked and dim.
			if x % 64 < 3 or y % 64 < 3:
				color = color.lightened(0.16)
			image.set_pixel(x, y, color)
	var nodes: Array = _node_positions()
	# Corridors between the nodes.
	for pair: Array in _links():
		var a: Vector2 = nodes[int(pair[0]) - 1] as Vector2
		var b: Vector2 = nodes[int(pair[1]) - 1] as Vector2
		_line(image, a, b, 26, Color("cfe3e3").darkened(0.25))
	# Four glowing tanks along the top edge.
	for index: int in range(TANK_COLORS.size()):
		_disc(image, Vector2(260.0 + 330.0 * float(index), 70.0), 46, TANK_COLORS[index].darkened(0.1), 0.55)
	# A landing spot under every node.
	for point: Vector2 in nodes:
		_disc(image, point, 44, Color("e8f4f4"), 0.5)
		_disc(image, point, 30, Color("0f1c24"), 0.35)
	return image


func _draw_board() -> Image:
	var image: Image = Image.create(BOARD_SIZE.x, BOARD_SIZE.y, false, Image.FORMAT_RGB8)
	for y: int in range(BOARD_SIZE.y):
		var t: float = float(y) / float(BOARD_SIZE.y)
		var base: Color = Color("16282e").lerp(Color("3c5a62"), t)
		for x: int in range(BOARD_SIZE.x):
			var color: Color = base
			if x % 96 < 3 or y % 96 < 3:
				color = color.lightened(0.12)
			image.set_pixel(x, y, color)
	for index: int in range(TANK_COLORS.size()):
		_disc(image, Vector2(190.0 + 385.0 * float(index), 60.0), 150, TANK_COLORS[index], 0.2)
	return image


## Node positions (pixels) from the blueprint's CSV percentages.
func _node_positions() -> Array:
	var result: Array = []
	var plan: Dictionary = (JSON.parse_string(FileAccess.get_file_as_string("res://data/dungeons/postgame_dungeons.json")) as Array)[0] as Dictionary
	for entry: Variant in plan["nodes"] as Array:
		var node: Dictionary = entry as Dictionary
		result.append(Vector2(float(node["x"]) / 100.0 * float(MAP_SIZE.x), float(node["y"]) / 100.0 * float(MAP_SIZE.y)))
	return result


func _links() -> Array:
	var result: Array = []
	var plan: Dictionary = (JSON.parse_string(FileAccess.get_file_as_string("res://data/dungeons/postgame_dungeons.json")) as Array)[0] as Dictionary
	for entry: Variant in plan["nodes"] as Array:
		var node: Dictionary = entry as Dictionary
		for target: Variant in node["next"] as Array:
			result.append([int(node["n"]), int(target)])
	return result


func _disc(image: Image, center: Vector2, radius: int, color: Color, strength: float) -> void:
	for y: int in range(maxi(0, int(center.y) - radius), mini(image.get_height(), int(center.y) + radius + 1)):
		for x: int in range(maxi(0, int(center.x) - radius), mini(image.get_width(), int(center.x) + radius + 1)):
			var distance: float = Vector2(float(x), float(y)).distance_to(center)
			if distance <= float(radius):
				var falloff: float = 1.0 - distance / float(radius)
				image.set_pixel(x, y, image.get_pixel(x, y).lerp(color, strength * clampf(falloff * 2.0, 0.0, 1.0)))


func _line(image: Image, from: Vector2, to: Vector2, width: int, color: Color) -> void:
	var length: float = from.distance_to(to)
	var steps: int = int(length / 6.0)
	for step: int in range(steps + 1):
		var point: Vector2 = from.lerp(to, float(step) / float(maxi(steps, 1)))
		_disc(image, point, width / 2, color, 0.8)
