# Critic notes 08: Primm's Castle and the Capital after freeing

Chunk: `chunks/08_castle_after.csv` (469 rows). Suggestions: `suggestions_08.csv` (46 rows, all pass `dialogue_critic_check.js`).

## Critique

### Primm's Castle (rows 0-346)

The strongest writing in the game is here, and most of it should stay exactly as it is. The Path-ologists' records ("You read the word
Subject until it stops being a word." / "You have seen that handwriting on a pie recipe."), the Private Gallery ("KEPT FOR REFERENCE. The
boy has your face."), the Last Journal ("I do not think anyone has ever tried so hard to be kind. I only wish somebody would say so."), the
Corrector's "I never once asked what was wrong with them", the clipboard margins in a shakier hand, the Staircase Guard's "By seventeen
people", Plume's "I used the active voice" and the whole of `primm_end` are finished lines. Keep.

The weakness is almost entirely one thing: **the Oct 21 ChatGPT pass flattened this area**, exactly as `review_flags.md` (flags 4, 9, 10, 13,
14, 15, 21, 36) describes, and none of those flags have been reverted. The tells:

- "You see / You face / You stand" narration where an image used to be: `pc_curator.blurb` ("You see a curator patrol..."), `pc_clerk.blurb`,
  `pc_staircase.blurb`, `boon.beefcake.line`, `boon.gourmand.line`, `still.primm::0-2`, `pc_boss.after::0` ("The table no longer holds a
  kingdom" replaced "all in the wrong places, and somehow they look better", the game's thesis).
- Primm made generic. `primm_intro.6` "Please remain still. I know how to put this right." is any villain; "This will not hurt. It will,
  however, be Standard." is only him, and names Phase 1. `primm_intro.4::2` lost the faintly proud question that makes numbering people a gift
  in his eyes.
- The Wanderer's answers turned into theses. "People are different. You know that." no longer answers "Why must anything be five?"; "I'm
  not your subject" drops Agnes's callback ("nobody files me under 'subject' again"); the rushed `primm_end.3::1` explains letting go
  instead of doing it. His first words to Primm ("Sorry. That's forest mud.") were his voice; now he has none.
- The "they are so good" motif (journals + blueprints) that makes Primm tragic was replaced with summaries ("Page after page describes work
  that helped people").
- The clipboards lost their accidental comedy, which is the only humour the dial allows here: Flex "does a lot of stretching" (quoted in
  the story bible itself) and the sauce making Gourmands "less themselves".

Small fixes found: `pc_wing_gourmand.before::2` and `pc_wing_beefcake.before::2` open a second `'` inside a note already opened in `::1`;
`pc_plume_memo` step 0 says the archive "is filing from floor to ceiling".

Things I deliberately kept: `pc_wing_refusemancer.before::3` ("I believe she will thank me") is better than the pre-pass line and rhymes
with the Last Journal; `pc_corrected_citizens.result.0::1` ("you repeat their names to yourself") is better than its original. The
rushed-reveal and phase rules are untouched.

### The Capital after freeing (rows 347-468)

Good bones: the signs ("Under new management. The new management is: all of us, arguing."), Spotless weeping at an approved-height man,
Aldous, Berta saying her name three times, the citizen who "looked away for a whole minute", Wren's footnote line, the exit guards' "A door.
A good door." The sincere freed slips (citizens 4, 5, 9) are right and stay.

What is missing is **payoff**. The voice bible says freed announcements should undo each setup, and the freed citizens should be giddy and
crooked; the Oct 21 pass sanded the giddiness into reasonable sentences ("Spontaneity is no longer limited to Thursday. You may disregard
this reminder.", "A hat of any size. I keep looking up, trying to decide.", "I kept trimming the corners, and then I wondered why I wanted
corners."). I restored the crooked versions and tied the broadcasts to their own setups: the weather is no longer approved (Plume's
running gag), stop rehearsing your surprise, "please thank anyone who exists". Marlo's "Everything in its proper place, at last" is the
regime's value in a liberated mouth (flag 12) and should go. Pell's return line repeats her intro.

The guard who "keeps almost asking permission to go for a walk" states the running gag as a sentence; it should be performed.

### The capture aftermath (rows 459-468, Maren and Wren)

Strong. Maren's 1987 callback and "Somewhere with glass walls and no windows" are exactly right. No changes.

## Scores (current lines)

| Area | Writing | Humour | Worldbuilding | Reason |
|---|---|---|---|---|
| Castle: wings, gallery, ward, last journal | 9 | 7 | 9 | Specific, lyrical, clue-bearing; two clipboard jokes lost to the Oct 21 pass |
| Castle: node blurbs and events | 6 | 5 | 7 | Many "You see/You face" flattenings; the honest mirror, staircase and garden events are good |
| Primm fight cutscenes | 7 | 6 | 8 | `primm_end` and phase 2 are excellent; intro and phase-1 answers made generic; callbacks lost |
| Boons and stills | 6 | 4 | 7 | Character images replaced by description; Agnes and the Grand Chef lost their voices |
| Capital after freeing | 7 | 6 | 7 | Signs, Aldous, Berta strong; several freed payoffs flattened into reasonable cheer |
| Capture aftermath (Maren, Wren) | 9 | 7 | 9 | Tight, in voice, sets up the Lab |

(Humour is judged against the dial: near-silent in the castle, warm and giddy after the fall.)

## Best 5

1. `cutscene.primm_intro.6::0`
   Before: "Please remain still. I know how to put this right."
   After: "This will not hurt. It will, however, be Standard."
2. `cutscene.primm_p1.2::0`
   Before: "People are different. You know that."
   After: "Because some things are five. Some people are."
3. `dungeon.pc_boss.after::0`
   Before: "You stand among the pieces of the model. Tiny houses lie scattered across the floor. The table no longer holds a kingdom."
   After: "The model lies in pieces. A hundred thousand tiny houses on the floor, all in the wrong places, and somehow they look better."
4. `facade.speaker.1.0.freed::0`
   Before: "Attention, citizens. (a cough) This is a loudspeaker. Nobody is on the other end."
   After: "Attention, citizens. (a cough) The weather is no longer approved. It is just weather. It seems to be managing."
5. `dungeon.pc_wing_beefcake.before::2`
   Before: "'When the champion is weak, he will no longer be a disagreement. NOTE: he continues to train without the weights. Observe carefully.'"
   After: "When the champion is sufficiently weak, he will no longer be a disagreement. NOTE: do not underestimate him. He does a lot of stretching.'"

## Flavour inventions

- The reading-room lampshade is homemade and "a little crooked" (Primm's private room; no lore weight).
- Freed citizen 1 plans to wear two hats at once (callback to Approved Hat Size: 1).
- "Hats of negative size remain under review" (restored from the pre-pass broadcast, wording tweaked).

Everything else in the suggestions is a restoration of pre-Oct-21 text or a direct payoff of an existing setup.

## Design notes

1. **Most of this chunk is a revert job.** About 37 of the 46 suggestions restore (sometimes tighten) lines from `review_flags.md`. If the designer
   agrees with the flags, `node tools/apply_dialogue_pass.js --revert=...` with those ids does the same thing faster; my versions differ in
   a few places (present tense in `still.primm`, no literal "His Perfection" in `pc_four_wings`, "Watch." instead of "Watch how it's done."
   so the Wanderer never gloats over a broken man).
2. **Speaker column mismatch:** `cutscene.primm_p1.2.rushed::0/1`, `primm_p2.2.rushed::0/1` and `primm_end.3.rushed::0/1` are labelled
   'Primm, "His Perfection"' in the edit CSV, but they are the Wanderer's lines. Check the `.speaker` key in `capital_story.tres` for those
   variants; if it says Primm in game, the hero's answers appear under Primm's name plate.
3. **Room name drift:** the boss node title is "The Scale Model Chamber", the warden's lines say "the Chamber of the Model", and the bibles
   say "the Model Room". Not renamed here (rename rule); pick one.
4. **"Eleven" used casually:** `pc_improved_portraits.body::1` makes Primm's last portrait "eleven feet tall". The clue is "my portraits stop
   at eleven" (the prince's age). Eleven also appears as the Corrector's and Primm's "eleven thousand" (deliberate rhyme, fine) and Spotless's.
   Consider "ten feet tall" (ten years) for the portrait so the reveal line stays clean.
5. **Who reads the freed broadcasts?** They are labelled Percival Plume, but `facade.speaker.1.0.freed` says "Nobody is on the other end", and
   Plume is defeated in the castle and later reassigned under Bertram. Either a citizen has the microphone (relabel) or Plume is reading
   freed news with gritted teeth (a strong comic idea: one line could let his spin slip, "Great news, citizens! I have been asked to say
   this."). My suggestion for 1.0 removes the contradiction either way.
6. **"ink still wet" is used twice** (Plume's memo, Primm's last journal). Harmless, but the journal is the one that should own it.
7. **Fig Sly's freed lines** (rows 379-381) are locked and untouched.

## Counts

- Rows read: 469 (castle 347, Capital after freeing and capture aftermath 122).
- Suggestions: 46 (castle 32, after freeing 14). Locked rows skipped: 3 (Fig Sly).
- Priority: High 19, Medium 19, Low 8.
- Category: Story 15, Humor 11, Voice 11, Natural 8, Fix 1.
