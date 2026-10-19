# Daytime Oct 19 - loop log

| # | Category | Change | Scorecard | Commit |
|---|---|---|---|---|
| 1 | Onboarding (no change kept) | Refusemancer cave run (82%, now the lowest): single cave fights are 100% (40/40 vs the Stalker), the run losses come from HP carried between fights. Three starter swaps (Compost Bin -> Kidding Around; + Raised Bed -> Rubbish Goat; Acid Vomitor -> Kidding Around) all 80-82% over 50 runs; reverted. The lever is probably the cave HP economy (shrine/well), not the deck. | 8 | - |
| 2 | Stability + Performance | Fixed a Part 4 regression: warming the shops used up their one-time tips (TipPanel.show_once set the flag inside the unseen screen), so a new player would never see the vendor and item-shop tips; show_once now skips warming screens (test fails without the fix). The Deck Station joins the town warmup: its first open 150 -> 128 ms; full tour town worst 128 ms, zones 63-72, final 109, 0 errors. | 9 | (this commit) |
