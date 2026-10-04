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

## The Endless Buffet's Gourmand cards (defined in ContentDefinitions.build_zone_cards). Sold by Dolcetta
## Crumb at the Grand Pantry; "tasting_menu" and "cheese_wheel_golem" are chest cards.
const BUFFET_VENDOR_IDS: Array[String] = [
	"breadstick_sentry", "gravy_courier", "meatloaf_golem", "gelatin_sentinel", "soup_of_the_day",
	"sous_assist", "food_fight", "runaway_meatball", "souffle_sprite", "sneeze_guard",
]
## The Walk-In Freezer's one-time unique reward.
const BUFFET_MINI_REWARD_ID: String = "buffet_colossus"

## The Verdant Dump's Refusemancer cards (defined in ContentDefinitions.build_zone_cards). Sold by Farmer Hob at the
## Swap Shed; "recycle_bin" and "moss_titan" are chest cards, "heap_mother" is the Landfill Depths' unique reward.
const HEAP_VENDOR_IDS: Array[String] = [
	"scrap_goat", "tin_can_raccoon", "compost_golem", "dung_beetle", "landfill_hog",
	"vine_snare", "fertilizer_burst", "harvest_moon", "sprout_surge", "bramble_trap",
]
const HEAP_MINI_REWARD_ID: String = "heap_mother"
