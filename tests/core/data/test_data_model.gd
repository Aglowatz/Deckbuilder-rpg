extends GutTest

const TMP_PATH: String = "user://test_card_roundtrip.tres"


func test_affinity_has_four_colors_plus_neutral() -> void:
	assert_eq(Affinity.colored_types().size(), 4)
	assert_eq(Affinity.Type.size(), 5)
	assert_eq(Affinity.display_name(Affinity.Type.A), "Beefcake")
	assert_eq(Affinity.display_name(Affinity.Type.NEUTRAL), "Neutral")


func test_card_energy_value_and_helpers() -> void:
	var card: CardData = CardBuilder.creature("c1", "Test", Affinity.Type.A, 2, [Affinity.Type.A, Affinity.Type.A], 3, 2)
	assert_eq(card.energy_value(), 4)
	assert_true(card.is_creature())
	assert_true(card.is_permanent())
	assert_false(card.is_infrastructure())


func test_infrastructure_builder_is_basic_and_colored() -> void:
	var infra: CardData = CardBuilder.infra(Affinity.Type.B)
	assert_true(infra.is_infrastructure())
	assert_true(infra.is_basic)
	assert_eq(infra.color, Affinity.Type.B)
	assert_eq(infra.energy_value(), 0)


func test_keywords_and_effect_lookup() -> void:
	var kws: Array[CardEnums.Keyword] = [CardEnums.Keyword.FLYING, CardEnums.Keyword.HASTE]
	var card: CardData = CardBuilder.creature("c2", "Flyer", Affinity.Type.B, 1, [], 1, 1, kws)
	CardBuilder.with_effect(card, CardBuilder.effect(CardEnums.Trigger.ON_ENTER, CardEnums.TargetKind.CONTROLLER, CardEnums.EffectOp.DRAW, 1))
	assert_true(card.has_keyword(CardEnums.Keyword.FLYING))
	assert_false(card.has_keyword(CardEnums.Keyword.REACH))
	assert_eq(card.effects_for(CardEnums.Trigger.ON_ENTER).size(), 1)
	assert_eq(card.effects_for(CardEnums.Trigger.ON_DEATH).size(), 0)
	assert_true(card.has_trigger(CardEnums.Trigger.ON_ENTER))


func test_card_resource_roundtrip_through_tres() -> void:
	var card: CardData = CardBuilder.creature("rt", "Roundtrip", Affinity.Type.C, 1, [Affinity.Type.C], 2, 3, [CardEnums.Keyword.TRAMPLE])
	var e: EffectData = CardBuilder.effect(CardEnums.Trigger.ON_DEATH, CardEnums.TargetKind.OPPONENT, CardEnums.EffectOp.DEAL_DAMAGE, 2)
	e.token = CardBuilder.token("tok", "Token", 1, 1)
	CardBuilder.with_effect(card, e)
	assert_eq(ResourceSaver.save(card, TMP_PATH), OK)
	var loaded: CardData = ResourceLoader.load(TMP_PATH, "", ResourceLoader.CACHE_MODE_IGNORE) as CardData
	assert_not_null(loaded)
	assert_eq(loaded.id, "rt")
	assert_eq(loaded.color, Affinity.Type.C)
	assert_eq(loaded.colored_pips, [Affinity.Type.C] as Array[Affinity.Type])
	assert_eq(loaded.power, 2)
	assert_eq(loaded.toughness, 3)
	assert_true(loaded.has_keyword(CardEnums.Keyword.TRAMPLE))
	assert_eq(loaded.effects.size(), 1)
	assert_eq(loaded.effects[0].op, CardEnums.EffectOp.DEAL_DAMAGE)
	assert_eq(loaded.effects[0].token.id, "tok")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TMP_PATH))


func test_deck_counts() -> void:
	var deck: Deck = Deck.new()
	var a: CardData = CardBuilder.creature("a", "A", Affinity.Type.A, 1, [], 1, 1)
	var infra: CardData = CardBuilder.infra(Affinity.Type.B)
	deck.cards = [a, a, infra, infra, infra] as Array[CardData]
	assert_eq(deck.size(), 5)
	assert_eq(deck.count_of("a"), 2)
	assert_eq(deck.infrastructure_count(), 3)
	assert_eq(deck.copy_counts()["a"], 2)
	var colors: Array[Affinity.Type] = deck.colors()
	assert_eq(colors.size(), 2)
	assert_true(colors.has(Affinity.Type.A))
	assert_true(colors.has(Affinity.Type.B))


func test_deck_colors_ignore_neutral() -> void:
	var deck: Deck = Deck.new()
	deck.cards = [CardBuilder.creature("n", "N", Affinity.Type.NEUTRAL, 1, [], 1, 1)] as Array[CardData]
	assert_eq(deck.colors().size(), 0)


func test_profile_defaults_and_clamping() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	assert_eq(profile.base_max_life(), 10)
	assert_eq(profile.base_opening_hand(), 5)
	assert_eq(profile.max_hand_size, 10)
	profile.max_life = 99
	profile.opening_hand_size = 12
	assert_eq(profile.base_max_life(), 25)
	assert_eq(profile.base_opening_hand(), 8)
	profile.max_life = 1
	profile.opening_hand_size = 0
	assert_eq(profile.base_max_life(), 10)
	assert_eq(profile.base_opening_hand(), 5)


func test_modifier_set_sums_by_kind_and_color() -> void:
	var mods: ModifierSet = ModifierSet.new()
	mods.add(CardBuilder.modifier(Modifier.Kind.MAX_LIFE, 3))
	mods.add(CardBuilder.modifier(Modifier.Kind.MAX_LIFE, 2))
	mods.add(CardBuilder.modifier(Modifier.Kind.COST_CHANGE, -1, Affinity.Type.A))
	mods.add(CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, Affinity.Type.B, 2))
	mods.add(CardBuilder.modifier(Modifier.Kind.STAT_CHANGE, 1, Modifier.ANY_COLOR, 0))
	assert_eq(mods.sum(Modifier.Kind.MAX_LIFE), 5)
	assert_eq(mods.sum(Modifier.Kind.EXTRA_DRAWS), 0)
	assert_eq(mods.sum_for_color(Modifier.Kind.COST_CHANGE, Affinity.Type.A), -1)
	assert_eq(mods.sum_for_color(Modifier.Kind.COST_CHANGE, Affinity.Type.B), 0)
	assert_eq(mods.stat_bonus(Affinity.Type.B), Vector2i(2, 2))
	assert_eq(mods.stat_bonus(Affinity.Type.A), Vector2i(1, 0))


func test_profile_gear_modifiers_collects_equipment_and_items() -> void:
	var profile: PlayerProfile = PlayerProfile.new()
	var sword: ModifierSource = CardBuilder.modifier_source("Ring", ModifierSource.SourceKind.EQUIPMENT, [CardBuilder.modifier(Modifier.Kind.MAX_LIFE, 2)] as Array[Modifier])
	var potion: ModifierSource = CardBuilder.modifier_source("Charm", ModifierSource.SourceKind.ITEM, [CardBuilder.modifier(Modifier.Kind.EXTRA_DRAWS, 1)] as Array[Modifier])
	profile.equipment = [sword] as Array[ModifierSource]
	profile.items = [potion] as Array[ModifierSource]
	var mods: ModifierSet = profile.gear_modifiers()
	assert_eq(mods.sum(Modifier.Kind.MAX_LIFE), 2)
	assert_eq(mods.sum(Modifier.Kind.EXTRA_DRAWS), 1)


func test_modifier_set_clone_is_independent() -> void:
	var mods: ModifierSet = ModifierSet.new()
	mods.add(CardBuilder.modifier(Modifier.Kind.MAX_LIFE, 1))
	var copy: ModifierSet = mods.clone()
	copy.add(CardBuilder.modifier(Modifier.Kind.MAX_LIFE, 5))
	assert_eq(mods.sum(Modifier.Kind.MAX_LIFE), 1)
	assert_eq(copy.sum(Modifier.Kind.MAX_LIFE), 6)
