extends GutTest
## Overnight Oct 18, Phase 2 cycle 5: the HUD toast wraps a long message (the zone's Path warning) and grows upward from the same bottom line.


func test_a_long_toast_wraps_and_keeps_its_bottom_line() -> void:
	var hud: TownHud = TownHud.new()
	add_child_autofree(hud)
	await wait_frames(2)
	var toast: Label = hud._toast
	hud.toast("Short.")
	assert_almost_eq(toast.position.y + toast.size.y, 824.0, 0.5)
	hud.toast(ZoneEffects.rival_warning(GainlandsZone.ID, Affinity.Type.NECROCRAT), UIStyle.GOLD, 6.0)
	assert_gt(toast.get_line_count(), 1, "the warning wraps")
	assert_almost_eq(toast.position.y + toast.size.y, 824.0, 0.5, "it grows upward")
	assert_lte(toast.size.x, 1000.0)
