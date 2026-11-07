# Critic C4c - Primm, the ending and the credits

## 1. Summary

The approach to the last boss is the best-looking part of the game I saw. The castle map is a lavish painted diorama. The Model Room still (Primm moving a tiny cottage with tweezers over a miniature of Patchwork, his reflections behind him in the mirrors) is a great image. Primm's opening lines ("I have given each of them exactly the same amount of each... I do. I counted.") give the villain a clear, funny, slightly chilling voice. Then the fight itself stops feeling like a finale. It is staged on the same generic town-square board as every other fight, not in the Model Room. It opens with a nine-icon rules wall. A headline rule ("every unit starts as a 3/3") visibly does not apply to my units. Phase 1 is a plain race against four 3/3 Militia that killed me twice. A loss throws you out of the castle to the Capital gate with a fine. Winning phase 1 gives you the same generic "Victory!" box as any roadside fight. **I never reached phase 2, the ending or the credits.** I lost phase 1 twice, won it once with the pilot in a run that then ran out of time, and the next run was stopped by the host because the PC ran out of memory. I was told not to restart it. So the ending and the credits are **not reviewed**. That gap is itself the main thing to fix in this pipeline (see finding 1).

How I played: 7 runs, about 40 minutes of wall clock, from the given Beefcake level-20 save (1330 gold; no shops in scope). The only `dev` commands I used were `dev load c4_approved`, `dev travel dungeon D-PC -2` and one `dev save c4c_p2` (by mistake it caught the post-defeat gate state, so I did not use it).
- r1-r3: castle map, Primm's intro, leader blessings, rules screen, read by hand.
- r4: phase 1 turn 1 by hand (clicks).
- r5: phase 1 turns 1-3 by hand, then the pilot. **Loss 1** in round 5: Primm still at 56 HP, me 31 to 0.
- r6: pilot from turn 1. **Won phase 1** in 9 rounds with 15 HP left. The run ended on the Victory box before Continue.
- r7: pilot from turn 1. **Loss 2** in round 8 with Primm at 7 HP. Then the run was killed by the host for low memory.
- 0 `SCRIPT ERROR`s in any `stdout.log`.

## 2. Scores

| | /10 | Reasoning |
|---|---|---|
| Fun | 4 | Phase 1 is a stat race against identical 3/3s while you sit on a hand of Powerhouses. It never becomes the clever rules puzzle the rule names promise. |
| Clarity | 3 | 9 rule icons, a "3/3" rule the board contradicts, a "Setting Up" promise I could not match to the board, "Round 1" shown in round 7, and a phase win dressed as a normal victory. |
| Difficulty | 4 (too hard and too swingy) | Same deck and same pilot: one win at 15 HP, one loss with Primm at 7, and a hand-played loss in round 5. Four 3/3s that hit from round 3 against 31 HP is a very short clock, and a loss costs the whole castle. |
| Text | 7 | Primm's voice is excellent and the four leaders' blessings land. Points off for the intro text not matching the art and for the defeat lines playing out of order. |
| Look | 7 | The castle map, Model Room still and boss cut-in are top-tier. The fight board is the reused village square, and the boss's "Model Room" never appears in play. |

## 3. Findings

1. **I could not get to phase 2, the ending or the credits in a test session.** Phase 1 alone took about 2-3 minutes of pilot time after about 70 s of load and intro, and phase 2 has to follow in the same battle. There is no checkpoint between phases: `dev load` only resumes outside the fight. A loss sends you to the Capital gate (finding 3), and the low-memory PC killed the long run.
   - Where: `c4c_r6_q_log.png`, `c4c_r7_r02_trans1.png`.
   - Severity: **blocker** for review and QA, and **major** for players (see finding 3).
   - Fix: checkpoint the final boss between phases (both for players and as a `dev travel dungeon D-PC -2 phase2` jump). Make the ending and credits reachable on their own from the Dev Menu so they can be reviewed.

2. **"Every unit, yours and his, starts as a 3/3" does not hold on the board.** Primm's Militia are 3/3, but my Portal Ripper shows 7/4 and Tavern Regular 6/4, Beefy Bouncer and Swole Patrol Sergeants 7/4, Village Militia 6/4. That is printed stats (plus Flex's +1), not 3/3. Either the rule is broken or the display ignores it. Either way the player cannot trust the boss's signature rule, and it's the one rule shown in big text on the left of the screen.
   - Where: `c4c_r6_q03.png`, `c4c_r5_p8.png`; rule text in `c4c_r3_battle_start.png`.
   - Severity: **major**.
   - Fix: apply the rule to both sides and show the changed stats on hand cards and on the board (strike-through 7/4 to 3/3), or reword the rule to what it really does.

3. **Losing the final boss throws you out of the castle and charges a fine.** "You are carried out of the dungeon", then "You wake in the dust outside the Approved Gate", "-20 gold (logged)", and the guard's "Not on my list. Off you pop." The whole castle has to be walked again, for a fight that the same deck wins or loses on draw luck.
   - Where: `c4c_r7_r02_trans1.png`, `c4c_r7_r05_trans4.png`.
   - Severity: **major**: the most likely place for a player to quit.
   - Fix: on a final-boss loss, offer "Try again" straight from the defeat screen (or respawn at the Royal Stair node), and keep the gate gag for a first defeat only.

4. **The defeat dialogue plays out of order.** The guard says "Hm? You? Not on my list. Off you pop. Heh." and "Small handling fee, mind." *before* the narration "You wake in the dust outside the Approved Gate. A guard leans over you, measuring your height...". The "Correction fee: -20 gold" banner shows before you have woken up.
   - Where: `c4c_r7_r03_trans2.png` (guard line) followed by `c4c_r7_r05_trans4.png` (wake line).
   - Severity: minor.
   - Fix: put the wake narration first, then the guard, then the fee toast.

5. **The phase 1 clock is too short and swingy for a finale.** Primm opens with 4 Militia (3/3). They start hitting for about 12 a turn from round 3, against my 31 HP, while I am limited to one infrastructure per turn (so 1-2 energy early) and two non-infrastructure cards per turn. My opening hands were 6 Powerhouses out of 10 cards twice. My hand-played attempt was dead in round 5 with Primm untouched at 56. The pilot won once at 15 HP and lost once with Primm at 7. "What beat you: Militia dealt 24 of the 33 damage" says the same thing.
   - Where: `c4c_r5_b06_t3.png` (31 to 19 before my third turn), `c4c_r5_p8.png`, `c4c_r7_r02_trans1.png`.
   - Severity: **major**.
   - Fix: start Primm with 2-3 Militia, or make "Setting Up" last until round 3 and say so. Give the player a guaranteed unit in the opening hand for this fight.

6. **"Setting Up: for its first 2 turns its units do not attack" did not match what I saw.** In r5 I went from 31 to 19 HP before my round-3 turn, which means Primm's four Militia attacked on Primm's turn 2. In r6 the first attack came in round 3. A player cannot tell what "its first 2 turns" means.
   - Where: `c4c_r3_i19.png` (rule), `c4c_r5_b06_t3.png`.
   - Severity: **major** if it's a bug, minor if it's wording.
   - Fix: count in rounds the player sees ("Primm's units can't attack until round 3"), and show a countdown badge on the Militia ("Zz 1").

7. **The finale's staging is missing.** The intro sets up the Model Room: domed, a house-sized miniature of Patchwork, mirrors. Then the fight is on the same sunny village-square board used elsewhere, with nothing of the miniature, the mirrors or the castle in it. Primm is a small portrait at top left. The intro also plays as a text box over the castle *map*, with the "Unknown. Step on it to find out what waits there." tooltip still showing under it.
   - Where: `c4c_r2_03_after_click.png`, `c4c_r3_i08.png` versus `c4c_r3_battle_start.png`.
   - Severity: **major** (the finale feels like any fight).
   - Fix: a Model Room battle backdrop (the still's table, blurred, as the board), and Primm's cut-out at the board edge. Open the intro on the Model Room still, not the map, and hide the node tooltip while dialogue is open.

8. **A phase win looks like a normal victory.** "VICTORY! You defeated Primm - Phase 1: Standardization in 9 rounds. [Continue]" is the same box as any fight. There's no sting, no "he's not done", no change of mood. The enemy name in the log and banner also reads clumsily: "Primm - Phase 1: Standardization attacks with Militia and 3 more".
   - Where: `c4c_r6_q_log.png`, `c4c_r6_q01.png`.
   - Severity: minor to major (it deflates the climax).
   - Fix: a dedicated phase-break card ("Primm straightens his circlet...") instead of the victory box. Call him "Primm" in the log and banners, and keep the phase name in the corner badge.

9. **The rules wall is too much.** Nine icons: Perfect Order, Mirrors, four leader blessings (three of which do nothing for a Beefcake), Standing Army, Setting Up and a Hidden trait. Then Primm's own rule box. In battle the icon row is drawn twice when a card preview is open.
   - Where: `c4c_r3_i19.png`, `c4c_r6_q03.png` (two icon rows at about 280,190 and 280,245).
   - Severity: minor.
   - Fix: hide blessings that don't touch your Path (or merge them into one "Allies' blessings" icon). Lead with the two rules that matter (the 3/3 rule and two cards a turn), and fix the doubled row.

10. **The intro text and the art disagree.** The text says "A man in a pressed grey coat and a thin gold circlet stands with his back to you". The still shows him facing us, in white and gold robes.
    - Where: `c4c_r3_i08.png`; the line is in the log at 49.7 s of r3.
    - Severity: minor.
    - Fix: rewrite to "a man in white and gold robes, bent over the table..."

11. **The round counter is wrong during the turn banner.** The panel shows "Round 1" while the banner reads "Round 7".
    - Where: `c4c_r6_q02.png`.
    - Severity: minor.
    - Fix: update the round label before the banner plays.

12. **The boss node is hidden as "???".** The last node, right next to Primm's throne room and reached after nine cleared rooms, is a generic "?" with "Unknown. Step on it to find out what waits there."
    - Where: `c4c_r1_01_castle.png`, `c4c_r2_03_after_click.png`.
    - Severity: minor.
    - Fix: show it as the boss node (crown icon, "The Model Room"), so the walk up the Royal Stair builds tension.

13. **Small clarity gaps in my hand-played turns.** Clicking a second infrastructure gives a good message ("One Infrastructure per turn: you already played yours."). But "Not enough energy" is the only clue to my energy, and the energy pips are tiny at bottom left. A first press of Space went straight to the second main phase, and the next one ended the turn, with no prompt that I had unused attackers.
    - Where: `c4c_r4_a07_play2.png`, `c4c_r4_a11_space3.png`.
    - Severity: minor.
    - Fix: a clear energy counter next to the hand, and an "End turn with N cards still playable?" check in boss fights.

## 4. What's great, don't touch

- **The Model Room still** (`c4c_r3_i08.png`): Primm with tweezers over a living map of the four zones, reflections in the mirrors. It's the best image in the game, and it says who he is without a word.
- **Primm's voice**: "Mind the floor: it has just been polished, by seventeen people, whom I thank daily, in writing." / "Every one of them has a number, so that nobody is ever overlooked... I do. I counted." / "This will not hurt. It will, however, be Standard." A villain who is polite, tidy and certain he is kind. Keep it.
- **The four freed leaders stepping in** before the fight (Flex's "Strength is the heart and the mind, son", the Chef's "Eat first, fight after", Agnes's technicality "It applies to him, dear", Compostella's shoot through the marble) is a lovely payoff for freeing the zones (`c4c_r3_i12.png`).
- **The boss cut-in** (`c4c_r3_i20.png`): portrait, mirror, "Phase 1: Standardization", quote. It looks like a finale.
- **The castle map** (`c4c_r1_01_castle.png`): named rooms (Archive of Good Intentions, Ministry of Correction) and gorgeous painting.
- **The "What beat you" defeat panel** names the culprit and gives an actionable tip.
- **No script errors** in any of the seven runs.
