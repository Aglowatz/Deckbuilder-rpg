# Critic 1 re-check: combat and deckbuilding (Nov 17)

## 1. How I played

I used all 8 runs, in about 45 minutes. Scripts are `docs/review/play_scripts/n17rcombat_01..08.txt` and shots are `_screenshots/exported/n17rcombat_*`.

- **Run 1:** `dev load bot_refusemancer_enter_refusemancer`. I walked about 12 s around Compost Commons and met no roaming enemy (`n17rcombat_01_e`; scene log says HeapZone, 17/17 HP throughout). I got no early-game fight.
- **Run 2:** `dev load bot_refusemancer_enter_gourmand` (level 14, 25 HP, 1099 gold), then `dev travel dungeon D-TTK`, which opens the Test Kitchen room map (`n17rcombat_02_b_ttk`). `dev save` on the dungeon map came back as the Buffet overworld when loaded in run 3, so that run was wasted.
- **Run 4:** clicking the first room opens a "Before the fight" rules card that needs Continue (`n17rcombat_04_a_enter`). The pilot found no battle behind it, so that run was wasted too.
- **Run 5:** the first room (Prep Station Sous-Chef). The pilot played the whole fight: 7 turns, 73 s at 1x speed. I went from 25 to 16 HP and got the victory screens (`n17rcombat_05_*`).
- **Run 6:** I played by hand, but the Escape I sent after a right-click opened the pause menu, and the rest of the run was lost behind it (`n17rcombat_06_*`). I did get a right-click preview out of it.
- **Run 7:** the same room. I played turns 1-2 by hand (clicked cards, To Combat, End Turn), then the pilot played turns 3-6 for 40 s. At the end of that run the fight was still going at 24 vs 9 HP (`n17rcombat_07_*`).
- **Run 8:** the same room at 1.5x speed. The pilot played the whole fight: 10 turns, 78 s, 25 to 14 HP. I shot every reward screen (`n17rcombat_08_*`).

**What I did not reach:** early-game roamers, Deck Station, packs, Sable's shop, the Buffet roamers, any Test Kitchen room after the first, the Test Kitchen boss, and the Beefcake Path. Only 2 turns were mine. Every finding below comes from one room of the mid-game dungeon, so treat it as a narrow sample.

## 2. Score: 4/10 (Clarity 5, Fun 4, Polish 6)

- **Clarity 5/10:** Some things explain themselves well:
  - the pre-fight rules card names every rule with an icon (`n17rcombat_04_a_enter`);
  - the turn panel says what the phase is for;
  - the opening-hand box counts infrastructure against other cards (`n17rcombat_05_a_start`).

  Playing a card by click is unreliable, though. My clicks mostly enlarged a card instead of playing it. The "One Infrastructure per turn" toast was still on screen 13 s later at the start of turn 2, before I had clicked anything (play log 58.8 and 71.6). A right-click preview showed the same card three times while a tutorial tip with a pointer line sat across it (`n17rcombat_06_t1_rclick`). **Lower than the anchor (6)** because of that click-to-play doubt and the stacked overlays, which the anchor shots do not show.
- **Fun 4/10:** A first dungeon room takes 7 to 10 turns. The enemy has 12 HP, and nothing happens on turns 1-2 except one infrastructure each (`n17rcombat_07_t1b`, `n17rcombat_07_t2b`). Each room costs about 9-11 of my 25 HP and nothing heals between rooms ("Zone HP: no healing after battles"), so the dungeon plays as an attrition grind. The reward is 30 gold and 45 XP with no card choice (`n17rcombat_08_d_reward2`), so winning changes nothing about my deck. **Same as the anchor (4):** the anchor's turn-2 shot is the same near-empty board at the same pace.
- **Polish 6/10:** The board art, card frames and kitchen table are handsome, and the VICTORY banner is clean (`n17rcombat_08_b_end`). On the other hand:
  - a card preview stayed over the VICTORY banner, though the pilot was driving the mouse (`n17rcombat_05_c_end`);
  - one win takes three separate "Victory!" moments to click through;
  - tooltips overlap each other.

  **Same as the anchor (6).**

## 3. Top 10 problems

| # | Problem | Where | Severity | One concrete fix |
|---|---|---|---|---|
| 1 | A normal fight's reward is only gold and XP, with no card or choice. Winning never changes the deck, which is the core reason fun stays low. | `n17rcombat_08_d_reward2` (+30 gold, +45 XP, Continue) | major | After every dungeon fight, offer "pick 1 of 3 cards (or skip for gold)" from the zone's Path pool, Slay-the-Spire style. |
| 2 | A first-room fight runs 7-10 turns and over a minute even with the pilot at 1.5x, against a 12 HP foe. | play log run 5 (7 turns, 46.3 to 118.9 s); run 8 (10 turns, 47.9 to 126.1 s at 1.5x) | major | Cut normal-room enemy HP to 8, or let leftover combat damage carry over, so trash fights end in 4-5 turns. Keep the length for elites and bosses. |
| 3 | Dead opening turns: turns 1-2 are one infrastructure each and nothing on the board. | `n17rcombat_07_t1b`, `n17rcombat_07_t2b`; anchor `n17combat_10_t4a` | major | Start each fight with 2 infrastructure already in play (or 2 energy on turn 1) so a 2-cost unit can come down at once. |
| 4 | HP drain without healing: one first-room win cost 9-11 of 25 HP, and the zone says "no healing after battles". | `n17rcombat_05_c_end` (16 HP), `n17rcombat_08_b_end` (14 HP); `n17rcombat_01_a_entrance` | major | Heal 30 % of max HP after each dungeon fight, or add a rest room on every route of the map. |
| 5 | Clicking a hand card usually enlarged it instead of playing it. My turn-2 clicks played nothing affordable, and it was unclear why. | `n17rcombat_07_t2b` (enlarged Wasteworks; Acid Vomitor never played) | major | One click plays an affordable card. Show unaffordable cards greyed out with the missing energy colour printed on them before the click. |
| 6 | The "One Infrastructure per turn" toast stays on screen into the next turn, before any action. | play log run 7, 58.8 s (turn 1) and 71.6 s (turn 2, before clicks); `n17rcombat_07_t2a` | minor | Clear all battle toasts when the turn changes, and give them a 3 s lifetime. |
| 7 | The Refusemancer story deck holds off-Path cards: Powerhouse (Beefcake infrastructure), The Carpool, and The Big Unit (Beefcake legendary). Drawing one leaves me unable to pay for my own colour. | `n17rcombat_06_t1_rclick` ("Not enough energy"), `n17rcombat_07_t2b` dump (Powerhouse: Beefcake) | major | Have the Deck Station flag any card whose colour has no matching infrastructure in the deck. |
| 8 | The right-click preview shows the card three times (big copy left, lifted copy, text panel), and the first-fight tip box and its pointer line cross it. | `n17rcombat_06_t1_rclick` | minor | Right-click shows one large card plus its keyword panel. Hold tutorial tips until no preview is open. |
| 9 | Three "Victory!" moments for one win: the banner, then "defeated in N turns" with Continue, then a second "Victory!" box with gold and Continue. | `n17rcombat_08_b_end`, `n17rcombat_05_d_reward2`, `n17rcombat_08_d_reward2` | minor | Merge them into one results box (turns, gold, XP, card pick) with a single Continue. |
| 10 | A card preview stayed over the VICTORY banner when the fight ended (the pilot was driving the mouse). | `n17rcombat_05_c_end` | minor | Close every hover preview and the hand when the victory banner starts. |

## 4. Three things that work and must not be lost

1. The pre-fight rules card names the foe, shows each rule with its icon, and keeps those icons on screen during the fight (`n17rcombat_04_a_enter`).
2. The opening-hand summary ("3 infrastructure, 3 other cards") with a free mulligan is an honest, quick decision (`n17rcombat_05_a_start`).
3. The Test Kitchen's painted room map is a lovely, readable branching route (`n17rcombat_02_b_ttk`).

## 5. SCRIPT ERROR lines

None. All eight game logs (`_screenshots/exported/play_n17rcombat_01.log` to `08.log`) have 0 `SCRIPT ERROR` lines.

## The six questions

- **Decisions:** I had 1-2 real options a turn. On turns 1-2 the only choice was which infrastructure to play (`n17rcombat_07_t1b`). By turn 6 there were a few units and an Exhaust ability to weigh (`n17rcombat_07_end`: Poo-uid, Acid Vomitor, Mulch Mole). The right play was usually obvious: play the land, play what you can afford.
- **Pace:** 7 turns / 73 s at 1x and 10 turns / 78 s at 1.5x, with the pilot. A person reading cards would take 2-3 minutes for a trash fight. The fights are too long for the reward, and the first two turns are dead.
- **The enemy:** readable. A banner names each enemy play ("Prep Station Sous-Chef plays Kitchen Porter", "blocks with 3 units"; run 7 and run 8 dumps), and new units arrive asleep ("Zz"). It never surprised me in the turns I saw. It builds Wonders (Recipe Engine, Herb Garden) and a Chef de Golem engine, which is slow, not clever.
- **Cards:**
  - **Best:** Poo-uid (Epic; Exhaust, eat garbage: make a 3/3 token; `n17rcombat_07_end`), Acid Vomitor (2 damage to a unit, a real removal choice), and the enemy's Chef de Golem (a clear engine card; run 8 dump).
  - **Deadest:** The Big Unit (needs 5 units with 5 different attack values; "Not enough energy"; `n17rcombat_06_t1_rclick`), Powerhouse in a Refusemancer deck (wrong colour), and Mulch Mole (a 0/3 that only adds energy, still asleep on turn 10; `n17rcombat_08_b_end`).
- **Rewards and deckbuilding:** no card came from the fights I saw, so nothing made me rebuild. I did not reach the Deck Station this sitting.
- **The one change:** a pick-1-of-3 card reward after every dungeon fight. Every win would then become a deckbuilding decision.
