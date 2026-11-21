extends GutTest
## Fable Nov 21 review (Part 4): text polish. The dialogue is written in British spelling and the fourteen lines that were not are
## fixed; the interface says "Paths", never "colors"; the glossary names every rule added since Nov 17 (three copies owned, essence and
## the Alembic's 6 / 18, the three-Path lock, the resting places, Pathless).

const DIALOGUE_FILES: Array[String] = [
	"res://data/story/intro_story.tres", "res://data/story/gainlands_story.tres", "res://data/story/gourmand_story.tres",
	"res://data/story/dna_story.tres", "res://data/story/refusemancer_story.tres", "res://data/story/capital_story.tres",
	"res://data/story/story_scenes.json", "res://data/story/old_well_story.json", "res://data/dungeons/dungeon_content.json",
	"res://data/vendors/vendor_lines.json", "res://data/encounters/boss_intros.json", "res://data/encounters/encounter_scripts.json",
]
## American spellings the dialogue does not use (names and game terms keep theirs: Defense, the Armor slot, the Honor Guard, the
## Extraction Theater).
const AMERICAN: String = "\\b(colors|colored|favorite|favor|center|recognize|recognized|apologize|gray|neighbor|rumor|rumors|traveler|mustache)\\b"


func test_the_dialogue_keeps_to_british_spelling() -> void:
	var pattern: RegEx = RegEx.new()
	pattern.compile(AMERICAN)
	var checked: int = 0
	for path: String in DIALOGUE_FILES:
		if not FileAccess.file_exists(path):
			continue
		checked += 1
		var found: PackedStringArray = []
		for line: String in FileAccess.get_file_as_string(path).split("\n"):
			# a line of notes for the developer ("_about", "theme", "art_direction") is not dialogue
			if line.contains("\"_about\"") or line.contains("\"_note\""):
				continue
			for hit: RegExMatch in pattern.search_all(line):
				found.append("%s in: %s" % [hit.get_string(), line.strip_edges().left(90)])
		assert_eq(found.size(), 0, "%s: %s" % [path.get_file(), "; ".join(found)])
	assert_gte(checked, 10)


func test_the_interface_says_paths_not_colors() -> void:
	for path: String in ["res://ui/town/card_filter_bar.gd", "res://ui/town/deckbuilder_screen.gd"]:
		var text: String = FileAccess.get_file_as_string(path)
		assert_false(text.contains("All colors"), "%s: the filter's first entry is 'All Paths'" % path.get_file())
		assert_false(text.contains("deck's colors"), "%s: 'your deck's Paths'" % path.get_file())
		assert_false(text.contains("color%s[/b]"), "%s: the deck tip counts Paths" % path.get_file())


func test_the_level_track_headline_is_spelled_as_the_dialogue_is() -> void:
	assert_true(FileAccess.get_file_as_string("res://data/progression/level_track.json").contains("Seasoned traveller"))


func _terms() -> Dictionary:
	var index: int = GlossaryPanel.TABS.find("Terms")
	var terms: Dictionary = {}
	for entry: Array in GlossaryPanel.entries(index):
		terms[str(entry[0])] = str(entry[1])
	return terms


func test_the_glossary_names_every_rule_added_since_nov_17() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.ensure_game(Affinity.Type.BEEFCAKE)
	var terms: Dictionary = _terms()
	# three copies owned
	assert_true(str(terms.get("Copies of a card", "")).contains("own up to 3 copies"), "the three-copies rule")
	# the three-Path lock
	assert_true(terms.has(MultiPathLock.RULE_TITLE), "the three-Path lock")
	# Pathless
	assert_true(terms.has("Pathless"))
	# essence, the copy notice and the Alembic's 6 / 18
	var essence: String = str(terms.get("Essence", ""))
	assert_true(essence.contains("%d essence of each" % Alchemy.MIN_ESSENCE_PER_PATH), "a brew's price in essence (%s)" % essence)
	assert_true(essence.contains("at most %d essence" % Alchemy.ESSENCE_CAP_PER_PATH), "a Path's cap")
	assert_true(essence.contains("%d gold" % Alchemy.GOLD_COST), "a brew's price in gold")
	assert_true(essence.contains("notice"), "the copy notice is named")
	assert_eq(Alchemy.MIN_ESSENCE_PER_PATH, 6)
	assert_eq(Alchemy.ESSENCE_CAP_PER_PATH, 18)
	# the heal rooms
	var resting: String = str(terms.get("Resting places", ""))
	assert_true(resting.contains("heal 5 HP for a price"), "the heal rooms' rule")


## The glossary says only the cave and the castle heal in full: that has to stay true.
func test_the_full_heal_rooms_are_the_ones_the_glossary_names() -> void:
	DungeonCatalog.reset()
	for room: Array in DungeonBuilder.full_heal_rooms():
		assert_true(str(room[0]) == DungeonCatalog.TUTORIAL_ID or str(room[0]) == "D-PC", "%s (%s) heals in full: the glossary names only the cave and the castle" % [room[1], room[0]])


## Part 7.5: the credits name the creator and list the tools honestly (the engine, the image tool, the coding and writing assistant,
## the music renderer), and say which parts were made with AI tools.
func test_the_credits_name_the_creator_and_the_tools() -> void:
	assert_eq(CreditsPanel.creator(), "Alex Glowatz")
	var all_text: String = ""
	for row: Array in CreditsPanel.paragraphs():
		all_text += str(row[1]) + "\n"
	assert_true(all_text.contains("A game by Alex Glowatz"))
	for needed: String in ["Godot Engine", "ChatGPT", "Claude", "FluidSynth", "FluidR3_GM", "Kenney", "KayKit", "game-icons.net", "Freesound"]:
		assert_true(all_text.contains(needed), "the credits name %s" % needed)
	assert_true(all_text.contains("made with AI tools, directed and curated by the creator"), "the art and music line")
	assert_true(all_text.contains("design and writing are the creator's, with AI assistance"), "the design and writing line")
	assert_true(all_text.contains("code was written with an AI coding assistant"), "the code line")


## "neutral" was the word before "Colorless", which is "Pathless" since Nov 21: the pack descriptions, Sable's first talk and the
## Neutral Mile's rule line still said "neutral cards" (the bout keeps its name).
func test_no_shown_text_calls_pathless_cards_neutral() -> void:
	for pack: PackData in PackCatalog.all():
		assert_false(PackShop.describe(pack).to_lower().contains("neutral"), "%s: %s" % [pack.id, PackShop.describe(pack)])
	var path_pack: PackData = PackCatalog.find("path_beefcake")
	assert_true(PackShop.describe(path_pack).contains("Beefcake cards and Pathless cards"), PackShop.describe(path_pack))
	for path: String in DIALOGUE_FILES:
		if FileAccess.file_exists(path):
			assert_false(FileAccess.get_file_as_string(path).contains("neutral cards"), "%s still says 'neutral cards'" % path.get_file())
