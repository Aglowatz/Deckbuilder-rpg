extends GutTest
## Oct 19: post-battle screens show where the player is - the fight's battleboard blurred (result panel, rewards) or the live scene
## blurred (level-up, quest-complete popups). docs/art/post_battle_backgrounds.md.


func before_each() -> void:
	Session.save_enabled = false
	Session.ensure_game(Affinity.Type.BEEFCAKE)


func test_a_board_backdrop_shows_that_board_blurred() -> void:
	for key: String in ["zone:beefcake", "dungeon:beefcake", "capital:in", "capital:out", "arena", "dungeon:hollow", "BB-HOG"]:
		var backdrop: PostBattleBackdrop = PostBattleBackdrop.for_board(key, false)
		add_child_autofree(backdrop)
		var picture: TextureRect = backdrop.get_node("Board") as TextureRect
		assert_not_null(picture.texture, "%s has a picture" % key)
		assert_eq(picture.texture, Battleboards.texture_for(key), "%s shows its own board" % key)
		assert_not_null(picture.material, "blurred")


func test_every_context_has_a_real_board_image() -> void:
	for key: String in ["dungeon:hollow", "town", "graveyard", "arena", "zone:beefcake", "zone:necrocrat", "zone:gourmand", "zone:refusemancer", "capital:out", "capital:in", "dungeon:beefcake", "dungeon:gourmand", "dungeon:necrocrat", "dungeon:refusemancer", "dungeon:final", "boss:final"]:
		assert_true(Battleboards.has_image(Battleboards.board_for(key)), "%s -> %s exists" % [key, Battleboards.board_for(key)])


func test_the_rewards_screen_takes_place_where_the_fight_was() -> void:
	var offer: RewardOffer = RewardOffer.new()
	offer.enemy_name = "Chancellor Clench"
	offer.board_key = "dungeon:beefcake"
	Session.pending_reward = offer
	var screen: Node = (load("res://scenes/rewards.tscn") as PackedScene).instantiate()
	add_child_autofree(screen)
	await wait_process_frames(2)
	var backdrop: PostBattleBackdrop = screen.find_child("PostBattleBackdrop", true, false) as PostBattleBackdrop
	assert_not_null(backdrop, "no more arena backdrop")
	assert_eq(backdrop.board, "dungeon:beefcake")
	for node: Node in screen.find_children("*", "", true, false):
		assert_false(node is ArenaBackdrop, "the generic arena backdrop is gone")
	Session.pending_reward = null


func test_a_dungeon_without_a_recorded_board_uses_the_run_s_board() -> void:
	Session.main_dungeon_active = false
	Session.mini_active = false
	assert_eq(PostBattleBackdrop.dungeon_board_key(), "dungeon:hollow", "outside a zone dungeon: the Forgotten Cave")


func test_popups_over_the_world_blur_it_instead_of_blacking_it_out() -> void:
	var level_up: LevelUpScreen = LevelUpScreen.new()
	level_up.setup([ProgressionTable.row(2)] as Array[LevelData])
	add_child_autofree(level_up)
	await wait_process_frames(1)
	assert_not_null(level_up.find_child("PostBattleBackdropLive", true, false), "level-up keeps the place visible")
	for child: Node in level_up.get_children():
		if child is ColorRect:
			assert_lt((child as ColorRect).color.a, 0.5, "no near-black shade")
