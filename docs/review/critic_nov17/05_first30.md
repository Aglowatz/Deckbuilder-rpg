# Critic 5 - the first 30 minutes and the menus (Nov 17)

## 1. How I played

I used all 14 runs (about 80 minutes). Screenshots are `_screenshots/exported/n17first30_<nn>_*.png` and logs are `play_n17first30_<nn>_play.log`. The only dev commands I used were `dev save` and `dev load`. I made no jumps.

- **Run 1-2:** title screen, all five Settings tabs, switched VSync off and on, New Game, and read the opening by hand.
- **Run 3-6:** the opening again, then the Choose your Path screen. It took me three runs to get a Path picked (see problem 1). `dev save` answers "Nothing to save yet" for the whole opening, so every retry replayed it from the title. My first snapshot, `n17first30_06`, is after the opening, in the forest.
- **Run 7-8:** walked to the Forgotten Cave and its dungeon map. I saved there, but loading put me back in the forest and the cave was reset (problem 4).
- **Run 9-11 and 14:** the cave's first fight, by hand. I played 5 turns of it (run 11). The Peek pop-up blocked one run (10). In run 14 the game ended up stuck on the pause menu because of the silent J/C/P keys (problem 5).
- **Run 12:** menus from the forest: map with Point me to..., quest log, Character page, Deck Station, Card Packs, Wardrobe, pause.
- **Run 13:** controller only: pause, map, Deck Station, walking, entering the cave, the dungeon map, and the first turn of a fight.

**Not reached:** a won fight, the second fight, the rest of the cave, Crosspath, the first errands, the shops, and Card Packs or Wardrobe actually opening. At this pace a scripted first-time player still had not reached the town after 80 minutes. Some of that is the driver's blindness, but most of the lost time came from problems 1, 3, 4 and 5 below.

## 2. Score: 4/10 (first impression)

- **Clarity 4/10:** The words are clear. The Path panel, the HUD and the screens that open in this area are not: J, C and P did nothing in the forest with no message (`n17first30_14_J`, `_12_char`, `_12_packs`), and a click on a Path's cards or icon did not select it (`n17first30_05_picked`). The tips explain each step, but they pile up: four pop-ups on turn one (`n17first30_09_f1`, `_f7`, `_10_t1b`).
- **Fun 5/10:** The card fight has a real hook. Ingredient tokens pile up, Peek is a small decision, and the board reads well (`n17first30_11_t4b`). But the first enemy has 3 HP and was still alive on turn 5, because new units wait a turn and the tutorial pace drags (`n17first30_11_end`). Slay the Spire has you through your first fight in two minutes.
- **Polish 6/10:** The painted art is very good: the title, the wake-up still, the cave map and the cards (`n17first30_01_title`, `_02_ng_a`, `_07_cave1`). Rough edges show around it: hand cards are cut off by the bottom edge of the screen, played Infrastructure is hidden behind the hand, and the forest is dark and murky next to the painted stills (`n17first30_06_end`).

## 3. Top 10 problems

| # | Problem | Where | Severity | One concrete fix |
|---|---|---|---|---|
| 1 | On Choose your Path, clicking a Path's three cards or its icon only shows its description; Begin stays grey with "Pick a Path first". Only a click on the Path's name selected it. A selected panel has no visible selected state. Over two runs I could not start the game. | `n17first30_05_picked`, `n17first30_06_try1` (icon click: still "Pick a Path first"), log run 6 TRY2 (title click: "Begin as Gourmand") | blocker | Make the whole Path panel, cards included, one button that selects it. Give the selected panel a gold border and lift it. |
| 2 | Nothing can be saved during the opening, from New Game until after the Path choice and the Rescuer's farewell. That is about 25 dialogue lines plus the Path screen. Quitting there, or getting stuck as in #1, means replaying all of it. | log run 2-5: `dev: Nothing to save yet` (`scene StartingArea; no game`) | major | Create the save as soon as New Game is pressed, and autosave again right after the Path is chosen. |
| 3 | The first duel is slow. It opens with two stacked pop-ups (Your first duel plus Opening hand). Turn one brings three more tips (Play an Infrastructure, Energy, You made a Resource). Units can't attack the turn they arrive. The 3 HP Cave Scavenger was at 1 HP on turn 5. | `n17first30_09_f1`, `_09_f7`, `_10_t1b`, `_11_end` | major | Give the first enemy no blockers, and give the player a ready unit or a Hustle starter, so the fight ends by turn 3. Show one tip at a time: queue the rest and drop "You made a Resource" until the player first needs to spend one. |
| 4 | Saving inside the dungeon and loading puts you back at the forest start, with the dungeon reset. A player who quits mid-cave loses the whole cave. | log run 8: `dev load n17first30_07` gives `scene StartingArea` (the save was made on the DungeonMap) | major | Save the dungeon node and HP in the save file and resume on the dungeon map. At least say "Your progress in this dungeon will be lost" in Save and Quit to Title while inside one. |
| 5 | In the forest, J (quest log), C (Character page) and P (Card Packs) do nothing and say nothing. The next Escape then opens the pause menu, which is easy to lose track of: in run 14 the game sat on the pause menu for the rest of the run. | `n17first30_14_J`, `n17first30_12_char`, `n17first30_12_packs`, `n17first30_14_end` (paused) | major | Open these screens everywhere, even if empty ("No quests yet"). If one must be locked, show a toast such as "Your quest log unlocks in Crosspath". |
| 6 | Hand cards are cut off by the bottom edge of the screen, so the rules text and stats of every card in hand are hidden until you hover it. Played Infrastructure is tucked behind the hand where you can barely see it. | `n17first30_09_f1` (hand cut at y 900), `n17first30_10_t1b` (Feastforge at about 715,650 behind the hand), `n17first30_11_end` | major | Raise the hand about 120 px, or shrink the cards, so the text box shows. Move your Infrastructure row to the left of your units, above the hand. |
| 7 | The cards on the Path choice screen are about 70 px wide and their text can't be read. Clicking More shows Beefcake's text even when no Path is picked. | `n17first30_03_op18`, `n17first30_04_more` | minor | Show the hovered Path's three cards at full size in the description strip. Make More show the hovered Path, or grey it out until one is picked. |
| 8 | The Peek pop-up has a grey Done and no way out until you press Top or Bottom. It is the only pop-up that E or Space do not dismiss, so a new player wonders whether the game is stuck. | `n17first30_10_t2a`; log run 10, every dump after Peek is the same | minor | Default the choice to Top with Done lit, and let E/Space confirm it. |
| 9 | Controller button prompts are wrong or missing in places. The pause menu says "Report a Problem (F8)". The battle tip buttons ("Got it", "Skip tips") and the round END TURN button show no pad glyph. | `n17first30_13_pause` (dump), `n17first30_13_b1` | minor | Switch every prompt to the active device. Add the pad glyph to tip buttons and End Turn. |
| 10 | The forest after the wake-up is very dark and low in contrast. The hero is a 50 px figure in a murky green scene, a big step down from the bright painted stills before it. The hero's look also changes between the wake-up still (teal cloak) and the dialogue portrait (brown cloak). | `n17first30_06_end`, `n17first30_07_w2`, compare `n17first30_02_ng_a` and `_02_ng_h` | minor | Light the clearing and the path to the cave more brightly and zoom the camera in for the first walk. Use one cloak colour across the still, the portrait and the sprite. |

## 4. Three things that work and must not be lost

- **The title screen and the painted stills:** the first two images sell the game better than any trailer could (`n17first30_01_title`, `n17first30_02_ng_a`).
- **The dungeon map art:** the painted cave with question-mark nodes is gorgeous and clear, and its tip explains the rules in one go (`n17first30_07_cave1`).
- **The controller in battle and menus:** A on a hand card plays it, focus is drawn with a clear gold frame, the HUD switches to "Left stick: move, A: interact", and the Deck Station, map and pause all open from the pad (`n17first30_13_b1`, `_13_dmap_nav`, `_13_deck`).

Also good: the Settings are thorough and plain-spoken. They have five tabs, a "Reduce motion" explanation and full rebinding with controller columns (`n17first30_02_set_access`, `_02_set_controls`). The writing has a light, dry humour ("No pressure. (Some pressure.)").

## 5. SCRIPT ERROR lines

None in any of the 14 runs. The game logs `play_n17first30_01.log` to `_14.log` contain only shutdown messages: "RID allocations ... leaked at exit", "resources still in use at exit", and `Parameter "RenderingServer::get_singleton()" is null`.

## The hook

The game earned my attention at minute one with the title and the wake-up painting, and the opening lines are well written. It began losing me at minute three or four on the Path screen, where my clicks on a Path did nothing. It lost more in the first duel: four tutorial pop-ups and five turns against a 3 HP scavenger. A first fight should feel like a payoff.

## Clarity

The opening dialogue was clear. On the Path screen I had to guess what to click. In the forest the gold marker and the "trees are packed too tightly" bark led me to the cave well (`n17first30_07_w2`). On the dungeon map, E did nothing after the tip and I had to guess to click a node. In the duel the right-hand phase panel ("Your main phase / Play an infrastructure...") always told me what to do, which is good. I guessed again at combat: attacking means clicking units and then Attack, but the tip only appears once you are already in the combat phase. In the overworld I guessed which menu keys exist: the HUD strip lists only WASD, E, M and Esc, and J, C and P were silent.

## The tutorials

There are too many at once, they are well written, and some are badly placed. Each one is short and often funny, but turn one of the first duel stacks four or five. Two of them (Opening hand plus Your first duel, then Energy plus Resource) sit on screen together and cover the board (`n17first30_09_f1`, `_10_t1b`). The dungeon-map tip and the Deck Station tip (`n17first30_13_deck`) are well placed: one screen, one tip, a Got it button.

## The menus

**Best:** the Deck Station (`n17first30_13_deck`). It shows the whole collection at a readable size, has filters by colour, type, cost and rarity, a deck list with copy counts, and Fill Infrastructure and Suggest a deck buttons. It works on a pad. **Worst:** the Choose your Path screen, because of problems 1 and 7: tiny unreadable cards, clicks that don't select, and a grey Begin that never explains which part to click. The pause menu (`n17first30_14_end`) is clean, but it hides the game behind a full parchment background. Its "Open feedback folder" and "Report a Problem" are developer items sitting in a player's pause menu.

## The controller

Worked:
- **Overworld:** Menu opens pause, View opens the map (with a pad hint about Point me to...), X opens the Deck Station, the stick walks, and A enters the cave. The prompt reads "[A] Enter the cave" (`n17first30_13_atcave`).
- **Dungeon map:** A dismisses the tip and the node tooltip says "Press A to go" (`n17first30_13_dmap`).
- **Battle:** A keeps the hand. The D-pad moves a gold focus frame across the hand, A plays the Infrastructure and then a unit, and the button reads "To Combat [X]" (`n17first30_13_b1`, `_b4`). Menu pauses inside a fight.

Did not work or not reached: Y in battle showed nothing visible (`n17first30_13_b5`). The tip buttons and END TURN have no glyph. The pause menu still says F8. I did not reach a shop with the pad.
