# Critic pass Oct 31: chunk 02, the Gainlands

Suggestions: `docs/dialogue/critic_oct31/suggestions_02.csv` (31 rows, `node tools/dialogue_critic_check.js --check=...` prints 31 of 31 pass).

## Critique

### Gainlands / gatekeeper (Brick Bronson, rows 1-30)
- Strong overall. The freed Brick is the best thing here: "I cried twice. Good tears.", "Maintenance is how I say sorry.", "...I'm SO glad I
  can say that quietly." Each one sets up and pays off the corrupted shouting.
- The corrupted side is weaker. Row 9 ("EARN YOUR TURN - TEN REPS OF PAIN!") is a generic gym slogan. Row 19 ("HA! The pump is still MINE!")
  is filler. Neither shows the zone's real joke: everyone is exhausted under the hype, and Brick is a softie underneath. Suggested both.
- The boss intro card (row 11) repeats his first dialogue box word for word, so the player reads the same shout twice in a row.
- The Quest Log (21-30) is clear and names places. No changes.
- The blocked narration (row 4) is fine but doesn't tell you who's up there; one tic ("shouting about hydration") fixes that.

### Gainlands (zone, rows 31-335)
- **What works:** the signs are the zone's comedy engine, and most of them land ("If found, do not lift him. He is probably tired.", "Day 1
  has been crossed out forty times.", "Civilization rests on the hamsters not finding out what a salary is.", "(Printed on iron-free
  paper, naturally.)"). Gary, the gym attendant ("House rule two: we have no weights.") and Gus ("The extra ten is me, crying quietly.")
  each have a clear voice. Benchley's floorboard thread (setup, whisper, "footing", freed "I'VE FORGOTTEN HOW") is the best running gag in
  the chunk.
- **Exposition dump:** Old Man Mountain's first box (174) reads like a brochure ("We Beefcakes power the kingdom on mills and hamster wheels,
  and move folks by throw and by portal"). The facts are needed; the voice isn't his. The next box (175) is dense but story-critical, so I
  left it.
- **Characters sounding the same:** Gus's quest hand-in (259) uses Benchley's caps ("HUMMING") and pep-talk energy. Chet's loss line (222) is
  quiet, which his bible entry forbids. Rita and Ripley both say "no tools... just lats" (67, 83). Shredna (79) repeats Mountain's "Nobody's
  been out there in months" from 269.
- **Repetition:** Pump says "brain-ceps" in 191 and again in 193. Baron Quadzilla's after-node line (348) repeats his mid-fight bark (346)
  word for word. The thrower lock fallbacks ("X is always ready.", 75/78/84/90/92) repeat too, but players rarely see them.
- **Missed worldbuilding:** the zone never mentions the Beefcake-Necrocrat rivalry outside the debuff flavour (312), and never gives Primm's
  good early reforms a nod. There's no Quota foreshadowing before her checkpoint, though the story bible puts "efficiency notices on every
  wheel". Old Hob's Gainlands line (319) is cute but doesn't hint that Death is jammed. Pump's burned books (191) are a free chance to say
  the regime erased the Lifting Festival history that Mountain remembers.
- **Small fixes:** the brute enemy line (171) says he flexes "at nobody" and then mentions "his audience". The empty-cup shake (243) joke
  doesn't parse. Benchley's "END THE BULKING ORDERS" (278) is unclear in a quest offer.
- **Direction:** good. Quest offers, actives and Quest Log hints all name the place and the thing. The cross-country sign (140) could say
  where the Gym Rat card is sold, as the thrower's own lock line already does.

### S-IRON (Baron Quadzilla, rows 336-349)
- Short and fun. "No standing ovation required" is a good joke on a man who hasn't stood up in years. The weak spot is the payoff: after
  the fight, the narration reuses the mid-fight "Standing. Wobbly. Like a first rep." Changed it so the payoff gets its own joke.
- The rule text and banners are consistent.

### The House of Gains (rows 350-489)
- **What works:** the narration's rule of three that breaks ("Not a dumbbell. Not a kettlebell. Not a single decorative plate."), the
  breathing under the floor, and the slow push-up behind the door with no handle. It all builds to Flex well. The Quota scenes are crisp
  and in voice ("Disappointing. But measurable."). Clench's pre-boss boxes carry real hurt. The rescue and the throne-room beats are
  sincere and well judged, and I left all of them alone.
- **Flat or off:** the confiscated-gear locker blurb (396) is flat. The Locker Room event (369) cites "a boxing movie", a real-world reference
  that breaks the setting. Flex's rescue box 2 (402, "The rounds are irregular") half-contradicts box 1 ("time their rounds by their
  squats"). The Trophy Hall plate line (457) says "empty" twice.
- The Sauna of Truth text (414, "how hard do you lead?") is vague about what the deck test wants. I didn't change it because I can't see
  the challenge condition here (see design notes).

### After freeing (rows 490-547)
- Warm and mostly earned. Gus's "Turns out a hundred was all of it", Benchley's clearance bin and Mountain's "These ten years were steeper"
  close their threads well. Flex's freed talk ends on the right sincere line.
- Flex's freed talk says Clench is "learning to lift from zero" but never shows it. One concrete image (spotting Gary) would make the
  redemption real.
- A few freed signs are filler or unclear: "Stairs sold separately" (517), "He is holding that pose for himself" (515), and "Leg Day is
  still Leg Day" (523), which repeats sign 520. I left 523 alone because none of my rewrites beat it.
- Mountain's freed intro (524) uses the gamey "the rest of your HP".

## Scores (current lines, before suggestions)

| Area | Writing | Humour | Worldbuilding | Reason |
|---|---|---|---|---|
| Gainlands / gatekeeper | 7 | 7 | 6 | Freed Brick is lovely; corrupted Brick is generic shouting, and the intro card repeats itself |
| Gainlands (zone) | 7 | 8 | 6 | Signs and side NPCs are funny and distinct; Mountain's intro is a brochure; no rivalry and no Primm nuance |
| S-IRON | 7 | 7 | 4 | Good single-joke boss; the payoff repeats the bark; no tie to the wider zone |
| The House of Gains | 8 | 7 | 7 | Strong build to Flex, a sincere rescue and Clench's hurt; a few flat blurbs and one real-world reference |
| After freeing | 7 | 7 | 6 | Threads close warmly; Clench's redemption is only told; a couple of filler signs |

## Best 5

1. `npc.brenda.intro::0` (Old Man Mountain)
   - Before: "Shh. Welcome to the Gainlands. The regime has ears. Big ones. I'm Old Man Mountain. We Beefcakes power the kingdom on mills and
     hamster wheels, and move folks by throw and by portal."
   - After: "Shh. Welcome to the Gainlands. The regime has ears. Big ones. Old Man Mountain. We Beefcakes keep the kingdom's lights on and
     its folks moving. Wheels, mills... and if you're in a hurry, we throw you."
2. `freed_npc.heartlift::3` (Flex)
   - Before: "Clench is learning to lift from zero. The strongest take the longest. The gym is open to everyone now. Come whenever you like."
   - After: "Clench is learning to lift from zero. The strongest take the longest. Yesterday he spotted Gary without being asked. The gym is
     open to everyone now; come whenever you like."
3. `npc.quiz.intro::1` (Professor Pump)
   - Before: "Fifteen concern biceps; the regime burned the other two, so I rewrote them from memory. You cannot confiscate a well-trained
     brain-cep."
   - After: "Fifteen concern biceps. The other two were a history of the Lifting Festival; the regime burned those, so I rewrote them from
     memory. You cannot confiscate a well-trained brain-cep."
4. `travel.ripper_calf.intro::0` (Shredna)
   - Before: "Shredna rolls her shoulders. "Calf Cove. Nobody's been out there in months."
   - After: "Shredna rolls her shoulders. "Calf Cove. Did the old yeti say hello? ...Don't tell me. I don't care. Did he, though?"
5. `sign.wheel::1`
   - Before: "Run it to power the grid. No actual hamsters. Hamsters are on break."
   - After: "Run it to power the grid. No actual hamsters. The hamsters get breaks."

(Close runners-up: Baron Quadzilla's "So those are my feet. Hello, feet." and Brick's "GO HOME AND HYDRATE! THAT IS AN ORDER, NOT
CONCERN!")

## Flavour inventions

- Professor Pump's two burned books were a history of the Lifting Festival (the regime burned them; he rewrote them from memory).
- Freed Clench spotted Gary, unasked, the day before Flex's freed talk.
- The D.N.A. once asked the mill crews for exact start times; the answer was "morning-ish" (the "there-ish, on-time-ish" rivalry).
- The gym's scales are Capital-issue standard measures (Primm's reform), and accurate.
- Every confiscated plate in the House of Gains has its owner's name chalked on the back.
- The House of Gains' entry sign gives a thirty-second authorization rule "by order of the Minister of Efficiency" (Quota; this matches her
  thirty-second searches in the checkpoint blurb, row 356).
- Brick "has not sat down since spring" (corrupted).
- Shredna would like to know whether Old Man Mountain said hello (matches his "She'll pretend she didn't miss me").

## Design notes

- **Unit name mismatch (battle UI):** the Trophy Hall Honor Guard's rule text (row 410) says "a 1/1 Militia joins", but the banner (412)
  says "A 1/1 Reserve Guard steps off a pedestal". Which unit is it? Make the two match. I didn't edit either, because renames are out of
  scope.
- **Hamster wheel names (rows 293-298):** "Gerald" and "The Colonel" clash with Gerald, Number 4,000,212 and Colonel Crumb / Colonel
  Casserole under the "no two characters share a name" rule. A hamster called Gerald may be a deliberate wink. If not, rename them (for
  example "Nugget" and "The Major"). Not suggested as line edits because renames are out of scope.
- **Rip's shirt number:** the bark (row 327) says "two hundred and thirteen", but story bible section 21 lists "shirt number 212" as Rip's
  gag. 213 is the Wanderer's D.N.A. number. Is this deliberate? It would be a lovely hidden echo, but check it against the other Rip barks.
- **The Sauna of Truth (row 414):** "how hard do you lead?" doesn't say what the deck test checks. If the challenge is about the first or
  strongest unit, say so in one plain clause.
- **Generic lock pop-up (row 50):** "Not yet. Come back when you've done a few more reps." is used for any locked spot and gives no
  direction. Where the code knows the lock reason, prefer the per-thrower lock lines.
- **Rivalry and Primm nuance:** this chunk has room for exactly one of each, and I placed them (113 rivalry, 228 standard measures). If
  other chunks also add a Primm-reform line, keep the Gainlands one about measures so the zones don't all say "the wells were cleaner".
- The `npc.brenda.*` and `npc.tony.*` legacy keys carry retired names in their ids only (not player-facing). That's fine; just noting it.

## Counts

- Rows read: 547 (all of the chunk).
- Suggestions: 31.
  - By priority: High 3, Medium 19, Low 9.
  - By category: Humor 10, Worldbuilding 5, Voice 4, Natural 4, Clarity 3, Story 3, Fix 2.
- By area: gatekeeper 4, Gainlands zone 18, S-IRON 1, the House of Gains 4, after freeing 4.
