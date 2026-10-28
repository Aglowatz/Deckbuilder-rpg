extends GutTest
## Overnight Oct 27-28, Phase 2: the Feats page builds every group and feat, hides the unearned hidden ones as "???", and marks the
## earned ones; the pause menu offers it.

var _account_path: String


func before_each() -> void:
	_account_path = FeatAccount.path
	FeatAccount.path = "user://test_feats_panel_account.json"
	FeatAccount.reset()
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.NECROCRAT)


func after_each() -> void:
	Session.new_game()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(FeatAccount.path))
	FeatAccount.path = _account_path
	FeatAccount.reset()


func test_panel_lists_every_feat_by_group_and_hides_the_hidden_ones() -> void:
	var panel: FeatsPanel = FeatsPanel.make()
	add_child_autofree(panel)
	for group: String in FeatDefs.GROUP_ORDER:
		assert_not_null(panel.find_child("Group_%s" % group.replace(" ", "_"), true, false), group)
	var rows: int = 0
	var hidden_rows: int = 0
	for def: FeatDefs.Def in FeatDefs.all():
		var row: HBoxContainer = panel.find_child("Feat_%s" % def.id, true, false) as HBoxContainer
		assert_not_null(row, def.id)
		rows += 1
		if def.hidden and not FeatAccount.has(def.id):
			hidden_rows += 1
			var title: Label = (row.get_child(0) as VBoxContainer).get_child(0) as Label if row.get_child(0) is VBoxContainer else null
			if title != null:
				assert_eq(title.text, "???", def.id)
	assert_eq(rows, FeatDefs.count())
	assert_true(hidden_rows >= 8, "the hidden ones read as ??? (%d)" % hidden_rows)
	var earned: HBoxContainer = panel.find_child("Feat_old_stone_cold_nights", true, false) as HBoxContainer
	assert_not_null(earned, "the fast-forwarded game cleared the cave")
	assert_eq((earned.find_child("Mark", true, false) as Label).text, "Earned here")
	assert_true(FeatsPanel.summary_text().contains("of %d earned" % FeatDefs.count()))


func test_pause_menu_offers_the_feats_page() -> void:
	var menu: PauseMenu = PauseMenu.new()
	add_child_autofree(menu)
	var button: Control = menu.find_child("FeatsButton", true, false) as Control
	assert_not_null(button, "a Feats entry")
	menu.call("_show_feats")
	assert_not_null(menu.find_child("FeatsPanel", true, false), "the page opens inside the menu panel")
