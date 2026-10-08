class_name ZoneCards
extends RefCounted
## The card ids each zone's vendor sells and its dungeons give (Brief 14: the designed card set; see docs/design/reward_cards.md).
## Single source of truth for who sells/gives which.

## D.N.A. (Necrocrat): sold by Afterlife Services and Labor's Requisitions Desk.
const VENDOR_IDS: Array[String] = ["N-01", "N-02", "N-04", "N-05", "N-09", "N-14", "N-15", "N-17", "N-23", "N-26"]
## The Waiting Room of Eternity (S-NECRO)'s one-time unique reward: Betty Bones, Surly Secretary.
const MINI_DUNGEON_REWARD_ID: String = "N-30"

## The Gainlands (Beefcake): sold by Coach Brutus Benchley at the Swole Station.
const GAINLANDS_VENDOR_IDS: Array[String] = ["B-01", "B-03", "B-05", "B-08", "B-09", "B-12", "B-14", "B-16", "B-20", "B-25"]
## Mount Swolympus (S-BEEF)'s one-time unique reward: the Barbell of the Ancients.
const GAINLANDS_MINI_REWARD_ID: String = "B-30"

## The Endless Buffet (Gourmand): sold by Madame Mirepoix at the Grand Pantry.
const BUFFET_VENDOR_IDS: Array[String] = ["G-01", "G-02", "G-05", "G-06", "G-07", "G-10", "G-16", "G-18", "G-20", "G-21"]
## Omakase (S-GOUR)'s one-time unique reward: Toro Toro.
const BUFFET_MINI_REWARD_ID: String = "G-27"

## The Verdant Dump (Refusemancer): sold by Granny Gristle at the Swap Shed.
const HEAP_VENDOR_IDS: Array[String] = ["R-02", "R-05", "R-06", "R-08", "R-10", "R-14", "R-17", "R-19", "R-22", "R-25"]
## The Trash Panda Throne (S-REF)'s unique reward: Raccoon.
const HEAP_MINI_REWARD_ID: String = "R-27"

## Main-dungeon unique rewards: The Grand Chef (Test Kitchen), The Big Unit (House of Gains), the Necrocrat leader card
## (Hall of Final Approvals), Archdruid Compostella (Rotheart).
const MAIN_DUNGEON_REWARD_IDS: Array[String] = ["G-33", "B-32", "N-33", "R-33"]
