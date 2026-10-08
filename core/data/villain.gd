class_name Villain
extends RefCounted
## Access to the big bad's name and title (`data/story/villain.tres`) and the `{villain}` / `{villain_title}`
## token substitution every story text reader applies. Rename him by editing the .tres only.

const PATH: String = "res://data/story/villain.tres"

static var _data: VillainData


static func data() -> VillainData:
	if _data == null:
		_data = load(PATH) as VillainData
		if _data == null:
			_data = VillainData.new()
	return _data


static func display_name() -> String:
	return data().villain_name


static func title() -> String:
	return data().villain_title


## "His Perfection, Primm" - how he introduces himself.
static func full_title() -> String:
	return "%s, %s" % [title(), display_name()]


static func fill(text: String) -> String:
	if not text.contains("{"):
		return text
	return RoyalFamily.fill(text.replace("{villain_title}", title()).replace("{villain}", display_name()))
