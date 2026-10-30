# Progression model (Rebalance Part E)

What the player is expected to look like at every point of the game: level, HP, deck quality, equipment (within the level track's
rarity caps) and consumables. This is the player the balance simulation plays (`core/sim/progression_model.gd` is the data; this
file is the prose). Encounter targets (`docs/design/balance_log.md`, Part E) are tuned against this player on their first try.

## XP Pass Oct 30: the levels are the real ones

The XP curve (`ProgressionTable`) was re-based on the XP the story timeline really pays (`tools/economy_model.gd` writes the
"Level timeline" in `docs/design/sim/economy_model.md`: every stop's XP and level for the rusher, expected and thorough profiles, on
the old and the current curve). The Level column below is now what the expected player really has (`ProgressionModel.LEVELS`).
A dungeon pays less than one level before its boss, so a dungeon's elites and boss are met at the dungeon's level
(`ELITE_STEP` / `BOSS_STEP` 0, were +1 / +2); Primm one level up (`PRIMM_STEP`, the castle's side wings). The economy model's stop
levels read the same table. Before the pass the expected player was L8 at the Gainlands, L12 at the House of Gains, L18 at the Test
Kitchen and L25-30 from the Dump on.

## Overnight Oct 22: the deck column follows the Oct 22 shops

The `UPGRADES` packages in `core/sim/progression_model.gd` now hold only cards a player can own at that level
(`docs/design/vendors.md`; checked by `Godot --headless --path . -s res://tools/reference_deck_audit.gd`, all 82 package cards ok):
before its own zone a Path gets Sable's rotating Commons and one Uncommon per level-track Path Pack (4, 9, 12, 16); on arrival the zone's
Commons and two opening Uncommons; only after the zone's boss the other Uncommons, the shelf Epic(s) and the dungeon prizes (so the boss
is met without them); the Black Market's Epic from 19; the Capital quests' Epics and the shelf Legendary at 22. In effect Beefcake (home
zone at 5) is stronger from level 8 (The Big Unit, its shelf Epic), the other three Paths are weaker until their own zone is freed
(Necrocrat 12, Gourmand 15, Refusemancer 18). The table below still describes the HP / gear / item columns.

## The run the model assumes

Zones can be done in any order; the model assumes the story's order: **Gainlands -> D.N.A. -> Endless Buffet -> Verdant Dump ->
the Capital -> Primm's Castle**, with the side dungeons and the arena along the way, and the postgame (Lab, Mount Swolympus, the
Vault) after Primm. XP per fight: Tutorial 15, Normal 30, Elite 60, Boss 120 (`EncounterRewards`), levels from `level_track.json`.

| Point in the game | Level | HP | Opening hand | Item slots | Deck | Equipment (caps: C 5 / U 2, 3 at L10, 5 at L16 / E 1 at L5, 2 at L13, 3 at L19 / L 1 at L22) | Consumables |
|---|---:|---:|---:|---:|---|---|---|
| Tutorial (Forgotten Cave) | 1 | 10 | 5 | 1 | the Path's 45-card starting deck | none (the armory opens at L5) | none |
| Town: corrupted NPCs (zone unlocks) | 3 | 11 | 5 | 1 | starter + 3 on-Path picks | none | Healing Draught x1 |
| Gainlands roamers | 5 | 12 | 5 | 1 | + the second package (4-6 commons/uncommons from the level-4 Path Pack and Crosspath) | Saucepan Helmet, Cardboard Cuirass (C) | Healing Draught x1 |
| Iron Cave (S-IRON), Forgotten Vault (S-TOWN) | 6 / 7 | 13 | 5 | 1 | as above | as above | Healing Salve x1 |
| House of Gains (D-HOG) early / elite / boss | 8 / 8 / 8 | 13-14 | 5 | 1 | + 4 uncommons (first Path Pack at L4, L9) | Wicked Dagger (U, Colorless units) from L6; + Glass Jaw Gauntlets (E) after Clench (L10) | Healing Salve x1 |
| Town: the Graveyard | 8 | 13 | 5 | 1 | as above | as above | Healing Salve x1 |
| D.N.A. roamers | 10 | 14 | 6 | 1 | as above | + Traveler's Boots (C) | Healing Salve x1 |
| Hall of Final Approvals (D-HFA), Waiting Room (S-NECRO) | 11 (S-NECRO 10) | 15-16 | 6 | 2 | + first Epic (L10-12) | + Extra Pocket (C) | Healing Salve x2, Firebrand Charm x1 |
| Endless Buffet roamers, Colonel Casserole, Shiro Swindle, Arena tier 2 | 13 | 16 | 6 | 2 | as above | as above | as above |
| Test Kitchen (D-TTK), Omakase (S-GOUR) | 14 | 17-18 | 6-7 | 2 | + 2 more Epics (L12 cap 2) | as above | as above |
| Verdant Dump roamers | 16 | 17 | 6 | 2 | as above | as above | as above |
| Rotheart (D-ROT), Trash Panda Throne (S-REF) | 17 (S-REF 16) | 18-19 | 7 | 2 | + the Signature Legendary (L18) | + Dog-Eared Bookmark (U), Elastic Waistband (E) from L16 (two Epics) | as above |
| The Capital roamers, Captain Spotless, Arena tier 3 | 20 (arena 22) | 19 | 7 | 2 | as above | as above | as above |
| Old Service Tunnels (S-CAP) | 21 | 19 | 7 | 2 | as above | as above | as above |
| Primm's Castle (D-PC): nodes / elites / Primm | 21 / 21 / 22 | 20-21 | 7 | 3 | + second Legendary slot (L18 cap 2) | as above | + Sharpening Stone x1 |
| Postgame: Mount Swolympus (S-BEEF) | 23 | 21 | 7 | 3 | full Path deck, 2 of each Epic | as above | as above |
| Postgame: the Four-Seal Vault | 24 | 22 | 8 | 3 | as above | as above | as above |
| Postgame: the Path-ology Lab (D-LAB) | 25 | 23-24 | 8 | 3 | 3 of each Epic (L22) | + Crown of Mild Hubris (L) from L22 | as above |

HP and hand sizes come from `ProgressionTable` (HP +1 every even level from 10, opening hand 5/6/7/8 at L8/16/24, item slots 2 at L10,
3 at L20). Zone HP does not heal between a zone's fights: a zone's "sequence" (three roamer fights in a row, or a side dungeon's three
fights) must be survivable on one HP pool.

## Reference decks

The simulation's deck for a Path at level L is its starting deck plus the upgrade packages up to L (`ProgressionModel.UPGRADES`),
shedding colorless filler so the deck stays about 46 cards; every copy count respects the copy caps of that level. The packages are
the cards a player following that Path would reasonably own by then: the 3 tutorial picks at L3; 4-6 more commons/uncommons by L6
(the first Path Pack, the vendors); the first Epic and two more uncommons by L10; two more Epics by L14; the Signature Legendary by
L18; a second Legendary and a second Epic copy by L22. See the table in `core/sim/progression_model.gd`.

## Equipment and consumables

The gear list is Path-neutral and bought from Bertram or found on the way (Overnight Oct 29): two cheap commons at L5, the Wicked
Dagger (Colorless units +1 attack) at L6, the Glass Jaw Gauntlets (the House of Gains) and the Traveler's Boots at L9, the Extra Pocket at
L11, the Dog-Eared Bookmark and the Elastic Waistband (the Test Kitchen; two Epics, cap 2 from L13) at L16, the Crown of Mild Hubris
(Legendary, cap 1 from L22) at L22. Consumables (a fight-worth of charges, since they are bought per use): one Healing Draught from L3, one Healing Salve from L6, two
Salves and a Firebrand Charm once the second item slot opens at L10, plus a Sharpening Stone at L20. Encounters are tuned to be winnable
**without** consumables (the sim's `--nogear` check) and comfortable with them.
