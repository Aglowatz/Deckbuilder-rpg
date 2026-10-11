class_name TitleMeta
extends RefCounted
## What the title screen remembers between runs (`user://meta.cfg`): whether the final boss was ever beaten, which switches the title art to the sunrise version
## (TITLE-KEYART-NIGHT). Players who finished before this existed are recognised from their save slots.

const PATH: String = "user://meta.cfg"


## True once Primm was beaten in any run (the flag is kept, or a save slot is already in the postgame).
static func postgame_reached() -> bool:
	var config: ConfigFile = ConfigFile.new()
	if config.load(PATH) == OK and bool(config.get_value("progress", "postgame_reached", false)):
		return true
	for slot: int in range(0, SaveSlots.SLOT_COUNT + 1):
		if SaveSlots.exists(slot) and bool(SaveSlots.info(slot).get("postgame", false)):
			return true
	return false


static func mark_postgame() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.load(PATH)
	config.set_value("progress", "postgame_reached", true)
	config.save(PATH)
