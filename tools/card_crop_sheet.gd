extends SceneTree
## UI + economy fixes Oct 22, Part 3: contact sheets of every card's art crop (cards and tokens) at each display size, to find heads and
## faces the crop cuts. Run NOT headless (it draws real CardViews):
##   Godot --path . --resolution 1920x1080 -s res://tools/card_crop_sheet.gd -- [--kinds=field,card,slot] [--only=R-22,G-23,T-06] [--tag=after]
## or `bash tools/card_crop_sheet.sh`. Pages go to docs/art/card_crops/<tag>/<kind>_<page>.jpg; each cell is labelled with the card id.
## Kinds: field = the battlefield card (COMPACT, at its battle size x0.56 - also the token tray), card = a full card (hand, collection, vendor, rewards),
## slot = a Deck Station slot filled by the card as its deck's cover.

const PAGE: Vector2 = Vector2(1920, 1080)
## CardView and DeckRack are loaded at run time, never named here: they need the autoloads, which do not exist yet while a SceneTree
## script compiles. CardView.SIZE and its Mode values are mirrored.
const CARD_SIZE: Vector2 = Vector2(300, 450)
const MODE_FULL: int = 0
const MODE_COMPACT: int = 1
const KINDS: Dictionary = {
	"field": {"scale": 0.56, "mode": MODE_COMPACT},
	"card": {"scale": 0.4, "mode": MODE_FULL},
	"slot": {"size": Vector2(150, 190)},
}
const LABEL_H: float = 22.0
const GAP: float = 8.0

var _args: Dictionary = {}
var _ids: Array[String] = []
var _kinds: Array[String] = []
var _kind_index: int = 0
var _page: int = 0
var _frames: int = 0
var _canvas: Control
var _tag: String = "sheet"


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			_args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	_tag = str(_args.get("tag", "sheet"))
	for kind: String in str(_args.get("kinds", "field,card,slot")).split(",", false):
		_kinds.append(kind)
	root.size = Vector2i(PAGE)


func _process(_delta: float) -> bool:
	if _ids.is_empty():
		var session: Node = root.get_node_or_null("Session")
		if session != null:
			session.set("save_enabled", false)
		_ids = _all_ids()
		_build_page()
		return false
	_frames += 1
	if _frames < 6:
		return false
	_save_page()
	_frames = 0
	_page += 1
	if _page * _per_page() >= _ids.size():
		_page = 0
		_kind_index += 1
		if _kind_index >= _kinds.size():
			print("card_crop_sheet: done")
			quit(0)
			return true
	_build_page()
	return false


func _all_ids() -> Array[String]:
	var only: String = str(_args.get("only", ""))
	var result: Array[String] = []
	if only != "":
		for id: String in only.split(",", false):
			result.append(id)
		return result
	for dir: String in ["res://data/cards/", "res://data/tokens/"]:
		for file: String in DirAccess.get_files_at(dir):
			if file.ends_with(".tres"):
				result.append(file.get_basename())
	result.sort()
	return result


func _card(id: String) -> CardData:
	var path: String = "res://data/%s/%s.tres" % ["tokens" if id.begins_with("T-") else "cards", id]
	return load(path) as CardData if ResourceLoader.exists(path) else null


func _cell_size() -> Vector2:
	var spec: Dictionary = KINDS[_kinds[_kind_index]] as Dictionary
	var picture: Vector2 = spec["size"] as Vector2 if spec.has("size") else CARD_SIZE * float(spec["scale"])
	return picture + Vector2(GAP, GAP + LABEL_H)


func _columns() -> int:
	return int((PAGE.x - GAP) / _cell_size().x)


func _per_page() -> int:
	return _columns() * int((PAGE.y - GAP) / _cell_size().y)


func _build_page() -> void:
	if _canvas != null:
		_canvas.queue_free()
	_canvas = Control.new()
	_canvas.size = PAGE
	root.add_child(_canvas)
	var back: ColorRect = ColorRect.new()
	back.color = Color(0.12, 0.1, 0.14)
	back.size = PAGE
	_canvas.add_child(back)
	var kind: String = _kinds[_kind_index]
	var spec: Dictionary = KINDS[kind] as Dictionary
	var cell: Vector2 = _cell_size()
	var start: int = _page * _per_page()
	for index: int in range(start, mini(start + _per_page(), _ids.size())):
		var card: CardData = _card(_ids[index])
		if card == null:
			continue
		var slot: int = index - start
		var origin: Vector2 = Vector2(GAP + (slot % _columns()) * cell.x, GAP + int(slot / _columns()) * cell.y)
		var holder: Control = Control.new()
		holder.position = origin
		_canvas.add_child(holder)
		if kind == "slot":
			var rack: GDScript = load("res://ui/widgets/deck_rack.gd") as GDScript
			var tile: Control = rack.call("cover_tile", card, spec["size"] as Vector2, card.display_name, [] as Array[Affinity.Type], false)
			holder.add_child(tile)
		else:
			var card_view: GDScript = load("res://ui/card/card_view.gd") as GDScript
			var view: Control = card_view.call("create", card, int(spec["mode"])) as Control
			holder.add_child(view)
			card_view.call("fit", view, float(spec["scale"]))
		var label: Label = Label.new()
		label.text = "%s %s" % [card.id, card.display_name]
		label.clip_text = true
		label.add_theme_font_size_override("font_size", 13)
		label.position = origin + Vector2(0, cell.y - GAP - LABEL_H)
		label.size = Vector2(cell.x - GAP, LABEL_H)
		_canvas.add_child(label)


func _save_page() -> void:
	var folder: String = "res://docs/art/card_crops/%s" % _tag
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var image: Image = root.get_texture().get_image()
	var path: String = "%s/%s_%d.jpg" % [folder, _kinds[_kind_index], _page + 1]
	image.save_jpg(ProjectSettings.globalize_path(path), 0.82)
	print("card_crop_sheet: saved %s" % path)
