# Critic notes, chunk 03: the Endless Buffet (Oct 31 2026)

Suggestions: `docs/dialogue/critic_oct31/suggestions_03.csv` (27 rows, `tools/dialogue_critic_check.js --check` passes all).

## Critique

### Endless Buffet / gatekeeper (Chef Fennel Gravois)
- Strong and on-voice. Corrupted Fennel shouts TASTE IT and "the war effort" exactly as briefed (1009, 1016: "The BISCUIT is for the war effort."). Freed
  Fennel's "more salt and I have never been so happy" (1003) and "Loser washes the ladle. It is a very big ladle." (1005) are good small turns.
- 1019 gives the player the story clue ("The real one ALWAYS tasted. Same face. Ask yourself who was wearing the apron.") and 1020 gives
  direction. Nothing missing.
- Weak spot: the door opening (1008) is generic ("something smells incredible"). It is the first moment in the zone and could plant the
  arms-factory secret. One suggestion.
- Quest Log text is clear; "extremely seasoned" in 1024 is a fair joke at no cost.

### Endless Buffet (zone)
- The sign writing is the best in the zone and some of the best in the game: "The soup of the day is soup." (1115), "There is no step 3.
  There is only boing." (1149), "Chocolate, vanilla and structural." (1199), the taste-tester recruitment pair (1346/1347), the inspector's
  note (1190/1191). The narration mostly follows the "one image, small turn" rule.
- Vendors and NPCs are distinct: Basil (whispered panic, "on the lowest possible heat"), Tarragon (lists, the angry pig), Mirepoix (slow
  "darling", decorative cake), Pate (chalk, footnotes), Flambe (caps, WHOOSH, Savannah Souffle), the knightly golems. Old Meatloaf's
  mend scene (1257-1261) is genuinely touching.
- Repetition: Tarragon's "She hears everything. She just never tastes anything." (1219) duplicates Basil's 1214 almost exactly; Pate's
  return line (1266) repeats his own roux bark (1367); Colonel Casserole's event line (1363) repeats his intro line (1360); the lettuce
  pun is spent twice (1047, 1228).
- Missed register: the brief's "chefs flinch at the word weapon" barely appears in the zone before the dungeon. The sign "Guard the
  kingdom (with golems)" (1102) is the natural place.
- Missed worldbuilding: no Gourmand-vs-Refusemancer line in the zone apart from the Dress Code debuff text (1351) and the inspector's "check
  the compost". Primm's genuinely good reforms (school lunches, the obvious Buffet one) are never mentioned anywhere in the chunk.
- Clarity: the Gravy Bank sign (1166) is where the three gates begin and does not say how they open; each gate's own sign does, but one
  line up front saves walking.
- Small clunks: 1042 ("a serving of fiction"), 1193 (sentence does not parse), 1223 (Mirepoix's stamp/cake line is hard to follow),
  1235 ("I'd like to send it back"), 1541.
- Bertram owns "load-bearing"; Layer-Cake Town's sign (1180) borrows it.

### Omakase (S-GOUR)
- Small and right. The Itamae's near-silence works ("...Sit.", "Omakase." then "This time it sounds like thank you."), and "a bull made of
  toro lowers its horns, politely" (1388) is a lovely image. Basil's offer lines ("I'm excited. I think. It feels a lot like the other
  thing.") are among his best. No suggestions.
- Question only: the Conveyor Gauntlet blurb (1386) compares it to "the Eternal Queue it was modelled on" (a D.N.A. reference). Fine if the
  Eternal Queue is named in the D.N.A.; otherwise a player meets it here first with no setup.

### The Test Kitchen (D-TTK)
- The strongest dungeon writing in the zone. The node blurbs are short and funny ("three kinds of meat and one regret", "Research appears
  to be a one-way conversation", "as though flavour might be used against them"), the canteen cook's "Nobody noticed. Everybody noticed.
  Nobody said." (1425) is excellent, and the Whistleblower event gives clue, direction and a moral choice.
- Crumb's inspection scene is on-voice ("With flavour on his breath."; "PASSED. NEEDS MORE SALT.").
- The reveal and the "wonder" cutscene stay sincere and carry the zone lesson cleanly; the Doppelganger's "I do not know what it means"
  and "There is nothing in here to taste with" land. I left all of these alone.
- Flat spots: the Vats blurb (1420) tells ("This is where the corruption is made") instead of showing; the R&D Archives clue (1449,
  left-handedness "only ever read about") is clunky and off-theme; the Armory blurb (1418) misses the euphemism joke.
- 1517 ("You have been my prisoner for five minutes") reads oddly for a woman who was the prisoner for ten years; it may be intended as
  her joke on the role reversal. Worth a designer look; I did not touch a sincere beat.

### After freeing
- Good payoffs: Basil's "YES, CHEF! ...Oh, that felt good." and "Is the boy all right?" (1549/1550, the best sincere line in the chunk),
  Mirepoix's cake "promoted from decoration to dessert", Escoffina's salt lines, the inspector note mirrored, the cannon firing bread.
- Tarragon's freed intro (1553) does not pay off his own running gag (lunch). The freed statue (1568) has lost the "Whose chin is that?"
  half of the chin gag pair the voice bible flags for restore (the boss blurb 1475 still sets it up: "Her chin is a little off.").
- The freed motto sign (1530) is identical to the corrupted one; a small change shows the zone changed.

## Scores (current lines, before suggestions)

| Area | Writing | Humour | Worldbuilding | Reason |
|---|---|---|---|---|
| Endless Buffet / gatekeeper | 8 | 7 | 7 | Fennel's two modes are clear and funny; the clue and direction are there; the door-opening narration is generic. |
| Endless Buffet | 8 | 8 | 6 | Excellent signs and distinct NPCs; a few repeats; the rivalry, Primm's reforms and the "weapon" flinch are missing. |
| Omakase | 8 | 7 | 6 | Spare and well judged; little room for lore, and the queue reference needs setup. |
| The Test Kitchen | 8 | 7 | 8 | Tight blurbs, strong reveal and clue trail; two blurbs tell instead of show. |
| After freeing | 8 | 7 | 7 | Warm payoffs; a couple of running gags not paid off. |

## Best 5

1. `npc.tarragon.intro::2`
   - Before: "Don't tell the Grand Chef I said anything. She hears everything. She just never tastes anything."
   - After: "Don't tell the Grand Chef I said anything. Last cook who complained got promoted to taste tester. We haven't seen him since."
2. `npc.odalys.intro::0`
   - Before: "Psst. Hello. I'm Basil, line cook. Ladle in one hand, nerves in the other. We Gourmands feed the kingdom and protect it. Every plate is a promise. Every golem is a guard."
   - After: "Psst. Basil, line cook. Ladle in one hand, nerves in the other. We Gourmands feed the kingdom and protect it: chefs cook, golems guard. Lately the golems have been... practising."
3. `sign.hub_motto::2`
   - Before: "- Guard the kingdom (with golems)"
   - After: "- Guard the kingdom (with golems. Defensive golems. Please stop saying the other word.)"
4. `dungeon.tk_vats.blurb::0`
   - Before: "Great vats of the Special Sauce bubble in the dark. This is where the corruption is made."
   - After: "Great vats of the Special Sauce bubble in the dark. A clipboard on the rail reads: BATCH 3,652. TASTED BY: (blank)."
5. `npc.quiz.return::0`
   - Before: "Back to improve your score? Splendid. Knowledge, like a good roux, wants patience. And butter. Mostly butter."
   - After: "Back for more? Splendid. A footnote, while it simmers: the Capital's school lunches were excellent once. Hot, free, balanced. Then came the paste."

## Flavour inventions

- The Capital's school lunches (Primm's early reform) were good, then were replaced by Crumb's Perfect Nutrient Paste (Pate, `npc.quiz.return::0`).
- A cook who complained was "promoted to taste tester" and has not been seen since (Tarragon; fits the taste-tester signs).
- The Special Sauce vats carry a batch clipboard: "BATCH 3,652. TASTED BY: (blank)" (about one batch a day for ten years).
- Test Kitchen weapon crates are labelled "SERVING UTENSILS (DEFENSIVE)".
- The impostor's signed notes are in perfect copperplate with no gravy stains (replaces the left-handedness clue; the "Compare the
  handwriting" choice and its outcome still fit).
- Layer-Cake Town has a mayor whose house is "down to two layers".
- After freeing, the Test Kitchen cannons are ovens (consistent with "war machines melted into ovens" in story bible section 10).

## Design notes

- Restore the chin gag pair: the Doppelganger's "I never liked this chin" is not in this chunk; if it was cut, the freed-statue suggestion
  can stand alone, as the boss blurb (1475) already sets up the chin.
- 1517 "You have been my prisoner for five minutes": confirm the intent (a joke on the role reversal?). If not, it reads as a mistake in a
  sincere beat.
- Fennel has no npcs.json barks in this chunk. A freed bark pair (biscuits, plain bread) would make him feel present after the gate.
- The Gourmand-Refusemancer rivalry has one line in this zone after my suggestion; the Verdant Dump should answer it (a Refusemancer on
  fancy food going to waste) so it reads as a two-way rivalry.
- `order.shouts` order: my suggestion for shout 1 assumes the shouts follow the `order.dishes` order (1 = The Cheese Please), which
  shouts 2-5 suggest. Check before applying.
- The Conveyor Gauntlet's "Eternal Queue" (1386): check that the D.N.A. names it, or the comparison has no setup.
- The suggestion rate is low (27 of 575, about 5%) because about 190 rows are UI, rule text, titles, station names, clues and fortune hints that
  should not change, and the zone's signs, Test Kitchen blurbs and freed lines are already at the level the brief asks for.

## Counts

- Rows read: 575.
- Suggestions: 27.
- By priority: High 2, Medium 12, Low 13.
- By category: Humor 12, Worldbuilding 6, Natural 4, Voice 3, Story 1, Clarity 1.
