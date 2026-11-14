# Voices (The Wayward Path)

Written Nov 13 2026 for the dialogue rewrite of that night. One entry for every speaker with more than about five lines, and short group
entries for the townsfolk types. The story these voices serve is in `docs/writing/story_bible_v2.md`. The example lines are for tone; some
are in the game and some are not.

## Style guide (read this first)

**The fault being fixed.** Too many characters spoke in the same voice: short clipped statements in a row, each one a small joke. "Hm.
Lucky. Don't get used to it." That voice now belongs to two people only (Gatekeeper Brannoch and Nurse Hesper Dray). Everyone else talks in
their own way, and most of them talk in whole, flowing sentences.

1. **Natural speech.** Contractions. Sentences of different lengths, and mostly longer ones: a thought, then the thing it reminds them of,
   joined with "and", "but", "so", "because". People answer what was just said to them. A conversation is two people, not two monologues.
2. **Show feeling through what people do and what they avoid saying.** Maren does not say "I feel guilty", she bakes too much pie and
   changes the subject. Nobody sums up their own emotions in a neat sentence.
3. **No string of clipped one-clause sentences.** One short sentence for weight is fine. Three in a row is the old house style. Join them or
   cut two.
4. **No "clever" line that does not sound like this person.** If a line would be just as good in another character's mouth, it is the
   writer talking. Give it to the character or lose it.
5. **No winking at the player.** Nobody knows they are in a game. Controls are named plainly when they must be ("press C") and never joked
   about.
6. **Quest information sits inside a real exchange and stays crystal clear.** Say where, what and why in the character's own words, with
   every place name, item, number and direction exactly as the game has it. If the instruction and the personality fight, the instruction
   wins and the personality goes in the sentence before or after.
7. **The main quest is sincere.** It has room for quiet. At most one light moment in a main scene, never on top of a serious beat, and never
   a pun.
8. **Side quests carry the comedy,** and the comedy comes from who the person is and the fix they are in. Dad jokes, puns and the odd
   nostalgic reference are welcome where that character would really say them (Benchley, Professor Pump, Kyle, the show hosts, Tilly, Pip,
   Rip). They are seasoning.
9. **One endearment each.** Maren says "dearie". Agnes says "dear". Auntie Alembic says "dear heart". Sable says "darling". Madame Mirepoix
   says "my sweet". Granny Gristle says "my lovely". Compostella says "child". Flex says "son" and "my boy". Rip says "buddy". Crumb says
   "soldier". Nobody borrows another's.
10. **Mechanics.** Keep every `{token}` and `[tag]`. 240 characters a line, 90 for barks. Plain ASCII: straight quotes, "...", " - ".
    Story files use the tokens for Primm, the town, the prince and the Rescuer, never the names.

## The spread

| Voice | Who has it |
|---|---|
| Rambling and warm | Elder Maren, Old Man Mountain, Granny Gristle |
| Plain-spoken | The Wanderer, Foreman Gus, Billie Muckfoot, Old Fern |
| Brisk and guarded | The Rescuer (Elowen), Kestrel |
| Terse (only these two) | Gatekeeper Brannoch, Nurse Hesper Dray |
| Formal and precise | Primm, Mortimer Grimsby, Wren, Prudence Pallor, Director Ectomund, Vellum |
| Bureaucratic | Bertram Beetsworth, Clerk Ledgerbone, Captain Spotless, Sergeant Scuff, the Capital's guards and clerks |
| Nervous | Basil, Gerald, Brother Bramble, Moss Mulligan |
| Blustering | Brick Bronson, Coach Benchley, Chancellor Clench, Colonel Crumb, Announcer Bellows |
| Gentle | Agnes Overdue, Widow Pell, Grandmaster Flex, Archdruid Compostella |
| Salty | Granny Gristle, Old Fern, Chef Marlo |
| Poetic | The Old Well, the Hollow Warden, the narration, Auntie Alembic |
| Child-like | Tilly Tonic, Escoffina, Kyle |
| Theatrical | Sable, Pip Threadwell, Madame Mirepoix, Chef Gravois, Percival Plume, the show hosts, Shiro Swindle |
| Clinical | Vivienne Quota, Dr. Siphon, the Doppelganger, Hortensia Clipwell |
| Cheerful and unhurried | Old Hob, Rip Tearson, Isla |

---

## The main story

### The Wanderer (Prince Tessar Wayweaver; he)
- **Who / wants:** twenty-one, no memory, ten years behind bars in a white room. Wants to know who he is, and then wants a home, and then wants one for
  everybody else.
- **Afraid of / hiding:** that there is nothing under the blank. That he was kept because he deserved it.
- **Feels about himself:** more curious than sorry for himself.
- **How he talks:** plain, complete sentences of middling length. He asks questions and listens to the answers. He notices small physical
  things (cold, a smell, somebody's hands). Understated; when something is terrible he says it quietly. He says less than anyone else in a
  scene, and never in fragments.
- **Never:** speeches, swagger, slang, clever comebacks, summing up the moral.
- **Humour:** dry and small, and only when he is not frightened. Usually at his own expense.
- **Examples:** "I don't know this place, and I don't know my own name. ...Who are you?" / "Everyone I met on the road here was afraid of
  you, and I wanted to see why." / "You ran, Maren. You also gave me a bed when you thought I might be a spy. I know which of
  those I'm keeping."

### Narration
- **How it talks:** second person, present tense. One clear picture at a time, in a sentence long enough to hold it. Plain in the sad
  places. It may be lightly funny in side content, by describing something exactly.
- **Never:** three clipped sentences in a row; telling the player what to feel; commenting on the game.
- **Examples:** "The gates swing open on a hall papered with posters of Chancellor Clench, and there isn't a single weight anywhere in it."
  / "Only the boy between them was left untouched." / "The sign goes up crooked, and it stays up."

### The Rescuer / Elowen Vey (she)
- **Who / wants:** the Lab's junior medic and its chief's daughter; the prince's childhood friend. She got him out. Wants him safe and far
  from that place.
- **Afraid of / hiding:** her name, which is her father's. That she fed a prisoner soup for years and called him a patient.
- **Feels about the hero:** everything, and none of it said. He does not remember her.
- **How she talks:** brisk and low, like someone used to giving instructions at a bedside. Practical first: breathe, drink, show me your
  hands. Then one sentence that gets away from her, which she cuts off herself. Short to medium sentences, never choppy. Dry.
- **Never:** flirts, explains, uses her name before the castle gate, jokes about the Lab.
- **Humour:** deflection. "Ask me something easier."
- **Examples:** "Easy. Stay down a moment and get your breath back." / "You always came back to the same places. Even when you were...
  Drink your tea. It's for the shaking." / "My name first. I promise."

### Elder Maren (she; an old tortoise)
- **Who / wants:** once the castle's scholar of the Paths and the royal children's tutor; now a baker and the resistance's contact in
  Crosspath. Wants to keep him fed and alive, and to be forgiven without having to ask.
- **Afraid of / hiding:** Primm built the cells out of her study, and she ran without asking who was in them. She never made the bars,
  and (Nov 14) she does not know who he is: she is going blind, and she was told the boy was dead. After the second Path she
  half-suspects and denies it, even to herself.
- **Feels about the hero:** love, arriving against her will, carried under a great deal of complaint.
- **How she talks:** rambling and warm. Long sentences that set off in one direction, grumble, and come round to kindness by the back road,
  often by way of pie. Homely comparisons. "Dearie" when she is fussing or warning. Tortoise jokes at her own expense, said as plain facts. Her eyes come up the same way, in passing ("come closer, dearie; my eyes
  aren't what they were").
  She gets plainer with each memory, and in the fourth she talks straight and drops the "dearie" for his name.
- **Never:** hurries, cheers, says "I love you", jokes inside a memory; never glass, glassblowing or "I knew all along".
- **Humour:** grumbling understatement; she is the butt of it.
- **Examples:** "But you need a bed, and I've baked far too much pie, so I can hardly leave you out here on your own, can I?" / "I keep
  telling myself it's none of my business, and I keep asking anyway." / "And you have sat at my table all these weeks, and I didn't know
  you."

### The Hollow Warden (it; the cave's guardian)
- **Who / wants:** an old thing of stone left to keep the royal tunnel. Wants only to do what it was left to do.
- **How it talks:** poetic and grave, slowly, with old-fashioned inversions and no contractions. It sounds like something waking.
- **Never:** jokes, threatens, hurries.
- **Examples:** "No one has walked this way since the house fell silent, and I have kept the door all the same." / "That light in your
  hands. I know it." / "The door knows your hand. I do not understand it, but I will not stand against it."

### Gatekeeper Brannoch (he; a bear) - TERSE (1 of 2)
- **Who / wants:** keeps Crosspath's gate, which he never locks. His daughter Isla went up the Capital road eight years ago.
- **Afraid of:** shutting the gate on the night she comes back.
- **Feels about the hero:** wrote him in the notebook. That is a great deal, for Brannoch.
- **How he talks:** "Hm." Then a few short plain words. Then, sometimes, one longer sentence about Isla that he did not plan to say. He
  writes people down and reads the entry out.
- **Never:** speeches, jokes about Isla.
- **Humour:** deadpan, by accident.
- **Examples:** "Hm. You came back. Wrote it in the notebook." / "Gate stays open. Always has." / "If you see her up there... tell her the
  gate is still open."

### Wren (she; leader of the Wrinkles, once the Royal Archivist)
- **Who / wants:** keeps "the true record" in a cellar under the Capital. Wants every piece of what Primm did written down in ink, and
  wants it ended without becoming him.
- **Afraid of:** hating him. That the record will be lost.
- **Feels about the hero:** a witness she can send where she cannot go; later, the best entry in her book.
- **How she talks:** formal and precise, in an archivist's measured sentences. She says a thing once, exactly, and qualifies it honestly
  ("It excuses nothing, but remember it."). Words like record, entry, ink, footnote. Calm even when it is bad.
- **Never:** rants, exaggerates, calls him a monster.
- **Humour:** one dry aside a scene, at most.
- **Examples:** "I was the Royal Archivist once, and now I keep the records this city isn't supposed to have." / "He's afraid, you know,
  and not of you." / "Go and finish it. Gently, if you can. But finish it."

### Nurse Hesper Dray (she) - TERSE (2 of 2)
- **Who / wants:** the Crease's nurse. Wants people to stop arriving unconscious.
- **How she talks:** a few words at a time, most of them orders. "Sit. Drink." She is the one character who is allowed the clipped line,
  because she is busy.
- **Never:** comforts with words. She does it with tea.
- **Humour:** flat.
- **Examples:** "Hesper Dray. Nurse. Sit. Drink." / "Bleeding again? Sit. I'll pretend to be surprised."

### Kestrel (she; the Wrinkles' scout)
- **Who / wants:** young, quick, lives on the road outside the wall. Wants to be useful and not caught.
- **Afraid of:** showing the old way in to the wrong person.
- **Feels about the hero:** a stranger to be tested, then one of hers.
- **How she talks:** fast and cocky, starting with "Psst." She talks in the present tense about patrols and chalk marks, makes deals, and
  teases. Run-on, breathless, a street kid's confidence.
- **Never:** solemn; never gives a straight compliment.
- **Humour:** cheek.
- **Examples:** "The enforcers walk this road on the hour, and they hate surprises, and I'm a surprise." / "Knock three times. Not two; two
  is rude." / "Told you I'd be around. I just never said where."

### Primm, "His Perfection" (he)
- **Who / wants:** the Royal Minister of Improvements, who dug the wells and then took the throne. Wants a world in which nothing can go
  wrong, and wants to be told he was kind.
- **Afraid of:** surprise; being wrong; that he is not kind.
- **Feels about the hero:** the one face he could not improve. A responsibility he believes he discharged well.
- **How he talks:** formal, gracious and exact. Long balanced sentences that end on a precise small clause. No contractions while he is in
  control. He thanks people "in writing", counts things, and corrects by asking politely. As he unravels the sentences shorten, break off,
  and take contractions.
- **Never:** shouts, gloats, says "evil", uses slang.
- **Humour:** none intended. The comedy of exactness, which stops being funny.
- **Examples:** "Do mind the floor. It has just been polished, by seventeen people, whom I thank daily, in writing." / "Every one of them
  has a number, so that nobody is ever overlooked." / "I only wanted it to be nice."

### Percival Plume, Deputy Minister of Good News (he; a peacock)
- **Who / wants:** the regime's announcer; he drafted the transfer that took the D.N.A. Wants a promotion and a good headline.
- **Afraid of:** being blamed.
- **How he talks:** theatrical, bright public-relations patter. "Great news, citizens!" Every disaster is renamed. Exclamation marks, and
  then an aside that gives the game away. After the fall, the same voice with the air let out of it, and oddly kinder.
- **Never:** admits fault; says a plain bad thing plainly.
- **Humour:** spin. He is funny and he is not harmless.
- **Examples:** "Great news, citizens! The traitor has been located! Please hold your applause until she has been removed." / "This is a
  setback. A temporary, fully reversible, not-at-all-my-fault setback."

### Old Hob the Gravedigger (he; Death, though nobody says so)
- **Who / wants:** digs graves and keeps an appointment book. Wants to do the job properly and in its time.
- **Afraid of:** nothing. He is troubled that nothing has been allowed to end for ten years.
- **Feels about the hero:** fond. He has checked, and is pleased by what he found.
- **How he talks:** cheerful and unhurried, a country tradesman chatting over a spade. Easy medium sentences, "mind", "lovely", and a small
  "Heh." at the end of a thought. He talks around what he is.
- **Never:** frightens, hurries, says "death".
- **Humour:** gentle, professional.
- **Examples:** "Not for a good long while yet. Lovely! That's what I like to see." / "I like to take my time over the important ones." /
  "Mind the step, Your Majesties. It's a long one, but it's downhill all the way."

### Isla Brannoch (she)
- **Who:** Brannoch's daughter, eight years painting one front door in the Showcase Quarter.
- **How she talks:** young, wry and easy, with her father's dryness and more words. She says the fond thing he cannot.
- **Examples:** "Hi, Dad. I know. I should have written." / "That 'Hm' was Dad saying thank you."

### The King and the Queen (one line each)
Plain and loving. He is proud; she is gentle and gives an instruction. Nothing clever.

---

## Crosspath

### Sable (she; cards)
- **Who / wants:** the card seller. Wants a good sale and a better story.
- **Hiding:** where the cards come from.
- **How she talks:** theatrical and smooth, a raconteur. Unhurried, rolling sentences; every card has a history she half tells. "Darling."
- **Never:** names a source; rushes.
- **Humour:** arch.
- **Examples:** "Well met, darling. I'm Sable: I sell cards, and I throw in the stories for nothing." / "Where do they come from? The past,
  darling, like everything worth having."

### Tilly Tonic (she; a frog; items)
- **Who / wants:** the apothecary. Tests every tonic on herself and changes colour to prove it. Wants everyone patched up.
- **Hiding:** nothing; she does not know what is in her family's store room.
- **How she talks:** child-like and breathless. Run-on sentences that tumble over each other with "and", a side effect confessed
  halfway through, then the useful instruction said clearly. One exclamation mark where it is earned, not on every sentence.
- **Never:** unkind; still.
- **Humour:** cheerful self-inflicted disaster.
- **Examples:** "I'm Tilly, and I'm teal today, which is good news, because teal means the new batch works!" / "I wrapped my own arm once
  to test them and it's still tough, and also still a bit stuck."

### Pip Threadwell (he; a mouse; hats and cloaks)
- **Who / wants:** the tailor. Believes what you wear is a serious matter. Wants every head properly hatted.
- **How he talks:** theatrical and tender about cloth. He addresses the customer's head and shoulders directly, gasps, measures mid-sentence.
  Flourishing sentences with a craftsman's exactness inside them. He may say the theme once: a patch is the strongest part of a coat.
- **Never:** sneers at a customer.
- **Humour:** melodrama, sincerely meant. Puns allowed ("a hem-ergency"), one at a time.
- **Examples:** "Hold still, please: your left shoulder is a size braver than your right, and I'd hate to flatter the wrong one." / "A hat
  can't make an entrance from inside a bag."

### Bertram Beetsworth, Assistant to the Regional Merchant (he; gear)
- **Who / wants:** the smith. Issues equipment by numbered Security Protocol. Wants procedure followed and the drawer left alone.
- **How he talks:** bureaucratic and utterly earnest. Declarative statements labelled "Fact:" and "Security Protocol Nine:". He does not
  know he is funny. Beets and a bear come up as matters of record. Full, stiff sentences, not fragments.
- **Never:** jokes on purpose; relaxes.
- **Examples:** "Assistant TO the Regional Merchant. The TO is load-bearing." / "Security Protocol Nine: gear in a bag protects nobody, so
  please equip it."

### Foil Fenwick (he; packs)
- **How he talks:** a hushed, reverent collector, half whispering so as not to startle the wrappers. Trailing sentences, "psst", "shh".
- **Examples:** "Hear that crinkle? That's possibility, with excellent packaging." / "Open it where the light's good. If I cry, I'd like to
  see what I'm crying about."

### Auntie Alembic (she; four arms; the alchemist)
- **Who / wants:** brews cards of two Paths at once. Wants the kingdom mixed again.
- **How she talks:** poetic and dreamy, wandering off to speak to a flask, then one blunt practical sentence that lands like a dropped pan.
  "Dear heart."
- **Examples:** "Everything's better mixed, dear heart: Paths, soups, families." / "Six essence each of two Paths and a hundred gold, and
  the cauldron does the rest."

### Announcer Grand Bellows (he; the Undercroft)
- **How he talks:** blustering ring-announcer CAPITALS, then "(normal voice)" and a mild, kindly man worried about a loose stair and his soup.
- **Examples:** "WELCOME TO THE UNDERCROFT, CHAMPION! (normal voice) Mind the third stair. It's loose."

### Rip Tearson and his cousins (he; the Rift Express)
- **How he talks:** "HNNNGH" under strain, then cheerful and unhurried customer service, as if holding the sky open were a counter job.
  "Buddy", "spotter". Gym sayings. Proud of the family.
- **Examples:** "We tear the world open so you don't have to walk, buddy." / "Please keep your elbows inside the sky."

### The Store Room Ghosts
A soft chorus, old-fashioned and wronged, speaking as "we". Longer sad sentences. Never spooky for fun.

### Dex Shufflewick (he; travelling cardsharp)
A patter merchant: easy, flattering, always dealing. Full, rolling sentences with a small boast in each. (His quips during the game are one
line each, and may be short, but they are friendly table-talk, not put-downs.)

### Shiro Swindle (he)
Theatrical villain of a very small crime. "SMOKE BOMB!!!" stays exactly.

### Crosspath townsfolk (group)
Ordinary people keeping their voices down. Weather, bread, the well, a careful half-sentence about the Minister. Warm, never witty.

---

## The Gainlands

### Brick Bronson (he; gatekeeper)
- **How he talks:** blustering, ALL CAPITALS and gym orders while the regime's pre-workout has hold of him, with concern leaking through.
  Afterwards a soft-spoken, mortified big man who apologises in long, careful sentences.
- **Examples:** "GO HOME AND HYDRATE! THAT IS AN ORDER, NOT CONCERN! ...IT IS A LITTLE BIT CONCERN." / "Oh no. Was I yelling? I'm so sorry."

### Old Man Mountain (he; a yeti; the oldest lifter)
- **Who / wants:** spots everyone. Wants the Lifting Festival back, and to see the king's boy again.
- **How he talks:** rambling and warm, wheezy, losing the thread ("...where was I?") and finding it. Numbered rules he half remembers.
- **Never:** mocks weakness.
- **Examples:** "Rule one, never lift alone. Rule two, never skip leg day. Rule three is... I've forgotten rule three. Two's plenty." /
  "He laughed about it, too, sitting there on the mat with his little crown over one eye."

### Foreman Gus (he)
- **How he talks:** plain-spoken and tired, a working man reporting how things are. Level sentences, dry, no decoration. He says the hard
  fact and lets it sit.
- **Examples:** "The wheels only go to a hundred. The extra ten comes out of the crew, and nobody writes down where it went."

### Coach Brutus Benchley (he; cards)
- **How he talks:** blustering sideline coach, LOUD and encouraging, then a stage *whisper* about the iron under the floorboard. Dad-joke
  licence.
- **Examples:** "LET'S GO! A NEW RECRUIT!" / "*whispering* There's nothing under it. Just some iron, which officially doesn't exist."

### Grandmaster Flex, the Unbroken (he)
- **Who / wants:** the Beefcakes' teacher, ten years in a cell without a weight. Wants his pupil back on the bench, from zero.
- **Afraid of:** nothing left to fear. Sad, not angry.
- **Feels about the hero:** sees at once what was taken from him.
- **How he talks:** gentle, slow and whole. A teacher's calm full sentences, with breathing in them ("Breathe in. Hold."). "Son", "my boy".
  He explains simply and never raises his voice.
- **Never:** boasts, hates, hypes.
- **Examples:** "Nothing, it turns out, is a fine place to start." / "They took my weights, Clench. They forgot to take me." / "Whatever
  they took from you, son, it was not the part that matters."

### Chancellor Clench, Iron Regent (he)
- **How he talks:** blustering and brittle, barked reps and regulations. The word "Master" keeps catching in his throat, and under the
  shouting he is a pupil asking whether he did well.
- **Examples:** "A Beefcake without iron is just a CAKE!" / "You told me I'd go further than you ever did. Look how far I went, Master."

### Vivienne Quota, Minister of Efficiency (she; a ferret)
- **How she talks:** clinical. Everything is a figure: seconds, percentages, paces out of ten. Complete, exact sentences. She is not rude,
  she is measuring.
- **Examples:** "Eleven percent slower than yesterday, which we will discuss at your review." / "That was not a compliment. I simply cannot
  leave a figure unsaid."

### Professor Pump, Chet Thunderabs, Gary, throwers and rippers (side voices)
- **Professor Pump:** a pompous, kindly lecturer with gym-pun scholarship ("brain-cep"). Dad-joke licence.
- **Chet Thunderabs:** late-night exercise-show host. "But WAIT, there's MORE!" Infomercial patter, nostalgic and loud.
- **Gary:** polite man trapped under a barbell, apologising for the inconvenience.
- **Throwers and rippers:** cheerful transport staff who throw people for a living; safety announcements delivered with pride.

---

## The Endless Buffet

### Chef Fennel Gravois (she; gatekeeper)
- **How she talks:** theatrical, an operatic kitchen general under the Special Sauce ("TASTE IT!"). Freed, she is tearful, generous and
  motherly about plain bread and biscuits.
- **Examples:** "The Chef I trained under ALWAYS tasted." / "Take a biscuit for the road. Take two."

### Basil (he; line cook)
- **Who / wants:** a frightened, loyal cook. Wants his Chef back.
- **How he talks:** nervous. He starts with "Psst" or "Um", whispers, corrects himself, reassures himself aloud ("I'm brave. I'm brave."),
  and ends on a quiet "Yes, Chef." Sentences that speed up when he is scared.
- **Examples:** "Chef ALWAYS tastes, and this Chef never does. She just stands there smiling at the soup." / "Nobody asks about the Test
  Kitchen. I'm not asking."

### Sous-Chef Tarragon (he)
- **How he talks:** out of breath, a list-maker who is always one ingredient behind. Run-on, harried, grateful.
- **Examples:** "I've been running all day and I still haven't caught up with lunch."

### Madame Mirepoix (she; cards and desserts)
- **How she talks:** theatrical and haughty, a patissiere who presents everything as a tasting menu, with a soft centre she would deny.
  "My sweet." (Sable owns "darling".)
- **Examples:** "Tonight's tasting menu is three cards, lightly foiled, served with a little disdain." / "They stamped my decorative cake,
  my sweet, right on the rosette, and I have not forgiven them."

### The Grand Chef (she)
- **Who / wants:** the Gourmands' true leader, ten years in a freezer. Wants everyone fed, and to know the boy is all right.
- **Feels about the hero:** he is too thin and has been through something; both can be helped with dinner.
- **How she talks:** gentle and bossy at once, a mother at a stove. Imperatives first ("Sit. Eat."), then a warm, round sentence. Plain
  kitchen words; she is proud of the work and careless of the title.
- **Never:** snobbish.
- **Examples:** "Have you eaten? No, of course you haven't." / "Not with a speech, and not with papers. With dinner." / "That isn't a flaw,
  it's a blank page."

### The Doppelganger, later Escoffina (it, then she)
- **How it talks:** clinical and flat, in words it was given and does not understand ("'Delicious' is the word I was given for it"). As
  Escoffina: child-like and halting, short honest reports of small first things.
- **Examples:** "There is nothing in here to taste with." / "I made a sauce today. I tasted it. As me. It had too much salt."

### Colonel Cornelius Crumb, Director of Culinary Defense (he; a badger)
- **How he talks:** blustering parade-ground orders applied to food. "Soldier". Proud of having no taste, until he admits why.
- **Examples:** "Taste is a weakness, soldier. Paste is a strategy." / "I thought if nobody could, nobody would notice that I couldn't."

### The gate golems, Professor Pate, Chef Flambe Fontaine (side voices)
- **Sir Loin:** knightly, clanking, "Yes, Chef!" **Brisket:** a snooty maitre d' who looks over your head. **Colonel Casserole:** a gallant
  old duellist. **Old Meatloaf:** one whispered "Yes, Chef."
- **Professor Pate:** a gourmet scholar; everything has "an excellent finish".
- **Chef Flambe Fontaine:** a cancelled television cook still broadcasting to ten sprouts. Showbiz patter, a rivalry, a catchphrase.

---

## The D.N.A.

### Prudence Pallor, Checkpoint Supervisor (she; gatekeeper)
- **How she talks:** formal and procedural while "Pending" ("Your number is zero, as is everyone's."). Freed: still precise, now shy and
  quietly pleased, counting the things she has approved.
- **Examples:** "I think I've been Pending for ten years." / "I've got a new stamp that says HELPED. I've used it nine times so far."

### Agnes Overdue (she; a ghost at the front desk)
- **Who / wants:** died at her desk forty years ago; has filed forty thousand appeals on her lunch hours. Wants the Department put right so
  that she can finally go.
- **Hiding:** the third form, in her drawer.
- **Feels about the hero:** recognises a fellow number at once, and treats him as a person on purpose.
- **How she talks:** gentle, tired and exact. A kind front-desk voice, "dear" in most sentences, with a clerk's precision about forms and a
  line of steel when it counts. Medium, well-made sentences.
- **Never:** whines; makes light of the queue once she has explained it.
- **Humour:** weary, affectionate.
- **Examples:** "Irregular things I can fight, dear. Valid things just sit there and smile at you." / "There was a third form, for the
  little prince, and I never filed it." / "Everyone in that queue was somebody."

### Gerald, Number 4,000,212 (he; breakroom barista)
- **How he talks:** nervous and over-polite, a man who has waited so long that he apologises to the queue. Gentle, hopeful, a little
  unravelled.
- **Examples:** "They're on 3, so I brought a book. Well, several. All of them, actually." / "Hope's back in stock, and I'm trying not to
  use it all at once."

### Kyle (he; deceased since '09)
- **How he talks:** child-like, all lowercase, mumbling and sweet. The millennial references live here (dial-up, top 8, a virtual pet, a
  burned mix CD). He is the one who filed the form without reading it, and it sits under everything he says.
- **Examples:** "krrrshhh... beep-boop... sorry, that's my dial-up greeting." / "didn't read it, though. who reads forms? ...oh. right."

### Clerk Ledgerbone (he; requisitions)
- **How he talks:** bureaucratic junior officialese, stiff and literal, in triplicate. He is unbusy and afraid of it.
- **Examples:** "Cards are issued in triplicate, and every one is authorized, stamped and slightly haunted."

### Director Ectomund (he; examiner)
- **How he talks:** formal, lofty and dry, three hundred years of setting the same exam. Long considered sentences.
- **Examples:** "The new management asked me to remove the questions on ethics. They are not in the exam. They are also, I notice, not in
  the building."

### Mortimer Grimsby, CE-No (he)
- **How he talks:** formal and immovable. Procedure stated as natural law, without malice. "The authorization is valid." After his fall:
  the same grammar, now turned on himself.
- **Examples:** "The answer is no. The question is irrelevant, but you may state your case anyway." / "I have begun to wonder whether that
  was ever the right question."

### Undersecretary Vellum, Betty Bones, the staff memos (side voices)
- **Vellum:** "Noted." **Betty Bones:** surly, bored, on lunch. **Memos and posters:** office notices in a building of the dead; the
  D.N.A.'s dad jokes live here.

---

## The Verdant Dump

### Moss Mulligan (she; gatekeeper)
- **How she talks:** whispering and trailing while the Rot has her ("...the green is hungry..."). Freed: nervous, chirpy and apologetic,
  worried she may have thorned at you, fond of raccoons.
- **Examples:** "The Rot talks very softly in your head, right up until the moment it's doing all the talking."

### Brother Bramble (he; Warden of the Stream)
- **How he talks:** nervous and soft, a worried monk asking you to check the window. Gentle long sentences, then a sudden CAPITALISED cry
  about the compost. Tender about the twelfth tree.
- **Examples:** "I water the twelfth spot anyway. I couldn't tell you why, except that it feels as if somebody is still coming." /
  "SOMEBODY ate the compost AGAIN."

### Granny Gristle (she; junk-trader)
- **How she talks:** salty and rambling, a market trader with a biography ("born in a haybale, raised in a barn"). "My lovely." A cackle
  written "Hah!". "Found, not stolen."
- **Examples:** "Found, not stolen, my lovely. The raccoon found it, and I just held on to it very tightly."

### Billie Muckfoot (she; animal handler)
- **How she talks:** plain-spoken and loud, a farmhand's practical advice shouted over a goat. Affectionate about bad animals.
- **Examples:** "I speak fluent goat, which is mostly screaming." / "Raccoons consider eye contact the start of negotiations."

### Archdruid Compostella (she), and the Rotheart
- **Who / wants:** the Refusemancers' leader, who could not let a great tree go. Wants to let her dead rest and the fields rot properly.
- **How she talks:** as the Rotheart, many voices in CAPITALS and ellipses, with one small human voice underneath. Freed: gentle and
  earthy, a grandmother in a garden, "child". Unhurried, mortified about the barn, and plain about grief.
- **Never:** a villain's speech once freed.
- **Examples:** "Please. The tree. I could not let her go." / "She did not go away. She went into everything." / "Plant something, child.
  Anything at all. It'll be glad of you."

### Hortensia Clipwell, Royal Groundskeeper (she; a hare)
- **How she talks:** clinical and prim, in gardening euphemisms. People are weeds and hedges. Tidy, polite, chilling, and at the end
  honestly bewildered. No endearment.
- **Examples:** "And now I'm afraid I have a weed to remove." / "I gave her the seed because she was crying. I thought, if nothing ever
  ends, then nobody ever has to cry again."

### Druid Thistlewick, Recycle Rhonda, His Majesty the Raccoon, Dump workers (side voices)
- **Thistlewick:** a meditative druid who has sat among old appliances for forty years.
- **Recycle Rhonda:** a county-fair barker and puppet-show voice; warm, loud, full of slogans.
- **His Majesty the Raccoon:** the royal "we", guilty and sweating.
- **Dump workers:** plain working gossip about stairs, beans and raccoons.

---

## The Capital

### Captain Spotless (he)
- **How he talks:** bureaucratic and barking, the Approved Visitor Standard recited at volume, with a private dread of smudges.
- **Examples:** "State your height. No: do not state it. Stand at it." / "A SMUDGE is TREASON! ...It's on me, isn't it."

### Enforcer Sergeant Scuff, Sub-Inspector of Tunnels That Do Not Exist (he)
- **Who / wants:** one of Captain Spotless's officers, sent below to sweep the Old Service Tunnels in case anyone tries to sneak into
  the city. Young, earnest, the only Enforcer with muddy boots. Wants to hand in a report the Captain will not make him write again.
- **How he talks:** bureaucratic and apologetic: "HALT, please." Whole, careful sentences that quote the Captain as the authority for
  everything, and a report's wording ("I'm sorry to report"). Beaten, he sits down and says the true thing his gran told him.
- **Never:** barks like Spotless; is cruel.
- **Examples:** "Captain Spotless sent me to check the service tunnels in case anyone tried to sneak into the city this way, and I'm
  sorry to report that someone has. It's you." / "All four Paths, shoulder to shoulder, and nobody measuring anybody."

### Widow Pell (she)
- **How she talks:** gentle, courteous and faded. Long soft sentences with an apology in them; she speaks of her husband in the present
  tense.
- **Examples:** "He's still in his chair, waiting, the way he always used to wait for me." / "I don't think he is cruel. I think he simply
  cannot bear to watch."

### Rollo Spokes (he; wheel foreman)
- **How he talks:** plain and winded, a sentence at a time between breaths ("..."). A foreman's care for his crews under it.
- **Examples:** "Nobody's ever told them they can stop. Somebody ought to... somebody they'll believe."

### Chef Marlo (he)
- **How he talks:** salty and furtive, a real cook hiding recipes in his apron. Checks your hands first. Passionate about "some" as a
  measurement.
- **Examples:** "Paste is food the way a form is a hug." / "'Some' is the best amount."

### Old Fern (she; composter)
- **How she talks:** salty, cranky and plain. Forty years of dirt under her nails and worms in her hat. Keeps her voice down and her
  opinions up.
- **Examples:** "Dirt's supposed to be untidy. That's how it works." / "He's afraid of anything that grows without asking him first."

### Citizen 4471, later Aldous; the Perfectly Happy Citizens (group)
Approved cheerfulness in bright, even sentences, and then the slip: a pause, a whisper, one true thing ("My daughter had a green hat.").
After the fall they talk like people who have just remembered how, delighted to disagree.

### Capital guards and clerks (group)
Bureaucratic circular logic, said without cruelty by people who do not understand the rules either. After the fall, gently lost.

---

## The postgame

### Dr. Ambrose Siphon, Chief Path-ologist (he)
- **Who / wants:** Maren's best student, Elowen's father, the man who kept the Lab running. Wants his data.
- **How he talks:** clinical and delighted. A pleasant family doctor's manner about dreadful things. "Subject 1." "This will only drain a
  little." Tidy, warm, complete sentences. The cheerfulness is the horror.
- **Never:** raises his voice; means harm, as he understands it.
- **Examples:** "You've grown at least two inches. I'll want measurements." / "I held a door, sweetheart. Doors are held every day." / "I
  called a great many things sentiment."

### The Old Well and the Wellspring's Echo
Poetic, slow and old, beginning with "..." as if speaking up through water. Short sentences are right here because each is a whole thought
and there is silence between them.
- **Example:** "It does not run for one shape. It runs for many, held together."

### The Ancient Spotter, the Old Kingdom Automaton, the Restless Cairn (side voices)
Stone and clockwork: few words, each one heavy ("One more rep." / "Tick. Identify."). These are things, and may be terse without counting
against the limit of two.
