class_name MenuText
extends RefCounted
## Fable Nov 21 review (Part 1.6): the info screens follow the Text size setting.
##
## The stained-glass screens (the pause menu, settings, the quest log, the glossary, feats, credits, save and load, the map's legend, the
## quest box, pop-ups and notices) all take their look from `GlassTheme.apply(root)`. That call also hands the root to `MenuText.follow`:
## every font size under it - the theme's own sizes and the explicit sizes the screens give their labels - is multiplied by `scale()`,
## which is read from the "Tooltip and menu text size" row (the Text size switch sets it with the others). At Normal the factor is 1 and
## nothing is touched. Cards keep their own setting (a CardView's subtree is skipped), as does anything tagged `menu_text_skip`.

## Menu factor per `Settings.text_tooltips` (Small, Normal, Large, Larger). Milder than the tooltip's own (0.85 / 1 / 1.2 / 1.4): a page
## has fixed panes that must still hold their text, and a menu never shrinks below Normal.
const SCALES: Array[float] = [1.0, 1.0, 1.15, 1.3]
const META_BASE: StringName = &"menu_text_base"
const META_APPLIED: StringName = &"menu_text_applied"
const META_SKIP: StringName = &"menu_text_skip"
const KEYS: Array[StringName] = [&"font_size", &"normal_font_size", &"bold_font_size", &"italics_font_size", &"bold_italics_font_size"]

static var _roots: Array[WeakRef] = []
static var _hooked: bool = false
static var _built_scale: float = 1.0
## Tests set a factor directly (-1 = read the setting).
static var forced_scale: float = -1.0


static func scale() -> float:
	if forced_scale > 0.0:
		return forced_scale
	return SCALES[clampi(Settings.text_tooltips, 0, SCALES.size() - 1)]


## A base font size at the menu factor (for the theme's own sizes and for sizes worked out in code).
static func size(base: int) -> int:
	return maxi(8, int(round(float(base) * scale())))


## Leaves `node` and everything under it at the size its screen gave it.
static func skip(node: Node) -> void:
	if node != null:
		node.set_meta(META_SKIP, true)


## Keeps every font size under `root` at the menu factor, now and for whatever the screen builds later.
static func follow(root: Control) -> void:
	if root == null:
		return
	_prune()
	for ref: WeakRef in _roots:
		if ref.get_ref() == root:
			rescale(root)
			return
	_roots.append(weakref(root))
	_hook()
	rescale(root)


static func _hook() -> void:
	if _hooked:
		return
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return
	_hooked = true
	_built_scale = scale()
	tree.node_added.connect(_on_node_added)
	Settings.text_changed.connect(refresh)


static func _prune() -> void:
	var live: Array[WeakRef] = []
	for ref: WeakRef in _roots:
		var root: Control = ref.get_ref() as Control
		if root != null and is_instance_valid(root):
			live.append(ref)
	_roots = live


## The setting changed (or a test changed the factor): the theme is rebuilt at the new sizes and every followed screen is re-sized.
static func refresh() -> void:
	_prune()
	if not is_equal_approx(_built_scale, scale()):
		_built_scale = scale()
		GlassTheme.reset()
		for ref: WeakRef in _roots:
			var root: Control = ref.get_ref() as Control
			if root != null and root.theme != null:
				root.theme = GlassTheme.theme()
	for ref: WeakRef in _roots:
		rescale(ref.get_ref() as Control)


static func rescale(node: Node) -> void:
	if node == null or not is_instance_valid(node) or _skipped(node):
		return
	if node is Control:
		_apply(node as Control)
	for child: Node in node.get_children():
		rescale(child)


static func _skipped(node: Node) -> bool:
	return node is CardView or node.has_meta(META_SKIP)


static func _on_node_added(node: Node) -> void:
	if not (node is Control) or _roots.is_empty():
		return
	if is_equal_approx(scale(), 1.0) and not node.has_meta(META_BASE):
		return
	for ref: WeakRef in _roots:
		var root: Control = ref.get_ref() as Control
		if root == null or not is_instance_valid(root) or not root.is_ancestor_of(node):
			continue
		var walker: Node = node
		while walker != null and walker != root:
			if _skipped(walker):
				return
			walker = walker.get_parent()
		_apply(node as Control)
		# a size set just after add_child (label made, added, then sized) is caught one frame later
		_apply_later.call_deferred(node)
		return


static func _apply_later(node: Node) -> void:
	if is_instance_valid(node) and node is Control:
		_apply(node as Control)


## Multiplies the explicit font sizes of one control. The size its screen gave it is remembered, so a second pass (or a changed setting)
## starts from that, and a size the screen sets again later is taken as the new base.
static func _apply(control: Control) -> void:
	var factor: float = scale()
	var has_meta: bool = control.has_meta(META_BASE)
	if is_equal_approx(factor, 1.0) and not has_meta:
		return
	var base: Dictionary = control.get_meta(META_BASE) as Dictionary if has_meta else {}
	var applied: Dictionary = control.get_meta(META_APPLIED) as Dictionary if control.has_meta(META_APPLIED) else {}
	var touched: bool = false
	for key: StringName in KEYS:
		if not control.has_theme_font_size_override(key):
			continue
		var now: int = control.get_theme_font_size(key)
		if not base.has(key) or int(applied.get(key, -1)) != now:
			base[key] = now
		var wanted: int = maxi(8, int(round(float(int(base[key])) * factor)))
		if wanted != now:
			control.add_theme_font_size_override(key, wanted)
		applied[key] = wanted
		touched = true
	if touched:
		control.set_meta(META_BASE, base)
		control.set_meta(META_APPLIED, applied)
