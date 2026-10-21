class_name OldHob
extends RefCounted
## Old Hob the Gravedigger, who is secretly Death (Oct 21; story bible sections 3, 8 and 16, the sheet's NPC-HOB row). When Primm's paperwork
## seized the D.N.A., the afterlife's intake froze and Death could not collect anyone, so he took a job digging graves in Crosspath and
## waited. He keeps an appointment book; he turns up in impossible places "just measuring"; at 0 life he is the one who sends you back ("Not
## on my list. Off you pop."); after Primm falls he holds the royal funeral. Gentle and funny, never grim. Scenes: data/story/story_scenes.json
## `hob_*`. Pure rules here: which scene plays where.

const NPC_ID: String = "NPC-HOB"
const SPRITE: String = "HOB"
## The line at 0 life, before the zone's own wake-up lines.
const WAKE_SCENE: String = "hob_wake"


## His cameo in a walkable zone (beefcake, necrocrat, gourmand, refusemancer, final): the freed variant once the zone (or, in the Capital, a
## lieutenant he has opinions about) has changed. "" when the zone has none.
static func cameo_scene(zone_id: String, flags: Dictionary) -> String:
	var base: String = "hob_%s" % zone_id
	if zone_id == CapitalZone.ID and bool(flags.get(str(Lieutenants.flag_beaten(Lieutenants.PLUME)), false)) and StoryScenes.has(base + "_plume"):
		return base + "_plume"
	if bool(flags.get(str(ZoneCompletion.flag_name(zone_id)), false)) and StoryScenes.has(base + "_freed"):
		return base + "_freed"
	return base if StoryScenes.has(base) else ""


## In Crosspath's graveyard: the first talk points at the Restless Cairn; once the D.N.A. is free the intake is open again; after Primm falls
## he is off to dig two graves properly (the funeral, in the Capital), and once it is done he is back, cheerful.
static func town_scene(flags: Dictionary) -> String:
	if bool(flags.get("royal_funeral_seen", false)):
		return "hob_town_after_funeral"
	if bool(flags.get("primm_defeated", false)):
		return "hob_town_funeral"
	if bool(flags.get(str(ZoneCompletion.flag_name("necrocrat")), false)):
		return "hob_town_freed"
	if not bool(flags.get("hob_met", false)):
		return "hob_town_first"
	return "hob_town"


## The royal funeral waits in Grave Row once Primm has fallen, until it has played.
static func funeral_waiting(flags: Dictionary) -> bool:
	return bool(flags.get("primm_defeated", false)) and StoryScenes.should_play("royal_funeral", flags)
