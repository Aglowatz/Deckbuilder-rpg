# Critic 1 - combat and deckbuilding (Nov 17)

## 1. How I played

13 of 14 runs used (about 75 minutes), each 170 s or shorter, one at a time. Screenshots and logs are in `_screenshots/exported/` under `n17combat_NN_*` and `play_n17combat_NN*.log`.

- **Runs 1-4, Verdant Dump (Refusemancer, level 5, `bot_refusemancer_enter_refusemancer`):** I walked from the entrance bridge looking for roaming enemies. I found none in four runs. The north gate past Compost Commons drops you into water ("You fall in! Someone fishes you out with a pitchfork", run 4, 47.3 s). **I got no roamer fight in the early game.** I count that as being stuck and moved on with dev jumps.
- **Runs 5-11, the Test Kitchen (Refusemancer, level 14, `bot_refusemancer_enter_gourmand`, then `dev travel dungeon D-TTK`):** I did not walk to the door. A `dev save` taken on the dungeon map reloads into the Buffet zone, not the dungeon, so every run had to re-enter the dungeon. Runs 6-7 were lost to that and to a modal I did not expect.
  - Fight 1, Frozen Line Cook: the pilot played it (run 8). It did not finish: turn 6, enemy at 8 of 12 HP.
  - Fight 2, the same room: **mine**, by hand (run 9). I got stuck on turn 1 behind the "End your turn?" confirm.
  - Fights 3-4, the boss (The Doppelganger): **mine**, by hand, from `D-TTK -2` (runs 10 and 11). Neither finished inside 170 s. Both reached turn 4: 25 vs 16 in run 10, 23 vs 15 in run 11.
- **Run 12, Beefcake (`bot_beefcake_enter_necrocrat`, level 8):** I sent this hero into the Test Kitchen's first room and let the pilot play it (fight 5). It won on turn 8.
- **Run 13, town Deck Station:** I looked at the deck and opened "Suggest a deck". Pressing Escape there closed only the Suggest pop-up, and `P` did nothing inside the Deck Station, so I never opened packs.

**My "by hand" fights were pre-written input.** I chose clicks, End Turn and blocks, then corrected the plan between runs from the screenshots, but I could not react within a turn.

**Not reached:**
- any roamer fight
- a finished dungeon
- a won or lost boss
- any reward screen (I captured only "VICTORY!", run 12, 141.4 s)
- level-ups, packs, Sable's shop, zone card vendors

I finished 1 of the 12 fights the brief asks for, and that one was played by the pilot. **Treat the scores as provisional.**

## 2. Scores

**Score: 4/10** (combat and deckbuilding lens)

- **Clarity 6/10.** The phase tracker with its live hint ("Your main phase / Play an infrastructure, then units and spells…", n17combat_09_t1b), the "Block! Click one of your units…" prompt (n17combat_11_t6b) and the pre-fight rules card are clear. But an overflowing hand with truncated names, and cards stacked over each other in combat, make the board hard to read at a glance (n17combat_10_end, n17combat_12_r1).
- **Fun 4/10.** Fights run long and start slow. The boss does nothing until turn 3 ("Setting Up - attacks start Turn 3"), then has 6 units out by turn 4 while I have 2 (n17combat_11_end2). A 45-card minimum with 19 basic infrastructure means a new card is 1 in 45 and rarely shows up (n17combat_13_deck3).
- **Polish 6/10.** The card art and table art are lovely and the attack banner reads well. But four modals come before your first real action, the intro speaker ("The Grand Chef") differs from the opponent's name ("The Doppelganger"), and blockers get hidden under attackers.

## 3. Top 10 problems

| # | Problem | Where | Severity | One concrete fix |
|---|---|---|---|---|
| 1 | Early-game roamer fights could not be found: four runs in the Verdant Dump with no enemy, and the obvious gate north drops you into water. | n17combat_03_e, n17combat_04_f; run 4 log 47.3 "You fall in!" | blocker (for this lens) | Put 2-3 roamers on the open terrace inside the first 20 m of the entrance, and mark them on the minimap in red. |
| 2 | The deck minimum is 45 cards, with 19 Wasteworks (basic infrastructure, 42 %), so new cards are diluted and draws flood. | n17combat_13_deck3 ("45 cards / at least 45", "Infrastructure 19") | major | Cut the minimum to 30 and set Fill Infrastructure to about 12, so one new card is about 3 % of the deck instead of 2 %, and it shows up every other fight. |
| 3 | Fights are long. A normal first-room fight took the pilot 8 turns and about 85 s (run 12, 56.4 s to 141.4 s "VICTORY!"). The same room with the Refusemancer deck was only at 8 of 12 enemy HP after 60 s of pilot (run 8). The boss was at 16 to 15 HP on turn 4 after about 110 s (run 11). | play_n17combat_12_play.log, n17combat_08_r1, n17combat_11_end2 | major | Lower room-enemy HP by about 30 %, or let infrastructure produce 2 energy from turn 3, so a room fight ends in 5-6 turns. |
| 4 | Boss pacing goes from no tension to a swarm. "Setting Up - attacks start Turn 3", then 6 enemy units (two Line Cooks, Hearth Kitchen, Meatloaf Mold and Golem, Sashimi Weenie) by turn 4 against my 2. | n17combat_10_t4a (label "Setting Up"), n17combat_11_end2 | major | Spend the setup turns showing what the boss will do next (an intent strip like Slay the Spire's), and cap the boss at 4 units on the board. |
| 5 | The hand overflows: 7-8 cards fan over each other, names are cut off, and the infrastructure row sits on top of the hand, so clicks land on the wrong card. | n17combat_10_t4a, n17combat_10_end, n17combat_11_t6b | major | Scale the hand down past 6 cards and move played infrastructure to a strip next to the deck pile, away from the hand. |
| 6 | In combat, cards stack over each other. Attackers cover my blockers (the Raccoon is hidden under the Sashimi Weenie), and the Beefcake board overlaps the enemy row. | n17combat_11_end2, n17combat_12_r1 | minor | Animate attackers forward to a separate lane above the blocker and keep both cards fully visible until damage resolves. |
| 7 | Four modals come before the first real action: the "Before the fight" rules, the Opening hand (Keep/Mulligan), the "Rules of this fight" tip, then the "End your turn?" confirm on turn 1. The confirm also catches players who press Space twice. | run 7 log 40.9; run 9 log 47.1 and 64.3; n17combat_09_t2a | minor | Merge the rules into the Opening hand panel, and only ask "End your turn?" when a playable card costs no more than the energy left. |
| 8 | The boss intro is voiced by "The Grand Chef", but the enemy portrait says "The Doppelganger". Players may think the wrong fight loaded. | n17combat_10_intro vs run 10 log 69.6 `[label @ 165,55] The Doppelganger` | minor | Name the reveal on screen, e.g. a line like "The Grand Chef… is not the Grand Chef" before the board opens. |
| 9 | Cards in the hand show a generic "Effect" tag instead of the keyword, so you must right-click every card to know what it does. | run 8 dump (`Effect` under Mercenary Captain, Raccoon, Archdruid) | minor | Print the first keyword or a 4-word summary in place of "Effect". |
| 10 | Path identity blurs. The mid-game Refusemancer deck holds Beefcake cards (The Big Unit, Powerhouse) and many Colorless units. In the Deck Station, Escape and P do not work as expected. | n17combat_10_t4a; run 13 log 53.8-56.8 (P did nothing, Deck Station still open) | minor | Show the Path mix on the deck panel ("72 % Refusemancer"). Make Escape close the Deck Station once no pop-up is open. |

## 4. Three things that work and must not be lost

- **The phase tracker with live hints** ("Your main phase…", "Second main phase…", "Block! Click one of your units…") teaches the turn without a tutorial wall. See n17combat_09_t1b and n17combat_11_t6b.
- **The pre-fight rules card.** Zone and Path modifiers ("Well Fed: Gourmand units on both sides get +1 defense", "Dress Code Violation: Refusemancer units get -1 attack") make each fight feel different before you play a card. See n17combat_07_b.
- **The Deck Station tools:** filters, copy caps, a mana-curve bar, Fill Infrastructure and Suggest a deck make building approachable. See n17combat_13_deck3.

## 5. SCRIPT ERROR lines

None. `grep -c "SCRIPT ERROR"` returns 0 for `play_n17combat_01.log` through `play_n17combat_13.log`.

## Answers

**Decisions.** In my turns the choice was mostly forced. Play the one infrastructure, then whichever one or two cards fit the energy. The hand was usually 6-8 cards with only 1-2 affordable (n17combat_10_t4a: turn 4, 2 infrastructure out, 7 cards in hand). The only real decision I met was blocking (n17combat_11_t6b), and it is a good one. Attacking is all-in by phase, and I saw no attacker choice. The right play looked obvious most turns.

**Pace.** Too slow. A normal room takes about 8 turns and 1.5 minutes even at pilot speed (run 12). A hand-played boss reached only turn 4 in about 110 s, with almost no damage dealt either way (n17combat_11_end2). The enemy's turn takes 4-6 s with "The opponent is thinking…" (n17combat_08_r1). The Speed button exists, but slow ramp and high HP are the bigger cause.

**The enemy.** Its actions are announced well: "Frozen Line Cook uses Pastry Artificer" (n17combat_08_r1), "The Doppelganger attacks with Sashimi Weenie and 2 more" (n17combat_11_end2), "Frozen Line Cook blocks with 3 units" (run 12). But nothing shows what it will do next turn, so you cannot plan around it. The boss's sudden flood surprised me in a bad way, not a good one.

**Cards.**
- Best from what I saw:
  - **Mercenary Captain**: three bodies for one card, and it flooded the board in run 8.
  - **Old Kingdom Automaton**: a 4/6 at common, far above the other commons.
  - **Bird of Paradump**: Flying, plus it turns garbage into energy of any Path, a real build-around (n17combat_11_t6b).
- Deadest:
  - **Village Militia**: a vanilla 2/2 with only flavour text.
  - **Courier Pigeon**: a 1/1 that peeks 1.
  - **Alarm-ish Clock**: pay 1 to attach, then a coin flip for +2/+0, too random to plan around.
  - (Deck Station dump, run 13; n17combat_12_r1.)

**Rewards and deckbuilding.** I never reached a reward screen, a card pick or a pack opening, so I cannot judge them. The Deck Station itself helps more than it hurts (Suggest a deck, Fill Infrastructure). The 45-card minimum means no single new card could make me rebuild.

**The one change.** Cut the deck minimum to 30 with about 12 infrastructure, and lower enemy HP to match. Fights would end in 5-6 turns, every new card would show up most fights, and picks would finally change how you play. That is the most likely reason fun has stayed at 6 or below.
