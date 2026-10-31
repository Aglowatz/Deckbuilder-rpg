# Critic notes, chunk 01: Prologue and Crosspath (first visit)

Suggestions: `docs/dialogue/critic_oct31/suggestions_01.csv` (22 rows; `tools/dialogue_critic_check.js --check` passes 22 of 22).

## Critique

### Prologue (Opening Forest, Forgotten Cave, cave mouth)
- **Works:** this is the best-written stretch in the chunk. The Wanderer is short, physical and dry ("...Cold. Leaves in my mouth. Great
  start.", "Two hands, one of them shaking. I'll start with the other one."). The Rescuer tells the plot as action and slips one guarded
  hint ("Hold out your hand like you used to... never mind, just your hand", row 11). The Warden's "You hit like someone I knew. Small.
  Stubborn." (row 31) is a quiet clue that needs no help. The kettle handoff from the Warden (row 34) to Maren (row 35) is a neat callback.
- **Flat or missing:** the treeline stop lines (rows 20-21) are the one place the game can name the way to the cave and they don't; the
  earlier Critic #1 note is folded in. Row 19 "I never even asked their name" is fine but slightly soft; left alone because he can't know her.
- **Direction:** good after the cave: Maren names Sable, Tilly and Pip and the card to buy (row 41).

### Crosspath: Maren and Brannoch
- **Works:** Maren is the strongest recurring voice in the game: pie as deflection, "1987", "dependable at a speed you can barely
  measure", "Further questions require fieldwork", "I keep wanting to curtsy. My knees have voted against it." Very few rows need help.
- **Flat:** the first-greeting history (row 66) is a list with no turn, and Brannoch's capital offer (row 80) repeats the same list in
  nearly the same words, which breaks his "Hm., a fact, one tender sentence" shape. I rewrote Maren's (the first one the player hears) and
  left Brannoch's because rows 81-82 depend on his mapping (Blackout/Famine/Restless Dead/Clutter in the same order). Row 71's "Some of them
  would, if {villain} let them" doesn't parse as a joke.
- **Brannoch** is otherwise right: "came back. Best two words I know." and the open gate land quietly.

### Crosspath: the six vendors
- **Works:** each vendor has one obsession and it shows: Bertram's numbered protocols ("I am very good at counting to zero", "Do not run
  with it"), Fenwick's "collector, not a strong person", Pip's "a size braver than your right", Tilly's colours, the red flask. Cover the
  name plate and you still know who is talking, except in the tutorial boxes.
- **Flat:** the tutorial/rule boxes drop the voice: Sable's row 89 could be any shopkeeper, Alembic's essence rule (row 142) reads like a
  tooltip. Tilly's return line (row 95) opens with a misparse ("Potions and charms, back for more!").
- **Continuity nit:** Bertram's bark (row 432) cites Protocol One for the drawer, but Protocol One is the gait check (row 46).
- **Missed:** none of the vendors notices the four-colour glow (the voice bible seeds one per vendor); I gave it to Alembic's bark.

### Store Room ghosts
- Strong all the way through ("With ninety years' interest, it is still four copper. We did the maths. We had time."). Only change: the
  locked-door narration repeats "not open for business", which also appears on the cellar hatch and Bellows' unlock line.

### The Undercroft (Bellows, arena tiers, events)
- **Works:** the loud/small rhythm ("IN THAT CORNER: ME! (normal voice) Hello.", "There is a rope.", the echo that believed in you first).
  Blurbs are good ("the armor has enough room for its own audience", "does not like being hit by anything with a heartbeat").
- **Flat:** the replay-win and puzzle-lost results (rows 270, 273) are the only Bellows lines without Bellows in them. The soup joke is used
  twice (bark row 441 and the Marshal's intermission row 258); the bark now pays off the moustache instead.

### Rip Tearson and the Beefcake Rift Express
- **Works:** "We are all very proud of one another and rarely speak", "naming became a cooldown exercise", the D.N.A. memo ("YOU WERE NOT
  AUTHORIZED TO ARRIVE"), the hatch "smells like a hospital" (a good Lab seed). Arrival lines each carry a zone's culture in one image.
- **Flat:** row 304 repeats row 303's information. Row 316 ("lower back does not mean lower universe") is the one Rip line that doesn't
  quite make sense; left for the designer.

### Old Hob
- The first scene is right (cheerful professional, "Paperwork. Heh."). The repeat scene (rows 403-404) reuses the first scene's answer
  word for word; suggested a variant that knows it's a repeat.

### Quest Log and UI
- Clear, names places and things, keeps numbers. No changes needed. The quest summaries even carry small jokes ("Everyone gets the
  trophy") without hiding the objective.

### Barks
- Maren, Brannoch, Sable, Pip, Fenwick, Brindle and three of the four townsfolk barks are good. The fourth townsfolk bark ("Lovely day for a
  quest") is generic; it now carries Primm's clean wells (his real reform) plus the watched town.
- The gatekeeper barks are labelled "(corrupted)" but several read as freed voices (see Design notes).

## Scores (current lines, before suggestions)

| Area | Writing | Humour | Worldbuilding | Reason |
|---|---|---|---|---|
| Prologue (forest, cave, cave mouth) | 8 | 6 | 7 | Tight, physical, good clues (glow, "hit like someone I knew"); humour rightly light; treeline lines lack direction |
| Crosspath: Maren and Brannoch | 8 | 8 | 7 | Maren is the game's best recurring voice; one list-style history dump told twice |
| Crosspath: vendors and ghosts | 8 | 8 | 5 | Every vendor memorable; tutorial boxes lose the voice; little lore beyond the Wellspring and Fenwick's packs |
| The Undercroft (Bellows, arena) | 7 | 7 | 6 | Loud/small rhythm works; two results lines flat; soup joke used twice |
| Rift Express (Rip and cousins) | 7 | 8 | 5 | Funny and consistent; some repeated instruction; zones' flavour comes through arrivals |
| Old Hob | 8 | 7 | 7 | Death-took-a-job told lightly; repeat scene duplicates text |
| Quest Log and UI | 8 | 5 | 4 | Clear and direct; humour not expected here |
| Townsfolk and gatekeeper barks | 6 | 7 | 5 | Good gossip, four plinths clue; one generic bark; gatekeeper bark states unclear |

## Best 5

1. `intro_story.tres::town.elder.first::1`
   - Before: "Ten years ago {kingdom} was whole. Beefcakes made the energy, Gourmands fed us, Necrocrats minded the dead, Refusemancers hauled the waste and grew the crops."
   - After: "... Refusemancers hauled the waste and grew the crops. Everyone complained. Everything worked."
2. `npcs.json::NPC-TOWNSFOLK.barks::0`
   - Before: "Lovely day for a quest, isn't it? Shh. Not too lovely. Somebody's listening."
   - After: "Say what you like about His Perfection, the wells are clean. Shh. Don't, actually."
3. `intro_story.tres::town.elder.idle::0`
   - Before: "Still here, dearie? The roads won't walk themselves. Well. Some of them would, if {villain} let them."
   - After: "Still here, dearie? {villain} would love you to sit by my fire forever. Don't give him the satisfaction. Give me back my chair."
4. `npcs.json::NPC-BELLOWS.barks::1`
   - Before: "IN THIS CORNER: MY LUNCH! (normal voice) It's soup. The soup is winning."
   - After: "IN THIS CORNER: MY MOUSTACHE! (normal voice) Undefeated. Eleven years. Same as me."
5. `intro_story.tres::town.arena.locked::1`
   - Before: "Whatever is down there is not open for business. Yet."
   - After: "Somewhere below, very faintly, someone is rehearsing the word CHAMPION. Not yet, apparently."

## Flavour inventions

- Bertram's **Security Protocol Three** covers the drawer (one to fill an unused number; One is the gait check, Two referral, Four the
  outskirts, Seven inventory, Twelve report to Maren).
- Alembic's flasks **bubble in every colour** when the Wanderer passes (the four-colours clue; nothing more is explained).
- Bellows' **moustache is "undefeated" for eleven years**, matching the Marshal blurb's "has not lost a bout in eleven years".
- Townsfolk credit Primm with **clean wells** (already canon as one of his good early reforms; only the bark is new).
- "The camp" in the forest (from the earlier suggestion for row 20): please confirm the clearing's lantern spot is read as a camp and that
  the cave is north-east of it; otherwise drop "north-east of the camp".

## Design notes

1. **Gatekeeper barks in Crosspath** (rows 442-449) are labelled "(corrupted)" but Brick's ("Sorry, am I ordering again? I meant we could do
   them together") and Moss's ("Did I thorn at you?") read like their freed voices, and Pallor's "Old habits die hard" works best after
   freeing. Corrupted Brick should be ALL-CAPS slogans by the voice bible. Question: are these barks shown before or after the gatekeeper is
   beaten? If before, they need corrupted versions; if after, the labels in the export are wrong.
2. **The history list is told twice** (Maren row 66, Brannoch row 80). Consider cutting Brannoch's to the services only ("Lights, kitchens,
   graveyards, bins. {villain} chained all four.") once you are sure the Blackout/Famine/Restless Dead/Clutter line still maps clearly.
3. **Only four townsfolk barks** carry Crosspath's whole "watched town" mood. The voice bible's seeds would fit as new barks (not line
   edits): a rivalry line ("A Beefcake and a Necrocrat argued at the fountain about whether 'about noon' is a time"), Old Hob's quiet
   competence, a "Royal Asset" poster as a lost-property notice, a cousin who went up the Capital road.
4. **awakening_lines "cut to about six"**: only three awakening lines are in this chunk and none carries an earlier note; nothing to cut here.
   If the note refers to another file's longer list, it belongs to that chunk.
5. **Old Hob repeat scene**: if `hob_town` can play many times, consider rotating 2-3 answers rather than one fixed reply.
6. **Rip row 316** ("lower back does not mean lower universe") reads as nonsense rather than a joke; worth a look by the designer.
7. **Spelling**: row 44 uses "four colors" (a tested phrase) while every other line uses British "colour"; the test pins it, so it would need
   a test change to unify.
8. **Row 223** must keep "Lunch Rush", but the line has it in lower case ("The lunch rush"); presumably the test is case-insensitive.
9. **"Not open for business"** appears three times in town text (rows 97, 127, 151); two suggestions vary it.

## Counts

- Rows read: 454 (all; Fig Sly rows 123-124, 194-197, 204-206 skipped as locked).
- Suggestions: 22 (about 5 percent; the chunk is roughly a third UI/rule/name rows and the comedic lines are already strong).
- By priority: High 5, Medium 10, Low 7.
- By category: Humor 8, Clarity 4, Voice 4, Worldbuilding 3, Natural 2, Fix 1.
