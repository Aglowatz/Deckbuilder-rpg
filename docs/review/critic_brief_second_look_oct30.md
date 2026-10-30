# Second-look brief - how to play "The Wayward Path" (read only this file and `critic_brief_oct30.md`)

You are a seasoned games critic and UX researcher. A colleague reviewed this new indie deckbuilder RPG earlier today; the developers
say they changed some things since. You have never seen the game. Read `docs/review/critic_brief_oct30.md` for how to run it, the
controls, the driver's commands and the hard rules (one game process at a time, foreground, 480 s runs, no other files read, no git) -
everything there applies, except the deliverable and the scope, which are below. You must NOT read your colleague's report, the
developers' notes, docs, code or data: judge only what you see and do in your own runs.

## Scope

**Part A - the first 30 minutes on the Gourmand Path** (title, opening, Path choice, the forest, the cave, the first duel played at least
once by hand and once with `pilot`, the map, the first rewards, the Deck Station). Score the same areas as the standard brief where the
30 minutes let you (first five minutes' hook, clarity, pacing and friction, combat feel, reward rhythm, visual readability, UI/UX
consistency, bugs), 1-10 against Slay the Spire / Inscryption / Monster Train / Sea of Stars / Octopath / Pokemon TCG Pocket.

**Part B - ten specific questions.** For each, say what you saw, cite a screenshot, and give a verdict: **landed** (a new player would
be fine here), **partly** (better, but still a problem - say what remains), or **not landed**. Reproduce each with the driver.

1. **Finding the cave on foot.** From the bedroll after the hooded figure leaves, is the way to the cave obvious without the cheat jumps?
   Is there any marker in the world, on the HUD or on the minimap / map (M)? Walk there with `hold` (try `hold W+D`, `hold W`,
   `hold D`; look at each screenshot before choosing the next direction). Note how long it took and whether you got stuck.
2. **The Deck Station in the forest.** Press B, close it with its X button (top right of its header) and again with Esc. Is the world
   drawn afterwards, or black?
3. **The map in the forest.** Press M, then M again, then open it and press its X button. Does each close it?
4. **The battle banners.** In any duel, screenshot right as YOUR TURN / ENEMY TURN appears (use `wait 0.3` after a turn change, or
   `dev win` then `wait 0.4` then `shot`). Is VICTORY! / DEFEAT / YOUR TURN whole and centred, or clipped at an edge?
5. **The tutorial's "Spend your Iron / Ingredient" tip.** Play the first duel by hand (or with `pilot`) and watch for a tip that says the
   duel waits for you. Does it ever appear while you have no unit of your own on the table? Can you always end the turn or get past it?
6. **Unplayable cards.** In a duel, click a hand card you cannot afford, and a second Infrastructure in one turn. What does the game
   tell you?
7. **The reward screen** after a won duel. Which button is the live gold one before you touch anything? Is a card already chosen?
   Hover a card with a keyword (Hustle, Wallflower, Flying...): is the keyword explained anywhere on that screen?
8. **The Hollow Well** (the cave's event node) and the **shrine**: does the well's result say whether you passed and why? What does
   the shrine's node info (hover it on the map) say it restores?
9. **The cave's Rules (R)** panel and the **Character screen (C, in town)**: is there a line about copies per card that a new player can
   read without a key?
10. **The HUD Menu button in town** (`dev travel town` if you are not there; the Menu button is at the right): what does it list? Can
    you reach the Glossary and the Feats from it?

Also note any **new** problem you hit, and whether the pause menu (Esc) works everywhere you tried it.

## Deliverable

`docs/review/fresh_eyes_second_look_oct30.md`: Summary; How I played; Part A scores (table) with 3-6 findings; Part B as a table
(question, what I saw, screenshot, verdict) followed by notes; New problems; a closing paragraph on whether the first 30 minutes now
hold a new player, compared with the games above. Copy cited screenshots into `docs/review/fresh_eyes_second_look_oct30/`. Scripts go
in `docs/review/play_scripts/critic2_*.txt`. Budget about 60-75 minutes. Your final reply: the ten verdicts in one line each and the
Part A scores.
