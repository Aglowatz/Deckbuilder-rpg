# Critic 6 - the new card games (Nov 17)

## 1. How I played

- **14 of 14 runs used** (all 170 s or less, one at a time, in the foreground). Every run started from `dev load bot_refusemancer_capital_ready` plus `dev travel zone <id>`. Scripts: `docs/review/play_scripts/n17_cardgames_01.txt` to `_14.txt`.
- Runs 1-8: the Gainlands. I walked to Chet Thunderabs, sat through his talk twice and played **Reps** three times: once fully on the **controller** (run 07, a loss), once with the mouse (run 08), plus the How to play screen (run 06). Run 05 was wasted: `dev save` in a zone brings you back at the zone entrance, not where you saved (`n17cardgames_05_b04`). Run 08 tried `dev win` to see Reps' win screen. It printed `dev: no battle`.
- Run 09 scouted the Buffet, Dump and D.N.A. maps and their "Point me to..." lists.
- Runs 10-13: the D.N.A. I tried four routes from the entrance to the **Mail Room Filing Terminal** and never got there. Each time the hero stopped against the lobby's north wall (`n17cardgames_10_map`, `_11_map`, `_12_map`, `_13_mapB`).
- Run 14: the Verdant Dump. I walked north towards the minigame host and stopped at a fence and gate below his ledge (`n17cardgames_14_mapB`, `_14_view`).
- **Not reached:** Order Up, Sort It Out, File in Order, every card quiz, and Reps' win screen. I never found any of the four quiz teachers (Professor Pump, Professor Pate, Druid Thistlewick, Director Ectomund) or Chef Flambe on any map, any "Point me to..." list or on screen (`n17cardgames_01_pointlist`, `_09_gourmand_list`, `_09_refusemancer_list`, `_09_necrocrat_list`).
- **Reps' win:** my script cannot see a card and then decide. A miss resets the streak to 0, so 8 in a row by blind guessing is close to impossible. My best streak was 4 (run 08 log, 67.3 s: "Power 5: right! That is rep 4.", then 69.6 s: "Power 3: a miss ... Rep 0 / 8").

## 2. Scores

**Score: 3/10** (for the card games as a player finds them today). Three of the four games, and every quiz, could not be reached in 80 minutes. The one I could play, Reps, is a well-dressed higher-or-lower game.

- **Clarity 3/10.** Reps' How to play screen is good: three numbered rules and an animated example (`n17cardgames_06_open2`). But no quiz teacher and no card-game host is listed under "Point me to...", and two hosts I could see on the map could not be walked to.
- **Fun 4/10.** Reps is pure guessing with a short sidebar of hints ("Powers here run from 1 to 6"). With a miss resetting the streak, one bad guess wipes out a good run, and nothing you do between guesses matters. Against Gwent or Sea of Stars' Wheels it is a coin flip with jokes.
- **Polish 4/10.** The host portrait, the card art and the studio backdrop look finished (`n17cardgames_07_mid`). The barbell the hero stands under is flat grey blocks with no plates on it, and the controller focus box shows through the How to play pop-up (`n17cardgames_07_result`).

## 3. Top 10 problems

| # | Problem | Where | Severity | One concrete fix |
|---|---|---|---|---|
| 1 | None of the four quiz teachers appears anywhere: not on the map, not in "Point me to...", not on screen in the Gainlands, Buffet, Dump or D.N.A. | `n17cardgames_01_pointlist`, `_09_gourmand_list`, `_09_refusemancer_list`, `_09_necrocrat_list` | **blocker** | Add a map icon and a "Point me to..." entry for each teacher, like the "Quest giver" entries already there. |
| 2 | The card-game hosts are never listed in "Point me to...". Chet, Dex Shufflewick and the Mail Room Filing Terminal show on the map but not in the list, and Chef Flambe is on neither | `n17cardgames_01_pointlist` (no Chet), `_09_refusemancer_list` (no Dex), `_09_necrocrat_list` (no terminal), `_09_gourmand_list` (no Flambe, no minigame icon) | **blocker** | List every Minigame and Puzzle map marker in "Point me to..." with the game's name ("Chet Thunderabs - Reps (Minigame)"). |
| 3 | The D.N.A. Mail Room Filing Terminal could not be walked to: four routes all stopped at the lobby's north wall | `n17cardgames_11_map`, `_12_map`, `_13_mapB` | **blocker** | Open a doorway in the lobby's north wall facing the terminal, or have the guide line from problem 2 route there. |
| 4 | Dex Shufflewick's ledge in the Dump could not be reached from the entrance: the hero stopped at a fence and gate below it | `n17cardgames_14_mapB`, `_14_view` | **major** | Put a visible open path or bridge from the farm terrace up to Dex's ledge, and mark the gate as passable. |
| 5 | Controller input reaches the game behind the How to play pop-up. With the pop-up open, `pad a` made a guess (Misses went to 1/3), and the focus frame on "Higher" is drawn on top of the pop-up | run 07 log, 98.5 s: "Power 1: a miss" while "How to play" and the "Back" button were on screen; `n17cardgames_07_after`, `_07_result` | **major** | While How to play is open, block input to the game under it and move pad focus to its Back/Play button. |
| 6 | On the Reps result screen, pad up + `pad a` opened the "?" help instead of reaching Play again / Leave. Focus jumps to the title-bar "?" button | run 07 log, 87.7-90.7 s ("Set failed", then the How to play dump) | **major** | Put first focus on "Play again" on the result screen, and leave the "?" button out of D-pad navigation there. |
| 7 | Reps is too swingy. The "8 right in a row" plus "3 misses allowed" wording reads as if misses only cost a life, but every miss also resets the streak to 0. That is how a 4-rep streak became Rep 0 | run 08 log, 67.3 s and 69.6 s; rules in `n17cardgames_06_open2` | **major** | Let a miss cost a life but keep the streak (8 right in total), or say on the rule card: "A miss also drops your reps to 0". |
| 8 | Reps "power" means the unit's attack, but every card also shows a mana number in its top corner. Mercenary Captain shows 4 there and is "Power 2" | `n17cardgames_07_mid` | **minor** | Dim the mana cost on cards inside Reps, or circle the attack number and label it "Power". |
| 9 | The barbell prop is flat grey placeholder blocks with no plates, so "the plates come off the bar" shows nothing | `n17cardgames_07_mid`, `_06_open2` (left) | **minor** | Swap in a painted barbell with plates and drop one plate on each miss. |
| 10 | Getting into Reps takes about 9 dialogue boxes the first time ("talk again" once), and the host's lines repeat on every visit | run 04 log 48.3-73.5 s; "Chet Thunderabs is ready when you are. Talk again." | **minor** | Open the game straight after the first talk, and give returning players a one-line greeting with a "Play Reps" choice. |

## 4. Three things that work and must not be lost

- The How to play card for Reps: three short numbered rules and a worked example ("6 > 1: right!") that animates before you play (`n17cardgames_06_open2`).
- The studio presentation: Chet's portrait, a reaction line on every guess ("And TWO!", "Feel the burn!", "Squeeze it!") and real card art for every draw (`n17cardgames_07_mid`).
- Clear status pills at the top (Rep 0/8, Misses 1/3, "Powers here run from 1 to 6") and a result line on every guess ("Power 2: a miss. The plates come off the bar.") (`n17cardgames_07_mid`).

## 5. SCRIPT ERROR lines

None. `grep -c "SCRIPT ERROR"` printed 0 for all 14 game logs (`_screenshots/exported/play_n17cardgames_01.log` to `_14.log`). At exit there are only engine shutdown leak lines (for example run 05: "23 RID allocations ... were leaked at exit").

## One line per game

- **Reps (Chet Thunderabs): 4/10.** Better: keep the streak after a miss (8 right in total, 3 misses allowed), so a good run is not wiped out by one guess.
- **Order Up (Chef Flambe): not rated.** Chef Flambe is not on the Buffet map or its list (`n17cardgames_09_gourmand_list`). Put him on the map and in "Point me to...".
- **Sort It Out (host): not rated.** The Dump's minigame marker is named "Dex Shufflewick", not Recycle Rhonda, and I could not reach his ledge (`n17cardgames_14_mapB`). Give him a walkable path.
- **File in Order (Mail Room Filing Terminal): not rated.** The terminal is on the map as a Puzzle but not in the list, and I could not reach it from the lobby (`n17cardgames_13_mapB`).
- **Card quizzes (all four): not rated.** I never found a teacher.

## Rewards

- Reps paid nothing on a loss: "Set failed ☆☆☆ ... No reward this time. Try again whenever you like." (run 07 log, 87.7 s). Chet promises "rewards for performance, plus a one-time bonus on your very first set" (run 04 log, 65.6 s), but I never saw a win screen, so I cannot say what it pays.
- Worth playing again? Not as it stands. Reps is three to five minutes of guessing, and I never saw what a win pays.

## Controller (Reps only; I reached no quiz)

- **Rule pop-up:** `pad a` pressed Play (run 07, 56.4 s). That worked.
- **Game screen:** D-pad up + `pad a` chose Higher on every guess. That worked.
- **Result screen:** pad up moved focus to the "?" help button, and `pad a` opened How to play instead of Play again. That failed (problem 6).
- **Help pop-up:** the game behind it still took pad presses, and its focus frame showed through. That failed (problem 5).
- **There are no on-screen pad prompts.** With the controller in use the buttons read "▲ Higher" and "▼ Lower". With the mouse they read "▲ Higher (Up)" and "▼ Lower (Down)", keyboard hints only (run 06 log, 56.6 s, against run 07 log, 58.5 s).
