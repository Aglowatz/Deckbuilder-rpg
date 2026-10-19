# Overnight inbox

Leave instructions here for the overnight run (one per line). The run reads this file before each part and logs what it did.

Older open questions (Oct 17 overnight, the rebalance, the v0.4.0 playtest build) are in `docs/overnight/inbox_archive.md`.

## Overnight Oct 18-19 - yours to decide (the safest choice was taken; most important first)

1. **Items work once per battle** (Part 1). Each equipped item can be used once per fight (1 / 2 / 3 uses with 1 / 2 / 3 item slots);
   leftover charges carry to later fights. Before, a stack of Salves could all be drunk in one fight and carry anything. Say if you prefer
   "one item per turn" instead (`GameState.items_used`).
2. **The Gainlands are nearly unwinnable for a level-5 Necrocrat** (17% vs both roamers in the sim): the zone's Processing Time debuff
   makes Necrocrat units enter exhausted. Players are now warned on arrival and pointed to the D.N.A. (cycle 5). Keep the rivalry as is,
   soften the debuff, or route Necrocrat players to the D.N.A. first?
3. **The Rotheart's normals stay at 54-63%** under its two rules (Overgrowth: every unit +1/+1 each turn; Rot: 1-defense units die at end
   of turn). A replay shows the sim player turtling while the foe board grows; a person who attacks does better. Keep, make Overgrowth every
   second turn, or make Rot one-sided?
4. **Late bosses that do not respond to numbers**: Shiro (88%, his deck is traps), Grand Bellows (75-79%), Primm phase 1 (100%, but the
   three phases in a row come to ~50%). Stat rules (+N/+N for the boss's units) brought nine other late fights into or near band; say if
   you would rather raise their decks than give them rules.
5. **Starting decks changed** (Part 2, cycle 9): Necrocrat 2 Waiting Room, 2 Ghoul, 1 Red Tape Dispenser, 1 Corpseified Public Accountant
   (from 3 Notary Wraiths, 2 Requisition Forms, 1 Invisible Ink); Beefcake 1 Mill Worker, 2 Shot Putters. L1 spread 24 -> 13 points.
   The live sheet needs these rows (`docs/design/sheet_changes.md`).
6. **Rarity and gear moves** (Part 1): Grandma's Rolling Pin Uncommon -> Epic (+38 for Gourmand at L12), Trash Panda Tiara Epic -> Uncommon;
   Big Brain Beret -2 max HP; Cheater's Dice lost its -1 hand; Thorned Loincloth -2 max HP (was -5); Scroll of Insight draws 2;
   Alchemist needs 6 essence of two Paths (was 10).
7. **A listen pass**: the new sounds are existing bank events (save chime on a sent report, end-turn on an auto-ended turn, a soft alert
   with the zone Path warning), plus last night's open items (music leveller, boss stings, MUS-SHOP-GRISTLE's loop step).
8. **Battle speeds are 1x / 1.5x / 2x** (were 1 / 1.7 / 2.8) as asked; the old 2.8x is gone. Auto-end turn is off by default.
9. **Arrival card subtitles** ("Home of the Beefcake Path", "Where every Path crosses", "Seat of His Perfection", "Beneath Crosspath"
   for the town's dungeons): edit them in `ZoneTitleCard.SUBTITLES`.
10. **Dialogue presentation plan** (Part 5): open questions at the end of `docs/design/dialogue_presentation_plan.md`; 204 portrait images
    in `docs/art/portrait_expression_requests.md` (High 72 / Medium 87 / Low 45; 29 wait for a base portrait). Fig Sly is left out on purpose.

Resolved tonight: Oct 17 item 12 (floating exit labels - no 3D words at the zone exits since v0.4.0); the starting forest's purple
top-edge shapes (gone since the Opening Forest rebuild); Colonel Casserole and Prudence Pallor (their free starting units were the problem,
cycle 1); the spells-only arena (cycle 10).
