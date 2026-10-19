# Overnight report - Oct 18-19 2026

Start Sun Oct 18 18:28 MDT (tag `pre-overnight-oct18`), target end Mon Oct 19 06:28. Last night's report: `docs/overnight_report_oct17.md`.
**Checkpoint version** (written at cycle 9, ~00:00); the final version replaces this at the end of the run.

## In one minute

- **Balance**: equipment/items/economy measured piece by piece (Part 1), five sim iterations over all 97 fights (Part 2) and seven balance
  cycles. Items now work **once per battle** each. Starting decks closer (round robin spread 24 -> 13 points), tutorial runs 80-92% for
  every Path. Late elites and bosses that were 90-100% now mostly sit in or near their bands; a handful still need a design call (inbox).
- **Playtest support**: **Report a Problem** (F8 / pause): screenshot, log, save copy, area + quest, opens the folder. **Crash-safe saves**
  with a backup the game falls back to; autosave on area change, after battles and quest steps.
- **Arrival cards** for every zone, the Capital, Crosspath, the forest and every dungeon, with a Path icon and subtitle; brief after the
  first visit; skippable. A **Path warning** when a zone works against your Path.
- **Settings**: battle speed 1x / 1.5x / 2x, auto-end turn (off by default), the end-turn warning names unused energy.
- **Dialogue presentation plan** + **204 portrait expression requests** (docs only, nothing generated).
- **The long-failing camera test** was stale (it read your saved zoom); fixed in the test. The forest's purple shapes are gone since the rebuild.

## Phase 1 by part

| Part | Commit | What |
|---|---|---|
| 1 - Rebalance F | dea1e329 | `--what=gear` sim mode (each piece/item vs bare, common random numbers), `tools/economy_audit.gd`; items once per battle; Rolling Pin -> Epic (+38 for Gourmand), Trash Panda Tiara -> Uncommon, Big Brain Beret -2 max HP, Cheater's Dice / Thorned Loincloth drawbacks softened (they were worse than nothing), Scroll of Insight draws 2, price fixes, Alchemist needs 6 essence (was 10) |
| 2 - Rebalance G | ad4c98cb | 97 fights measured, 5 iterations; sim bug fixed (town NPCs simulated at 15 HP); levers that work: foe basics (early/mid), one-sided stat rules (late); Necrocrat/Beefcake starter swaps |
| 3 - Playtest support | 29e84c95 | Report a Problem; crash-safe SaveSystem (.tmp + read-back + .bak fallback); autosaves; version already on title + pause |
| 4 - Zone arrival | 12ee6d33 | Flourish (Path icon + subtitle) under the banner card, full first / brief later, skippable; dungeon cards on their zone's banner |
| 5 - Dialogue plan | 60613118 | `docs/design/dialogue_presentation_plan.md`; `docs/art/portrait_expression_requests.md` / `.csv` |
| 6 - Quest guidance | cd840871 | Already present (tracker, map marks, edge pointer); added "Go to <area>" for steps elsewhere |
| 7 - QoL settings | a2f0ed0d | 1x/1.5x/2x, auto-end turn, energy in the end-turn warning |
| 8 - Cleanup | 3744aa79 | Camera test fixed (stale test); purple shapes gone; inbox tidied |

## Portrait images (Part 5)

**204 images**: High 72, Medium 87, Low 45; 29 wait for a base portrait that does not exist yet; 11 batches of 20
(`docs/art/portrait_expression_requests.md`, `.csv`).

## Phase 2 cycles (so far)

See `docs/overnight/loop_log.md`. 1 Balance (Casserole 42 -> 73%, Prudence 38 -> 53%), 2 Balance (late elites into band), 3 Performance
(glyph warmup: town slow frames 77-82 -> 43-45), 4 Balance (Spotter/Shiro Epics), 5 Playtest readiness (zone Path warning), 6 Balance
(Doppelganger 29 -> 63%, Honor Guard 54 -> 63%), 7 Balance (Hollow Warden), 8 Performance (vendor: investigated, nothing kept),
9 Onboarding (Necrocrat tutorial run 76 -> 82%).
