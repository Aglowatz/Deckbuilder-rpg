# Early-game fun check, every Path (Overnight Nov 4-5, Part 3)

Tool: `tools/early_game_study.gd` (`tools/early_game_study_tool.gd`; `--path=<path>` runs one Path, `--runs=N`, `--no_ease` measures without
the fix). It walks the economy model's timeline the way a new save of each Path plays it - the cave, Crosspath's first shops, the player's
OWN Path's gatekeeper (Maren sends everyone to their own zone first), the armory at level 5, that zone's arrival and its main dungeon - as the
no-grind player of the gold study (every story step and roamer once, half the chests, two thirds of the side quests), with today's prices
(cards 100 / 200 / 500 / 1000, items 50-100, General Pack 150, Path Pack 200) and gold sources (Part 2). Spending: two Commons of the Path at
the first shop, one Healing Salve at each later stop. The dungeon is simulated along one route (fights only, one HP pool, no healing) with
the **starter deck plus those two Commons**, at the level the walk reaches, with the model's equipment and items for that level. 10 runs per
Path and setting (a 10-run rate is good to about +-15 points; each Path takes about ten minutes of simulation on this PC).

## Gold and what it buys

The same for every Path until the zones split (the economy timeline is shared):

| Stop | Level | Gold on arrival | After the stop's quests and fights | Affords then (Commons / items / General Packs) |
|---|---:|---:|---:|---|
| Crosspath, the first shops | 5 | **520** | 834 | 5 / 7 / 3 on arrival, 8 / 11 / 5 after |
| Store room, town chests | 5 | 634 | 939 | 9 / 13 / 6 |
| The own gatekeeper | 5 | ~800-870 | ~970-1,060 | 9 / 13 / 6 |
| The own zone's arrival (roamers, vendor, side quests) | 6-7 | ~900 | 1,600-1,960 | 16-19 / 22-28 / 10-13 |
| The first main dungeon (on arrival) | 8-9 | 1,530-1,890 | 2,890-3,250 | |

**Affordability is fine for every Path:** 520 gold at the first shop is five Commons, seven items or three General Packs (goal: 2-3).

## First dungeon win rates

| Path | Home zone (designed place) | First dungeon | Level | Before the fix | **After** | HP left |
|---|---|---|---:|---:|---:|---:|
| Beefcake | Gainlands (1st) | The House of Gains | 9 | 50% | **70%** | 17.6 |
| Necrocrat | D.N.A. (2nd) | The Hall of Final Approvals | 8 | (not finished; 30% with HP-only ease) | **90%** | 18.6 |
| Gourmand | Endless Buffet (3rd) | The Test Kitchen | 9 | 40% | **90%** | 16.1 |
| Refusemancer | Verdant Dump (4th) | The Rotheart | 9 | 10% | **70%** | 15.1 |

Goal: about 65-80% with the starting deck plus a couple of buys. Beefcake and Refusemancer land in it; Necrocrat and Gourmand land a little
above (90%, within the noise of 10 runs of the top of the band). Before the fix the Paths whose zone is designed later were punished: a
Refusemancer met the Rotheart, tuned for level 17, at level 9.

## The change: `ZoneOrderEase` (`core/zone/zone_order_ease.gd`)

The four zones are tuned for one order (Gainlands, D.N.A., Buffet, Dump), but every player starts with their own. A zone played earlier
than its designed place gets easier foes - its main dungeon, its side dungeon, its roamers and its gatekeeper - and nothing else changes
(decks, rules, rewards stay):

| Places early | HP factor | Attack ease | Example |
|---:|---:|---:|---|
| 0 | 1.00 | - | the Gainlands for a Beefcake |
| 1 | 0.95 | units -1 attack | the D.N.A. first |
| 2 | 0.85 | units -1 attack | the Buffet first |
| 3 | 0.42 | units -1 attack | the Dump first |

While no zone is freed yet (the player's first zone) the HP factor is multiplied by 0.85 more. A freed zone and the Capital are never eased;
a zone played in its designed place or later is as designed. Calibration runs (`_logs/early_v2..v5_*.md`): HP alone (factors down to 0.34)
plateaued at 40-50% for the late zones - their bosses still out-damaged a starter deck - so the attack ease does most of the work and the HP
factors were backed off again. Smallest change: the starter decks, early rewards and prices were left alone (affordability was never the
problem). Tests: `tests/core/test_overnight_nov5_part3.gd`.
