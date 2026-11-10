# Late-game critic report: The Wayward Path v1.0.0-rc1 (exported build), Nov 10

(Saved by the overnight run from the critic agent's hand-back: the harness blocked the agent's own write. Text as delivered.)

Screenshots: `shots/` (41). Play scripts: `docs/review/play_scripts/critic_late_n10_01.txt` ... `_25.txt`.

**Scores:** Clarity 5/10, Fun 4/10, Polish 5/10. No `SCRIPT ERROR` in any of the 25 game logs.

## 1. Summary and how I played

The Capital and Primm's Castle look good and read clearly from the outside: the map, the castle entry popup, the painted node map and
Primm's introduction are the best-presented things I saw. The late game falls down in three places. **I could not beat Primm**: six
losses, all by round 4-5, Primm on 56 HP in four of them, so I never saw the ending. **The `c13end` and `c13post` snapshots do not reach the
ending or the postgame**: both load Crosspath with "Storm Primm's castle" still active. And **the story stills have a collage problem**:
speaker portraits pasted into paintings that already contain the same characters.

25 runs of 170 s or less, one at a time, foreground; about 50 minutes of game time.
- Runs 1-5: `c13cap`, the Capital on foot (Gate Road, Gate Plaza, Palace Approach, the castle doors, no jump), the castle-gate cutscene.
- Runs 6-9: `dev travel dungeon D-PC`; the Courtyard of Perfect Hedges by hand then pilot (won in 7 rounds at 2x).
- Runs 10-20: `dev travel dungeon D-PC -2`, Primm's intro, six real Primm fights (no dev win/autowin/encounter): attempts 1-2 at level 20,
  3-6 at level 24 (`dev level 24`, `dev heal` after the 2nd loss); own drags for rounds 1-3 in four. All ended in Phase 1 (Primm's lowest HP 30).
- Runs 21-22: `c13end`, `c13post` both load Crosspath before the castle.
- Runs 23-25: the title Credits; `dev travel dungeon D-LAB` from `c13post`: intro read, first fight lost on the pilot.

## 2. Scores
- **Clarity 5/10.** Map, quest log and the pre-fight rules panel are clear; the boss fight contradicts itself (the 3/3 rule vs 7/4 cards, two
  energy messages, the Setting Up count); played infrastructure is almost invisible.
- **Fun 4/10.** The walk up to the castle builds well and the first castle fight was fine; the final boss is a wall (4-7 Militia, 36 damage
  in about two swings) and a loss restarts the 20-room castle.
- **Polish 5/10.** Rich painted UI, node maps and card art, against collaged stills, a village backdrop for the final boss, the "1 done"
  HUD line and the flat outer Capital backdrop.
- **Broken:** the ending/postgame snapshots, the HUD "1 done", the contradictory energy messages.
- **Unfinished / AI-made:** duplicated speaker cut-outs in stills (`l5_06`, `l5_07`, `l5_09`), mirror clones in the Model Room still, the
  template boss reward line. The credits disclose the AI art (`l23_01_credits`).

## 3. Top 10 problems
1. **Final boss is a wall** (`l14_03`, `l16_04`, `l19_end`, `l20_end2`, `l14_02_turn1`). **Blocker.** Primm opens with 4 Militia, adds 1-3
   units and an Old Kingdom Banner (4/3s); when Setting Up ends they hit for 30+ ("Militia dealt 36 of the 39 damage you took (12 hits)").
   1-2 energy against costs of 2-7; level 24 made no visible difference; a loss restarts the castle. Fix: open with 2 Militia or extend
   Setting Up until the player has 3 infrastructure; respawn at the Royal Stair.
2. **Ending and postgame snapshots** (`l21_00`, `l22_00`, `l22_04_J`). **Blocker for review.** Both load Crosspath with "Storm Primm's
   castle" active (5/6). Fix: re-save `c13end` after Primm and `c13post` after the credits.
3. **Collaged stills** (`l5_06`, `l5_07`, `l5_09`, `l4_07_E`). **Major.** Speaker cut-outs duplicate characters already in the still
   (Percival, Elowen); Tessar's overlaps a guard. Fix: nameplate only when the speaker is already in the still.
4. **Primm on a village board** (`l14_02_turn1` vs `l6_03`). **Major.** Fix: the castle-hall or a Model Room board.
5. **Rule text contradicts the screen** (`l14_02_turn1`, `l15_03_r1played`, `l15_05_r2`, `l13_01`). **Major.** "Every unit is a 3/3" vs
   7/4 hand cards; "You have 1 energy left and can still play 1 card" with "Needs 7 energy; you have 0"; the panel says attacks "from
   round 3", the HUD in round 1 "Setting Up: 3 rounds left". Fix: adjusted stats on cards, one energy count, aligned counter.
6. **Invisible infrastructure and two-row hands** (`l15_03_r1played`, `l8_08_after`). **Major.** Fix: an infrastructure strip with an
   energy counter, one fanned hand row.
7. **HUD shows "1 done"** (`l1_02_capital`, `l21_00` vs `l22_04_J`). **Minor.** The first ticked line should read "The Gainlands: beat its main dungeon".
8. **Template boss panel** (`l11_01`). **Minor.** "50 gold and XP, a choice of card"; the intro box covers the panel.
9. **Dialogue inconsistencies** (`l11_01`, `l11_08`, `l12_01`, `l24_01_node`). **Minor.** Esc opens the pause menu during the first intro
   lines; two box styles in one scene; the skip prompt repeats its title ("Skip this scene? / Skip this scene? You haven't seen it.").
10. **Outer Capital road** (`l1_02_capital`, `l1_06_walkW`, `l2_07_n30`, `l3_02_afterE`). **Minor.** Flat washed-out wall backdrop, blotchy
    stairs; HP 23 -> 21 (once 19) from an unseen Tidy-Bot whose message is not readable on screen.

## 4. Smaller notes
- Castle-gate still vs text: the text says the Rescuer "stands ... as if she was always going to be here" while the still shows guards
  gripping her (`l5_01`); later the guards "pour from the gatehouse" (`l5_04`). The writing itself is good.
- Best lines: Primm's "Ten years I have been mending this kingdom ... I am afraid I shall have to correct you." (`l11_12`), "Do mind the
  floor..." (`l13_03_turn1`), the hero's "Sorry, that's forest mud." (`l11_08`).
- Flavour clash: Primm's Hedge Trimmer Guard fields Resistance Scouts (`l8_08_after`).
- "MIRRORS COPIED TRIPWIRE" banner without showing what was received.
- Map legend says "Goal: Free the Four Zones" while the castle is the goal (`l2_05_map`).
- Castle Gate node unlabelled "???" after the `-2` jump (`l10_01_map`), possibly the jump.
- Lab: max HP 5 lower ("Specimen Conditions", `l25_01_node`); good intro; the pilot lost the first fight (`l25_04_after`).
- The pilot often logged "the turn is not moving" in boss and Lab fights (possibly the driver).
- Credits: a static panel, mostly licence text (`l23_01_credits`).
- The defeat screen says "Losing costs nothing" while a loss restarts the 20-room castle (`l20_end2`).

## 5. What worked
1. The Gate Road to Gate Plaza tone shift and the fully labelled map (`l2_02_n10`, `l2_05_map`).
2. The castle entry popup and the painted node map (`l4_04_E`, `l10_01_map`).
3. Primm's presentation: the Model Room still, the phase title card, his lines (`l11_08`, `l13_03_turn1`).
4. The "Before the fight" rules panel and the "What beat you" defeat recap (`l13_01`, `l20_end2`).
5. Card hover previews and the mulligan panel that counts infrastructure (`l7_02_hover`).
