# Critic notes, chunk 06: Crosspath between zones, the Ending, the Postgame

Suggestions: `docs/dialogue/critic_oct31/suggestions_06.csv` (23 rows; `tools/dialogue_critic_check.js --check` passes 23 of 23).

The headline: this chunk is mostly very good, and its main weakness is not the original writing but the Oct 21 ChatGPT pass, which
flattened the ending (review_flags.md items 5-8, 18, 21, 22) into "You see... / You watch..." narration. Most of my 23 rows put back the
specific detail it removed, rewritten where needed (present tense for the still, `{showcase}` for the literal name, "the Crease" kept for
the tested phrase). The Lab, the memories, Isla and the royal funeral are left almost untouched on purpose.

## Critique

### Crosspath between zones (memories, cave mouth, Maren idles, Old Well, Old Hob, Restless Cairn, quests)
- **Works:** the memory fragments are the best sincere writing in the game: "Then the light thins, like breath on glass, and I am back."
  (2694), "Again. Again. Again." / "I wasn't lost. I was kept." (2718-2719), "I know that man's face. I have always known it." (2743). Leave
  them alone. Memory 4 (2765-2771) lands the tortoise-house line and the Wanderer's "a bed and pie when you thought I might be a spy".
- **Cave mouth scenes** are excellent and need nothing: the pencil sharpened with a scalpel (2706), "Four of them. Next question." (2737),
  the boy who ate the frosting off every layer (2757), "Too many people around here say things before they're certain." (2755).
- **Maren's idles** keep the voice (one slice per zone, "I complain about it every morning and mean none of it", "a lot of feelings").
  One misfire: "holding its breath. It's murder on my knees" (2749) does not connect; suggested a tortoise breath-holding turn.
- **Flattened by the earlier pass:** memory 2's confession lost "I am not only a tortoise who bakes" and "Mostly." (2721, 2723), which
  were her stage-2 voice; memory 3's "hiding here ever since" (2747) lost its image. For 2747 I did not restore the pie-dough joke as a
  joke (no pie punchline over the lab guilt) but kept the image sincerely: the hands in pie dough are the hands that blew the glass.
- **Old Well:** the Well's own voice is right (slow, plural, no jokes). The narration lost two of its three running gags (the boot the
  water goes "politely round", 2798; "first, water" framed as "You recall", 2802) and the Wanderer's closer lost "Fine." (2823).
- **Old Hob:** "Gerald's number came up. Lovely chap. Brought his own mug." (2676) is exactly the "funny once you know who he is" register.
  Only two barks in this chunk, both fine.
- **Restless Cairn:** spare and right. No change.
- **Quest Log / direction:** clear throughout (Fragments, The Door Under the Well, Four Seals all name place and thing).
- **Earlier suggestion on 2778** (Maren and "the tortoises"): not taken. The line reads as self-mockery (she barely passed a tortoise, i.e.
  she is slower than one) and works better now that she visibly is one.

### The Forgotten Vault (and the town secrets: Shiro, the Four Seals)
- **Works:** the Automaton is dignified and on-model ("Tick. ...Recognised. Four Paths. One kingdom. Carry it well."; "a sound like a very
  old clock remembering the hour"). The Warden of the Four Seals' "The Paths agreed to bury this. They also agreed you might come." is the
  right dry note. Shiro's log "I gave it my eyebrows." is the best battle line in the chunk.
- Maren's "Look at the bow: four little carvings, in a ring. Hm. Never mind." (2879) is a model crest clue. No suggestions.
- The Warden's one dry closing line lives in `vault_guardian.gd` and is not in this chunk.

### Ending
- **Works (original):** the throne beat (4019-4022) is lyrical and exact; "Cracked streets. Real faces. A boy he kept in a cell." (4025);
  the royal funeral is the emotional peak of the game and is perfectly pitched: Hob digging slowly "so they could be visited properly",
  Agnes tearing up the third form "with great pleasure", the King and Queen's two lines, the lullaby "and does not need to finish it",
  the top hat bobbing away (4053-4067). Isla's homecoming is strong ("Isla. Not yet." / "Today it says 'home'.").
- **Flattened (the earlier pass):** beats 1, 2, 4, 5, 6, 7, 10 and the reunion still now say "You hear / You see / You watch" and describe
  instead of showing. The worst losses: the four Paths arriving in character (3978), the thesis line before "The point was the argument"
  (3982), the decree with a pigeon on the full stop (3986), the drawer-sound collapse (3963), Maren "tortoise-slow" (4029). All restored.
- **Beat 8's title** reads "the Pathwork Throne" in lower case (4018): fix.
- **Agnes's freed line** (4006) lost the "Irregular." payoff of her whole arc; restored for the first box, the sincere "I have wanted to
  for a very long time" box kept.
- **Isla** (4050): "Dad says a lot, actually" contradicts the man who has just said "Hm."; suggested reading his "Hm" as the thank-you.
- **Primm postgame** is right ("I find that I miss the wells."). The guard's second line called himself "the guard" (4035).
- **Credits** are placeholders ("PLACEHOLDER CREDITS", Kenney/KayKit). The three dedications (3994-3996) are near-identical; I restored the
  two jokes (Form 27-B, hats) as Low.

### Postgame (Crosspath/forest lines after the ending)
- Maren's postgame ("I have never been so glad to be annoyed") and the Rescuer's ("She let him have one slice of pie. One. I've never seen
  him so frightened.") are spot on. Rip's postgame "went exploring" tip is not in this chunk.
- `ending.postgame.line.2` (4076) shows a dev note to the player: "(no tri-Path recipes exist yet)". See design notes.

### Mount Swolympus
- Strong. Old Man Mountain trails off correctly ("I spilled one, the Festival year... where was I."; "Rule two... rule two was water."), and
  the Ancient Spotter's ending is one of the best small payoffs in the game: "for the first time in a thousand years, sets something down"
  / "'...That was the one. Thank you for coming up.'" "Never lift alone. Not even me." is the right gag at the right time. No suggestions.

### The Path-ology Lab
- **Works:** the horror is in the ordinary, as the bible asks: the WORLD'S OKAYEST PATH-OLOGIST mug, the "cooperative?" column filled
  with "asks for his mother", the half-written resignation letter, "They were only ever as strong as the people who buckled them." Cell 4
  is perfect and tested ("ten years of tally marks", "Took you long enough, Tess."). Siphon is clinically cheerful in exactly the way the
  bible wants ("The draining has been very good for your posture", "It made you a poor scientist and a lovely daughter", "She thinks she
  rescued something"). His defeat image ("like a man who has dropped something very small") and "I called a great many things sentiment."
  are excellent. Elowen's "If you're kind to me now, I won't be able to walk in there." is the best line of her arc.
- No line suggestions: every candidate would have been merely different. See design notes for token and continuity issues.

## Scores (current lines)

| Area | Writing | Humour | Worldbuilding | Reason |
|---|---|---|---|---|
| Crosspath between zones | 8 | 7 | 8 | Memories and cave-mouth scenes are top quality; Maren and the Well narration lost some voice to the earlier pass |
| The Forgotten Vault | 8 | 7 | 8 | Dignified Automaton, a perfect crest clue from Maren, Shiro's eyebrows |
| Ending | 7 | 6 | 7 | The throne, funeral and Isla are superb; seven beats flattened into "You see" narration and the four Paths' character lost |
| Postgame | 8 | 8 | 7 | Maren and Elowen's postgame lines land; one dev note shown to players |
| Mount Swolympus | 9 | 8 | 8 | Mountain's trailing voice and the Spotter's "That was the one" payoff |
| The Path-ology Lab | 9 | 9 | 9 | Ordinary horror done right; Siphon's cheer is chilling; humour correctly near-absent, scored as right for the beat |

## Best 5 (before / after)

1. 3978 Ending, beat 5: "You watch the four Paths gather around their leaders, carrying what they have saved from the past ten years." ->
   "The Beefcakes are late. The Necrocrats have brought a form. The Gourmands are overdressed. The Refusemancers smell, faintly, of compost."
2. 3986 The New Decree: "You read the changes beneath it: MAY crossed out for SHOULD, then WILL, IF THEY FEEL LIKE IT. Four hands have left
   their marks." -> "Somebody has crossed out MAY and written SHOULD. Somebody else has crossed out SHOULD and written WILL, IF THEY FEEL LIKE
   IT. A pigeon sits on the full stop."
3. 3982 Together: "You see hands marked by iron, flour, ink and soil reach across the space between the four groups." -> "Muscle and stoves,
   records and soil: each was good alone. Together they ran a kingdom, argued about it every day, and it worked."
4. 2747 Memory 3: "I have been hiding here ever since." -> "I have been hiding here ever since, with my hands in pie dough, where nobody
   would ask what else they had made."
5. 4006 Agnes, freed: "Thank you, dear. I have written it down, though that hardly seems enough." -> "I have filed a Form of Gratitude,
   dear. It was approved on the first attempt. Irregular."

## Flavour inventions

- Maren can hold her breath "for a week" (2749): a tortoise trait, light idle line only.
- "A Form of Gratitude" (4006) and the pigeon / drawer / "tortoise-slow" images are restorations of earlier authored text, not new lore.

## Design notes

1. **Literal names in story files (need a token; the check tool rejects token changes, so not filed as rows):**
   - `story_scenes.json::scenes/lab_study/steps/3::1` (4150): "Elowen..." should be "{rescuer}...".
   - `story_scenes.json::scenes/lab_siphon/steps/2::1` (4192) and `lab_siphon_after_alone/steps/5::1` (4201): "Crosspath" should be
     "{town}".
   - `dungeon_content.json::event.lab_cell4.body` (4140): "Elowen" in a non-`dungeons/` key; should be "{rescuer}" if that key is
     token-expanded.
2. **Dev note in player text:** `ending.postgame.line.2` (4076) says "(no tri-Path recipes exist yet)". Either add recipes or cut the line
   until they exist; I did not rewrite it because a cleaner line would promise something that is not there.
3. **Continuity (Lab, alone path):** `lab_study_alone` (4154) has the Wanderer say "Her father held the door." If he skipped Cell 4, does
   he know at that point that Siphon is her father? Plume names her "Elowen" at the gate; check whether the gate scene also says whose
   daughter she is. If not, use "Siphon. He held the door." there.
4. **Credits** (3989-3996) are still placeholders ("PLACEHOLDER CREDITS", "Design and direction: you"); my two credit rows are Low and
   only matter if the jokey credits survive into the real list.
5. **2668 (Gainlands freed body)**: current "Gary lifts with a spotter" is a better payoff than the pre-pass "nobody has to spot him"
   (which contradicts "never lift alone"); left as is.
6. **4081** "You came for me. Twice, if you count the woods." In the woods she rescued him, not the other way round. If the intent is
   "the castle gate and the Lab", the designer may want "Twice, if you count the gate." Not filed: I am not sure what the second time is.

## Counts

- Rows read: 500 (Crosspath between zones 243, the Forgotten Vault 14, Ending 111, Postgame 21, Mount Swolympus 15, the Lab 96).
- Suggestions: 23 (4.6%): Crosspath between zones 7, Ending 16; Postgame, Swolympus, Vault and Lab 0.
- Priority: High 8, Medium 10, Low 5. Category: Voice 6, Story 5, Humor 5, Natural 5, Worldbuilding 1, Fix 1.
- Restorations of lines flattened by the Oct 21 pass (applied_ledger.json "before" text, often rewritten): 21 of the 23; new: 2749, 4050.
- Check: 23 of 23 pass.
