extends GutTest
## Fable Nov 15b (the hour pass): the pins.
## Part 1 - Primm's phase rule shows once in his fight (its badge), not a second time on the gold panel under the HUD.
## Part 2 - the Verdant Dump's "floating door" (the fridge's blank back and open door) is gone and the root ramp's slab lies on its slope.


func test_primms_rule_line_is_not_written_twice() -> void:
	var hud: BattleHud = BattleHud.new()
	add_child_autofree(hud)
	for index: int in range(3):
		var badge: RuleBadges.Badge = PrimmBoss.phase_badge(index)
		if badge == null:
			continue
		var shown: Array[RuleBadges.Badge] = [badge]
		hud.set_rule_badges(shown)
		assert_true(hud.rule_text_is_shown(PrimmBoss.phase(index).rule_text()), "phase %d: the badge carries the rule line" % (index + 1))
		hud.set_capital_panels({}, PrimmBoss.phase(index).rule_text())
		assert_null(hud.find_child("PhaseRulePanel", true, false), "phase %d: no second copy on the gold panel" % (index + 1))
	assert_false(hud.rule_text_is_shown("A rule with no badge."), "a rule line with no badge still gets its panel")


func test_the_dumps_fridge_is_gone_and_its_chest_stays() -> void:
	var layout: HeapLayout = HeapLayout.new()
	layout.build()
	for prop: HeapLayout.Prop in layout.props:
		assert_ne(prop.kind, "fridge", "the fridge that read as two flat green slabs (a floating door)")
	assert_true(layout.chests.has("chest_fridge"), "its chest is still there")


func test_the_root_ramps_slab_rises_to_the_north() -> void:
	var layout: HeapLayout = HeapLayout.new()
	layout.build()
	var checked: int = 0
	for ramp: HeapLayout.Ramp in layout.ramps:
		if ramp.kind != "ramp":
			continue
		checked += 1
		var node: Node3D = HeapTerraces.root_ramp(ramp, 0.0)
		add_child_autofree(node)
		var body: MeshInstance3D = node.get_node("Body") as MeshInstance3D
		var south_low: float = INF   # the lowest point of the slab's south (foot) end and of its north (head) end
		var north_low: float = INF
		for v: Vector3 in body.mesh.get_faces():
			var p: Vector3 = body.transform * v
			if absf(p.x - ramp.rect.get_center().x) > ramp.rect.size.x * 0.3:
				continue  # the slab's middle, not the splayed roots
			if p.z > ramp.rect.end.y - 1.0 and p.z < ramp.rect.end.y:
				south_low = minf(south_low, p.y)
			elif p.z < ramp.rect.position.y + 1.0 and p.z > ramp.rect.position.y:
				north_low = minf(north_low, p.y)
		assert_lt(south_low, ramp.y0 + 0.6, "%s: the foot lies on the lower terrace (it stood in the air)" % ramp.id)
		assert_gt(north_low, ramp.y0 + (ramp.y1 - ramp.y0) * 0.5, "%s: the head is up at the upper terrace" % ramp.id)
	assert_gt(checked, 0)


## Part 4 - the Wardrobe and the Card Packs page are laid out on the whole canvas: they are held at 100 % (not cropped). (Fable Nov 16b:
## the Deck Station's deck list is a full-height column now and follows the UI scale: tests/ui/test_deck_station_column.gd.)
func test_the_full_canvas_screens_are_held_at_100_percent() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	for script: GDScript in [WardrobeScreen, PacksScreen]:
		var screen: OverlayScreen = script.new() as OverlayScreen
		add_child_autofree(screen)
		Settings.set_ui_scale(1.3)
		await wait_process_frames(8)
		var scaler: UiScale = screen.get_node_or_null(^"UiScaleFit") as UiScale
		assert_not_null(scaler)
		if scaler != null:
			assert_almost_eq(scaler.current_factor(), 1.0, 0.011, "%s fits the screen at a 130 %% UI scale" % script.get_global_name())
		Settings.set_ui_scale(1.0)
		screen.queue_free()
		await wait_process_frames(2)
	Session.save_enabled = true
