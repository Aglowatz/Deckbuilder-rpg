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
5. **Side dungeons with the real gear (22:45)**: S-IRON / S-TOWN / S-NECRO / S-GOUR (then S-REF / S-CAP / S-BEEF / D-LAB) simmed at 6-12 games; Baron
   Quadzilla read 33 / 31 % on two seeds (under the ~35 floor) with the Colorless-only Dagger at L8, so his "Max Pump" rule is +1 attack
   instead of +1/+1 (29 / 46 after; `modifiers.json`, not a dialogue file). The Vault's normals (54-67) live in the frozen dungeon_content.json:
   inbox 10. Logged in balance_log.md. Kept.
6. **Late side bosses (23:00)**: with the real L16+ gear (Gauntlets + Waistband) the Raccoon was 92 %, the Grate's Spotless 88, the Ancient
   Spotter 79, the Lab's Failed Experiment 94. The Raccoon's rule is +2/+2 (46 % after), Spotless's +4/+3 (73 %); the rest noted (inbox 12).
   Core GUT OK. Kept.
7. **Tailor preview (23:05)**: `--open=tailor --wear=cloak_red_cape,hat_wizard` - the wizard hat sits on the head in the tailor's preview
   (`_screenshots/oct29/p2_tailor_hat.png`). No change.
8. **Second seeds (23:10)**: the Hall, the Test Kitchen and the Rotheart at 12 games on seed 8100 - Mortimer 56, the Doppelganger 50, the
   elites 67-83 (Rotheart below). The bosses of the first three zones hold their band on both seeds. No change.
9. **Dungeon picks reroll too (23:30)**: `RewardOffer.reroll / reroll_price / rerolled`, `Session.reroll_dungeon_pick` (the same price, the same
   generator branch as the offer, the boss's chase card kept, never in the tutorial's first run), a "Reroll (N gold)" button beside Skip on the
   dungeon rewards screen that rebuilds the card row. Test in `test_world_reward_pick`; dungeons smoke and prologue smoke; shot
   `_screenshots/oct29/p2_dungeon_reroll.png`. Kept.
10. **Model with dungeon rerolls (23:15)**: the economy model offers two rerolls a dungeon as well; expected spends 98 % (320 left), thorough
    93 %. Loop closed here: what is left (the XP curve, Primm, the Honor Guard, the Vault, the late elites) is the designer's call (inbox).
