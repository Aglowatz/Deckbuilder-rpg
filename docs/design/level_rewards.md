# Level rewards (1-30)

Generated from `data/progression/level_track.json` by `tools/level_rewards_doc.gd` - edit the data file, then re-run the tool.
Every level grants something; **bold** levels are the big unlocks (the level-up screen highlights them). Packs marked
"Path" / "Gilded" are the player's own Path (Beefcake shown here). Stats (HP, hands, item slots) are computed by
`ProgressionTable` from the track's `stats` section.

| Level | XP to reach | Headline | Rewards |
|---|---|---|---|
| 1 | 0 |  | Starting stats. |
| 2 | 30 | A little something for the road | 60 gold. +1 starting HP (11). |
| 3 | 90 | Looking sharp | Bowler Hat (cosmetic). 40 gold. |
| 4 | 180 | Your first Path Pack | Beefcake Pack. +1 starting HP (12). |
| **5** | 300 | **The armory opens** | The armory opens: Bertram Beetsworth's quest unlocks every equipment slot. Wear up to 1 Epic piece of equipment. 80 gold. |
| 6 | 450 | Tilly's back shelf | Unlocks the second half of Tilly's stock. 100 gold. +1 starting HP (13). |
| **7** | 630 | **Two more deck slots** | Deck Station: 4 to 6 deck slots. General Pack. |
| 8 | 840 | A bigger opening hand | Opening hand size +1 (6). 120 gold. +1 starting HP (14). |
| 9 | 1080 | Uncommons up to 3 copies | Uncommon cards: up to 3 copies. Beefcake Pack. |
| **10** | 1350 | **A second item slot** | Wear up to 3 Uncommon pieces of equipment. +1 item slot (2). Patchwork Cloak (cosmetic). 100 gold. +1 starting HP (15). |
| 11 | 1650 | Regular customer | Permanent vendor discount +10%. 150 gold. |
| 12 | 1980 | Epics up to 2 copies | Epic cards: up to 2 copies. Beefcake Pack. +1 starting HP (16). |
| 13 | 2340 | Bertram's advanced rack | Wear up to 2 Epic pieces of equipment. Unlocks Bertram's advanced equipment rack. 150 gold. |
| **14** | 2730 | **Two more deck slots** | Deck Station: 6 to 8 deck slots. Max hand size +1 (11). General Pack, Tier II. +1 starting HP (17). |
| 15 | 3150 | A hat with opinions | Tricorn (cosmetic). 120 gold. |
| 16 | 3600 | A bigger opening hand | Wear up to 5 Uncommon pieces of equipment. Opening hand size +1 (7). Beefcake Pack. +1 starting HP (18). |
| 17 | 4080 | Sable's rare stock | Unlocks a small batch of rarer cards at Sable's stall. 200 gold. |
| **18** | 4590 | **Legendaries up to 2 copies** | Legendary cards: up to 2 copies. Gilded Beefcake Pack. +1 starting HP (19). |
| 19 | 5130 | A third Epic piece | Wear up to 3 Epic pieces of equipment. 250 gold. |
| **20** | 5700 | **A third item slot** | +1 item slot (3). Beefcake Pack. 150 gold. +1 starting HP (20). |
| **21** | 5754 | **All ten deck slots** | Deck Station: 8 to 10 deck slots. Permanent vendor discount +10%. General Pack. |
| **22** | 5862 | **Your first Legendary gear** | Epic cards: up to 3 copies. Wear up to 1 Legendary piece of equipment. Gilded Beefcake Pack. +1 starting HP (21). |
| 23 | 6024 | Hazard pay | 300 gold. Beefcake Pack. |
| 24 | 6240 | A bigger opening hand | Opening hand size +1 (8). General Pack, Tier II. +1 starting HP (22). |
| 25 | 6510 | Epic gear in every slot | Wear up to 5 Epic pieces of equipment. Red Cape (cosmetic). 200 gold. |
| 26 | 6834 | Pocket money for heroes | 350 gold. Beefcake Pack. +1 starting HP (23). |
| 27 | 7212 | Sable's deepest drawer | Unlocks a small batch of rarer cards at Sable's stall. Gilded Beefcake Pack. |
| **28** | 7644 | **A second Legendary piece** | Wear up to 2 Legendary pieces of equipment. Max hand size +1 (12). 300 gold. +1 starting HP (24). |
| 29 | 8130 | Almost a legend | 400 gold. Gilded Beefcake Pack. |
| **30** | 8670 | **Legend of Patchwork** | Legendary cards: up to 3 copies. +1 item slot (4). Prismatic Pack. Wizard Hat (cosmetic). +1 starting HP (25). |

## Anchors

- **Level 5**: first Epic gear. (Oct 20: the armory quest, "Some Assembly Required", no longer starts at level 5: Elder Maren gives it after the store room, which is when the early-game chain brings a new hero to level 5; see docs/design/quests.md.)
- **Levels 7, 14, 21**: two more Deck Station slots each (4 -> 10).
- **Copy caps** reach 3 for every rarity by level 30: Uncommon 9, Epic 12/22, Legendary 18/30.
- **Equipment caps**: Epic 1/2/3/5 at 5/13/19/25, Uncommon 3/5 at 10/16, Legendary 1/2 at 22/28.

## XP curve

Unchanged: 15 x L x (L-1) up to level 20 (5700 XP), then +40 x (L-20) x (L-19) (10100 XP at 30). `tools/xp_budget.gd` sums what one
playthrough offers; see the Overnight Oct 17 report for the numbers and the reasoning.
