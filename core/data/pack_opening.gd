class_name PackOpening
extends RefCounted
## The result of opening one pack: what came out, which cards were new, and what the extra copies converted into.

class Entry:
	extends RefCounted
	var card: CardData
	## First copy of this card the player has ever owned.
	var is_new: bool = false
	## The copy was beyond the 4-copy limit and converted into essence (or gold for a neutral card).
	var converted: bool = false
	## Essence gained, Affinity.Type (as int) -> amount.
	var essence: Dictionary = {}
	var gold: int = 0
	var notice: String = ""

var pack: PackData
var entries: Array[Entry] = []


func cards() -> Array[CardData]:
	var result: Array[CardData] = []
	for entry: Entry in entries:
		result.append(entry.card)
	return result


func new_count() -> int:
	var count: int = 0
	for entry: Entry in entries:
		if entry.is_new:
			count += 1
	return count


func converted_count() -> int:
	var count: int = 0
	for entry: Entry in entries:
		if entry.converted:
			count += 1
	return count


## Total essence gained, Affinity.Type (as int) -> amount.
func essence_totals() -> Dictionary:
	var totals: Dictionary = {}
	for entry: Entry in entries:
		for path: Variant in entry.essence.keys():
			totals[int(path)] = int(totals.get(int(path), 0)) + int(entry.essence[path])
	return totals


func gold_total() -> int:
	var total: int = 0
	for entry: Entry in entries:
		total += entry.gold
	return total


func has_legendary() -> bool:
	for entry: Entry in entries:
		if entry.card.rarity == CardEnums.Rarity.LEGENDARY:
			return true
	return false
