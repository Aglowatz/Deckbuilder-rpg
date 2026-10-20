# Dialogue pass Oct 19: gainlands_buffet

Writer area: the Gainlands (Beefcakes) and the Endless Buffet (Gourmands). Text values only. No keys added or removed, no ids, flags,
`.speaker` values, `%s`/`%d` or indexed arrays (`reps.shouts`, `wheel.*`, `order.*`, `recipe.*`, `fortune.hints`, `travel.dest.*`) changed.
Godot was not run. Checked with a node script (scratchpad `gb_check.js`): both files parse, the key sets match the originals (245 and 251),
placeholders and tokens survive, and no dialogue box is over 240 characters. The only boxes over 240 are the old `hud.objective` /
`ui.main.body` texts, which I did not touch (`ui.*` is not measured by the fit test). Every test string I found that reads these files
still matches ("star pupil", "Lovely day for it", "it was not the part that matters", "do something worth signing", "Grandmaster Flex"
and "regime" in Old Man Mountain's intro, "Special Sauce" in Basil's intro, "CLENCH" / "NEW HOUSE RULES", the sign quiz answers).

## Files and key groups rewritten

| File | Key groups | Keys changed |
|---|---|---|
| `data/story/gainlands_story.tres` | Flex/Clench: `cutscene.rescue.*`, `cutscene.flex.*`, `dungeon.hg_boss.before/after(_alone)`, `freed_npc.heartlift`, `dungeon.hg_stretch.after`, `event.hg_rescue.*`, `event.hg_trophy_hall.result.*`; Old Man Mountain `npc.brenda.*`, `fx.wake`, `quest.gain_spot_me.*`; Gus `npc.gus.*`, `quest.gain_power.*`; Benchley `npc.tony.*`, `quest.gain_lanes.*`; Gary `npc.gary.*`, `fx.spot_done`; Pump `npc.quiz.*`, `quiz.result.2`; Chet `npc.minigame.intro`; throwers/rippers `travel.*.intro/.locked`; `dungeon.hg_checkpoint.blurb`; a few signs; the quiz `where` note | 63 keys (155 lines) |
| `data/story/gourmand_story.tres` | reveal `cutscene.reveal.*`, `cutscene.wonder.*`, `dungeon.tk_boss.before/after`, `freed_npc.grandchef/.escoffina`; Basil `npc.odalys.*`, `fx.wake`, `quest.buf_mend.*`; Tarragon `npc.tarragon.*`, `quest.buf_pantry.*`; Mirepoix `npc.dolcetta.*`, `quest.buf_pie.*`; Pate `npc.quiz.*`, `quiz.not_passed`; Flambe `npc.minigame.intro`; golems `gate.ingredient/quest.*`; `event.tk_whistleblower.*`, `dungeon.tk_cold/vats`; `sign.innovation`, `sign.inspection_note`; the quiz `where` notes | 52 keys (133 lines) |

Arrays I lengthened, only to split a long box (each is read as one box per entry or as one cutscene panel, so this is safe):
`dungeon.hg_boss.before` 4 -> 5 (the beat map's 230-character box), `cutscene.rescue.3` 2 -> 3, `cutscene.flex.5` 1 -> 2,
`dungeon.tk_boss.after` 2 -> 3, `cutscene.reveal.3` 1 -> 2, `cutscene.reveal.5` 1 -> 2, `cutscene.wonder.5` 1 -> 3 (the 300-character
box), `cutscene.wonder.6` 2 -> 3. Every other array kept its length.

## Notable fixes

- **Tiny Tony leftovers:** `npc.tony.intro` "Yes, I know. Everything's relative." is gone. Benchley now has his voice from the voice bible:
  no inside voice, "LET'S GO!", cards sold as "supplements for your DECK", and a whisper only for the floorboard. `quest.gain_power.offer`
  "Tony's stand" now says "the protein stand here in the Station" (that is the quest's real spot, `protein_stand`). Vendors no longer say
  "Shop's open" (Benchley, Mirepoix).
- **Pronouns:** `travel.ripper_calf.locked` "her 'Spot Me!' quest" is now "his 'Spot Me!' favour" (Old Man Mountain is he). Basil's
  "for a man who does not eat" is now "for someone who never tastes a thing"; the whistleblower's "He does not taste the soup" is now "She";
  the Grand Chef and her double are she everywhere. Basil has no pronoun in canon, so I took the old "Basil sends her thanks" / "Speak to
  her" out of Sir Loin's lines ("Basil sends thanks", "Speak to Basil in the Grand Pantry").
- **"Brenda"** (banned) is out of the quiz `where` note ("Old Man Mountain's intro line"). The Buffet's "Basil' intro line" is now "Basil's".
- **The Doppelganger reveal:** "Soup is for the weak. {villain}'s orders are for the strong" and "Behold the true dish of {villain}: the
  Doppelgänger" (umlaut) are gone. Now it speaks cold, flat pitch-speak ("Tasting is inefficient... 'Delicious.' That is the word I was given
  for it. I do not know what it means."). Then the sad part: "I wore her face so long that I forgot my own. There is nothing in here to
  taste with." `npc.odalys.intro.freed` now spells "Doppelganger" without the umlaut. `dungeon.tk_boss.before` "the future tastes like...
  Obedience" is quieter now ("The future does not need to be tasted").
- **Gus speaking of himself in the third person** (`quest.gain_power.done`) is fixed: "I'd hug you, but I'm a foreman. We nod."
- **Flex's lesson:** the rescue and the boss scene now say that the strength is breath, heart and mind ("So I had everything. My breath. My
  body. My mind."). He calls the Wanderer "son" and Clench "my boy", which is his voice entry. Narration says "you", not "the Wanderer", so
  nothing reads wrong after the prince reveal.
- **The Grand Chef's closing line** used the literal "Wanderer". Now it is "my dear", which keeps "a blank page" and "do something worth
  signing" (the test string).
- **Instructions are clearer.** `quest.gain_spot_me.active` names both mirrors (the Station, Pec Perch). Benchley's `gain_lanes.offer` says
  "any three, in card duels". `buf_pantry` says "any three". `buf_pie` says "into the Grand Oven by the arch, then bring it here".
  `buf_mend` names Sir Loin and the Layer-Cake Town gate, not "the Warden".

## Callbacks and beats planted

- **C1:** `gainlands cutscene.flex.3` now really says "They took my weights, Clench. They forgot to take me." The beat map cited this line,
  but the text did not have it. It goes with "it was not the part that matters" (`dungeon.hg_boss.after`, `_alone`, `freed_npc.heartlift`).
  These are for the capital writer's `cutscene.primm_p1.2` to quote.
- **C2:** `gourmand freed_npc.grandchef` keeps "That is not a flaw, it is a blank page." The phrase is the same as before, for `primm_p2.2`
  to quote.
- **C6 (the face):** `npc.brenda.return` sets it up ("Four colours in his hands, plain as day... You've got a look about you") and
  `npc.brenda.intro.freed` pays it off ("you made the same face he did. Exactly the same face."). The payoff now sits in its own box and is
  played straight.
- **C7 (the cake):** `npc.odalys.return` (four layers, he licked off the frosting, Chef laughed for a week, the fake forgot it) pays off in
  `npc.odalys.intro.freed` ("Is the boy all right?").
- **C18:** `npc.gus.intro` now says "They want the same out of the city wheels up in the Capital. Those crews get told it's cardio. It
  isn't." This sets up Rollo's "we were told it was cardio" (capital `npc.rollo.intro`).
- **The Clench set-up:** `npc.brenda.intro` box 4 now names Clench as "Grandmaster Flex's own star pupil". That lands before
  `dungeon.hg_boss.before`'s "Your star pupil".
- **The prison feeling familiar:** `event.hg_rescue.body` ("Ten years, a cell, people trying to break you. Something tightens in your
  chest") is kept and tightened.
- **"She never tastes":** the beat runs Basil (`npc.odalys.intro`: "Chef ALWAYS tastes, and this Chef doesn't") -> Tarragon ("She just
  never tastes anything") -> the inspector's note -> the canteen cook -> the whistleblower ("Chef ALWAYS tastes") -> `tk_vats.after` ("soup
  that nobody has ever tasted") -> the reveal ("You never taste your own soup") -> Escoffina ("I tasted it. As me.").
- **The freezer:** `dungeon.tk_cold.blurb` has a new hint, "One of the freezers is humming louder than the rest". It pays off in
  `dungeon.tk_boss.after`, when the freezer door opens.
- **Lieutenants (mentions only, section 4.6):** Quota's stopwatch at the Regime Checkpoint (`dungeon.hg_checkpoint.blurb`), and Crumb's
  seal plus "for the war effort" on `sign.innovation`.

## Not done / needs someone else

- `still.flex` ("They had not taken his muscles") is in `intro_story.tres`, not my files. It is the beat map's weak line 4 and still
  contradicts the lesson.
- C24 (Brick's "the old man who never broke") is in intro `beefcake_npc_*_lines`, not my files. Brick's freed-zone lines need code (the
  gatekeeper victory array is replayed forever).
- The name clash between Rhonda the Gainlands ripper and Recycle Rhonda is still open in the inbox. I kept the name.
- I did not touch the Gainlands and Buffet barks in `npcs.json`, or the `quest.side_s_beef/_gour.*` lines in `dungeon_content.json`
  (not my files).
- Some `dungeon.hg_*` / `dungeon.tk_*` node titles and blurbs may be overridden by `DungeonCatalog` text built from the sheet. I polished
  only the ones the beat map named.

## 10 best before -> after

1. `gourmand cutscene.reveal.5`
   - Before: "THIS is my real face. Behold the true dish of {villain}: the Doppelgänger. Now. Let me serve you."
   - After: "This is what was under it. I wore her face so long that I forgot my own. There is nothing in here to taste with." / "Sit down, taster. I was told to serve you."
2. `gourmand cutscene.reveal.3`
   - Before: "...Soup is for the weak. {villain}'s orders are for the strong. I have given the Gourmands the Special Sauce, and they have given me an army of golems. It is a very efficient arrangement."
   - After: "...Tasting is inefficient. The orders from {capital} asked for golems, not flavour, and the Special Sauce delivers golems." / "\"Delicious.\" That is the word I was given for it. I say it often. I do not know what it means."
3. `gainlands cutscene.flex.3`
   - Before: "You took my plates, my protein, my pump, Clench. You thought you had taken my strength. But you only took the weight." / "You left me my heart, and my mind. I taught you everything I knew about the first, and you stopped listening before I got to the second."
   - After: "They took my weights, Clench. They forgot to take me." / "You only ever took the weight. I taught you the heart, and you stopped listening before I got to the mind."
4. `gainlands npc.tony.intro`
   - Before: "I'm Coach Brutus Benchley. Yes, I know. Everything's relative." ... "Do not ask what is under it. Iron."
   - After: "LET'S GO! FRESH LEGS! Coach Brutus Benchley! Retired champion, current motivator, part-time merchant!" ... "*whispering* And do not stand on the loose floorboard behind the counter. There's nothing under it. Iron. Nothing."
5. `gourmand npc.odalys.return` (box 3)
   - Before: "The Grand Chef has very good hearing, for a man who does not eat."
   - After: "The Grand Chef has very good hearing, for someone who never tastes a thing."
6. `gainlands npc.gus.intro` (box 2-3)
   - Before: "The regime wants a hundred and ten percent. The wheels only go to a hundred."
   - After: "The regime wants a hundred and ten percent. The wheels go to a hundred. The extra ten is me, crying quietly." / "They want the same out of the city wheels up in the Capital. Those crews get told it's cardio. It isn't."
7. `gainlands dungeon.hg_boss.before` (end)
   - Before: "\"So I took your iron, your protein, your followers. And you come back weaker than a damp towel. What do you think you can do?\""
   - After: "\"So I took your iron. Your protein. Your followers. And you come back to me weaker than a damp towel.\"" / "\"Look how far I went, Master. What do you think you can do?\""
8. `gourmand npc.odalys.intro` (box 4)
   - Before: "She looks the same. Sounds the same. But she does not taste a dish before it goes out any more."
   - After: "She looks the same. She sounds the same. But Chef ALWAYS tastes, and this Chef doesn't. She just smiles at the soup."
9. `gainlands quest.gain_power.done`
   - Before: "The grid's running smooth, and some of it is even staying here. Gus would hug you, but Gus is allergic to humility."
   - After: "The grid's running smooth, and some of it's even staying here. I'd hug you, but I'm a foreman. We nod. ...That was a big nod."
10. `gourmand freed_npc.escoffina` (box 3)
    - Before: "I made a sauce today. A real one. It had too much salt."
    - After: "I made a sauce today. A real one. I tasted it. As me. It had too much salt."

Runners-up: `gainlands freed_npc.heartlift` box 5, new ("Lift what you can. Carry what you must. Put down what was never yours.");
`gourmand quest.buf_mend.ready` ("I'm not crying. I'm standing near onions."); `gainlands travel.ripper_calf.locked` (the pronoun fix).
