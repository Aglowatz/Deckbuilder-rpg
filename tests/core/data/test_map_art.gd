extends GutTest
## Dungeon map art (core/data/map_art.gd, data/dungeons/map_layout.json): the importer (copy only, never crops, manifest, unknown files), every dungeon of the list has
## its painted 3:2 map, every node has a fitted position on it, and the map screen shows the picture whole with the nodes on it.

const SOURCE: String = "user://map_test/source"
const OUT: String = "user://map_test/out"
const MANIFEST: String = "user://map_test/manifest.csv"


func before_each() -> void:
	MapArt.reset()
	DungeonCatalog.reset()
	_clean()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SOURCE))


func after_all() -> void:
	_clean()


func _clean() -> void:
	for dir: String in [SOURCE, OUT]:
		var real: String = ProjectSettings.globalize_path(dir)
		if DirAccess.dir_exists_absolute(real):
			for file_name: String in DirAccess.get_files_at(real):
				DirAccess.remove_absolute(real.path_join(file_name))
	var manifest: String = ProjectSettings.globalize_path(MANIFEST)
	if FileAccess.file_exists(manifest):
		DirAccess.remove_absolute(manifest)


func _save(width: int, height: int, file_name: String) -> void:
	var image: Image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.3, 0.5, 0.2))
	image.save_png(ProjectSettings.globalize_path(SOURCE.path_join(file_name)))


func test_the_import_copies_never_crops_and_reports() -> void:
	_save(1536, 1024, "MAP-HOG.png")
	_save(1500, 1000, "MAP-TUT.png")
	_save(1200, 1200, "MAP-PC.png")
	_save(1536, 1024, "MAP-NOWHERE.png")
	var known: Dictionary = {"MAP-HOG": "The House of Gains", "MAP-TUT": "Trial", "MAP-PC": "Primm", "MAP-S-BEEF": "Mount"}
	var result: MapArt.Result = MapArt.import_from_source(SOURCE, OUT, MANIFEST, known)
	assert_eq(result.added, ["MAP-HOG", "MAP-PC", "MAP-TUT"] as Array[String])
	assert_eq(result.unknown, ["MAP-NOWHERE.png"] as Array[String])
	assert_eq(result.missing, ["MAP-S-BEEF"] as Array[String])
	assert_eq(result.not_three_two.size(), 1, "the square picture is reported, not cropped")
	var square: Image = Image.load_from_file(ProjectSettings.globalize_path(OUT.path_join("MAP-PC.webp")))
	assert_eq(square.get_size(), Vector2i(1200, 1200), "a map is never cropped")
	assert_eq(DirAccess.get_files_at(ProjectSettings.globalize_path(SOURCE)).size(), 4, "the source folder is untouched")


func test_big_maps_are_scaled_down_and_unchanged_files_skipped() -> void:
	_save(3072, 2048, "MAP-HOG.png")
	var known: Dictionary = {"MAP-HOG": "The House of Gains"}
	MapArt.import_from_source(SOURCE, OUT, MANIFEST, known)
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(OUT.path_join("MAP-HOG.webp")))
	assert_eq(image.get_size(), Vector2i(1536, 1024))
	var again: MapArt.Result = MapArt.import_from_source(SOURCE, OUT, MANIFEST, known)
	assert_eq(again.unchanged, 1)
	assert_eq(again.added.size(), 0)


func test_the_source_folder_is_configured() -> void:
	assert_eq(MapArt.source_dir(), "G:/My Drive/Card Game Art/Approved_Maps")


func test_every_dungeon_has_its_painted_3_2_map() -> void:
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		assert_true(MapArt.has_map(blueprint.map_id), "%s has %s" % [blueprint.id, blueprint.map_id])
		var texture: Texture2D = MapArt.texture_for(blueprint.map_id)
		assert_not_null(texture)
		if texture != null:
			assert_almost_eq(float(texture.get_width()) / float(texture.get_height()), 1.5, 0.01, "%s is 3:2" % blueprint.map_id)
	assert_null(MapArt.texture_for("MAP-NOWHERE"))


func test_the_map_fits_the_screen_without_cropping() -> void:
	var rect: Rect2 = DungeonMapScreen.fit_rect(Vector2(1536, 1024))
	assert_eq(rect.size, Vector2(1620, 1080))
	assert_eq(rect.position, Vector2(150, 0))
	var wide: Rect2 = DungeonMapScreen.fit_rect(Vector2(1920, 1080))
	assert_eq(wide, Rect2(0, 0, 1920, 1080))
	var tall: Rect2 = DungeonMapScreen.fit_rect(Vector2(1000, 1500))
	assert_almost_eq(tall.size.y, 1080.0, 0.01)
	assert_lte(tall.size.x, 1920.0)


func test_every_node_has_a_fitted_position_on_its_map() -> void:
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		var fitted: Dictionary = DungeonCatalog.fitted_layout(blueprint.id)
		for node: DungeonCatalog.BlueprintNode in blueprint.nodes:
			assert_true(fitted.has(str(node.number)), "%s node %d has a fitted position" % [blueprint.id, node.number])
			assert_between(node.position.x, 0.02, 0.98, "%s node %d x" % [blueprint.id, node.number])
			assert_between(node.position.y, 0.02, 0.98, "%s node %d y" % [blueprint.id, node.number])
		assert_true(["full", "subtle", "highlight", "none"].has(DungeonCatalog.path_style(blueprint.id)), "%s path style" % blueprint.id)


func test_nodes_do_not_sit_on_top_of_each_other() -> void:
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		for first: DungeonCatalog.BlueprintNode in blueprint.nodes:
			for second: DungeonCatalog.BlueprintNode in blueprint.nodes:
				if second.number <= first.number:
					continue
				var apart: Vector2 = (first.position - second.position) * Vector2(1536.0, 1024.0)
				assert_gt(apart.length(), 90.0, "%s: nodes %d and %d are apart" % [blueprint.id, first.number, second.number])


func test_the_map_screen_shows_the_picture_and_puts_every_node_on_it() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	for key: String in ["beefcake", "final"]:
		Session.zone_run = ZoneRun.enter(key, Session.profile, Session.deck)
		Session.dungeon_key = key
		Session.dungeon_map = MainDungeons.build_map(key)
		Session.run = DungeonRun.enter(Session.profile, Session.deck, Session.zone_run.run.dungeon_sources)
		Session.main_dungeon_active = true
		var screen: DungeonMapScreen = DungeonMapScreen.new()
		add_child_autofree(screen)
		await wait_frames(3)
		var picture: TextureRect = screen.get_node_or_null("MapArt") as TextureRect
		assert_not_null(picture, "%s shows its painted map" % key)
		if picture != null:
			assert_eq(picture.size, Vector2(1620, 1080))
			for child: Node in screen.get_children():
				if child is MapNodeButton:
					var button: MapNodeButton = child as MapNodeButton
					assert_true(Rect2(picture.position, picture.size).has_point(button.center_point()), "%s: %s sits on the map" % [key, button.map_node.title])
		Session.main_dungeon_active = false
	Session.zone_run = null
	Session.run = null
	Session.dungeon_map = null
