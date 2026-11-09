extends GutTest
## Fable Nov 9 (Batch 14): the Red Cross recolour (ArtPatches) - only red pixels inside the boxes change, everything else stays.


func _picture(width: int, height: int) -> Image:
	var image: Image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.9, 0.88, 0.8, 1.0))  # cream cloth
	return image


func test_red_inside_a_box_turns_green_and_nothing_else_moves() -> void:
	var image: Image = _picture(100, 100)
	image.fill_rect(Rect2i(45, 45, 10, 10), Color(0.75, 0.1, 0.1, 1.0))  # the cross
	image.fill_rect(Rect2i(5, 5, 10, 10), Color(0.75, 0.1, 0.1, 1.0))  # a red banner outside the box
	var changed: int = ArtPatches.recolour_box(image, Rect2(0.4, 0.4, 0.2, 0.2))
	assert_eq(changed, 100, "the 10x10 cross")
	var centre: Color = image.get_pixel(50, 50)
	assert_gt(centre.g, centre.r, "green leads")
	assert_gt(centre.g, centre.b)
	assert_almost_eq(image.get_pixel(5, 5).r, 0.75, 0.01, "the banner outside the box is untouched")
	assert_almost_eq(image.get_pixel(46, 44).r, 0.9, 0.01, "cream next to the cross is untouched")


func test_cream_and_transparent_pixels_are_not_red() -> void:
	assert_false(ArtPatches.is_red(Color(0.9, 0.88, 0.8, 1.0)), "cream")
	assert_false(ArtPatches.is_red(Color(0.7, 0.5, 0.4, 1.0)), "skin")
	assert_false(ArtPatches.is_red(Color(0.8, 0.1, 0.1, 0.0)), "transparent")
	assert_true(ArtPatches.is_red(Color(0.6, 0.15, 0.12, 1.0)), "a shaded cross red")


func test_apply_patches_only_listed_pictures() -> void:
	var image: Image = _picture(40, 40)
	image.fill_rect(Rect2i(0, 0, 40, 40), Color(0.75, 0.1, 0.1, 1.0))
	var texture: ImageTexture = ImageTexture.create_from_image(image)
	assert_eq(ArtPatches.apply("NPC-ELDER", texture), texture, "no patch: the same texture back")
	assert_eq(ArtPatches.apply("NPC-HESPER", null), null)
	var patched: Texture2D = ArtPatches.apply("NPC-HESPER", texture)
	assert_ne(patched, texture, "a new texture")
	var pixel: Color = patched.get_image().get_pixel(18, 4)  # inside the cap box (0.415-0.505, 0.085-0.145)
	assert_gt(pixel.g, pixel.r, "the cap box is green now")
	var outside: Color = patched.get_image().get_pixel(2, 30)
	assert_almost_eq(outside.r, 0.75, 0.01, "outside the boxes: red stays")


func test_the_two_shipped_pictures_are_listed_and_the_boxes_are_small() -> void:
	assert_true(ArtPatches.has_patch("NPC-HESPER"))
	assert_true(ArtPatches.has_patch("STORY-EPI-WRINKLES"))
	for id: String in ArtPatches.PATCHES:
		for box: Rect2 in ArtPatches.PATCHES[id] as Array:
			assert_lt(box.size.x * box.size.y, 0.01, "%s: a box covers under 1 %% of the picture" % id)
