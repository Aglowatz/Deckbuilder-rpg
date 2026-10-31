# Voice bible for the dialogue critic pass (Oct 31 2026)

The working brief for the Oct 31 critic pass (`docs/dialogue/critic_suggestions_oct31.csv`). It condenses and extends the full design voice
bible (`docs/design/voice_bible.md`, which wins on any per-character detail and "Never" rule). Facts: `docs/design/story_bible.md`.
Locked names and banned names: `docs/design/canon.md`.

Note on the source: the Dialogue Edit tab and `docs/dialogue/edit_oct27.csv` have no designer "New line" rewrites yet (all 4203 rows are
empty in that column on Oct 31), so this pass critiques the current game text and takes its voice from the bibles and the strongest current
lines. Every row is effectively "Current line".

## 1. What good looks like in this game

The best current lines already show the target, and the pass should write toward them:

- "...Cold. Leaves in my mouth. Great start." (the Wanderer: physical, dry, short)
- "That is no prince, I told them. That is a damp young man with good posture." (Maren: a sting in the tail that hides what she knows)
- "Bertram Beetsworth, Assistant TO the Regional Merchant. The TO is load-bearing." (character comedy from one obsession)
- "Hear that? They're close. I'll draw them off the other way. They know my face; let them chase it." (the Rescuer: plot told as action)

The pattern: **one concrete detail, one turn, punchline last.** Facts arrive inside character, not as a lecture. A line earns its box if
you could cover the name plate and still know who said it.

## 2. Hard rules for every suggestion

1. **Placeholders exactly**: `{town}` `{kingdom}` `{villain}` `{villain_title}` `{wanderer}` `{prince}` `{prince_full}` `{royal_house}` `{king}`
   `{queen}` `{rescuer}` `{rescuer_full}` `{capital}` `{pathordia}` `{showcase}`, `%s`/`%d`, and a leading `[smug]`-style tag. Same set,
   same count. Story files never spell Primm, Crosspath, Tessar, Wayweaver, Pathordia, Showcase Quarter or Elowen literally; barks
   (`npcs.json`), tips, boss intros, encounter scripts and dungeon event screens show text literally and take no tokens.
2. **Tested phrases stay word for word.** The chunk files list them per row ("Must keep"); `tools/dialogue_critic_check.js --check`
   enforces them. Example: "Tell me: which Path resonates the strongest within you?" is asserted whole.
3. **Each line keeps its job**: the hint, the instruction, the name, the reveal, the rule text. Quest Log and `(battle UI)` rule text must
   keep every number and condition. Choice buttons stay short and say what they do.
4. **Length**: a dialogue box line stays at or under 220 characters (and near the longest current line of its kind); barks under 90; titles,
   name cards, event names and button labels stay as short as they are now (a few words).
5. **Canon**: names and facts from `canon.md`; no new lore that contradicts it. Small flavour inventions are allowed when consistent; log
   them in section 7.
6. **PG, no real-world references**, no real brands, songs, films, shows, places or people. Parody names only.
7. **Sincere beats stay sincere**: the prince's captivity, grief for the king and queen, the four leader reveals, the memories, Isla, Primm's
   fall, Widow Pell, Citizen 4471, the Lab cell, Elowen's rescue. Humour goes around them, never on top. Keep the specific human detail.
8. **Fig Sly and the Secret Dealer (black market) are locked.** No suggestions for their lines.
9. **Do not rename anything**: cards, places, NPCs, quests, dungeons, nodes, items.
10. **Plain ASCII punctuation** (straight quotes, "...", " - " for a dash), like the current lines.

## 3. The comedic register

Each Path has a house style. The joke always comes from someone sincerely inside the culture, never from the narrator sneering at it.

| Where | Register | The engine of the joke | Under it (never lose this) |
|---|---|---|---|
| Crosspath | small-town warmth with eccentric shopkeepers | every vendor has one obsession taken totally seriously | a watched town under a regime; four roads blocked |
| The Gainlands (Beefcakes) | **gym-bro sincerity** | huge, earnest people applying gym logic to everything (spotting = friendship, hydration = love, leg day = destiny); infomercial hype | everyone is exhausted; wheels never stop; the leader is in a cell |
| The Endless Buffet (Gourmands) | **haute-cuisine snobbery** and cooking-show drama | culinary vocabulary for war; plating as morality; "Yes, Chef!" | a kitchen turned into an arms factory; chefs who flinch at "weapon" |
| The D.N.A. (Necrocrats) | **deadpan bureaucracy** | procedure applied flawlessly to absurd ends; forms that need forms; the dead patiently queuing | the dead are owed humanity; "the authorization is valid" crushes people |
| The Verdant Dump (Refusemancers) | **scrappy junk pride**, folksy farm chaos | treasure-from-trash, raccoon royalty, goats eating signs, compost as sacred | growth that never stops; a grieving leader; nothing can rot |
| The Capital (Primm, Plume, the facade) | **too-perfect politeness** | approved cheer and regulation over plain misery; the gap between slogan and whisper | fear; vanished names; the jokes go quiet near the castle |

The rivalries are a comedy resource that is under-used: Beefcakes vs Necrocrats (chaos vs by-the-book: "there-ish, on-time-ish"), Gourmands
vs Refusemancers (snooty vs "garbage eaters"). A Beefcake complaining about a queue, a Gourmand sniffing at compost, a Necrocrat filing a
complaint about a thrown person: one line each, from someone in the zone, is worth more than any narration.

**The humour dial** (from loud to off): vendors, barks, idle lines, minigame hosts, quiz hosts > zone story NPCs > gatekeepers > Capital
(cracks in the facade) > the castle (Primm's precision only) > memories, leader reveals, ending, Lab cell (off: no punchline, keep colour).

## 4. Speakers

Format: **who** - what they want - how they talk - a sample line in their voice (new, not in the game). Pronouns as given. Full entries with
"Never" rules: `docs/design/voice_bible.md`.

### Prologue, cave and the Wanderer's circle

- **The Wanderer** (he; Prince Tessar, 21, no memory) - to know who he is and do the right thing first. Shortest lines in the game; dry inner
  voice; notices hands, cold, smells; undercuts himself; plain and earnest when it counts. Never speeches. *"I don't know my name, but I know
  that sword is badly balanced. Strange thing to keep."*
- **Narration** - shows, never tells the player what to feel; second person, present tense; one concrete image per sentence; the rule of
  three that breaks on the third; deadpan in the zones, plain in the sincere beats. *"The rack holds no weights. Someone has dusted it
  anyway, every day, for ten years."*
- **The Rescuer / Elowen** (she) - him safe, far from the Lab. Quick, low, practical imperatives; medic checks; one guarded warm line per
  scene; never says her name before Plume does. *"Eat something before you fall over. That's not advice, it's a schedule."*
- **The Hollow Warden** - to let the right one through and sleep. Slow stones of words, pauses, "the house". *"...Small feet. I have heard
  them before. Running, then. Walking, now."*
- **Elder Maren** (she; tortoise; founded Path-ology; resistance contact) - to protect him without admitting what she suspects; forgiveness
  for her lab. Slow, grumbly, "dearie" as a warning, a sting in the tail, pie as love and deflection; gets plainer each memory.
  *"Questions are like pie, dearie. One at a time, and never before I've sat down."*
- **Gatekeeper Brannoch** (he; bear) - Isla home. "Hm.", a short fact, then one tender sentence; the notebook; knees; the gate he never locks.
  *"Hm. Wrote you down again. 'Stranger, slightly less damp.' Progress."*
- **Isla Brannoch** (she) - home, quietly. Small warm lines; no jokes about her eight years. *"He left the gate open the whole time. I could
  tell from the hinges."*

### Crosspath vendors and regulars

- **Sable** (she; cards) - a good sale with a good story. Smooth, theatrical, quick "darling"; misprints as personalities; never reveals a
  source. *"This one's had three owners, darling. All of them lucky. Two of them on purpose."*
- **Tilly Tonic** (she; frog; items) - to test everything on herself. Bursts of exclamation; her skin changes colour with the potion.
  *"New tonic! Side effects include courage and mild purple! The purple's the fun part!"*
- **Bertram Beetsworth, Assistant TO the Regional Merchant** (he; equipment) - promotion, order, the bear's respect. "Fact:", numbered
  Security Protocols, the drawer, beets and bears; never knows he is funny. *"Security Protocol Four: smile at the customer. I am smiling
  internally. It is very professional in there."*
- **Pip Threadwell** (he; mouse; hats and cloaks) - every head properly hatted. Gasping fashion melodrama, "Hat!", measures you mid-sentence.
  *"That hat is wearing you, and frankly it has given up."*
- **Foil Fenwick** (he; packs) - every Path's pack on his shelf. Breathless collector whisper; "foil" said reverently. *"Don't open it near
  me. I'm a collector, not a strong person."* (his own running gag)
- **Auntie Alembic** (she; four arms; the Alchemist) - the Paths mixed again. Soft and mystical, then one blunt sentence like a dropped pan;
  talks to her flasks. *"Everything is better mixed, dear. Paths, soups, families. Not the red flask. The red flask is fine alone."*
- **Announcer Grand Bellows** (he; the Undercroft) - a great bout and a full cellar. ALL-CAPS announcements, then a small normal aside about
  the low ceiling. *"THE CROWD GOES WILD! (The crowd is me. I'm going a bit wild.)"*
- **Brindle the Baker** (he; badger) - everyone fed and asleep by nine. Cosy, one dough pun per box. *"Rose at four. The bread rose at five.
  Only one of us looks good for it."*
- **Old Hob** (he; the gravedigger who is secretly Death) - to get the queue moving. Cheerful, unhurried professional; the appointment book;
  "Pencilled in." *"Lovely day. Nobody on the list. I'm just measuring. Habit."*
- **Rip Tearson and cousins** (all he; the Beefcake Rift Express) - to hold the sky open and have his form noticed. "HNNNGH", then polite
  customer service; "buddy", "brother"; numbered cousins. *"HNNNGH. Mind the gap, buddy. The gap is the sky."*
- **Shiro Swindle** (he; ninja) - a worthy rival. Theatrical, rhetorical, "the oldest trick in the book!", "SMOKE BOMB!!!" kept exactly.
- **The Storeroom ghosts** - their haunting handled. Polite collective "we", customer service beyond death.
- **The Old Well and its Echo** - short slow fragments ("...Four streams. One spring."). No jokes in their own voice.
- **Crosspath townsfolk** - a quiet life; cousins home. One-line gossip, a little nervous; louder each freed zone.

### The four gatekeepers

- **Brick Bronson** (he) - corrupted: ALL-CAPS slogans, "I AM THE SPOTTER", never please; freed: sheepish run-on apologies, stretching,
  oils the crank to say sorry.
- **Prudence Pallor** (she; skeleton) - corrupted: monotone policy, no contractions; freed: tired, wry, Agnes's deputy, loves APPROVED.
- **Chef Fennel Gravois** (he) - corrupted: manic "TASTE IT", "the war effort"; freed: teary over plain bread, biscuits.
- **Moss Mulligan** (she; faun druid) - corrupted: whispered ellipses, "the green is hungry"; freed: shy, apologetic, raccoons are good boys.

### The Gainlands

- **Old Man Mountain** (he; yeti hermit) - someone to spot; the old king's boy remembered. Wheezy, nostalgic, trails off mid-thought; "Rule
  one: never lift alone"; the Lifting Festival. *"The king lifted with us every summer. Badly. Lovely man. Terrible form."*
- **Foreman Gus** (he) - a hundred percent instead of a hundred and ten. Flat, tired, sedition between the lines. *"The wheels don't stop.
  Neither do we. Only one of us was built for it."*
- **Coach Brutus Benchley** (he; minotaur; cards) - the old cards back on the rack, legally. No inside voice, "LET'S GO!", the whispered
  floorboard.
- **Professor Pump** (he; quiz) - students who read the signs. Tweed, footnotes, "brain-ceps"; quiz facts exact.
- **Chet Thunderabs** (he; Rep Counter) - an audience. Infomercial host ("But WAIT!"), legwarmers.
- **Gary** (he; under a barbell) - a spotter. Muffled, polite, "No rush. Bit of a rush."
- **Throwers and rippers** (Big Hurl and the named ones) - to throw you well. Cheerful countdowns, one tic each; the landing is your problem.
- **The gym attendant** - weights to re-rack. Cheerful, overworked, "House rule two: we have no weights."
- **Grandmaster Flex, the Unbroken** (he) - Clench back on the bench from zero. Serene, short, perfect timing; "son", "my boy"; never
  brags or hates. *"Strength is not what you lift. It is what you put down when it is time."*
- **Chancellor Clench, Iron Regent** (he) - to feel strong without being told. Barked orders in reps and regulations; a crack on "Master".
- **Vivienne Quota** (she; ferret; lieutenant) - 110 percent. Crisp percentages and seconds, never a wasted word.
- **Baron Quadzilla / the Ancient Spotter** (S-IRON / S-BEEF bosses) - leg day; the lift finished. Grunted; booming and kind.

### The Endless Buffet

- **Basil** (he; rabbit line cook) - the real Chef back. Whispered, jittery, loyal; "Chef ALWAYS tastes"; "Yes, Chef" quietly; the
  four-layer cake. *"I'm not scared. I'm marinating in courage. It takes a while."*
- **Sous-Chef Tarragon** (he) - three ingredients and one day off. Harried lists, apologetic.
- **Madame Mirepoix** (she; Persian cat; cards) - a real pot pie, honest taste buds. Slow, formal "darling", cards as courses; warm to
  scrappy customers. *"Three cards, lightly foiled, served with a reduction of my patience."*
- **Professor Pate** (he; quiz) - curious students. Lecturing, food metaphors; tastes his chalk.
- **Chef Flambe Fontaine** (he; Dinner in a Dash) - his show back. "ORDER UP!", feuds with Chef Savannah Souffle.
- **Old Meatloaf and the gate golems** (Brisket, Sir Loin, Colonel Casserole) - a chef worth "Yes, Chef". Knightly formality from meat;
  Old Meatloaf: one or two slow words.
- **The Grand Chef** (she) - everyone fed; the boy all right. "Sit. Eat." then one big-hearted sentence; never cares about her title.
- **The Doppelganger, later Escoffina** - before: the Chef's words with no warmth, "Delicious" without meaning; after: shy, earnest, trying.
- **Colonel Cornelius Crumb** (he; badger; lieutenant) - an army of golems. Military orders in food metaphors; never compliments flavour.
- **The Itamae Supreme** (Omakase boss) - one perfect word.

### The D.N.A.

- **Agnes Overdue** (she; ghost) - to pass on, after fixing the place. Sweet, exasperated, "dear"; her ribboned stack of denied appeals;
  "Irregular."; steely when it matters. *"Appeal forty-one thousand. Denied, with a lovely stamp. They've started decorating them."*
- **Gerald, Number 4,000,212** (he; breakroom barista) - his number called. Patient, polite, slightly unravelling; "They're on 3."
  *"I've made friends with my number. We've been through a lot. Mostly waiting."*
- **Clerk Ledgerbone** (he; skeleton; Requisitions) - one form done right. Flat, one-liners, a tiny flash of joy at a correct form.
- **Director Ectomund** (he; quiz) - a perfect score in triplicate. Droning, numbered, delighted by correct answers.
- **Kyle (Deceased Since '09)** (he; memory match) - someone to play with. Lowercase energy, "brb", away messages; only '09; no real brands.
- **Mortimer Grimsby, CE-No** (he; boss) - the rules obeyed; later, to know whether "valid" was the right question. Formal, immovable, precise;
  "The authorization is valid." *"Your objection has been noted, stamped and laminated. It remains an objection."*
- **Undersecretary Vellum** (he) - the Court held. "Noted."
- **Betty Bones** (she; S-NECRO boss) - home at five. Dry, nasal, never impressed.
- **D.N.A. staff** - courteous, procedural, faintly sorry; each clerk one sentence.
- **Percival Plume** (he; peacock; Deputy Minister of Good News; the Capital loudspeaker) - a promotion. Oily PR spin, "Great news,
  citizens!", approves the weather. *"Great news! Hunger is down, because complaining about it is now illegal!"*

### The Verdant Dump

- **Brother Bramble** (he; hedgehog druid) - the Archdruid back; the compost thief caught. Soft and worried, then a sudden CAPITALISED
  outburst about compost; the eleven birthday trees. *"The vines hummed at me this morning. Vines don't hum. Also SOMEBODY ate the
  compost."*
- **Granny Gristle** (she; opossum; cards) - fed fields, a shed that stays a shed. Rambling junk-trader grandma, "Heh!", "found, not stolen,
  dearie" (cheerful, unlike Maren's). *"Everything here was thrown away by somebody who was wrong. Heh!"*
- **Billie Muckfoot** (she; animal handler) - the herd home by dark. Sunny, muddy, unflappable; animals always get out.
- **Druid Thistlewick** (he; quiz) - correct sorting, in bins and minds. Solemn recycling sermons; the dishwasher that talks back.
- **Recycle Rhonda** (she; Sort It Out) - a sorting champion. Peppy public-service-announcement slogans.
- **Compostella** (she) - Rotheart: many voices in capitals and ellipses with one small human voice under them; Archdruid: earthy, playful,
  grandmotherly, sincere when it matters; "child"; mortified about the barn.
- **His Majesty the Raccoon** (he; S-REF boss) - to escape the trial. Royal "We", nervous, never confesses: "We... sampled it."
- **Hortensia Clipwell** (she; hare; lieutenant) - everything trimmed. Prim gardening euphemisms; never raises her voice.
- **Dump workers** - one-liners while working; folksy, uneasy about the purple.

### The Capital and the castle

- **Wren** (she; resistance leader, once Royal Archivist) - the true record finished. Low, steady, short; one sharp joke per scene; "He is not
  a monster." *"We keep two lists. What he did, and what we'll fix. The second one is longer. That's the good news."*
- **Kestrel** (she; scout) - you inside alive. Quick, cocky, whispered half sentences; chalk marks.
- **Nurse Hesper Dray** (she) - people patched and sitting down. "Sit. Drink." and one wry sentence.
- **Captain Spotless** (he) - one perfectly approved visitor. Rigid, fussy, shouted contradictory regulations, polishing between sentences;
  a tired human under the armour.
- **Widow Pell** (she) - to lay her husband to rest. Tired, gentle, plain; soft dry humour, never at her loss.
- **Rollo Spokes** (he) - someone to tell his crews they may stop. Breathless jokes between pedal strokes.
- **Chef Marlo** (he; mole) - someone to remember what food is. Hushed, passionate, recipes as contraband.
- **Old Fern** (she; gnome) - one thing planted. Grumbly, defiant, "untidy" as a badge.
- **A Perfectly Happy Citizen** (nine of them) - a name back. Approved phrase, slightly-off phrase, frightened whisper; after the fall, giddy
  joy at small freedoms. The slip line is never a punchline.
- **Citizen 4471, later Aldous** - played straight.
- **Capital guards and clerks** - polite, baffled, contradictory regulations; freed: almost asking permission to go for a walk.
- **Primm, "His Perfection"** (he) - a world where nothing surprises him; to be told he was kind. Gracious, polished, long balanced sentences
  with a precise last clause; never cackles, gloats or says "evil"; heard in person only in the castle and postgame. *"I have taken the
  liberty of improving your posture in the portrait. You may thank me in writing."*
- **Dr. Ambrose Siphon** (he; postgame boss) - the next cycle. Clinical, faintly delighted, "Subject 1"; the cheer is the horror.

### UI voices

- **(battle UI), (UI), (narration/UI), (choice button), (name card), (Quest Log)** - clear first. A rule text keeps every number and
  condition. A Quest Log step names the place and the thing. A name card title may be funny in four words or fewer. Only suggest a change
  for clarity, a real typo, a missing direction, or a title/blurb that could carry a joke or a fact at no cost.

## 5. Running jokes

**Keep (they work; reuse only for their owner and where the setup was heard):**
Bertram's numbered Security Protocols and "the TO is load-bearing"; Maren's pie and "1987"; Brannoch's notebook ("stranger, damp") and open
gate; Gerald's number 4,000,212 and "They're on 3" (and Mortimer's 4,000,214 payoff); "The authorization is valid."; forms that need forms
(27-B/27-C); "Yes, Chef!" and the Special Sauce; "Chef ALWAYS tastes"; never lift alone / spotting / leg day / Gary under the bar; Rip's
numbered cousins and "do not look at the seam"; the raccoons who "sampled" the compost; goats eating signs; Old Hob's appointment book
("Pencilled in." / "in pen."); Plume approving the weather; Primm's precision (two is the perfect number; regulation hats, approved height);
Shiro's SMOKE BOMB!!!; Fenwick's collector weakness; Tilly's colour changes; Pip's "Hat!".

**Seed (under-used, where a line is weak anyway):**
- **The rivalries out loud**: Beefcakes on Necrocrat queues ("there-ish, on-time-ish"), Necrocrats filing complaints about thrown people,
  Gourmands on "garbage eaters", Refusemancers on fancy food going to waste. One per zone in idle/bark lines.
- **Old Hob's quiet competence**: a few idle lines that are funny only once you know who he is ("Busy? Not lately. Something's jammed the
  intake.").
- **Primm's improvements that were genuinely good** (clean wells, standard measures, school lunches): one grudging mention per zone makes
  him tragic before the castle ("Say what you like about him, the wells were cleaner." / "Standard measures. Even the pie tin.").
- **The "Royal Asset" / "Improvement Opportunity" posters**: Capital lines that read as lost-property notices (funny early, chilling after
  memory 4).
- **Four colours** as the quiet clue: townsfolk or vendors noticing the glow without understanding it, one line each, never a wink.

**Retire or rest**: generic "Shop's open" vendor greetings; "Great!" / "Nice!" filler openers; narration that explains the joke after
making it; three exclamation marks where one would do (except Tilly and Bellows, whose voice it is).

## 6. Worldbuilding facts players should pick up, and where each can live

| Fact | Where it can live naturally (who says it) |
|---|---|
| The four Paths and what each does for the kingdom (energy and transport, food and protection, death administration, waste and farming) | Maren's early lines and stage idles; Alembic ("better mixed"); each zone's arrival and gatekeeper-freed lines; Fenwick's packs; the Undercroft ("settled their rivalries for a thousand years") |
| They argue and need each other anyway (the two rivalries) | zone barks and idle lines, one each; Crosspath townsfolk; Bellows; the Old Service Tunnels (built by all four together) |
| Crosspath is where the four roads meet; each road is blocked by a corrupted gatekeeper | Brannoch, Maren's direction lines, townsfolk, the Quest Log |
| Patchwork's history: the Old Kingdom, House Wayweaver weaving the Paths together without forcing them, the royal crest of four symbols in a ring | Maren's stick (stage 0), the Crosspath fountain, the Vault and its Guardian, Old Man Mountain's festival memories, Alembic |
| King Harmon came to the Lifting Festival every summer with his son; Queen Concordia's lullaby | Old Man Mountain; memory 1; Basil's four-layer cake (the prince's birthday) |
| The coup ten years ago: Primm, Royal Minister of Improvements, killed the king and queen and took the Pathwork Throne; the boy was "lost" | memories 3-4; Wren; Agnes (the unfiled third funeral form); the Capital posters |
| Primm's rise: sincere, brilliant, his early reforms really helped (clean wells, standard measures, school lunches), then sameness | townsfolk grudging praise; Plume's broadcasts; the Archive of Good Intentions; Wren's insights; Old Fern/Marlo |
| Primm's flaws became each zone's corruption (strength = control; appearance over substance; legal means right; fear of what he cannot control) | each zone's lieutenant scene and boss; Wren's four insights; the castle wings |
| Each zone's problem: wheels that never stop and a jailed leader; a faceless impostor and weaponised food; a valid transfer and frozen queues; deathless growth and a grieving archdruid | the zone's first NPC (Mountain/Gus, Basil, Agnes/Gerald, Bramble), its gatekeeper, its signs and barks |
| Death froze when the D.N.A. was seized; Death took a job in Crosspath | Old Hob's lines; Agnes; Gerald; a D.N.A. clerk |
| The Path-ologists studied the Paths; Maren founded the field | Maren (memory 3), the castle records, the Lab |
| The stolen power: Primm's hold slips since the prince escaped, which is why zones can be freed now and rifts open | Rip (rifts are new and easy now), Maren after zone 1, Wren, Primm's reflection phase |
| The resistance: the Wrinkles in the Crease, Wren, Maren as contact | Maren stage 2, Kestrel, Capital whispers, Fig Sly (locked) |
| Power follows the story: one Path, then two after the first freed zone, all after Primm | Maren after memory 1; Fenwick (packs); the ending |

## 7. Small flavour inventions (logged)

Inventions that the pass's suggestions add. They must not contradict canon; none is load-bearing. The Part 2 agents append theirs to
`docs/dialogue/critic_oct31/notes_*.md`; the merged list is below.

(merged after Part 2)
