extends GutTest
## Fable Nov 21 castle, Part 1: the owner's quick fixes and card changes.

var content: ContentSet


func before_all() -> void:
	content = ContentLibrary.load_all()


# ---- 1.1 choice prompts sit above the played cards ------------------------------------------------------------------------------


func test_the_prompt_layer_is_above_the_table_and_under_the_modals() -> void:
	assert_gt(BattleHud.PROMPT_LAYER, BattleHud.BANNER_LAYER, "above the banner, the tooltips and every card on the table")
	assert_lt(BattleHud.PROMPT_LAYER, BattleHud.MODAL_LAYER, "the engine's own choices and the Peek stay on top")


func test_every_battle_prompt_is_built_in_the_prompt_layer() -> void:
	var source: String = FileAccess.get_file_as_string("res://ui/battle/battle_screen.gd")
	for panel_name: String in ["AbilityMenu", "XDialog", "PathChooser"]:
		var at: int = source.find("name = \"%s\"" % panel_name)
		assert_gt(at, 0, panel_name)
		var after: String = source.substr(at, 400)
		assert_true(after.contains("prompt_layer().add_child("), "%s goes into the prompt layer" % panel_name)
		assert_false(after.contains("_overlay_layer.add_child(panel)"), "%s is not under the cards any more" % panel_name)


func test_a_prompt_stands_beside_its_card_and_on_the_screen() -> void:
	var size: Vector2 = Vector2(380, 220)
	for center: Vector2 in [Vector2(960, 540), Vector2(40, 40), Vector2(1900, 1060), Vector2(1700, 300), Vector2(200, 900)]:
		var spot: Vector2 = BattleScreen.prompt_spot(center, size)
		var rect: Rect2 = Rect2(spot, size)
		assert_true(Rect2(0, 0, 1920, 1080).encloses(rect), "on the screen for a card at %s" % center)
		assert_false(rect.has_point(center), "never over the card it belongs to (%s)" % center)


# ---- 1.2 to 1.5 the cards and items ----------------------------------------------------------------------------------------------


func test_wobble_weights_costs_two_to_equip_and_gives_less() -> void:
	var card: CardData = content.card("NB-13")
	assert_not_null(card)
	assert_true(card.rules_text.contains("pay 2: attach"), card.rules_text)
	assert_true(card.rules_text.contains("Necrocrat unit, it gets +3/+3"), card.rules_text)
	assert_true(card.rules_text.contains("Beefcake units you control get +1/+1"), card.rules_text)
	assert_true(card.script_text.contains("attach | pay(2)"), card.script_text)
	assert_true(card.script_text.contains("stat(3,3)"), card.script_text)
	assert_true(card.script_text.contains("host_is(B) => stat(1,1)"), card.script_text)


func test_the_crown_of_mild_hubris_costs_ten_max_hp() -> void:
	var crown: EquipmentData = content.equipment_piece("hubris_crown")
	assert_not_null(crown)
	var loss: int = 0
	for modifier: Modifier in crown.modifiers:
		if modifier.kind == Modifier.Kind.MAX_HP:
			loss += modifier.value
	assert_eq(loss, -10)
	assert_true(crown.description.contains("Max HP -10"), crown.description)
	assert_eq(crown.drawback, "Max HP -10.")


func test_silence_powder_tosses_one_and_the_charm_summons_two() -> void:
	var code: Dictionary = ProgressionContent.items(content.tokens)
	for powder: ItemData in [content.item("silence_powder"), code.get("silence_powder") as ItemData]:
		assert_eq(powder.effect.amount, 1)
		assert_true(powder.description.contains("tosses 1 random card"), powder.description)
	for charm: ItemData in [content.item("summoning_charm"), code.get("summoning_charm") as ItemData]:
		assert_eq(charm.effect.amount, 2)
		assert_true(charm.description.contains("two 1/1 Militia"), charm.description)


# ---- 1.7 the deck builder --------------------------------------------------------------------------------------------------------


func test_the_type_selector_offers_infrastructure() -> void:
	assert_true(CardFilterBar.TYPE_LABELS.has("Infrastructure"))
	var bar: CardFilterBar = CardFilterBar.new()
	add_child_autofree(bar)
	assert_eq(bar._card_type_for(CardFilterBar.TYPE_LABELS.find("Infrastructure")), int(CardEnums.CardType.INFRASTRUCTURE))
	bar.type_filter = int(CardEnums.CardType.INFRASTRUCTURE)
	var infrastructure: CardData = null
	var unit: CardData = null
	for card: CardData in content.cards.values():
		if card.type == CardEnums.CardType.INFRASTRUCTURE and infrastructure == null:
			infrastructure = card
		if card.type == CardEnums.CardType.UNIT and unit == null:
			unit = card
	assert_true(bar.matches(infrastructure))
	assert_false(bar.matches(unit))


## The battle deck as a legal list: at most three copies of a card (the developer shortcut `ensure_game` adds showcase cards past the
## cap), filled up to the minimum with a basic Infrastructure.
func _legal_cards() -> Array[CardData]:
	var cards: Array[CardData] = []
	var copies: Dictionary = {}
	var basic: CardData = null
	for card: CardData in Session.deck.cards:
		if card.is_basic:
			basic = card
			cards.append(card)
			continue
		copies[card.id] = int(copies.get(card.id, 0)) + 1
		if int(copies[card.id]) <= 3:
			cards.append(card)
	while basic != null and cards.size() < 45:
		cards.append(basic)
	return cards


func test_a_newly_created_legal_deck_becomes_the_battle_deck() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.profile.level = 30
	var screen: DeckbuilderScreen = DeckbuilderScreen.new()
	add_child_autofree(screen)
	await wait_frames(2)
	var before: int = Session.deck_box.active
	var slot: int = -1
	for candidate: int in range(1, 10):
		if Session.slot_open(candidate) and Session.deck_box.index_in_slot(candidate) < 0:
			slot = candidate
			break
	assert_gt(slot, 0, "a free slot")
	var cards: Array[CardData] = _legal_cards()
	screen._start_new_deck(slot)
	screen.editor.deck.cards = cards
	assert_true(screen.editor.is_valid(), "the copied battle deck is legal: %s" % ("" if screen.editor.is_valid() else screen.editor.issues()[0].message))
	assert_true(screen.save_to_slot(slot))
	assert_ne(Session.deck_box.active, before, "the new deck is in use")
	assert_eq(Session.deck_box.decks[Session.deck_box.active].slot, slot)
	# saving an existing deck again never switches decks
	Session.use_deck(before)
	screen._edit_deck(Session.deck_box.index_in_slot(slot))
	assert_true(screen.save_to_slot(slot))
	assert_eq(Session.deck_box.active, before)


func test_an_unfinished_new_deck_is_not_put_in_use() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	Session.profile.level = 30
	var screen: DeckbuilderScreen = DeckbuilderScreen.new()
	add_child_autofree(screen)
	await wait_frames(2)
	var before: int = Session.deck_box.active
	var slot: int = -1
	for candidate: int in range(1, 10):
		if Session.slot_open(candidate) and Session.deck_box.index_in_slot(candidate) < 0:
			slot = candidate
			break
	screen._start_new_deck(slot)
	assert_true(screen.save_to_slot(slot))
	assert_eq(Session.deck_box.active, before, "an empty deck is saved but the battle deck stays")
	# ... and it is put in use at the first save at which it is legal
	screen.editor.deck.cards = _legal_cards()
	assert_true(screen.save_to_slot(slot))
	assert_eq(Session.deck_box.decks[Session.deck_box.active].slot, slot)


# ---- 1.8 Pathwork ----------------------------------------------------------------------------------------------------------------


func test_the_kingdom_is_pathwork() -> void:
	assert_eq(RoyalFamilyData.new().kingdom, "Pathwork")
	assert_eq((load("res://data/story/royal_family.tres") as RoyalFamilyData).kingdom, "Pathwork")
	for path: String in ["res://data/loading/loading_tips.txt", "res://data/npcs/npcs.json", "res://data/progression/level_track.json", "res://data/credits/credits.txt"]:
		assert_false(FileAccess.get_file_as_string(path).contains("Patchwork"), path)
	# left on purpose: the Patchwork Body token (a stitched body) and the Dump's Patchwork Fields (a field of patches)
	assert_eq(content.tokens.get("T-21").display_name, "Patchwork Body")


# ---- 1.9 the Mirror Knight's reflections -----------------------------------------------------------------------------------------


func test_the_mirror_knights_reflection_wears_his_own_picture() -> void:
	var raw: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/encounters/encounter_scripts.json")) as Dictionary
	var effect: Dictionary = (((raw["Mirror Knight"] as Array)[0] as Dictionary)["effects"] as Array)[0] as Dictionary
	var token: CardData = EncounterModifiers._token_of(effect, "Mirror Knight")
	assert_eq(token.display_name, "Reflection")
	assert_eq(token.art_override, "res://assets/art/bestiary/BST-MIRROR-KNIGHT.webp")
	assert_true(ResourceLoader.exists(token.art_override), "the Knight's picture is in the game")
	assert_lt(token.art_tint.r, token.art_tint.b, "a cool, silvery tint")
	assert_eq(TokenRegistry.data("T-16").art_override, "", "the Militia token itself is untouched")
	var view: CardView = CardView.create(token)
	add_child_autofree(view)
	await wait_frames(1)
	var picture: TextureRect = view.find_child("ArtPicture", true, false) as TextureRect
	assert_not_null(picture)
	if picture != null:
		assert_eq(((picture.texture as AtlasTexture).atlas as Texture2D).resource_path, token.art_override)
		assert_eq(picture.modulate, token.art_tint)


# ---- 1.10 max-HP curses by depth -------------------------------------------------------------------------------------------------


func test_max_hp_curses_are_scaled_by_depth() -> void:
	var regex: RegEx = RegEx.new()
	regex.compile("max_hp=(-\\d+)")
	var seen: int = 0
	for blueprint: DungeonCatalog.Blueprint in DungeonCatalog.all():
		var block: Dictionary = DungeonCatalog.content_for(blueprint.id)
		var deep_dungeon: bool = blueprint.type == DungeonCatalog.TYPE_FINAL or blueprint.is_postgame() or blueprint.id == "S-GALLERY"
		var events: Dictionary = block.get("events", {}) as Dictionary
		for number: Variant in events.keys():
			var node: DungeonCatalog.BlueprintNode = blueprint.node(int(str(number)))
			for found: RegExMatch in regex.search_all(JSON.stringify(events[number])):
				var loss: int = int(found.get_string(1))
				seen += 1
				if deep_dungeon:
					assert_between(loss, -8, -6, "%s room %s: the castle and the postgame take 6 to 8" % [blueprint.id, number])
				elif node != null and node.csv_position.x >= 0.5:
					assert_between(loss, -5, -4, "%s room %s: deep in a zone dungeon, 4 to 5" % [blueprint.id, number])
				else:
					assert_between(loss, -3, -2, "%s room %s: early in a zone dungeon, 2 to 3" % [blueprint.id, number])
	assert_gt(seen, 3)
	# the castle's events that are still built in code
	var code: String = FileAccess.get_file_as_string("res://core/dungeon/primms_castle_dungeon.gd")
	for found: RegExMatch in regex.search_all(code):
		assert_between(int(found.get_string(1)), -8, -6, "the castle's own events")
