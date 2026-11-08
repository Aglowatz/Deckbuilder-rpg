extends GutTest
## Fix pass Nov 4 (B), Part 1.2: Mount Swolympus (S-BEEF) opens after Primm. Old Man Mountain's "Only the Worthy..." is offered only in the postgame; handing it
## in unlocks S-BEEF; the trailhead gate then opens (its barrier no longer blocks), the collapsed span is rebuilt and the ridge is walkable to the trail.

var builder: GainlandsBuilder
var layout: GainlandsLayout


func before_all() -> void:
	var host: Node3D = Node3D.new()
	add_child(host)
	builder = GainlandsBuilder.new()
	builder.build(host)
	layout = builder.layout


func after_all() -> void:
	builder.root.get_parent().queue_free()


func before_each() -> void:
	Session.save_enabled = false
	Session.new_game()
	Session.profile = CampaignStart.new_profile(ContentLibrary.load_all(), Affinity.Type.BEEFCAKE)


func test_the_quest_is_only_offered_after_primm_and_unlocks_s_beef() -> void:
	var quest: QuestData = QuestCatalog.find(ZoneQuestDefinitions.SIDE_BEEF)
	assert_not_null(quest)
	assert_eq(quest.title, "Only the Worthy...")
	assert_eq(quest.giver_npc, GainlandsZone.NPC_BRENDA, "Old Man Mountain gives it")
	assert_false(Condition.met(quest.prerequisite, Session.unlock_state()), "not before Primm falls")
	Session.profile.postgame_unlocked = true
	Session.set_flag(&"primm_defeated")
	assert_true(Condition.met(quest.prerequisite, Session.unlock_state()), "offered once the kingdom is whole again")
	assert_has(quest.reward_unlock_flags, str(DungeonCatalog.side_unlock_flag("S-BEEF")), "handing it in unlocks the climb")


func test_old_man_mountain_hints_at_the_gate_and_offers_the_climb() -> void:
	var story: ZoneStoryText = ZoneStoryText.for_zone(GainlandsZone.ID)
	var hint: String = " ".join(story.get_lines("npc.brenda.return"))
	assert_string_contains(hint, "when the kingdom is whole again")
	assert_false(story.get_lines("quest.side_s_beef.offer").is_empty(), "the offer has dialogue")
	assert_string_contains(" ".join(story.get_lines("quest.side_s_beef.offer")), "Only the worthy")


func test_s_beef_has_a_map_a_battleboard_and_music() -> void:
	var plan: DungeonCatalog.Blueprint = DungeonCatalog.find("S-BEEF")
	assert_eq(MainDungeons.build_map("S-BEEF").problems(), [] as Array[String], "a sound node map")
	assert_true(ResourceLoader.exists("res://assets/art/maps/MAP-S-BEEF.webp"), "its painted map")
	assert_true(ResourceLoader.exists("res://assets/art/battleboards/BB-S-BEEF.webp"), "its battleboard")
	assert_eq(str((MusicDirector.DUNGEONS["S-BEEF"] as Dictionary)["exp"]), "MUS-SWOLY-EXP", "its own music")
	assert_eq(plan.map_id, "MAP-S-BEEF")


func test_opening_mount_swolympus_makes_the_ridge_walkable_to_the_trail() -> void:
	var gate: Vector3 = layout.anchors[GainlandsZone.SWOLYMPUS_GATE] as Vector3
	var foot: Vector3 = layout.anchors["swolympus_foot"] as Vector3
	assert_false(builder.is_walkable(Vector3(foot.x, 0.0, foot.z), 0.3), "sealed: the trail is out of reach")
	assert_false(builder.is_walkable(Vector3(gate.x + 0.0, 0.0, gate.z), 0.3), "sealed: the barrier blocks the gate")
	builder.open_swolympus(false)
	var ridge: Node3D = builder.root.find_child("SwolympusRidge", false, false) as Node3D
	assert_true((ridge.get_node("RebuiltSpan") as Node3D).visible, "the collapsed span is rebuilt")
	assert_false((ridge.get_node("CollapseLip") as Node3D).visible, "the broken lip is gone")
	for point: Vector2 in GainlandsLayout.RIDGE:
		assert_true(builder.is_walkable(Vector3(point.x, 0.0, point.y), 0.3), "the ridge is walkable at %s" % str(point))
	var walk: Callable = func(pos: Vector3) -> bool: return builder.is_walkable(pos, 0.3)
	var start: Vector3 = gate + Vector3(-3.0, 0.0, 3.0)
	assert_eq(WalkProbe.unreachable(walk, start, builder.map_bounds(), {"trail": foot}), [] as Array[String], "through the open gate and along the ridge to the trail")
	var trail: Dictionary = {}
	for spot: Dictionary in GainlandsZone.build_def().spots:
		if str(spot["id"]) == GainlandsZone.SWOLYMPUS_TRAIL:
			trail = spot
	assert_eq(str(trail.get("anchor", "")), "swolympus_foot", "the climb starts at the trail")


## Overnight Nov 7-8, Part 1.9: with the gate shut, no ground behind it can be reached from the meadow on any side (a flood fill over the walkable
## ground at 0.5 m from the plaza in front of the gate never reaches the strip behind the barrier or the crag beside the west tower).
func test_nothing_behind_the_shut_gate_can_be_reached_from_any_side() -> void:
	var host: Node3D = Node3D.new()
	add_child_autofree(host)
	var shut: GainlandsBuilder = GainlandsBuilder.new()  # its own build: an earlier test opens the shared builder's gate
	shut.build(host)
	assert_false(shut.swolympus_open)
	var builder: GainlandsBuilder = shut
	var gate: Vector3 = shut.layout.anchors[GainlandsZone.SWOLYMPUS_GATE] as Vector3
	var basis: Basis = Basis(Vector3.UP, deg_to_rad(GainlandsBuilder.SWOLYMPUS_GATE_YAW))
	var start: Vector3 = gate + basis * Vector3(0.0, 0.0, 4.0)
	assert_true(builder.is_walkable(Vector3(start.x, 0, start.z), 0.3), "the meadow in front of the gate")
	var step: float = 0.5
	var seen: Dictionary = {}
	var queue: Array[Vector2i] = [Vector2i.ZERO]
	seen[Vector2i.ZERO] = true
	var reached_behind: Array[Vector2] = []
	while not queue.is_empty() and seen.size() < 40000:
		var cell: Vector2i = queue.pop_front()
		for offset: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var next: Vector2i = cell + offset
			if seen.has(next) or absi(next.x) > 60 or absi(next.y) > 60:
				continue
			var world: Vector3 = start + Vector3(float(next.x) * step, 0.0, float(next.y) * step)
			var mid: Vector3 = start + Vector3((float(cell.x) + float(offset.x) * 0.5) * step, 0.0, (float(cell.y) + float(offset.y) * 0.5) * step)
			if not builder.is_walkable(Vector3(world.x, 0, world.z), 0.3) or not builder.is_walkable(Vector3(mid.x, 0, mid.z), 0.3):
				continue
			seen[next] = true
			queue.append(next)
			var local: Vector3 = basis.inverse() * (world - gate)
			if local.z < -1.2 and absf(local.x) < 18.0:
				reached_behind.append(Vector2(local.x, local.z))
	assert_eq(reached_behind.size(), 0, "nothing behind the gate is reachable: %s" % str(reached_behind.slice(0, 5)))
	assert_gt(seen.size(), 200, "the flood really ran over the meadow")
