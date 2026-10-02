class_name GainlandsZone
extends RefCounted
## The Gainlands (Beefcake zone). Stub until Part D.

const ID: String = "beefcake"


static func build_def() -> ZoneDef:
	var def: ZoneDef = DnaZone.build_def()
	def.id = ID
	return def
