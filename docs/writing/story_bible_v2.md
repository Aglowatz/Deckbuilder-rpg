# Story bible v2 (The Wayward Path)

Written Nov 13 2026 for the dialogue rewrite of that night (`docs/prompts/fable_nov13_dialogue.md`). It is drawn from what the game contains
today: every line in `docs/dialogue/rewrite_nov13_base.csv`, the quest definitions and the zone, boss and NPC data. Where it disagrees with
`docs/design/story_bible.md` (Oct 19), this file wins on story and the game's data wins on names. It changes nothing the game does: no quest,
place, name, number or rule. It says what the story is about, so that every scene can pull the same way.

Line IDs are the ones in the export (`<file>::<key>::<index>`); `intro` = `data/story/intro_story.tres`, `capital` = `data/story/capital_story.tres`,
`gainlands`, `gourmand`, `dna`, `refusemancer` = the zone story files, `scenes` = `data/story/story_scenes.json::scenes`.

## 1. The through-line

**One sentence:** a boy who was kept in a glass room so that a kingdom could be made all one shape walks out with nothing, is taken in by a
town of mismatched people, and learns from four peoples what the man who kept him never understood: that a thing made of different pieces,
stitched together and allowed to pull against each other, is stronger and kinder than a thing made perfect.

**Who the hero is.** The Wanderer is Prince Tessar Wayweaver, twenty-one. He was eleven when Primm killed his parents, and he has spent the
ten years since in the Path-ology Lab under the forest, called "the Subject", drained of the royal gift that holds the four Paths together.
He wakes in the first scene with no name and no memory. He is not a chosen hero in his own mind. He is a tired, polite young man who notices
things, asks plain questions and keeps his promises, and people keep being kind to him before he has earned it.

**What he lost.** Four fragments come back, one for each zone freed, always told to Maren by her fire:
1. *Warmth:* four colours on a ceiling, a hand on his head, a woman humming a lullaby. He had a mother.
2. *The Cells:* white rooms, glass, white coats, the word "again". "I wasn't lost. I was kept."
3. *The Coup:* the throne room at night, a man in white and gold who kneels and then rises, two pairs of hands pushing him behind them.
4. *A Name:* a courtyard, his mother's voice calling him, the crest of four signs in a ring on every door.

The order matters. He remembers being loved first, then being kept, then who did it, and only then who he is. By the time he has a name he
already knows what it cost.

**What he wants.** At the start, only to know who he is. By the middle, a place to belong: Maren's kitchen is the first room in ten years
where nobody is measuring him. By the end he wants the same thing for everyone else. "Home" is the word the story keeps handing back to him:
Maren's "so we are never far from home", Brannoch's gate that is never locked in case someone comes home late, the Old Well humming "like a
kettle kept warm for whoever comes home", the King's "You came home", Maren's "Welcome home".

**What Primm's perfection costs.** Primm did not conquer the Paths, he corrected them. Each zone shows one Path with the thing that made it
itself taken out, by people who thought they were helping:
- the Beefcakes lost rest and each other (strength became output, measured by Quota's stopwatch);
- the Gourmands lost taste (food became the Special Sauce and then paste, cooked by someone who cannot taste);
- the Necrocrats lost mercy (the rules stayed valid and stopped being right; the dead cannot pass on);
- the Refusemancers lost endings (nothing may rot, so nothing can grow).

In the Capital all four losses arrive in one city: Blackout, Famine, Restless Dead, Clutter. A perfect street, and behind it people who have
forgotten their names.

**What Patchwork means.** The kingdom's name is the theme. A patchwork is made from pieces that do not match, and its strength is in the
seams. The four Paths argue "like family", and the old Queen "used to say that was the point" (`scenes/royal_funeral/steps/4`). The royal
gift was never the power to rule the Paths. It was the power to hold four different things at once without making them one. The Old Well
says it plainly: "It does not run for one shape. It runs for many, held together." Primm wanted a kingdom without seams. The ending is a
sign that goes up crooked and stays up.

The image family the rewrite uses, sparingly, for this: thread, seams, stitches, patches, mending; four colours in one thread; a ring of four
signs. Pip the tailor and Maren may say it outright once each. Nobody else lectures about it.

**How the hero changes.** He begins as someone things are done to: woken, hidden, sent, fed. In each zone he watches someone who lost
everything keep the part that matters, and each of them gives him a sentence he will need:
- Flex: "Whatever they took from you, son, it was not the part that matters."
- The Grand Chef: not knowing your name "isn't a flaw, it's a blank page. Go and do something worth signing."
- Agnes: "Never let anyone file you under 'subject' again."
- Compostella: "The ones we lose aren't gone. They go into everything."

In the Model Room he gives all four back to Primm in his own words. And at the very end he does the one thing Primm never could: he does not
correct him. "I'm not going to correct you; that was always your way. I'm not going to forgive you either, not today. Start smaller than a
kingdom. Say sorry to one person." The boy who was kept becomes a man who can hold a kingdom loosely.

## 2. The four Path zones as chapters

The zones can be played in any order, so each is a whole story, and each leaves the hero with one of the four sentences above. In every zone
there is also one ordinary person who remembers a little prince and looks at the Wanderer a moment too long. These four small memories are
the same boy seen from four sides, and Elowen gathers two of them up at the cave mouth (`scenes/cave_mouth_3/steps/3`).

### The Gainlands: "Raise the Bar" (strength)
- **The mini story.** A proud, worn-out people keep the kingdom's lights on by running wheels at a hundred and ten percent. Their teacher,
  Grandmaster Flex, has been ten years in a cell with no weights. His best pupil, Clench, rules in his place and guards the last bench press
  like a throne. The hero frees Flex, who walks into the hall thin as wire and is stronger than everyone in it.
- **Its emotional beat.** A teacher who will not stop loving the student who jailed him. Flex offers Clench his hand. Clench "does not take
  it yet, but he does not pull away."
- **What it adds.** The lesson: strength lives in the heart and the mind, and nobody can lock those in a cell. For the hero, who has just
  learned or will learn that he was kept in a cell too: what was taken from him was not the part that matters. The bare cell "tightens your
  chest, and you couldn't say why" (`gainlands::event.hg_rescue.body::2`).
- **The prince remembered.** Old Man Mountain: the king's boy tried his dumbbell at the Lifting Festival and sat down hard, laughing.
- **Pointing to the Capital.** Foreman Gus: the crews on the city wheels have it worse, and are told it is cardio. Quota, who "does the
  arithmetic", flees to the Capital and is met again at Rollo's wheels. In the castle's Beefcake wing, the margin note: "We took everything
  from him and he got stronger. I do not understand it."
- **Ally gained.** Flex, and his boon in the Model Room.

### The Endless Buffet: "Key Ingredients" (identity)
- **The mini story.** The kitchens that fed the kingdom are making cannons, and every pot has the Special Sauce in it. The cooks have noticed
  for ten years that the Grand Chef no longer tastes her soup, and not one of them has said so aloud. She is a Doppelganger with no face of
  its own. The real Chef is in the walk-in freezer.
- **Its emotional beat.** The Grand Chef proves who she is "not with a speech, and not with papers. With dinner." Then, instead of punishing
  the creature that wore her face, she gives it her old name and a place at the stove.
- **What it adds.** The lesson: what you are called matters far less than what you do. For a hero with no name, the first hint that the
  answer to "who am I" is not a word.
- **The prince remembered.** Basil: the four-layer birthday cake, one layer for each Path, and a little prince who licked the frosting off
  all four. The Chef's first words out of the freezer: "Is the boy all right?"
- **Pointing to the Capital.** The reveal names where the orders came from (`gourmand::cutscene.reveal.3`). Colonel Crumb, who cannot taste
  either, leaves "before dessert" to feed the Capital grey paste from a tap. Chef Marlo's insight: Primm cannot taste. Professor Pate's
  footnote on the school lunches.
- **Ally gained.** The Grand Chef, and her boon; Escoffina as proof that a person can start again.

### The D.N.A.: "Take a Number" (dignity)
- **The mini story.** The Department that looks after the dead was not conquered. A perfectly valid form signed it over, and Necrocrats obey
  a valid form. Since then nobody has passed on. The queue is on 3. Agnes Overdue, a ghost at the front desk, has filed forty thousand
  appeals on her lunch hours. At the bottom of the pile is a clerk's note: the transfer was filed on a Tuesday, and nothing is filed on a
  Tuesday.
- **Its emotional beat.** Agnes "only ever wanted to leave", wins the office she never asked for, and stays "until nobody has to wait as
  long as I did."
- **What it adds.** The lesson: everyone in the queue was somebody; no order outranks treating people as people. It is the zone where
  Primm's method is clearest ("I did not need to force anyone. I needed only to be correct."). It also plants the heir: the transfer's
  clause reads "Deceased (presumed). Remains: not on file", and Agnes calls it an incomplete form.
- **The prince remembered.** Agnes stamped the King's funeral form and the Queen's, and her hand shook. There was a third form, for the
  little prince. She never filed it.
- **Pointing to the Capital.** Percival Plume, who drafted the transfer, cuts a ribbon and hurries back to "a Capital to reassure". Widow
  Pell's husband waits three years for the same Form 27-B.
- **Ally gained.** Agnes, whose "technicality" is her boon, and who stamps HEIR: ALIVE in the ending.

### The Verdant Dump: "Root Cause" (letting go)
- **The mini story.** The druids who turn the kingdom's waste into harvests are being swallowed by their own fields. Nothing has died in the
  valley for ten years. Their Archdruid went down to the deep roots and never came up. She was grieving a great tree she grew up under, and
  a tidy woman with shears brought her a gift: a seed of life that never ends.
- **Its emotional beat.** The quietest and saddest of the four. Under the many voices of the Rotheart there is one small one: "Please. The
  tree. I could not let her go." She lets the seed die with the hero holding on to her.
- **What it adds.** The lesson: to grow, you have to let things go. The hero is carrying two deaths he cannot yet name. Compostella sees it:
  "You're carrying a loss you can't name yet, child." This is the sentence that lets him stand at two headstones in the epilogue.
- **The prince remembered.** Brother Bramble: the Archdruid planted a tree for every royal birthday. Eleven trees, and he waters the twelfth
  spot. After the zone is freed, Compostella plants the twelfth.
- **Pointing to the Capital.** The seed's tag: PROPERTY OF THE PATH-OLOGISTS. Clipwell walks off up the Capital road and is met again
  measuring Old Fern's seedling. Old Fern's insight: Primm is afraid of anything that grows without asking him first.
- **Ally gained.** Compostella and her boon ("Even him. Especially him.").

### How the four add up
| | Primm's belief | What the zone answers | The hero's line to Primm |
|---|---|---|---|
| Gainlands | Strength is control | Strength is what is left when everything is taken | `capital::cutscene.primm_p1.2` |
| Buffet | The right face and the right name are enough | A name is a blank page until you sign it | `capital::cutscene.primm_p2.2` |
| D.N.A. | What is valid is right | No order outranks respect | `capital::cutscene.primm_p2.2` |
| Dump | Nothing should ever be lost | Nothing grows where nothing is allowed to end | `capital::cutscene.primm_end.3` |

## 3. The Capital, Primm and the ending

### Primm as a person
Primm was a thin, anxious, kind young clerk who became the Royal Minister of Improvements, and he was good at it. He dug six wells because
half the lower city walked two miles for water. He put a hot lunch in front of every schoolchild, and when a little girl told him warm soup
was "the best idea anyone has ever had", he framed it. The castle's Blueprint Vault is full of plans that are "good, genuinely good".

What went wrong in him is small and human, and the Capital's four quest-givers each hold a piece of it:
- **He cannot taste** (Marlo). He never knew what the rest of them were missing, so he could not see why paste was a loss.
- **He cannot bear to watch grief** (Widow Pell). So he scheduled it: Thursdays, 3:00 to 3:05.
- **He cannot wait** (Rollo). Lateness is disagreement. "He's always in a hurry... to be loved."
- **He is afraid of anything that grows without asking him** (Old Fern). "Weeds, moss, children."

Wren puts them together: "He's a man who made a list of everything he couldn't control, and then made it illegal." And: "He is not a monster."

**Why he wants perfection.** Because every good thing he made could still go wrong once it left his hands. A well can be fouled, a lunch can
be late, a king can be sentimental. He stopped asking people whether they wanted the next improvement and started making sure they could
not refuse it. He put his name on every well. The escalation shelf in his archive says it as a joke: school lunches, lunch rules, lunch
inspectors, inspector rules.

**What he is afraid of.** Being surprised. Being wrong. And underneath both, that he is not kind. His last journal: "I do not think anyone
has ever tried so hard to be kind. I only wish somebody would say so." Everything he does in the final scene is a request to be told he was
right, and the cruellest and truest thing the hero can do is not answer.

**What he did.** He knelt to King Harmon, rose, and killed him and Queen Concordia. He "removed two people so that a whole kingdom could be
safe" and "did the sums twice". He kept their son, because the royal gift could hold the Paths in one shape if it was drained from the boy
and routed to the Throne. He kept the boy's portrait in the one gallery nobody may clean, his parents painted over in white, with a card:
KEPT FOR REFERENCE. He believes he looked after him: fed at seven, at noon and at six, never once cold.

**How he talks.** Graciously. Long, balanced sentences with an exact last clause, no contractions while he is in control, thanks given "in
writing". He never shouts and never gloats. He comes apart in his grammar before he comes apart anywhere else.

### The reveal schedule
| When | What the player learns | Where |
|---|---|---|
| Prologue | You were held somewhere terrible; someone got you out; "Path-ologists" are hunting you; you can feel all four Paths | `intro::prologue.*` |
| The cave | A door that only one may pass, "and he is long dead", opens for your hand | `intro::tutorial.warden.*` |
| Crosspath | Ten years ago the kingdom was whole; the Minister of Improvements took the Paths one by one; Maren did not want this and knows more than she says | `intro::cave_mouth.*`, `intro::town.elder.first` |
| Each zone | One Path's wound, one leader's lesson, one person who remembers a little prince | zone files |
| Fragment 1 | A lullaby from the old court; a second Path opens to you | `intro::memory.1.*` |
| Fragment 2 | You were kept. Maren is the resistance's contact; Wren leads it from the Capital | `intro::memory.2.*` |
| Fragment 3 | The coup, and Primm's face. Maren founded Path-ology and "helped to blow that glass" | `intro::memory.3.*` |
| Fragment 4 | Your name. Maren knew from the moment the Warden let you through | `intro::memory.4.*` |
| Cave mouth 1-4 | The Rescuer keeps watch from outside the town; she knew a boy; she promises her name "first", after | `scenes/cave_mouth_*` |
| The Capital | Posters for an "escaped royal asset"; Primm's four fears; "It began the night the boy got out" | `capital::npc.*`, `capital::quest.cap_*` |
| The castle gate | Plume names the Rescuer and takes her "home", to her father | `scenes/pc_capture` |
| The castle | How each Path was taken, in Primm's own neat hand, with a second, shaking hand in the margins; Maren's Year 1 note; the portrait | `capital::dungeon.pc_*` |
| The Model Room | Primm in person. (If the fourth fragment has not been seen, he tells you who you are.) | `capital::cutscene.primm_*` |
| Ending | The Pathwork Throne knows you. Agnes stamps HEIR: ALIVE. Maren says your name to the kingdom | `capital::ending.beat.*` |
| Epilogue | Isla comes home; the King and Queen are buried and seen once more | `scenes/isla_homecoming`, `scenes/royal_funeral` |
| Postgame | The Lab under the forest; Dr. Siphon held the door on the night of the coup; he is Elowen's father | `scenes/lab_*` |

### The emotional peak
It is not the last blow of the fight. It is the silence after `capital::cutscene.primm_end.4`, when Primm lays out the sums ("Tell me which
part of that was unkind. I should like it in writing.") and the hero says nothing, and Primm, waiting for a correction that does not come,
reaches the truth by himself: "a world where nothing surprises you is a world with nobody else in it." The still that follows says it for
the player: "It does not feel like winning. It feels like the end of a long, quiet lie."

The scenes before it are built to make that silence heavy: the portrait with the white paint, Maren's note in the ward ("The child is not a
specimen. He asks for his mother."), the Last Journal.

### The resolution
The model lies in pieces and "somehow they look better". Under the Model Room is the Pathwork Throne, four seats grown into one. It was
never Primm's. It says the hero's name back to him and brings the Paths with it, "as they were always meant to be carried". The facade
falls; a child paints PATHORDIA on the gate; the four leaders meet in the plaza and agree on nothing; a sign goes up crooked. Primm lives.
He is under guard, kept away from every Path, reading the list of the eleven thousand people he corrected (he is on the third page) and
designing a water main, "the first thing I have made in ten years that nobody had to agree to."

### The epilogue
- **Isla.** Brannoch has written "Isla. Not yet." in his notebook every day for eight years. "Today it says 'home'."
- **The funeral.** Old Hob has been digging two graves for ten years, slowly, so as not to finish before they could be visited. Agnes tears
  up the third form. Maren: "He used to say the Paths argued like family. She used to say that was the point." The King: "Look at you. You
  came home." The Queen: "Carry them gently, love. All four of them." She hums the lullaby from the first fragment and does not need to
  finish it.
- **Maren.** She says his name to the kingdom, with flour on her sleeve, and then says the truest thing in her character: "Eat first. Then
  go and fetch her home."

### The postgame hook
- **The Path-ology Lab.** The brambles south of the clearing where the game began let go, and there is a hatch. Rip will not open it: "it
  feels like yours to open." Down there is Cell 4, the hero's own cell, with ten years of tally marks and a child's drawing in four
  colours, and Elowen under it. She calls him Tess. Her father, Dr. Ambrose Siphon, Maren's best student, kept the Lab running and held the
  east door open on the night of the coup. He is delighted to see them both, and that is the horror of him. When the tanks go dark the four
  colours rise into the forest: "You do not feel stronger. You feel less alone." She says her name properly, "somewhere with a roof".
- **The Shattered Gallery.** A mirror by the castle door has cracked from the inside and still shows the kingdom that never was. Every frame
  holds someone the hero beat, "perfect and cold". The last holds the hero as Primm would have made him.
- **Mount Swolympus** opens "when the kingdom is whole again", and the Ancient Spotter finally sets something down.

## 4. Plants and payoffs

Each pair is already in the game's lines; the rewrite keeps both ends and makes sure the words match.

| # | Plant | Payoff |
|---|---|---|
| 1 | **Voices through a wall.** The Wanderer feels all four Paths "faintly. Like voices through a wall." `intro::prologue.wanderer.2::0` | Elowen, when all four zones are free: "like voices through a wall, except now the wall's coming down." `scenes/cave_mouth_4/steps/1::1` |
| 2 | **The door that knows one hand.** "Only one may pass this door, and he is long dead." `intro::tutorial.warden.before::2`; "The door knows your hand." `intro::tutorial.warden.after::0` | Maren: "The Warden opens that tunnel for one family only, and I knew it the moment you walked out of it." `intro::memory.4.after::2` |
| 3 | **The lullaby.** A woman humming a tune with no words. `intro::memory.1.fragment::1`; Maren: "That tune is from the old court." `intro::memory.1.after::0` | The Queen "hums the first bars of the lullaby, and does not need to finish it. You know the rest." `scenes/royal_funeral/steps/8::1` |
| 4 | **"Again."** "They call me 'the Subject', and whatever I do, they only say 'again.'" `intro::memory.2.fragment::2` | To Primm: "every morning someone said 'again'. I remember that word better than I remember their faces." `capital::cutscene.primm_end.3::1`; Agnes: "Never let anyone file you under 'subject' again." `dna::freed_npc.agnes::4` |
| 5 | **Four signs in a ring.** The key's bow in "The Door Under the Well" `data/dungeons/dungeon_content.json::quest.side_s_town.ready::0`; the crest on every door `intro::memory.4.fragment::1` | Maren's stick: "Four signs in a ring, the same as the ones carved on my stick." `intro::memory.4.after::3`; the headstones: "four colours in a ring" `scenes/royal_funeral/steps/0::1`; the Throne, "four colours woven as a single thread" `capital::ending.beat.8::1` |
| 6 | **Never far from home.** The boy at court asked Maren why tortoises carry their houses. "So we are never far from home." `intro::memory.4.after::1` | "Then let us make the kingdom a home again." `intro::memory.4.after2::0`; "'Welcome home.'" `capital::ending.beat.10::2`; the King: "You came home." `scenes/royal_funeral/steps/6::1` |
| 7 | **The gate that is never locked.** Brannoch: "My girl's still up that road somewhere, and I'd hate for her to come home and find it shut." `intro::town.guard::1`; "tell her the gate is still open." `intro::town.guard.capital_offer::4` | Isla: "Hi, Dad." and "Today it says 'home'." `scenes/isla_homecoming/steps/7::2`; "He just likes the sound of it opening now." `scenes/isla_talk/steps/0::2` |
| 8 | **Two particular graves.** Old Hob: "Two particular graves, these ten years now. I like to take my time over the important ones." `scenes/hob_town/steps/0::1` | "Ten years I've been digging these two. Slowly. I didn't want to finish before they could be visited properly." `scenes/royal_funeral/steps/2::1` |
| 9 | **The third form.** Agnes: "There was a third form, for the little prince, and I never filed it." `dna::npc.dolores.return::4`; the heir clause: "Remains: not on file." `dna::dungeon.ha_records.before::2` | HEIR: ALIVE. FILE COMPLETE. `capital::ending.beat.10::0`; "I'm tearing that one up now, dear. With great pleasure." `scenes/royal_funeral/steps/3::2` |
| 10 | **Filed on a Tuesday.** Kyle: "the peacock drafted it and handed it to me on my way to the rec room, so... a tuesday." `dna::npc.matching.intro::2`; the HR memo, Rule 1 `dna::memo.hr::1` | "FILED ON A TUESDAY. SORRY. - K." `dna::dungeon.ha_boss.after::1`; Plume: "had a clerk file it, on a Tuesday, I believe!" `scenes/plume_ribbon/steps/3::1` |
| 11 | **The dumbbell and the frosting.** Old Man Mountain `gainlands::npc.brenda.return::2`; Basil `gourmand::npc.odalys.return::3` | Elowen: "I knew a boy who fell on his behind trying to lift a dumbbell, and who ate the frosting off every layer of his cake." `scenes/cave_mouth_3/steps/3::1`; Mountain: "the same face he made on my dumbbell" `gainlands::npc.brenda.intro.freed::2`; the Chef: "Is the boy all right?" `gourmand::npc.odalys.intro.freed::2` |
| 12 | **The twelfth tree.** Bramble waters the twelfth spot. `refusemancer::npc.marigold.return::1`-`::2` | Compostella "walked straight to the row of royal trees and planted a twelfth." `refusemancer::npc.marigold.intro.freed::2` |
| 13 | **Not the part that matters.** Flex: "Whatever they took from you, son, it was not the part that matters." `gainlands::dungeon.hg_boss.after::4` | To Primm (the hurried answer): "I don't know everything you took, but I know it wasn't the part that matters." `capital::cutscene.primm_p1.2.rushed::1` |
| 14 | **A blank page.** The Grand Chef: "That isn't a flaw, it's a blank page. Go and do something worth signing." `gourmand::freed_npc.grandchef::5` | To Primm: "a name's a blank page until you sign it." `capital::cutscene.primm_p2.2::0`; "My name is mine to sign." `capital::cutscene.primm_p2.2.rushed::1` |
| 15 | **The wells.** Townsfolk: "Say what you like about His Perfection, the wells are clean." `data/npcs/npcs.json::NPC-TOWNSFOLK.barks::0`; Wren: "His first decree put a hot lunch in front of every schoolchild... It excuses nothing, but remember it." `capital::npc.wren.return::1` | The Early Journals `capital::event.pc_early_journals.body`; Primm: "I made the wells... and I stopped asking anyone whether they wanted the next." `capital::cutscene.primm_p2.3::1`; "I find that I miss the wells." `capital::freed_npc.primm::2` |
| 16 | **"I only wish somebody would say so."** The four insights (`capital::quest.cap_burial.ready::4`, `cap_wheels.ready::4`, `cap_recipes.ready::3`, `cap_untidy.ready::2`) and the Last Journal `capital::event.pc_last_journal.body::2` | "Tell me which part of that was unkind. I should like it in writing." `capital::cutscene.primm_end.4::1`, and the hero's silence `capital::cutscene.primm_end.5::0` |
| 17 | **Her name.** "A friend. That's all I can tell you." `intro::prologue.rescuer.2::0`; "when it's over, I'll tell you everything. My name first. I promise." `scenes/cave_mouth_4/steps/3::2` | Plume says it for her `scenes/pc_capture/steps/4::1`; the hero: "I asked her twice, and both times she said 'a friend'" `scenes/pc_capture/steps/9::1`; she says it herself, "somewhere with a roof" `scenes/lab_siphon_after/steps/5::1` |
| 18 | **"I'll find you. I always do."** `intro::prologue.rescuer.4::3` | He finds her: "You came back for me. Down there, on purpose." `intro::postgame.rescuer.freed::0`; "Took you long enough, Tess." `scenes/lab_cell4/steps/2::1` |
| 19 | **Maren's handwriting.** "Just keep your eyes off the recipe" `intro::town.elder.stage.0::1`; "I helped to blow [that glass]" `intro::memory.3.after::1` | The oldest note in the ward: "The child is not a specimen. He asks for his mother. I am leaving the lab. M." / "You have seen that handwriting on a pie recipe." `capital::dungeon.pc_ward.before::3`-`::4`; Siphon: "Maren said so, and I called it sentiment." `scenes/lab_siphon_after/steps/1::1` |
| 20 | **The steady hands.** Elowen: "Let me see your hands. Steadier than they were." `scenes/cave_mouth_1/steps/1::2`; "Drink your tea. It's for the shaking." `scenes/cave_mouth_2/steps/3::2` | "Your hands are shaking. You go down anyway." `scenes/lab_hatch/steps/0::2` |
| 21 | **Argued like family.** Maren: the four Paths "used to meet, and argue, and borrow each other's pans." `intro::town.elder.first::0` | "Nobody agrees on anything. It is the happiest sound the Capital has ever heard." `capital::ending.beat.5::2`; the Queen "used to say that was the point." `scenes/royal_funeral/steps/4::1` |
| 22 | **The tidy lady with shears.** Moss Mulligan: the Rot "got into me the day a very tidy lady with shears came calling." `intro::refusemancer_npc_victory_lines::1` | Clipwell: "I brought the Archdruid a little seed as a gift" `scenes/clipwell_mill/steps/4::1`; "I gave her the seed because she was crying." `scenes/clipwell_lawn/steps/3::1` |

## 5. Recurring relationships

### The hero and Elder Maren
The spine of the game. Maren is an old tortoise, the founder of Path-ology, and she knows from the first minute who has walked out of her
cave. She is too frightened and too guilty to say so, and she covers it with pie and complaint.

| Visit | Where she is | Line |
|---|---|---|
| Cave mouth | Gruff, put-upon, feeding him anyway. "I never said I'd take in a half-drowned stray." | `intro::cave_mouth.maren` |
| Settling in | A grandmother with a list: meet people, choose your own cards, be gentle with ghosts, get a blade. She is teaching him how to belong somewhere | `quest.meet_the_merchants.*` to `quest.path_direction` |
| First road | Still guarding herself: "For all I know, you're somebody's spy. I've been wrong about people before." | `intro::town.elder.return::1` |
| Fragment 1 | The lullaby undoes her. "Don't ask me why my eyes are wet." | `intro::memory.1.after` |
| Fragment 2 | The first truth: she is the resistance's contact. "I wasn't sure of you before. I am now, near enough." | `intro::memory.2.after` |
| Fragment 3 | The worst truth: she built the glass. "And I ran." | `intro::memory.3.after` |
| Fragment 4 | She says his name, tells him about the boy who asked about her shell, and asks to be forgiven. He does not weigh it up: "I know which of those I'm keeping." | `intro::memory.4.*` |
| After the capture | She admits she was wrong about Elowen: "It seems I've gone and done it twice." | `scenes/maren_after_capture` |
| Ending | "Welcome home", to the whole plaza | `capital::ending.beat.10` |

Her language tracks it: long, grumbling, sideways sentences at the start; plainer with every fragment; by the fourth she simply says what
she means. "Dearie" is armour. When she drops it and uses his name, it should be felt.

### The hero and Pip Threadwell
Pip is the tailor of a town called Crosspath in a kingdom called Patchwork, and he is the one shopkeeper whose trade is the theme. He
measures the hero before he has a name ("your left shoulder is a size braver than your right"), and treats what he wears as a serious
question when nothing else about him is settled. Across visits: the delighted first fitting; pride as freed zones send their fabrics;
gossip about hidden pieces; and, about the Capital's mantle, "The mantle, frankly, is rooting for you." Pip never learns to be less than
delighted, and that is his use: he is the proof that the town went on making nice things under a regime with one Approved Hat Size.

### The hero and the four Path leaders
Each is met as a rumour (the gatekeeper's story), then as a prisoner or a monster, then as themselves, and then they come to him:
| | Rumour | Found | Freed | At the castle | After |
|---|---|---|---|---|---|
| Flex | "Folks still whisper that the old man never broke." | Cross-legged in the dark: "You are not a guard." | "Lift what you can. Carry what you must. Put down what was never yours." | "Breathe in. Hold." | "That is a city with nowhere it has to be." |
| The Grand Chef | "The Chef I trained under ALWAYS tasted." | Out of the freezer, "upright, blinking and furious" | "Have you eaten? Sit, sit." | "Eat first, fight after." | "You did something worth putting your name to." |
| Agnes | (she is there from the start) | In the queue with her appeals | "I have never been so annoyed to win." | "I have found a technicality, dear." | "I think I'm going to cry, dear. I've wanted to for a very long time." |
| Compostella | "The Rot took Archdruid Compostella first." | Half woman, half tree | "Thank you for helping me let it rot." | "Even him. Especially him." | "Look at this crack in the marble, child. Something's growing out of it." |

They call him "son", "my dear", "dear" and "child". None of them has a child in the story. He has no parents. Nobody says this.

### The hero and Elowen, the Rescuer
She is the first voice he hears and the last person he brings home. She was the Lab's junior medic and its Chief Path-ologist's daughter,
told as a girl that the prince was a patient, and she brought him soup for years. She got him out. She will not give her name because her
name is her father's.
- **Prologue:** brisk, low, practical, frightened for him. "I'll find you. I always do."
- **Cave mouth 1-4:** she will not come into town ("the old woman with the shell looks at me like I owe her something, and she's probably
  right"). She checks his hands, brings tea, nearly says it, stops herself. Each visit her hood is a little further down.
- **Castle gate:** she is there, as promised, and is taken in front of him. He learns her name from the man who takes her.
- **Postgame:** in his cell, under his drawing. "Took you long enough, Tess."

She is funny in the way of someone who has spent years being careful: dry, quick, deflecting ("Four of them. Next question."). She never
flirts. What is between them is older than that and has not been said.

### Kestrel and the resistance
The Wrinkles are "the people Primm couldn't iron out", and the Crease is a warm cellar of mismatched furniture: the patchwork kept alive
under the perfect city.
- **Kestrel**, the scout on the road outside, is the first of them he meets: quick, cocky, chalk on her fingers, and she does not show the
  older way in to strangers. She tests him ("Deal?") and then treats him as one of hers ("Told you I'd be around; I just never said where.").
- **Wren**, once the Royal Archivist, keeps "the true record", and what she wants from the hero is not a fighter but a witness: "Talk to
  the people in the streets. Each of them carries a piece of what he did." Across the four insights she assembles Primm ("I can almost see
  his shape") and then refuses the easy version of him. Her charge, "Gently, if you can. But finish it", is the instruction the ending obeys.
- **Nurse Hesper Dray** mends him with tea and very few words every time he falls.
- After the fall they climb out "blinking, into a light they had forgotten", and Wren starts THE TRUE RECORD, VOLUME ONE.

### Fig Sly
The black marketeer: found first behind a hidden chest in Crosspath, then running a stall in the Crease, then, when everything is legal,
complaining that nobody arrests him any more ("I miss the thrill"). He is the story's small proof that not everyone under a tyranny is
noble or broken; some people just keep selling. His lines are locked (`docs/design/canon.md`) and were not changed in this pass.

### Old Hob and the funeral
Hob is Death, working as a gravedigger, and nobody says so. He turns up in every zone "just measuring", checks his appointment book, and
tells the hero he is "not down for a good long while". He is the story's gentlest voice about endings, and the regime's deepest wrong is
that it has put him out of work: he cannot collect in the D.N.A., and nothing has died in the Dump.
- **Town:** digging "two particular graves, these ten years now".
- **Zones:** one visit each; each time the same question ("What are you writing?") and the same kind answer.
- **Capital:** asked about the man in the castle: "Pencilled in." (And about Plume: "Oh, I've got HIM in pen.")
- **Zones freed:** "Things rotting properly again. Lovely sound, that - it means something's about to grow." Gerald's number comes up and
  Hob lets him stay for one more pot.
- **The funeral:** he finishes the two graves, walks the King and Queen "downhill all the way", and pencils Agnes in for later.

Hob and Compostella say the same thing from two sides, and so does the hero to Primm: an ending is not the opposite of care.

## 6. Decisions made while writing this
- **Names.** All names follow the game's data. Internal keys differ from display names in places and were left alone (`npc.brenda` is Old
  Man Mountain, `npc.odalys` Basil, `npc.dolcetta` Madame Mirepoix, `npc.dolores` Agnes, `npc.barnaby` Gerald, `npc.pip` Clerk Ledgerbone,
  `npc.marigold` Brother Bramble, `npc.hob` Granny Gristle, `npc.wren` Billie Muckfoot, `freed_npc.heartlift` Flex).
- **Primm's past** is only what the castle's journals and the four insights say. Nothing new was invented about his childhood or family.
- **Elowen's feelings** are left unsaid, as the game leaves them.
- **The theme is spoken aloud** only by Maren, Pip, the Old Well and the ending narration. Everyone else lives it.
