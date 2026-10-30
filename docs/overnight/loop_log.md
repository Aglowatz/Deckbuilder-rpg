# Overnight Oct 29-30 - Phase 2 polish loop

Rules: polish on tonight's work (shop and character readability of the new prices and gear, upgrade / sidegrade hints, reward screens showing
gold meaningfully, then economy or hat issues found); each cycle verified, committed or reverted; STOP_OVERNIGHT checked between cycles.
Parts 1-4 landed at 6264456c, 04d28dcc, 45311175, 2d38e6e9. Last run's log: `docs/overnight/oct29/loop_log_oct28.md`.

## Cycles

1. **Shop and picker verdicts (21:40)**: `EquipmentCompare.verdict` (pure, `tests/core/data/test_equipment_compare_verdict.gd`): Upgrade /
   Sidegrade / Downgrade / Empty slot / Equipped against what is worn in that slot. Bertram's and the zone stalls' tiles now show
   "Uncommon Weapon" in the rarity colour with a rarity-tinted border, the effect text readable on the tile (it was invisible: only the
   tooltip had it), and the verdict line ("Sidegrade vs Solid Plate"); the character screen's piece picker leads with the verdict word before
   the number changes. Shot `_screenshots/oct29/p2_vendor_geared.png` (new opener `--open=equipment_vendor_geared`). ui GUT OK. Kept.
