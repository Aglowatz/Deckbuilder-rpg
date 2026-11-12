# Critic report - late game, release candidate v1.0.0-rc5 (Nov 12)

Saved by the main session from the critic's hand-back (the critic's own write to this file was refused). The critic had no context
beyond `docs/review/critic_late_nov12_brief.md` and played the exported RC5 pack. Its play scripts are
`docs/review/play_scripts/critic_late_n12_01.txt` to `_30.txt`; its screenshots (`q<run>_*.png`) and logs are in `_screenshots/exported/`
(not in the repo). **What was done about it** is at the end, written by the main session, not the critic.

## 1. Summary and how I played

**Summary.** The end of The Wayward Path looks and reads like a finished game: the castle, Lab and Gallery maps and the story stills are
beautiful, Primm's dialogue is the best writing I saw, and the battle screen now explains itself well. What I could not do is finish it.
Phase 1 of Primm fell on the first completed try in 8 turns. Phases 2 and 3 beat the built-in player in all five fights that finished
(levels 20 and 24), usually by turn 6-9, with a sixth cut off on 1 HP, and a loss throws you out to the Crease with the 21-room castle
reset. So I never saw the ending cutscenes or the in-story credits. I judged the "after Primm" state from the `c13end` / `c13post`
snapshots, which look identical to each other.

**How I played.** 30 scripts, 34 runs, one at a time, each under 170 s. About 54 minutes of process time, roughly 40 minutes in game after
loading.

- **Capital (q1-q4):** from `c13cap` I walked the Gate Road, the gate, the Gate Plaza and the Palace Approach to the castle door, and
  entered on foot. Snapshots do not keep your position, so the walk had to fit one run.
- **Castle (q5-q12):** `dev travel dungeon D-PC` (node 1 and 2). I read the gate scene, played the Courtyard fight half by hand (4 turns
  of clicks, then `pilot`, won turn 10), then used `dev autowin on` for the Courtyard again and took the Grand Foyer event. I only ever
  entered those two rooms, and autowin went on after one played room, not the two the brief asks for.
- **Primm (q13-q22):** `dev load c13castle` then `dev primm 1/2/3`. No `dev win` or autowin. `dev level 24` and `dev heal` from the third
  phase-2 try onward.
- **After Primm (q23-q30):** `dev load c13end` and `c13post`, the title-screen Credits, `dev travel dungeon D-LAB` (one fight, piloted, won
  turn 8), a walk to the cracked mirror, and `dev travel dungeon S-GALLERY` (map and rules only).

**Not done.**
- No Primm phase played start to finish by hand. I played turns 1-4 of phase 2 with clicks (q16) and the first three turns of another try
  (q20); a blind hand-played phase does not fit in 170 s. No drags in a Primm fight, and I never declared an attack by hand.
- Phase 2 was never beaten. I used `dev primm 3` to see phase 3 anyway.
- The ending, epilogue and in-story credits were not seen.
- The funeral on Grave Row was not reached.

## 2. Scores (old build: clarity 5, fun 4, polish 5)

I did not play the Nov 11 build, so "what moved" is my reading against the old numbers.

**Clarity 6/10 (was 5).** The boss tooltip, the "Before the fight" panel, the "In this fight: 7/4 (printed 4/4)" breakdown and the defeat
recap tell you exactly what is going on (q11_end, q14_99, q18_99b). It stops short of 7 because every dungeon room is "???", the epilogue
event has no pointer, and the phase 3 hint promises something the numbers do not deliver.

**Fun 4/10 (unchanged).** Phase 1 and the Lab fight were good 8-turn fights that I watched the built-in player win. Phases 2 and 3 ended
six runs in a row with a hand full of cards I could not afford, and the penalty for losing is the whole castle again.

**Polish 6/10 (was 5).** Painted maps, stills, portraits and cards are release quality, and there were zero SCRIPT ERRORs in 34 runs. The
walkable Capital is the weak spot: flat untextured stairs and walls, a crude flat mirror, and a few clipped or overlapping texts.

**Broken.**
- The turn panel runs off the right edge of the screen while "Setting Up: 2 turns left" is shown (q14_t2_c).
- The built-in player stalls ("the turn is not moving") 2-6 times per fight in Primm phases 2 and 3 and never in phase 1, the Courtyard
  or the Lab. I could not see why.

**Unfinished or obviously AI-made.**
- The cracked mirror is a flat blue rectangle with black and white blocks (q30_03_left).
- The castle steps and Palace Approach walls are bare 3D boxes next to painted portraits (q2_05_north2).
- The story stills have the over-smooth look of generated art, but they are consistent with each other and I would not call them a
  problem. The credits say so openly.

## 3. The Primm fight

Eight tries (two at phase 1, four at phase 2, two at phase 3), all at 2x speed with the built-in player unless noted.

| Try | Run | Phase | Level | Result | Detail |
|---|---|---|---|---|---|
| 1 | q14 | 1 | 20 | Unfinished | 1x speed; run ended at turn 8, Primm 21/56, me 22/31 |
| 2 | q15 | 1 | 20 | **Won, turn 8** | "PHASE BROKEN!", me 16/31 |
| 3 | q17 | 2 | 20 | Lost, turn 6 | Primm 45/52; he attacked with 6 units against my 1 |
| 4 | q18 | 2 | 20 | Lost, turn 8 | Primm 52/52 untouched; Beefy Bouncer dealt 15 of 43 damage |
| 5 | q19 | 2 | 24 | Lost, turn 7 | Primm 52/52; he had about a dozen cards on the table to my one |
| 6 | q20 | 2 | 24 | Lost, turn 9 | I played the first three turns by hand; Primm 35/52 |
| 7 | q21 | 3 | 24 | Lost, turn 8 | Primm 30/50; Resistance Scout dealt all 36 damage in 9 hits |
| 8 | q22 | 3 | 24 | Unfinished | Six stalls; run ended at turn 6 with me on 1 HP, Primm 44/50 |

**Why I lost.** Each Infrastructure gives 1 energy a turn, and I was landing about one a turn, so by turn 8 (my fourth turn) I had 4
energy and a hand of cards costing 3 to 5. In phase 2 he plays my deck while drawing two extra cards a turn; in phase 3 his units get
+1/+1 and he draws an extra card. He floods the table before my deck can deploy. The built-in player's stalls make this worse, so a human
would do better, but the shape of the loss was the same every time.

**Militia count and Setting Up.** Both read clearly.
- The Militia are one stack with an "x3" badge, a 3/3 and a Zz (q14_t2_c). The boss tooltip and the "Before the fight" panel both say
  "3 Militia (3/3)".
- "Setting Up - attacks start Turn 3" sits by the hourglass in the rules row, and the turn panel counts it down. The row text is small,
  and the turn panel line is the one that gets clipped.

**Were the phases distinct?** Yes, on paper and in play.
- Phase 1, Standardization: every unit is a 3/3 and you may play two cards a turn.
- Phase 2, Reflection: he plays a copy of your deck. His copies are meant to "shine silver"; the tint is faint (q16_t4_c).
- Phase 3, Unraveling: he loses 1 HP a turn. The hint says "hold the line and he runs out of time", but he has 50 HP, so that is 50 turns.
- All three phases use the same battle backdrop, and phases 2 and 3 open on the same banner quote ("Do mind the floor..."), which
  undersells the change.
- The talk between phases is excellent: "Because some things are five. Some people are." and "I only wanted it to be nice."

## 4. The ending and the credits

**Not seen.** I never beat phase 3, so I did not read the ending cutscenes, the epilogue or any in-story credits roll.

**What I read around it.**
- **Castle gate scene (q5):** Elowen is named and arrested by a peacock minister. "I asked her twice, and both times she said 'a friend',
  and both times I let her." This landed.
- **Primm's intro (q13):** "This will not hurt. It will, however, be Standard." Funny and menacing at once.
- **The freed leaders (q13_i16):** they step in with boons before the fight. Good idea, but it plays over the dungeon map instead of the
  Model Room painting.
- **Title-screen Credits (q27):** one name, the tools, the licences, and a plain statement that the game was made by one person with AI
  tools. Honest and clear, but it is a licence wall, not an ending.

**How the postgame is announced (`c13end` / `c13post`).**
- The Capital has changed: bunting, the gold statue toppled into the fountain, and the speaker now says "Welcome to Pathordia." instead
  of "Welcome to Primm's Perfection" (q26_01). This is a lovely payoff.
- A new main quest, "Under the Forest", is tracked in the HUD with "Go to Crosspath" and a "Where to go" line (q27_05). I knew where to
  go next.
- A toast says "At the end of Grave Row, the city is gathering at dusk." Nothing points to it: it is not in the "Point me to..." list
  (q24_01_point) and the Crease is "You are here" on the Rift Express (q25_01_ft). I gave it two runs and found no way down from the plaza.
- The Shattered Gallery is in the pointer list as "(the cracked mirror) (Mini dungeon, usually level 26)", and the mirror is by the castle
  door at the left of the steps.
- The Feats page in the pause menu lists "See Isla come home" and "Attend the royal funeral" in plain text; I saw this on a save that had
  already earned them, so I cannot say it spoils a first run.

## 5. Top 10 problems

| # | Problem | Where | Severity | Smallest fix |
|---|---|---|---|---|
| 1 | Primm phases 2 and 3 beat the built-in player in all 5 finished fights at levels 20-24; the hero has 4 energy and a full hand when he dies | q17_99, q19_99, q18_99b | Blocker for my playthrough; major if a human copes | Slow his extra draw in phase 2 for the first turns, or give the hero a starting energy in the Model Room |
| 2 | Losing any Primm phase resets the whole castle and drops you in the Crease, a long walk from the door | q18_99b, q19_99c | Major | Offer "Retry this phase" on the defeat screen |
| 3 | The built-in player stalls 2-6 times a fight in phases 2 and 3 only | play logs q17-q22 | Major (may be a real input stall) | Reproduce phase 2 by hand at turns 1-3 and watch for a prompt that blocks the turn |
| 4 | Turn panel overflows the screen edge during Setting Up ("2 turns lef") | q14_t2_c | Major (it is the line that explains the window) | Wrap the line or shorten it to "Setting Up: 2" |
| 5 | The funeral toast has no route: not in "Point me to...", not on fast travel | q24_01_point, q25_01_ft | Major | Add "Grave Row (the gathering)" as a goal entry |
| 6 | Rooms in the castle, Lab and Gallery are "???" until you clear the room next to them, so there is no route to plan | q4_12_e, q28_02_map, q30_06_map | Major | Show the room type one step further ahead |
| 7 | Phase 3 hint says he "runs out of time" at 1 HP a turn from 50 HP | q21 and q22 play logs | Minor | Say what the drain is for, or raise it as turns pass |
| 8 | The cracked mirror and the castle steps are flat stand-ins | q30_03_left, q2_05_north2 | Minor | Use a painted mirror sprite like the portraits beside it |
| 9 | The hero snags on the wall corner left of the castle steps while the goal arrow points up the steps; the "castle door" is the bottom step | q2_05_north2 to q2_11_e | Minor | Widen the door trigger or smooth the corner |
| 10 | Reward screen says "Added to your collection: Curb Alert" before you press Take, and a level-21 castle fight offers three Commons | q10_n4_a | Minor | Change to "Take to add..." and offer one Uncommon or better |

## 6. Smaller notes

- **SCRIPT ERRORs: none** in any of the 34 game logs. The only ERROR lines are Godot's "resources still in use at exit" and leaked-RID
  messages when the driver closes the game.
- A Tidy-Bot knocks you flat for 2 HP on the Gate Road with no warning I could see, in a zone that says "no healing after battles"
  (q1_08_e).
- The gate scene says "E / Click to close" on every line, where other dialogue says "continue" until the last line (q4_08_e).
- The defeat banner appeared while my HP still read 2 (q17_99).
- With about a dozen enemy cards on the table they overlap into an unreadable row (q19_99).
- A 10-11 card hand clips names and stat boxes ("POWERHOUS", "6/") (q6_03_after_unit).
- The city is "The Capital" on the map and "Pathordia" on the Rift Express and the speaker.
- The "Point me to..." list covers the map labels behind it (q24_01_point).
- No mulligan prompt appeared in any Primm fight; it did in the Courtyard and the Lab.
- The defeat tip "spend your energy every turn: cheap units first" does not fit a hand with no cheap units.
- The `c13castle` snapshot loads into the Town scene, not the castle.
- A stray label "vwxyz 012345" appeared in the label dump at the top-left of the HUD after the respawn (q19 play log); I cannot see it in
  q19_99c, so it may be hidden.
- Old Hob's line on respawn ("Not on my list. Off you pop.") is a nice touch after a loss.

## 7. What worked

1. **The dungeon maps.** Primm's Castle, the Lab and the Gallery are the best-looking screens in the game (q4_12_e, q28_02_map,
   q30_06_map).
2. **Primm's writing.** Polite, fussy and sad; the three between-phase exchanges give the fight an arc even when you lose.
3. **Rule explanations.** The boss tooltip, the "Before the fight" list, the per-card "In this fight" breakdown and the "What beat you"
   recap.
4. **The freed Capital.** Bunting, the fallen statue, the changed announcement and defacing the portrait for 12 gold.
5. **Safety prompts.** "Skip this scene? You haven't seen it yet." and "End your turn? You have 1 energy left and can still play 2
   cards."

---

## What was done about it (main session, Nov 12, after the report)

Against the brief's target (clarity 7, fun 6, polish 7) the critic gave **6 / 4 / 6**: the target was missed on all three. No second
critic was run after the fixes below, so there is no re-score.

| # | Done? | What |
|---|---|---|
| 1 | Not changed (owner's decision: no Primm tuning). Partly a driver fault, see #3 | With the driver fixed, the built-in player beat phase 2 at level 20 on its one try (no stalls) and lost phase 3 three times out of three (turns 6, 7, 7; no stalls). Phase 3 against the simple built-in player is still a loss; a human was not tested |
| 2 | Not changed | A design decision for the owner (inbox, Fable Nov 12) |
| 3 | Fixed, in the driver | Not an input stall in the game. In a ten-card hand the centre of a card lies under its neighbour; the pilot clicked the centre, nothing happened, and the play driver passed the turn after 30 tries - so the critic's player skipped 2-6 turns a fight. `tools/battle_pilot.gd` now clicks the card's uncovered left strip on the second try |
| 4 | Fixed | The line widened the whole turn panel off the screen. It is now set smaller when it carries the countdown and can no longer widen the panel (`BattleHud._fit_turn_sub`) |
| 5 | Fixed | "Old Hob at Grave Row (the city is gathering)" is on the map and in "Point me to..." while the funeral waits |
| 6 | Not changed | Room fog is a design rule; logged for the owner |
| 7 | Fixed | "...but he loses 1 HP every turn: every turn you hold the line wears him down." |
| 8 | Not changed | Needs painting: Batch 15 (`docs/art/batch15_nov12.csv`) |
| 9 | Not changed | Not reproduced in this pass |
| 10 | Half | The line now reads "Take it and <card> goes to your collection (find it at the Deck Station)."; the reward rarity was not changed |

The smaller notes were not worked through.
