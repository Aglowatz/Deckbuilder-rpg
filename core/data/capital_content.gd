class_name CapitalContent
extends RefCounted
## Brief 10 / 14: the card ids the Capital and Primm's Castle hand out or sell, and the junk card the Refusemancer service
## debuff shuffles into your deck (a token defined in code: see `CardImporter.extra_tokens`).

const JUNK_ID: String = "JUNK-01"
## The four Path-quest reward cards, by Path order Beefcake, Gourmand, Necrocrat, Refusemancer
## (Barbell of the Ancients, Recipe for wonder, Lich of Accounts Payable, The Mother Heap).
const QUEST_REWARD_IDS: Array[String] = ["B-30", "G-31", "N-28", "R-30"]
## The card for toppling Primm: Reunion of the Paths.
const FINAL_REWARD_ID: String = "P4-02"
## Sold at Fig Sly's black market (the rare ones, any Path).
const BLACK_MARKET_CARD_IDS: Array[String] = ["N-27", "R-31", "G-29", "B-27", "C-30", "C-24", "NR-12", "GB-12"]
