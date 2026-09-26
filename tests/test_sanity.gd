extends GutTest


func test_true_is_true() -> void:
	assert_true(true)


func test_addition() -> void:
	assert_eq(2 + 2, 4)
