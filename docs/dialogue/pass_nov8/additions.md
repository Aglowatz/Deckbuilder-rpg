# Nov 8 story pass: new dialogue boxes

The rewrites of existing lines are in `edit_rows.csv` (58 rows, Current line copied exactly from `export_before.csv`). This file lists the
three boxes that need a new slot. Each one is a plain line of 230 characters or fewer. None of them needs a code change: two are an extra
line on an existing key, and one is an extra step in an existing scene.

## New boxes

1. **The Wanderer reacts to Memory 4, then absolves Maren**
   - File: `data/story/intro_story.tres`
   - Key: `memory.4.reply`. Append as line index 1, after `data/story/intro_story.tres::memory.4.reply::0`.
   - Speaker: the Wanderer. `town_scene.gd` `_after_memory` plays the whole key with `NpcRegistry.PLAYER_ID` (NPC-PLAYER).
   - Text: `You built the glass, Maren. You also gave me a bed and pie when you still thought I might be a spy. I know which of those I'm keeping.`
   - Context: `memory.4.reply::0` is rewritten in the CSV as his reaction to the reveal (his mother's voice across the courtyard, a face he
     can't see, wanting to know what his parents were like). This new line is the absolution, so he reacts first and forgives second.
     `memory.4.after2` ("...Then let us make the kingdom a home again") follows as before.

2. **The ending notices that Elowen is missing (the hook into "Under the Forest")**
   - File: `data/story/capital_story.tres`
   - Key: `ending.beat.10`. Append as line index 3, after `data/story/capital_story.tres::ending.beat.10::2`.
   - Speaker: narration. The ending screen shows no name plate; Maren's words are a quotation inside the narration, as in `::2`.
   - Text: `You look past her for a hood with leaves caught in it, and it isn't there. {rescuer} is still in the Path-ology Lab, under the forest where you woke. 'Eat first,' Maren says quietly. 'Then go and fetch her home.'`
   - Context: the reunion still (`intro::still.reunion::2`, rewritten) shows him looking for her in the crowd and not finding her. This
     line names where she is. She is named at the castle gate (`pc_capture`, which sets `rescuer_named`), so `{rescuer}` and "Path-ology"
     are both already revealed here. The Lab stays postgame: nobody goes there in the ending. Rip's forest tip (`travel.forest_tip::4`,
     rewritten) then links the hatch to "your friend from the castle gate". The Quest Log text for "Under the Forest" is unchanged and
     still names neither Elowen nor Path-ology.
   - Length: beat 10 becomes about 630 characters across four lines, about the same as beat 8 (four lines, about 600). Check it with a
     beat shot (`tools/beat_shots.gd -- --only=epilogue` or the ending run) in case the text panel needs a smaller font.

3. **Clipwell refuses and walks away**
   - File: `data/story/story_scenes.json`
   - Key: `scenes/clipwell_lawn`. Add a new step after `steps/6` (the scene's last step), at index 7.
   - Speaker: `""` (narration).
   - Text: `She walks away down the exact middle of the path. She does not look back at the seedling, and it goes on growing without her permission.`
   - JSON: `["", "She walks away down the exact middle of the path. She does not look back at the seedling, and it goes on growing without her permission."]`

## Notes

**The climax (`primm_end`).** The Wanderer's line of his own is `cutscene.primm_end.3::1`, which is also used in `.rushed::1`: "You took my
mother and father. Then you kept me behind glass for ten years, and every morning someone said 'again'..." It comes from Memory 2, not from
a mentor. There is no "I'm letting it go". Primm answers in `primm_end.4::0-1`, in his own register: the parents were "sentimental", he
"removed two people so that eleven thousand could be safe" and "did the sums twice", and the boy was fed at seven, noon and six and "never
once cold. Tell me which part of that was unkind. I should like it in writing." The Wanderer does not answer (`primm_end.5::0` opens on
the silence), then says outright that he won't forgive him "not today" (`primm_end.6::0`). The hats line stays, but Primm now hears that it
is the wrong thing and says he never learned how to say the right one (`primm_end.8::1`). The lesson lines that the tests check keep their
phrases ("strength is not control", "treating people with respect", "nothing grows", "blank page" in the `.gourmand` variant). They are
now told as things he saw (Flex lifting him after ten years without weights, the Chef giving her name away, the field where nothing could
die), so they no longer read as quotations.

**The castle opens.** In `ending.beat.1::0` every locked door in the castle swings open; `ending.beat.8::0` says the floor under the Model
Room "opens too". I found nothing else that says the castle falls: the facade, the model and the portraits still fall, and so they
should. `ending.beat.8::3` no longer says "everything comes back at once ... the name", which repeated Memory 4. The Throne "says your name
back to you, {prince_full}" and brings the Paths, so the line works on both routes (Memory 4, or Primm's reveal), and `{prince_full}`
stays in beat 8 for the test.

**The beat 10 speaker tag.** The export tags `ending.beat.10.title` and `ending.beat.10::0-2` as "Agnes Overdue". The beat is narration
(the stamp, Maren pushing through the crowd), and the quoted line is Elder Maren's. The tag is not in the game files: `capital_story.tres`
has no `.speaker` for ending beats, and the ending screen shows no name plate. It comes from the Oct 21 export's speaker map, which
`tools/export_dialogue.js` reuses (`priorSpeaker`). In the CSV the changed row `ending.beat.10::2` carries `(narration)`. To make the export
show the right tag for `.title`, `::0` and `::1` as well, fix the speaker map entry for `capital_story.tres::ending.beat.10`.

**Maren is not the first.** `ending.beat.10::2` now says she has said his name in her kitchen and that this is the first time she says it
to the kingdom. The test phrase `'{prince},' she says` is kept.

**Lieutenants.**
- **Crumb** keeps his menial-job redemption ("...Yes, Chef.", unchanged).
- **Quota is arrested** (`quota_yards_after`). Rollo's crews hold her for Flex's people, because some of the wheels had children on them.
  She is "detained" and will time every minute of it, and on the way out she stops clicking the stopwatch.
- **Clipwell refuses.** Old Fern still offers the compost rows. Clipwell turns them down ("I will not be forgiven by a compost heap") and
  walks off (new box 3). Her "I gave her the seed because she was crying" is kept.
- Primm's captivity now carries weight (`freed_npc.primm::0`): every morning he reads the list of the eleven thousand people he corrected,
  and he is on the third page. "water main" and "not permitted" are kept for the test.
- `docs/design/story_bible.md` still gives Quota the break schedule and Clipwell compost duty (the lieutenants table and the
  `quota_yards_after` / `clipwell_lawn` notes). Update both once this pass is applied.

**Other fixes in the CSV.**
- **"Never once asked her"** (`pc_capture/steps/9::1`): "I asked her twice, and both times she said 'a friend', and both times I let her."
  This matches `prologue.rescuer.2::0` and `cave_mouth_1/steps/3::1`.
- **Prince hints (F7).**
  - Cut two: Old Man Mountain's "four colours ... you've a look of him" (the dumbbell story stays, because Elowen calls back to it) and
    Bramble's glowing young man carried through the woods (his twelfth tree stays).
  - The surviving hints now show the Wanderer reacting. Maren ("Don't look so startled"), Basil ("You've gone pale"), Agnes ("You've gone
    very still ... when the form is about them") and Bramble ("as if you've stood there before") each notice it. The Records Labyrinth
    beat ends with him holding his breath.
  - At cave mouth 3 he asks Elowen outright, with the hints in mind.
  - The NPC dialogue keys in the zone `.tres` files have one speaker each, so his reactions are shown through what the speaker notices
    rather than as his own boxes.
- **Primm's confession (F8)** (`primm_p2.3::1`): he built them, they were good, then he put his name on every one and stopped asking anyone
  whether they wanted the next. `primm_reveal.5::0` now says his power kept "the Paths in one shape", not "this kingdom lit".
- **Gerald (F11).** Hob says Gerald's number came up and he asked to stay for one more pot; Gerald says the same. This is consistent with
  `npc.barnaby.intro.freed` and the vacancy queue.
- **Maren (F12)** (`maren_after_capture/steps/1::2`): "the day she sent you through my cave".
- **Kestrel (F14).** She now says up front that the gate is the only way in for strangers and that she shows her older way only to friends
  of Wren's. The order is: get past Spotless's gate, knock at the manhole, ask Wren, come back for the hatch. The Quest Log summary
  (`side_quests::13`) matches. Quest steps and targets are unchanged.
- **Bramble (F23)** (`marigold.return.freed::1`): "Nobody's apologised for the compost". This is true whether or not the Trash Panda quest
  is done.
- **The Tuesday rule (F6).**
  - Planted in `memo.hr::1` ("Nothing is filed on a Tuesday (Rule 1)") and on the Rec Room sign (`sign.matching::1`).
  - Kyle now filed the transfer, which "the peacock drafted", on his way to the rec room, "so... a tuesday" (`npc.matching.intro::2`).
  - The note under Mortimer's pile is in "a junior clerk's handwriting: FILED ON A TUESDAY. SORRY. - K."
  - Plume now "had a clerk file it" (`pc_plume_memo/steps/2::2`, `plume_ribbon/steps/3::1`), so Plume drafts it and Kyle files it.
- **Beat 6 (F10)** is now one concrete image: the four Paths hanging a sign together and arguing about where it goes. It cannot be cut
  outright, because `test_ending_postgame.gd` needs "one way for everyone" and "Different Paths, working together" somewhere in the ending
  beats, and `test_finale_v2.gd` expects 10 beats. Both phrases are kept inside the image. `ending.postgame.body` drops "What made the
  kingdom strong was never sameness" and ends on the Lab hook ("And under the forest, someone is still waiting for you").

**What I didn't do, and why.**
- **Branching beat 8 between the memory route and the reveal route** needs code (EndingDefs has no variants). I rewrote the line so that it
  is true on both routes instead.
- **Separate Wanderer boxes after each NPC hint** need speaker support in the zone `.tres` NPC keys (one speaker per key). The NPCs react
  to him instead, and he gets his own question at cave mouth 3.
- **`{rescuer}` in `ending.postgame.body`.** The importer rejects any change to a line's tokens, so that line says "someone". The new beat
  10 box, which has no existing tokens to match, uses `{rescuer}`.
- **Protected-phrase check.** The `critic_oct31/protected_phrases.json` hits on the changed rows are generic substrings ("The Capital",
  "Someone", "The Crease", "A Name", "The Model Room", "Gainlands"), and I checked that the tests they cite do not read these lines. The one
  real constraint I found, "blank page" in `primm_p2.2.gourmand`, is kept.
- I didn't run the Godot box-fit measure. Every line is at most 209 characters; the longest is `primm_end.4::0`.
- I didn't touch the F13, F15-F22 and F24 items. They were outside this brief.
