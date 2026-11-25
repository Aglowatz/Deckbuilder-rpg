# The zone drafts' rivals, a longer measurement (Fable Nov 24)

`bash tools/run_draft_table_sims.sh rivals`: four batches of three drafts for each of the four Paths, 4 games against each of
the three rivals (level 12, the rules as shipped: rivals capped at Uncommon equipment, boss-level play, HP bonus 12).
**Two of the four batches hit the 20-minute limit** (`zone_rivals_3`, `zone_rivals_9`; logged in `_logs/nov24/table_sims.log`)
and wrote no table, so every batch is tallied here from the per-fight lines of its log. The sample is uneven for that reason:
the Paths at the end of a killed batch have fewer games.

| Path | Fights won | Games |
|---|---:|---:|
| Beefcake | **63%** | 144 |
| Gourmand | **43%** | 120 |
| Necrocrat | **61%** | 96 |
| Refusemancer | **69%** | 72 |
| **All** | **58%** | 432 |

By batch (drafts 0-2, 3-5, 6-8, 9-11): 74 % (144), 58 % (48), 52 % (144), 44 % (88). The spread between batches is the seed
variance the big pass saw (82 % and 41 % on its two halves); the mean agrees with its "about 60 %".
Gourmand is the weak draft Path against these rivals, as it is against Octavia in the Halls.
