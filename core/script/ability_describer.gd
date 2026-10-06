class_name AbilityDescriber
extends RefCounted
## Short readable text for a scripted ability (its costs and what it does), for the ability menu and tooltips.

const OP_PHRASES: Dictionary = {
	"damage": "deal damage",
	"damage_divided": "deal divided damage",
	"destroy": "destroy",
	"destroy_self": "destroy this",
	"shred": "Shred",
	"send_back": "send back",
	"to_hand": "return to hand",
	"reinstate": "Reinstate",
	"plate": "Plate",
	"brawl": "Brawl",
	"steal": "gain control",
	"create": "create",
	"create_x": "create an X/X token",
	"add": "add energy",
	"gain": "gain HP",
	"lose": "lose HP",
	"draw": "draw",
	"peek": "Peek",
	"bury": "Bury",
	"search": "search your deck",
	"put_field": "put onto the field",
	"pump": "boost",
	"buff": "put a buff on",
	"kw_grant": "grant a keyword",
	"exhaust": "exhaust",
	"attach": "attach",
	"cant_block": "can't block",
}


static func describe(ability: CardAbility) -> String:
	var parts: Array[String] = []
	for cost: CardAbility.Cost in ability.costs:
		parts.append(_cost_text(cost))
	var effect_parts: Array[String] = []
	for fx: CardAbility.Fx in ability.effects:
		effect_parts.append(_fx_text(fx))
	var text: String = ", ".join(parts)
	if ability.kind == CardAbility.Kind.ATTACH:
		return "%s: attach to a unit you control" % text
	if not effect_parts.is_empty():
		text += (": " if not text.is_empty() else "") + "; ".join(effect_parts)
	return text if not text.is_empty() else "Activate"


static func _cost_text(cost: CardAbility.Cost) -> String:
	var count_text: String = "X" if cost.x_count else str(cost.count)
	match cost.kind:
		"exhaust":
			return "Exhaust"
		"overexert":
			return "Overexert"
		"destroy_self":
			return "Destroy this"
		"eat":
			return "Eat garbage" if cost.count == 1 else "Eat garbage x%d" % cost.count
		"pay":
			var text: String = "Pay %s" % str(cost.generic) if cost.generic > 0 else "Pay"
			for pip: Affinity.Type in cost.pips:
				text += " (%s)" % Affinity.symbol(pip)
			return text
		"use":
			var names: Array[String] = []
			for kind: ResourceKind.Kind in cost.resource_kinds:
				names.append(ResourceKind.display_name(kind))
			return "Use %s %s" % [count_text, "/".join(names)]
		"use_token":
			return "Use a token"
		"destroy":
			return "Destroy %s" % ("a unit you control" if cost.count == 1 else "%d units you control" % cost.count)
	return cost.kind


static func _fx_text(fx: CardAbility.Fx) -> String:
	var phrase: String = str(OP_PHRASES.get(fx.name, fx.name))
	if fx.name == "create" and not fx.args.is_empty():
		var kind: int = ResourceKind.from_word(str(fx.args[0]))
		var what: String = ResourceKind.display_name(kind as ResourceKind.Kind) if kind != ResourceKind.NONE else str(fx.args[0])
		var count: String = " x%s" % str(fx.args[1]) if fx.args.size() > 1 and fx.args[1] is int and int(fx.args[1]) > 1 else ""
		return "create %s%s" % [what, count]
	return phrase
