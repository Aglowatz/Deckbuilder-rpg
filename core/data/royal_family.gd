class_name RoyalFamily
extends RefCounted
## Access to the royal family, rescuer and place names (`data/story/royal_family.tres`) and their token substitution.
## Tokens: {prince} {prince_full} {royal_house} {king} {queen} {rescuer} {rescuer_full} {kingdom} {town} {capital} {showcase} {wanderer} {pathordia}.
## `{wanderer}` is how people address the player: "Wanderer" until the prince's identity is revealed, then the prince's name (`set_identity_revealed`).
## `{rescuer}` reads "The Rescuer" until Percival Plume names her at the castle gate (flag `rescuer_named`), then her first name; `{rescuer_full}` is
## always her full name (only for the line that names her, and after).
## `{capital}` reads "Primm's Perfection" until Primm falls and "Pathordia" afterwards (`set_capital_liberated`).

const PATH: String = "res://data/story/royal_family.tres"

static var _data: RoyalFamilyData
static var _capital_liberated: bool = false
static var _identity_revealed: bool = false
static var _rescuer_named: bool = false


static func data() -> RoyalFamilyData:
	if _data == null:
		_data = load(PATH) as RoyalFamilyData
		if _data == null:
			_data = RoyalFamilyData.new()
	return _data


## Called by the session when the "Primm has fallen" flag changes (new game, load, victory).
static func set_capital_liberated(value: bool) -> void:
	_capital_liberated = value


## Called by the session when the "the Wanderer's identity is known" flag changes.
static func set_identity_revealed(value: bool) -> void:
	_identity_revealed = value


## Called by the session when the "rescuer_named" flag changes (Plume names her at the castle gate).
static func set_rescuer_named(value: bool) -> void:
	_rescuer_named = value


static func rescuer_named() -> bool:
	return _rescuer_named


## The Rescuer as people call her: "The Rescuer", then "Elowen" once she has been named.
static func rescuer_name() -> String:
	return data().rescuer_true_name if _rescuer_named else data().rescuer_name


static func identity_revealed() -> bool:
	return _identity_revealed


## How people address the player: "Wanderer", or the prince's name after the reveal.
static func wanderer_name() -> String:
	return data().prince_name if _identity_revealed else "Wanderer"


## The name plate of the player in dialogue: "The Wanderer", or the prince's name after the reveal.
static func wanderer_plate() -> String:
	return data().prince_name if _identity_revealed else "The Wanderer"


static func capital_name() -> String:
	return data().capital_liberated if _capital_liberated else data().capital


static func fill(text: String) -> String:
	if not text.contains("{"):
		return text
	var d: RoyalFamilyData = data()
	return text.replace("{prince_full}", d.prince_full_name).replace("{prince}", d.prince_name) \
		.replace("{royal_house}", d.royal_house).replace("{king}", d.king_name).replace("{queen}", d.queen_name) \
		.replace("{rescuer_full}", d.rescuer_full_name).replace("{rescuer}", rescuer_name()).replace("{kingdom}", d.kingdom).replace("{town}", d.town) \
		.replace("{capital}", capital_name()).replace("{showcase}", d.showcase).replace("{wanderer}", wanderer_name()).replace("{pathordia}", d.capital_liberated)
