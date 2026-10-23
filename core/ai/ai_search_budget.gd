class_name AISearchBudget
extends RefCounted
## Battle AI upgrade (Oct 23): how much thinking one decision may take. Node counts are the real limit (they keep sim games
## deterministic for a seed); the wall-clock deadline is a safety net for the live game (0 = none). A search checks `tick()` before
## every clone and stops with its best answer so far when the budget is spent - the game never freezes.

var max_nodes: int = 200
var nodes: int = 0
var deadline_usec: int = 0


static func make(nodes_allowed: int, time_ms: int) -> AISearchBudget:
	var budget: AISearchBudget = AISearchBudget.new()
	budget.max_nodes = nodes_allowed
	budget.deadline_usec = Time.get_ticks_usec() + time_ms * 1000 if time_ms > 0 else 0
	return budget


## Spends one node; false when the budget is gone (the caller should stop expanding).
func tick() -> bool:
	nodes += 1
	return within()


func within() -> bool:
	if nodes > max_nodes:
		return false
	return deadline_usec == 0 or Time.get_ticks_usec() < deadline_usec


func remaining() -> int:
	return maxi(0, max_nodes - nodes)
