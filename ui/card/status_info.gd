class_name StatusInfo
extends RefCounted
## Overnight Oct 23, Part 5: what is happening to one card on the table right now, in plain words, for the battle's tooltip box -
## exhausted (and "skips its next refresh"), Red Tape and other changes that last until a turn (with turns left), until-end-of-turn
## pumps (Iron), permanent buffs, the fight's rules on its stats, granted keywords, attached Tools, tokens, protection. Reads core
## state only; each entry is [title, text] like KeywordInfo's.


static func entries(game: GameState, card: CardInstance) -> Array[Array]:
	var result: Array[Array] = []
	if game == null or card == null:
		return result
	var on_field: bool = game.players[card.owner].field.has(card)
	if card.is_token() and card.data.is_unit():
		result.append(["Token", "A unit made by an effect, not drawn from a deck. It plays like any unit; when it leaves the field it is gone for good (no Refuse Pile)."])
	if not on_field:
		return result
	if card.exhausted and card.data.is_unit():
		var text: String = "Spent this turn (it attacked, used an ability or entered exhausted). An exhausted unit can't attack or block; it refreshes at the start of its controller's turn."
		if card.skip_refresh > 0:
			text += " It will skip its next refresh."
		result.append(["Exhausted", text])
	for change: Dictionary in card.lingering:
		var atk: int = int(change.get("atk", 0))
		var def: int = int(change.get("def", 0))
		var until: int = int(change.get("player", 0))
		var whose: String = "your" if until == 0 else "the enemy's"
		var left: int = _turn_starts_until(game, until)
		var name: String = "Red Tape" if atk < 0 and def == 0 else "Lingering change"
		result.append([name, "%s until the start of %s next turn (%s)." % [_stats(atk, def), whose, "ends this coming turn" if left <= 1 else "%d turns left" % left]])
	if card.temp_attack != 0 or card.temp_defense != 0:
		result.append(["Until end of turn", "%s until the end of this turn (Iron and other pumps)." % _stats(card.temp_attack, card.temp_defense)])
	if card.attack_bonus != 0 or card.defense_bonus != 0:
		var buffed: String = " (%d buff%s)" % [card.buffs, "" if card.buffs == 1 else "s"] if card.buffs > 0 else ""
		result.append(["Changed for good", "%s for as long as it stays on the field%s." % [_stats(card.attack_bonus, card.defense_bonus), buffed]])
	var rules: Vector2i = game.players[card.owner].modifiers.stat_bonus_for(card.data)
	if card.data.is_unit() and (rules.x != 0 or rules.y != 0):
		result.append(["The fight's rules", "%s from the rules of this fight (the icons under the portraits)." % _stats(rules.x, rules.y)])
	for keyword: CardEnums.Keyword in card.granted_keywords + card.temp_keywords:
		if card.data.keywords.has(keyword) or not KeywordInfo.KEYWORD_TEXT.has(keyword):
			continue
		var lasting: String = " (until end of turn)" if card.temp_keywords.has(keyword) else ""
		result.append(["%s%s" % [KeywordInfo.keyword_name(keyword), lasting], KeywordInfo.keyword_description(keyword)])
	var tools: Array[CardInstance] = game.attached_tools(card)
	if not tools.is_empty():
		var names: PackedStringArray = []
		for tool_card: CardInstance in tools:
			names.append(tool_card.data.display_name)
		result.append(["Equipped", "%s attached. A Tool's bonus lasts while it stays attached." % ", ".join(names)])
	if card.protected_until_turn > game.turn:
		result.append(["Protected", "Can't be damaged or targeted for now."])
	if card.cannot_block or card.temp_cannot_block:
		result.append(["Can't block", "This unit can't block%s." % (" this turn" if card.temp_cannot_block and not card.cannot_block else "")])
	return result


## "-2/-0", "+1/+1".
static func _stats(atk: int, def: int) -> String:
	return "%s%d/%s%d" % ["+" if atk >= 0 else "-", absi(atk), "+" if def >= 0 else "-", absi(def)]


## How many turn starts until `player`'s next turn begins: 1 when that is the very next turn.
static func _turn_starts_until(game: GameState, player: int) -> int:
	return 1 if game.active != player else 2
