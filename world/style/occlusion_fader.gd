class_name OcclusionFader
extends Node
## What may go see-through for the camera, and how (Fable Nov 19, Part 1: "what looks solid must stay visible").
##
## One system, four types (`type_of`; a mesh or any of its parents may name its own with the meta `fade_type`):
##   tall_occluder  a building, a tall wall, a big tree, a column: the ONLY type that ever goes see-through, and only while it
##                  really hides the hero (two of the three sight lines lens -> head / chest / hips pass through it).
##   low_blocker    anything lower than the hero's shoulder (counters, desks, fences, hedges, rails, rocks, crates): never fades.
##   small_prop     lamps, posts, plants, banners, barrels (under a metre across, or named so): never fades.
##   sign           signs and signposts: never fade.
##
## A tall occluder that hides the hero is never faded as a whole. Only a soft circle round the hero goes see-through, in the shader
## (`style_occlusion.gdshaderinc`, the instance uniform `occlusion_fade` is the mesh's eased share): the part of it nearer the lens
## than the hero, kept at WINDOW_KEEP of its surface, never nothing; its roof, its far side and its foot (the lowest FOOT metres) stay
## solid, so the place it blocks still reads. The hero's own outline is drawn through whatever is left (`hero_hidden` drives
## WorldSprite.set_silhouette in the Path colour).
##
## The one exception is a piece the LENS itself is inside (the camera trails 17 m behind the hero and passes through houses): nothing
## of it can be drawn, so it is cut away and a soft outline of its footprint is laid on the ground instead (`_footprints`).
##
## Easing: EASE_TIME in and out; a thing that started to fade keeps fading until no sight line touches it for HOLD seconds (no flicker
## along an edge). Pure geometry: the sight lines are tested against each candidate's world box, cached at a scan every few seconds.

const SCAN_INTERVAL: float = 4.0
## Fable Nov 21 (Part 7.2): batched pieces open the round window in their own shaders (a field of tree cards in one MultiMesh, the
## D.N.A.'s cabinets in one merged mesh, a single tree card). The fader cannot fade them one by one, but it draws the hero's outline
## behind them as behind a building: their builders leave where each piece stands on the node, as (x, z, half width, top y) in the
## node's own space (`META_PIECES`), or mark a single card whose transform is the piece (`META_CARD`).
const META_PIECES: StringName = &"fade_pieces"
const META_CARD: StringName = &"fade_card"
## Kept for the scenes that still set them (the quest door, the person in reach): the window round the hero covers the person in
## reach; a far door is shown by its marker, and no longer hollows out the house in front of it.
static var focus_points: Array[Vector3] = []
static var talk_focus: Vector3 = Vector3.INF

const TALL_OCCLUDER: StringName = &"tall_occluder"
const LOW_BLOCKER: StringName = &"low_blocker"
const SMALL_PROP: StringName = &"small_prop"
const SIGN: StringName = &"sign"
const TYPES: Array[StringName] = [TALL_OCCLUDER, LOW_BLOCKER, SMALL_PROP, SIGN]
const RULES: Dictionary = {
	TALL_OCCLUDER: "a see-through window round the hero while it hides most of him; cut away only when the lens is inside it",
	LOW_BLOCKER: "never fades (lower than the hero's shoulder)",
	SMALL_PROP: "never fades (small: a lamp, a post, a plant, a banner)",
	SIGN: "never fades (a sign)",
}
## The hero's shoulder: nothing whose top is lower than this above its own foot (or above the hero's feet) ever fades.
const SHOULDER: float = 1.5
## Under this across (the wider side of its footprint) a thing is a small prop whatever its height: a lamp post, a pole, a sapling.
const SMALL_ACROSS: float = 1.0
## ... and a short thing this narrow is a small prop too (a barrel stack, a plant in a pot, a market crate pile).
const SMALL_SHORT_ACROSS: float = 2.0
const SMALL_SHORT_HEIGHT: float = 2.4
const NAMED_ACROSS: float = 3.6
const NAMED_HEIGHT: float = 6.5
const SIGN_WORDS: Array[String] = ["sign"]
const SMALL_WORDS: Array[String] = ["lamp", "lantern", "banner", "bunting", "pennant", "flag", "post", "plant", "bush", "flower", "barrel", "crate", "bench", "torch", "candle"]

const MIN_HEIGHT: float = 1.0
const MAX_EXTENT: float = 400.0
## The window: its radius in metres at the hero's depth, the share of the surface kept inside it, the height of the solid foot.
const WINDOW_RADIUS: float = 2.3
const WINDOW_KEEP: float = 0.36
const OUTLINE_IN_WINDOW: float = 0.4
const FOOT: float = 0.75
## A mesh whose material has no window (not a toon / painted shader) fades as a whole instead, to this transparency (55 % see-through).
const WHOLE_FADE: float = 0.55
## The lens is inside (or this close to) a tall piece: it is cut away.
const CUT_AWAY: float = 1.0
const CAMERA_PADDING: float = 0.7
## ... and a tall piece that hides the hero while it stands this close to the lens is cut away too (it would fill the screen).
const NEAR_LENS: float = 3.0
const EASE_TIME: float = 0.25
const HOLD: float = 0.2
## The five sight lines end at the hero's hips, chest and head, and at his two shoulders (SIGHT_SIDE to each side, across the view): a
## roof's corner that covers half of him counts, a post that crosses one line does not.
const SIGHT_HEIGHTS: Array[float] = [0.7, 1.15, 1.6, 1.2, 1.2]
const SIGHT_SIDE: float = 0.32
const LINES_TO_START: int = 2
const TALK_REACH: float = 3.0
const PADDING: float = 0.15
const MAX_GROUP_MESHES: int = 80
## Meshes looked at per frame while a scan is under way.
const SCAN_BATCH: int = 160
const TEST_INTERVAL: float = 0.06

var camera: Camera3D
var hero: Node3D
var root: Node
## 0..1: how much a tall occluder hides the hero right now (eased); his outline shows through it.
var hero_hidden: float = 0.0
## The colour of the hero's outline behind a wall: his Path's official colour, lightened (set by the scene; a warm white before a Path is chosen).
static var outline_color: Color = Color(1.0, 0.96, 0.86)

var _candidates: Array[MeshInstance3D] = []
## Per group key: the meshes that take the window together (the candidate plus its siblings under the same parent, without its low
## pieces and its signs).
var _members: Dictionary = {}
var _group_type: Dictionary = {}
var _group_box: Dictionary = {}
var _group_name: Dictionary = {}
## Per group key: the eased window share (0..1) and the eased cut (0..1).
var _fade: Dictionary = {}
var _cut_fade: Dictionary = {}
var _dither_cache: Dictionary = {}
var _scan_timer: float = 0.0
## Cached at each scan: the world box of every candidate that may block (tall pieces only), the group each belongs to.
var _boxes: Array[AABB] = []
var _box_keys: Array[int] = []
var _group_keys: Array[int] = []
var _pending: Array[Node] = []
var _pending_index: int = 0
var _next: Dictionary = {}
var _shadow_proxies: Dictionary = {}
var _test_timer: float = 0.0
var _blocking: Dictionary = {}
var _cut: Dictionary = {}
## Per group key: seconds since a sight line last touched it (hysteresis).
var _clear_for: Dictionary = {}
var _footprints: Dictionary = {}
var _silhouette_on: bool = false
## A tall thing crosses at least one sight line: the hero's outline shows through it even before (or without) a window.
var _touched: bool = false
## World (x, z, half width, top) of every batched piece found by the last scan, and whether one of them hides the hero now.
var _pieces: PackedFloat32Array = PackedFloat32Array()
var piece_cover: bool = false

static var _footprint_shader: Shader


func _ready() -> void:
	RenderingServer.global_shader_parameter_set(&"occlusion_window", Vector4(WINDOW_RADIUS, WINDOW_KEEP, FOOT, 0.0))


func _exit_tree() -> void:
	RenderingServer.global_shader_parameter_set(&"occlusion_hero", Vector3(0.0, -1000.0, 0.0))


func _process(delta: float) -> void:
	if OS.get_environment("OCCLUSION_OFF") != "":
		return
	if camera == null or hero == null or root == null:
		return
	if _pending_index < _pending.size():
		_scan_step()
	else:
		_scan_timer -= delta
		if _scan_timer <= 0.0:
			_scan_timer = SCAN_INTERVAL
			_scan()
	_test_timer -= delta
	if _test_timer <= 0.0:
		_run_tests(TEST_INTERVAL - _test_timer)
		_test_timer = TEST_INTERVAL
	RenderingServer.global_shader_parameter_set(&"occlusion_hero", hero.global_position)
	# The painted tree cards fade themselves in their shader from the hero's position (KitFoliage / kit_card.gdshader): a MultiMesh field cannot be faded per tree from here.
	KitFoliage.set_hero(hero.global_position)
	var step: float = delta / EASE_TIME
	var hidden_target: float = 1.0 if _touched else 0.0
	for key: int in _active_keys():
		var window_target: float = 1.0 if _blocking.has(key) and not _cut.has(key) else 0.0
		var cut_target: float = CUT_AWAY if _cut.has(key) else 0.0
		if _blocking.has(key) and not _cut.has(key):
			hidden_target = 1.0
		var window: float = float(_fade.get(key, 0.0))
		var cut: float = float(_cut_fade.get(key, 0.0))
		if absf(window - window_target) < 0.004 and absf(cut - cut_target) < 0.004:
			continue
		window = move_toward(window, window_target, step)
		cut = move_toward(cut, cut_target, step)
		_fade[key] = window
		_cut_fade[key] = cut
		for member: Variant in _members.get(key, []) as Array:
			if is_instance_valid(member):
				var piece: MeshInstance3D = member as MeshInstance3D
				# a piece that has shrunk under the shoulder since the scan (a root that grows and sinks) is a low blocker now
				if window > 0.0 and _piece_box(piece).size.y < SHOULDER:
					piece.set_instance_shader_parameter(&"occlusion_fade", 0.0)
					piece.transparency = 0.0
					continue
				if _dithers(piece):
					piece.set_instance_shader_parameter(&"occlusion_fade", window)
					piece.transparency = cut
				else:
					piece.transparency = maxf(cut, window * WHOLE_FADE)
				# A piece that is cut away stops casting its sun shadow too: the shadow of an invisible building read as a flat violet rectangle.
				_set_shadow_faded(piece, cut > 0.8)
		for proxy: Variant in _shadow_proxies.get(key, []) as Array:
			if is_instance_valid(proxy):
				_set_shadow_faded(proxy as MeshInstance3D, cut > 0.8)
		_set_footprint(key, cut)
	hero_hidden = move_toward(hero_hidden, hidden_target, step)
	_show_silhouette(hero_hidden > 0.02)


func _show_silhouette(shown: bool) -> void:
	if not shown and not _silhouette_on:
		return
	_silhouette_on = shown
	var sprite: Object = hero_sprite(hero)
	if sprite != null:
		# inside an open window the figure itself shows through the gaps, so the outline only fills them in lightly
		sprite.set("outline_tint", outline_color)
		sprite.call("set_hidden_outline", (hero_hidden * (OUTLINE_IN_WINDOW if not _blocking.is_empty() or piece_cover else 1.0)) if shown else 0.0)


## The painted card of a hero node (TownPlayer.model is a SpriteActor with `sprite`), or null for the 3D fallback.
static func hero_sprite(hero_node: Node) -> Object:
	if hero_node == null or not ("model" in hero_node):
		return null
	var model: Object = hero_node.get("model") as Object
	if model == null or not ("sprite" in model):
		return null
	var sprite: Object = model.get("sprite") as Object
	return sprite if sprite != null and sprite.has_method("set_hidden_outline") else null


func _set_shadow_faded(piece: MeshInstance3D, faded: bool) -> void:
	# A shadows-only proxy is hidden outright (turning its casting off would draw it as a plain box); a normal piece just stops casting.
	var proxy: bool = piece.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY or piece.has_meta(&"shadow_proxy_hidden")
	if faded:
		if proxy:
			if not piece.has_meta(&"shadow_proxy_hidden"):
				piece.set_meta(&"shadow_proxy_hidden", true)
				piece.visible = false
		elif not piece.has_meta(&"shadow_before_fade"):
			piece.set_meta(&"shadow_before_fade", piece.cast_shadow)
			piece.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	elif piece.has_meta(&"shadow_proxy_hidden"):
		piece.visible = true
		piece.remove_meta(&"shadow_proxy_hidden")
	elif piece.has_meta(&"shadow_before_fade"):
		piece.cast_shadow = int(piece.get_meta(&"shadow_before_fade")) as GeometryInstance3D.ShadowCastingSetting
		piece.remove_meta(&"shadow_before_fade")


## The soft outline a cut-away piece leaves on the ground (its footprint, so nobody tries to walk through the gap).
func _set_footprint(key: int, cut: float) -> void:
	var mark: MeshInstance3D = _footprints.get(key) as MeshInstance3D
	if cut <= 0.01:
		if mark != null and is_instance_valid(mark):
			mark.queue_free()
		_footprints.erase(key)
		return
	if mark == null or not is_instance_valid(mark):
		if not _group_box.has(key):
			return
		var box: AABB = _group_box[key] as AABB
		if _footprint_shader == null:
			_footprint_shader = Shader.new()
			_footprint_shader.code = FOOTPRINT_CODE
		var quad: PlaneMesh = PlaneMesh.new()
		quad.size = Vector2(box.size.x, box.size.z)
		var material: ShaderMaterial = ShaderMaterial.new()
		material.shader = _footprint_shader
		material.set_shader_parameter("size", quad.size)
		mark = MeshInstance3D.new()
		mark.name = "FadeFootprint"
		mark.mesh = quad
		mark.material_override = material
		mark.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		mark.set_meta(&"no_occlusion_fade", true)
		mark.set_meta(StyleToon.META_NO_TOON, true)
		mark.set_meta(PaintedClasses.META_NO_PAINT, true)
		add_child(mark)
		mark.global_position = Vector3(box.get_center().x, clampf(hero.global_position.y, box.position.y, box.position.y + 1.5) + 0.07, box.get_center().z)
		_footprints[key] = mark
	(mark.material_override as ShaderMaterial).set_shader_parameter("amount", cut)


const FOOTPRINT_CODE: String = """shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_disabled, shadows_disabled;
uniform vec2 size = vec2(4.0, 4.0);
uniform float amount = 1.0;
void fragment() {
	vec2 m = (0.5 - abs(UV - 0.5)) * size;
	float edge = min(m.x, m.y);
	float line = 1.0 - smoothstep(0.12, 0.34, edge);
	float soft = smoothstep(0.0, 0.1, edge);
	float hatch = step(0.5, fract((UV.x * size.x + UV.y * size.y) * 0.9)) * 0.1;
	ALBEDO = vec3(0.05, 0.05, 0.09);
	ALPHA = amount * soft * (line * 0.62 + 0.2 + hatch);
}
"""


func _group_key(mesh_instance: MeshInstance3D) -> int:
	var parent: Node = mesh_instance.get_parent()
	# A building (a parent with a modest number of pieces) takes the window as one; a chunk or a whole-map holder with hundreds of children does not.
	if parent != null and parent != root and parent is Node3D and parent != camera and parent.get_child_count() <= MAX_GROUP_MESHES:
		return parent.get_instance_id()
	return mesh_instance.get_instance_id()


## The type of a thing by its box and what it is called (`names`: its own and its parent's node names). An explicit `fade_type` wins.
static func type_of(size: Vector3, names: String = "", explicit: StringName = &"") -> StringName:
	if explicit != &"" and TYPES.has(explicit):
		return explicit
	var lower: String = names.to_lower()
	var across: float = maxf(size.x, size.z)
	# a name only counts for a thing of a prop's size: "Building_signwriter" is a house
	var prop_sized: bool = across < NAMED_ACROSS and size.y < NAMED_HEIGHT
	if prop_sized:
		for word: String in SIGN_WORDS:
			if lower.contains(word):
				return SIGN
	if size.y < SHOULDER:
		return LOW_BLOCKER
	if across < SMALL_ACROSS or (across < SMALL_SHORT_ACROSS and size.y < SMALL_SHORT_HEIGHT):
		return SMALL_PROP
	if prop_sized:
		for word: String in SMALL_WORDS:
			if lower.contains(word):
				return SMALL_PROP
	return TALL_OCCLUDER


## A mesh's explicit type: its own `fade_type` meta or the nearest parent's (up to the scene root).
func _explicit_type(mesh_instance: Node) -> StringName:
	var node: Node = mesh_instance
	for _level: int in range(4):
		if node == null or node == root:
			break
		if node.has_meta(&"fade_type"):
			return StringName(str(node.get_meta(&"fade_type")))
		node = node.get_parent()
	return &""


static func _names(mesh_instance: Node, top: Node) -> String:
	var text: String = str(mesh_instance.name)
	var parent: Node = mesh_instance.get_parent()
	if parent != null and parent != top:
		text += "/" + str(parent.name)
	return text


func _piece_box(piece: MeshInstance3D) -> AABB:
	var box: AABB = piece.global_transform * piece.get_aabb()
	# A piece may name the box that blocks the view (world space, meta `occlusion_box`) when its mesh box is much bigger than its
	# body - the Capital's walls carry towers and buttresses.
	if piece.has_meta(&"occlusion_box"):
		box = piece.get_meta(&"occlusion_box") as AABB
	# (the old `occlusion_shrink` is no longer used: a roof's eaves hide the hero as much as its walls do, and the window only opens round him)
	return box


func _piece_type(piece: MeshInstance3D) -> StringName:
	if piece.mesh == null:
		return SMALL_PROP
	return type_of(_piece_box(piece).size, _names(piece, root), _explicit_type(piece))


## Starts a scan of the tree for candidates. The work is spread over frames (SCAN_BATCH meshes each): a big zone has thousands of meshes and one frame of scanning was a
## visible hitch. The old candidate list keeps working until the new one is complete.
func _scan() -> void:
	var path: Affinity.Type = Session.profile.primary_affinity if Session.profile != null else Affinity.Type.NEUTRAL
	outline_color = Color(1.0, 0.96, 0.86) if path == Affinity.Type.NEUTRAL else PathPalette.main(path).lightened(0.45)
	_pending = root.find_children("*", "MeshInstance3D", true, false)
	_pending_index = 0
	_collect_pieces()
	_next = {"candidates": [] as Array[MeshInstance3D], "members": {}, "type": {}, "tall_box": {}, "any_box": {}, "name": {}, "proxies": {}, "boxes": [] as Array[AABB], "keys": [] as Array[int], "groups": [] as Array[int]}
	_scan_step()


## Fable Nov 21 (Part 7.2): gathers every batched piece of the scene into `_pieces` (world space).
func _collect_pieces() -> void:
	var found: PackedFloat32Array = PackedFloat32Array()
	for node: Node in root.find_children("*", "GeometryInstance3D", true, false):
		var instance: GeometryInstance3D = node as GeometryInstance3D
		if not instance.is_visible_in_tree():
			continue
		if instance.has_meta(META_PIECES):
			var local: PackedFloat32Array = instance.get_meta(META_PIECES) as PackedFloat32Array
			var shift: Vector3 = instance.global_position
			for index: int in range(0, local.size() - 3, 4):
				found.append_array(PackedFloat32Array([local[index] + shift.x, local[index + 1] + shift.z, local[index + 2], local[index + 3] + shift.y]))
		elif instance.has_meta(META_CARD):
			var at: Vector3 = instance.global_position
			var card_scale: Vector3 = instance.global_transform.basis.get_scale()
			found.append_array(PackedFloat32Array([at.x, at.z, card_scale.x * 0.5, at.y + card_scale.y]))
	_pieces = found


## How many batched pieces the last scan found (tests, the probe).
func piece_count() -> int:
	return _pieces.size() / 4


## True when a batched piece stands on the line from the lens to the hero, in front of him and taller than his shoulder: the same
## test its shader makes for the window (kit_card.gdshader, dna_fade.gdshader).
func pieces_cover(from: Vector3, feet: Vector3) -> bool:
	if _pieces.is_empty():
		return false
	var chest: Vector3 = feet + Vector3(0.0, 0.9, 0.0)
	var ab: Vector2 = Vector2(chest.x - from.x, chest.z - from.z)
	var length_squared: float = maxf(ab.length_squared(), 0.0001)
	var low_x: float = minf(from.x, chest.x) - 4.0
	var high_x: float = maxf(from.x, chest.x) + 4.0
	var low_z: float = minf(from.z, chest.z) - 4.0
	var high_z: float = maxf(from.z, chest.z) + 4.0
	for index: int in range(0, _pieces.size() - 3, 4):
		var x: float = _pieces[index]
		var z: float = _pieces[index + 1]
		if x < low_x or x > high_x or z < low_z or z > high_z:
			continue
		var top: float = _pieces[index + 3]
		if top < feet.y + SHOULDER + 0.3:
			continue
		var t: float = clampf(((x - from.x) * ab.x + (z - from.z) * ab.y) / length_squared, 0.0, 1.0)
		if t < 0.03 or t > 0.93:
			continue
		var side: float = Vector2(x - (from.x + ab.x * t), z - (from.z + ab.y * t)).length()
		if side > _pieces[index + 2] * 0.75 + 0.2:
			continue
		if top < lerpf(from.y, chest.y, t):
			continue
		return true
	return false


## The whole scan at once (tests, the probe).
func scan_now() -> void:
	_scan()
	while _pending_index < _pending.size():
		_scan_step()


func _scan_step() -> void:
	var end: int = mini(_pending_index + SCAN_BATCH, _pending.size())
	var next_members: Dictionary = _next["members"] as Dictionary
	var next_type: Dictionary = _next["type"] as Dictionary
	var tall_box: Dictionary = _next["tall_box"] as Dictionary
	var any_box: Dictionary = _next["any_box"] as Dictionary
	var next_name: Dictionary = _next["name"] as Dictionary
	while _pending_index < end:
		var node: Node = _pending[_pending_index]
		_pending_index += 1
		if not is_instance_valid(node):
			continue
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance.mesh == null or mesh_instance.layers == 0 or mesh_instance.get_parent() == camera:
			continue
		if mesh_instance.has_meta(&"no_occlusion_fade") or hero.is_ancestor_of(mesh_instance) or str(mesh_instance.name).begins_with("Decals_"):
			continue
		var box: AABB = _piece_box(mesh_instance)
		if box.size.y < MIN_HEIGHT or maxf(box.size.x, box.size.z) > MAX_EXTENT or box.size.y > 40.0:
			continue
		if not mesh_instance.is_visible_in_tree():
			continue
		(_next["candidates"] as Array[MeshInstance3D]).append(mesh_instance)
		var key: int = _group_key(mesh_instance)
		var type: StringName = type_of(box.size, _names(mesh_instance, root), _explicit_type(mesh_instance))
		any_box[key] = (any_box[key] as AABB).merge(box) if any_box.has(key) else box
		if type == TALL_OCCLUDER:
			(_next["boxes"] as Array[AABB]).append(box)
			(_next["keys"] as Array[int]).append(key)
			tall_box[key] = (tall_box[key] as AABB).merge(box) if tall_box.has(key) else box
		# the group is a tall occluder as soon as one of its pieces is; else it keeps its first piece's type
		if not next_type.has(key) or type == TALL_OCCLUDER:
			next_type[key] = type
		if not next_members.has(key):
			(_next["groups"] as Array[int]).append(key)
			var members: Array = []
			var parent: Node = mesh_instance.get_parent()
			if key != mesh_instance.get_instance_id() and parent != null:
				var siblings: Array[Node] = parent.find_children("*", "MeshInstance3D", true, false)
				next_name[key] = "%s (%d)" % [str(parent.name), siblings.size()] if siblings.size() > 1 else "%s/%s" % [str(parent.name), str(mesh_instance.name)]
				var proxies: Array = []
				for sibling: Node in siblings:
					var piece: MeshInstance3D = sibling as MeshInstance3D
					if piece.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY:
						proxies.append(sibling)
					elif members.size() < MAX_GROUP_MESHES and not sibling.has_meta(&"no_occlusion_fade") and not _is_ground(piece):
						var piece_type: StringName = _piece_type(piece)
						# only the tall pieces of a group take the window: its low pieces, its posts and its signs stay
						if piece_type == TALL_OCCLUDER:
							members.append(sibling)
				if not proxies.is_empty():
					(_next["proxies"] as Dictionary)[key] = proxies
			else:
				next_name[key] = "%s/%s" % [str(mesh_instance.get_parent().name) if mesh_instance.get_parent() != null else "", str(mesh_instance.name)]
				if type == TALL_OCCLUDER:
					members.append(mesh_instance)
			next_members[key] = members
	if _pending_index >= _pending.size():
		var next_box: Dictionary = {}
		for key: Variant in any_box.keys():
			next_box[key] = tall_box[key] if tall_box.has(key) else any_box[key]
			# a group with no tall piece of its own never blocks, so it holds nothing to fade (its nested tall pieces belong to their own group)
			if next_type.get(key) != TALL_OCCLUDER:
				next_members[key] = []
		# A group that is still faded but that this scan no longer lists (its pieces were hidden meanwhile) keeps its members until its
		# fade is back at zero, so nothing is left as a ghost.
		for key: Variant in _active_keys():
			if not next_members.has(key) and _members.has(key):
				next_members[key] = _members[key]
				next_type[key] = _group_type.get(key, TALL_OCCLUDER)
				next_name[key] = _group_name.get(key, "?")
				if _group_box.has(key):
					next_box[key] = _group_box[key]
				if _shadow_proxies.has(key):
					(_next["proxies"] as Dictionary)[key] = _shadow_proxies[key]
		_candidates = _next["candidates"] as Array[MeshInstance3D]
		_members = next_members
		_group_type = next_type
		_group_box = next_box
		_group_name = next_name
		_shadow_proxies = _next["proxies"] as Dictionary
		_boxes = _next["boxes"] as Array[AABB]
		_box_keys = _next["keys"] as Array[int]
		_group_keys = _next["groups"] as Array[int]
		_pending = []
		_next = {}


func _named_small(piece: Node) -> bool:
	var size: Vector3 = _piece_box(piece as MeshInstance3D).size
	if maxf(size.x, size.z) >= NAMED_ACROSS or size.y >= NAMED_HEIGHT:
		return false
	var lower: String = _names(piece, root).to_lower()
	for word: String in SMALL_WORDS:
		if lower.contains(word):
			return true
	return false


## Wide terrain never fades with its group (the starting forest's 900 m floor shares a parent with the clearing's props), nor does
## anything flat (a rug, a plank, a decal).
static func _is_ground(mesh_instance: MeshInstance3D) -> bool:
	if mesh_instance == null or mesh_instance.mesh == null:
		return false
	var box: AABB = mesh_instance.global_transform * mesh_instance.get_aabb()
	return maxf(box.size.x, box.size.z) > MAX_EXTENT


## True when the segment from -> to passes through `box` (slab test).
static func _segment_hits(box: AABB, from: Vector3, to: Vector3) -> bool:
	var direction: Vector3 = to - from
	var t_min: float = 0.0
	var t_max: float = 1.0
	for axis: int in range(3):
		var origin: float = from[axis]
		var delta_axis: float = direction[axis]
		var low: float = box.position[axis]
		var high: float = box.position[axis] + box.size[axis]
		if absf(delta_axis) < 0.00001:
			if origin < low or origin > high:
				return false
			continue
		var t1: float = (low - origin) / delta_axis
		var t2: float = (high - origin) / delta_axis
		if t1 > t2:
			var swap: float = t1
			t1 = t2
			t2 = swap
		t_min = maxf(t_min, t1)
		t_max = minf(t_max, t2)
		if t_min > t_max:
			return false
	return true


## True for a mesh drawn with the toon or painted-triplanar shader (they carry the window); false for anything else.
func _dithers(mesh_instance: MeshInstance3D) -> bool:
	var key: int = mesh_instance.get_instance_id()
	if _dither_cache.has(key):
		return bool(_dither_cache[key])
	var material: Material = mesh_instance.material_override
	if material == null and mesh_instance.mesh != null and mesh_instance.mesh.get_surface_count() > 0:
		material = mesh_instance.get_surface_override_material(0)
		if material == null:
			material = mesh_instance.mesh.surface_get_material(0)
	var result: bool = false
	if material is ShaderMaterial:
		var shader: Shader = (material as ShaderMaterial).shader
		# Fable Nov 21 (Part 7.2): the terrain shader carries the window too (the Iron Cave's crag is drawn with it)
		result = shader != null and (shader.resource_path.contains("style_toon") or shader.resource_path.contains("style_painted_triplanar") or shader.resource_path.contains("style_painted_terrain"))
	_dither_cache[key] = result
	return result


## Which groups hide the hero (`_blocking`) and which hold the lens (`_cut`). `elapsed` feeds the hysteresis; a negative value
## forgets the past (the probe asks "what would fade here" for a hero that was put there).
func _run_tests(elapsed: float = TEST_INTERVAL) -> void:
	var from: Vector3 = camera.global_position
	var feet: Vector3 = hero.global_position
	var lines: Dictionary = {}
	var cut_groups: Dictionary = {}
	var across: Vector3 = Vector3(from.z - feet.z, 0.0, feet.x - from.x).normalized() * SIGHT_SIDE
	var ends: Array[Vector3] = []
	for line: int in range(SIGHT_HEIGHTS.size()):
		ends.append(feet + Vector3(0.0, SIGHT_HEIGHTS[line], 0.0) + (across if line == 3 else (-across if line == 4 else Vector3.ZERO)))
	var touched: bool = false
	# the person in reach (the [E] prompt's NPC, a step or two from the hero): a tall thing that hides them opens its window too
	var talk: bool = talk_focus != Vector3.INF and Vector2(talk_focus.x - feet.x, talk_focus.z - feet.z).length() <= TALK_REACH
	var talk_hits: Dictionary = {}
	var near_lens: Dictionary = {}
	# Pure float maths over the boxes cached at the last scan (a static scene has thousands of candidates; no node is touched here).
	for index: int in range(_boxes.size()):
		var box: AABB = _boxes[index]
		var key: int = _box_keys[index]
		# never anything whose top is under the hero's shoulder where he stands (a wall on lower ground)
		if box.position.y + box.size.y < feet.y + SHOULDER:
			continue
		if box.grow(CAMERA_PADDING).has_point(from):
			cut_groups[key] = true
			continue
		if box.grow(NEAR_LENS).has_point(from):
			near_lens[key] = true
		var grown: AABB = box.grow(PADDING)
		var mask: int = int(lines.get(key, 0))
		for line: int in range(SIGHT_HEIGHTS.size()):
			if mask & (1 << line) == 0 and _segment_hits(grown, from, ends[line]):
				mask |= 1 << line
		if mask != 0:
			lines[key] = mask
		if talk and _segment_hits(grown, from, talk_focus + Vector3(0.0, 1.1, 0.0)) and _segment_hits(grown, from, talk_focus + Vector3(0.0, 0.4, 0.0)):
			talk_hits[key] = true
	var blocking_groups: Dictionary = {}
	var fresh: bool = elapsed < 0.0
	for key: Variant in lines.keys():
		var mask: int = int(lines[key])
		var count: int = (mask & 1) + ((mask >> 1) & 1) + ((mask >> 2) & 1) + ((mask >> 3) & 1) + ((mask >> 4) & 1)
		touched = true
		if count >= LINES_TO_START or (not fresh and _blocking.has(key)):
			blocking_groups[key] = true
			_clear_for.erase(key)
	# A tall thing that hides the hero AND stands right at the lens would fill the picture with one wall or roof and leave only the
	# window to look through: it is cut away like a piece the lens is inside (its footprint stays outlined on the ground).
	for key: Variant in near_lens.keys():
		if blocking_groups.has(key):
			cut_groups[key] = true
	for key: Variant in talk_hits.keys():
		blocking_groups[key] = true
		_clear_for.erase(key)
	if not fresh:
		# hysteresis: a group that was blocking and is touched by no line any more holds on for HOLD seconds
		for key: Variant in _blocking.keys():
			if blocking_groups.has(key) or cut_groups.has(key):
				continue
			var clear: float = float(_clear_for.get(key, 0.0)) + elapsed
			if clear < HOLD:
				_clear_for[key] = clear
				blocking_groups[key] = true
			else:
				_clear_for.erase(key)
	_blocking = blocking_groups
	_cut = cut_groups
	piece_cover = pieces_cover(from, feet)
	_touched = touched or piece_cover
	if OS.get_environment("OCCLUSION_DEBUG") != "" and Engine.get_process_frames() % 120 == 0:
		print("occlusion: ", debug_summary())
		print("occlusion blockers: ", "; ".join(debug_blockers()))


## Only the groups that are fading, faded or about to fade need work this frame (the rest of a big scene's groups sit at zero).
func _active_keys() -> Array[int]:
	var work: Dictionary = {}
	for key: Variant in _fade.keys():
		if float(_fade[key]) > 0.004:
			work[int(key)] = true
	for key: Variant in _cut_fade.keys():
		if float(_cut_fade[key]) > 0.004:
			work[int(key)] = true
	for key: Variant in _blocking.keys():
		work[int(key)] = true
	for key: Variant in _cut.keys():
		work[int(key)] = true
	var result: Array[int] = []
	for key: Variant in work.keys():
		result.append(int(key))
	return result


## What goes see-through for the hero and the lens as they stand now, one row per PIECE that takes it:
## {name, size (the piece's own box), kind (the piece's own type), why ("window" | "cut")}. `recompute` runs the test first,
## forgetting the past.
func verdict_now(recompute: bool = false) -> Array[Dictionary]:
	if recompute:
		_run_tests(-1.0)
	var result: Array[Dictionary] = []
	var keys: Dictionary = {}
	for key: Variant in _blocking.keys():
		keys[key] = "window"
	for key: Variant in _cut.keys():
		keys[key] = "cut"
	for key: Variant in keys.keys():
		var group: String = str(_group_name.get(key, "?"))
		for member: Variant in _members.get(key, []) as Array:
			if is_instance_valid(member):
				var piece: MeshInstance3D = member as MeshInstance3D
				if _piece_box(piece).size.y < SHOULDER:
					continue
				result.append({"name": group, "piece": str(piece.name), "size": _piece_box(piece).size, "kind": str(_piece_type(piece)), "why": str(keys[key])})
	return result


## Every thing the fader knows, with its type and its rule (the fade probe's list): {name, type, rule, size, can_fade, pieces}.
func catalogue() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for key: int in _group_keys:
		var type: StringName = _group_type.get(key, LOW_BLOCKER) as StringName
		var box: AABB = _group_box.get(key, AABB()) as AABB
		var pieces: int = (_members.get(key, []) as Array).size()
		result.append({"name": str(_group_name.get(key, "?")), "type": str(type), "rule": str(RULES[type]), "size": box.size, "can_fade": pieces > 0, "pieces": pieces})
	return result


## One line per active group: its name, box, eased values and what its first piece really carries (the play-script `fadeshot` log).
func debug_state() -> PackedStringArray:
	var lines: PackedStringArray = PackedStringArray()
	lines.append("lens %s hero %s" % [str(camera.global_position.snapped(Vector3(0.1, 0.1, 0.1))), str(hero.global_position.snapped(Vector3(0.1, 0.1, 0.1)))])
	for key: int in _active_keys():
		var members: Array = _members.get(key, []) as Array
		var first: MeshInstance3D = members[0] as MeshInstance3D if not members.is_empty() and is_instance_valid(members[0]) else null
		var box: AABB = _group_box.get(key, AABB()) as AABB
		lines.append("%s box %s + %s window %.2f cut %.2f piece %s transparency %.2f uniform %s visible %s" % [str(_group_name.get(key, "?")), str(box.position.snapped(Vector3(0.1, 0.1, 0.1))), str(box.size.snapped(Vector3(0.1, 0.1, 0.1))), float(_fade.get(key, 0.0)), float(_cut_fade.get(key, 0.0)), str(first.name) if first != null else "-", first.transparency if first != null else -1.0, str(first.get_instance_shader_parameter(&"occlusion_fade")) if first != null else "-", str(first.is_visible_in_tree()) if first != null else "-"])
	return lines


func debug_summary() -> String:
	return "boxes %d groups %d blocking %d cut %d" % [_boxes.size(), _group_keys.size(), _blocking.size(), _cut.size()]


func debug_blockers() -> PackedStringArray:
	var names: PackedStringArray = PackedStringArray()
	for key: Variant in _blocking.keys():
		names.append(str(_group_name.get(key, "?")))
	return names
