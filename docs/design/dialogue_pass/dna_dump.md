# Dialogue pass Oct 19: dna_dump (the D.N.A. and the Verdant Dump)

Writer area `dna_dump`. Files: `data/story/dna_story.tres`, `data/story/refusemancer_story.tres`. Only these two files were edited.
Nothing was committed and Godot was not run.

## Files and key groups rewritten

| File | Keys changed / total | Lines in changed keys | Groups |
|---|---|---|---|
| dna_story.tres | 66 / 226 | 162 | Agnes (`npc.dolores.*`, `quest.dna_backlog.*`, `dungeon.ha_number/ha_forms/ha_records.before`, `freed_npc.agnes`), Gerald (`npc.barnaby.*`, `quest.dna_onboarding.*`), Ledgerbone (`npc.pip.*`, `quest.dna_audit.*`), Kyle (`npc.matching.*`, `match.*`), Ectomund (`npc.quiz.intro`, `quiz.result.4`, `quiz.not_passed`), Mortimer (`dungeon.ha_boss.*`, `cutscene.vacancy.1/.3`, `freed_npc.mortimer`), Vellum (`dungeon.ha_clerk.before`), Prudence (`freed_npc.prudence`), the queue number (`dungeon.ha_lobby.before`, `dungeon.ha_number.blurb`, `event.ha_take_a_number.body/.result.0`, `sign.now_serving`), enemies, a few fx/events |
| refusemancer_story.tres | 56 / 232 | 137 | Bramble (`npc.marigold.*`, `quest.heap_dam.*`), Granny Gristle (`npc.hob.*`, `quest.heap_fert.*`, `fx.wake`), Wren Muckfoot (`npc.wren.*`, `quest.heap_herd.*`), Druid Sorrel (`grow.bridge_center.*`), Thistlewick (`npc.quiz.intro`, results), Rhonda (`npc.minigame.*`, `sort.win/.first/.lose`), workers (`bark.worker_1..3`), the Rotheart (`dungeon.rh_boss.*`, `rh_pool`, `rh_roots`, `rh_soil.after`, `rh_golem.after`), the sever (`cutscene.sever.1/.2/.4`), `freed_npc.compostella`, signs (`sign.exit/.exit.freed`, swap shed) |

Checked with a script against the originals: same key set in both files, the `quiz_questions` blocks and file headers are unchanged,
sign/memo/poster/prop arrays keep their lengths, indexed lists (`puzzle.bins/.souls`, `match.pairs`, `sort.*`) keep their order and
count, `%s` placeholders are intact, there are no banned names, no literal "Primm", and the only tokens are `{villain}`. The longest
changed box is 193 characters in the D.N.A. file and 202 in the Dump file (`enemy.golem`, a description). Most boxes are under 160.
Dialogue arrays changed length only where the code reads the whole array (`get_lines`, `_greeting` + `quest.offer`, cutscene beats).

## Notable fixes

- **C17 queue numbers.** The player is now **4,000,213 everywhere**: Agnes's front-desk intro ("Yours is 4,000,213. We're serving
  number 3."), the lobby ticket (`dungeon.ha_lobby.before`), `dungeon.ha_number.blurb`, `event.ha_take_a_number.body`. This matches
  dungeon_content.json's S-NECRO text, which already used 4,000,213. Gerald now says his own number and "They're on 3" in his intro (he
  never did before). Agnes in `ha_number.before` places you next to Gerald ("You two will be neighbours"). The payoff: Mortimer is 4,000,214
  (`freed_npc.mortimer`, `npc.dolores.intro.freed`, `npc.barnaby.return.freed`).
- **"Serving number one" clash.** `npc.dolores.intro` now says 3. `sign.now_serving` changed "ONE (since 1291)" to "THREE (since 1291)"
  (the sign was a second clash the beat map did not list). The same sign's "The Regime of Final Approvals" became "The Department of
  Necrotic Affairs".
- **Kyle's years.** No more 2003/2001. He is "deceased since '09. runner-up, employee of the month, 2009. Agnes won. Agnes always wins."
  This also fixes a hidden clash: Agnes is "employee of the month since 1987. Nobody else qualified", so Kyle could not have been the
  "last employee of the month". His intro now has one millennial reference per conversation (dial-up), not five stacked.
- **Literal names.** `dungeon.ha_records.before` and `cutscene.sever.1` now say `{villain}`.
- **`dungeon.ha_boss.before` box 1** (about 210 characters) is split; Mortimer's canon line is kept word for word.
- **`dungeon.ha_boss.after`** now explains the Tuesday on the spot ("Tuesday is not a business day in this building"), so "It was always
  valid" lands even if the player never reads the freed notice.
- **`freed_npc.agnes`** went from seven boxes to five. Her sincere lines are kept exactly ("Even the dead deserve humanity. Our job is to
  help the lost souls. Following orders be damned: we treat everyone with respect." and "Never let anyone file you under 'subject' again").
- **`freed_npc.prudence`** now carries the bible's freed line "{villain} did not corrupt us, you know. He used our own rules."
- **Agnes's "I know he's evil"** is softened to "We all know it's wrong", and the intern's "evil" to "wrong" (Primm is sincere and wrong).
- **Ledgerbone** is cut to flat one-line statements, with one flash of joy at a correct form ("Oh. Oh, that's lovely."). His freed stamp
  "got its raise".
- **Puzzle soul "Dame Basil"** is now "Dame Wilhelmina", because Basil is the Buffet's rabbit (rule: no two characters share a name).
- **Bramble timeline.** "A few months back" is now "Not long ago". His intro went from nine boxes to seven: the Refusemancer explanation
  fits in one box and keeps every quiz source (waste removal and agriculture, animals turning garbage into fertilizer, magic for the crops).
  It ends on his tic, "Also, SOMEBODY ate the compost AGAIN."
- **`cutscene.sever.4`.** "{villain}'s grip on the living world is broken" is gone. The scene now ends on her and the tree she lost
  (see the examples below).
- **Druid Sorrel.** The beat map says Sorrel exists nowhere, but she does: `core/zone/heap_growth.gd` makes her the speaker of the centre
  bridge ("Talk to Druid Sorrel"). So `quest.heap_herd.done` now tells you where she is and why to go: "Druid Sorrel at the centre bridge
  will grow you a crossing now." That reference is not a dead end.
- **Granny Gristle** said "I run the Compost Grange" (Bramble's job); she now runs the shed. "HOB'S SWAP SHED" (`prop.swap_shed`,
  `sign.swap_shed`) is now "GRANNY GRISTLE'S SWAP SHED": `npc.hob` is Gristle, and Old Hob is not in the game. She gets her "found, not
  stolen, dearie" and "Heh!" tics, and her "Shop's open. The cards are fresh." line (the vendor catchphrase the bible bans) is gone.
- **Moss Mulligan** is named, as she, on `sign.exit` and `sign.exit.freed` ("Moss Mulligan says sorry, again.").
- **Quest instructions** say where to go: the time clock "by the front desk", the coffee machine "here in the breakroom", "Roaming staff,
  any floor", "Director Ectomund's quiz, and one hidden stash in the filing mazes", the goat "from the north stable", fertilizer in "the
  fields, the east edge and the far side of the stream".

## Callbacks planted

- C17: `npc.barnaby.intro` (Gerald 4,000,212, "They're on 3") -> `npc.dolores.intro` / `dungeon.ha_number.before` (you are 4,000,213, next to
  Gerald) -> `cutscene.vacancy.6` ("right behind Gerald", canon line kept) -> `freed_npc.mortimer` ("Number 4,000,213 was, I am told, you.
  You did not wait.") -> `npc.barnaby.return.freed` ("You were 213, in between us.").
- C5 (kept intact): `npc.dolores.return` (the third form was never filed) -> `dungeon.ha_records.before` ("Irregular," very quietly) ->
  `npc.dolores.intro.freed` ("kept it in my drawer for ten years, just in case... won't be needed").
- "Irregular" seeded early: `npc.dolores.intro` ("Irregular things I can fight, dear. Valid things just sit there and smile at you.") ->
  `ha_records.before`.
- Tuesday: `memo.reorg` ("dead since Tuesday", existing) -> `dungeon.ha_boss.after` (FILED ON A TUESDAY, "Tuesday is not a business day")
  -> `sign.authorization.freed`.
- C20: Kyle `npc.matching.intro` ("ten years ago i filed the big transfer form. didn't read it... Necrocrats. we read forms.") feeds the
  transfer thread before the Records Labyrinth.
- Kyle -> Agnes: "runner-up, employee of the month, 2009. Agnes won." -> Agnes's "employee of the month since 1987".
- Gerald's biscuit: `event.ha_take_a_number.result.0` ("the polite ghost ahead of you shares a biscuit").
- C8: `npc.marigold.return` ("Eleven trees. Then nothing." + new "I water the twelfth spot anyway... It feels as if somebody is still
  coming.") -> `npc.marigold.intro.freed` (she plants a twelfth and smiles at you).
- C9: `npc.marigold.return` ("Not long ago, somebody carried a sleeping young man...").
- C21: `dungeon.rh_roots.before` keeps the tag PROPERTY OF THE PATH-OLOGISTS, now "in very tidy handwriting" (a quiet nod to
  Clipwell, who is not named).
- C4 (kept intact): `freed_npc.compostella` "do not bury it in a jar".
- The Wellspring thread (4.2): `dungeon.rh_soil.after` now has "a thread of clear water... the only clean water you have seen down here".
  It does not say "Wellspring" and adds no lore.
- The compost thief: `rh_pool.before` ("WHO IS EATING THE COMPOST?") -> `npc.marigold.intro` ("SOMEBODY ate the compost AGAIN") ->
  `npc.marigold.return.freed` ("NOBODY has explained who ate it. The raccoons have gone very quiet.") -> the S-REF raccoon trial.

## Could not do (needs code or another owner)

- Quest-log summaries are code strings, so I did not touch them. `zone_quest_definitions.gd` `_heap_dam` says Bramble "she will reward
  you" (he is he). `quest_definitions.gd` Root Cause says "a voice that isn't his" (Moss is she).
- Freed twins for the worker barks (`bark.worker_N.freed`) would retire "Those purple trees... Nobody's talking about it" after the cure.
  The generic `.freed` lookup would read them, but the brief says add no keys, so I did not.
- Kyle (`npc.matching.*`) and Ectomund have no freed variants. Same reason.
- Druid Sorrel has no entry in the voice bible or the sheet, yet she speaks in game (`heap_growth.gd`). The inbox should decide whether
  she stays.
- Name clashes are still open for the inbox: Wren Muckfoot vs Wren, and Recycle Rhonda vs the Gainlands ripper Rhonda.
- In `cutscene.sever.3` Compostella speaks "...Then we let it die, together." The bible may mean that as the Wanderer's line. The
  speaker is fixed per beat, so it stays hers; it reads as her own resolve.
- npcs.json barks for these NPCs (Agnes's library bark and others) were not in my files.

## 10 best before -> after

1. **`cutscene.sever.4`** (box 3)
   Before: "Thank you. {villain}'s grip on the living world is broken."
   After: "I can hear the stream. I can hear the goat." / "And I can hear her, a little, in all of it. She did not go away. She went into
   everything." / "To grow, I had to let her go. ...I think she has been waiting ten years for me to say so."

2. **`npc.marigold.return`** (new box)
   Before: "...Eleven trees, then nothing." / "A few months back, somebody carried a sleeping young man..."
   After: "...Eleven trees. Then nothing." / "I water the twelfth spot anyway. I couldn't tell you why. It feels as if somebody is still
   coming." / "Not long ago, somebody carried a sleeping young man..."

3. **`npc.barnaby.intro`** (Gerald)
   Before: "Oh! A customer! Gerald, breakroom barista."
   After: "Oh! A customer! Hello. Gerald, breakroom barista. Also Number 4,000,212." / "They're on 3. I've been waiting a while. I brought
   a book. Several. All of them, actually."

4. **`freed_npc.mortimer`**
   Before: "Currently number 4,000,214 in the Waiting Room of Eternity, right behind Gerald."
   After: "...Currently number 4,000,214 in the Waiting Room of Eternity. Gerald was 4,000,212." / "Number 4,000,213 was, I am told, you.
   You did not wait. I find I resent that, and I am told resenting it is healthy."

5. **`npc.matching.intro`** (Kyle)
   Before: "I'm Kyle. Last employee of the month of 2003..." / "I filed the paperwork myself. I did not read it."
   After: "i'm Kyle. deceased since '09. runner-up, employee of the month, 2009. Agnes won. Agnes always wins." / "fun fact: ten years ago
   i filed the big transfer form. didn't read it. who reads forms." / "...oh. right. Necrocrats. we read forms. that's, like, our whole
   thing."

6. **`npc.dolores.intro`** (Agnes)
   Before: "Take a number. We're serving number one. Have been for seven hundred years. He's very thorough." ... "I know he's evil." / "We
   all know. But the authorization is valid."
   After: "Take a number. Yours is 4,000,213. We're serving number 3. Bring a cushion." ... "We all know it's wrong." / "But the
   authorization is valid. Irregular things I can fight, dear. Valid things just sit there and smile at you."

7. **`dungeon.ha_boss.after`**
   Before: "\"...Oh,\" says Mortimer. \"Oh no. The authorization is valid." / "It was always valid. But the office is vacant, and policy is
   policy.\""
   After: "\"...Oh,\" says Mortimer. \"Oh, no. Tuesday is not a business day in this building." / "The authorization was valid. It was
   always valid. But the office is vacant, and policy is policy.\""

8. **`freed_npc.prudence`**
   Before: "Now I stamp APPROVED on things that deserve it. It is a lot more fun than it sounds, and the stamp is lighter than I remembered."
   After: "{villain} did not corrupt us, you know. He used our own rules. Now I stamp APPROVED on things that deserve it." / "The stamp is
   lighter than I remembered. Do you have anything I can approve?"

9. **`npc.hob.intro`** (Granny Gristle)
   Before: "I run the Compost Grange. One person's trash is another person's cards, as the saying goes. I mean, I made that saying up."
   After: "Everything here's Refusemancer-issue: grown, composted, well rinsed. Found, not stolen, dearie. The raccoon found it. I just
   held it very tightly."

10. **`npc.pip.intro.freed`** (Ledgerbone)
    Before: "...The stamp has stopped haunting." / "It's just a stamp. It looks so sad. Cards, in triplicate, as always."
    After: "Requisitions. Clerk Ledgerbone. The stamp has stopped haunting. It got its raise." / "It doesn't know what to do with itself.
    Neither do I. Cards, in triplicate, as always."

Runners-up: `npc.barnaby.return.freed` "Mortimer is Number 4,000,214 now. You were 213, in between us. Don't mention it to him. He goes
very quiet."; `quest.heap_herd.active` "The raccoon is writing a strongly worded letter."; `match.win` "you're in my top 8 now. you're
number one, actually. sorry, me. you've been bumped."
