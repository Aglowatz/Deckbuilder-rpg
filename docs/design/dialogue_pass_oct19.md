# Dialogue pass, Oct 19 2026: the report

Tonight the game's dialogue was rewritten area by area and then reviewed by separate editors. This page covers what changed, how the
scores moved, 30 before -> after examples for you to judge, and what still needs code or a decision from you.
Detailed reports: `docs/design/dialogue_pass/` (writer_brief, editor_brief, four writer reports, four `*_editor.md` with every score).
References the writers used: `docs/design/voice_bible.md` (81 voice entries and global rules) and `docs/design/dialogue_beats.md` (beats,
foreshadowing and callbacks per area, box limits, the weakest lines).

Commits: `dd29a10b` (voice bible + beat map), `93cb6207` (writers), `c3485f6d` (tests), `03a04532` (editors).

## 1. How it was done

1. **Voice bible** (`voice_bible.md`): global rules (one or two sentences per box, target 160 characters, never over 240; every NPC distinct;
   no shared catchphrases; parody, never real brands; jokes get quieter near Primm; Primm is sincere and wrong), plus one entry per speaker.
2. **Beat map** (`dialogue_beats.md`): which conversation carries which beat, foreshadowing and callback, and the weakest lines to fix.
3. **Four writers**, one per area, in priority order: opening + Crosspath, the Gainlands + Buffet, the D.N.A. + Dump, the Capital + the
   Primm story (with the side dungeons and the Lab in `dungeon_content.json`). Text only: every key, array, tag, placeholder and token kept.
4. **Four separate editors** (none edited their own writing) scored every conversation, OLD and NEW, 1-5 on in character / funny (fit, not
   volume) / beat landed / brevity / clarity of what to do next. A conversation's score is the lowest of the five. Every conversation under 4
   was rewritten and scored again until it reached 4.
5. Tests were added for banned names, quest instructions and box fit (section 6).

## 2. What was rewritten

Diff `pre-overnight-oct19..HEAD`, dialogue files: 7 files, 528 lines added and 523 removed. (`data/story/old_well_story.json`, +127, is
the Old Well quest from another part, not this pass.) Keys changed (from the writer reports; the editors changed text only, no keys):

| Area | Files | Keys changed | Notable fixes |
|---|---|---|---|
| Opening + Crosspath | `intro_story.tres` (138 diff lines); 6 cave blurbs in `trial_of_the_hollow.gd`; 1 tip in `tutorial_layer.gd` | 66 keys/arrays (~175 lines) + 7 code strings | The first lines no longer break the amnesia ("I remember a kingdom. Four Paths"). Banned "Z.V." -> "- A.". "THE USURPER", "Primm", "Tessar", "Wayweaver" -> `{villain}`, `{prince}`, `{royal_house}`. `still.flex` no longer says "They had not taken his muscles" (it contradicted Flex's lesson). Maren's first talk 6 -> 4 boxes. Gatekeeper victory arrays made true before and after a zone is freed. Bellows is "he". "The trial begins." gone (canon: a passage). Return lines cut (Fenwick, Pip 4 -> 2 boxes). Pip lost "goblin". |
| The Gainlands | `gainlands_story.tres` (134) | 63 keys (155 lines) | Tiny Tony leftovers gone; Benchley gets his shouting voice. Old Man Mountain is "he" (`travel.ripper_calf.locked` said "her"). "Brenda" out of the quiz note. Gus no longer speaks of himself in the third person, and is "Foreman Gus" everywhere (canon). The lesson (breath, heart, mind) lands in the rescue and the boss. Narration says "you". |
| The Endless Buffet | `gourmand_story.tres` (112) | 52 keys (133 lines) | The Doppelganger stops gloating ("Soup is for the weak") and becomes cold and sad; no umlaut. The Grand Chef is "she" everywhere ("a man who does not eat" fixed). Literal "Wanderer" gone. Vendors no longer say "Shop's open". Quest steps name places (Grand Oven by the arch, Sir Loin's gate). |
| The D.N.A. | `dna_story.tres` (134) | 66 of 226 keys | Queue numbers made consistent: you are 4,000,213 everywhere, Gerald 212, Mortimer 214; "serving number one" -> 3 (also on `sign.now_serving`). Kyle's 2003/2001 clash fixed ('09, runner-up to Agnes). "Primm" -> `{villain}`. "evil" -> "wrong" (Primm is sincere and wrong). "Dame Basil" -> "Dame Wilhelmina" (Basil is the Buffet's). Agnes's closing 7 -> 5 boxes, sincere lines kept word for word. |
| The Verdant Dump | `refusemancer_story.tres` (112) | 56 of 232 keys | Granny Gristle ran "the Compost Grange" (Bramble's job): now she runs the shed, and "HOB'S SWAP SHED" is "GRANNY GRISTLE'S SWAP SHED". Banned vendor catchphrase "The cards are fresh" gone. "A few months back" -> "Not long ago". Bramble 9 -> 6 boxes, Rhonda 6 -> 4, quiz sources kept. Druid Sorrel placed ("at the centre bridge"). Moss Mulligan named, as she. Compostella's sever ends on her and the tree, not the plot. |
| The Capital, castle, ending | `capital_story.tres` (288) | 138 of 582 keys (118 rewritten, 20 token-only) | Every literal "Primm" in text -> `{villain}` (31 uses), "His Perfection" -> `{villain_title}`, "Primm's Perfection" -> `{capital}`. The Wanderer stops lecturing: his lines quote the four leaders. Primm sincere, not gloating (`primm_reveal.5`). Ending in second person. Quest insights in the giver's voice instead of bracketed "(the records say...)" asides. The freed bird is "Thursday", not "Gerald". Over-240 popups cut (`fx.cable`, `ui.main.body`, `ui.gate.body`, the Escalation Shelf). |
| Side dungeons + the Lab | `dungeon_content.json` `text` block (133) | 47 of 49 keys | All six side-quest givers in their own voice; Gerald owns his quest ("That's me"); Kestrel rewritten as the playful scout; Basil no longer opens with Fig Sly's "Psst. Over here."; Kestrel's steps name the manhole and the tunnel mouth (north-east). Siphon tokenized. |

Total: about 488 keys plus 7 code strings. The commit message for `93cb6207` says "~360"; the per-file counts above are the writers' own.

### Callbacks planted (setup -> payoff)

- **Flex (C1):** gainlands `cutscene.flex.3` "They took my weights, Clench. They forgot to take me." + `dungeon.hg_boss.after` "it was not
  the part that matters" -> capital `cutscene.primm_p1.2`.
- **Grand Chef (C2):** gourmand `freed_npc.grandchef` "a blank page... do something worth signing" -> `primm_p2.2` -> capital
  `freed_npc.grandchef` "You did something worth signing".
- **Agnes (C3):** dna `freed_npc.agnes` "Never let anyone file you under 'subject' again" -> `primm_p2.2`; Siphon's "Subject 1".
- **Compostella (C4):** refusemancer `freed_npc.compostella` "do not bury it in a jar" -> `primm_end.3` -> `boon.refusemancer.line`
  "Even him. Especially him." -> `primm_end.6` (sparing him).
- **The third form (C5):** dna `npc.dolores.return` -> `dungeon.ha_records.before` ("Irregular," very quietly) -> `npc.dolores.intro.freed`.
- **The face (C6):** gainlands `npc.brenda.return` -> `npc.brenda.intro.freed` "you made the same face he did".
- **The cake (C7):** gourmand `npc.odalys.return` -> `npc.odalys.intro.freed` "Is the boy all right?".
- **The twelfth tree (C8):** refusemancer `npc.marigold.return` "I water the twelfth spot anyway" -> `npc.marigold.intro.freed`.
- **The kettle (C10):** `tutorial.warden.after` -> `cave_mouth.maren` "Kettle's been on since noon."
- **Maren's handwriting (C14):** `town.elder.stage.1` (the pie recipe "in my own hand") -> capital `dungeon.pc_ward.before`.
- **Isla, unnamed (C16):** `town.guard` / `town.guard.capital_done` "My girl's still up that road" -> capital `facade.door.3` (the painter
  who "has meant to write home for years") -> `facade.door.3.freed`.
- **The queue (C17):** dna `npc.barnaby.intro` (212) -> `npc.dolores.intro` (213, you) -> `freed_npc.mortimer` (214, "You did not wait")
  -> `npc.barnaby.return.freed`.
- **The wheels (C18):** gainlands `npc.gus.intro` "Those crews get told it's cardio" -> capital `npc.rollo.intro` -> capital
  `freed_npc.heartlift` "rest is a rep".
- **The transfer form (C20):** Kyle's unread form -> the Records Labyrinth.
- **Flex never broke (C24):** `beefcake_npc_victory_lines` -> Flex freed.
- **The crest (4.1):** `town.elder.stage.0` (four carvings on Maren's stick) -> `memory.4.fragment/.after` -> `quest.side_s_town.ready`
  (the vault key) -> `dungeon.dg_s_town_boss.before/.after` ("Tick. ...Recognised.").
- **The Wellspring (4.2, legend only):** `start.gate_prompt` "older water" -> the Hollow Well blurb -> `tutorial.warden.after` "The spring
  at the end ran once" -> `cave_mouth.maren` -> `town.alchemist.intro`; refusemancer `dungeon.rh_soil.after` (a thread of clean water).
- **The prince (4.3):** `cave_mouth.maren` "Certainly not this damp" -> `town.elder.stage.2` "That is no prince"; the Warden opens for one
  family -> `memory.4.after` "And I knew."
- **The Rescuer (4.5):** `prologue.rescuer.2` "You always used to... Never mind." -> `dungeon.dg_lab_rescue.before`; Siphon "My assistant
  left us too". Siphon hint: `memory.3.after` "My best student" -> `dungeon.dg_lab_boss.after`.
- **Inside one zone:** Clench as "star pupil" (`npc.brenda.intro` -> `hg_boss.before`); "she never tastes" (Basil -> Tarragon -> the
  inspector -> the whistleblower -> the reveal -> Escoffina "I tasted it. As me."); the humming freezer (`tk_cold.blurb` -> `tk_boss.after`);
  Tuesday (`memo.reorg` -> `ha_boss.after` -> `sign.authorization.freed`); the compost thief (`rh_pool` -> Bramble -> the S-REF raccoon);
  "seventeen people" -> "sorry about the hats"; "eleven thousand" (Spotless, the Chief Corrector, Primm); Plume's loudspeaker sign-offs.

## 3. Editor scores

Average and lowest of the conversation minimums (each conversation's score is its lowest axis).

| Area | Conversations | Old avg / min | Writer avg / min | Final avg / min | Under 4: old -> writer -> final |
|---|---|---|---|---|---|
| Opening + Crosspath | 68 | 3.01 / 1 | 3.97 / 3 | 4.01 / 4 | 49 -> 3 -> 0 |
| The Gainlands | 29 | 3.31 / 2 | 3.97 / 3 | 4.00 / 4 | 17 -> 1 -> 0 |
| The Endless Buffet | 27 | 3.19 / 2 | 3.89 / 3 | 4.00 / 4 | 16 -> 3 -> 0 |
| The D.N.A. | 28 | 2.89 / 1 | 3.96 / 3 | 4.00 / 4 | 24 -> 1 -> 0 |
| The Verdant Dump | 25 | 2.92 / 1 | 3.88 / 3 | 4.00 / 4 | 19 -> 3 -> 0 |
| Capital, castle, side dungeons, Lab | 81 | 3.41 / 2 | 3.98 / 2 | 4.11 / 4 | 41 -> 10 -> 0 |
| **All** | **258** | **3.17 / 1** | **3.95 / 2** | **4.04 / 4** | **166 -> 21 -> 0** |

The editors rewrote the 21 conversations still under 4 and polished 7 more that were at 4 (canon names, shared catchphrases, a replaying
line). On the five axes: the old text lost most on **brevity** (6-9 box intros, 300-character boxes) and **in character** (retired names,
wrong pronouns, the same vendor catchphrase, the villain gloating); final in-character is mostly 5. **Beat landed** rose from 3 to 4-5 as
the callbacks went in. **Clarity** is 4-5 everywhere (quest steps now name the place). **Funny** is mostly 4, which is the ceiling the
editors allowed for quiet scenes near Primm, where no joke is the right fit. (Opening area, average of all five axes: 4.05 -> 4.53.)

## 4. The 30 best before -> after

Final text from the working tree; " / " separates dialogue boxes.

### Opening and Crosspath

1. **`awakening_lines`**, the Wanderer (the first words of the game)
   - BEFORE: "Where am I?" / "What happened?" / "My head... I remember a kingdom. Four Paths." / "A great, bright city where they all met. And then... nothing." / "...There. Light, through the rocks. That must be the way out."
   - AFTER: "...Cold. Leaves in my mouth. Great start." / "I reach for my name and there's nothing there. Not even the shape of one." / "No name. Two hands. One of them is shaking. I'll start with the other one." / "...And I'm not alone."
   - Why: real amnesia instead of a lore summary, a joke in his voice, and it hands off to the Rescuer.
2. **`prologue.rescuer.2`** box 2, the Rescuer
   - BEFORE: "Can you still fight? Can you still pull energy from the Paths? Hold out your hand."
   - AFTER: "Can you still fight? Can you still pull from the Paths? Hold out your hand. You always used to... Never mind. Your hand."
   - Why: one slip plants that she knew him (pays off in the Lab).
3. **`cave_mouth.maren`** boxes 1-3, Elder Maren
   - BEFORE: "So. You're the one they sent through the old tunnel." / "I was told someone would come out of there. Not who. Not what you would look like." / "You look like you haven't slept in years."
   - AFTER: "So. You're the one they sent through the old tunnel. Kettle's been on since noon." / "I was told someone would come out of there, past the dry spring and that grumpy Warden. Not who. Certainly not this damp." / "Don't mistake this for trust, dearie. You could be anyone's spy. And whoever pushed you into that tunnel is reckless, and I don't like reckless."
   - Why: three set-ups in one greeting (the kettle, the dry spring, her distrust of the Rescuer), all in her voice.
4. **`town.elder.stage.2`**, Elder Maren
   - BEFORE: "The resistance has ears in every Path. If you meet Wren, tell her my pie is still the best thing in the kingdom."
   - AFTER: "Somebody in the square says you have a look of the old court about you. That is no prince, I told them. That is a damp young man with good posture." / "And if you meet Wren in the Capital, tell her my pie is still the best thing in the kingdom. She'll argue. She'll be wrong."
   - Why: the prince hint hidden inside a denial, and it says where Wren is.
5. **`memory.4.after`** new boxes 3-4, Elder Maren
   - BEFORE: (straight from "So we are never far from home." to) "And my lab, ten years of my life's work, was used on that boy. Forgive me, if you ever can."
   - AFTER: "And I knew. The Warden opens that tunnel for one family only. I knew the moment you walked out of it, and I was too frightened to say so." / "Four signs in a ring. The same as on my stick. I have carried it for ten years and told nobody why." / "And my lab, my life's work, was used on that boy. Forgive me, if you ever can."
   - Why: pays off the Warden and the stick, and gives her confession a reason.
6. **`town.alchemist.locked`** box 2, Auntie Alembic's note
   - BEFORE: "'CLOSED UNTIL TWO PATHS ARE FREE. THE USURPER CONFISCATED MY CAULDRON. I AM STILL BREWING IN THE SINK. - Z.V.'"
   - AFTER: "'CLOSED UNTIL TWO ZONES ARE FREE. {villain} TOOK MY CAULDRON. I AM BREWING IN THE SINK. THE SINK IS COPING. - A.'"
   - Why: banned initials gone, the unlock rule matches the toast, and "THE SINK IS COPING" is a better button.

### The Gainlands

7. **`cutscene.flex.3`**, Grandmaster Flex
   - BEFORE: "You took my plates, my protein, my pump, Clench. You thought you had taken my strength. But you only took the weight." / "You left me my heart, and my mind. I taught you everything I knew about the first, and you stopped listening before I got to the second."
   - AFTER: "They took my weights, Clench. They forgot to take me." / "You only ever took the weight. I taught you the heart, and you stopped listening before I got to the mind."
   - Why: half the words, and the first box is the line the finale quotes.
8. **`npc.tony.intro`** boxes 1 and 4, Coach Brutus Benchley
   - BEFORE: "I'm Coach Brutus Benchley. Yes, I know. Everything's relative." ... "Do not ask what is under it. Iron."
   - AFTER: "LET'S GO! NEW RECRUIT! Coach Brutus Benchley! Retired champion, current motivator, part-time merchant!" ... "*whispering* And do not stand on the loose floorboard behind the counter. There's nothing under it. Iron. Nothing."
   - Why: a Tiny Tony leftover replaced by his own voice; the whisper is the joke.
9. **`npc.gus.intro`** boxes 2-3, Foreman Gus
   - BEFORE: "The regime wants a hundred and ten percent. The wheels only go to a hundred." / (no box 3)
   - AFTER: "The regime wants a hundred and ten percent. The wheels go to a hundred. The extra ten is me, crying quietly." / "They want the same out of the city wheels up in the Capital. Those crews get told it's cardio. It isn't."
   - Why: a punchline on the old set-up, and it plants Rollo's wheels in the Capital.
10. **`quest.gain_power.done`**, Foreman Gus
    - BEFORE: "The grid's running smooth, and some of it is even staying here. Gus would hug you, but Gus is allergic to humility."
    - AFTER: "The grid's running smooth, and some of it's even staying here. I'd hug you, but I'm a foreman. We nod. ...That was a big nod."
    - Why: no more third person, and a warmer, character-true joke.

### The Endless Buffet

11. **`cutscene.reveal.3`**, the Doppelganger (as the Grand Chef)
    - BEFORE: "...Soup is for the weak. {villain}'s orders are for the strong. I have given the Gourmands the Special Sauce, and they have given me an army of golems. It is a very efficient arrangement."
    - AFTER: "...Tasting is inefficient. The orders from {capital} asked for golems, not flavour, and the Special Sauce delivers golems." / "\"Delicious.\" That is the word I was given for it. I say it often. I do not know what it means."
    - Why: from a cartoon villain to something unsettling; the second box is the zone's theme.
12. **`cutscene.reveal.5`**, the Doppelganger
    - BEFORE: "THIS is my real face. Behold the true dish of {villain}: the Doppelgänger. Now. Let me serve you."
    - AFTER: "This is what was under it. I wore her face so long that I forgot my own. There is nothing in here to taste with." / "Sit down, taster. I was told to serve you."
    - Why: the monster gets a sad truth before the fight, and Escoffina's later "I tasted it. As me." answers it.
13. **`npc.odalys.intro`** box 4, Basil
    - BEFORE: "She looks the same. Sounds the same. But she does not taste a dish before it goes out any more."
    - AFTER: "She looks the same. She sounds the same. But Chef ALWAYS tastes, and this Chef doesn't. She just smiles at the soup."
    - Why: starts the "never tastes" thread the whole zone pays off, with a creepy image.
14. **`freed_npc.escoffina`** box 3, Escoffina
    - BEFORE: "I made a sauce today. A real one. It had too much salt."
    - AFTER: "I made a sauce today. A real one. I tasted it. As me. It had too much salt."
    - Why: four words close the zone's arc.

### The D.N.A.

15. **`npc.dolores.intro`** boxes 3-5, Agnes Overdue
    - BEFORE: "Take a number. We're serving number one. Have been for seven hundred years. He's very thorough." / ... "Properly. Now the whole department works for him. I know he's evil." / "We all know. But the authorization is valid."
    - AFTER: "Take a number. Yours is 4,000,213. We're serving number 3. Bring a cushion." / "Ten years ago, {villain}'s people filed some paperwork. Reviewed, approved, notarized, filed. Properly. Now the whole Department works for him." / "We all know it's wrong. But the authorization is valid. Irregular things I can fight, dear. Valid things just sit there and smile at you."
    - Why: the queue numbers agree everywhere now, Primm is "wrong", not cartoon "evil", and "Irregular" is set up.
16. **`npc.barnaby.intro`** boxes 1-2, Gerald
    - BEFORE: "Oh! A customer! Gerald, breakroom barista."
    - AFTER: "Oh! A customer! Hello. Gerald, breakroom barista. Also Number 4,000,212." / "They're on 3. I've been waiting a while. I brought a book. Several. All of them, actually."
    - Why: starts the 212-213-214 chain with a joke about waiting.
17. **`npc.matching.intro`**, Kyle (9 boxes -> 5)
    - BEFORE: "I'm Kyle. Last employee of the month of 2003. My away message still says 'brb, getting a snack'." / "That was my snack. In 2003. I have been here through the transfer." / "I filed the paperwork myself. I did not read it." (and six more)
    - AFTER: "i'm Kyle. deceased since '09. runner-up, employee of the month, 2009. Agnes won. Agnes always wins." / "fun fact: ten years ago i filed the big transfer form. didn't read it. who reads forms." / "...oh. right. Necrocrats. we read forms. that's, like, our whole thing."
    - Why: fixes the date clash with Agnes, one millennial reference instead of five, and plants the transfer form.
18. **`dungeon.ha_boss.after`** boxes 3-4, Mortimer
    - BEFORE: "\"...Oh,\" says Mortimer. \"Oh no. The authorization is valid." / "It was always valid. But the office is vacant, and policy is policy.\""
    - AFTER: "\"...Oh,\" says Mortimer. \"Oh, no. Tuesday is not a business day in this building." / "The authorization was valid. It was always valid. But the office is vacant, and policy is policy.\""
    - Why: the win is explained on the spot, so "FILED ON A TUESDAY" lands without reading the freed notice.
19. **`freed_npc.mortimer`** boxes 1-2, Mortimer Grimsby
    - BEFORE: "Mortimer Grimsby. Formerly CE-No. Currently number 4,000,214 in the Waiting Room of Eternity, right behind Gerald." / "I am told this is called 'learning to wait.'..."
    - AFTER: "Mortimer Grimsby. Formerly CE-No. Currently number 4,000,214 in the Waiting Room of Eternity. Gerald was 4,000,212." / "Number 4,000,213 was, I am told, you. You did not wait. I find I resent that, and I am told resenting it is healthy."
    - Why: the queue payoff, and a former villain who is funny and a little sorry.

### The Verdant Dump

20. **`cutscene.sever.4`**, Archdruid Compostella
    - BEFORE: "...It is rotting. Honest compost, the first in ten years. I can hear the soil." / "I can hear the stream. I can hear the goat. To grow, I had to let go." / "Thank you. {villain}'s grip on the living world is broken."
    - AFTER: "...It is rotting. Honest compost, the first in ten years. Oh. I can hear the soil again." / "I can hear the stream. I can hear the goat." / "And I can hear her, a little, in all of it. She did not go away. She went into everything." / "To grow, I had to let her go. ...I think she has been waiting ten years for me to say so."
    - Why: ends on her grief, not a plot summary; this is the pass's best emotional beat.
21. **`npc.marigold.return`**, Brother Bramble (new box 3)
    - BEFORE: "...There's a row of them past the stream. Eleven trees, then nothing." / "A few months back, somebody carried a sleeping young man through these woods at night..."
    - AFTER: "...There is a row of them past the stream. Eleven trees. Then nothing." / "I water the twelfth spot anyway. I couldn't tell you why. It feels as if somebody is still coming." / "Not long ago, somebody carried a sleeping young man through these woods at night..."
    - Why: the prince foreshadow becomes a feeling, and the timeline fix ("Not long ago").
22. **`npc.hob.intro`** box 3, Granny Gristle
    - BEFORE: "I run the Compost Grange. One person's trash is another person's cards, as the saying goes. I mean, I made that saying up."
    - AFTER: "Everything here's Refusemancer-issue: grown, composted, well rinsed. Found, not stolen, dearie. The raccoon found it. I just held it very tightly."
    - Why: she no longer claims Bramble's job, and the joke is hers.
23. **`quest.heap_herd.done`**, Wren Muckfoot
    - BEFORE: "The herd is home and it is plotting. Thank you. Druid Sorrel at the stream owes you a bridge, by the way."
    - AFTER: "The herd's home and it's plotting. Thanks! Druid Sorrel at the centre bridge will grow you a crossing now. Tell her I sent you."
    - Why: a vague aside becomes a clear next step with the right place.

### The Capital, the castle and the side dungeons

24. **`cutscene.primm_intro.3`**, the Wanderer
    - BEFORE: "You have to stop, Primm. The Paths are breaking. The people are afraid of you."
    - AFTER: "Sorry. That's forest mud. I've walked a long way, and everyone I met on the way here was afraid of you."
    - Why: a small human line on the polished floor instead of a speech; still sets up "Afraid? Of what?".
25. **`cutscene.primm_p1.2`**, the Wanderer
    - BEFORE: "Because they are not the same, Primm. People are not the same, and strength is not control. It comes from the heart and the mind, not from ordering the world into rows."
    - AFTER: "Because some things are five. Some people are." / "You took ten years from me. Whatever you took, it was not the part that matters. Strength is not control."
    - Why: the lecture is gone; he quotes Flex.
26. **`cutscene.primm_p2.2`**, the Wanderer
    - BEFORE: "You can only copy, Primm. A name is not a self, and a face is not either: what you do is what you are. And no order, however valid, outranks treating people with respect."
    - AFTER: "You copied my cards. You can't copy what I do with them. A name is a blank page until you sign it." / "And nobody files me under 'subject' again. No order outranks treating people with respect."
    - Why: two callbacks (the Grand Chef, Agnes) in two short boxes, tied to the fight.
27. **`cutscene.primm_end.6`**, the Wanderer
    - BEFORE: "It is not too late to say sorry."
    - AFTER: "I'm not going to correct you. That was your way. Start smaller. Say sorry to one person."
    - Why: mercy that turns his own word against him; Primm answers "One? I corrected eleven thousand...".
28. **`facade.citizen.4.slip`**, a Showcase citizen
    - BEFORE: "The man next door smiled at a funeral and he was corrected. He had to. It was his wife. She was not a regulation death."
    - AFTER: "The man next door smiled at his wife's funeral. He was remembering her laugh." / "(a whisper) They corrected him for a month. He does not remember her laugh now."
    - Why: the regime's cost in one quiet image; the editor scored it 5 on every axis.
29. **`freed_npc.heartlift`** (capital), Grandmaster Flex in the Crease
    - BEFORE: "Grandmaster Flex: \"Heart and mind, little one. And you have both. I once taught a mill to run backwards. You are better than the mill.\""
    - AFTER: "Breathe in. Hold. ...Feel that? That is a city with nowhere it has to be." / "Rollo's crews are lying in the sun. I told them rest is a rep. They believed me. Heart and mind, son. You used both."
    - Why: the extra name prefix is gone, the odd mill line is gone, and the wheels thread ends here.
30. **`quest.side_s_cap.active`** (dungeon_content), Kestrel's quest step
    - BEFORE: "Find the resistance hideout. Ask Wren about the tunnels."
    - AFTER: "Get inside and find the Crease: the manhole near the gate. Knock three times. Not two. Two is rude. Then ask Wren about the tunnels."
    - Why: says where to go and what to do, and still has a joke.

## 5. Needs code or a decision

Merged from all eight reports, with duplicates removed.

**Code**
1. **Gatekeeper freed variants.** The four victory arrays replay after a zone is freed (`town_scene.gd` around line 1269). They are now
   written to read true both before and after, but real freed lines (Brick's C24 payoff in particular) need code.
2. **First talks are long.** `zone_scene.gd _talk_quest_npc` joins `npc.<id>.intro` and the quest offer into one conversation, so Agnes,
   Bramble, Gerald, Wren Muckfoot and Ledgerbone run 7-8 short boxes the first time. Options: show the offer on the second talk, or after a
   prompt. The same goes for the minigame intros (Chet 8 boxes, Flambe 9; cutting them shortens arrays, which the writers were not allowed to
   do) and Maren's `stage.0` + `return` (4 boxes on every visit; a "one random line per return" option would need code).
3. **Leader quotes in the finale.** The castle can be entered with fewer than four zones freed, but `primm_p1.2`, `primm_p2.2` and
   `primm_end.3` always play. They read as the Wanderer's own words, so nothing breaks; naming the leader would need per-zone keys read by
   `CutsceneScreen`. Also: `primm_p1.2` "You took ten years from me" and `primm_end.3` "You took my mother and father" assume he knows who he
   is by phase 1 (memory 4 or `primm_reveal` makes sure of that today); check them if the reveal order ever changes.
4. **Quest-log summaries with the wrong pronoun** (code strings): `zone_quest_definitions.gd:289` `_heap_dam` "she will reward you"
   (Bramble is he); `quest_definitions.gd` Root Cause "a voice that isn't his" (Moss is she).
5. **`world/town_scene.gd`:** `BAKER_LINES[2]` says "the bridge to the Capital" (the road has an arch); the arena prompt "Enter the Grand
   Clashatorium" is a banned name; `_talk_equipment_vendor` uses `lines.append_array` on the shared exported `equipment_vendor_intro_lines`
   on the first visit before level 5 (a bug).
6. **Agnes meets you twice as a stranger:** `dungeon.ha_number.before` ("Oh, you're new.") plays even after the front desk. Needs a met-flag
   variant key that the code reads.
7. **Missing freed variants:** worker barks (`bark.worker_N.freed`; "Those purple trees... Nobody's talking about it" still plays after the
   cure), Kyle, Ectomund. The generic `.freed` lookup would read new keys, but the writers were told not to add keys.
8. **`DungeonCatalog` may override** some `dungeon.hg_*` / `dungeon.tk_*` titles and blurbs from the sheet. If it wins, Quota's stopwatch
   (`hg_checkpoint.blurb`) and the humming-freezer hint (`tk_cold.blurb`) never show. Needs a check in code or a run.
9. **The crest at the Crosspath fountain** has no place yet: the fountain needs an "E to read" text.
10. **Popups are not length-checked.** `ui.*` bodies are not in the fit test; the D.N.A. and Dump `ui.main.body` are still 364 and 355
    characters. A popup-length check would be a test change.

**Decisions**
11. **Druid Sorrel** speaks in game (`core/zone/heap_growth.gd`, `grow.bridge_center.*`) but has no voice-bible entry, is not on the sheet,
    and the Wren Muckfoot entry says "no unseen Druid Sorrel". Keep her (add her to the bible) or retire her (code). The text now places her.
12. **Old Hob:** `npc.hob` is Granny Gristle, and Old Hob is not in the game, so "HOB'S SWAP SHED" became "GRANNY GRISTLE'S SWAP SHED". Only
    the key id still says hob. Confirm.
13. **Name clashes:** Wren (Capital resistance) vs Wren Muckfoot (the Dump); Recycle Rhonda vs Rhonda the Gainlands ripper; the tailor shop
    "Thimble's Hats & Hems" vs the tailor Pip Threadwell (shop name or leftover?). All kept as they are.
14. **Openers:** while writing this report I noticed "Psst. Over here." opens both Fig Sly (`capital npc.fig`) and Fenwick
    (`town.pack_vendor.first`, unchanged from before), and Basil ("Psst. Hello.") and Kestrel ("Psst. Down.") also open with "Psst". The
    rule is no shared catchphrases; Fig Sly is hands-off, so Fenwick is the one to change if you agree.
15. **Real-world years:** "since 1989" (Chet) and "two-thousand-three" (Flambe's return). Not brands; left for you.
16. **`cutscene.vacancy.6`** "You are right behind Gerald" (a canon line) sits a little oddly next to you being 4,000,213; `freed_npc.mortimer`
    reconciles it. **`cutscene.sever.3`** "...Then we let it die, together." is Compostella's line (the speaker is fixed per beat); the story
    bible may have meant it for the Wanderer.
17. **The alchemist note** reads "Primm TOOK MY CAULDRON" in an all-caps note (no upper-case token). Fine as it is, in the editor's view.
18. **Not built, only hinted:** Isla's homecoming (`town.guard` is postgame-only in practice), Plume as a named character, the lieutenants'
    fights, Elowen's abduction.
19. **Not reviewed:** the NPC barks in `data/npcs/npcs.json` for every zone.

## 6. Tests

- **New: `tests/test_dialogue_quality.gd`** (commit `c3485f6d`):
  - `test_canon_lists_the_banned_names`: the banned list is read from `docs/design/canon.md` ("Banned old names"), at least 20 names, with a
    fallback list if the file cannot be read.
  - `test_no_banned_old_name_in_player_text`: no banned name across the story files, `dungeon_content.json`, the loading tips, `npcs.json`
    and the quests. (It found two loading tips that said "Pathwork" for "Patchwork"; fixed.)
  - `test_every_quest_step_says_what_to_do`: every quest step has instruction text.
  - `test_every_dungeon_content_line_fits_the_box`: every `dungeon_content.json` line fits the dialogue box (4 lines at default text size,
    6 at the largest).
- **Existing: `tests/test_dialogue_fit.gd`**: every story line fits the box at the default and the largest text size.
- **Result:** 158/158 dialogue-related tests passing (the run after the editor pass, commit `03a04532`).

## First-talk trim (Phase 2)

**How a first talk is built.** `world/zone/zone_scene.gd` `_talk_quest_npc` shows `_greeting(npc_id) + story.get_lines("quest.<id>.offer")`
as one conversation when the NPC has a quest to offer. `_greeting` returns `npc.<id>.intro` on the first talk (`npc.<id>.intro.freed` once
the zone is freed, through `ZoneStoryText.get_lines`), and `.return` plus the dungeon hooks afterwards. Minigame hosts get `_greeting` and
then the minigame. Capital Wren is `capital_scene.gd` `_talk_wren`: `_greeting("wren")` plus `npc.wren.insight.<n>` (she has no offer).
Every one of these arrays is read whole (`get_lines` / `text`, `append_array`). No code reads them by index. The tests only check
substrings: "the authorization is valid" (Agnes), "Compostella" (Bramble), "Maren" (Wren). All three are still there.

**Rule:** a first talk is at most 5 boxes (intro + offer), and each box is at most 200 characters (the longest is now 186). Boxes were
tightened and merged. Every quest instruction, quiz source, callback, token and tic is still there.

| NPC (keys) | Before | After | Kept on purpose |
|---|---|---|---|
| Agnes (`npc.dolores.intro` + `quest.dna_backlog.offer`) | 5+3 = 8 | 3+2 = 5 | employee of the month 1987 (Kyle callback), 4,000,213 / serving 3 (C17), "the authorization is valid", "Irregular things I can fight" (seed for `ha_records`), "three roaming staff, any floor, by duel" |
| Agnes freed (`.intro.freed` + offer) | 5+3 = 8 | 3+2 = 5 | the unfiled form in her drawer (C5), word for word; Mortimer 4,000,214 |
| Gerald (`npc.barnaby.intro` + `quest.dna_onboarding.offer`) | 4+3 = 7 | 2+2 = 4 | 4,000,212, "They're on 3", the book line, the temperamental machine; time clock by the front desk + breakroom machine; HR in the walls |
| Gerald freed (`.intro.freed` + offer) | 4+3 = 7 | 3+2 = 5 | CALLED; Agnes calling every number all night |
| Clerk Ledgerbone (`npc.pip.intro` + `quest.dna_audit.offer`) | 4+3 = 7 | 3+2 = 5 | flat one-liners, the haunted stamp wants a raise, Form 13-B (quiz answer hint); Ectomund's quiz + one hidden stash in the filing mazes |
| Brother Bramble (`npc.marigold.intro` + `quest.heap_dam.offer`) | 6+2 = 8 | 4+1 = 5 | the quiz box, word for word (waste removal and agriculture; animals turn garbage into fertilizer; magic helps the crops grow); Compostella and `{villain}`; "too alive" (echoes `rh_pool.before`); ends on "SOMEBODY ate the compost AGAIN"; the dam: north bank feeder channel, borrow a mount from the stables, charge it, compost boots |
| Wren Muckfoot (`npc.wren.intro` + `quest.heap_herd.offer`) | 4+3 = 7 | 2+3 = 5 | fluent goat; the stable mounts; the offer unchanged |
| Granny Gristle (`npc.hob.intro` + `quest.heap_fert.offer`) | 4+3 = 7 | 3+2 = 5 | the shed that grows, "Found, not stolen, dearie", one "Heh!"; three fertilizer sacks from around the Dump |
| Wren, Capital (`npc.wren.intro` + insights) | 4 (+0-3) | 3 (+0-3) | the records, Maren (C23), the Crease, the Wrinkles, tea and grudges, castle at the north end, "Talk to the streets" |
| Chet Thunderabs (gainlands `npc.minigame.intro`) | 8 | 5 | the show, legwarmers, the ban, "But WAIT, there's MORE!", Rep Counter rules, first-set bonus, "Operators are standing by" (`reps.first` calls it back) |
| Chef Flambe (gourmand `npc.minigame.intro`) | 9 | 5 | the whoosh, Savannah Souffle and the Test Kitchen, the Turbo Tots, ORDER UP rules, first-time bonus, sprouts and the cloche (`sign.studio`, `sign.taste_test`) |

Cut: Agnes's "Pending" / "Bring a cushion" asides, Gerald's "It's very freeing", Bramble's goat-pig-raccoon chain and "the Rot is breeding
in the still water", Gristle's "I'm not worried. I'm a bit worried", Capital Wren's "spy or a hero" and "Doctors, clerks, farmers, a goat",
Chet's egg-timer abs and "since 1989" (so item 15 above now only concerns Flambe's "two-thousand-three"), and Flambe's "Spaghetti Deluxe".

**Example (Bramble, 8 boxes -> 5).** Before: "...Our Archdruid, Compostella, went first. Something got into her roots." / "Now nothing rots, so
nothing feeds the soil. The plants are not dying. They are too alive, and the whole Dump is sick with growing." / "Also, SOMEBODY ate the
compost AGAIN." / "Somebody has dumped a dam of junk across the feeder channel on the north bank. The stream cannot breathe, and the Rot is
breeding in the still water." / "It needs something big and stubborn to run straight through it. Borrow a mount from the stables, charge the
junk dam, and the compost boots I've been keeping warm are yours."
After: "...Our Archdruid, Compostella, went first. Something got into her roots." / "Now nothing rots, so nothing feeds the soil.
Everything is too alive, and the whole Dump is sick with growing. Also, SOMEBODY ate the compost AGAIN." / "Somebody dumped a dam of junk
across the feeder channel on the north bank, and the stream cannot breathe. Borrow a mount from the stables, charge the dam, and my compost
boots are yours."

**Still over 5 (not in this task's list, not touched):** Basil (`npc.odalys.intro` + `quest.buf_mend.offer`) 7+4 = 11, Tarragon
(`npc.tarragon.intro` + `quest.buf_pantry.offer`) 7+3 = 10, Gus (`npc.gus.intro` + `quest.gain_power.offer`) 5+4 = 9, Old Man Mountain
(`npc.brenda.intro` + `quest.gain_spot_me.offer`) 6+3 = 9, Coach Benchley (`npc.tony.intro` + `quest.gain_lanes.offer`) 4+3 = 7, Widow
Pell 4+2 = 6, Chef Marlo 4+2 = 6. There is one edge case too: Capital Wren with all four insights before the first talk would run 3+3 = 6.

**Phase 2b: the rest of the long first talks.** Same rule (at most 5 boxes, each at most 200 characters; the longest is now 191). Text only
in `data/story/gourmand_story.tres`, `gainlands_story.tres` and `capital_story.tres`; no keys added or removed. Test substrings still there:
"Grandmaster Flex" and "regime" (`npc.brenda.intro`), "Special Sauce" (`npc.odalys.intro`). A `.freed` intro is trimmed when it plus the offer
went over 5.

| NPC (keys) | Before | After | Kept on purpose |
|---|---|---|---|
| Basil (`npc.odalys.intro` + `quest.buf_mend.offer`) | 7+4 = 11 | 3+2 = 5 | quiz facts (feed and protect the kingdom, every golem is a guard, nobody leaves hungry); "Chef ALWAYS tastes, and this Chef doesn't" (the "She never tastes" thread); Special Sauce, "Yes, Chef." Quietly, the Test Kitchen; Old Meatloaf: sea salt + black truffle, Sir Loin's Layer-Cake Town gate |
| Basil freed (`.intro.freed` + offer) | 4+4 = 8 | 3+2 = 5 | the Doppelganger, "YES, CHEF!"; the cake payoff "Is the boy all right?" word for word (C7) |
| Sous-Chef Tarragon (`npc.tarragon.intro` + `quest.buf_pantry.offer`) | 7+3 = 10 | 3+2 = 5 | fetching, legs with legs, deliveries vanishing into the Test Kitchen, the wrong (angry) pig (freed callback), "She just never tastes anything"; any three ingredients with the three spots, come back |
| Foreman Gus (`npc.gus.intro` + `quest.gain_power.offer`) | 5+4 = 9 | 3+2 = 5 | volunteers, humming, pre-workout in the water, 110 percent, the city wheels / "told it's cardio" (C18, Rollo); "Wouldn't that be a shame"; run the Colossal Hamster Wheel + buy a shake at the protein stand |
| Old Man Mountain (`npc.brenda.intro` + `quest.gain_spot_me.offer`) | 6+3 = 9 | 3+2 = 5 | regime, mills and hamster wheels, throw and portal, Clench as Flex's star pupil, "If you fall, I catch you", rule one / rule two "never skip leg day" (quiz), rule three forgotten; offer opens "Which brings me to rule one" (reads after `.return`'s "Where was I." too); spot Gary + Flex Mirror, Calf Cove |
| Old Man Mountain freed (`.intro.freed` + offer) | 5+3 = 8 | 3+2 = 5 | the boy at the Festival, and "you made the same face he did. Exactly the same face." still in its own box (C6) |
| Coach Benchley (`npc.tony.intro` + `quest.gain_lanes.offer`) | 4+3 = 7 | 3+2 = 5 | LET'S GO / NEW RECRUIT, supplements for your DECK, Regime-Approved Merchandise, the floorboard box word for word; three roaming enemies, any three, card duels |
| Widow Pell (`npc.pell.intro` + `quest.cap_burial.offer`) | 4+2 = 6 | 3+2 = 5 | every line kept, boxes merged: the 27-B / 27-C loop, "the patient one", talking to him |
| Chef Marlo (`npc.marlo.intro` + `quest.cap_recipes.offer`) | 4+2 = 6 | 3+2 = 5 | every line kept, boxes merged: Market of the Four Paths, Nutrient Distributor, `{villain}`'s paste, "a form is a hug" |

Already at 5 or under, not touched: Tarragon freed 2+2, Gus freed 3+2, Benchley freed 2+2, Pell freed 2+2, Marlo freed 2+2.
Cut: Basil's "everyone clears their own plate" rule and "golems say Yes, Chef! to a chef who doesn't cook" (signs carry the golem answer),
Tarragon's "grateful in alphabetical order", Gus's "You'll know when it does", Old Man Mountain's "If you quit, I don't", "hermit of the Swole
Station" and "the mills turn at a sensible pace" (freed), Benchley's "Cards, basically!". Not run in Godot (writer rule); `test_dialogue_fit`
should be run by the main session.

## Barks (Phase 2)

The passing lines in `data/npcs/npcs.json` (`"barks"`, shown by `world/npc_barks.gd` as a speech bubble: one line, picked at random,
label 20 px with word wrap at a 260 px minimum width, on screen 3.4 s; `tests/core/data/test_npc_truth.gd` requires every bark under 90
characters). 102 lines for 50 NPCs rewritten to the voice bible; Fig Sly's 2 left untouched (black market); the Secret Dealer has none.
Same ids, same count and order per NPC. Barks are picked at random (no index meaning), but `sample_line` mirrors `barks[0]` (tools/npc_truth.js
and the V-SABLE test), so the 50 `sample_line` values follow. The same text went into `tools/npc_truth_input.json` (the tool's input, so a
re-run keeps it) and `docs/design/npc_registry.csv` (the generated sheet: Sample Line and Barks cells). Longest bark now 81 characters.

Rules kept: barks are raw text (no token replacement in `NpcBarks`), so no `{tokens}` and no literal "Primm" (the old Kestrel line had one);
no banned names, no "Elowen", no real brands; the four gatekeepers stand in Crosspath both corrupted and freed (and Pallor freed in the D.N.A.),
so their lines are now true in either state; Primm's bark is postgame (workshop under guard), quiet and joke-free. Not run in Godot.

Scores: min of the five editor axes (in character / funny / beat / brevity / clarity), old (pre-pass text) and new.

| NPC | Old min (5 axes) | New min (5 axes) | What changed |
|---|---|---|---|
| Elder Maren (`NPC-ELDER`) | 3 (4/4/3/5/5) | 4 (5/4/4/5/5) | dearie + pie/kettle (C10 kettle echo) |
| Gatekeeper Brannoch (`NPC-GATEKEEPER`) | 3 (4/4/3/5/5) | 4 (5/4/5/5/5) | grunt + notebook ('Stranger, damp'), unlocked gate for Isla (C16) |
| Sable (`V-SABLE`) | 4 (5/4/4/5/5) | 4 (5/5/4/5/5) | misprints as personalities, never names a source |
| Tilly Tonic (`V-TONIC`) | 3 (3/4/4/5/5) | 4 (5/4/4/5/5) | old used full stops; now self-tested, frog colour ('I'm teal!') |
| Bertram Beetsworth (`V-BEETSWORTH`) | 4 (5/4/4/5/5) | 4 (5/4/4/5/5) | Fact:/Protocol, the drawer, Assistant TO |
| Pip Threadwell (`V-THREADWELL`) | 3 (4/4/3/5/5) | 4 (5/4/5/5/5) | 'Hat!' melodrama; hints the cloak on a muscly island (legendary cosmetic) |
| Foil Fenwick (`V-FENWICK`) | 3 (4/3/3/5/5) | 4 (5/4/5/5/5) | whispery 'Foil'; a pack arrives per freed road |
| Auntie Alembic (`V-ALEMBIC`) | 3 (4/4/3/5/5) | 4 (5/4/5/5/5) | the red flask; the Wellspring as legend (one spring fed all four Paths, no place or cause) |
| Announcer Grand Bellows (`NPC-BELLOWS`) | 4 (5/4/4/5/5) | 4 (5/5/4/5/5) | LOUD then a normal-voice aside; the cellar echo; narrates his lunch |
| Old Hob the Gravedigger (secretly Death) (`NPC-HOB`) | 3 (4/4/3/5/5) | 4 (5/4/5/5/5) | appointment book (sheet canon); slow business for ten years = the frozen D.N.A., unexplained |
| Brick Bronson (corrupted) (`NPC-BRONSON`) | 2 (3/4/2/5/5) | 4 (5/4/5/5/5) | old was corrupted-only but he stays in town after he is freed; now true in both states; plants C24 (the old man who never broke) |
| Prudence Pallor (corrupted) (`NPC-PALLOR`) | 3 (3/4/3/5/5) | 4 (5/4/4/5/5) | old was corrupted-only (she also stands freed in the D.N.A.); skeleton deadpan, the two stamps |
| Chef Fennel Gravois (corrupted) (`NPC-GRAVOIS`) | 3 (3/3/3/5/5) | 4 (5/4/4/5/5) | old 'the soup is the enemy' contradicted his TASTE IT voice; now taste + the ladle key |
| Moss Mulligan (corrupted) (`NPC-MULLIGAN`) | 2 (2/3/2/5/5) | 4 (5/4/4/5/5) | old 'Everything rots' is the opposite of her corruption (nothing rots); now 'the green is hungry' -> 'Did I thorn at you?', raccoons |
| Coach Brutus Benchley (`V-BENCHLEY`) | 3 (4/4/3/5/5) | 4 (5/4/4/5/5) | no calm sentence; regime-approved (not); the floorboard |
| Big Hurl (`NPC-HURL`) | 4 (5/4/4/5/5) | 4 (5/4/4/5/5) | countdown gag; 'never once missed' |
| Rip Tearson (`NPC-RIP`) | 3 (3/3/4/5/5) | 4 (5/4/4/5/5) | HNNNGH + polite clerk, the seam, shirt numbers |
| Professor Pump (`NPC-PUMP`) | 3 (4/3/4/5/5) | 4 (5/4/4/5/5) | brain-ceps; 'read the signs' (quiz answers are findable) |
| Chet Thunderabs (`NPC-THUNDERABS`) | 4 (4/4/4/5/5) | 4 (5/4/4/5/5) | infomercial parody (invented, no products) |
| Old Man Mountain (`NPC-MOUNTAIN`) | 3 (3/4/3/5/5) | 4 (5/4/5/5/5) | old read as a guru; now trailing grandpa, rule one, the Festival boy with four colours (C6) |
| Clerk Ledgerbone (`V-LEDGERBONE`) | 3 (4/3/4/5/5) | 4 (5/4/4/5/5) | old echoed a real song title; now Form 12-B joy, the stamp's raise |
| Director Ectomund (`NPC-ECTOMUND`) | 3 (4/3/4/5/5) | 4 (5/4/4/5/5) | 300 years of the same quiz; ethics questions removed by management |
| Kyle (Deceased Since '09) (`NPC-KYLE`) | 4 (4/4/4/5/5) | 4 (5/4/4/5/5) | lowercase, '09, away message, brb |
| Gerald (`NPC-GERALD`) | 4 (5/4/4/5/5) | 4 (5/4/4/5/5) | his number, 'They're on three', coffee nobody can taste |
| Agnes Overdue (`NPC-AGNES`) | 2 (2/4/2/5/5) | 4 (5/4/4/5/5) | old library jokes (voice bible: she is front desk, never a librarian); now 1987 + the denied appeals |
| Madame Mirepoix (`V-MIREPOIX`) | 3 (4/3/3/5/5) | 4 (5/4/4/5/5) | slow formal snoot; the decorative cake |
| Professor Pate (`NPC-PATE`) | 4 (4/4/4/5/5) | 4 (5/4/4/5/5) | roux lecture; tastes his chalk |
| Chef Flambe Fontaine (`NPC-FLAMBE`) | 4 (4/4/4/5/5) | 4 (5/4/4/5/5) | ORDER UP/WHOOSH; rival Savannah Souffle |
| Basil (`NPC-BASIL`) | 3 (3/4/3/5/5) | 4 (5/4/5/5/5) | whispered, jittery; 'Chef ALWAYS tastes' (the impostor thread); one pun, not two |
| Granny Gristle (`V-GRISTLE`) | 3 (4/4/3/5/5) | 4 (5/4/4/5/5) | 'Found, not stolen', the raccoon, the shed that grows |
| Druid Thistlewick (`NPC-THISTLEWICK`) | 3 (4/4/3/5/5) | 4 (5/4/4/5/5) | bins sermon; the dishwasher that talks back |
| Recycle Rhonda (`NPC-RHONDA`) | 3 (4/4/3/5/5) | 4 (5/4/4/5/5) | PSA slogan; secretly the voice of Captain Compost Badger |
| Brother Bramble (`NPC-BRAMBLE`) | 3 (3/4/3/5/5) | 4 (5/4/5/5/5) | soft then CAPS compost outburst; eleven birthday trees (C8) |
| Wren (`NPC-WREN`) | 3 (4/3/3/5/5) | 4 (5/4/4/5/5) | low and steady; 'He likes things perfect. We like things alive.' |
| Kestrel (`NPC-KESTREL`) | 3 (4/4/3/5/5) | 4 (5/4/4/5/5) | old had a literal 'Primm' (barks show raw text, no tokens); now chalk marks, teasing |
| Captain Spotless (`NPC-SPOTLESS`) | 4 (5/4/4/5/5) | 4 (5/5/4/5/5) | HALT + height; the smudge is on him |
| Widow Pell (`NPC-PELL`) | 2 (2/3/3/5/5) | 4 (5/4/4/5/5) | old 'Blink twice' was a citizen joke; now the 27-B/27-C loop and the patient husband (no punchline at the loss) |
| Rollo Spokes (`NPC-ROLLO`) | 2 (2/3/2/5/5) | 4 (5/4/5/5/5) | gasping between strokes; cardio lie + the Gainlands wheel crews (C18) |
| Chef Marlo (`NPC-MARLO`) | 3 (4/3/3/5/5) | 4 (5/4/4/5/5) | recipes as contraband, quantities as 'some' |
| Old Fern (`NPC-FERN`) | 3 (4/4/3/5/5) | 4 (5/4/4/5/5) | 'untidy' as a badge; worms in her hat |
| A Perfectly Happy Citizen (`NPC-CITIZEN`) | 4 (5/4/4/5/5) | 4 (5/4/4/5/5) | approved -> off -> whisper; the eight-degree smile (pays into Citizen 4471) |
| Grandmaster Flex (`NPC-FLEX`) | 3 (4/4/3/5/5) | 4 (5/4/5/5/5) | breath timing, 'son'; 'They took the iron' echoes C1 |
| The Grand Chef (formerly Grand Chef Escoffina) (`NPC-ESCOFFINA`) | 3 (5/3/4/5/5) | 4 (5/4/4/5/5) | 'Have you eaten? Sit. Eat.' + order-giving warmth |
| The Doppelganger (later named Escoffina) (`NPC-DOPPEL`) | 3 (5/3/4/5/5) | 4 (5/4/5/5/5) | salt, dishes, third-class apprentice, "I am trying" (freed_npc.escoffina) |
| Mortimer Grimsby (`NPC-MORTIMER`) | 4 (4/4/4/5/5) | 4 (5/4/5/5/5) | number 4,000,214, "understand Gerald" (C17); learning to wait, badly |
| Archdruid Compostella (`NPC-COMPOSTELLA`) | 3 (4/4/3/5/5) | 4 (5/4/4/5/5) | 'child', grows back; mortified about the barn and the goat |
| Primm (`NPC-PRIMM`) | 1 (4/4/1/5/5) | 4 (5/4/5/5/5) | old 'sweeping the square' contradicted the bible (locked workshop under guard); now the drain he designs (freed_npc.primm), no jokes |
| Isla Brannoch (`NPC-ISLA`) | 4 (5/4/4/5/5) | 4 (5/4/5/5/5) | eight years up the road, played straight (C16); not placed in the game yet |
| Bun the Baker (`NPC-VILLAGER`) | 4 (4/4/4/5/5) | 4 (5/4/4/5/5) | badger baker, one dough pun per line, flour whiskers |
| Crosspath townsfolk (`NPC-TOWNSFOLK`) | 2 (2/4/3/5/5) | 4 (5/4/5/5/5) | old dragon cousin (no dragons in Patchwork); now watched-town nerves, the Undercroft cheering, the humming well, the empty fountain plinths (crest 4.1) |

**Averages:** old 3.12, new 4.00 (50 NPCs). New per axis: in character 5.00, funny 4.06, beat 4.32,
brevity 5.00, clarity 5.00. Old per axis: 3.84 / 3.72 / 3.30 / 5.00 / 5.00. Every NPC is 4+ now; none needed a further fix.

**Callbacks planted or echoed:** C1 (Flex, the iron), C6 (Old Man Mountain, the Festival boy with four colours), C8 (Bramble, eleven trees),
C10 (Maren's kettle), C16 (Brannoch's unlocked gate, Isla's eight years), C17 (Mortimer 4,000,214 / Gerald), C18 (Rollo and the Gainlands
wheel crews), C24 (Bronson, the old man who never broke), 4.1 (the empty fountain plinths), 4.2 (the Wellspring as legend, the humming well),
Hob's appointment book and his ten slow years (the frozen D.N.A.), Basil's "Chef ALWAYS tastes".

### 8 best before -> after

1. **Primm** (`NPC-PRIMM` barks[0]): "I am sweeping the square. It is not perfect. I am learning to let that be." -> "I am designing a drain. It will not be perfect. I am learning to let that be."
2. **Agnes Overdue** (`NPC-AGNES` barks[1]): "Shh. This is a library. It's also a cemetery. Double shh." -> "Appeal forty thousand and one. Denied. I'm starting to take it personally."
3. **Crosspath townsfolk** (`NPC-TOWNSFOLK` barks[1]): "My cousin's a dragon. Long story. Mostly fire." -> "The old cottage cheers at night now. From the cellar. I'm choosing to love it."
4. **Brick Bronson (corrupted)** (`NPC-BRONSON` barks[0]): "Do you even lift, bro? I lift. Constantly. Help." -> "Never lift alone. An old man told me that. Never broke, they say. Huh."
5. **Moss Mulligan (corrupted)** (`NPC-MULLIGAN` barks[0]): "Everything rots. That's the fun part." -> "...the green is hungry... Oh! Sorry. Did I thorn at you? I thorn when nervous."
6. **Rollo Spokes** (`NPC-ROLLO` barks[1]): "Need a spoke? I've got loads." -> "Trained with... the Gainlands wheel crews. They told us... it was cardio."
7. **Gatekeeper Brannoch** (`NPC-GATEKEEPER` barks[0]): "The road's open. My knees are not." -> "Hm. Wrote you in the book. 'Stranger, damp.' I'll fix it when you know."
8. **Widow Pell** (`NPC-PELL` barks[1]): "The dead don't complain. That's what scares me." -> "27-B needs a 27-C. 27-C needs a 27-B. I've taken up knitting."

**Open:** Isla (`NPC-ISLA`) has barks but is not placed in any scene yet (C16, CODE). The Showcase citizens keep their facade lines
after the Capital is freed (barks have no freed variant; that would need code).
