# Level rewards (1-30)

Generated from `data/progression/level_track.json` by `tools/level_rewards_doc.gd` - edit the data file, then re-run the tool.
Every level grants something; **bold** levels are the big unlocks (the level-up screen highlights them). Packs marked
"Path" / "Gilded" are the player's own Path (Beefcake shown here). Stats (HP, hands, item slots) are computed by
`ProgressionTable` from the track's `stats` section.

| Level | XP to reach | Headline | Rewards |
|---|---|---|---|
| 1 | 0 |  | Starting stats. |
| 2 | 50 | A little something for the road | 60 gold. +1 starting HP (16). |
| 3 | 120 | Looking sharp | Bowler Hat (cosmetic). 60 gold. |
| 4 | 200 | Your first Path Pack | Beefcake Pack. +1 starting HP (17). |
| 5 | 300 | Getting the hang of this | 120 gold. |
| **6** | 580 | **A third item slot** | +1 item slot (3). 100 gold. +1 starting HP (18). |
| **7** | 880 | **Two more deck slots** | Deck Station: 4 to 6 deck slots. General Pack. |
| 8 | 1220 | A bigger opening hand | Opening hand size +1 (6). 150 gold. +1 starting HP (19). |
| 9 | 1600 | Uncommons up to 3 copies | Uncommon cards: up to 3 copies. Beefcake Pack. |
| **10** | 2025 | **A little pocket money** | Patchwork Cloak (cosmetic). 150 gold. +1 starting HP (20). |
| 11 | 2460 | Regular customer | Permanent vendor discount +10%. 150 gold. |
| **12** | 2905 | **A fourth item slot, and Epics up to 2 copies** | Epic cards: up to 2 copies. +1 item slot (4). Beefcake Pack. +1 starting HP (21). |
| 13 | 3360 | Bertram's advanced rack | Unlocks Bertram's advanced equipment rack. 200 gold. |
| **14** | 3825 | **Two more deck slots** | Deck Station: 6 to 8 deck slots. Max hand size +1 (11). General Pack, Tier II. +1 starting HP (22). |
| 15 | 4300 | A hat with opinions | Tricorn (cosmetic). 200 gold. |
| 16 | 4785 | A bigger opening hand | Opening hand size +1 (7). Beefcake Pack. +1 starting HP (23). |
| 17 | 5280 | The shops' best stock: Sable's rares, Tilly's high shelf | Unlocks a small batch of rarer cards at Sable's stall. Unlocks the second half of Tilly's stock. 250 gold. |
| **18** | 5785 | **Legendaries up to 2 copies** | Legendary cards: up to 2 copies. Gilded Beefcake Pack. +1 starting HP (24). |
| 19 | 6300 | Seasoned traveler | 250 gold. |
| **20** | 6825 | **Halfway to legend** | Beefcake Pack. 300 gold. +1 starting HP (25). |
| **21** | 7360 | **All ten deck slots** | Deck Station: 8 to 10 deck slots. Permanent vendor discount +10%. General Pack. |
| **22** | 7930 | **Epics up to 3 copies, and a Gilded Pack** | Epic cards: up to 3 copies. Gilded Beefcake Pack. +1 starting HP (26). |
| 23 | 8535 | Hazard pay | 150 gold. Beefcake Pack. |
| 24 | 9175 | A bigger opening hand | Opening hand size +1 (8). General Pack, Tier II. +1 starting HP (27). |
| 25 | 9850 | A cape worth swishing | Red Cape (cosmetic). 200 gold. |
| 26 | 10560 | Pocket money for heroes | 200 gold. Beefcake Pack. +1 starting HP (28). |
| 27 | 11305 | Sable's deepest drawer | Unlocks a small batch of rarer cards at Sable's stall. Gilded Beefcake Pack. |
| **28** | 12085 | **Room for one more card** | Max hand size +1 (12). 250 gold. +1 starting HP (29). |
| 29 | 12900 | Almost a legend | 300 gold. Gilded Beefcake Pack. |
| **30** | 13750 | **Legend of Patchwork** | Legendary cards: up to 3 copies. Prismatic Pack. Wizard Hat (cosmetic). +1 starting HP (30). |

## Anchors

- **Level 5**: the armory quest ("Some Assembly Required") starts by itself and unlocks every equipment slot; first Epic gear.
- **Levels 7, 14, 21**: two more Deck Station slots each (4 -> 10).
- **Copy caps** reach 3 for every rarity by level 30: Uncommon 9, Epic 12/22, Legendary 18/30.
- **Equipment caps**: Epic 1/2/3/5 at 5/13/19/25, Uncommon 3/5 at 10/16, Legendary 1/2 at 22/28.

## XP curve

Unchanged: 15 x L x (L-1) up to level 20 (5700 XP), then +40 x (L-20) x (L-19) (10100 XP at 30). `tools/xp_budget.gd` sums what one
playthrough offers; see the Overnight Oct 17 report for the numbers and the reasoning.
