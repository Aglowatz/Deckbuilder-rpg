class_name ZoneCards
extends RefCounted
## Ids of the D.N.A. zone's Necrocrat cards (defined in ContentDefinitions.build_zone_cards,
## stored in data/cards/zone/). Single source of truth for who sells/gives which.

## Sold by the zone vendor (Afterlife Services and Labor's Requisitions Desk).
const VENDOR_IDS: Array[String] = [
	"cubicle_zombie", "overdue_intern", "middle_manager", "soul_auditor", "performance_review",
	"mandatory_fun_day", "death_benefits", "take_a_number", "hr_reaper",
]
## The mini dungeon's one-time unique reward.
const MINI_DUNGEON_REWARD_ID: String = "deceased_ceo"

## The Gainlands' Beefcake cards (defined in ContentDefinitions.build_zone_cards, stored in
## data/cards/zone/). Sold by Tiny Tony at the Swole Station; "max_rep" is a chest/enemy card.
const GAINLANDS_VENDOR_IDS: Array[String] = [
	"gym_rat", "protein_golem", "pump_chaser", "wheel_runner", "mill_hand",
	"courtesy_chucker", "flex_off", "leg_day", "cheat_day", "pre_workout",
]
## The Gainlands mini dungeon's one-time unique reward.
const GAINLANDS_MINI_REWARD_ID: String = "iron_titan"
