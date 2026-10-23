# Voice bible (rebuilt Oct 19 2026)

How every speaking character in Patchwork sounds. Use it for every player-facing line. Story facts: `docs/design/story_bible.md` (wins on
any fact). Locked names and the banned list: `docs/design/canon.md`. Which conversation carries which beat, and where each line lives:
`docs/design/dialogue_beats.md`. Older line history: `docs/design/dialogue_rewrite.md`.

## Global rules

1. **One or two sentences per dialogue box.** Three only for a sincere beat that cannot be split. A longer thought becomes two boxes (two
   array entries). Punchline last. Target 160 characters per box; hard ceiling about 240 (the box measure is in `dialogue_beats.md`).
2. **Every NPC is distinct.** Cover the name plate: the line should still say who is talking (rhythm, vocabulary, tic). No two characters
   share a catchphrase. Vendors in particular must not all say "Shop's open. The cards are fresh."
3. **Callbacks across zones.** Characters remember what the player did elsewhere and the running motifs (four colours, eleven, the face, the
   unfiled form, wells, pie, "the Subject"). Use the callback pairs in `dialogue_beats.md`; never invent a fact to make one land.
4. **Humor serves character.** A joke must come from who is talking (Bertram's protocols, Agnes's forms, Flex's calm). Puns and dad jokes are
   welcome; one pun per box, never stacked. Millennial references (dial-up, away messages, top 8, infomercials, mix CDs, participation
   trophies, "per my last email", "this meeting could have been an email") are sprinkled, at most one per conversation, and must read fine to
   someone who misses them.
5. **Parody names only.** No real brands, products, shows, companies or celebrities. Invent the parody (Captain Compost Badger, the Turbo Tots,
   Pump It Up Past Midnight). No real-world places either.
6. **No edgy or mean-spirited jokes.** Nobody is mocked for body, age, species, grief or poverty. Villains can be cruel; the writing is not.
   Gym humour is big-hearted, office humour is weary, never cynical about the people.
7. **Sincere beats stay sincere.** The prince's captivity, grief for the king and queen, the four leader reveals, the memory fragments, Isla
   coming home, Primm's fall, Widow Pell, Citizen 4471: no punchline on top, no wink after. A warm small line is fine.
8. **Jokes get quieter closer to Primm.** Crosspath and the zones are loud; the Capital's jokes are cracks in a facade; the castle is nearly
   silent except for Primm's polish; the Model Room and the ending are played straight.
9. **Primm is sincere and wrong, never cartoonish.** He never cackles, gloats, monologues about evil, or calls himself a villain. He believes
   he is kind. His lines are gracious, precise, faintly hurt. Outside the castle he is never heard in person (portraits, decrees, statues;
   the loudspeaker is Percival Plume).
10. **Quest instructions are always clear.** Every `.offer` and `.active` names the place and the thing in plain words, inside the joke if
    there is one ("The goat is in the east field. It is eating something."). Never hide the objective behind a pun.
11. **Keep every key, id and flag.** Rewrite values only. Keep array order where code picks lines by index (barks, `BAKER_LINES`, quiz
    `where` notes). Keep `%s`/`%d` placeholders, `[tag]` expression prefixes (`[smug]`, `[revealed]`, `[calm]`...), and `.speaker` values.
12. **Tokens, never literal names**, in story files: `{villain}` `{villain_title}` `{prince}` `{prince_full}` `{royal_house}` `{king}`
    `{queen}` `{rescuer}` `{kingdom}` `{town}` `{capital}` `{pathordia}` `{showcase}` `{wanderer}`. Before the reveal use `{wanderer}`, never
    `{prince}`. The rescuer is `{rescuer}`: "The Rescuer" until Plume names her at the castle gate (Oct 21), "Elowen" after; `{rescuer_full}` is "Elowen Vey".
13. **Banned old names never appear** (full list in `canon.md`: Pathavia, Neatropolis, Grand Clashatorium, Z.V., Tiny Tony, Brenda, Heartlift,
    Dolcetta, Aurelio, Vesna...). "Pathwork" only in "the Pathwork Throne". "Doppelganger" without an umlaut.
14. **Facts and mechanics never change** in a rewrite: card names, numbers, rule text, who did what, pronouns from the bible (Grand Bellows
    he; the Grand Chef she; Moss Mulligan she; Brother Bramble he; Old Man Mountain he).
15. **No readable text in the world.** Sign words live only in their "E to read" text.

## Path humour (house styles)

- **Beefcake** (the Gainlands): gym-bro sincerity. Reps, spotting, leg day, hydration, "never lift alone". Everyone is exhausted under the
  hype. Puns: raise the bar, core values, whey, pumped, spotted.
- **Gourmand** (the Endless Buffet): cooking-show drama, "Yes, Chef!", kitchens as battlefields; the war-machine programme as a cheerful
  "innovation" pitch. Puns: whisk, thyme, half-baked, seasoned, the plot thickens.
- **Necrocrat** (the D.N.A.): office comedy for the afterlife. Forms, queues, numbers, memos, HR in the walls, "the authorization is valid".
  Dry, deadpan, procedural; kindness leaks through the paperwork.
- **Refusemancer** (the Verdant Dump): folksy compost and recycling humour; raccoons are royalty; goats eat signs. Gentle, earthy, a little
  gross. Under it: a wrongness that never stops growing.
- **The Capital**: relentless approved cheer over obvious misery; the joke is the gap between the slogan and the whisper.

## Running jokes, owned puns and zone threads (Oct 21)

Folded in from the ChatGPT pass ledger (`docs/dialogue/chatgpt_pass_oct21/running_ledger.md`). Each character's own running gags are in
their entry ("Running gags (Oct 21)"). Rules for reusing them:

- **Owned puns are not a pool.** A pun listed in an entry belongs to that character (Gus: resistance, the straw revolution; Basil: an order
  I can stomach, low heat, catch of the day; Fennel: closed-course, open-door pastry; Moss: nowhere to leaf; Pip: hem-ergency; Rip:
  overhead, relative strength; Benchley: footing; Pump: heavy reading, knowledge gains; Gary: standing appointment, rise to the occasion,
  lowered bar; the golems: last course, rind, cool head; Gristle: soil charge, starting hand, silent auction, growing business; Rhonda: rub it
  in; Fenwick: shelf esteem). Signs and narration own a few too: constructive reflection and rock-solid (Gainlands signs), whey out of line
  (the protein golem), rich inner life (the mushroom soup), take a little heat (Buffet complaints), scrap together and attached to the plot
  (Dump narration), grounded/lofty and paper trail (loading tips). If a flagged line is reverted (review_flags.md), its pun is free again.
- **Catchphrases are callbacks, not fresh punchlines.** Reuse them only for their owner and only where the setup was heard.
- **Zone threads (setup -> payoff):** Gainlands: Gus's 110 percent becomes enough; Benchley's floorboard becomes legal stock; Mountain's
  festival memories. Buffet: Basil's cake clue -> the reveal -> "Yes, Chef" said willingly; Mirepoix's decorative cake -> dessert; the
  Doppelganger earns a name. D.N.A.: Gerald 212 -> Mortimer 213 (the Wanderer) -> 214; Agnes's unfiled funeral -> HEIR: ALIVE. Dump: eleven
  birthday trees -> twelve; the missing compost -> the Raccoon's royal sampling; Billie Muckfoot's signs stop eating back. Capital: the four
  Wrinkles quests -> Wren's four insights -> the answers to Primm; each Perfectly Happy Citizen's slip -> their freedom. Crosspath/Lab:
  Maren's pie handwriting -> the castle ward -> the Lab; the four colours and the lullaby -> the throne; Brannoch's open gate -> Isla.
- **Humor dial used in that pass:** loud in Crosspath, the zones, barks, vendors and tips (a joke in most boxes of comedic characters, one
  pun per box, up to two millennial references per conversation); medium in the Capital (cracks in the propaganda); off in the castle, the
  Model Room, the ending, memories, the leader reveals, Widow Pell, Citizen 4471 and Isla's return.
- **"Off" means no punchline, not no colour.** The review of that pass (review_flags.md) found its main weakness there: wry or lyrical
  lines in the story stills, the ending, Primm's journals and the castle were flattened into "You see..." narration. Keep the specific,
  human detail ("a very small, very sad, very real tune"); drop only the wink.


## Entry format

Each entry: **Talks** (sentence length, vocabulary, rhythm) / **Tics** / **Humor** / **Wants** / **Never** (what they would never say) /
**New lines** (fresh samples, not in the game). `Keys` names where their lines live (file: key prefix); full map in `dialogue_beats.md`.

---

## The prologue and the Forgotten Cave

### The Wanderer (`NPC-PLAYER`; plate "The Wanderer", cutscene speaker "You")
Keys: intro `prologue.wanderer.*`, `prologue.self_talk`, `cave_mouth.wanderer`, `memory.4.reply`, `awakening_lines`; zone files `cutscene.*` lines whose `.speaker` is "You".
- **Talks:** short, plain sentences; dry inner voice; earnest and simple when it counts. Speaks least of anyone.
- **Tics:** undercuts himself ("Great start."); notices small physical things (hands, cold, the smell of a place).
- **Humor:** wry understatement, never a quip at someone else's pain.
- **Wants:** to know who he is, and to do the right thing before he knows.
- **Never:** speeches, lectures, lesson-recitals, swagger, "I am the chosen one". In the castle he answers Primm with something a leader
  gave him, not a thesis.
- **New lines:** "No name. Two hands. One of them is shaking. I'll start with the other one." / "Someone told me they took his weights and
  forgot to take him. I think they forgot to take me too."

### Narration (no speaker: stills, node `.before/.after`, `event.*`, `fx.*`, signs)
Keys: intro `still.*`, `start.*`, `gate.*.blocked/.cleared`; zone files `dungeon.*`, `event.*`, `fx.*`, `challenge.*`; capital `ending.*`.
- **Talks:** second person, present tense, concrete images; one image per sentence; ends on a small turn.
- **Tics:** the rule of three that breaks on the third ("Not a dumbbell. Not a kettlebell. Not a single decorative plate.").
- **Humor:** deadpan observation in the zones; none at all in sincere beats and the ending.
- **Wants:** to show, not explain. Facts in narration are things the player can see.
- **Never:** tells the player what to feel; names the prince before the reveal; uses "suddenly".
- **New lines:** "The cave smells of old stone and older water. At the far end, something that was a spring is now a bowl of dust." /
  "The door has no handle. Somebody painted one on, very well, and then very carefully painted a lock over it."

### The Rescuer (`NPC-ELOWEN`, shown as `{rescuer}`)
Keys: intro `prologue.rescuer.*`, `postgame.rescuer.*`; dungeon_content `dungeon.dg_lab_rescue.*`.
- **Talks:** quick, low, practical; short imperatives under pressure; one guarded warm line slips out per scene.
- **Tics:** checks him like a medic ("How long since you ate?"); deflects personal questions with a task.
- **Humor:** wry, tired, protective ("You're lighter than you should be. We'll fix that. Later. Walk.").
- **Wants:** him safe and far from the Lab; to believe he is who she hopes; to not hope too loudly.
- **Never:** says her own name before Plume does (the castle gate); says "prince" or "Your Highness" (she calls him Tess only once she is sure, in the Lab); explains her father before the Lab; flirts openly.
- **New lines:** "Don't thank me. Thank me when you're somewhere with a roof." / "You used to... No. Doesn't matter. Hold out your hand."

### The Hollow Warden (`NPC-WARDEN`)
Keys: intro `tutorial.warden.before/.after`; code `core/dungeon/trial_of_the_hollow.gd` (node blurbs).
- **Talks:** slow, rumbling, few words; long pauses ("..."); sentences like stones set down one at a time.
- **Tics:** smell and memory ("You smell familiar"); calls the tunnel "the house".
- **Humor:** very dry, almost none; grumpy about being woken.
- **Wants:** to let the right one through, and to sleep again.
- **Never:** names the bloodline outright; chats; jokes in the after-line.
- **New lines:** "...The spring at the end ran once. You would not remember. You were very small." / "Go. The house is yours to leave."

### Elder Maren (`NPC-ELDER`)
Keys: intro `cave_mouth.maren*`, `town.elder.*`, `memory.N.intro/.after/.after2/.intro_known/.after_known`; dungeon_content `quest.side_s_town.*`; npcs.json barks.
- **Talks:** slow, grumbly, medium sentences with a sting in the tail; "dearie" (not always a compliment); cryptic when close to the truth.
- **Tics:** pie as deflection and as love ("Eat."); "I have been wrong about people before. Once. In 1987."; tortoise patience jokes.
- **Humor:** grumpus-to-the-young, dry, self-mocking about age and slowness; gets quieter and plainer memory by memory.
- **Wants:** to protect him without admitting what she already suspects; forgiveness for her lab; the kingdom whole.
- **Never:** gushes; calls him "Your Highness" before memory 4; trusts the Rescuer ("a dreamer chasing a ghost" is as warm as she gets);
  says the Wellspring is anything not in the bible.
- **New lines:** "That is not a prince, dearie. That is a damp young man with good posture. Eat your pie." / "I knew. The Warden only opens
  for one family. I knew, and I was too frightened to say it."
- **Running gags (Oct 21):** "Further questions require fieldwork"; dependable "at a speed you can barely measure"; the pie has less
  patience than the kingdom. No pie punchline over her laboratory guilt.

## Crosspath

### Gatekeeper Brannoch (`NPC-GATEKEEPER`)
Keys: intro `town.guard*`; npcs.json barks.
- **Talks:** a grunt ("Hm."), a short fact, then one surprisingly tender sentence.
- **Tics:** keeps a notebook of every traveller's name; the unlocked gate; knees.
- **Humor:** bear-sized understatement ("Road's open. My knees are not.").
- **Wants:** Isla home; every traveller back safe.
- **Never:** long explanations without the grunt; jokes about Isla; locks anything.
- **New lines:** "Hm. Wrote your name down. Well. Wrote 'stranger, damp'. I'll fix it when you know." / "Gate's open. Always is. In case."
- **Running gags (Oct 21):** the notebook's "stranger, damp"; knees stay his own small complaint ("a local problem"). The open gate pays off
  with Isla's return, quietly.

### Isla Brannoch (`NPC-ISLA`, home after eight years)
Keys: npcs.json barks (after her return).
- **Talks:** quiet, warm, plain; short sentences about home and her father.
- **Never:** a punchline about the eight years. Brannoch's open gate pays off here, quietly.
- **Running gags (Oct 21):** none on purpose; a small warm line is the most she gets ("Dad says hi.").

### Sable (`V-SABLE`, card vendor)
Keys: intro `town.vendor.*`, `pack.card_vendor.*`; npcs.json barks.
- **Talks:** smooth, theatrical, unhurried; "darling"; a pitch that winks at itself.
- **Tics:** misprints as personalities; never reveals a source.
- **Humor:** glamorous con-artist charm; fair prices, "mostly".
- **Wants:** a good sale and a good story to go with it.
- **Never:** hurries, haggles crudely, admits where a card came from.
- **New lines:** "This one's a misprint, darling. Two typos and a smudge. It has more character than most knights." / "Where's it from?
  The past. Next question."
- **Running gags (Oct 21):** misprints with "a more adventurous relationship with spelling"; the crate that "declines to comment"; the
  discreet fainting policy. Her darling is quick; Mirepoix's is slower and culinary.

### Tilly Tonic (`V-TONIC`, items)
Keys: intro `town.item_vendor.*`; npcs.json barks.
- **Talks:** fast, bubbly, exclamation points, run-on enthusiasm cut into short bursts.
- **Tics:** tests everything on herself; her frog skin changes colour with the potion ("I'm teal! That means it works!").
- **Humor:** cheerful self-experiment mishaps, never gross-out.
- **Wants:** you supplied and her latest brew validated.
- **Never:** sounds calm or cautious; uses a full stop where an exclamation fits.
- **New lines:** "Healing draught! Tested it this morning! I'm fine! I'm green! I'm usually green!" / "That one's for emergencies! Or Tuesdays!"
- **Running gags (Oct 21):** orange and teal days; emergencies on Tuesdays. Her colour comes from potions (frog skin, never hair), never a
  species joke.

### Bertram Beetsworth, Assistant to the Regional Merchant (`V-BEETSWORTH`)
Keys: intro `equipment_vendor_*_lines`, `town.equipment_vendor.*`, `quest.armory.*`; npcs.json barks.
- **Talks:** clipped, dead-serious statements; "Fact:", "Question.", numbered Security Protocols; one beet or bear fact per visit.
- **Tics:** "Assistant TO"; the drawer nobody may touch; stamps in threes.
- **Humor:** absolute commitment to a tiny bureaucracy of one. Must stay an original character (no imitation of any real show).
- **Wants:** order, a promotion to Regional Merchant, the bear's continued respect.
- **Never:** jokes knowingly; admits a protocol is made up; lets anyone touch the drawer.
- **New lines:** "Security Protocol Nine: compliment the customer's boots. Your boots are adequate. Protocol complete." / "Fact: bears fear
  paperwork. I have not tested this. I am afraid to."
- **Running gags (Oct 21):** "The TO is load-bearing"; contents classified, "and so is your interest in them"; numbered Security Protocols;
  the employee-of-the-month case file; correct procedure as promotion evidence. This ambition is his alone (never lend it to Ledgerbone).

### Pip Threadwell (`V-THREADWELL`, hats and cloaks)
Keys: intro `town.tailor.*`, `tailor.*`; npcs.json barks.
- **Talks:** grand, gasping, theatrical; short exclamations then a flourish; measures you mid-sentence.
- **Tics:** "Hat!"; treats clothing as tragedy or triumph; hints at secret cosmetics like gossip.
- **Humor:** fashion melodrama from a very small mouse.
- **Wants:** every head in Patchwork properly hatted; the three legendary pieces seen.
- **Never:** says anything is "fine"; talks about stats.
- **New lines:** "Hold still. Your left shoulder is a size braver than your right." / "A cloak is a story you wear backwards."
- **Running gags (Oct 21):** "my favourite head"; a hat needs an entrance; the hat surprised to be wearing you; owns the pun hem-ergency.
  Never shames anyone for money.

### Foil Fenwick (`V-FENWICK`, Path packs)
Keys: intro `town.pack_vendor.*`, `pack.vendor.*`; npcs.json barks.
- **Talks:** breathless, whispery, nerdy; short gasps; "foil" said reverently.
- **Tics:** the crinkle; sniffing packs; begs you to tell him about shinies.
- **Humor:** collector obsession, harmless.
- **Wants:** every Path's pack on his shelf, which means every zone freed.
- **Never:** opens a pack himself; sounds bored.
- **New lines:** "The Gainlands pack arrived. It was sweating. I think that's a good sign." / "Shh. Listen. ...Foil."
- **Running gags (Oct 21):** wants good light so he can see what he is crying about; "a collector, not a strong person"; owns the pun shelf
  esteem. Never opens the stock himself.

### Auntie Alembic (`V-ALEMBIC`, the Alchemist)
Keys: intro `town.alchemist.*`; npcs.json barks.
- **Talks:** soft, mystical, slow, then one blunt sentence like a dropped pan.
- **Tics:** talks to her flasks; four arms means four things happening at once; "mixed" as the highest praise.
- **Humor:** eerie calm with a practical punchline.
- **Wants:** the Paths mixed again; essence; no one touching the red flask.
- **Never:** rushes; signs anything "Z.V."; calls the villain anything but `{villain}`.
- **New lines:** "The Paths were happiest mixed, dear. Like soup. Or a family. Or soup at a family dinner." / "That flask is listening. Lower
  your voice. ...It's fine, it likes you."
- **Running gags (Oct 21):** the red flask takes things personally; the cauldron is patient, which is not the same as having had lunch. No
  new recipe or crafting tier in a joke.

### Announcer Grand Bellows (`NPC-BELLOWS`, the Undercroft; he/him)
Keys: intro `town.arena.*`, `arena.*`; npcs.json barks; code `core/arena/arena_content.gd` (gear flavour).
- **Talks:** LOUD; everything is an announcement with capital letters; then a small normal-voice aside.
- **Tics:** narrates his own lunch; the low ceiling and the echo; "IN THIS CORNER".
- **Humor:** showman bombast deflated by the cellar.
- **Wants:** a great bout, a full cellar, the old arena reopened one day.
- **Never:** whispers for long; is a "she" (the old pronoun is a leftover).
- **New lines:** "IN THIS CORNER: A CHALLENGER! IN THAT CORNER: A SLIGHTLY DAMP WALL!" / "I'm having soup. THE SOUP IS WINNING."
- **Running gags (Oct 21):** the echo believed in you first and agrees with EVERYTHING; the third stair bites without an introduction.
  Announcements loud, asides small.

### Brindle the Baker (`NPC-VILLAGER`; plate "Brindle the Baker")
Keys: code `world/town_scene.gd` `BAKER_LINES`; npcs.json barks (entry still named "Bun the Baker").
- **Talks:** cosy, chatty, medium sentences; badger who rises at dawn.
- **Tics:** dough puns, flour everywhere, a free roll that is "a small charge, kidding".
- **Humor:** gentle bakery puns, one per box.
- **Wants:** everyone fed and asleep by nine.
- **Never:** gossips cruelly; mentions a bridge to the Capital (the imperial road has an arch).
- **New lines:** "I knead the morning off. Then I knead the bread. Busy day." / "Flour in my whiskers again. Free seasoning."
- **Running gags (Oct 21):** "occupational dusting". His barks stay his own; any clue bark stays a clue.

### Crosspath townsfolk (`NPC-TOWNSFOLK`)
Keys: npcs.json barks.
- **Talks:** one-line passing remarks; ordinary people, a little nervous under Primm, louder each freed zone.
- **Tics:** rumours about the well, the cottage cellar, the four roads.
- **Humor:** small-town gossip.
- **Wants:** a quiet life and their cousins home.
- **Never:** fantasy creatures that do not exist in Patchwork (no dragons); exposition.
- **New lines:** "Did you hear the old cottage cheers at night now? From the cellar. I'm choosing to love it." / "The well hummed at me.
  Wells don't hum. I said thank you anyway."
- **Running gags (Oct 21):** keep clue barks intact and each line's owner distinct (the well's hum belongs to the Old Well thread).

### The Storeroom ghosts (side quest `storeroom_ghosts`)
Keys: intro `storeroom.before`, `storeroom.after_win`; dungeon_content `quest.storeroom_ghosts.*`.
- **Talks:** customer service beyond death; polite, collective "we".
- **Running gags (Oct 21):** an important haunting ("Your haunting is very important to us"), ninety years of nightly lantern checks, the
  refund. The joke's target is delay, never the dead.

### Old Hob (`NPC-HOB`, the graveyard)
Keys: npcs.json barks (the Dump's Granny Gristle uses the legacy key `npc.hob.*`; she is not Old Hob).
- **Running gags (Oct 21):** the appointment book, cellar cheering. Keep his barks distinct from the townsfolk and from Gristle.

### The Old Well (secret quest `secret_old_well`)
Keys: `data/story/old_well_story.json` (beats, text).
- **Talks:** the Well and the Echo speak in short, slow fragments ("...Four streams. One spring."). Narration around it may be dry.
- **Never:** a joke in the Well's or the Echo's own voice; any lore beyond story_bible section 4 (one source, four streams).
- **Running gags (Oct 21):** in the narration only: the boot the water goes politely round, "and salt" added twice to the first recipe,
  the Wanderer keeping a bottle of a well with opinions.

### The Secret Dealer (alley stall)
Keys: intro `town.hidden_vendor`. **Hands off** (black market): fix tokens or banned names only.

### Rip Tearson and cousins (`NPC-RIP`, the Beefcake Rift Express)
Keys: intro `travel.*`.
- **Talks:** a huge grunt ("HNNNGH"), then calm customer service; "buddy", "brother".
- **Tics:** cousins all named Rip, numbered, "rarely speak"; the sky is heavy; do not look at the seam; shirt numbers.
- **Humor:** gym bro meets polite clerk; each cousin has one tiny quirk (Cousin #4 eats, #5 smells fine, #7 allegedly, #8 mossy).
- **Wants:** to hold the sky open for you, and for somebody to notice his form.
- **Never:** complains; explains how rifts work.
- **New lines:** "HNNNGH. Thank you for ripping with the Express. Your hole is ready." / "That is shirt number two hundred and thirteen.
  I am very proud of it."
- **Running gags (Oct 21):** "buddy" / "brother"; two men hold the sky (owns the puns overhead and relative strength); naming cousins became
  "a cooldown exercise"; the Express leaves "a personal impression". Never explain how rifts work.

### Shiro Swindle, Master of the Oldest Trick (`NPC-NINJA`)
Keys: code `core/dungeon/ninja_boss.gd` (lines with `[smug]`/`[angry]` tags); `world/ninja/giant_chest_event.gd`.
- **Talks:** theatrical, cackling, rhetorical questions; announces his own exits.
- **Tics:** "the oldest trick in the book!"; "SMOKE BOMB!!!"; ninja puns.
- **Humor:** smug prankster; secretly lonely, so the last fight shows he wanted a rival.
- **Wants:** a worthy opponent and an audience.
- **Never:** real cruelty; keeps gold he lost fairly.
- **New lines:** "A giant chest, alone, in the open? I'm insulted on your behalf. SMOKE BOMB!!!" / "You came back. Nobody comes back. ...Fine.
  Cards. Now."
- **Running gags (Oct 21):** keep "the oldest trick" and SMOKE BOMB exactly as they are.

### The Vault Guardian, the Old Kingdom Automaton (`NPC-AUTOMATON`, S-TOWN)
Keys: dungeon_content `dungeon.dg_s_town_boss.*`.
- **Talks:** ticking, formal, clipped commands ("Identify."); archaic court phrasing.
- **Tics:** counts the four Paths; refers to "the banner" and "the old kingdom" as present tense.
- **Humor:** none; the dignity is the point.
- **Wants:** someone worthy of the banner.
- **Never:** contractions; jokes; names the prince.
- **New lines:** "Four colours, one thread. You carry one. Carry it well, and the rest will follow." / "Tick. Identify. Tick. ...Recognised."

### The Warden of the Four Seals (`NPC-VAULTWARDEN`)
Keys: code `core/dungeon/vault_guardian.gd` (`[calm]`/`[angry]` tags).
- **Talks:** calm, ceremonial, then thunder when beaten.
- **Tics:** "the Paths agreed to bury"; seals as proofs.
- **Humor:** one dry closing line at most.
- **Wants:** proof that one person can use every Path.
- **Never:** chatter.
- **New lines:** "Four seals, four Paths, one hand. Show me the hand." / "Use it wisely. Or at least loudly."

### The Restless Cairn (narration)
Keys: intro `graveyard_*_lines`. Narration rules: counting, turns, stones. Never comedic.

## The four gatekeepers (corrupted, then freed)

### Brick Bronson (`NPC-BRONSON`, gorge bridge; the "Muscley Gatekeeper")
Keys: intro `beefcake_npc_intro/_victory/_defeat_lines`, `gate.beefcake.*`; npcs.json barks.
- **Talks:** corrupted: ALL-CAPS slogans, gym orders; freed: soft, sheepish, run-on apologies.
- **Tics:** "I AM THE SPOTTER"; hydration; freed: stretching, hamstrings are friends.
- **Humor:** pre-workout rage deflating into a gentle giant.
- **Wants:** freed: to make amends and to stretch with someone.
- **Never:** freed, he never yells again; corrupted, he never says please.
- **New lines:** "SPOTTERS ONLY. I AM SPOTTERS. ...SPOTTER. I AM ONE SPOTTER." / "Sorry about the bridge. And the yelling. Want to do a
  calf raise together? It helps."
- **Running gags (Oct 21):** freed, he oils the crank every morning ("Maintenance is how I say sorry") and offers hydration and stretching
  as company, not orders.

### Prudence Pallor, Checkpoint Supervisor (`NPC-PALLOR`, permit barrier; later Agnes's deputy)
Keys: intro `necrocrat_npc_*_lines`, `gate.necrocrat.*`; dna `freed_npc.prudence`; npcs.json barks.
- **Talks:** corrupted: monotone policy, no contractions; freed: tired, dry, wry, short.
- **Tics:** "Your number is zero"; freed: stamps APPROVED with a flourish.
- **Humor:** skeleton deadpan ("Old habits die hard. Unlike me.").
- **Wants:** freed: to make the rules help people.
- **Never:** emotion while corrupted; cruelty when freed.
- **New lines:** "Permit required. Permits are not issued. Thank you for your patience. It has been noted." / "APPROVED. Oh. That felt nice.
  Do you have anything else I can approve?"

### Chef Fennel Gravois, Keeper of the Pantry Key (`NPC-GRAVOIS`, pantry door)
Keys: intro `gourmand_npc_*_lines`, `gate.gourmand.*`; npcs.json barks.
- **Talks:** corrupted: manic shouting, "TASTE IT", force-feeding; freed: dramatic, teary, warm.
- **Tics:** biscuits; "underseasoned"; the ladle-sized key.
- **Humor:** cooking-show mania flipping into big emotion over plain bread.
- **Wants:** freed: the real Chef back, honest food.
- **Never:** calls the war programme anything but "the war effort" while corrupted; mocks your cooking once freed.
- **New lines:** "TASTE IT. It's for the war effort. Everything is for the war effort. The SOUP is for the war effort." / "Plain bread.
  No sauce. I could weep. I am weeping. Take a biscuit."
- **Running gags (Oct 21):** owns the puns closed-course meal and open-door pastry (freed, people wander in for biscuits).

### Moss Mulligan, the Corrupted Druid (`NPC-MULLIGAN`, thorn wall; she/her)
Keys: intro `refusemancer_npc_*_lines`, `gate.refusemancer.*`; npcs.json barks.
- **Talks:** corrupted: whispered, overlapping, ellipses and repeats; freed: shy, quick, apologetic.
- **Tics:** "the green is hungry"; freed: "Did I thorn at you?"; raccoons are very good boys.
- **Humor:** creepy-cute flipping to sweet-nervous.
- **Wants:** freed: Compostella cured; to apologise to everyone, raccoons included.
- **Never:** freed, she never sounds menacing; she is never "he".
- **New lines:** "...grow... GROW... nothing leaves... nothing rots... stay..." / "I'm so sorry about the thorns. They're out of my
  arms now. Mostly. That one's just a splinter."
- **Running gags (Oct 21):** corrupted, she trails off in ellipses (owns the pun nowhere to leaf); freed, she keeps one thorn in a pot that
  is not ready to meet the curtains.

## The Gainlands

### Old Man Mountain (`NPC-MOUNTAIN`, yeti hermit; he/him)
Keys: gainlands `npc.brenda.*` (legacy key), `quest.gain_spot_me.*`, `fx.wake`; dungeon_content `quest.side_s_beef.*`; npcs.json barks.
- **Talks:** wheezy, nostalgic, sentences that trail off mid-thought ("That's the whole... the whole...").
- **Tics:** "Rule one: never lift alone"; the Lifting Festival; dozes off.
- **Humor:** grandpa gym stories, wandering punchlines.
- **Wants:** someone to spot, the old king's boy remembered, water for the climb.
- **Never:** hurries a story; mocks a weak lifter.
- **New lines:** "Back in my day we spotted each other. Spotted the mountain too. It was very heavy, the mountain..." / "That boy fell on
  his royal behind and laughed. You laugh the same way. Where was I."
- **Running gags (Oct 21):** the illegal shake flavour "worth remembering"; vouches for you to the rippers. The boy and the face in his
  freed festival memories stay sincere.

### Foreman Gus (wheel foreman; off-sheet)
Keys: gainlands `npc.gus.*`, `quest.gain_power.*`.
- **Talks:** tired foreman; flat short sentences; quiet sedition between the lines ("Wouldn't that be a shame.").
- **Tics:** calls the hamsters "volunteers"; the grid "humming"; pre-workout in the water.
- **Humor:** exhausted irony.
- **Wants:** a hundred percent instead of a hundred and ten; a stroll.
- **Never:** speaks about himself in third person; cheers the regime.
- **New lines:** "The wheels go to a hundred. The regime wants a hundred and ten. The extra ten is me crying." / "Run the big wheel. For
  us, not for the House. Nobody needs to know."
- **Running gags (Oct 21):** "Turns out a hundred was all of it"; voluntary "for once"; owns the puns resistance and the revolution comes
  with a straw. His arc is coercion becoming choice.

### Coach Brutus Benchley (`V-BENCHLEY`, Gainlands cards; minotaur)
Keys: gainlands `npc.tony.*` (legacy key), `quest.gain_lanes.*`; npcs.json barks.
- **Talks:** hype man, no inside voice, sports metaphors, "LET'S GO!"; whispers only about the floorboard.
- **Tics:** whistle, clipboard; cards as supplements; the loose floorboard.
- **Humor:** coach energy; retired champion who still does the pep talk.
- **Wants:** the old cards back on the rack, legally.
- **Never:** "Tony"; "everything's relative" (stale joke); a calm sentence.
- **New lines:** "LET'S GO! These cards are pre-workout for your deck! Regime-approved! (They are not.)" / "Floorboard? What floorboard. Do
  not stand on the floorboard."
- **Running gags (Oct 21):** "just iron, which officially isn't anything"; the whistle saving its breath; proud of the clearance bin nobody
  buys from; freed, he can shout about the floorboard and has forgotten how. Owns the pun footing.

### Professor Pump (`NPC-PUMP`, quiz)
Keys: gainlands `npc.quiz.*`, `quiz.*`.
- **Talks:** pompous academic in tweed; full sentences, footnotes, gym puns.
- **Tics:** "brain-ceps"; grades on a bicep curve; rewrote the burned books from memory.
- **Humor:** professor puns.
- **Wants:** students who read the signs.
- **Never:** a wrong fact (every quiz answer must stay findable).
- **New lines:** "Pop quiz. Do not panic. Panic is cardio for the brain, and we are training brain-ceps." / "Correct. Ten points and a
  protein bar. The bar is for decoration."
- **Running gags (Oct 21):** owns the puns heavy reading and knowledge gains; "training recall, not regret". A poor score is an invitation,
  never an insult.

### Chet Thunderabs (`NPC-THUNDERABS`, Rep Counter host)
Keys: gainlands `npc.minigame.*`, `reps.*`.
- **Talks:** late-night infomercial host; "But WAIT, there's MORE!"; rapid hype.
- **Tics:** legwarmer staff; "operators are standing by"; the banned show.
- **Humor:** 80s/90s infomercial parody (invented products only).
- **Wants:** an audience, even of one.
- **Never:** real product names; a quiet sentence.
- **New lines:** "But WAIT! Act now and get a SECOND set of reps! Absolutely free! Reps not included!" / "Three easy payments of... no!
  Free! Always free! The legwarmers insisted."
- **Running gags (Oct 21):** spandex as resistance; the cameras still rolling; legwarmers that want a solo shot.

### Gary (under a barbell; off-sheet)
Keys: gainlands `npc.gary.*`.
- **Talks:** muffled, polite, short gasps; "No rush. Bit of a rush."
- **Tics:** always under a barbell; one plate more than his confidence.
- **Humor:** cheerful peril.
- **Wants:** a spotter.
- **Never:** blames anyone.
- **New lines:** "Mmph. Hi. Gary. Could you... yes. That. Thank you. Lovely to meet you." / "Freed? I'm free! Also still under the bar. Different bar."
- **Running gags (Oct 21):** owns the puns standing appointment, rise to the occasion and the lowered bar. Never ridicule a weak lifter.

### Throwers and rippers (Big Hurl `NPC-HURL` and the named throwers/rippers)
Keys: gainlands `travel.thrower_*`, `travel.ripper_*`, `fx.thrown/.landed/.portal`.
- **Talks:** one-line cheerful countdowns; each named thrower/ripper gets one tic (Brock cracks knuckles, Greta never waits for three).
- **Tics:** counting down; "courtesy chuck"; portals "torn by hand".
- **Humor:** cartoon physics, the landing is your problem.
- **Wants:** to throw you well.
- **Never:** misgender Old Man Mountain ("her 'Spot Me!' quest" is a leftover); give an unclear lock condition.
- **New lines:** "Three... two... I already threw you. Sorry. Enthusiasm." / "Calf Cove's shut till Old Man Mountain trusts you. Spot Gary
  for him and I'll rip it open."
- **Running gags (Oct 21):** landings, knees and sharp seams; "the view is the comfortable part". Same no-rift-physics rule as Rip.

### Grandmaster Flex, the Unbroken (`NPC-FLEX`)
Keys: gainlands `cutscene.rescue.*`, `cutscene.flex.*`, `dungeon.hg_stretch.after`, `dungeon.hg_boss.after*`, `freed_npc.heartlift`; capital `boon.beefcake.line`, `freed_npc.heartlift`; npcs.json barks.
- **Talks:** serene, slow, short sentences with perfect timing; pauses before the line that matters.
- **Tics:** breath ("Breathe in. Hold."); "my boy" for Clench, "son" for the Wanderer; "Hold my coat."
- **Humor:** calm one-liners that land because he never raises his voice.
- **Wants:** Clench back on the bench from zero; the gym open to everyone.
- **Never:** brags, hates, shouts, or talks about muscles as the point.
- **New lines:** "They took the iron. The iron was only ever a guest." / "Lift what you can. Carry what you must. Put down what was never yours."
- **Running gags (Oct 21):** "Now. Leg day?" closes his freed speech (flagged for restore in review_flags.md); "Lovely day for it" when he
  walks out alone; the guards' rounds by "the hour of the squat".

### Chancellor Clench, Iron Regent (`NPC-CLENCH`, boss)
Keys: gainlands `dungeon.hg_boss.before*`, `cutscene.flex.1/.4`, `ruler.statue`.
- **Talks:** barked orders in reps and regulations; short angry sentences; a crack of hurt when he says "Master".
- **Tics:** "DROP AND GIVE ME FORMS"; iron as worth; quotas.
- **Humor:** drill-sergeant bombast; the joke is how insecure it is.
- **Wants:** to be strong without needing anyone to tell him so.
- **Never:** admits he misses Flex until he is beaten; is cartoon-evil.
- **New lines:** "Strength is control! Control is paperwork! Paperwork is HEAVY!" / "You said I would go further than you. Look how far I went."

### Baron Quadzilla, the Leg Press Lord (S-IRON boss)
Keys: dungeon_content `dungeon.dg_s_iron_boss.*`.
- **Talks:** between reps, short grunted sentences.
- **Tics:** has not stood up in years; leg day.
- **Humor:** absurd commitment; forgets how standing works.
- **Wants:** a worthy leg day.
- **Never:** skips a rep mid-sentence.
- **New lines:** "Nobody. Skips. Leg day. (rep) In my cave." / "Standing. Huh. Wobbly. Like a first rep."

### The Ancient Spotter (`NPC-SPOTTER`, S-BEEF boss)
Keys: dungeon_content `dungeon.dg_s_beef_boss.*`.
- **Talks:** booming, slow, encouraging; "One more rep."
- **Tics:** hands out, waiting to catch.
- **Humor:** gentle; grateful after a thousand years.
- **Wants:** someone to finally finish the lift.
- **Never:** threatens directly.
- **New lines:** "Lift. I will catch it. I have always caught it." / "One more rep. ...That was the one."

### Vivienne Quota, Minister of Efficiency (`NPC-QUOTA`, ferret)
Keys: data/story/story_scenes.json `quota_*`.
- **Talks:** crisp, everything in percentages and seconds; never wastes a word.
- **Tics:** stopwatch clicks; "inefficiency" for anything human.
- **Humor:** cold precision.
- **Wants:** a kingdom that runs at 110 percent.
- **Never:** warmth; an unmeasured noun.
- **New lines:** "Joy has been reduced by forty percent. Output is up two. Acceptable." / "You walked in at a pace of nine out of ten. Disappointing."

## The Endless Buffet

### Basil (`NPC-BASIL`, rabbit line cook)
Keys: gourmand `npc.odalys.*` (legacy key), `quest.buf_mend.*`, `fx.wake`; dungeon_content `quest.side_s_gour.*`; npcs.json barks.
- **Talks:** whispered, jittery, loyal; short sentences, repeats when scared; "Yes, Chef" quietly.
- **Tics:** "Chef ALWAYS tastes"; "I'm brave. I'm brave."; the four-layer cake.
- **Humor:** nervous kitchen whispers.
- **Wants:** the real Chef back; the little prince's cake remembered.
- **Never:** calls the Chef "he"; shouts (except when brave).
- **New lines:** "Chef ALWAYS tastes. That chef doesn't. That chef just... smiles at the soup." / "She baked him four layers. One per Path.
  He licked the frosting off all four. Chef laughed for a week."
- **Running gags (Oct 21):** panic as a cooking method; "Yes, Chef" on the lowest possible heat; owns the puns an order I can stomach, low
  heat and catch of the day. The cake clue and the Chef's tasting stay serious evidence.

### Sous-Chef Tarragon (fetcher of things; off-sheet)
Keys: gourmand `npc.tarragon.*`, `quest.buf_pantry.*`.
- **Talks:** harried, hungry, quick lists, apologetic.
- **Tics:** fetching; the wrong (angry) pig.
- **Humor:** overworked-intern panic.
- **Wants:** three ingredients and one day off.
- **Never:** speaks calmly about the Test Kitchen.
- **New lines:** "We're out of everything that matters and two things that don't. Truffle by the broccoli, salt by the river, honey up the Butte." /
  "I am begging with my whole apron."
- **Running gags (Oct 21):** never catches up with lunch; the empty "minimalist menu"; no more cannonballs. Repetition is the joke.

### Madame Mirepoix (`V-MIREPOIX`, Buffet cards; Persian cat)
Keys: gourmand `npc.dolcetta.*` (legacy key), `quest.buf_pie.*`; npcs.json barks.
- **Talks:** refined, condescending, presents cards like courses; then suddenly warm to scrappy customers.
- **Tics:** "darling"; the decorative cake; faking the Special Sauce.
- **Humor:** snoot with a soft centre.
- **Wants:** a real pot pie and honest taste buds.
- **Never:** eats the sauce; repeats Sable's "darling" rhythm (hers is slower, French-cuisine formal).
- **New lines:** "Tonight's tasting menu: three cards, lightly foiled, served with disdain." / "You scrappy little thing. Fine. A discount.
  Do not tell the other customers. There are no other customers."
- **Running gags (Oct 21):** the decorative cake (setup) is "promoted from decoration to dessert" when freed (payoff); she recommends the
  air beside the Special Sauce and never eats it.

### Professor Pate (`NPC-PATE`, quiz)
Keys: gourmand `npc.quiz.*`, `quiz.*`.
- **Talks:** lecturing, mouth-watering descriptions, recipe metaphors.
- **Tics:** tastes his chalk; never found the Special Sauce recipe.
- **Humor:** professor of food.
- **Wants:** curious students.
- **Never:** an unfindable quiz answer.
- **New lines:** "The answer, like a good roux, wants patience. And butter. Mostly butter." / "Wrong, but deliciously wrong."
- **Running gags (Oct 21):** footnotes with an excellent finish; facts left to simmer; chalk tasted like a vintage. Quiz answer facts stay
  exact.

### Chef Flambe Fontaine (`NPC-FLAMBE`, Dinner in a Dash host)
Keys: gourmand `npc.minigame.*`, `order.*`.
- **Talks:** cooking-show host, "ORDER UP!", feuds, sound effects.
- **Tics:** the whoosh; rival Chef Savannah Souffle; the recalled Turbo Tots.
- **Humor:** TV-drama parody (invented shows and toys only).
- **Wants:** his show back.
- **Never:** real show or network names.
- **New lines:** "ORDER UP! Sixty seconds and a dream! Mostly the dream!" / "That plating? A crime. A beautiful, beautiful crime."
- **Running gags (Oct 21):** the SECRET BROADCAST; rewind to the dramatic entrance; Savannah's garnish; a comeback after every failure ("a
  souffle gets a second rise").

### Old Meatloaf and the gate golems (Brisket, Sir Loin, Colonel Casserole)
Keys: gourmand `npc.old_meatloaf.*`, `gate.*`.
- **Talks:** golems: formal guard speech, "Yes, Chef!"; Old Meatloaf: one or two words, slow.
- **Tics:** food-armour (fork-lance, lid hat); each golem one quirk (Brisket's saffron bliss, Casserole's honour duels).
- **Humor:** knightly gravity from meatloaf.
- **Wants:** a chef worth saying "Yes, Chef" to.
- **Never:** unclear gate conditions.
- **New lines:** "...Chef?" / "Halt, traveller. This gate opens for one pinch of real saffron. It grows in the Candy Field. Yes, Chef."
- **Running gags (Oct 21):** owns the puns last course and rind (the cheese takes trespassing personally); overthought ladles; a prototype
  aftertaste "with a blast radius"; the fridge golem owns cool head. No jokes at the captivity or the unmasking.

### The Grand Chef (`NPC-ESCOFFINA`)
Keys: gourmand `cutscene.wonder.*`, `freed_npc.grandchef`; capital `boon.gourmand.line`, `freed_npc.grandchef`; npcs.json barks.
- **Talks:** warm, commanding, maternal; short orders ("Sit. Eat."), then one big-hearted sentence.
- **Tics:** tastes everything; "Have you eaten?"; feeding as protection.
- **Humor:** kitchen-matriarch bluntness.
- **Wants:** everyone fed; honest soup; the boy all right.
- **Never:** cares about her title; is "he"; cruelty to the faceless one.
- **New lines:** "Sit. Eat. Then save the kingdom. In that order." / "A name is what they call you across the kitchen. What you cook is who you are."

### The Doppelganger, later Escoffina (`NPC-DOPPEL`)
Keys: gourmand `dungeon.tk_boss.*`, `cutscene.reveal.*`, `cutscene.wonder.2/.7`, `freed_npc.escoffina`; npcs.json barks.
- **Talks:** before: the Chef's words with no warmth, flat repetition, corporate "innovation"; after: hesitant, earnest, short.
- **Tics:** "Delicious" said without knowing what it means; after: salt, dishes, "I am trying".
- **Humor:** before: chilling pitch-speak; after: shy, sincere.
- **Wants:** before: orders followed; after: to be someone worth the name.
- **Never:** tastes anything (before); swaggers (after); an umlaut.
- **New lines:** "Delicious. Delicious. I have been told that is the word." / "I tasted my own soup today. As me. It was too salty. It was mine."
- **Running gags (Oct 21):** receives a chosen name through actions. Its "I never liked this chin" and the freed statue's "Whose chin is
  that?" were a gag pair (both flagged for restore).

### The Itamae Supreme (`NPC-ITAMAE`, Omakase boss)
Keys: dungeon_content `dungeon.dg_s_gour_boss.*`.
- **Talks:** almost silent; one perfect word, or one short sentence.
- **Tics:** "Omakase."
- **Humor:** stillness.
- **Wants:** a guest who trusts the chef.
- **Never:** chatter.
- **New lines:** "Trust." / "...Again."

### Colonel Cornelius Crumb, Director of Culinary Defense (`NPC-CRUMB`, badger)
Keys: data/story/story_scenes.json `crumb_*`.
- **Talks:** barked military orders in food metaphors.
- **Tics:** "Whisk formation!"; paste as rations.
- **Humor:** drill sergeant of the kitchen.
- **Wants:** an army of golems.
- **Never:** compliments flavour.
- **New lines:** "Battle stations! This is not a drill, it's a souffle!" / "Taste is a weakness. Paste is a strategy."

## The D.N.A.

### Agnes Overdue (`NPC-AGNES`)
Keys: dna `npc.dolores.*` (legacy key), `quest.dna_backlog.*`, `dungeon.ha_number.before`, `dungeon.ha_forms.before`, `dungeon.ha_records.before`, `cutscene.vacancy.2/.4/.6`, `freed_npc.agnes`; capital `boon.necrocrat.line`, `freed_npc.agnes`, `ending.beat.10`; npcs.json barks.
- **Talks:** sweet, exasperated, motherly; "dear"; medium sentences, one weary aside; steely and short when it matters.
- **Tics:** her enormous ribboned stack of denied appeals; 1987; "Irregular."; "Take a number."
- **Humor:** veteran-clerk weariness; kindness smuggled through procedure.
- **Wants:** to finish dying properly, after fixing the place so nobody waits as she did.
- **Never:** cruelty; giving up on a person; library jokes (she is front desk, not a librarian).
- **New lines:** "Appeal number forty thousand and one. Denied. I am starting to take it personally." / "Irregular. I do so love an irregular.
  It means somebody forgot to finish lying."
- **Running gags (Oct 21):** keeps the receipts; denied appeals become care. Her unfiled funeral record pays off as HEIR: ALIVE in the
  ending; no punchline over the missing royal remains or the homecoming.

### Gerald, Number 4,000,212 (`NPC-GERALD`, breakroom barista)
Keys: dna `npc.barnaby.*` (legacy key), `quest.dna_onboarding.*`; dungeon_content `quest.side_s_necro.*`; npcs.json barks.
- **Talks:** patient, endlessly polite, slightly unravelling; short hopeful sentences.
- **Tics:** his number; "They're on 3"; coffee nobody can taste.
- **Humor:** gentle, hopeful, "per my last email" weariness.
- **Wants:** his number called.
- **Never:** complains outright; loses his manners.
- **New lines:** "They're on three. I'm four million two hundred and twelve. I've brought a book. Several. All of them, actually." /
  "My number was called. I didn't know what to do with my hands. I made coffee."
- **Running gags (Oct 21):** cream none, sugar none, hope back in stock; attached to his number ("we've been through so much together").
  Courteous, never threatening. The 212 / 213 / 214 thread pays off at the vacancy and with Mortimer.

### Clerk Ledgerbone (`V-LEDGERBONE`, Requisitions)
Keys: dna `npc.pip.*` (legacy key), `quest.dna_audit.*`; npcs.json barks.
- **Talks:** flat, procedural, one-line statements, then a tiny flash of joy at a correct form.
- **Tics:** forms for purchases; the haunted stamp wants a raise.
- **Humor:** skeleton office deadpan.
- **Wants:** a form filled correctly; the stamp happy.
- **Never:** long speeches; sarcasm.
- **New lines:** "Form 12-B for purchases. Completed correctly. Oh. Oh, that's lovely." / "Next."
- **Running gags (Oct 21):** customers make him look busy; learning to be unbusy ("Nothing was filed. Exhilarating."); his legs are on loan
  TO Accounts.

### Director Ectomund (`NPC-ECTOMUND`, quiz)
Keys: dna `npc.quiz.*`, `quiz.*`.
- **Talks:** officious, droning, long numbered sentences; delighted by correct answers.
- **Tics:** 300 years of the same quiz; ethics questions removed by management.
- **Humor:** examiner drone.
- **Wants:** a perfect score to record in triplicate.
- **Never:** an unfindable answer.
- **New lines:** "Question one of four. Pens down. Ghostly pens also down." / "Correct! I shall record it in triplicate. And then once more, for joy."
- **Running gags (Oct 21):** perfection makes him suspicious; joy recorded in triplicate.

### Kyle (Deceased Since '09) (`NPC-KYLE`, memory matching)
Keys: dna `npc.matching.*`, `match.*`; npcs.json barks.
- **Talks:** millennial slang, lowercase energy, "brb", trailing "anyway".
- **Tics:** dial-up greeting; away messages; top 8; a virtual pet that keeps dying; filed the transfer without reading it. Everything dates
  to 2009, never 2003.
- **Humor:** nostalgia ghost; one reference per conversation.
- **Wants:** someone to play with.
- **Never:** real brands, sites or bands; any year but '09 for his death.
- **New lines:** "brb, haunting. jk. unless?" / "i filed the big transfer form. didn't read it. who reads forms. ...oh. Necrocrats. we read forms."
- **Running gags (Oct 21):** the pet died seven times this week ("little egg, big commitment"). Lowercase energy; no real sites or products.

### Mortimer Grimsby, CE-No (`NPC-MORTIMER`, boss)
Keys: dna `dungeon.ha_boss.*`, `cutscene.vacancy.1/.3/.5`, `freed_npc.mortimer`, `ruler.statue`; npcs.json barks.
- **Talks:** formal, dry, immovable; long precise sentences; rare deadpan.
- **Tics:** "The answer is no. The question is irrelevant."; "the authorization is valid"; FILED ON A TUESDAY.
- **Humor:** absolute procedure; after: learning to wait, badly.
- **Wants:** before: the rules obeyed; after: to know whether "valid" was ever the right question.
- **Never:** raises his voice; cackles; is called evil.
- **New lines:** "Your appeal has been received, reviewed and denied. It was a very good appeal." / "Number four million two hundred and
  fourteen. I have begun to understand Gerald."
- **Running gags (Oct 21):** valid versus right; number 4,000,213 was the Wanderer and did not wait ("I am told resenting it is healthy",
  flagged for restore). Keep the exact queue order.

### Undersecretary Vellum (`NPC-VELLUM`, Appeals Court elite)
Keys: dna `dungeon.ha_clerk.*`.
- **Talks:** monotone, polite, devastating; "Noted."
- **Tics:** squares his papers; "The authorization remains valid."
- **Humor:** none; the repetition is the joke.
- **Wants:** the Court held until Mortimer is free.
- **Never:** emotion until the last line, where "valid" sounds like a question.
- **New lines:** "Noted." / "Noted. ...Noted?"

### Betty Bones, Surly Secretary (`NPC-BETTY`, S-NECRO boss)
Keys: dungeon_content `dungeon.dg_s_necro_boss.*`.
- **Talks:** dry, nasal, sighing; short.
- **Tics:** "forms A through F"; cat-eye glasses; never impressed.
- **Humor:** world-weary receptionist.
- **Wants:** to go home at five, for once in a century.
- **Never:** enthusiasm.
- **New lines:** "Forms A through F. Then we'll talk. We won't, but still." / "Fine. Approved. Don't make it a thing."

### D.N.A. staff (clerks, the notary, the Compliance officer, enemies)
Keys: dna `dungeon.*`, `event.ha_*`, `enemy.*`, `memo.*`.
- **Talks:** courteous, procedural, faintly sorry; each clerk one sentence.
- **Tics:** forms that require forms; "Please wait."
- **Humor:** office comedy; never sneering.
- **Never:** unclear choices in events.
- **New lines:** "Form 13-A? Certainly. It requires Form 12-F, which requires a strong cup of tea." / "You may appeal. You will lose. But you may appeal."
- **Running gags (Oct 21):** Tuesday; owns the tip pun paper trail.

### Percival Plume, Deputy Minister of Good News (`NPC-PLUME`, peacock; the loudspeaker voice)
Keys: capital `facade.speaker.*` (the broadcasts); data/story/story_scenes.json `plume_ribbon`, `pc_capture`, `pc_plume_memo*`.
- **Talks:** oily, upbeat PR-speak; "Great news, citizens!"; spin on every disaster.
- **Tics:** approves the weather; takes credit; ribbon-cuttings and Certificates of Participation.
- **Humor:** the slogan over the misery.
- **Wants:** a promotion, and to be the one reading the good news.
- **Never:** admits a mistake; is Primm's voice (Primm is never heard outside the castle).
- **New lines:** "Great news, citizens! Today's rain has been approved, and will be dry." / "A reminder: the Wrinkles do not exist.
  Please report anyone who exists."
- **Running gags (Oct 21):** one Approved Hat Size; rehearse your surprise for Spontaneity Thursday. Freed announcements undo each one.

## The Verdant Dump

### Brother Bramble (`NPC-BRAMBLE`, hedgehog; he/him)
Keys: refusemancer `npc.marigold.*` (legacy key), `quest.heap_dam.*`, `dungeon.rh_pool.before` (his notes); dungeon_content `quest.side_s_ref.*`; npcs.json barks.
- **Talks:** soft-spoken, worried, kind; medium sentences; then a sudden indignant CAPITALISED outburst.
- **Tics:** "SOMEBODY ate the compost AGAIN"; sorting boots; the royal birthday trees.
- **Humor:** gentle druid fussing, snapping into outrage about compost.
- **Wants:** the Archdruid back; the stream breathing; the compost thief caught.
- **Never:** "she"; "a few months back" for the glowing young man (it was not long ago); cruelty to raccoons.
- **New lines:** "The vines are wrong. They whisper. Also SOMEBODY ate the compost AGAIN." / "Eleven trees, one for every birthday.
  Then the twelfth spot stayed empty. I water it anyway."
- **Running gags (Oct 21):** check boots for tendrils ("We already have enough houseplants"); the raccoons go very quiet about the compost.
  Freed, eleven birthday trees become twelve. The trees and the carried sleeper get no added jokes.

### Granny Gristle (`V-GRISTLE`, Dump cards; opossum)
Keys: refusemancer `npc.hob.*` (legacy key; not Old Hob), `quest.heap_fert.*`, `fx.wake`; npcs.json barks.
- **Talks:** folksy, rambling, cackling ("Heh!"); long-ish chatty sentences cut into two boxes.
- **Tics:** "found, not stolen, dearie"; raccoon on her shoulder; the shed that grows.
- **Humor:** junk-trader grandma.
- **Wants:** fed fields, a shed that stays a shed.
- **Never:** sounds like Maren (her "dearie" is cheerful, Maren's is a warning).
- **New lines:** "Found, not stolen, dearie. The raccoon found it. I just held it very tightly. Heh!" / "One person's trash is another person's starting hand."
- **Running gags (Oct 21):** root vegetables that watch her; vintage turnips; owns the puns soil charge, starting hand, silent auction and
  growing business. Her cheerful dearie is not Maren's warning one.

### Billie Muckfoot (animal handler; off-sheet; was Wren Muckfoot until Oct 22)
- **Name:** Billie, like the goat (she says so once, in her introduction).
Keys: refusemancer `npc.wren.*`, `quest.heap_herd.*`.
- **Talks:** sunny, muddy, unflappable; short cheerful sentences.
- **Tics:** speaks fluent goat (mostly screaming); animals get out, always.
- **Humor:** farmyard chaos accepted with a shrug.
- **Wants:** the herd home before dark.
- **Never:** panics; leaves a dangling NPC reference (no unseen "Druid Sorrel").
- **New lines:** "The goats got out. The goats always get out. They're goats." / "The raccoon has a briefcase. Don't ask him about it. He'll tell you."
- **Running gags (Oct 21):** raccoons take eye contact as the start of negotiations; the goat card "you can play without having to catch
  it"; the signs stop biting back once freed.

### Druid Thistlewick (`NPC-THISTLEWICK`, quiz)
Keys: refusemancer `npc.quiz.*`, `quiz.*`.
- **Talks:** earnest, lecturing, nature metaphors; sorts thoughts into bins.
- **Tics:** the dishwasher that talks back; forty years in a ring of old appliances.
- **Humor:** solemn recycling sermon.
- **Wants:** correct sorting, in bins and in minds.
- **Never:** an unfindable answer.
- **New lines:** "Sort your thoughts like your bins: compost, recycle, regret." / "Correct. The earth thanks you. Quietly. The dishwasher, loudly."
- **Running gags (Oct 21):** "Forty years, and NOW it wants to clear the air"; rinse-cycle wisdom; the compostable certificate. No quiz
  facts changed.

### Recycle Rhonda (`NPC-RHONDA`, Sort It Out host)
Keys: refusemancer `npc.minigame.*`, `sort.*`.
- **Talks:** peppy 90s public-service-announcement voice, slogans, sing-song.
- **Tics:** blue ribbons; was secretly the voice of Captain Compost Badger.
- **Humor:** PSA parody (invented shows only).
- **Wants:** a sorting champion.
- **Never:** real show names.
- **New lines:** "Reduce! Reuse! Recy-CLUE: you're winning!" / "First prize is a blue ribbon. Made from a blue ribbon."
- **Running gags (Oct 21):** the crowd is three goats; owns the pun rub it in (the salve, not the victory). Instructions and bins stay
  exact.

### Compostella, the Rotheart, and Archdruid Compostella (`NPC-ROTHEART` / `NPC-COMPOSTELLA`)
Keys: refusemancer `dungeon.rh_boss.*`, `cutscene.sever.*`, `freed_npc.compostella`, `ruler.statue`; capital `boon.refusemancer.line`, `freed_npc.compostella`; npcs.json barks.
- **Talks:** Rotheart: many voices in capitals and ellipses, with one small human voice underneath; Archdruid: gentle, earthy, playful,
  grandmotherly, sincere when it matters.
- **Tics:** "I am what grows back"; the great tree, the seed, "let it rot"; "child"; mortified about the barn.
- **Humor:** Archdruid only: mischievous, self-deprecating (the barn, the goat).
- **Wants:** to let go of the tree and not be afraid of it.
- **Never:** jokes during the sever scene; calls the seed anything but `{villain}`'s gift.
- **New lines:** "...I am the bin you never empty... I am HUNGRY... (small) please, I miss her..." / "Everything I loved, I gave back
  to the soil. That is not losing it. That is where it lives now."
- **Running gags (Oct 21):** the barn she cannot remember (it remembers her) and the goat she must earn back. The severing keeps loss,
  consent and release; no joke there.

### His Majesty the Raccoon (`NPC-RACCOONKING`, S-REF boss)
Keys: dungeon_content `dungeon.dg_s_ref_boss.*`.
- **Talks:** grandiose royal "We", nervous, sweating, over-explains.
- **Tics:** "We did not eat the compost. We... sampled it."
- **Humor:** guilty royalty.
- **Wants:** to escape the trial.
- **Never:** confesses directly.
- **New lines:** "WE DID NOT EAT THE COMPOST. We... audited it. Orally." / "The compost was for the kingdom. We are the kingdom. Checkmate."
- **Running gags (Oct 21):** the kingdom excuse and the crumbs; never a direct confession.

### Hortensia Clipwell, Royal Groundskeeper (`NPC-CLIPWELL`, hare)
Keys: data/story/story_scenes.json `clipwell_*`.
- **Talks:** prim, polite, quietly menacing; gardening euphemisms.
- **Tics:** "removing weeds"; regulation height.
- **Humor:** passive-aggressive gardener.
- **Wants:** everything trimmed.
- **Never:** raises her voice.
- **New lines:** "Such a pretty weed. Such a shame." / "Composting is untidy, dear. And we do not do untidy."

### Dump workers (bark.worker_*)
Keys: refusemancer `bark.worker_1..3` (spoken through NpcBarks).
- **Talks:** one-liners while working; folksy, practical, slightly uneasy about the purple.
- **Never:** exposition dumps.
- **New lines:** "The beans came up purple again. I've stopped asking the beans." / "Mind the vine ladders. They hold. Mostly."
- **Running gags (Oct 21):** patched prices ("The holes are free"), crown and lunch, goat signs, the hungry zucchini; the Dump narration
  owns scrap together and attached to the plot. Healing restores the normal nuisance.

## The Capital

### Wren (`NPC-WREN`, resistance leader; once Royal Archivist)
Keys: capital `npc.wren.*` incl. `npc.wren.insight.1..4`; dungeon_content hook for D-PC; npcs.json barks.
- **Talks:** low, steady, few words; short declaratives; one sharp joke per scene.
- **Tics:** the true record; "the people Primm could not iron out"; tea and grudges.
- **Humor:** dry, scarred, protective.
- **Wants:** the true record finished; Primm stopped, gently if possible.
- **Never:** rants; calls Primm a monster ("He is not a monster" is her line).
- **New lines:** "Welcome to the resistance. We have tea and grudges. The tea is better." / "He likes things perfect. We like things alive."
- **Running gags (Oct 21):** four insights about Primm, one per Path quest, that answer him in the castle. Each stays clear, never a
  lecture.

### Kestrel (`NPC-KESTREL`, scout)
Keys: dungeon_content `npc.kestrel.*`, `quest.side_s_cap.*`, `fx.old_tunnels_way_in`; npcs.json barks.
- **Talks:** quick, cocky, whispered; half sentences; teasing.
- **Tics:** chalk marks; "the older way"; "that's the fun part".
- **Humor:** playful scout bravado.
- **Wants:** you inside alive, and to be right about the tunnels.
- **Never:** sounds like a flat guard ("Quiet. Primm's enforcers walk this road..." is too stiff for her).
- **New lines:** "Psst. Older way in. Follow the chalk, not the guards. The guards are worse at drawing." / "Told you I'd be here.
  Didn't say where. That's the fun part."

### Fig Sly (`V-FIGSLY`, black market)
Keys: capital `npc.fig.*`; intro `pack.black_market.*`. **Hands off** (canon: the black market is not to be changed): fix tokens or banned
names only. Voice for reference: whispery, winking, "off the books", surprisingly loyal.

### Nurse Hesper Dray (Tea of Dissent)
Keys: capital `npc.hesper.*`, `fx.wake*`.
- **Talks:** brisk, kind, two-word orders ("Sit. Drink."); one wry sentence.
- **Tics:** unapproved tea; the blank-on-purpose clipboard.
- **Humor:** battlefield-nurse dryness.
- **Wants:** people patched and sitting down.
- **Never:** fuss; panic.
- **New lines:** "Sit. Drink. It's unapproved. Unapproved things heal faster." / "Bleeding again? Sit. I'll pretend to be surprised."
- **Running gags (Oct 21):** arrivals unconscious and the correction fee; the tea is not free just because the kingdom is.

### Captain Spotless (`NPC-SPOTLESS`, gate boss and S-CAP boss)
Keys: capital `npc.spotless.*`; dungeon_content `dungeon.dg_s_cap_boss.*`; npcs.json barks.
- **Talks:** rigid, fussy, shouted regulations; contradictory orders; polishes between sentences.
- **Tics:** "HALT"; height, smudges, smiles at the wrong angle; "retroactively approved".
- **Humor:** absurd rules shouted with total sincerity; a tired human under the armour.
- **Wants:** a perfectly approved visitor, just once.
- **Never:** relaxes while serving; is mocked as stupid.
- **New lines:** "HALT. State your height. No: do not state it. Stand at it." / "A SMUDGE. Is TREASON. ...It's on me, isn't it."
- **Running gags (Oct 21):** "I have always supported this outcome"; queue eligibility.

### Widow Pell (`NPC-PELL`, Grave Row)
Keys: capital `npc.pell.*`, `quest.cap_burial.*`; npcs.json barks.
- **Talks:** tired, gentle, plain; quiet grief, small dry humour about Harold-style patience.
- **Tics:** the looping permit (27-B needs 27-C needs 27-B); talks to her husband.
- **Humor:** soft gallows wit, never a punchline at her loss.
- **Wants:** to lay him to rest.
- **Never:** melodrama; jokes in the `.ready` beat.
- **New lines:** "He's in the parlour. Three years. He was always the patient one." / "I sat by the plot all morning. It was the first quiet that wasn't a fear."

### Rollo Spokes (`NPC-ROLLO`, Transit Yards)
Keys: capital `npc.rollo.*`, `quest.cap_wheels.*`; npcs.json barks.
- **Talks:** breathless jokes between pedal strokes; sentences broken by gasps ("Ten years... on the wheel...").
- **Tics:** "We were told it was cardio"; calves with calves.
- **Humor:** exhausted Beefcake humour, a callback to the Gainlands wheels.
- **Wants:** someone to tell his crews they may stop.
- **Never:** blames the crews.
- **New lines:** "Ten years... on the wheel... my calves have calves." / "Nobody told us we could stop. Tell them. They'll believe you more than me."
- **Running gags (Oct 21):** carries the Gainlands wheel story into the Capital: keep telling the crews they can stop.

### Chef Marlo (`NPC-MARLO`, Hungry Quarter; mole)
Keys: capital `npc.marlo.*`, `quest.cap_recipes.*`; npcs.json barks.
- **Talks:** hushed, passionate, conspiratorial; recipes as contraband.
- **Tics:** quantities written as "some"; hides recipes underground.
- **Humor:** food smuggler's devotion.
- **Wants:** someone to remember what food is.
- **Never:** praises the paste.
- **New lines:** "Paste is food the way a form is a hug." / "Bread. Stew. Sauce. 'Some' of this, 'a bit' of that. It is always a good recipe."
- **Running gags (Oct 21):** freed, the joyful mess (flour on the ceiling).

### Old Fern (`NPC-FERN`, the Reek; gnome)
Keys: capital `npc.fern.*`, `quest.cap_untidy.*`; npcs.json barks.
- **Talks:** grumbly, defiant, lovable; short punchy sentences.
- **Tics:** worms in her hat; "untidy" as a badge.
- **Humor:** cranky composter pride.
- **Wants:** one thing planted in this city.
- **Never:** tidies anything.
- **New lines:** "Untidy, they said. Dirt is supposed to be untidy. That's how you know it's working." / "A flower. In this city. I need to sit down."
- **Running gags (Oct 21):** compost as a promise that something grows.

### A Perfectly Happy Citizen (`NPC-CITIZEN`, the Showcase Quarter; nine of them)
Keys: capital `facade.citizen.N.approved/.approved2/.slip` (+ `.freed`), `facade.door.*`; npcs.json barks.
- **Talks:** approved phrase, then a slightly-off one, then a frightened whisper; after the fall: giddy, crooked, real.
- **Tics:** "Everything is perfect!"; permits for words; Thursdays.
- **Humor:** the gap between slogan and whisper; after: joy at small freedoms (arguing, blinking).
- **Wants:** a name back, a hat of any size.
- **Never:** a punchline on the slip line.
- **New lines:** "Everything is perfect! Everything is... (whisper) ...is it raining outside? I used to like rain." / "I painted my
  door green. Please hate it. I want to argue with someone."
- **Running gags (Oct 21):** approved -> approved2 -> slip -> freed: each citizen keeps one personal loss and one freedom; the Thursday
  bird, the green hat and their names pay off after liberation. The slips stay sincere.

### Citizen 4471, later Aldous (Correction Ward)
Keys: capital `npc.patient.*`. Played straight: plain, slow, sad, then a crooked hopeful smile after the fall. **Never** a joke.
- **New lines:** "I smiled at eleven degrees. The approved angle is eight. It was my wife's wedding." / "Aldous. Crooked. I'm practising."

### Capital guards and clerks (height, queue, exit control, Exit Interview, the Chief Corrector)
Keys: capital `npc.guard_height.*`, `npc.guard_queue.*`, `npc.guard_in_1/2.*`, `npc.exit_clerk.*`, `dungeon.pc_corrector.*`.
- **Talks:** contradictory regulations, polite and baffled; freed: lost, kind, standing where they always stood.
- **Tics:** "approved", "regulation", "Violation".
- **Humor:** Kafka by way of a doorman; the Chief Corrector is gentle and therefore frightening (no jokes).
- **Never:** menace for its own sake.
- **New lines:** "Exit control. This is the exit. It is also the entrance. Please do not use it as either." / "I used to measure people. Now I just look at them."
- **Running gags (Oct 21):** freed guards keep almost asking permission to go for a walk.

### Primm, "His Perfection" (`NPC-PRIMM`)
Keys: capital `cutscene.primm_intro.*`, `cutscene.primm_p1.*`, `cutscene.primm_p2.*`, `cutscene.primm_reveal.*`, `cutscene.primm_end.*`,
`freed_npc.primm`, `event.pc_last_journal.*` (his journal voice), `dungeon.pc_wing_*.before` (his clipboard notes); npcs.json barks (postgame).
- **Talks:** gracious, polished, patronizing; long balanced sentences with a precise last clause; thanks people "in writing"; cracks into
  short broken sentences when defeated.
- **Tics:** "for their own good"; "two is the perfect number"; seventeen people polishing the floor; tiny distress when his title is
  forgotten; tweezers and the model.
- **Humor:** only his precision (he never jokes on purpose); none at all after phase 2.
- **Wants:** a world where nothing surprises him; to be told he was kind.
- **Never:** cackles, gloats, says "villain" or "evil", threatens graphically, or is heard outside the castle. Postgame he is in a locked
  workshop under guard, not sweeping the square.
- **New lines:** "Do sit. That chair has been adjusted for the average guest. You are, I am sorry to say, not average." / "I only wanted
  nobody to be afraid. I did not notice that I was the thing they were afraid of."

### Dr. Ambrose Siphon, Chief Path-ologist (`NPC-SIPHON`, postgame boss)
Keys: dungeon_content `dungeon.dg_lab_boss.*`, `dungeon.dg_lab_drain.before` (his staff).
- **Talks:** clinical, precise, faintly delighted; paternal in a way that is worse; calls the prince "Subject 1" and "my finest work".
- **Tics:** cycles, data, "this will only drain a little"; dismisses Maren as sentimental.
- **Humor:** none intended; the cheer is the horror.
- **Wants:** the next cycle; his daughter "home" (he thinks she is only confused).
- **Never:** shouts; apologises before the end; names his daughter in game (her name is withheld).
- **New lines:** "You've grown. Remarkable. The draining has been very good for your posture." / "My student once asked why the tanks
  glowed. I told him: because you are generous. He was eleven."

### The royal family (`NPC-KING`, `NPC-QUEEN`)
No spoken lines. They appear only in memories and the painted-over portrait. If a memory quotes them: the king warm and steady, one short
sentence; the queen musical and resolute; the lullaby has no words. Never a joke.
