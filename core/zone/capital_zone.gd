class_name CapitalZone
extends RefCounted
## Constants and the `ZoneDef` of the Capital (Neatropolis): the final area the town's last entrance leads to, home of
## Primm's Perfection (the facade town), the four broken districts, the resistance hideout (the Crease) and the doors of
## Primm's Castle. Zone id `final` (the same id as `ZonePortals.FINAL_ID`). All text lives in `data/story/capital_story.tres`.
## Pure data: nothing here touches `Session` (see `CapitalInteractables`).

const ID: String = "final"
const DISPLAY_NAME: String = "The Capital"
const FULL_NAME: String = "The Capital: Neatropolis"
const HUB_NAME: String = "The Crease"

const NPC_MABBIT: String = "Wren"
const NPC_FIG: String = "Fig Sly"
const NPC_HESPER: String = "Nurse Hesper Dray"
const NPC_GUS: String = "Old Fern"
const NPC_TILDA: String = "Widow Pell"
const NPC_BRAM: String = "Gus"
const NPC_ODILE: String = "Chef Marlo"

const QUEST_BURIAL: String = "cap_burial"
const QUEST_WHEELS: String = "cap_wheels"
const QUEST_RECIPES: String = "cap_recipes"
const QUEST_UNTIDY: String = "cap_untidy"

## Counters / flags (quest objectives read these as Conditions).
const COUNTER_CHESTS: String = "cap_chests_opened"
const COUNTER_ENEMIES: String = "cap_enemies_defeated"
const COUNTER_DEFACED: String = "cap_defaced"
const COUNTER_RIFTS_SEALED: String = "cap_rifts_sealed"
const COUNTER_COMPLAINTS: String = "cap_complaints"
const COUNTER_WHEELS: String = "cap_wheels_freed"
const COUNTER_RECIPES: String = "cap_recipes_found"
const COUNTER_COMPOST: String = "cap_compost_rescued"
const FLAG_GATE_OPEN: StringName = &"cap_gate_open"
const FLAG_INSIDE: StringName = &"cap_inside"
const FLAG_TUNNEL_FOUND: StringName = &"cap_tunnel_found"
const FLAG_HUB_KNOWN: StringName = &"cap_hub_known"
const FLAG_STAMP: StringName = &"cap_stamp_found"
const FLAG_LAID_TO_REST: StringName = &"cap_laid_to_rest"
const FLAG_CABLE_CUT: StringName = &"cap_cable_cut"
const FLAG_PASTE_SPOILED: StringName = &"cap_paste_spoiled"
const FLAG_SEED_FOUND: StringName = &"cap_seed_found"
const FLAG_SEED_PLANTED: StringName = &"cap_seed_planted"
const FLAG_CASTLE_ENTERED: StringName = &"cap_castle_entered"
## Set when Primm is defeated: the facade is down, the rifts are sealed, the citizens are free.
const FLAG_FREED: StringName = &"zone_final_completed"
const SECRET_TUNNEL: String = "capital_old_joint_works"

## The correction fee charged when you wake at the hub.
const FEE: int = 20
## Rift damage per touch (small rifts, big rifts) and the seconds between touches.
const RIFT_DAMAGE: int = 1
const BIG_RIFT_DAMAGE: int = 2
const RIFT_COOLDOWN: float = 1.4

## Hidden chest rewards: id -> {gold, item, card, equipment}. Documented in docs/design/secrets.md - keep both in sync.
const CHEST_REWARDS: Dictionary = {
	"chest_wreck": {"gold": 60, "item": "field_bandage", "card": ""},
	"chest_rock": {"gold": 80, "item": "", "card": "G-26"},
	"chest_reek": {"gold": 40, "item": "healing_salve", "card": ""},
	"chest_crypt": {"gold": 90, "item": "", "card": "N-31"},
	"chest_cellar": {"gold": 70, "item": "hearty_pie", "card": ""},
	"chest_wheel": {"gold": 100, "item": "", "card": "B-31"},
	"chest_lane": {"gold": 120, "item": "vitality_charm", "card": ""},
	"chest_corner": {"gold": 50, "item": "ward_sigil", "card": ""},
	"chest_ward": {"gold": 150, "item": "", "card": "R-26"},
	# Polish round: the harder the chest is to reach, the better it pays (docs/design/secrets.md).
	"chest_facade_back": {"gold": 100, "card": "C-30"},
	"chest_facade_west": {"gold": 80, "item": "ward_sigil"},
	"chest_crease_e": {"gold": 60, "pack": "general_2"},
	"chest_crease_w": {"gold": 70, "item": "hearty_pie"},
	"chest_ward_n": {"gold": 120, "equipment": "cheaters_dice"},
	"chest_yard_corner": {"gold": 150, "cosmetic": "hat_top_hat"},
}

## Propaganda that can be defaced (spot ids) and the small reward for each.
const DEFACE_REWARD: int = 12
const DEFACE_SPOTS: Array[String] = ["portrait_f1", "portrait_f2", "portrait_f3", "portrait_a1", "portrait_a2", "portrait_a3"]

## The black market's items (id -> price).
const BLACK_MARKET_ITEMS: Dictionary = {
	"healing_draught": 40, "field_bandage": 25, "scroll_of_insight": 60, "firebrand_charm": 90,
	"vitality_charm": 120, "ward_sigil": 80, "binding_chains": 70, "summoning_charm": 110,
	"iron_ration": 60, "spice_pouch": 60, "bag_of_rubbish": 40, "blank_form": 60,
}

## Pickups (id -> counter or flag they feed): each can be taken once, and the progress is saved.
const PICKUPS: Dictionary = {
	"recipe_1": "recipe", "recipe_2": "recipe", "recipe_3": "recipe",
	"heap_1": "compost", "heap_2": "compost", "heap_3": "compost",
	"stamp": "stamp", "seed": "seed",
}


static func secret_id(kind: String, id: String) -> String:
	return "cap_%s_%s" % [kind, id]


static func build_def() -> ZoneDef:
	var def: ZoneDef = ZoneDef.new()
	def.id = ID
	def.display_name = DISPLAY_NAME
	def.full_name = FULL_NAME
	def.music = &"capital"
	def.scene_path = "res://scenes/capital_zone.tscn"
	def.story_path = "res://data/story/capital_story.tres"
	def.fee = FEE
	def.fee_label = "Correction fee"
	def.wake_speaker = NPC_HESPER
	def.flag_quiz_done = &"cap_quiz_done"
	def.flag_quiz_passed = &"cap_quiz_passed"
	def.flag_puzzle_solved = &"cap_puzzle_solved"
	def.flag_mini_cleared = &"cap_mini_cleared"
	def.flag_minigame_first = &"cap_minigame_first"
	def.flag_met_prefix = "cap"
	def.counter_chests = COUNTER_CHESTS
	def.counter_enemies = COUNTER_ENEMIES
	def.secret_prefix = "cap_"
	def.chest_rewards = CHEST_REWARDS
	def.vendor_ids = CapitalContent.BLACK_MARKET_CARD_IDS
	def.vendor_name = "Fig Sly's Contraband & Curiosities"
	def.vendor_title = "Fig Sly's Contraband & Curiosities - the Black Market"
	def.quest_npc_names = [NPC_GUS, NPC_TILDA, NPC_BRAM, NPC_ODILE]
	def.ruler_name = Villain.display_name()
	def.ruler_tint = Color("c9a227")
	def.gloom_tint = Color(0.5, 0.46, 0.58)
	def.hub_anchor = "crease_spawn"
	# The freed leaders stand in the Crease once Primm has fallen (their dialogue is the story keys `freed_npc.<id>`).
	def.freed_npcs = [
		{"id": "heartlift", "npc_id": "NPC-FLEX", "model": "Barbarian", "offset": Vector3(-6.0, 0.0, -3.0), "yaw": 180.0, "tint": Color(1.2, 0.9, 0.7), "scale": 1.9, "name": "Grandmaster Flex", "speaker": "Grandmaster Flex"},
		{"id": "aurelio", "npc_id": "NPC-ESCOFFINA", "model": "Rogue", "offset": Vector3(-2.0, 0.0, -3.5), "yaw": 180.0, "tint": Color(1.2, 1.1, 0.8), "scale": 1.5, "name": "Grand Chef Escoffina", "speaker": "Grand Chef Escoffina"},
		{"id": "vellum", "npc_id": "NPC-MORTIMER", "model": "Mage", "offset": Vector3(2.0, 0.0, -3.5), "yaw": 180.0, "tint": Color(0.85, 0.75, 1.2), "scale": 1.5, "name": "Mortimer Grimsby", "speaker": "Mortimer Grimsby"},
		{"id": "fernwick", "npc_id": "NPC-COMPOSTELLA", "model": "Mage", "offset": Vector3(6.0, 0.0, -3.0), "yaw": 180.0, "tint": Color(0.7, 1.1, 0.7), "scale": 1.6, "name": "Archdruid Compostella", "speaker": "Archdruid Compostella"},
	] as Array[Dictionary]
	def.npcs = [
		{"id": "mabbit", "npc_id": "NPC-WREN", "model": "Mage", "anchor": "mabbit", "yaw": 0.0, "tint": Color(0.85, 0.85, 1.1), "scale": 1.5},
		{"id": "fig", "npc_id": "V-FIGSLY", "model": "Rogue_Hooded", "anchor": "fig", "yaw": 0.0, "tint": Color(1.1, 0.9, 0.8), "scale": 1.5},
		{"id": "hesper", "model": "Mage", "anchor": "heal", "yaw": 180.0, "tint": Color(1.1, 1.0, 0.95), "scale": 1.45},
		{"id": "gus", "npc_id": "NPC-FERN", "model": "Barbarian", "anchor": "gus", "yaw": 0.0, "tint": Color(0.8, 1.0, 0.7), "scale": 1.6},
		{"id": "tilda", "npc_id": "NPC-PELL", "model": "Mage", "anchor": "tilda", "yaw": 180.0, "tint": Color(0.75, 0.7, 0.95), "scale": 1.45},
		{"id": "bram", "npc_id": "NPC-GUS", "model": "Barbarian", "anchor": "bram", "yaw": 180.0, "tint": Color(1.2, 0.85, 0.7), "scale": 1.85},
		{"id": "odile", "npc_id": "NPC-MARLO", "model": "Rogue", "anchor": "odile", "yaw": 180.0, "tint": Color(1.1, 0.95, 0.7), "scale": 1.5},
		{"id": "gate_captain", "npc_id": "NPC-SPOTLESS", "model": "Knight", "anchor": "gate_captain", "yaw": 0.0, "tint": Color(0.9, 0.9, 1.0), "scale": 1.7},
		{"id": "guard_height", "model": "Knight", "anchor": "guard_height", "yaw": 0.0, "tint": Color(0.85, 0.85, 0.95), "scale": 1.5},
		{"id": "guard_queue", "model": "Knight", "anchor": "guard_queue", "yaw": 0.0, "tint": Color(0.85, 0.85, 0.95), "scale": 1.5},
		{"id": "guard_in_1", "model": "Knight", "anchor": "guard_in_1", "yaw": 180.0, "tint": Color(0.85, 0.85, 0.95), "scale": 1.5},
		{"id": "guard_in_2", "model": "Knight", "anchor": "guard_in_2", "yaw": 180.0, "tint": Color(0.85, 0.85, 0.95), "scale": 1.5},
		{"id": "exit_clerk", "model": "Rogue_Hooded", "anchor": "exit_booth", "yaw": 90.0, "tint": Color(0.9, 0.9, 0.9), "scale": 1.4},
		{"id": "patient", "model": "Rogue", "anchor": "ward_patient", "yaw": 180.0, "tint": Color(0.75, 0.75, 0.8), "scale": 1.4},
	]
	for index: int in range(1, 10):
		def.npcs.append({"id": "citizen_%d" % index, "npc_id": "NPC-CITIZEN", "model": "Rogue", "anchor": "citizen_%d" % index, "yaw": 180.0 if index % 2 == 0 else 0.0, "tint": Color(1.25, 1.1, 1.05), "scale": 1.4, "facade": true})
	def.spots = _spots()
	def.poi_kinds = _poi_kinds()
	return def


static func _spots() -> Array[Dictionary]:
	var spots: Array[Dictionary] = []
	# The hub (the Crease).
	spots.append(_spot("mabbit", "Wren, Resistance Leader", "mabbit", Vector3(0, 0, 1.0), 1.8, "Talk", "zone", {"npc": "mabbit", "npc_id": "NPC-WREN", "speaker": "Wren", "act": "mabbit"}))
	spots.append(_spot("fig", "Fig Sly's Contraband & Curiosities", "fig", Vector3(0, 0, 1.0), 1.8, "Browse the black market", "vendor_npc", {"npc": "fig", "npc_id": "V-FIGSLY", "npc_name": NPC_FIG, "speaker": "Fig Sly"}))
	spots.append(_spot("fig_crate", "Fig's Crate of Supplies", "fig_crate", Vector3(0, 0, 0.0), 1.8, "Buy supplies", "zone", {"act": "supplies"}))
	spots.append(_spot("heal", "The Tea of Dissent", "heal", Vector3(0, 0, 1.0), 1.8, "Take a cup of the Tea of Dissent (full heal)", "heal"))
	spots.append(_spot("ladder_up", "The Ladder (to the Reek)", "ladder_up", Vector3(0, 0, 0.0), 1.6, "Climb the ladder up to the Capital", "zone", {"act": "ladder"}))
	spots.append(_spot("tunnel_out", "The Old Joint Works Tunnel", "tunnel_out", Vector3(0, 0, 0.0), 1.8, "Crawl out through the tunnel to the Outskirts", "zone", {"act": "tunnel_out"}))
	for destination: String in CapitalLayout.NETWORK_DESTINATIONS:
		spots.append(_spot("shaft_" + destination, "Service Shaft", "shaft_" + destination, Vector3(0, 0, -0.9), 1.5, "Take the service shaft", "zone", {"act": "shaft", "dest": destination}))
	# The Outskirts.
	spots.append(_spot("exit", "The Road Back to Concord Crossing", "exit", Vector3(0, 0, 0.0), 1.9, "Walk back to town (full heal)", "exit"))
	spots.append(_spot("gate_captain", "The Approved Gate Captain", "gate_captain", Vector3(0, 0, 1.0), 1.9, "Talk", "zone", {"npc": "gate_captain", "npc_id": "NPC-SPOTLESS", "speaker": "Captain Spotless", "act": "gate_captain"}))
	spots.append(_spot("guard_height", "Gate Guard (Height Inspection)", "guard_height", Vector3(0, 0, 1.0), 1.7, "Talk", "zone", {"npc": "guard_height", "speaker": "Gate Guard", "act": "guard"}))
	spots.append(_spot("guard_queue", "Gate Guard (Queue Management)", "guard_queue", Vector3(0, 0, 1.0), 1.7, "Talk", "zone", {"npc": "guard_queue", "speaker": "Gate Guard", "act": "guard"}))
	spots.append(_spot("tunnel_in", "Collapsed Service Shaft", "tunnel_in", Vector3(0, 0, 0.0), 1.5, "Squeeze through the gap", "zone", {"act": "tunnel_in", "hidden": true}))
	# Checkpoint Plaza (inside the gate).
	spots.append(_spot("guard_in_1", "Gate Guard (Exit Control)", "guard_in_1", Vector3(0, 0, -1.0), 1.7, "Talk", "zone", {"npc": "guard_in_1", "speaker": "Gate Guard", "act": "guard"}))
	spots.append(_spot("guard_in_2", "Gate Guard (Exit Control)", "guard_in_2", Vector3(0, 0, -1.0), 1.7, "Talk", "zone", {"npc": "guard_in_2", "speaker": "Gate Guard", "act": "guard"}))
	spots.append(_spot("exit_booth", "The Exit Interview Booth", "exit_booth", Vector3(0, 0, 1.2), 1.8, "Request an exit permit", "zone", {"npc": "exit_clerk", "speaker": "Exit Clerk", "act": "exit_booth"}))
	spots.append(_spot("complaint_1", "The Anonymous Complaint Box", "complaint_1", Vector3(0, 0, 1.0), 1.5, "Submit an anonymous complaint", "zone", {"act": "complaint", "box": "1"}))
	spots.append(_spot("complaint_2", "The Anonymous Complaint Box", "complaint_2", Vector3(0, 0, 1.0), 1.5, "Submit an anonymous complaint", "zone", {"act": "complaint", "box": "2"}))
	spots.append(_spot("manhole", "A Suspicious Manhole", "manhole", Vector3(0, 0, 0.0), 1.5, "Knock three times", "zone", {"act": "manhole"}))
	# Primm's Perfection.
	for index: int in range(1, 10):
		spots.append(_spot("citizen_%d" % index, "A Citizen of Perfection", "citizen_%d" % index, Vector3(0, 0, 1.0), 1.6, "Talk", "zone", {"npc": "citizen_%d" % index, "npc_id": "NPC-CITIZEN", "speaker": "A Perfectly Happy Citizen", "act": "citizen", "n": index}))
	for index: int in range(1, 5):
		spots.append(_spot("door_%d" % index, "A Perfect Front Door", "door_%d" % index, Vector3(0, 0, 0.0), 1.4, "Try the door", "zone", {"act": "door", "n": index}))
	for index: int in range(1, 4):
		spots.append(_spot("speaker_%d" % index, "A Cheerful Loudspeaker", "speaker_%d" % index, Vector3(0, 0, 0.8), 1.4, "Listen", "zone", {"act": "speaker", "n": index}))
	for portrait: String in DEFACE_SPOTS:
		spots.append(_spot(portrait, "A Portrait of His Perfection", portrait, Vector3(0, 0, 0.9), 1.4, "Deface the portrait", "zone", {"act": "deface"}))
	# The four districts: quest givers, quest objects.
	spots.append(_spot("gus", "Old Fern, Banished Composter", "gus", Vector3(0, 0, 1.0), 1.8, "Talk", "quest_npc", {"npc": "gus", "npc_id": "NPC-FERN", "npc_name": NPC_GUS, "speaker": "Old Fern"}))
	spots.append(_spot("tilda", "Widow Pell", "tilda", Vector3(0, 0, 1.0), 1.8, "Talk", "quest_npc", {"npc": "tilda", "npc_id": "NPC-PELL", "npc_name": NPC_TILDA, "speaker": "Widow Pell"}))
	spots.append(_spot("bram", "Gus", "bram", Vector3(0, 0, 1.0), 1.9, "Talk", "quest_npc", {"npc": "bram", "npc_id": "NPC-GUS", "npc_name": NPC_BRAM, "speaker": "Gus"}))
	spots.append(_spot("odile", "Chef Marlo", "odile", Vector3(0, 0, 1.0), 1.8, "Talk", "quest_npc", {"npc": "odile", "npc_id": "NPC-MARLO", "npc_name": NPC_ODILE, "speaker": "Chef Marlo"}))
	spots.append(_spot("permit_window", "The Permit Office Window", "permit_window", Vector3(0, 0, 0.0), 1.7, "Apply for a burial permit", "zone", {"act": "permit"}))
	spots.append(_spot("marrow_plot", "The Marrow Family Plot", "marrow_plot", Vector3(0, 0, 0.0), 1.7, "Lay Grandfather Marrow to rest", "zone", {"act": "plot"}))
	spots.append(_spot("sick_patch", "The Sick Patch", "sick_patch", Vector3(0, 0, 0.0), 1.7, "Plant the old seed", "zone", {"act": "patch"}))
	spots.append(_spot("dispenser", "The Perfect Nutrient Paste Dispenser", "dispenser", Vector3(0, 0, 0.0), 1.8, "Spoil the paste", "zone", {"act": "dispenser"}))
	spots.append(_spot("cable", "The Main Power Cable", "cable", Vector3(0, 0, 0.0), 1.8, "Cut the cable", "zone", {"act": "cable"}))
	for wheel: int in range(1, 4):
		spots.append(_spot("wheel_%d" % wheel, "Energy Wheel %d" % wheel, "wheel_%d" % wheel, Vector3(0, 0, 0.0), 2.0, "Talk to the wheel crew", "zone", {"act": "wheel", "n": wheel}))
	for pickup: String in PICKUPS.keys():
		spots.append(_spot("pickup_" + pickup, _pickup_title(pickup), pickup, Vector3.ZERO, 1.4, _pickup_prompt(pickup), "zone", {"act": "pickup", "pickup": pickup}))
	# Rifts: the seal stones of the sealable ones.
	for seal: String in ["out_a", "reek", "grave", "hungry", "approach_e"]:
		spots.append(_spot("seal_" + seal, "A Rift-Stone", "seal_" + seal, Vector3(0, 0, 0.0), 1.7, "Seal the rift", "zone", {"act": "seal", "rift": seal}))
	# Ward, castle.
	spots.append(_spot("ward_window", "The Spontaneity Permit Window", "ward_window", Vector3(0, 0, 1.0), 1.6, "Request a spontaneity permit", "zone", {"act": "ward_window"}))
	spots.append(_spot("ward_patient", "A Corrected Citizen", "ward_patient", Vector3(0, 0, 1.0), 1.6, "Talk", "zone", {"npc": "patient", "speaker": "Citizen 4471", "act": "patient"}))
	spots.append(_spot("castle_door", "Primm's Castle", "castle_door", Vector3(0, 0, 0.0), 2.4, "Enter Primm's Castle", "main_dungeon"))
	return spots


static func _pickup_title(pickup: String) -> String:
	match _pickup_kind(pickup):
		"recipe":
			return "A Hidden Recipe Card"
		"compost":
			return "A Banished Compost Heap"
		"stamp":
			return "The Stamp of Final Approval"
	return "A Jar of Old Seed"


static func _pickup_prompt(pickup: String) -> String:
	match _pickup_kind(pickup):
		"recipe":
			return "Take the recipe card"
		"compost":
			return "Rescue the compost heap"
		"stamp":
			return "Take the stamp"
	return "Take the seed"


static func _pickup_kind(pickup: String) -> String:
	return str(PICKUPS.get(pickup, ""))


static func _poi_kinds() -> Dictionary:
	var kinds: Dictionary = {
		"mabbit": MapPoi.Kind.QUEST_GIVER, "fig": MapPoi.Kind.VENDOR, "fig_crate": MapPoi.Kind.VENDOR, "heal": MapPoi.Kind.HEAL,
		"ladder_up": MapPoi.Kind.INTERACTABLE, "tunnel_out": MapPoi.Kind.INTERACTABLE, "exit": MapPoi.Kind.EXIT, "gate_captain": MapPoi.Kind.GATE,
		"exit_booth": MapPoi.Kind.INTERACTABLE, "complaint_1": MapPoi.Kind.INTERACTABLE, "complaint_2": MapPoi.Kind.INTERACTABLE,
		"gus": MapPoi.Kind.QUEST_GIVER, "tilda": MapPoi.Kind.QUEST_GIVER, "bram": MapPoi.Kind.QUEST_GIVER, "odile": MapPoi.Kind.QUEST_GIVER,
		"permit_window": MapPoi.Kind.INTERACTABLE, "dispenser": MapPoi.Kind.INTERACTABLE, "cable": MapPoi.Kind.INTERACTABLE,
		"castle_door": MapPoi.Kind.DUNGEON, "ward_window": MapPoi.Kind.INTERACTABLE,
	}
	for destination: String in CapitalLayout.NETWORK_DESTINATIONS:
		kinds["shaft_" + destination] = MapPoi.Kind.TRAVEL_PORTAL
	return kinds


static func _spot(id: String, title: String, anchor: String, offset: Vector3, radius: float, prompt: String, kind: String, extra: Dictionary = {}) -> Dictionary:
	var entry: Dictionary = {"id": id, "title": title, "anchor": anchor, "offset": offset, "radius": radius, "prompt": prompt, "kind": kind}
	entry.merge(extra)
	return entry


## The flag a Path quest sets when it is handed in: the story insight into Primm that Path's people gave you.
static func insight_flag(path_zone: String) -> StringName:
	return StringName("capital_insight_%s" % path_zone)
