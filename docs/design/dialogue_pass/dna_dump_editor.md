# Dialogue pass Oct 19: dna_dump editor review

Area `dna_dump`. Files: `data/story/dna_story.tres` (the D.N.A.) and `data/story/refusemancer_story.tres` (the Verdant Dump).
Old = `git show pre-overnight-oct19:<path>`; new = the writer's version (docs/design/dialogue_pass/dna_dump.md); final = after this edit.
Godot was not run and nothing was committed. Only the two story files and this report were touched.

Scores per conversation, 1-5: **C** in character, **F** funny (fit, not volume), **B** story beat landed, **L** brevity, **N** clarity of
what to do next. A conversation's score is the minimum of the five. The five numbers in the tables are the final ones.

First-talk note: `zone_scene.gd _talk_quest_npc` shows `npc.<id>.intro` + `quest.<id>.offer` as one conversation the first time, so an
NPC's intro and quest offer are scored together.

## The D.N.A. (`dna_story.tres`)

| # | Conversation (keys) | Old | New | Final | C F B L N | What changed (writer, then editor) |
|---|---|---|---|---|---|---|
| D1 | Agnes first talk (`npc.dolores.intro` + `quest.dna_backlog.offer`) | 2 | 3 | 4 | 5 4 5 4 4 | Writer: serving 3, you are 4,000,213, "We all know it's wrong", "Irregular things I can fight". Editor: intro 6 -> 5 boxes (paperwork and "works for him" in one box; "wrong / valid / smile" in one), first talk 9 -> 8 boxes |
| D2 | Agnes return (`npc.dolores.return`) | 3 | 4 | 4 | 5 4 5 4 4 | Re-split the Form 13-B box; "No remains, no certificate" (C5 kept) |
| D3 | Backlog quest (`quest.dna_backlog.active/ready/done`) | 3 | 4 | 4 | 5 4 4 5 5 | "Roaming staff, any floor"; "now he's my supervisor" |
| D4 | Agnes freed (`npc.dolores.intro.freed`, `.return.freed`) | 3 | 4 | 4 | 5 4 5 4 4 | Split long boxes; Mortimer is 4,000,214 |
| D5 | Gerald first talk (`npc.barnaby.intro` + `quest.dna_onboarding.offer`) | 2 | 4 | 4 | 5 4 5 4 4 | His number and "They're on 3" (C17); offer names the time clock by the front desk and the breakroom machine |
| D6 | Gerald return (`npc.barnaby.return`) | 3 | 4 | 4 | 5 5 4 5 4 | "Per my last email: they're still on 3" |
| D7 | Onboarding quest (`.active/.ready/.done`) | 3 | 4 | 4 | 5 4 4 4 5 | Places named; "I read it once, and I'm still in line" |
| D8 | Gerald freed (`npc.barnaby.intro.freed`, `.return.freed`) | 4 | 4 | 4 | 5 4 5 4 4 | Agnes called every number all night; "You were 213, in between us" |
| D9 | Ledgerbone (`npc.pip.intro`, `.return`) | 3 | 4 | 4 | 5 4 4 4 4 | Flat one-liners, no exclamation marks; stamp wants a raise |
| D10 | Audit quest (`quest.dna_audit.*`, Ledgerbone) | 3 | 4 | 4 | 4 4 4 4 5 | Names Director Ectomund and the filing mazes; "Oh. Oh, that's lovely." |
| D11 | Ledgerbone freed (`npc.pip.intro.freed`, `.return.freed`) | 3 | 4 | 4 | 5 4 4 5 4 | "It got its raise"; practising being un-busy |
| D12 | Ectomund quiz (`npc.quiz.*`, `quiz.*`) | 3 | 4 | 4 | 5 4 4 4 5 | 300 years of the same exam; "in triplicate, and then once more, for joy" |
| D13 | Kyle (`npc.matching.intro`, `.return`) | 1 | 4 | 4 | 5 4 4 4 4 | '09 not 2003/2001; one reference (dial-up); the unread transfer form (C20); 9 -> 5 boxes |
| D14 | Kyle's game lines (`match.*`) | 2 | 4 | 4 | 5 4 4 5 4 | Lowercase Kyle voice; "you've been bumped" |
| D15 | The queue (`fx.main_dungeon`, `dungeon.ha_lobby.before`, `ha_number.blurb`, `event.ha_take_a_number.*`) | 2 | 4 | 4 | 5 4 5 4 4 | 40,001 -> 4,000,213 everywhere; Gerald's biscuit |
| D16 | Agnes in the Hall (`dungeon.ha_number.before`, `ha_forms.before`) | 3 | 4 | 4 | 5 4 5 4 4 | Neighbour of Gerald; "on my lunch hour, appellant" explains why she is in the queue |
| D17 | Records Labyrinth (`dungeon.ha_records.before`) | 3 | 4 | 4 | 5 4 5 4 4 | Literal "Primm" -> `{villain}`; "Irregular," very quietly (C5) |
| D18 | Vellum (`dungeon.ha_clerk.before/.after`) | 4 | 4 | 4 | 5 4 4 5 4 | Squares his papers; "Noted." |
| D19 | Mortimer (`dungeon.ha_boss.before/.after`) | 3 | 4 | 4 | 5 4 5 4 4 | Box 1 split; "Tuesday is not a business day in this building" explains the win |
| D20 | The vacancy (`cutscene.vacancy.1-6`) | 3 | 4 | 4 | 5 4 5 5 4 | "you, Ms. Overdue" makes clear who inherits; "I would have to deny it" |
| D21 | Agnes's closing (`freed_npc.agnes`) | 2 | 4 | 4 | 5 4 5 4 4 | 7 -> 5 boxes; sincere lines kept word for word (C3) |
| D22 | Prudence freed (`freed_npc.prudence`) | 3 | 4 | 4 | 5 4 5 5 4 | "{villain} did not corrupt us... He used our own rules." |
| D23 | Mortimer freed (`freed_npc.mortimer`) | 4 | 4 | 4 | 5 4 5 4 4 | 212-213-214 payoff (C17) |
| D24 | Hall events and nodes (`event.ha_form_*`, `ha_notary`, `ha_compliance.after`, `ha_waiting.after`) | 3 | 4 | 4 | 4 4 4 4 4 | Long single boxes split; Form 12-F tea line |
| D25 | Zone narration (`fx.*`, `hud.objective*`) | 4 | 4 | 4 | 4 4 4 4 4 | `fx.wake` split; little else |
| D26 | Signs, memos, posters, statue | 3 | 4 | 4 | 4 5 4 4 4 | `sign.now_serving` ONE -> THREE, "Regime of Final Approvals" -> the Department; the statue "has taken a number" |
| D27 | Enemies (`enemy.*`) | 3 | 4 | 4 | 4 4 4 4 4 | "evil" -> "wrong" (Primm is sincere and wrong) |
| D28 | Soul-routing puzzle (`puzzle.*`) | 3 | 4 | 4 | 4 4 4 4 4 | "Dame Basil" -> "Dame Wilhelmina" (Basil is the Buffet's rabbit) |

## The Verdant Dump (`refusemancer_story.tres`)

| # | Conversation (keys) | Old | New | Final | C F B L N | What changed (writer, then editor) |
|---|---|---|---|---|---|---|
| R1 | Bramble first talk (`npc.marigold.intro` + `quest.heap_dam.offer`) | 1 | 3 | 4 | 5 4 5 4 4 | Writer: 9 -> 7 boxes, quiz facts in one box, ends on "SOMEBODY ate the compost AGAIN". Editor: 7 -> 6 boxes (magic, `{villain}` and Compostella in one box; "nothing rots / too alive" in one), first talk 9 -> 8 boxes. All three quiz sources kept in box 2 |
| R2 | Bramble return (`npc.marigold.return`) | 3 | 4 | 4 | 5 4 5 4 4 | "Not long ago" (C9); new twelfth-spot box (C8) |
| R3 | Dam quest (`quest.heap_dam.active/ready/done`) | 4 | 4 | 4 | 4 4 4 5 5 | Small tightening |
| R4 | Bramble freed (`npc.marigold.intro.freed`, `.return.freed`) | 3 | 4 | 4 | 5 4 5 4 4 | Twelfth tree split into its own beat; compost-thief callback |
| R5 | Gristle first talk (`npc.hob.intro` + `quest.heap_fert.offer`, `fx.wake`) | 2 | 4 | 4 | 5 4 4 4 4 | Writer: she runs the shed, not the Grange; "Found, not stolen, dearie". Editor: cut one of three "Heh!"s in a row (tic stacking) |
| R6 | Gristle return (`npc.hob.return`) | 2 | 4 | 4 | 4 4 4 5 4 | Banned vendor catchphrase "The cards are fresh" removed |
| R7 | Fertilizer quest (`quest.heap_fert.active/ready/done`) | 3 | 4 | 4 | 5 4 4 5 5 | "Follow your nose. Then apologise to it." |
| R8 | Gristle freed (`npc.hob.*.freed`) | 3 | 4 | 4 | 5 4 4 5 4 | Same catchphrase removed |
| R9 | Wren first talk (`npc.wren.intro` + `quest.heap_herd.offer`) | 2 | 4 | 4 | 5 4 4 4 4 | 6+3 -> 4+3 boxes; mounts explained |
| R10 | Wren return + herd active | 4 | 4 | 4 | 5 5 4 5 4 | "a strongly worded letter" |
| R11 | Herd hand-in + Druid Sorrel (`quest.heap_herd.ready/done`, `grow.bridge_center.*`, `sign.bridge_center`) | 2 | 4 | 4 | 4 4 4 4 5 | Sorrel is placed: "at the centre bridge will grow you a crossing now" |
| R12 | Wren freed | 4 | 4 | 4 | 5 4 4 5 4 | Contractions only |
| R13 | Thistlewick quiz (`npc.quiz.*`, `quiz.*`) | 3 | 4 | 4 | 5 4 4 4 5 | "Sort your thoughts like your bins"; the dishwasher callback |
| R14 | Rhonda (`npc.minigame.intro`, `.return`) | 1 | 3 | 4 | 5 4 4 4 4 | Writer: six 200+ boxes cut to six short ones. Editor: 6 -> 4 boxes; dropped the ribbon box (ribbons stay in `sort.win`, `.return`, `sign.fair`) and joined "cancel ME!" with the show pitch. The rules stay (and `sort.intro` repeats them) |
| R15 | Sort results (`sort.win/first/lose`) | 4 | 4 | 4 | 5 4 4 5 4 | "Recy-CLUE" |
| R16 | Worker barks (`bark.worker_1..3`) | 3 | 4 | 4 | 5 4 4 5 4 | Order kept; the purple beans; the crying raccoon |
| R17 | Rotheart nodes and events (`fx.main_dungeon`, `rh_gate`, `rh_pool`, `rh_soil`, `rh_golem`, mushrooms, wall) | 3 | 4 | 4 | 5 4 5 4 4 | The clean-water thread in `rh_soil.after` (4.2, no lore added); Bramble's notes |
| R18 | The seed (`dungeon.rh_roots.before`) | 3 | 4 | 4 | 5 4 5 4 4 | Split into 4 boxes; tag "in very tidy handwriting" (C21) |
| R19 | Compostella boss (`dungeon.rh_boss.before/.after`) | 3 | 4 | 4 | 5 4 5 4 4 | Split; the goat eats a sign |
| R20 | The sever (`cutscene.sever.1-4`) | 3 | 4 | 4 | 5 5 5 4 4 | `{villain}`'s gift; the scene ends on her and the tree, not the plot |
| R21 | Compostella's closing (`freed_npc.compostella`) | 3 | 3 | 4 | 5 4 5 4 4 | Editor: 7 -> 6 boxes (goat + "Plant something" in one); cut the writer's added goat joke from the sincere run; C4 "do not bury it in a jar" kept word for word |
| R22 | Zone narration (`fx.*`, `hud.*`) | 4 | 4 | 4 | 4 4 4 4 4 | Gristle's `fx.wake` gets "dearie" |
| R23 | Signs and props | 3 | 4 | 4 | 4 4 4 4 4 | "HOB'S SWAP SHED" -> "GRANNY GRISTLE'S"; Moss Mulligan named on the exit signs |
| R24 | Enemies (`enemy.*`) | 3 | 4 | 4 | 4 4 4 4 4 | Tighter |
| R25 | Garden puzzle and bean mounds (`growth.*`, `grow.bridge_west/east`, `grow.ladder_*`) | 4 | 4 | 4 | 4 4 4 4 4 | Unchanged |

## Area averages (of the conversation minimums)

| | Conversations | Old | New, before edit | Final |
|---|---|---|---|---|
| The D.N.A. | 28 | 2.89 | 3.96 | 4.00 |
| The Verdant Dump | 25 | 2.92 | 3.88 | 4.00 |
| **dna_dump** | **53** | **2.91** | **3.92** | **4.00** |

I rewrote 4 conversations because they scored under 4 (D1, R1, R14, R21), plus one polish (R5, the stacked "Heh!"). Each one is 4 or higher now.

## Scan results (both files, final)

- No box over 240 characters in dialogue. The only text values over 240 are `ui.main.body` in both files (364 and 355). That is the
  dungeon-entry popup body, not a dialogue box; `ui.*` is not checked by `test_dialogue_fit.gd`, and the writers did not change it. Left as is.
- Longest spoken or narrated story box: 193 (`dungeon.ha_records.before` box 1). The longest text overall is in instruction and
  description panels, all unchanged by the pass and under 240: `growth.intro` 233, the Dump `hud.objective` 228, `sort.intro` 219,
  `enemy.golem` 202.
- No banned old names, no "Elowen", no literal "Primm" outside `.speaker` values, no real brands, nothing mean-spirited. The only token
  is `{villain}`.
- Key sets are unchanged (226 and 232 keys). `quiz_questions` are untouched. The arrays I shortened (`npc.dolores.intro`,
  `npc.marigold.intro`, `npc.minigame.intro`, `freed_npc.compostella`) are read whole (`get_lines`, `_greeting`, `freed_npc.%s`).

## Needs code or a decision (for the user)

1. **First talks are long because of the code.** `_talk_quest_npc` joins the intro and the quest offer into one conversation, so Agnes,
   Bramble, Gerald, Wren and Ledgerbone run 7-8 boxes on first meeting, even though each box is short. A code change could show the offer
   on the second talk, or after a prompt.
2. **Agnes meets you twice as a stranger.** `dungeon.ha_number.before` ("Number 4,000,213? Oh, you're new.") plays even if you already met
   her at the front desk. Fixing it needs a met-flag variant key, and the code would have to read it.
3. **Quest-log summaries with the wrong pronoun** are code strings (writer's note): `heap_dam` "she will reward you" (Bramble is he); Root
   Cause "a voice that isn't his" (Moss is she).
4. **No freed variants** for the worker barks (`bark.worker_N.freed`), Kyle or Ectomund. After the cure, "Those purple trees... Nobody's
   talking about it" still plays. Adding the keys is allowed only if the code reads them; the generic `.freed` lookup would.
5. **Druid Sorrel** speaks in game (`heap_growth.gd`, `grow.bridge_center.*`) but has no voice-bible entry and is not on the sheet, and the
   voice bible's Wren entry says "no unseen Druid Sorrel". Keep her (and add her to the bible) or retire her (code). The text now places her
   clearly.
6. **Open name clashes** (inbox): Wren Muckfoot vs Wren; Recycle Rhonda vs the Gainlands ripper Rhonda.
7. **`cutscene.vacancy.6`** "You are right behind Gerald" (canon, kept) sits a little oddly beside 4,000,213 being the player. The text
   reconciles it (`freed_npc.mortimer`, "You did not wait"), so no change is needed unless the user wants the canon line changed.

## 5 best final before -> after

1. **`cutscene.sever.4`**
   Before: "...It is rotting. Honest compost, the first in ten years. I can hear the soil." / "I can hear the stream. I can hear the goat. To grow,
   I had to let go." / "Thank you. {villain}'s grip on the living world is broken."
   After: "...It is rotting. Honest compost, the first in ten years. Oh. I can hear the soil again." / "I can hear the stream. I can hear the
   goat." / "And I can hear her, a little, in all of it. She did not go away. She went into everything." / "To grow, I had to let her go.
   ...I think she has been waiting ten years for me to say so."

2. **`npc.marigold.return`** (Bramble)
   Before: "...There's a row of them past the stream. Eleven trees, then nothing." / "A few months back, somebody carried a sleeping young
   man through these woods at night..."
   After: "...There is a row of them past the stream. Eleven trees. Then nothing." / "I water the twelfth spot anyway. I couldn't tell you
   why. It feels as if somebody is still coming." / "Not long ago, somebody carried a sleeping young man through these woods at night..."

3. **`npc.dolores.intro`** (Agnes, final)
   Before: "Take a number. We're serving number one. Have been for seven hundred years. He's very thorough." / "...Properly. Now the whole
   department works for him. I know he's evil." / "We all know. But the authorization is valid."
   After: "Take a number. Yours is 4,000,213. We're serving number 3. Bring a cushion." / "Ten years ago, {villain}'s people filed some
   paperwork. Reviewed, approved, notarized, filed. Properly. Now the whole Department works for him." / "We all know it's wrong. But the
   authorization is valid. Irregular things I can fight, dear. Valid things just sit there and smile at you."

4. **`npc.matching.intro`** (Kyle)
   Before: "I'm Kyle. Last employee of the month of 2003. My away message still says 'brb, getting a snack'." / "That was my snack. In 2003.
   I have been here through the transfer." / "I filed the paperwork myself. I did not read it." (and six more boxes)
   After: "i'm Kyle. deceased since '09. runner-up, employee of the month, 2009. Agnes won. Agnes always wins." / "fun fact: ten years ago
   i filed the big transfer form. didn't read it. who reads forms." / "...oh. right. Necrocrats. we read forms. that's, like, our whole
   thing."

5. **`dungeon.ha_boss.after`** (Mortimer)
   Before: "\"...Oh,\" says Mortimer. \"Oh no. The authorization is valid." / "It was always valid. But the office is vacant, and policy is
   policy.\""
   After: "\"...Oh,\" says Mortimer. \"Oh, no. Tuesday is not a business day in this building." / "The authorization was valid. It was
   always valid. But the office is vacant, and policy is policy.\""
