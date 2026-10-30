# Economy audit (Overnight Oct 29, Part 1)

Read before changing anything. Everything here is measured by `tools/economy_model.gd` (report `docs/design/sim/economy_model.md`,
regenerate with `Godot --headless --path . -s res://tools/economy_model.gd`), which reads the game's own tables: the level track,
quests, dungeon blueprints and `dungeon_content.json`, the zone roamers, hidden chests, rifts, arena, minigames, feats, every vendor's
stock and price. Three profiles walk the story order (Crosspath -> Gainlands -> D.N.A. -> Buffet -> Dump -> Capital -> castle ->
postgame), earn what their play style earns, level up from the XP they actually collect, and buy from a want list at every shop stop.
The profiles: **rusher** (main path only, a third of the roamers, no chests or side content), **expected** (main path, every roamer once,
half the chests, two of three side quests per zone, the side dungeons, the minigames once, half the arena) and **thorough**
(everything once, the repeat content a little, every luxury).

The model is a model: the dungeon node pay, first clears, quests, chests and roamers are exact; essence is a rough guess (it only comes
from over-cap duplicates); the buying policy is a sensible player, not a real one.

## 1. The map of the economy

### Sources (gold, one of everything)

| Source | Count | Gold | XP | Notes |
|---|---:|---:|---:|---|
| Starting gold + the Forgotten Cave | 1 | 120 + 280 | 150 | tutorial fights 40 each, boss 120 |
| Level track L2-30 | 29 levels | 3,070 | - | + 16 packs, 5 cosmetics; by band L2-5 180, L6-10 320, L11-20 1,020, L21-30 1,550 |
| Main quests (10) | 10 | 1,420 | 1,160 | + 40 at each gatekeeper objective, + a Path Pack per zone |
| Side quests (26) | 26 | 2,090 | 1,830 | 40-150 each; items, cards, gear and packs on top |
| Corrupted NPC gatekeepers | 4 | 520 | 240 | Elite pay (130) once each |
| Graveyard (the Restless Dead) | 1 | 220 | 60 | once |
| Store room ghosts | 1 | 15 | 30 | once |
| Dungeon battle nodes, main route | 65 | 3,545 | 3,570 | Normal 35 / Elite 65 / Boss 100 (half the open-world rate); **paid on every run** |
| Dungeon battle nodes, side branches | 4 | 200 | 180 | Primm's Castle only |
| Dungeon treasure nodes | 9 | 540 | - | 60 each, the castle 240 |
| Dungeon first clears | 14 | 2,340 | 1,500 | main 200 + 150 bonus + Gilded Pack + Path Pack; side 30 + the unique card and a piece of gear |
| Dungeon repeat clears | - | main 100 + Path Pack, side 30 + a pack | - | plus the nodes again: a repeat House of Gains run is ~435 gold + a 150 pack |
| Hidden chests (town 11 + zones 70) | 81 | 4,185 | - | 20-150 each; plus items, cards, gear, packs, cosmetics; 20-30 % roll a gear piece |
| Capital rifts | 9 | 340 | - | once |
| Zone roamers, one sweep (2 per kind) | 34 | 740 | 960 | 25-45 each, respawn; Crosspath outskirts 12-14 |
| Zone elites (Casserole, Spotless) | 2 | 170 | 180 | repeatable |
| Arena first clears | 8 | 1,560 | 750 | 90-500; replays 15 |
| Minigames, first clear at 2 stars | 3 | 420 | 120 | repeats 32 |
| Feats | 40 | 1,620 | - | once per account; 12 essence |
| Collection 50 % | 1 | 200 | - | 25 / 75 / 100 % pay packs |
| Lieutenants' yards | 1 | 120 | 60 | once |
| **Everything once** | | **~19,600** | **~10,800** | the thorough profile's 23,728 includes repeat content |

Essence sources: over-cap duplicates (1 / 2 / 4 / 8 by rarity, only once a card is at its copy cap), feats (12), the arena (5-16 per tier),
the Four Paths feat. Essence sink: the Alchemist only (all essence of two Paths, min 6 each, + 100 gold, for one random dual-Path card).

### Sinks

| Sink | Prices | Where |
|---|---|---|
| Cards | Common 20-45 (mean 27), Uncommon 40-70 (50), Epic 85-110 (101), Legendary 180-195 (187): base 15 / 35 / 80 / 160 + 5 per energy | Sable (sampler), the four zone shelves, the Black Market (untouched) |
| Packs | General 100, General II 220, Path 150, Gilded 600, Prismatic 900 | Sable, the Pack Vendor (Path Packs once the zone is freed) |
| Gear, Bertram | basics 60-130 (Extra Pocket 60, Cuirass 60, Helmet 70, Boots 100, Plate 110, Dagger 120, Goggles 130); advanced (L13) 220-320 | Crosspath |
| Gear, zones | Flip-Flops 80, Bookmark 180, Bandolier / Seal 220, Rolling Pin 240, Mitts 260 (the Path pieces once freed) | each zone's shop |
| Items | 25-55 (Draught 40, Salve 50, Tonic 45, Firebrand 45, Chains 55); the second half at L6 | Tilly |
| Cosmetics | hats 90-360, cloaks 180-900 | Pip |
| Alchemist | 100 gold + essence | after one zone |
| Zone fee | 15-20 on waking at the hub after a loss | zones |
| **Not in the game** | an inn / healing for gold, rerolls, selling cards or gear, repairs, upgrades, card-pick rerolls, deck slots | - |

Whole-game sink capacity (one of everything that is not repeatable): all gear ~3,600, all cosmetics 2,750, one copy of every card on the
shelves ~5,000 (a Path's whole shelf ~1,000), items ~600 for a run's worth. About 12,000. Packs are the only open-ended sink.

## 2. The three profiles (before)

Gold on hand at the shop stops (the model's level in brackets; the progression model expects 5 at the Gainlands, 9 at the D.N.A., 12 at the
Buffet, 15 at the Dump, 18 at the Capital, 20 at the castle):

| Stop | Rusher | Expected | Thorough |
|---|---:|---:|---:|
| Crosspath arrival | 603 (L4) | 735 (L5) | 922 (L6) |
| Level 5, the armory (3 essentials 250) | 442 -> 112 | 329 -> 39 | 66 -> 26 |
| Gainlands arrival | 127 -> 47 | 859 -> 39 | 1,308 -> 138 |
| Gainlands freed | 1,247 -> 414 | 1,674 -> 323 | 1,748 -> 107 |
| D.N.A. arrival | 414 -> 334 | 973 -> 328 | 957 -> 32 |
| D.N.A. freed | 1,614 -> 426 (L12) | 1,703 -> 352 (L15) | 1,912 -> 741 (L17) |
| Buffet freed | 1,550 -> 412 | 1,752 -> 341 | 2,453 -> 62 |
| Dump freed | 1,687 -> 424 (L16) | 2,676 -> 545 (L25) | 3,214 -> 2,083 (L28) |
| Capital arrival | 644 -> 483 | 2,745 -> 2,445 (L27) | 5,283 -> 4,763 (L30) |
| After Primm | 1,493 -> 1,413 (L18) | 4,895 -> 3,221 (L30) | 7,263 -> 5,369 |
| Postgame | 1,663 -> 1,583 | 4,686 -> 3,982 | 7,534 -> 6,610 |

| | Rusher | Expected | Thorough |
|---|---:|---:|---:|
| Income | 8,098 | 18,535 | 23,728 |
| Spent | 6,515 (80 %) | 14,553 (79 %) | 17,118 (72 %) |
| Left at the end | 1,583 | 3,982 | 6,610 |
| Sinks never used | packs, cosmetics, alchemy | none | none |
| Shop stops where nothing wanted was affordable | 0 (but 3 stops at 32-72 gold after the armory) | 0 | 0 |
| Stops with gold at twice the priciest open want | 2 | 4 (from the Capital on) | 4 (from the Dump freed on) |

Income by source, expected: main route 6,285 (34 %), level track 3,070 (17 %), chests 2,495, side quests 1,570, postgame 1,215, side
dungeons 1,200, roamers 805, feats 735, minigames 420, arena 300. Spend, expected: gear 3,560, packs 3,150, cards 2,853, cosmetics 2,750,
items 1,745, alchemy 400.

## 3. Problems, ranked

1. **Gold comes in lumps, not per visit.** The main route pays ~1,150-1,500 at each main dungeon (6-7 nodes at 35-100 plus 350 for the
   clear) and almost nothing on a zone's first visit (roamers 25-45, the arrival stock is bought from what was left after the last
   dungeon). Every profile buys in one burst at the "freed" stop and walks into the next zone nearly empty (expected: 39 gold at the
   Gainlands, 328 at the D.N.A.). The brief's target - a meaningful purchase in reach about every zone visit - fails on the arrival
   visits and overshoots on the freed ones.
2. **Everything is affordable; nothing is choosy.** At every freed stop the whole new stock (gear 220-320, 3 Uncommons 150, the Epic
   100, a Path Pack 150: ~620-1,260) costs less than the gold on hand (1,250-3,200). The expected player buys a zone's entire
   Uncommon and Epic shelf plus its gear plus a pack in one go. Cards are the cheapest thing in the game relative to income: an Epic
   (101) is a single Elite node and a Boss node; a Legendary (187) is one dungeon boss.
3. **Late-game hoarding with no sink.** From the Capital on the expected player holds 2,400-4,000 gold and the thorough one 4,700-6,600
   with nothing wanted left: the cosmetics are all bought by the Dump, the gear by the Buffet, the shelves by the freed stops, and the
   only open sinks are Gilded (600) and Prismatic (900) packs that the model (rightly) treats as luxuries. The level track's L21-30 band
   adds 1,550 more. Nothing recurring (rerolls, upgrades, rare rotating stock) exists to spend on.
4. **The early pinch is in the wrong place.** The three armory essentials (Cuirass 60 + Helmet 70 + Dagger 120 = 250) land at L5 right
   after the Crosspath shopping and drain every profile to 26-112 gold; the Gainlands arrival stock (Flip-Flops 80, commons 20-45) is
   then out of reach and the rusher sits at 32-72 gold for three stops (Iron Cave, Vault, Graveyard) until the House of Gains pays
   1,200 at once.
5. **Prices do not follow a curve.** Gear: Extra Pocket (Common) 60 but Traveler's Boots (Common) 100; Solid Plate (Uncommon) 110, Wicked
   Dagger (Uncommon) 120, Dog-Eared Bookmark (Uncommon) 180, Bandolier (Uncommon) 220; Rolling Pin (Epic) 240, Mitts (Epic) 260,
   Flamethrower (Epic) 320. Cards: 15 / 35 / 80 / 160 + 5 per energy gives 20-45 for a Common (a 1-cost and a 5-cost Common differ by 20
   gold, a 1-cost Epic and a 5-cost Common cost about the same). Nothing scales with the zone or level it is sold at: a Gainlands
   Common and a Dump Common both cost 27 while income per fight has doubled.
6. **Repeat content pays almost as much as first clears, except the things that should.** A repeat main-dungeon run pays its nodes again
   (335-370) + 100 + a Path Pack: about half a first clear, fine. But the first clear of a side dungeon pays only 30 gold (the card
   and the gear are the prize) while its three nodes pay 170 - the clear bonus is noise. Minigame repeats (32) and arena replays (15)
   are below one roamer. Roamers respawn at 30-35 forever (the Capital 35-45) - fine as pocket money, never a farm.
7. **The level track's gold is back-loaded and the XP curve throws it away.** L21-30 pay 1,550 of the track's 3,070 gold, but
   `ProgressionTable.POSTGAME_STEP` is 27 (the docs say 40): levels 21-30 together cost 2,970 XP, less than levels 17-20 (2,280), so
   the expected player reaches L25 at the Dump and L30 at the Capital (design: 19 and 18-20) and collects 1,550 postgame gold during the
   main game, where it has no use. The rusher ends at L18 after Primm (design 20-22). This is an XP finding, not a price: flagged in the
   inbox; the model's gold curves above already include it.
8. **Essence barely exists.** Over-cap duplicates only start once a card is at its cap (Commons 3, Uncommons 2-3, Epics 1-3), so a
   player who buys singles never makes essence; packs do, slowly (the rough model: 20-45 a run). One sink (the Alchemist, a random
   dual-Path card). The gold half of the brew (100) is nothing by the time the essence half is reachable.
9. **Items are the one steady sink, and they are flat.** Tilly's prices (25-55) never change; the consumable rule (once per battle,
   charges carry over) means a real player buys a few charges per zone. Zone shops sell no items at all (the Buffet's Saucepan Helmet is
   gear), so the only item shop is in Crosspath.
10. **No sink is missing that the game needs, but two are missing that would help:** a repeatable mid-size sink per zone (a rotating
    rare card, a reroll of a reward pick, a heal) and anything to spend on at level 20+.

## 4. What the three profiles show, in one line each

- **Rusher**: fine until the armory, starved for three stops, then over-funded by every dungeon (1,200 bursts) and ends with 1,583 and
  nothing to buy beyond cards; never touches packs, cosmetics or the Alchemist.
- **Expected**: comfortable from the Gainlands on, buys a zone's whole stock at every freed stop, has everything by the Dump and
  ends with 4,000 unspent.
- **Thorough**: 23,700 income, the luxuries exhausted by the Buffet, 6,600 unspent at the end; the only unaffordable things in the
  whole run were the 600-gold Gilded packs for a few stops.

Targets and the price curve that answer these: `docs/design/economy.md` (Part 2).
