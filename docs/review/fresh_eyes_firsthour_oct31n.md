# Fresh eyes: the first hour of The Wayward Path (v0.5.0), Oct 31 / Nov 1

Screenshots are in `fresh_eyes_firsthour_oct31n/`, named `<run>_<shot>.png`.

## Summary

The Wayward Path looks good in stills and in menus. The title screen, the painted wake-up still, the dialogue portraits, the cave node map, the reward screens and the Deck Station would hold up next to Sea of Stars or Monster Train's menus. The card game underneath has real ideas: Red Tape shrinking blockers, Ingredients cooked into Golems, delayed "Processing" spells, a defeat screen that explains *what* beat you, and an "End your turn? You have 2 energy left" guard.

The first hour fights the player the whole way, though:

- **The town camera.** In Crosspath, roofs in the foreground cover most of the screen and often hide the hero completely.
- **Walking.** Moving is slow and fiddly, NPCs block you, and conversations re-open when you press E once too often.
- **The first duel.** It is a 3-HP enemy, but I lost it twice out of three tries (once per Path). Clicking a hand card does not reliably play it, and tip boxes sit on top of the cards and units they talk about.
- **Decks are too big.** You start with a 45-card deck, 19 of them basic Infrastructure, so your choices barely move the deck.
- **Writing slips** right in the opening lines.

The game keeps telling me it is charming; in play it mostly felt like work. Against the comparison set it is a promising 5/10 today. The presentation is 7 to 8 territory, and the moment-to-moment feel and onboarding are 3 to 4.

## How I played

- **Time.** About 51 minutes of wall clock (05:46 to 06:37), 23 driver runs (`c11_*`), each a fresh process. Every run starts at the title, and the first run spent about 3 minutes booting. Most later runs had roughly 40 to 60 s of load overhead before the script started.
- **Path 1: Necrocrat.** Title, then `dev newgame`. I read the whole opening, picked the Path (with More), and walked the forest to the cave arch (I found the "[E] Enter the cave" prompt on foot, run `c11_c2`).
  - When the cave walk from a snapshot failed twice (the snapshot restored me in a slightly different spot), I used `dev travel dungeon D-TUT`.
  - I played the first duel myself three times, with clicks, drags and attacker selection.
    - **Run 1:** I lost, with `pilot` taking over only at the end (`c11_i`).
    - **Run 2:** I won with 2 HP left after `pilot` finished the last turns (`c11_j`).
  - I took the Hollow Well event, the shrine, and the boss intro (Hollow Warden) with `dev autowin on`.
  - Then "Step outside", Elder Maren's arrival scene, quest log, map, first steps in Crosspath, and a look at the D.N.A. via `dev travel zone necrocrat`.
- **Path 2: Gourmand.** Fresh `dev newgame`, picked Gourmand with More, and played the first duel myself with click-to-play and select-all-attackers. **I lost again** (`c11_o`; `pilot` took the last turns and lost too).
  - I autowon to the cave boss, arrived in Crosspath, and used the map's "Where to?" to reach the square.
  - I tried for four runs to reach Sable's card shop on foot and only ever reached Bertram the gear merchant, who turned me away.
  - Then the Deck Station (B), Card Packs (P), and a look at the Endless Buffet via `dev travel zone gourmand`.
- **What I did not reach.** I never bought a card. I did not complete the first errand ("Meet the Merchants" stayed 0/4), and I fought no zone battle. The first hour's errands defeated me before the content did, and that is the main finding.

## Scores (1-10, against Slay the Spire, Inscryption, Monster Train, Sea of Stars, Octopath Traveler, Pokemon TCG Pocket)

| Area | Score | One line |
|---|---|---|
| First 5 minutes' hook | 6 | A beautiful title and wake-up still, and a fast route to a Path choice, but generic amnesia and typos in the first 20 lines |
| Clarity (what to do, cards, keywords, why I won/lost) | 4 | Tooltips and keyword panels exist, and the defeat recap is great; but click-to-play is unreliable, "Needs 3 energy; you have 0" stays on screen, tips cover the action, and the quest names "Sable" while the map says "Card Vendor" |
| Pacing and friction | 3 | Slow walking, NPCs body-block you, E re-opens talk loops, 3 to 4 confirm screens after every win, 10-turn duels against a 3-HP enemy |
| Combat depth and feel | 5 | Interesting resource hooks and good phase UI; the board is cramped, tokens and infra are tiny, and the AI swarms with 2/1s |
| Deck-building satisfaction | 4 | The Deck Station is slick, but a 45-card minimum with 19 basics and 1-3 copies owned means my picks are a drop in the bucket |
| Reward rhythm | 6 | Gold + XP + a 3-card pick after every fight, level-ups with cosmetics; but too many popups, and Card Packs is empty at the start |
| Exploration and world | 4 | The cave node map is lovely; the forest is murky and blocks you with "too dense" barks; town navigation is the worst part of the game |
| Story and humour landing | 5 | Some good gags ("Even in death, he files", the Elder's pie); typos, a flat boss intro, and Bertram is a straight Dwight Schrute lift |
| Visual cohesion and readability | 6 | Painted 2D (stills, portraits, cards) is excellent; the 3D world switches between murky green, orange-washed town and grey-box D.N.A.; small card text |
| UI/UX consistency | 4 | E advances some screens but not others (it throws errors on the cave-complete card); Esc opens the pause menu on top of modal screens; name plates truncate |
| Audio | n/a | I cannot judge from screenshots and logs; the logs showed no audio errors |
| Performance | 6 | No visible stutter in the timestamps; zone loads about 8 to 12 s; first boot about 3 min on this PC; engine leak warnings at every exit |
| Bugs | 4 | 20 `SCRIPT ERROR`s on one screen, an Esc/pause click-through into "Quit the game?", a talk loop, NPC blocking |
| **Overall** | **5** | Production values outrun the feel; fix the town camera, the first duel and the friction, and this jumps |

## Findings per area

### First 5 minutes

- **Good.**
  - The title screen (`c11_a1_01_title.png`) is gorgeous and sets a warm, whimsical tone. The four Path icons in the logo are a clever promise.
  - The wake-up still (`c11_a1_02_wake.png`) is painted to a high standard, and the rescuer's portrait (`c11_a1_13.png`) is strong. We reach the Path choice inside two minutes, which is a good pace.
- **Bad: generic writing.** It is amnesia, a hooded stranger, and "the path-ologists are hunting us", with no joke or image specific to this world until the Path screen.
- **Bad: typos in the very first conversation.**
  - "I can't imagine **its** much after what they put you through."
  - "She's gone, and **shes** leading them away. By the way **their** shouting I do not want to be caught by them."
  - Later, Elder Maren says "get **aquainted**".

  These are the first words a player reads, and they undercut the polish of the art.
- **The Path chooser is good (`c11_b_path_03_more.png`).** You get three sample cards per Path and a More panel with the resource, and it says "you can mix in other Paths later".
- **But the More text is a wall.** "Starting deck, 45 cards: 19 Necrocrat Infrastructure, 20 units, 5 spells, 1 trap" plus a 13-name card list in 12 px type, with the resource line truncated with "..." in the label data. A new player only needs one sentence and one example card.
- **Esc on the Path chooser opens the full pause menu on top of it** (`c11_b_path_04_after.png`). The "Quit the game?" dialog in that shot came from my next click landing on the pause menu's Quit Game button, which sits right where "Begin as Necrocrat" was. Esc should close More, or do nothing.

### Clarity

- **Click-to-play is unreliable.** The tutorial tip says "Click a unit to put it on the field". In practice, clicking a glowing hand card often opened the card's keyword panel instead (`c11_h`, the Ghost Town click), or nothing visibly happened. In `c11_o_g_t4_d.png` the Soup Kitchen Volunteer glows gold but is still in hand after I had clicked it. Dragging works, but the game teaches clicking. Players will feel the game is ignoring them.
- **The "Needs 3 energy; you have 0" hint stays on screen** for the whole turn, even after I played Infrastructure, and it contradicts the tip just above it ("Play an Infrastructure. It gives you energy", `c11_g_b1_15.png`).
  - New Infrastructure apparently is not usable the turn it lands, or it shows 0 until exhausted.
  - Either way, the number a player trusts most says 0 right after they followed the instruction.
- **Tip boxes sit on top of the thing they explain.**
  - "Play a unit" covers the hand (`c11_h_b1_22_t2.png`).
  - "Attack!" covers the enemy units you are about to attack (`c11_i_b1_t4_b.png`).
- **Played Infrastructure becomes a thumbnail-sized card** tucked between the board and the hand (`c11_g_b1_15.png`, around 711,628). I could not tell how much energy I had at a glance. The energy orbs (bottom-left, around 40,880) are tiny.
- **The defeat recap is excellent (`c11_i_b1_end.png`).** "Cannon Fodder dealt 6 of the 13 damage you took (3 hits)" plus a concrete tip. This beats Slay the Spire's death screen for teaching. Keep it.
- **Keyword panels on inspect are good** (Exhaust, Red Tape spelled out in `c11_h`). The resource rule text is long, though. For example: "target unit gets -2/-0 until the start of your next turn (it stays shrunk through your opponent's turn). Your turn only."
- **The quest and map disagree on names.**
  - The quest says "Say hello to Sable at her card shop"; the map's Where to? list says "Card Vendor (Vendor)" (`c11_p_p_02_whereto.png`).
  - "Assistant to the Regional Merchant (Vendor)" is a joke title in a navigation list, so I did not know it was the gear shop until I talked to him.
- **The quest log reads "Given by Elder Maren, hand it back to them".** That is template grammar: Maren is a "her".

### Pacing and friction

- **Walking is slow and blocked.**
  - The forest pushes you back with "The trees are too dense to pass through. To the cave." (`c11_c2_n_05.png`) and "No point getting lost twice in one day" (`c11_c2_n_07.png`).
  - In Crosspath, 1.5 to 2.5 s of held movement barely moved me. A yellow-haired NPC parked next to the hero blocked the route west (`c11_t_t_01.png`).
  - Across four runs I could not reach Sable on foot, the first objective of the main quest.
- **Talk loops.** Bertram's conversation re-opens if you press E again after the last line. After eight E presses I was still inside his dialogue (`c11_u_u_05_deck.png`). The last line should not be re-triggerable from the same key press, and a talked-out NPC should shrink to a one-line bark.
- **Too many screens after every win.** Victory banner, then Continue, then reward pick, then Take, then Level up (two pages), then Continue, then "Through the Forgotten Cave", then "Step outside". That is 6+ clicks between the last hit and walking again. Slay the Spire does it in one screen.
- **The first duel lasts 8 to 10 turns against a 3-HP enemy.** The Scavenger floods 2/1 Cannon Fodder and fliers, and my early turns were spent on 0-energy Infrastructure. Three tries gave two defeats, one by 0 HP at turn 8 (Gourmand) and one at turn 10 (Necrocrat), plus a win at 2 HP. Some of that is my semi-blind scripted play, but the built-in `pilot`, a simple bot, also lost its Gourmand finish. A tutorial duel should be hard to lose.

### Combat depth and feel

- **There is real promise.** Red Tape as a spendable tempo tool, Processing (delayed) spells, Golem cooking, and Refuse Piles beside decks. The phase tracker (Start / Main / Combat / Main 2 / End) and "Select All Attackers" (`c11_i_b1_t4_b.png`) are good, readable UI.
- **The board is cramped and vertical.** Enemy units sit directly above mine, almost touching (`c11_j_b2_t4_atk.png`). Most of the lush battlefield art is empty while the action happens in a 450 px column. The hand overlaps the bottom row of units.
- **Small numbers.** Attack/HP badges and card rules text are small at 1600x900, and hand-card text is unreadable without hovering.
- **The AI announcements are good** ("Cave Scavenger attacks with Cannon Fodder and 3 more").
- **The "End your turn?" guard works** (`c11_o_g_t4_main.png`). It needs to be paired with the click fix, though, or it reads as the game scolding you for something its input caused.

### Deck-building satisfaction

- **The Deck Station UI is the best screen in the game after the title (`c11_w_w_01_deck.png`).** It has filters, copy counts ("Deck 2/3 Own 2"), a mana curve, legality checks, Fill Infrastructure, and Suggest a deck.
- **The underlying design undercuts it.** A 45-card minimum with 19 basic Infrastructure and only 1 to 3 copies of everything owned means each reward card is about 2 % of the deck. After the cave, my "choice" was 1 card into 46. Slay the Spire and Monster Train make the first pick matter; here it vanishes.
- **There is no reason to open the Deck Station in the first hour.** There is nothing to swap. Card Packs is empty ("No unopened packs", `c11_w_w_03_packs.png`).
- **Smaller issues:**
  - "At most 1 colors" is a grammar slip.
  - The "Tip: Building a deck" box covers the deck list.
  - Locked slot racks at "Level 7 / Level 14" add visual noise to a first look.

### Reward rhythm

- **Good.** Gold, XP and a 3-card pick after each fight (`c11_j_b2_after.png`). Level-ups give cosmetics ("Bowler Hat"). Feats pop up early ("Feat: Leaves in Your Hair").
- **The rhythm is front-loaded with popups.** After the cave I was level 3 with 440 gold and nothing I could spend it on (Bertram refuses, and I could not reach Sable).
- **The reward pick pre-selects the middle card** ("Working in Your Own Casket joins your deck") before you choose. That makes Take feel like a default rather than a decision.

### Exploration and world

- **The cave node map is lovely and clear (`c11_e_tut_01.png`).** The Hollow Well event shows its odds ("about 69 % to pass"), which is a nice touch.
- **The forest is very dark teal**, with large translucent tree-trunk planes cutting across the frame (`c11_c2_n_05.png`, the diagonal pale shafts). It reads like a rendering glitch rather than god rays.
- **Crosspath is the biggest problem in the hour.**
  - The camera sits behind and above rooftops, so a huge thatched roof covers 40 to 60 % of the screen (`c11_m_m_03.png`, `c11_n_n_03.png`).
  - In several shots the hero is not visible at all.
  - The square itself is charming when visible (`c11_q_q_02.png`), with its fountain, lamps, half-timbered houses, and named NPCs.
  - Compare Octopath, whose HD-2D town cameras always fade or cut away foreground buildings.
- **The town map starts nearly black** ("Dark areas are unexplored", `c11_m_m_05_map.png`), so it cannot help you find Sable. "Where to?" teleports or walks you to the square, then leaves you there.
- **First-zone looks:**
  - The **Endless Buffet** (`c11_v_v_07_buffet.png`) has a fun idea: broccoli trees and a checkered-tablecloth bridge. Under a heavy orange wash it reads flat and low-detail, with a black cube oven that looks unfinished.
  - The **D.N.A.** (`c11_n_n_10_dna.png`) is grey slabs and empty floor: stark, more grey-box than office-of-the-dead.

### Story and humour

- **Lines that land:**
  - "Even in death, he files." (Skeleton Clerk)
  - "I have far too much pie."
  - "Runs on carbs and spite."
  - "No pressure. (Some pressure.)"
  - The Path names (Necrocrat, Refusemancer) are good.
- **Lines that miss:**
  - **The opening is generic** (see above).
  - **The boss intro is flat.** The Hollow Warden says "...Hm. Woken from my slumber. It has been some time since anyone has walked this path. No matter. Only one may pass, and he is long dead." The last line doesn't parse.
  - **The cave-complete card opens with a stray line.** "Let the Paths guide you." sits above "The light drains from the Warden's eyes." (`c11_l_l_07.png`).
  - **Bertram Beetsworth, "Assistant to the Regional Merchant"**, holding a beet, with "Security Protocol" lines (`c11_u_u_05_deck.png`). That is a direct *The Office* lift. It will get one smile from people who know it and reads as borrowed rather than original.
  - **Townsfolk repeat one bark** ("Lovely day for a quest, isn't it? Shh. Not too lovely. Somebody's listening.") and are all labelled "Townsfolk".

### Visual cohesion and readability

- **The painted 2D layer is excellent and consistent.** That covers the stills, portraits, card art and UI frames.
- **The 3D world switches styles between areas.** The forest is murky green, the town orange-washed with tilt-shift blur, the D.N.A. flat grey, and the Buffet orange again.
- **Text is small throughout.** That includes the hand cards, the More panel, and the control hint line (bottom right).
- **Long names truncate** ("BERTRAM BEETSWORTH, ASSIS...").

### UI/UX consistency

- **E / Space advance dialogue, but not the "Through the Forgotten Cave" card.** Pressing E there throws `SCRIPT ERROR: Invalid access to property or key 'disabled' on a base object of type 'previously freed'` at `RewardsScreen._input (rewards_screen.gd:248)`, 20 times in run `c11_l`, and does nothing. You must click "Step outside".
- **Victory "Continue" and the opening-hand "Keep Hand"** also need clicks where E would be expected.
- **Esc opens the pause menu over modal screens** (the Path chooser), and over the town when a dialogue has just closed.

### Audio

I cannot judge it from screenshots and logs; no audio errors appeared.

### Performance

- **No stutter showed in the command timestamps.** Battle actions were responsive.
- **Waits:**
  - Zone and dungeon loads took about 8 to 12 s.
  - The first boot took about 3 minutes on this PC.
  - Every snapshot load needed about 5 to 8 s.
- **Every exit logs RID and ObjectDB leak warnings** ("38 ObjectDB instances were leaked at exit"). That is harmless for players but worth cleaning.

### Bugs seen

1. The `RewardsScreen._input` freed-object errors (20 per cave completion when E is pressed).
2. Esc on the Path chooser opens the pause menu over it, and a click meant for the chooser's Begin button lands on the pause menu's Quit Game (`c11_b_path_04_after.png`).
3. NPC talk re-opens on repeated E (Bertram).
4. A roaming or idle NPC body-blocks the hero on the square (`c11_t_t_01.png`).
5. The energy hint shows "you have 0" after playing Infrastructure.
6. After a `dev travel zone`, the HUD objective reads "Go to Crosspath" inside the zone (`c11_n_n_10_dna.png`). This is possibly a debug-jump artefact, but worth checking.
7. The opening dialogue's typewriter swallowed an E press, so the same line showed twice ("Behind me is the Forgotten Cave..." in `c11_c2`). That is fine behaviour (the first press completes the line), but with 1 s waits the opening feels sticky.

## Top 15 problems (ranked by impact on a new player)

1. **The town camera hides the hero behind roofs.**
   - **Where:** Crosspath (`c11_m_m_03.png`, `c11_n_n_03.png`, `c11_u_u_05_deck.png`).
   - **Why it matters:** The hub is where the first hour happens. Not seeing yourself or the shop doors makes every errand a chore and makes the game look broken.
   - **Fix:** Fade or cut away any building between the camera and the hero (dither or alpha on roofs within a cone), lower the town camera pitch less steeply, or pull the camera in toward the hero.
2. **The first tutorial duel is long and losable.**
   - **Where:** Forgotten Cave, Cave Scavenger (`c11_i_b1_end.png`, `c11_o_g_t4_d.png`).
   - **Why it matters:** I lost 2 of 3 tries across two Paths. Losing your first fight before seeing the town is a churn point.
   - **Fix:** Script the first duel. Give a fixed opening hand with Infrastructure plus a 1-drop, stop the enemy flooding (one Cannon Fodder, no fliers), and hand the player a lethal-in-3 line. Or make the Scavenger 2 HP with no blockers on turns 1 to 2.
3. **Clicking a hand card doesn't reliably play it.**
   - **Where:** Battle (`c11_h`, `c11_o_g_t4_d.png`).
   - **Why it matters:** The tutorial teaches click-to-play, so it feels like the game ignores input.
   - **Fix:** A single click on an affordable card plays it (target-select if needed). Inspect goes to right-click or hover, and the keyword panel to hover-hold.
4. **Walking is slow, gets blocked, and the first errand is hard to reach.**
   - **Where:** Crosspath square (`c11_t_t_01.png`) and the forest (`c11_c2_n_05.png`).
   - **Why it matters:** "Say hello to Sable" took me four runs and I never got there.
   - **Fix:**
     - Raise walk speed (or default to sprint in town).
     - Make NPCs non-blocking (or let them step aside).
     - Make "Where to?" walk you all the way to the named NPC.
     - Put a ground arrow or beacon on the current objective.
5. **The starting deck is 45 cards, so picks don't matter.**
   - **Where:** Path chooser (`c11_b_path_03_more.png`) and Deck Station (`c11_w_w_01_deck.png`).
   - **Why it matters:** Deck-building is the genre's core pleasure, and here a reward card is about 2 % of your deck.
   - **Fix:** Start at about 20 to 25 cards (8 to 10 Infrastructure) and grow the minimum with level. Or keep 45 for constructed play but run dungeons with a smaller "run deck".
6. **Tip boxes cover the cards and units they explain.**
   - **Where:** Battle (`c11_h_b1_22_t2.png`, `c11_i_b1_t4_b.png`).
   - **Why it matters:** New players can't see what they're being told to click.
   - **Fix:** Anchor tips to the side rail (left of the phase tracker), point to the target with an arrow, and never overlap the hand or the targeted row.
7. **The energy feedback contradicts the tutorial.**
   - **Where:** "Needs 3 energy; you have 0" after playing Infrastructure (`c11_g_b1_15.png`).
   - **Why it matters:** It breaks trust in the most basic rule.
   - **Fix:**
     - Show energy as large orbs by your HP.
     - Make new Infrastructure usable at once (or say plainly "ready next turn").
     - Remove the persistent "needs X" label once the player has acted.
8. **Typos and flat lines in the opening and the first boss.**
   - **Where:** Wake-up dialogue, Elder Maren, Hollow Warden, the cave-complete card (`c11_l_l_07.png`).
   - **Why it matters:** The first 20 lines set the quality bar, and the art promises more.
   - **Fix:** Proofread the first hour line by line ("it's", "she's", "the way they're shouting", "acquainted"). Rewrite the Warden's intro with one specific joke. Drop the stray "Let the Paths guide you." line.
9. **Too many screens between fights and play.**
   - **Where:** Victory, then rewards, then two level-up pages, then the cave-complete card (`c11_j_b2_after.png`, `c11_l_l_07.png`).
   - **Why it matters:** Each extra click dulls the win.
   - **Fix:** Merge victory, gold/XP and the card pick into one screen. Show level-up as a toast with details in C. Let E or Space confirm everything.
10. **E doesn't work on the cave-complete card, and it throws script errors.**
    - **Where:** `RewardsScreen._input` (rewards_screen.gd:248), run `c11_l`, 20 errors.
    - **Why it matters:** The input feels inconsistent and it is a real freed-object bug.
    - **Fix:** Guard the freed button reference in `_input` and map E / Space / Enter to the focused button on every reward or summary card.
11. **NPC conversations re-open in a loop.**
    - **Where:** Bertram (`c11_u_u_05_deck.png`).
    - **Why it matters:** The player is trapped re-reading lines and thinks the game is stuck.
    - **Fix:** Swallow the E press that closes a dialogue. After the first full talk, show a one-line bark with a "[E] Talk again" prompt.
12. **Esc on modal screens opens the pause menu.**
    - **Where:** The Path chooser (`c11_b_path_04_after.png`).
    - **Why it matters:** A misclick then lands on "Quit Game" in the most important choice of the game.
    - **Fix:** Esc closes the topmost panel (More then Less), and pause is suppressed while a modal chooser is open.
13. **The battle board is cramped and its numbers are small.**
    - **Where:** `c11_j_b2_t4_atk.png`.
    - **Why it matters:** Readability is the soul of a card battler, and units overlap and text is tiny.
    - **Fix:** Spread the rows (enemy row higher, player row lower), shrink the hand when it is not hovered, enlarge the ATK/HP badges, and show played Infrastructure as a clear row of energy orbs, not mini-cards.
14. **The quest, the map and the NPC names don't match.**
    - **Where:** "Sable" versus "Card Vendor (Vendor)"; "Assistant to the Regional Merchant (Vendor)" (`c11_p_p_02_whereto.png`); "hand it back to them".
    - **Why it matters:** Navigation by name fails.
    - **Fix:** Use one canonical label per NPC ("Sable - Cards", "Bertram - Gear") everywhere: quest text, map, HUD and name plates. Fix the pronoun template.
15. **The world style is inconsistent and the forest is murky.**
    - **Where:** The forest's translucent tree planes (`c11_c2_n_05.png`), the grey-box D.N.A. (`c11_n_n_10_dna.png`), the orange-washed Buffet (`c11_v_v_07_buffet.png`).
    - **Why it matters:** The title screen promises a vivid storybook world; the 3D spaces under-deliver next to the painted UI.
    - **Fix:**
      - Lift forest exposure and remove or soften the large translucent trunk planes.
      - Give the D.N.A. an office set-dressing pass (desks, filing stacks, signage) before anything else.
      - Pull back the global orange grade in the Buffet and town so local colours read.
