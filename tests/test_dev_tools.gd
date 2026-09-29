extends GutTest
## New brief (third), Part E: DevTools.shrine_enabled() is the one gate deciding whether the town's
## Dev Shrine exists at all - it must not appear in an exported release build.

func test_debug_build_enables_the_shrine() -> void:
	assert_true(DevTools.shrine_enabled(true), "a debug build should always show the dev shrine")


func test_release_build_hides_the_shrine_by_default() -> void:
	assert_false(DevTools.shrine_enabled(false), "a release build should not show the dev shrine unless the project setting explicitly opts in")


func test_a_project_setting_override_can_enable_it_even_in_a_release_build() -> void:
	ProjectSettings.set_setting(DevTools.SETTING_PATH, true)
	assert_true(DevTools.shrine_enabled(false), "the explicit override should still enable it in a release build")
	ProjectSettings.set_setting(DevTools.SETTING_PATH, false)
	assert_false(DevTools.shrine_enabled(false))
