class_name TexFit
extends RefCounted
## Size pass Nov 3, Part 3: how large is each 2D texture actually drawn? `report(root, out_path)` walks every CanvasItem that draws a
## texture (TextureRect, Sprite2D, TextureButton, NinePatchRect, Button icons) and appends one line per texture to `out_path`:
##   texfit: <resource path or node name> native=WxH drawn=WxH ratio=<drawn max side / native max side> node=<node path>
## Sizes are design pixels (the 1920x1080 canvas; the window stretches canvas_items, so 1440p draws everything x1.333).
## Used by tools/screenshot.gd --texfit=true and summed up per folder by tools/texfit_report.js (the size_limit per folder).


static func report(root: Node, out_path: String, label: String) -> int:
	var lines: PackedStringArray = []
	_walk(root, lines)
	var file: FileAccess = FileAccess.open(out_path, FileAccess.READ_WRITE if FileAccess.file_exists(out_path) else FileAccess.WRITE)
	if file == null:
		push_error("texfit: cannot write %s" % out_path)
		return 0
	file.seek_end()
	for line: String in lines:
		file.store_line("%s screen=%s" % [line, label])
	file.close()
	return lines.size()


static func _walk(node: Node, lines: PackedStringArray) -> void:
	if node is CanvasItem and not (node as CanvasItem).is_visible_in_tree():
		return
	if node is TextureRect:
		var rect: TextureRect = node as TextureRect
		if rect.texture != null:
			var native: Vector2 = rect.texture.get_size()
			var drawn: Vector2 = _texture_rect_drawn(rect, native)
			lines.append(_line(rect.texture, native, drawn, rect))
	elif node is Sprite2D:
		var sprite: Sprite2D = node as Sprite2D
		if sprite.texture != null:
			var native: Vector2 = sprite.texture.get_size()
			if sprite.region_enabled:
				native = sprite.region_rect.size
			var scale: Vector2 = sprite.get_global_transform().get_scale()
			lines.append(_line(sprite.texture, native, Vector2(native.x * absf(scale.x) / float(maxi(sprite.hframes, 1)), native.y * absf(scale.y) / float(maxi(sprite.vframes, 1))), sprite))
	elif node is TextureButton:
		var button: TextureButton = node as TextureButton
		if button.texture_normal != null:
			var native: Vector2 = button.texture_normal.get_size()
			var drawn: Vector2 = button.get_global_rect().size if not button.ignore_texture_size or button.stretch_mode != TextureButton.STRETCH_KEEP else native
			lines.append(_line(button.texture_normal, native, drawn, button))
	elif node is NinePatchRect:
		var patch: NinePatchRect = node as NinePatchRect
		if patch.texture != null:
			# a nine-patch stretches its middle: the corners draw at native size, so the texture is "drawn" at its own scale
			lines.append(_line(patch.texture, patch.texture.get_size(), patch.texture.get_size(), patch))
	elif node is Button:
		var b: Button = node as Button
		if b.icon != null:
			var native: Vector2 = b.icon.get_size()
			var drawn: Vector2 = native
			var icon_max: int = b.get_theme_constant("icon_max_width")
			if b.expand_icon:
				drawn = Vector2(b.get_global_rect().size.y, b.get_global_rect().size.y)
			elif icon_max > 0 and native.x > float(icon_max):
				drawn = native * (float(icon_max) / native.x)
			lines.append(_line(b.icon, native, drawn, b))
	for child: Node in node.get_children():
		_walk(child, lines)


static func _texture_rect_drawn(rect: TextureRect, native: Vector2) -> Vector2:
	var size: Vector2 = rect.get_global_rect().size
	match rect.stretch_mode:
		TextureRect.STRETCH_KEEP, TextureRect.STRETCH_KEEP_CENTERED, TextureRect.STRETCH_TILE:
			return native
		TextureRect.STRETCH_KEEP_ASPECT, TextureRect.STRETCH_KEEP_ASPECT_CENTERED:
			if native.x <= 0.0 or native.y <= 0.0:
				return size
			var s: float = minf(size.x / native.x, size.y / native.y)
			return native * s
		TextureRect.STRETCH_KEEP_ASPECT_COVERED:
			if native.x <= 0.0 or native.y <= 0.0:
				return size
			var s: float = maxf(size.x / native.x, size.y / native.y)
			return native * s
		_:
			return size


static func _line(texture: Texture2D, native: Vector2, drawn: Vector2, node: Node) -> String:
	var name: String = texture.resource_path
	if name.is_empty() and texture is AtlasTexture and (texture as AtlasTexture).atlas != null:
		name = (texture as AtlasTexture).atlas.resource_path + "#atlas"
	if name.is_empty():
		name = "(runtime)%s" % (texture.resource_name if not texture.resource_name.is_empty() else "@" + node.name)
	var ratio: float = 0.0
	if maxf(native.x, native.y) > 0.0:
		ratio = maxf(drawn.x, drawn.y) / maxf(native.x, native.y)
	return "texfit: %s native=%dx%d drawn=%dx%d ratio=%.3f node=%s" % [name, int(native.x), int(native.y), int(round(drawn.x)), int(round(drawn.y)), ratio, str(node.get_path()).replace("/root/", "")]
