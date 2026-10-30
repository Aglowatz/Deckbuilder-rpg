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
2. **Reward boxes and the purse (22:05)**: under "+70 gold / +30 XP" the reward box now says "462 gold in your purse now - an Uncommon
   card's worth" (`RewardPopup._worth`, from the curve's prices), so a sum reads against what it buys. Opener `--open=reward_gold`;
   shot `_screenshots/oct29/p2_reward_gold.png`; ui GUT OK. Kept.
3. **Hat tilt test (22:10)**: `fit.json` `rot` / `rot_<DIR>` covered by `test_hat_sheets` (no tilt unless set, a per-direction tilt in degrees). Kept.
4. **Reward-pick reroll (22:25)**: the audit's missing late sink. `RewardSummary.reroll` / `reroll_price` / `rerolled`, `Session.reroll_reward_pick`
   (pays `Economy.reroll_price(level)`, draws the pick again without counting a win, once), a "Reroll the cards (N gold)" button under the
   three cards that greys out when the purse is short and rebuilds the row in place. Tests in `test_world_reward_pick`; gatekeeper pick probes
   by mouse and pad; shot `_screenshots/oct29/p2_reroll.png`. Economy model given reroll offers (about two per zone). Kept.
