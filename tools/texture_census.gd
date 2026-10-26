extends SceneTree
## Performance pass Oct 25, Part 4: what fills the video memory in one area. Run NOT headless, alone:
## Godot --path . -s res://tools/texture_census.gd -- --scene=res://scenes/town.tscn [--quality=1] [--open=deck] [--top=40] [--wait=6]
## After the wait, lists every texture the scene references (materials, sprites, decals, controls): totals per folder and per format, and the
## biggest single textures with their size and format. Generated textures (no path) are grouped as "(generated)".

var _args: Dictionary = {}
var _scene: Node
var _elapsed: float = 0.0
var _started: bool = false


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--"):
			var parts: PackedStringArray = arg.substr(2).split("=", true, 1)
			_args[parts[0]] = parts[1] if parts.size() > 1 else "true"
	root.size = Vector2i(1600, 900)
	DisplayServer.window_set_size(Vector2i(1600, 900))


func _process(delta: float) -> bool:
	if not _started:
		_started = true
		root.get_node("Session").set("save_enabled", false)
		root.get_node("Settings").set("graphics_quality", int(_args.get("quality", 1)))
		_scene = (load(str(_args.get("scene", "res://scenes/town.tscn"))) as PackedScene).instantiate()
		if _scene.has_method("screenshot_prepare"):
			_scene.call("screenshot_prepare", _args)
		root.add_child(_scene)
		return false
	_elapsed += delta
	if _elapsed < float(_args.get("wait", 6.0)):
		return false
	_report()
	quit(0)
	return true


static func folder_of(path: String) -> String:
	if path.is_empty():
		return "(generated)"
	var clean: String = path.replace("res://", "")
	var parts: PackedStringArray = clean.split("/")
	var depth: int = 3 if clean.begins_with("assets/art/") else 2
	return "/".join(parts.slice(0, mini(depth, parts.size() - 1)))


func _report() -> void:
	var usage: Array = _collect_textures()
	var by_folder: Dictionary = {}
	var by_format: Dictionary = {}
	var total: int = 0
	usage.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a["bytes"]) > int(b["bytes"]))
	for entry: Dictionary in usage:
		var bytes: int = int(entry["bytes"])
		total += bytes
		var folder: String = folder_of(str(entry["path"]))
		var fmt: String = _format_name(int(entry["format"]))
		by_folder[folder] = int(by_folder.get(folder, 0)) + bytes
		by_format[fmt] = int(by_format.get(fmt, 0)) + bytes
	print("texture_census: %s quality %s: %d textures used by the scene, about %.1f MB (renderer total %.0f MB)" % [_args.get("scene"), _args.get("quality", 1), usage.size(), float(total) / 1048576.0, Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED) / 1048576.0])
	for table: Array in [["folder", by_folder], ["format", by_format]]:
		var dict: Dictionary = table[1]
		var keys: Array = dict.keys()
		keys.sort_custom(func(a: Variant, b: Variant) -> bool: return int(dict[a]) > int(dict[b]))
		for key: Variant in keys:
			if int(dict[key]) < 262144:
				continue
			print("texture_census:   by %s  %7.1f MB  %s" % [table[0], float(dict[key]) / 1048576.0, key])
	_cache_report()
	var top: int = int(_args.get("top", 40))
	for index: int in range(mini(top, usage.size())):
		var entry: Dictionary = usage[index]
		print("texture_census:   %6.2f MB  %4dx%-4d %-6s %s" % [float(entry["bytes"]) / 1048576.0, int(entry["width"]), int(entry["height"]), _format_name(int(entry["format"])), str(entry["path"])])


## The session-long art caches (outside the scene tree): textures held and their size.
func _cache_report() -> void:
	var caches: Dictionary = {"UiArt": UiArt._textures, "KeyArt": KeyArt._textures, "IconArt": IconArt._textures, "CardArt": CardArt._cache,
		"CardArt thumbs": CardArt._thumbs, "SpriteLibrary": SpriteLibrary._textures, "Portraits": Portraits._textures, "PaintedLibrary": PaintedLibrary._textures}
	for cache_name: String in caches.keys():
		var dict: Dictionary = caches[cache_name]
		var bytes: int = 0
		var count: int = 0
		var biggest: Array = []
		for value: Variant in dict.values():
			if value is Texture2D:
				var tex: Texture2D = value as Texture2D
				var size: int = int(float(tex.get_width() * tex.get_height()) * _bytes_per_pixel(RenderingServer.texture_get_format(tex.get_rid()) if tex.get_rid().is_valid() else -1))
				bytes += size
				count += 1
				biggest.append([size, tex.resource_path])
		biggest.sort_custom(func(a: Array, b: Array) -> bool: return int(a[0]) > int(b[0]))
		var names: PackedStringArray = []
		for i: int in range(mini(4, biggest.size())):
			names.append("%s %.1f" % [str(biggest[i][1]).get_file(), float(biggest[i][0]) / 1048576.0])
		print("texture_census:   cache %-15s %4d textures %7.1f MB  (%s)" % [cache_name, count, float(bytes) / 1048576.0, ", ".join(names)])


## Every Texture2D the scene tree references (materials of meshes and MultiMeshes, sprites, decals, controls), sized from its format.
## (Godot 4.7 has no RenderingServer.texture_debug_usage; art held only in static caches is not counted.)
func _collect_textures() -> Array:
	var seen: Dictionary = {}
	var objects: Array[Object] = []
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		for child: Node in node.get_children(true):
			stack.append(child)
		objects.append(node)
		if node is GeometryInstance3D:
			var geo: GeometryInstance3D = node as GeometryInstance3D
			objects.append(geo.material_override)
			objects.append(geo.material_overlay)
			var mesh: Mesh = null
			if node is MeshInstance3D:
				mesh = (node as MeshInstance3D).mesh
				for i: int in range((node as MeshInstance3D).get_surface_override_material_count()):
					objects.append((node as MeshInstance3D).get_surface_override_material(i))
			elif node is MultiMeshInstance3D and (node as MultiMeshInstance3D).multimesh != null:
				mesh = (node as MultiMeshInstance3D).multimesh.mesh
			if mesh != null:
				for i: int in range(mesh.get_surface_count()):
					objects.append(mesh.surface_get_material(i))
				if mesh is PrimitiveMesh:
					objects.append((mesh as PrimitiveMesh).material)
	var textures: Array[Texture2D] = []
	for obj: Object in objects:
		if obj == null:
			continue
		_textures_of(obj, textures, seen, 0)
	var result: Array = []
	for tex: Texture2D in textures:
		var rid: RID = tex.get_rid()
		var format: int = RenderingServer.texture_get_format(rid) if rid.is_valid() else -1
		var bpp: float = _bytes_per_pixel(format)
		var bytes: int = int(float(tex.get_width() * tex.get_height()) * bpp)
		result.append({"path": tex.resource_path, "width": tex.get_width(), "height": tex.get_height(), "format": format, "bytes": bytes})
	return result


func _textures_of(obj: Object, out: Array[Texture2D], seen: Dictionary, depth: int) -> void:
	if depth > 3 or seen.has(obj.get_instance_id()):
		return
	seen[obj.get_instance_id()] = true
	if obj is Texture2D:
		out.append(obj as Texture2D)
		return
	if obj is ShaderMaterial:
		var sm: ShaderMaterial = obj as ShaderMaterial
		if sm.shader != null:
			for uniform: Dictionary in sm.shader.get_shader_uniform_list():
				var value: Variant = sm.get_shader_parameter(str(uniform["name"]))
				if value is Object and value != null:
					_textures_of(value as Object, out, seen, depth + 1)
		if sm.next_pass != null:
			_textures_of(sm.next_pass, out, seen, depth + 1)
		return
	if obj is Node and not (obj is Sprite3D or obj is Decal or obj is TextureRect or obj is NinePatchRect or obj is Sprite2D or obj is TextureButton):
		return
	for prop: Dictionary in obj.get_property_list():
		if int(prop["type"]) != TYPE_OBJECT:
			continue
		var value: Variant = obj.get(str(prop["name"]))
		if value is Texture2D or value is Material:
			_textures_of(value as Object, out, seen, depth + 1)


static func _bytes_per_pixel(format: int) -> float:
	match format:
		Image.FORMAT_BPTC_RGBA, Image.FORMAT_DXT5, Image.FORMAT_RGTC_RG:
			return 1.0
		Image.FORMAT_DXT1, Image.FORMAT_RGTC_R:
			return 0.5
		Image.FORMAT_RGBA8:
			return 4.0
		Image.FORMAT_RGB8:
			return 4.0  # padded to RGBA on the GPU
		Image.FORMAT_L8, Image.FORMAT_R8:
			return 1.0
		Image.FORMAT_LA8, Image.FORMAT_RG8:
			return 2.0
		Image.FORMAT_RGBAH:
			return 8.0
		Image.FORMAT_RGBAF:
			return 16.0
		Image.FORMAT_RH:
			return 2.0
		Image.FORMAT_RF:
			return 4.0
	return 4.0


static func _format_name(format: int) -> String:
	match format:
		Image.FORMAT_RGBA8:
			return "RGBA8"
		Image.FORMAT_RGB8:
			return "RGB8"
		Image.FORMAT_BPTC_RGBA:
			return "BC7"
		Image.FORMAT_DXT1:
			return "BC1"
		Image.FORMAT_DXT5:
			return "BC3"
		Image.FORMAT_RGTC_RG:
			return "BC5"
		Image.FORMAT_L8:
			return "L8"
		Image.FORMAT_LA8:
			return "LA8"
		Image.FORMAT_RGBAH:
			return "RGBAH"
		Image.FORMAT_RGBAF:
			return "RGBAF"
		Image.FORMAT_RF:
			return "RF"
		Image.FORMAT_RH:
			return "RH"
		Image.FORMAT_R8:
			return "R8"
	return "fmt%d" % format
