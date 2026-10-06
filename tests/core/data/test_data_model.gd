extends GutTest

const TMP_PATH: String = "user://test_card_roundtrip.tres"


func test_affinity_has_four_colors_plus_neutral() -> void:
	assert_eq(Affinity.colored_types().size(), 4)
	assert_eq(Affinity.Type.size(), 5)
	assert_eq(Affinity.display_name(Affinity.Type.BEEFCAKE), "Beefcake")
	assert_eq(Affinity.display_name(Affinity.Type.NEUTRAL), "Colorless")


func test_card_energy_value_and_helpers() -> void:
	var card: CardData = CardBuilder.unit("c1", "Test", Affinity.Type.BEEFCAKE, 2, [Affinity.Type.BEEFCAKE, Affinity.Type.BEEFCAKE], 3, 2)
	assert_eq(card.energy_value(), 4)
	assert_true(card.is_unit())
	assert_true(card.is_permanent())
	assert_false(card.is_infrastructure())


func test_infrastructure_builder_is_basic_and_colored() -> void:
	var infra: CardData = CardBuilder.infra(Affinity.Type.GOURMAND)
	assert_true(infra.is_infrastructure())
	assert_true(infra.is_basic)
	assert_eq(infra.color, Affinity.Type.GOURMAND)
	assert_eq(infra.energy_value(), 0)


func test_keywords_and_effect_lookup() -> void:
	var kws: Array[CardEnums.Keyword] = [CardEnums.Keyword.FLYING, CardEnums.Keyword.HUSTLE]
	var card: CardData = CardBuilder.unit("c2", "Flyer", Affinity.Type.GOURMAND, 1, [], 1, 1, kws)
	CardBuilder.with_effect(card, CardBuilder.effect(CardEnums.Trigger.ON_ENTER, CardEnums.TargetKind.CONTROLLER, CardEnums.EffectOp.DRAW, 1))
	assert_true(card.has_keyword(CardEnums.Keyword.FLYING))
	assert_false(card.has_keyword(CardEnums.Keyword.SWAT))
	assert_eq(card.effects_for(CardEnums.Trigger.ON_ENTER).size(), 1)
	assert_eq(card.effects_for(CardEnums.Trigger.ON_DEATH).size(), 0)
	assert_true(card.has_trigger(CardEnums.Trigger.ON_ENTER))


func test_card_resource_roundtrip_through_tres() -> void:
	var card: CardData = CardBuilder.unit("rt", "Roundtrip", Affinity.Type.REFUSEMANCER, 1, [Affinity.Type.REFUSEMANCER], 2, 3, [CardEnums.Keyword.BULLDOZE])
	var e: EffectData = CardBuilder.effect(CardEnums.Trigger.ON_DEATH, CardEnums.TargetKind.OPPONENT, CardEnums.EffectOp.DEAL_DAMAGE, 2)
	e.token = CardBuilder.token("tok", "Token", 1, 1)
	CardBuilder.with_effect(card, e)
	assert_eq(ResourceSaver.save(card, TMP_PATH), OK)
	var loaded: CardData = ResourceLoader.load(TMP_PATH, "", ResourceLoader.CACHE_MODE_IGNORE) as CardData
	assert_not_null(loaded)
	assert_eq(loaded.id, "rt")
	assert_eq(loaded.color, Affinity.Type.REFUSEMANCER)
	assert_eq(loaded.colored_pips, [Affinity.Type.REFUSEMANCER] as Array[Affinity.Type])
	assert_eq(loaded.attack, 2)
	assert_eq(loaded.defense, 3)
	assert_true(loaded.has_keyword(CardEnums.Keyword.BULLDOZE))
	assert_eq(loaded.effects.size(), 1)
	assert_eq(loaded.effects[0].op, CardEnums.EffectOp.DEAL_DAMAGE)
	assert_eq(loaded.effects[0].token.id, "tok")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TMP_PATH))


func test_deck_counts() -> void:
	var deck: Deck = Deck.new()
	var a: CardData = CardBuilder.unit("a", "A", Affinity.Type.BEEFCAKE, 1, [], 1, 1)
	var infra: CardData = CardBuilder.infra(Affinity.Type.GOURMAND)
	deck.cards = [a, a, infra, infra, infra] as Array[CardData]
	assert_eq(deck.size(), 5)
	assert_eq(deck.count_of("a"), 2)
	assert_eq(deck.infrastructure_count(), 3)
	assert_eq(deck.copy_counts()["a"], 2)
	var colors: Array[Affinity.Type] = deck.colors()
	assert_eq(colors.size(), 2)
	assert_true(colors.has(Affinity.Type.BEEFCAKE))
	assert_true(colors.has(Affinity.Type.GOURMAND))


func test_deck_colors_ignore_neutral() -> void:
	var deck: Deck = Deck.new()
	deck.cards = [CardBuilder.unit("n", "N", Affinity.Type.NEUTRAL, 1, [], 1, 1)] as Array[CardData]
	assert_eq(deck.colors().size(), 0)


func test_profile_defaults_and_clamping() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	assert_eq(profile.base_max_hp(), 10)
	assert_eq(profile.base_opening_hand(), 5)
	assert_eq(profile.max_hand_size, 10)
	profile.max_hp = 99
	profile.opening_hand_size = 12
	assert_eq(profile.base_max_hp(), 25)
	assert_eq(profile.base_opening_hand(), 8)
	profile.max_hp = 1
	profile.opening_hand_size = 0
	assert_eq(profile.base_max_hp(), 10)
	assert_eq(profile.base_opening_hand(), 5)


func test_modifier_set_sums_by_kind_and_color() -> void:
	var mods: ModifierSet = ModifierSet.new()
	mods.add(CardBuilder.modifier(Modifier.Kind.MAX_HP, 3))
	mods.add(CardBuilder.modifier(Modifier.Kind.MAX_HP, 2))
	mods.add(CardBuilder.modifier(Modifier.Kind.COST_CHANGE, -1, Affinity.Type.BEEFCAKE))
	mods.add(CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, Affinity.Type.GOURMAND, 2))
	mods.add(CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, Modifier.ANY_COLOR, 0))
	assert_eq(mods.sum(Modifier.Kind.MAX_HP), 5)
	assert_eq(mods.sum(Modifier.Kind.EXTRA_DRAWS), 0)
	assert_eq(mods.sum_for_color(Modifier.Kind.COST_CHANGE, Affinity.Type.BEEFCAKE), -1)
	assert_eq(mods.sum_for_color(Modifier.Kind.COST_CHANGE, Affinity.Type.GOURMAND), 0)
	assert_eq(mods.stat_bonus(Affinity.Type.GOURMAND), Vector2i(2, 2))
	assert_eq(mods.stat_bonus(Affinity.Type.BEEFCAKE), Vector2i(1, 0))


func test_profile_gear_modifiers_collects_equipment_and_items() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	var sword: ModifierSource = CardBuilder.modifier_source("Ring", ModifierSource.SourceKind.EQUIPMENT, [CardBuilder.modifier(Modifier.Kind.MAX_HP, 2)] as Array[Modifier])
	var potion: ModifierSource = CardBuilder.modifier_source("Charm", ModifierSource.SourceKind.ITEM, [CardBuilder.modifier(Modifier.Kind.EXTRA_DRAWS, 1)] as Array[Modifier])
	profile.equipment = [sword] as Array[ModifierSource]
	profile.items = [potion] as Array[ModifierSource]
	var mods: ModifierSet = profile.gear_modifiers()
	assert_eq(mods.sum(Modifier.Kind.MAX_HP), 2)
	assert_eq(mods.sum(Modifier.Kind.EXTRA_DRAWS), 1)


func test_modifier_set_clone_is_independent() -> void:
	var mods: ModifierSet = ModifierSet.new()
	mods.add(CardBuilder.modifier(Modifier.Kind.MAX_HP, 1))
	var copy: ModifierSet = mods.clone()
	copy.add(CardBuilder.modifier(Modifier.Kind.MAX_HP, 5))
	assert_eq(mods.sum(Modifier.Kind.MAX_HP), 1)
	assert_eq(copy.sum(Modifier.Kind.MAX_HP), 6)
