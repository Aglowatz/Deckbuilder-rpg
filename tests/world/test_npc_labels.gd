extends GutTest
## Playtest v0.4.0 Part A: floating NPC name labels are screen UI (`NpcLabels`): vendors say what they sell, quest givers are green,
## every label (vendors and quest givers too, since Oct 20) shows within `NpcLabels.NEAR` metres and fades, everything hides while blocked (dialogue, menus), and the black market
## (the Crosspath Secret Dealer, Fig Sly) gets no label at all. Vendors and quest givers also get a glow at their feet (`NpcGlow`).


func test_vendor_labels_say_what_they_sell() -> void:
	assert_eq(NpcLabels.text_for("V-SABLE", "Sable"), "Sable - Cards")
	assert_eq(NpcLabels.text_for("V-BEETSWORTH", "Bertram"), "Bertram Beetsworth - Gear")
	assert_eq(NpcLabels.text_for("V-TONIC", "Tilly"), "Tilly Tonic - Items")
	assert_eq(NpcLabels.text_for("V-THREADWELL", "Pip"), "Pip Threadwell - Clothes")
	assert_eq(NpcLabels.text_for("V-FENWICK", "Foil"), "Foil Fenwick - Packs")
	assert_eq(NpcLabels.text_for("V-ALEMBIC", "Auntie"), "Auntie Alembic - Alchemy")
	assert_eq(NpcLabels.text_for("V-BENCHLEY", "Coach"), "Coach Brutus Benchley - Cards", "the zone card vendors too")


func test_kinds_vendor_quest_plain_and_the_black_market_has_none() -> void:
	assert_eq(NpcLabels.kind_for("V-SABLE"), "vendor")
	assert_eq(NpcLabels.kind_for("NPC-ELDER"), "quest")
	assert_eq(NpcLabels.kind_for("NPC-GATEKEEPER"), "quest")
	assert_eq(NpcLabels.kind_for("NPC-GERALD"), "quest")
	assert_eq(NpcLabels.kind_for("NPC-PELL"), "quest", "the Path quest givers")
	assert_eq(NpcLabels.kind_for("NPC-PUMP"), "npc", "a quiz master is a plain NPC")
	assert_eq(NpcLabels.kind_for("NPC-CITIZEN"), "npc")
	assert_eq(NpcLabels.kind_for("V-FIGSLY"), "", "Fig Sly (black market) is left exactly as he is: no label")
	assert_eq(NpcLabels.sells_for("V-FIGSLY"), "")
	assert_eq(NpcLabels.text_for("NPC-ELDER", "x"), "Elder Maren", "a quest giver's label is the short name alone")
	assert_eq(NpcLabels.text_for("NO-SUCH-NPC", "Fallback"), "Fallback")


func test_colors_tell_vendors_and_quest_givers_apart() -> void:
	assert_ne(NpcLabels.color_for("vendor"), NpcLabels.color_for("quest"))
	assert_ne(NpcLabels.color_for("quest"), NpcLabels.color_for("npc"))
	assert_ne(NpcGlow.VENDOR, NpcGlow.QUEST, "the glows differ too")


var _blocked: bool = false
var _marked: bool = true


func _scene() -> Dictionary:
	var root: Node3D = Node3D.new()
	add_child_autofree(root)
	var camera: Camera3D = Camera3D.new()
	root.add_child(camera)
	camera.position = Vector3(0, 8, 10)
	camera.look_at(Vector3.ZERO, Vector3.UP)
	camera.current = true
	var hero: Node3D = Node3D.new()
	root.add_child(hero)
	var anchor: Node3D = Node3D.new()
	anchor.position = Vector3(0, 1.8, 0)
	root.add_child(anchor)
	return {"root": root, "camera": camera, "hero": hero, "anchor": anchor}


func test_an_always_label_is_on_screen_and_a_plain_one_only_near_the_hero() -> void:
	var parts: Dictionary = _scene()
	_blocked = false
	var layer: NpcLabels = NpcLabels.install(parts["root"] as Node, parts["hero"] as Node3D, parts["camera"] as Camera3D, func() -> bool: return _blocked)
	var vendor_label: Label = layer.register(parts["anchor"] as Node3D, "Sable - Cards", "vendor", true, 0.3, "vendor")
	var far_anchor: Node3D = Node3D.new()
	far_anchor.position = Vector3(0, 1.8, -30)  # far ahead, still in the camera's view
	(parts["root"] as Node3D).add_child(far_anchor)
	var plain_label: Label = layer.register(far_anchor, "Townsfolk", "npc", false, 0.3, "stroller")
	assert_eq(layer.entry_count(), 2)
	await wait_process_frames(40)
	assert_true(vendor_label.visible, "a vendor's label shows when the hero stands beside them")
	assert_gt(vendor_label.modulate.a, 0.9)
	assert_false(plain_label.visible, "a plain NPC 30 m away has no label")
	(parts["hero"] as Node3D).position = Vector3(0, 0, -29)
	await wait_process_frames(40)
	assert_true(plain_label.visible, "walking up to a plain NPC shows its name")
	_blocked = true
	await wait_process_frames(40)
	assert_false(vendor_label.visible, "every label hides while a dialogue or menu is up")
	assert_false(plain_label.visible)
	_blocked = false
	layer.unregister(far_anchor)
	assert_eq(layer.entry_count(), 1)


func test_a_quest_mark_boosts_a_plain_label() -> void:
	var parts: Dictionary = _scene()
	var layer: NpcLabels = NpcLabels.install(parts["root"] as Node, parts["hero"] as Node3D, parts["camera"] as Camera3D, func() -> bool: return false)
	_marked = true
	layer.boost = func(key: String) -> bool: return _marked and key == "hermit"
	var far_anchor: Node3D = Node3D.new()
	far_anchor.position = Vector3(0, 1.8, -30)  # far ahead, still in the camera's view
	(parts["root"] as Node3D).add_child(far_anchor)
	var label: Label = layer.register(far_anchor, "Old Man Mountain", "npc", false, 0.3, "hermit")
	await wait_process_frames(60)
	assert_false(label.visible, "a quest mark no longer shows a name from afar (Oct 20: one radius for every label)")
	(parts["hero"] as Node3D).position = Vector3(0, 0, -29)
	await wait_process_frames(60)
	assert_true(label.visible, "walking up shows it")
	assert_eq(label.get_theme_color("font_color"), NpcLabels.QUEST, "in the quest colour while the mark is up")
	_marked = false
	await wait_process_frames(60)
	assert_eq(label.get_theme_color("font_color"), NpcLabels.PLAIN, "and plain again once the quest is gone")


func test_overlapping_labels_are_spread_apart() -> void:
	var parts: Dictionary = _scene()
	var layer: NpcLabels = NpcLabels.install(parts["root"] as Node, parts["hero"] as Node3D, parts["camera"] as Camera3D, func() -> bool: return false)
	var a: Label = layer.register(parts["anchor"] as Node3D, "Sable - Cards", "vendor", true, 0.3, "a")
	var twin: Node3D = Node3D.new()
	twin.position = Vector3(0.05, 1.8, 0.0)
	(parts["root"] as Node3D).add_child(twin)
	var b: Label = layer.register(twin, "Tilly Tonic - Items", "vendor", true, 0.3, "b")
	await wait_process_frames(40)
	assert_true(a.visible and b.visible)
	var ra: Rect2 = Rect2(a.position, a.size * a.scale)
	var rb: Rect2 = Rect2(b.position, b.size * b.scale)
	assert_false(ra.intersects(rb), "two labels on the same spot never print over each other")


func test_the_glow_is_a_flat_additive_disc_under_the_npc() -> void:
	var npc: Node3D = Node3D.new()
	add_child_autofree(npc)
	var glow: NpcGlow = NpcGlow.attach(npc, NpcGlow.VENDOR)
	await wait_process_frames(2)
	assert_not_null(glow)
	assert_eq(NpcGlow.of(npc), glow)
	assert_eq(NpcGlow.attach(npc, NpcGlow.QUEST), glow, "attaching again recolours the same disc")
	assert_true(glow.mesh is QuadMesh)
	assert_lt(glow.position.y, 0.1, "it lies at the feet")
	assert_true(glow.has_meta(StyleToon.META_NO_TOON), "excluded from the toon pass")


func test_vendor_and_quest_giver_labels_follow_the_same_radius() -> void:
	var parts: Dictionary = _scene()
	var layer: NpcLabels = NpcLabels.install(parts["root"] as Node, parts["hero"] as Node3D, parts["camera"] as Camera3D, func() -> bool: return false)
	var far_anchor: Node3D = Node3D.new()
	far_anchor.position = Vector3(0, 1.8, -12)  # 12 m from the hero, still in view
	(parts["root"] as Node3D).add_child(far_anchor)
	var vendor: Label = layer.register(far_anchor, "Sable - Cards", "vendor", true, 0.3, "vendor")
	await wait_process_frames(40)
	assert_false(vendor.visible, "a vendor 12 m away shows no name")
	(parts["hero"] as Node3D).position = Vector3(0, 0, -12.0 + NpcLabels.NEAR - 0.5)
	await wait_process_frames(40)
	assert_true(vendor.visible, "inside the radius the vendor's name is up")
	assert_gt(vendor.modulate.a, 0.9)
	assert_between(NpcLabels.NEAR, 5.5, 7.0, "the radius stays about 6-7 m")
