extends GutTest
## The Low / Medium / High preset table: every knob only ever rises with the level.


func test_table_has_three_rows_and_knobs_never_drop() -> void:
	var rows: Array[Dictionary] = GraphicsQuality.table()
	assert_eq(rows.size(), 3)
	for key: String in ["render_scale", "shadows", "foliage_density", "ambient_particles", "ambient_particle_budget", "light_budget", "decal_budget"]:
		for i: int in range(1, rows.size()):
			assert_true(float(rows[i][key]) >= float(rows[i - 1][key]), "%s rises with the level" % key)


func test_recommended_level_is_valid() -> void:
	assert_between(GraphicsQuality.recommended(), 0, 2)
