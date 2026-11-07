# Critic CF: a fresh first hour (Gourmand)

## 1. Summary

The Wayward Path makes a strong first impression. The title, the painted wake-up still, the portraits and the battle boards are lovely, and the route from waking up to the gatekeeper is short and clearly signposted. I reached **Chef Fennel Gravois, the Gourmand gatekeeper, and fought him**, lost the first duel, and won the rematch. The first hour is held back by three things. First, the combat UI fights the player: a Peek popup draws *behind* the units on the board, error messages stick around, the fanned hand hides card text, and the card counts are cramped. Second, the cave's difficulty runs backwards: its second fight is the dangerous one (I lost it once and finished it once on 4/15 HP), while the "boss" has 3 HP and folds in 4 rounds. Third, the shop and reward systems quietly don't do what the player thinks. Cards bought from Sable go to the collection, not the deck. A reward card I "took" was turned into essence that never appeared on the Character page. Two card packs sat unopened and nothing told me. The writing is warm and often funny, and the defeat recap ("What beat you") is excellent.

**How I played**
- 31 scripted runs, all from `C:\Dev\wp_critic`, one game process at a time. Path: **Gourmand**.
- **Time.** The runs themselves added up to about 95-100 minutes of wall clock. A lot of that was overhead, not play. Snapshots can't save a dungeon in progress, so every cave attempt replayed from the cave mouth, and several runs were spent learning the UI or recovering from a blind script getting stuck on a popup. On an equivalent continuous first-time timeline (one opening, the real losses replayed once each), it comes to about 40 minutes: about 3 min opening and Path choice; about 18 min in the cave including one loss in fight 1 and one loss in fight 2; about 2 min with Maren; about 4 min in town and at the shop; about 2 min finding Fennel; then Fennel lost at about minute 33 and won at about minute 40.
- **Fights.** I played the first two cave duels myself with clicks: infrastructure first, then units, Select All Attackers, End Turn. Because the driver can't react mid-turn, those were scripted sequences of clicks rather than thought-through plays. I lost duel 1 outright. Stuck on the hidden Peek popup, I then handed the rest of that duel and later fights to `pilot`. The cave boss and both Fennel fights were `pilot`. That is a caveat on my difficulty score: a human who reads the board will do better than my click macros, and probably about as well as the pilot.
- **Gold.** Left the cave with 560 gold (120 start + 40 + 40 + 200 boss + 2 × 60 from level-ups). At **Sable's Card Stall** (560 gold) I bought Food Critic ×2 and Gourmand Cooking Academy ×1 at 100 each, leaving 260. Every card on the stall was 100. I could afford five cards but stopped at three to keep money for later. I didn't visit Tilly or Pip. After beating Fennel: 460 gold.
- **`dev` commands.** Only `dev newgame`, plus `dev save` / `dev load` to chain runs. I never used `dev travel`: I found the cave arch on foot.

## 2. Scores

| | Score | Why |
|---|---|---|
| Fun | 6/10 | A good loop and a satisfying gatekeeper win, but the cave's swingy second fight and the fiddly board make the first half hour feel like work. |
| Clarity | 5/10 | Wayfinding and quest text are good. The battle UI isn't: a hidden Peek popup, stale "Needs 1 energy" text, a crowded hand, and silent collection-vs-deck routing for bought cards. |
| Difficulty | 5/10 | Badly ordered rather than too hard or too easy. Fight 2 of the tutorial cave can kill you, the boss has 3 HP, and the gatekeeper beat the pilot once and lost to it once. |
| Text | 8/10 | Maren, Sable and Fennel have distinct voices and real jokes ("The pantry key is shaped like a ladle. Don't ask why. The answer is soup."). Several key lines get cut off with "..." in the dialogue dump. |
| Look | 8/10 | Gorgeous key art, portraits, cave map and Buffet board. The town is a bit blurry and soft, and some props hide NPCs (Fennel behind the trees). |

## 3. Findings

1. **The Peek popup draws behind the board units, so the duel locks up.** When Amuse-Bouche resolves (Create an Ingredient, Peek 1), the "Peek 1 / Keep it on top, or send it to the bottom" modal is drawn under the enemy and player cards on the table. Its Top / Bottom / Done buttons are covered, and the turn can't continue until it's answered. My first manual duel stalled here for two turns until I handed it to the pilot. Where: `cf_r10_n6a.png`. **Severity: blocker** (for a mouse player who can't find the hidden buttons). **Fix:** put the Peek/choice modal on a top CanvasLayer above the board, dim the board behind it, and put the buttons in the modal's own footer.

2. **Cards bought in the shop don't go into the deck, and nothing says so.** I paid 300 gold for three Gourmand cards before the gatekeeper. The Deck Station afterwards shows "Gourmand Cooking Academy — Deck 0/3 Own 1". The cards sat in the collection, so the purchase did nothing for the Fennel fight. Sable's line about this ("Buy a few, then put t...") is truncated in the box I read, and the buy dialog only says "100 gold for one copy. You own 0…". Where: `cf_r23_b01_buy.png`, `cf_r31_u01_deck.png`. **Severity: major.** **Fix:** for the first purchases, add the card to the active deck automatically when there's room, or add a "Add to deck now?" toggle in the buy dialog. Then show a toast: "Food Critic added to your collection. Open the Deck Station (B) to put it in your deck."

3. **The tutorial cave's difficulty runs backwards.**
   - Fight 1 (Cave Scavenger, 3 HP) flooded the board with five units by round 4. My first attempt lost it.
   - Fight 2 (Hollow Stalker, 7 HP) was the real threat: one run ended at 4/15 HP and another run lost it, which sends you back to the forest to restart the cave ("You come round in the forest clearing at full HP. The cave starts over").
   - The boss (Hollow Warden) has **3 HP** and died in 4 rounds.
   A first-time player can lose twice before the boss, then find the boss trivial. Where: `cf_r9_m_after.png` (defeat in fight 1), `cf_r13_w07.png` (4/15 HP at the shrine after fight 2), `cf_r15_x02_boss.png`. **Severity: major.** **Fix:** ramp it as 3 HP → 5 HP → boss 8-10 HP, give fight 2 a smaller enemy deck or no flyers, and put the shrine before fight 2 or make the Well heal more.

4. **A reward card I took was turned into essence I never got.** After the first cave fight I picked Soup Kitchen Volunteer. The screen said "Soup Kitchen Volunteer joins your deck", then a toast said "Extra copy of Soup Kitchen Volunteer converted into 2 Gourmand essence." The Character page later shows Path Essence 0 / 0 / 0 / 0. So either the toast is wrong or the essence vanished, and either way the reward screen lied about the card joining the deck. Where: the quoted toast in run cf_r11; `cf_r31_u02_char.png`. **Severity: major.** **Fix:** when a pick would go over the copy cap, mark it on the reward card *before* the choice ("At cap: becomes 2 essence") and make the essence show up on the Character page.

5. **The combat board is crowded and its feedback is stale.**
   - "Needs 1 energy; you have 0 (each ready Infrastructure gives 1 a turn)." stayed on screen across the enemy turn and into the next round (`cf_r8_t04.png`, still there in `cf_r8_t08.png`).
   - The hover preview of a hand card sits on top of the unit row.
   - The "Attack!" tip box covers the enemy's units (`cf_r8_t08.png`).
   - With 9 cards in hand the fan hides each card's cost and text (`cf_r13_q4b.png`).
   - Costs are tiny coin pips in the card corner.
   - It also wasn't clear why my first Line Cook was free but the second "needs 1 energy" on round 1.
   **Severity: major.** **Fix:** clear error toasts after about 2 s or at the next phase change; anchor tips away from the board's unit rows; draw the cost as a large numeral; let the hand shrink or scroll instead of overlapping past about 7 cards; explain "an Infrastructure gives energy the turn after it's played" in the first infra tip.

6. **The gatekeeper is hidden behind trees, and so is the player.** Fennel stands in a pocket between two orchard trees and crates by the pantry door. Walking up from the south, both the player and Fennel disappear behind the foliage, and no talk prompt appears. One approach got stuck on the crates with no prompt at all. The prompt shows up only on one narrow line. Where: `cf_r25b_g02.png` (Fennel's name tag over the trees, neither character visible), `cf_r26_h01.png` (when it works, his name tag is printed over his own speech bubble). **Severity: major** (it's the main goal of the hour). **Fix:** move Fennel out onto the open path in front of the door, remove or fade the two trees and crates in the camera's line of sight, widen his interact radius, and keep the name tag from overlapping his bark bubble.

7. **The cave entrance prompt only shows on a tiny spot.** Standing inside the golden ring at the ruined arch gave no prompt, and pressing E did nothing (`cf_r4_f07.png`). The "[E] Enter the cave" prompt appeared for a moment one step further in, and vanished again if I kept walking. **Severity: minor-major** (it's the very first interaction in the game). **Fix:** make the whole ring the trigger, or enter automatically when the player walks into the arch.

8. **The Path choice screen's cards are unreadable.** The three sample cards per Path are thumbnails whose text can't be read (`cf_r3_p03_more.png`). "More" adds a dense list of card names. Also, Esc didn't close the More panel. **Severity: minor.** **Fix:** zoom a card on hover, show the Path's resource icon and one sample card at full size, and let Esc collapse More.

9. **Unopened packs and other freebies go unannounced.** After the cave the Character page shows "Gourmand Pack x2 — Open" that nothing ever pointed me to (`cf_r31_u02_char.png`). The "Some Assembly Required" equipment hint overflows its pill box ("...(from Elder Maren)" runs outside it). **Severity: minor.** **Fix:** show a "You have 2 unopened packs (P)" badge on the HUD Menu button, and widen the pill or wrap its text.

10. **The quest log lists the other Paths' gatekeepers as Main quests.** As a Gourmand, my Main tab has Raise the Bar, Take a Number, Key Ingredients, Root Cause and Fragments, all 0/4, and the arrival banner announced "NEW QUEST Raise the Bar — Out-muscle Brick Bronson at the gorge / +4 more". That's noise right when the player should be focused on Fennel. Where: `cf_r19_t03_quests.png`. **Severity: minor.** **Fix:** put other Paths' gatekeepers under a collapsed "Other Paths" group, and don't pop banners for them on arrival.

11. **The cave boss's "Hidden trait" text is meaningless.** The before-fight card says: "Hidden trait ?: Something happens in this fight you haven't seen yet." It tells the player nothing they can act on. **Severity: minor.** **Fix:** give a hint ("When it's low, it calls for help") or drop the panel for the tutorial boss.

12. **Small UI polish.**
    - J (the quest log) does nothing in the opening forest.
    - The minimap in the forest is a pale blob shaped like a rabbit (`cf_r1_12.png`).
    - The shrine's HP bar draws a green block over the red fill (`cf_r13_w07.png`).
    - The cave boss's dialogue box overlaps the node tooltip "Unknown. Step on it..." (`cf_r15_x02_boss.png`).
    - Dialogue lines longer than two lines get cut off with "..." in the dump, so check they fit the box.
    **Severity: minor.**

There were no `SCRIPT ERROR`s in any run's `stdout.log`. The only errors were engine shutdown leak warnings (RID / resources still in use at exit).

## 4. What's great, don't touch

- **The opening:** the painted wake-up still, the masked Rescuer, and a two-minute run from waking to a meaningful Path choice. "I feel them. All four, faintly. Like voices through a wall." (`cf_r1_12.png`)
- **The cave map:** painted, readable nodes, with a clear tip that says exactly what carries over ("HP carries from fight to fight… Cards and gold you've won are kept") (`cf_r6_c04.png`). The Hollow Well's odds readout ("about 69 % to pass") is a great touch.
- **The defeat recap:** "What beat you: Cake Golem dealt 15 of the 18 damage you took… Block it with a unit you can afford to lose". This is the best clarity feature in the game (`cf_r28_f22_end.png`).
- **Maren's arrival scene and the tracked-quest HUD:** she tells you exactly where your Path's gatekeeper is, and the map marks "Your Path: Chef Fennel Gravois" (`cf_r18_xs_4.png`, `cf_r19_t02_map.png`). The road to the gatekeeper is about 10 seconds of walking from the square.
- **Sable's stall:** filters, Own x/3, flat pricing, a confirm dialog that tells you your gold after the purchase, and her voice ("Every card has a story, darling. Some of them even happened.") (`cf_r22b_sh02_hover.png`).
- **The battle boards and card art:** the Buffet tablecloth board for Fennel is gorgeous (`cf_r28_f21.png`). The phase ladder on the right with its one-line explanations ("Your main phase: Play an infrastructure, then units and spells") works.
- **The "End your turn? You can still play 1 card" safety prompt**, and the opening-hand Keep/Mulligan with its infrastructure count.
- **Fennel's writing:** "TASTE IT! The Special Sauce is in everything now", and after he's beaten, "Is that plain bread, with no sauce on it at all? I could weep. In fact, I am weeping."
