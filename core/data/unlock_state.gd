class_name UnlockState
extends RefCounted
## A plain-data snapshot of everything a `Condition` can check. Kept separate from `Session`
## (an autoload Node) so `Condition.met()` stays pure `core/` logic, testable with no scene tree;
## `Session.unlock_state()` builds one of these from the live campaign each time it is needed.

var flags: Dictionary = {}
## Names of dungeons fully cleared.
var cleared_dungeons: Array[String] = []
## card id -> copies owned.
var owned_cards: Dictionary = {}
## Ids of secrets found (chests, hidden vendors, ...).
var found_secrets: Array[String] = []
## Lifetime gold spent (not current balance).
var gold_spent: int = 0
var player_level: int = 0
var completed_quests: Array[String] = []
## Named progress counters (Session.counters), for Condition.COUNTER.
var counters: Dictionary = {}
## How many of the four Path zones are freed (derived from `flags`).
var zones_completed: int = 0
## The postgame is unlocked (Primm defeated).
var postgame: bool = false
