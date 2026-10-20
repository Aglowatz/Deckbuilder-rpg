# Story Bible (The Wayward Path)

**This is the one story reference.** Rebuilt Oct 19 2026 from every story source in the repo. Older story docs are kept only as archive
(`story_source.md`, `story_source_v2.md`, the story parts of `zones.md`, `secrets.md` and `starting_deck_and_affinity.md`); where they
disagree with this file, this file wins. Quick-reference of locked names and rules: `docs/design/canon.md`. How characters sound:
`docs/design/voice_bible.md`.

**Authority order** used to settle every conflict (see "Contradictions resolved" at the end):
1. The user's locked decisions (answers in `open_questions.md`, `[Resolved ...]` inbox lines, the user's briefs).
2. The design sheet canon (`data/source/npc_list.csv`, `data/source/dungeon_list.csv`: exports of the designer's Google Sheet).
3. Game data (`data/story/*.tres`, `data/dungeons/*.json`, `data/npcs/npcs.json`, `core/`).
4. Old docs.

Where the game currently says something different from canon, the section says so under **In game now**. Nothing in the game was
changed to match this file; changes that need the user are listed in `docs/overnight_inbox.md`.

**Status tags** used below: **[built]** in the game today; **[canon, not built]** sheet canon with no game content yet;
**[open]** undecided.

## Contents

1. Premise and tone
2. Names in text: the token table
3. The kingdom of Patchwork and its history
4. The Wellspring and the Old Well
5. The Wanderer: the lost prince's arc
6. Primm and his lieutenants
7. The forest, the Forgotten Cave and the prologue
8. Crosspath, the hub town
9. The Gainlands (Beefcakes)
10. The Endless Buffet (Gourmands)
11. The D.N.A. (Necrocrats)
12. The Verdant Dump (Refusemancers)
13. Zone buffs and debuffs
14. The Capital: Primm's Perfection (Pathordia)
15. Primm's Castle and the final fight
16. The ending
17. Side dungeons and secrets
18. Postgame: the Path-ology Lab, Siphon and Elowen
19. The cast: every named NPC
20. Main quest beat list
21. Running jokes and callbacks
22. Open questions
23. Contradictions resolved (Oct 19)

---

## 1. Premise and tone

A stolen prince with no memory reclaims a kingdom whose strength was always its differences. Ten years ago Primm, the Royal Minister of
Improvements, killed the king and queen and seized the Pathwork Throne. He kept their son alive to drain the bloodline's power. Now the
prince has escaped. Every zone he frees loosens Primm's grip, returns a piece of his memory and teaches him something he will need to rule.

**Theme.** One way for everyone breaks a kingdom; many ways, held together, make it whole. Primm demands sameness. The royal bloodline's
gift is wielding all four Paths at once, as they are. The deck-building progression IS the story: one Path, then two, then all of them.

**Tone.** Comedic on the surface, serious underneath. Every joke has a cost the player can see, and the jokes get quieter the closer the
player gets to Primm. Puns and dad jokes are welcome; sincere beats stay sincere (the prince's captivity, grief for the king and queen, the
four leader reveals, the memory fragments, Isla coming home, Primm's fall): no punchline on top of them.

**Hard presentation rules** (locked): no readable text in the 3D world (signs are pictures; words live in the "E to read" text); enemy
intent is never shown; Primm is only seen or heard in person inside his castle (and in the postgame); no chapters.

## 2. Names in text: the token table

Names that may still change live in ONE data location each and appear in story text as tokens, filled in by `Villain.fill` /
`RoyalFamily.fill` whenever text is read. Write tokens, never the literal names, in story files.

| Token | Value today | Lives in | Notes |
|---|---|---|---|
| `{villain}` | Primm | `data/story/villain.tres` | |
| `{villain_title}` | His Perfection | `data/story/villain.tres` | He insists on it. |
| `{prince}` | Tessar | `data/story/royal_family.tres` | Only after the reveal; before it use `{wanderer}`. |
| `{prince_full}` | Prince Tessar Wayweaver | royal_family.tres | |
| `{royal_house}` | Wayweaver | royal_family.tres | |
| `{king}` | King Harmon Wayweaver | royal_family.tres | |
| `{queen}` | Queen Concordia Wayweaver | royal_family.tres | |
| `{rescuer}` | The Rescuer | royal_family.tres | Placeholder; sheet canon names her **Elowen Vey** (section 18, inbox). |
| `{kingdom}` | Patchwork | royal_family.tres | |
| `{town}` | Crosspath | royal_family.tres | |
| `{capital}` | Primm's Perfection, then Pathordia | royal_family.tres | Switches when Primm falls (`RoyalFamily.set_capital_liberated`). |
| `{pathordia}` | Pathordia | royal_family.tres | Always the liberated name. |
| `{showcase}` | the Showcase Quarter | royal_family.tres | The facade district. |
| `{wanderer}` | "Wanderer", then the prince's name | `core/data/royal_family.gd` | Flag `prince_revealed`. The dialogue plate reads "The Wanderer" until then. |

## 3. The kingdom of Patchwork and its history

### The Old Kingdom and the four Paths

**Patchwork** ran on four **Paths**, each a people, a magic and a vital service. They argued constantly and needed each other anyway.

| Path (faction) | Vital service | Home zone | Resource | Colour | Rival (why) |
|---|---|---|---|---|---|
| **Beefcakes** | Energy and transport: mills, giant hamster wheels, throwing people, ripping open portals | The Gainlands | Iron | red | Necrocrats: chaos vs. by-the-book ("there-ish, on-time-ish") |
| **Gourmands** | Food and protection: feeding the kingdom, food golems to guard it ("Yes, Chef!") | The Endless Buffet | Ingredient | blue | Refusemancers: snooty vs. "garbage eaters" |
| **Necrocrats** | Death administration: the dead, the afterlife and its labour (Afterlife Services and Labor), all properly filed | The Department of Necrotic Affairs (the D.N.A.) | Red Tape | purple | Beefcakes |
| **Refusemancers** | Waste removal and agriculture: animals that eat the garbage, fertilizer, magic that grows crops | The Verdant Dump | Garbage | green | Gourmands |

**How they worked together.** The Beefcakes ran the lights and the roads, the Gourmands the kitchens and the guards, the Necrocrats the
graveyards and the records, the Refusemancers the bins and the fields. The proof is still under the Capital: the Old Service Tunnels, a
Beefcake-dug bore with Gourmand ventilation, Necrocrat signage and Refusemancer drainage. The old arena (now the Undercroft) is where the
four Paths "settled their rivalries for a thousand years". Auntie Alembic believes the kingdom was healthiest when everything was mixed.

**Crosspath** is the town where the four Paths met, traded and argued. **The Capital** is where their power meets.

**The Pathwork Throne** sits in the old heart of the Capital, below the castle: four seats grown into one, four colours woven as a single
thread. Whoever sits on it is connected to all four Paths, and the ruler's character flows out through them into the land. It answers to
one bloodline.

**The royal bloodline** can wield all four Paths at once; that is why the throne worked under them. They carried the Paths as they were,
without forcing them into one shape. **House Wayweaver** weaves the four Paths together without forcing them into one.

- **King Harmon Wayweaver**: gentle and patient; held the Paths together by letting each be itself. Came to the Gainlands' Lifting Festival
  every summer with his son.
- **Queen Concordia Wayweaver**: clever, musical and fierce. Hers is the wordless lullaby the prince remembers first. She died shielding him.
- **Prince Tessar Wayweaver**: their son, named for the tesserae of a mosaic: many different pieces making one picture.

**The royal crest** is the four Path symbols in a ring. It appears without explanation as a quiet clue: Elder Maren's walking stick, the
fountain in Crosspath's square (four Path plinths in a ring), the Forgotten Vault's Old Kingdom banner, the Vault Guardian's four-coloured
core, the Wayweaver crest "on every door" in memory 4.

**The Path-ologists** are the kingdom's scientists of the Paths. **Elder Maren** founded the field and led it before the coup, "for the best
of reasons". Her protege **Ambrose Siphon** was also the prince's **Royal Pathguide**, who taught the boy to walk the Paths.

### The coup (ten years ago)

Primm, Royal Minister of Improvements, believed the kingdom would be better under his rule and saw it as his official duty to improve it by
any means, including removing the royal family. One night in the throne room he knelt to the king, then stood. Siphon stepped aside and let
Primm's guards through. Primm killed King Harmon and Queen Concordia and took the Pathwork Throne; the boy (eleven) was pushed behind his
parents toward the dark and taken. Primm spared him because he wanted the power in the royal bloodline for himself.

The Necrocrats filed the royal funeral forms (Agnes stamped the king's and the queen's herself); the third form, for the prince, was never
filed: no body, no certificate. Maren fled into hiding in Crosspath. Siphon took over her research and her lab.

### The corruption

Sitting on the throne connected Primm to all four Paths, and his darker traits poured through them. Each faction's corruption is one of his
flaws turned into policy, engineered by one of his lieutenants and fronted by a ruler:

| Path | What happened | Primm's flaw | Mastermind (lieutenant) | The ruler (boss) | The true leader |
|---|---|---|---|---|---|
| Beefcakes | A coup; the leader imprisoned without weights; a regime of endless wheels | Strength means control | Vivienne Quota | Chancellor Clench, Iron Regent | Grandmaster Flex, the Unbroken |
| Gourmands | A doppelganger replaced the leader; corrupted food (the Special Sauce); kitchens turned into a weapons factory | Appearance over substance | Colonel Cornelius Crumb | The Doppelganger | The Grand Chef |
| Necrocrats | Authority transferred by perfectly valid paperwork | Legal means right | Percival Plume | Mortimer Grimsby, CE-No | Agnes Overdue (after the zone) |
| Refusemancers | The leader corrupted through nature itself: a deathless seed; growth that never stops | Fear of anything he cannot control | Hortensia Clipwell | Compostella, the Rotheart | Archdruid Compostella |

**The stolen power.** Primm has no royal blood. His hold on the throne depends on power drained from the prince in the Path-ology Lab
for ten years. When the prince escaped, the hold started to slip: that is why the zones can be freed now, why rifts tear open in the
Capital, and why his "Reflection" phase can only copy. His power was never his.

**Death froze too** [canon, not built]. When Primm's paperwork seized the D.N.A., the afterlife's intake froze and Death could not collect
anyone. Death (Old Hob) took a job digging graves in Crosspath and waited. That is why Agnes cannot pass on and Gerald's queue never moves.

### Ten years later (the game's present)

Each Path lives under its ruler. Crosspath is quiet and watched; its four roads are blocked by corrupted gatekeepers. The Capital is a
perfect facade over a broken city. The Wanderer wakes in the forest outside Crosspath.

## 4. The Wellspring and the Old Well

### What is canon so far

- **The Wellspring** is the spring that once fed all four Paths (user brief, Oct 19). It is singular. The old placeholder lore of "four
  Wellsprings, one per element" (`starting_deck_and_affinity.md`, an early working title) is retired.
- "Wellspring" is a lore word only (BL-3): no place in the game is labelled "the Wellspring". The town's well is **the Old Well**.
- **The Old Well** stands in its own yard off the west market street, by the Champions' Road block, in Crosspath [built]. It glows pale cyan with rising motes. Touching it
  ("Touch the Old Well") answers in the colour of the Path the Wanderer carries: "The <Path> spring hums. It knows you." (In early builds
  this was where the starting Path was chosen.) Townsfolk joke about it ("Did you hear the well talks now? It doesn't. But imagine.").
- **Beneath the Old Well** is the Forgotten Vault (S-TOWN): an iron hatch beside the well, "a door under the old well that has been locked
  since before [Maren] was born". The vault is Old Kingdom work "from the days when the four Paths marched as one" (section 17).
- **The Forgotten Cave ends at a dried-up ancient wellspring** (sheet, D-TUT theme). Its third node is the Hollow Well, a deck challenge:
  "Five cards fall into the well. Will it answer?" The cave is a royal escape tunnel that only the bloodline may pass.
- **The Rotheart's ninth node is the Last Clean Spring** (full heal), the one place in the Dump the corruption has not reached.
- **Primm and the wells.** Clean wells were among his genuinely good early reforms. In the postgame he designs water mains under guard:
  "I find that I miss the wells."

**Made canon by the Old Well secret quest (Oct 19-20, Part 6; below)** [built]:
- **Where it is.** The Wellspring rises deep under the kingdom, nearest the surface under Crosspath: the Paths met there because the water
  did ("Where it rose, they built a town to argue in"). The Old Well is the Old Kingdom's well over it.
- **Four streams, one spring.** Its water fed all four Paths, each as its own stream (red, blue, purple, green in the vision). Two are shown:
  the green one fed the Refusemancers' fields (it still comes up, clear, at the head of the Verdant Dump's river on the highest terrace); the
  blue one went into the Gourmands' first stockpot (an old stone basin, now under the little gravy pond in the Buffet's Broccoli Forest;
  every Gourmand recipe still begins "first, water"). The four peoples gave it four names and argued about the name for a thousand years.
- **The vault under the well was built to guard its source.** Over the source the Old Kingdom built the Forgotten Vault, and the four Paths
  locked it together "so no one Path could ever own the water". (Fits section 17: Old Kingdom work from the days the Paths marched as one;
  its four-coloured core sits over the source. The vault's dungeon, quest and Automaton are unchanged.)
- **Why it dried.** It ran while the four Paths shared it and while one house held the four together. Ten years ago "the house went quiet"
  (the coup), the streams stopped speaking and the spring went down to wait. The Forgotten Cave's Hollow Well, the little spring at the end
  of the royal tunnel, went to dust then; the Old Well almost did.
- **It does not come when it is told.** Good new wells were dug all over the kingdom, clean and straight (Primm's early reform, unnamed in
  the text); the water did not come. "It does not run for one shape. It runs for many, held together."
- **The bloodline hint** (no more than canon): it has waited ten years "for a hand that can hold all four", and it hums when the Wanderer
  touches it. Nothing names the prince or says the house is his; the line reads the same before and after memory 4.

Still not canon: how the Wellspring relates to the Pathwork Throne's four-coloured stair, whether it can run again, and the purple (Necrocrat)
and red (Beefcake) streams' places.

### The Old Well secret quest [built]

**The Water Under the Well** (`secret_old_well`, SIDE, hidden; code `core/dungeon/old_well_quest.gd`, text `data/story/old_well_story.json`,
world `world/old_well/old_well_spot.gd` + `TownScene._use_well`). No giver and no marker: the Old Well itself starts it.

1. **The vision** (first touch of the Old Well once a Path zone is free): the stone goes warm, water moves far below; the well whispers
   "Four streams. One spring. They drank together, once." and "Listen for what is left"; two hums answer, one high in the Verdant Dump where its
   river starts to fall, one in the Endless Buffet by a little pond under the broccoli. The Wanderer: "The townsfolk say the well doesn't talk.
   I'm not going to be the one who tells them." (callback to the townsfolk bark). Until a zone is free the well keeps its old greeting.
2. **The Dump's hum** (any order): at the head of the falls on the Overgrown Plateau, a thread of clear water under roots and junk ("The
   cleanest water in the Dump starts in its dirtiest corner"; a boot in it, "the water has gone politely round the boot"); the green stream.
3. **The Buffet's hum**: the first stockpot under the gravy pond in the Broccoli Forest ("first, water"; "Somebody has added 'and salt'.
   Twice."); the blue stream. Each find ends with a whisper, "One stream remembers."
4. **The Echo**: with both found the well fills with light of all four colours. **The Wellspring's Echo** ("what is left when the water goes.
   Every Path's voice, in one throat"; "Hold all four, and I will run again. Hold fewer, and I will show you what the others were for.") is a
   four-Path deck (every Path's Infrastructure, Village Wells, the Harmony Engine, Reunion of the Paths) with the one-sided rule **The Spring
   Remembers** (heals 2 HP at the start of each of its turns; starts with an Iron, a Red Tape, an Ingredient and a Garbage). Node-based duel on
   the town battleboard; a loss: "Not yet. The spring is patient. It has had ten years of practice."
5. **The reveal** (first win): the well becomes a mirror showing the spring under everything; the facts above; "It hums when you touch it.
   Take a little with you. It remembers the way home." The Wanderer: "A well with opinions. Fine. I'm keeping the bottle."
6. **Reward**: the **Phial of First Water** (relic, never sold: multi-Path cards cost 1 less generic energy, gain 1 HP each turn; "A thimble
   of the water that fed all four Paths. It does not slosh. It waits."), 250 gold, 300 XP. Intended level about 16.

Voices: the Old Well (new, narration-adjacent): slow, plural, "..." pauses, water images, no jokes; the Echo: the same, colder. The humour stays
in the narration's small turns and the Wanderer's two lines.

## 5. The Wanderer: the lost prince's arc

**Who he is.** Prince Tessar Wayweaver (`NPC-PLAYER`), eleven at the coup, twenty-one now, presumed dead. Ten years in the Path-ology Lab
("the Subject") plus the corruption flowing from the throne left him weak and amnesiac. He was smuggled out through the royal tunnel by his
childhood friend Elowen (the Rescuer). Curious, resilient, quietly funny; short, wry inner monologue, earnest when it counts. He does not
know his name, only that what he is doing is right. In game he is "the Wanderer" until the reveal.

**Power returns as the land heals** (built: `DeckValidator.base_max_colors`, `PlayerProfile.zones_freed`):

| Point in the story | Paths he can wield | Why |
|---|---|---|
| Start | One (the starting deck he chooses in the prologue) | Weakened; the corruption smothers his gift |
| After the first freed zone | Two | The corruption over the land wanes (Maren's memory 1 announces it) |
| After defeating Primm | All (3+ Path decks, `postgame_unlocked`) | The throne answers to the true bloodline |

**Memory returns zone by zone** (built: `MemoryDefs`, flags `memory_1..4`, quest `fragments`). Fragment N follows the NUMBER of zones freed,
not which zone, and plays the next time he talks to Elder Maren. Maren's default lines change by stage (0 guarded, 1 warmer, 2 resistance, 3
her past, 4 the prince).

1. **Warmth.** Four-coloured light, a woman humming, a hand on his head (lavender and woodsmoke). Maren: a lullaby from the old court.
   The second Path opens.
2. **The Cells.** White rooms, glass, coats, "the Subject", "again". "I wasn't lost. I was kept." Maren admits she is the resistance's
   contact in Crosspath (Wren leads it from the Capital).
3. **The Coup.** A throne room at night, banners of four colours woven as one; a man in white and gold kneels to the king, then stands; two
   people push a boy behind them. He knows the face: Primm. Maren admits she founded the study of the Paths and helped build that lab ("I
   helped to blow that glass"), then ran.
4. **A Name.** A boy of eleven in a courtyard; someone calls "Tessar!"; the Wayweaver crest. He is the prince. Maren remembers the boy at
   court who asked why tortoises carry their houses ("So we are never far from home"). Sheet canon adds: she admits she knew all along
   (the Warden let him through, which only royal blood can do) and now helps with everything she has. If Primm told him first, the scene
   uses its `intro_known` / `after_known` variant.
5. **On the Pathwork Throne: everything.** Full memory and full power (ending beat 8).

**What each zone teaches him** (order does not matter; each mirrors his own wound):

| Zone | Lesson | Why it hits him |
|---|---|---|
| Gainlands | Strength comes from the heart and mind | Flex was imprisoned and stripped too, and came out stronger |
| Endless Buffet | What you are called does not matter; what you do does | He does not know his name, only that what he does is right |
| D.N.A. | Everyone deserves humanity, even the dead; no order outranks respect | For ten years he was a subject in a file |
| Verdant Dump | Death is not the end; to grow, you have to let things go | He carries a grief he cannot name yet: his parents |

His answer to Primm uses all four, one per phase (section 15).

**The reveal.** Either Maren's fourth fragment, or Primm in the castle if fewer than four zones are freed ("I kept your face"). Both set
`prince_revealed`: the name plate, `{wanderer}`, Maren's lines and the lost-property posters change.

**Relationships.** Elowen (childhood friend; she has loved him since they were children; he does not remember her). Maren (guardian,
grumpy, guilty). Siphon (his old teacher and jailer: "my finest work"). Primm (the man who kept his face). Brannoch (the gate that waits for
people to come home). The four leaders (each lends him a boon at the end).

## 6. Primm and his lieutenants

### Primm, "His Perfection" (`NPC-PRIMM`)

**What he believes.** If everyone just did things his way, the world would be perfect. A difference is a defect, an inefficiency, a smudge.
Every decree begins "for their own good". He is tragic, not cackling: sincere, brilliant, arrogant and selfish, and deeply narcissistic and
controlling. His "perfect" world is the world as HE finds comfortable: mirrors that reflect only him, portraits that "improve" him, a
facade district that exists to be admired. He gets visibly, very slightly upset when his title is forgotten.

**Why he is tragic.** His early reforms really helped (clean wells, standard measures, school lunches) and some of his complaints about
the old kingdom were valid. He cannot see that every improvement made the kingdom more like him. The Archive of Good Intentions holds his
early journals, sincere and helpful, sliding entry by entry into control.

**Voice.** Gracious, polished, patronizing ("Mind the floor: it has just been polished, by seventeen people, whom I thank daily, in
writing."); cracks into rage and grief when defeated ("I only wanted it to be nice!"). Played straight at the end.

**Where he is.** Only in person in the castle (locked). Elsewhere he is portraits, statues, decrees and posters; the loudspeaker voice is
Percival Plume. The Model Room: a table-sized model of Patchwork, every tiny house exactly where he wants it; he moves a cottage one
centimetre with tweezers. Pressed grey coat, thin gold circlet (white and gold in the prince's memory of the coup).

**Fate.** The prince does not kill him: Primm made one choice for everyone, and the prince makes a different one. Primm serves the kingdom
on infrastructure (water mains, drains, wells) under permanent arrest in a locked workshop, kept away from all Path workings. Brilliant,
sincere and never again in charge. [built: postgame Primm stands in the Crease with a guard; the workshop building is a polish item.]

### The four lieutenants [canon, not built]

Masterminds who engineered each takeover and control it for Primm. Semi-present in their zone (cameos), they flee to the Capital when
their zone is freed, and each is beaten in a one-off fight there. None exists in the game yet.

| Lieutenant | Path | What they did | In their zone | In the Capital | Fate |
|---|---|---|---|---|---|
| **Vivienne Quota, Minister of Efficiency** (`NPC-QUOTA`) | Beefcake | Designed the endless energy wheels and the Iron-less Prison ("remove the inefficiencies: weights, protein, joy"); picked Clench as figurehead because his insecurity made him easy to steer; corrupted Brick Bronson | Efficiency notices on every wheel; stopwatch; "measures" the Wanderer at the House of Gains' Regime Checkpoint and finds him wanting | One-off battle in the Transit Yards at the end of Rollo Spokes's quest | Runs the Gainlands' new break schedule, and hates it |
| **Colonel Cornelius Crumb, Director of Culinary Defense** (`NPC-CRUMB`) | Gourmand | Ordered the doppelganger swap and the war-machine programme; invented Primm's Perfect Nutrient Paste; corrupted Chef Fennel Gravois | His seal on every "for the war effort" poster; inspects the Test Kitchen prototypes; Basil is terrified of him | Boss of the Paste Works mini-dungeon (S-PASTE) through Chef Marlo's quest | Learns to actually cook under the Grand Chef |
| **Percival Plume, Deputy Minister of Good News** (`NPC-PLUME`) | Necrocrat | Drafted, notarized and filed the transfer of authority; reads every broadcast; corrupted Prudence Pallor; the NPC everyone loves to hate | Spins every freed zone, then turns up to cut a ribbon and hand the Wanderer a Certificate of Participation | Works out who smuggled "the Subject" out and has Elowen taken back to the Lab when the Wanderer first enters the castle (memo: "Re: the leak in the lab. Handled. Promotion?"); elite in the castle's Necrocrat wing | Tries to become the prince's spokesman; Agnes denies the form; reassigned as Assistant to the Assistant to the Regional Merchant, under Bertram Beetsworth |
| **Hortensia Clipwell, Royal Groundskeeper** (`NPC-CLIPWELL`) | Refusemancer | Outlawed composting as "untidy"; brought the grieving Compostella the Path-ologists' deathless seed (Primm's gift); corrupted Moss Mulligan | Nails tidy decrees to rotting trees; trims overgrowth into topiaries of Primm; tense, polite standoffs with Brother Bramble | Keeps the Showcase Quarter's lawns at regulation height; one-off battle on the regulation lawn at the end of Old Fern's quest | Compost duty under Granny Gristle |

Voices: Quota crisp, everything in percentages and seconds; Crumb barked military orders in food metaphors ("Whisk formation!"); Plume
oily, upbeat PR-speak ("Great news, citizens! The weather has been approved!"); Clipwell prim, polite, quietly menacing ("removing weeds").

## 7. The forest, the Forgotten Cave and the prologue

**The forest outside Crosspath** (area `start`, "The Forest Clearing"; walkable). A small teal-dusk clearing walled by treeline, a lantern,
glowing mushrooms, the cave mouth in the rock. The Path-ology Lab's hidden entrance is in this same forest (sealed until the postgame), which
is why he woke here. Three hidden chests (gold) and a secret gap in the treeline (a shortcut that skips the tutorial; it reuses the Path
already chosen).

**Prologue beats** [built]:
1. **Waking** (story still `still.wake`): leaves in his hair, no name in his head, a faint four-coloured glow fading from his hand.
2. **The Rescuer** kneels beside him, hooded (Elowen; NOT Elder Maren). "Easy. Stay down." "We are not the only ones in these woods
   tonight." He asks "...Who are you?" - "A friend. That's all I can give you." "Can you still fight? Still draw on the Paths?" He feels
   all four, faintly, "like voices through a wall". Torches on the ridge: the pursuers are close (Oct 20 rewrite).
3. **The Path choice** ("Choose your Path"): "Which Path resonates the strongest within you?" The starting deck is chosen here.
4. **Sent on.** The cave behind her runs through to Crosspath, and "someone there will be waiting for you". The pursuers are close; she
   draws them off the other way ("They know my face; let them chase it"), so he goes on alone. She slips away toward the torches; he never
   asked her name. (No line says he can carry only one Path: the choice is simply his strongest.) Wandering toward the treeline gets a self-talk line and a nudge back.
5. **The Forgotten Cave** (D-TUT, 6 nodes; renamed from the Trial of the Hollow; a passage, not a trial): Cave Mouth, Scavenger's Den,
   the Hollow Well (deck challenge), Mossy Gallery, Whispering Shrine (full heal), Heart of the Hollow (boss). A card pick from his Path after
   each battle. No Beefcake or Necrocrat infrastructure or Resources appear in it (enemy decks only; his own Path may be either).
6. **The Hollow Warden** (`NPC-WARDEN`), an Old Kingdom moss-and-stone guardian of the royal escape tunnel; only the bloodline may pass.
   Before: "You smell familiar. Like old stone and cold nights in a house I used to keep." After: "The old walls do not lie... Someone is
   waiting there with a kettle on." (Lands differently after memory 4.)
7. **Elder Maren.** Canon (sheet): she is waiting at the far end; word reached her that someone would be smuggled out through the old
   tunnel, but not who. She is slow to trust ("You could be anyone's spy"), kind, cryptic, full of pie. **In game now:** the welcome plays
   at her door in Crosspath ("You have walked yourself right into {town}, and right up to my door"), then her first greeting explains the
   four Paths, Primm and the gatekeepers.

## 8. Crosspath, the hub town

Zone id `town`, walkable. The town where the four Paths used to meet; quiet and watched under Primm, louder with each freed zone.
Arriving in Crosspath is a full heal.

**Layout** [built]: a big round square with the royal-crest fountain (four Path plinths in a ring) and six shops round it (north: Tilly
Tonic, Foil Fenwick; west: Sable, Bertram Beetsworth; east: Pip Threadwell, Auntie Alembic); the notice board (quest log); the Deck
Station; a dim alley off the square's north-east corner (the Secret Dealer, once the original giant chest is opened); Elder Maren's lane and
home; Champions' Road south (the chapel, the Old Well in its yard with the iron hatch, the Sealed Vault, and at the road's end the abandoned
cottage over the Undercroft); the graveyard and the Restless Cairn; lakes and docks; the Four-Seal Vault in the north hills near the Capital
road. Townsfolk stroll the lanes; Brindle the Baker strolls the square.

**The five roads out** (the hub is one country; each road ends at an obstacle):

| Road | Obstacle | Gatekeeper (corrupted, then freed) | Unlock flag |
|---|---|---|---|
| The sunny meadow road to the Gainlands | the gorge bridge, drawn up | Brick Bronson, at the crank | `beefcake` gate |
| The cracked road to the D.N.A. | the permit barrier ("Permits are not issued") | Prudence Pallor, Checkpoint Supervisor | `necrocrat` gate |
| The orchard lane to the Endless Buffet | the great pantry door, locked | Chef Fennel Gravois, Keeper of the Pantry Key | `gourmand` gate |
| The winding forest path to the Verdant Dump | a breathing wall of thorns | Moss Mulligan, the Corrupted Druid | `refusemancer` gate |
| The imperial road to the Capital | a stone arch; open from the start | (Brannoch warns you) | none |

Each gatekeeper must be beaten once (on its own zone's battleboard); freed, they stay in town with new lines and open the way. Gatekeeper
Brannoch, at the Capital road, explains the four broken services and gives Free the Four Zones; his gate has no lock because he is waiting
for his daughter Isla.

**Unlocks as zones are freed** [built]: 1 zone: the Undercroft (the Arena) opens and the second Path; 2 zones: Auntie Alembic's (the
Alchemist) opens; Sable's back crates open at level 10 or two zones. Maren's progress lines and the town crier announce each.

**The Undercroft** (the Arena; the user's Oct 16 hub brief): the colosseum is gone. An abandoned cottage at the end of Champions' Road
"has started cheering at night. From the cellar." Announcer Grand Bellows runs the ring underground: "Four Paths settled their rivalries in
the old arena for a thousand years, until {villain} chained the doors. So we dug." Eight encounters in three tiers (Bronze, Silver and Gold
Sand): battles and puzzles, arena-exclusive gear (never sold), gold, essence. The top fight is "The Marshal": Bellows himself.

**Auntie Alembic's** (the Alchemist): copies over the cap turn into Path essence; trade the essence of two Paths plus gold for a random
dual-Path card. Tri-Path crafting is a hook after Primm falls (no tri-Path cards yet). Her locked-door note: "THE USURPER CONFISCATED MY
CAULDRON. I AM STILL BREWING IN THE SINK."

**Tilly's store room** (Oct 20): the north-west corner house beside Tilly Tonic's Supplies. Three ghosts bought one lantern between them
ninety years ago; it never worked; Tilly's great-grandmother said "no receipt, no refund", so they waited, died, and kept waiting,
professionally. Maren's third errand: the duel at the door (they settle it with cards, like everyone here); beaten, they move to the chapel
belfry ("a lovely draught") and leave the lantern on the top shelf. It still doesn't work.

**Other town stories**: Shiro Swindle's giant chests (section 17); the Sealed Vault and the Four-Seal Vault (section 17); the Forgotten
Vault under the Old Well (section 17); the Restless Cairn (a graveyard challenge: something under the cairn "is still keeping count of its
turns"; sheet: Old Hob starts it).

## 9. The Gainlands (Beefcakes)

**Core lesson:** they took everything they thought made him strong, and missed the part that mattered.

**The zone** (`beefcake`, walkable): a sandstone plateau over a gorge, entered by the lowered bridge. Hub: the Swole Station (Old Man
Mountain, Coach Benchley's shop, the Cooldown Hot Tub heal, the protein stand, Flex Mirrors, the Rift Express). Mills and the Colossal
Hamster Wheel, power lines, floating islands reached by Throwers (Big Hurl) and portal rippers (Delt Deck, Calf Cove, Pec Perch, Glute
islands). The House of Gains, a fortress-gym, beyond the north rim; Mount Swolympus's trailhead gate (locked: "coming soon", postgame); the
Iron Cave (S-IRON). The comedy is gym-bro; underneath, people are exhausted. Regime posters; the flag is a barbell with a red line through it.

**The situation.** Chancellor Clench, Iron Regent, runs the Gainlands for Primm like a bureaucracy of muscle: Beefcakes on endless wheels
to power the kingdom, transport only where the regime approves, every weight confiscated. Grandmaster Flex rots in the Iron-less Prison
beneath the House of Gains. (Mastermind: Vivienne Quota, section 6.)

**Gatekeeper: Brick Bronson** (a former courier). Corrupted: "NOBODY CROSSES THE GORGE WITHOUT A SPOTTER. I AM THE SPOTTER. Only iron
matters! Also hydration!" Freed: sheepish, apologetic, has quietly taken up stretching (rumours of the old man who never broke).

**Mini story** [built]: Old Man Mountain remembers the Lifting Festival: the old king came every summer with his boy, who tried to lift a
dumbbell and fell on his royal behind, "four colours in his hands, plain as day". Freed: "When you lifted that last regime brute, you made
the same face he did."

**Favours** (any one is the main line's midpoint): Juice the Station (`gain_power`, Foreman Gus: run the wheel, drink a shake); Spot Me!
(`gain_spot_me`, Old Man Mountain: spot Gary, flex at a Flex Mirror; opens Calf Cove); Clear the Lanes (`gain_lanes`, Coach Benchley:
beat three roamers).

**Dungeon: the House of Gains** (D-HOG, 13 nodes): Grand Entrance; Cardio Corridor / Free Weight Courtyard; Protein Pantry; Locker Room of
Legends; the Regime Checkpoint (elite); Stairs Down (the optional branch: skipping nodes 8-9 skips the rescue); Prison Block; **the
Iron-less Prison** (rescue: Flex joins as an ally token); Meditation Garden (heal); Hall of Trophies (elite; an empty trophy for Flex) / the
Sauna of Truth (deck challenge); **Throne of Gains** (boss). Rules: Pump Iron (your Beefcake units enter with +1 attack); in the prison
(nodes 8-9) Iron cannot be used. Reward: The Big Unit (B-32), a Gilded Beefcake Pack; frees the Gainlands. Hook: "The old champion isn't
dead. He's under the House."

**The rescue.** Flex looks frail and ancient, meditating. He trained ten years with nothing: calisthenics, yoga, breath. "They took the
plates, the protein, the pump. I had nothing. So I had everything." The Wanderer is shaken without knowing why.

**Boss: Chancellor Clench.** Flex's star pupil, the strongest lifter he ever trained, who never believed he was strong without the iron.
Primm (through Quota) offered him control. At the Throne of Gains Clench sneers; Flex says "Hold my coat" and throws off his robes (still
`still.flex`): "They took my weights. They forgot to take me." "True strength is not the ability to lift heavy things. It comes from the
heart, and from the mind."

**Resolution.** Flex beats Clench by refusing to hate him: "We start from zero. Everyone does." Clench, stripped of title and medals, does
not take the hand yet, but does not pull away. Flex to the Wanderer: "Whatever they took from you, son, it was not the part that matters."
If Flex was not rescued, he walks up out of the prison on his own after the fight: "I was going to leave eventually. Lovely day for it."
**Freed:** the wheels turn at a healthy pace ("Quotas abolished"), transport runs, the weights come out from under Benchley's floorboard,
Flex opens the gym to everyone, Gary lifts with a spotter.

## 10. The Endless Buffet (Gourmands)

**Core lesson:** what you are called does not matter; what you do is what matters.

**The zone** (`gourmand`, walkable): an endless banquet landscape entered through the great pantry door. Hub: the Grand Pantry (Basil,
Madame Mirepoix's shop, the Grand Oven, Old Meatloaf the broken golem, heavy meal tables, the Rift Express). Cheerful "innovation"
signage, prototype tastings, golem guards answering "Yes, Chef!", chefs who flinch at the word "weapon". The Test Kitchen at the far end.

**The situation.** It looks like a thriving centre of culinary invention; it is a military-industrial complex. A doppelganger wearing Grand
Chef Escoffina's face uses enchanted, corrupted food (the Special Sauce, in every pot) to bend the chefs, and the food golems that once
protected the kingdom are rebuilt as war machines for Primm. (Mastermind: Colonel Crumb.)

**Gatekeeper: Chef Fennel Gravois.** Corrupted: force-feeding passers-by "for the war effort" ("TASTE IT. TASTE IT!"). Freed: weeps over
plain bread; "The Grand Chef is not the Grand Chef... the real one ALWAYS tasted her sauces." Hands over a key the size of a ladle.

**Mini story** [built]: Basil remembers the four-layer birthday cake the real Chef baked for the little prince, one layer per Path; he ate
the frosting off all four. The fake Chef did not remember it. "Chef remembers every cake she's ever baked."

**Favours:** Pantry Run (`buf_pantry`, Sous-Chef Tarragon: gather ingredients); Bake Me a Pie (`buf_pie`, Madame Mirepoix: the Grand Oven);
Mend the Meatloaf (`buf_mend`, Basil: repair Old Meatloaf).

**Dungeon: the Test Kitchen** (D-TTK, 13 nodes): Loading Dock; Prep Station / Walk-In Cooler; Taste Test Lab (challenge) / Spice Vault;
Prototype Bay (elite: an unfinished war machine); Corrupted Pantry (boon or curse) / Golem Assembly Line; Staff Break Room (heal); **R&D
Archives** (proof of the swap) / Weapons Test Range (elite); the Head Chef's Pass; **the Grand Kitchen** (boss). Rules: Experimental (each
side's first unit gains a random keyword), Corrupted Food (healing heals 1 less). Reward: Grand Chef Escoffina (G-33), a Gilded Gourmand
Pack. Hook (Basil): "Chef doesn't taste her own sauces anymore. Chef ALWAYS tastes."

**Boss: the Doppelganger.** Escoffina's words with no warmth. "They never looked at their Chef. They looked at the food." "You never
taste your own soup, do you?" The disguise peels away into a faceless, shifting shape in a chef's coat (still `still.doppel`). It has worn
her face so long it forgot its own; it never tastes because it cannot taste anything as itself.

**Resolution** (cutscene `wonder`). The true chef is found in the deep freezer, "on ice" for ten years. No speech or document can prove who
she is; dinner does: a plain, golden, enormous dish whose first bite breaks the enchantment through the whole Buffet. Then she gives the
faceless thing her name: "What you're called doesn't matter. It's what you do that matters... Take my old name: Escoffina." She is "the
Grand Chef" (everyone just says "Chef"); the former Doppelganger is **Escoffina**, apprentice, learning to cook honestly (too much salt;
"I did not know people could be so kind about salt"). To the Wanderer: "You do not know your name yet. Good. That is not a flaw, it is a
blank page." **Freed:** war machines melted into ovens, golems back to guarding pantries, the Buffet feeds the kingdom again.

## 11. The D.N.A. (Necrocrats)

**Core lesson:** our job is to help the lost souls. Following orders be damned; we treat everyone with respect.

**The zone** (`necrocrat`, walkable; "The Department of Necrotic Affairs" on its title card, "the D.N.A." everywhere else): a haunted
government office building reached over a causeway and a stone gate. Lobby with the front desk (Agnes), Clerk Ledgerbone's Requisitions,
the breakroom (Gerald's coffee machine, the time clock), cubicle fields, filing mazes, the mail room, the records basement, the executive
floor, and on the skyline the Hall of Final Approvals. Permits to stand, forms for forms, queue numbers for the queue.

**The situation.** The Necrocrats are not good or evil; they believe death should be properly administered. Authority over them was
transferred to Primm through a process that was submitted, reviewed, approved, notarized and filed. It is valid, so they obey. Mortimer
Grimsby, CE-No, enforces every rule to the letter, no matter who it crushes. "Yes, but the authorization is valid." (Mastermind: Percival
Plume, who drafted it.)

**Gatekeeper: Prudence Pallor** (a skeleton clerk). Corrupted: monotone, stamping DENIED ("Your number is zero. It is always zero."). Freed:
tired, wry, sorry: "{villain} did not corrupt us. He used our own rules." Later Agnes's deputy, stamping APPROVED with a flourish.

**Mini story** [built]: Agnes stamped the royal funeral forms herself; the third form, for the little prince, was never filed. Freed: she has
kept it in her drawer for ten years, "just in case. Something tells me it won't be needed."

**Favours:** Clear the Backlog (`dna_backlog`, Agnes: beat roaming staff); Mandatory Onboarding (`dna_onboarding`, Gerald: punch the clock,
pour a coffee); Compliance Audit (`dna_audit`, Clerk Ledgerbone: Director Ectomund's quiz and a hidden stash).

**Dungeon: the Hall of Final Approvals** (D-HFA, 14 nodes): Entrance Queue; Take-a-Number Kiosk (Agnes joins as guide); Department of
Intake / Department of Returns; Waiting Room of Eternity (challenge) / **Records Labyrinth** (the original transfer document); Notary
Checkpoint (elite); Form 27-B Office (boon or curse) / Resurrection Permits Desk; Coffin Breakroom (heal); **Appeals Court** (elite:
Undersecretary Vellum) / the Shredding Room; Executive Elevator; **Office of Final Approval** (boss). Rules: Processing Time (each
player's first spell each turn costs 1 more), Red Tape Everywhere (start with one Red Tape). Reward: Mortimer Grimsby, CE-No (N-33), a
Gilded Necrocrat Pack. Hook: "I just want to finish dying properly."

**Agnes Overdue** is the heart of the zone: a sweet, exasperated ghost who has waited so long to pass on that all she wants is to let go.
Every appeal is denied. She guides the player through the Hall with her enormous stack, turning up at its nodes. In the Records Labyrinth
the transfer is flawless, except one clause under HEIR OF THE FORMER SOVEREIGN: "Deceased (presumed). Remains: not on file." Agnes:
"Irregular." (It means nothing to the player yet.)

**Boss: Mortimer Grimsby, CE-No.** Not cackling-evil, just immovable. "The answer is no. The question is irrelevant. Please state your
case anyway. You have, according to the clock, four hundred years." Under every form, a small note: FILED ON A TUESDAY.

**Resolution** (cutscene `vacancy`). With the CE-No removed, policy passes the office to the senior-most applicant on file: Agnes, who has
filed more appeals than anyone alive or dead. All she wanted was to leave; she stays to fix the system first: "Even the dead deserve
humanity. Our job is to help the lost souls. We have an obligation to help. Following orders be damned. We treat everyone with respect."
Mortimer: "That is not in the handbook." Agnes: "Then we write a new one. Take a number, Mortimer. You are right behind Gerald." To the
Wanderer: "Never let anyone file you under 'subject' again." **Freed:** the queue machines stop, Gerald's number is called, Agnes runs the
Department around one rule (help people), Prudence is her deputy, Mortimer is number 4,000,214 "learning to wait".

## 12. The Verdant Dump (Refusemancers)

**Core lesson:** death is not the end, just a new beginning; to grow, we have to be able to let things go.

**The zone** (`refusemancer`, walkable): a terraced violet ravine of junkyard farms, vine bridges, stone cliffs, purple-mushroom trees and
turquoise water, entered by the forest path's bridge. Hub: the Compost Grange (Brother Bramble, Granny Gristle's shop, Wren Muckfoot's
stables with the charging boar and goat). Smug raccoons, goats that eat the signs, then overgrowth that is wrong in a way the druids can
feel. A corruption gradient deepens toward the Rotheart.

**The situation.** Archdruid Compostella was corrupted through her own bond with nature. The Dump is not dying; it is unnaturally alive:
plants that never stop growing, mutated fungi, roots splitting barns. Nothing rots, so nothing feeds the soil, so everything chokes.
(Mastermind: Hortensia Clipwell.)

**Gatekeeper: Moss Mulligan** (a young faun druid with thorns in her arms). Corrupted: whispering for the "hungry green", overlapping
voices. Freed: shy, earnest, apologetic ("Did I thorn at you?"), loves raccoons ("They are very good boys").

**Mini story** [built]: Brother Bramble: the Archdruid planted a tree for every royal birthday, eleven trees, then nothing; and somebody
carried a sleeping young man through these woods at night, glowing faintly in four colours ("The raccoons saw. Raccoons see everything.").
Freed: Compostella plants a twelfth tree and smiles at the Wanderer on the way past.

**Favours:** Round Up the Herd (`heap_herd`, Wren Muckfoot); Fertilizer Run (`heap_fert`, Granny Gristle); Unblock the Stream (`heap_dam`,
Brother Bramble: smash the junk dam on a charging mount).

**Dungeon: the Rotheart** (D-ROT, 13 nodes): Edge of the Blight; Overgrown Junkyard / Fungal Hollow; Strangled Greenhouse (challenge) / Spore
Grotto; Root-Choked Mill (elite); **Weeping Compost Pool** (corrupted boon; nothing has rotted in ten years) / Thorn Maze; **the Last Clean
Spring** (heal); Hive of Mutant Bees (elite) / Rot Tunnel; **the Heart Roots** (sever the tendrils; weakens the boss); **the Rotheart**
(boss). Rules: Overgrowth (every unit +1/+1 each turn), Rot (1-defense units die at end of turn). Reward: Archdruid Compostella (R-33,
cured), a Gilded Refusemancer Pack. Hook: "The Archdruid hasn't spoken in weeks. The compost... it's growing teeth."

**Why her bond turned.** After a great loss (the ancient tree she grew up beneath), Primm sent her a gift through Clipwell: a seed engineered
by the Path-ologists, "life that never dies" (its tag at the Heart Roots: PROPERTY OF THE PATH-OLOGISTS). In her grief she planted it in the
great tree's place; it has been growing in her grief for ten years. Its records sit in the castle's Refusemancer wing.

**Boss: Compostella, the Rotheart.** Half woman, half tree, roots running into every plant in the Dump; many voices of the hungry green,
sorrowful and enraged ("I am what you throw away. I am what grows back. I am HUNGRY."); under them one small voice: "Please. The tree. I
could not let her go."

**Resolution** (cutscene `sever`). The cure is to let the seed finally die, and she has to agree. "Everything I ever loved, I gave back to
the soil. Except this one. I couldn't." "Then we let it die, together." Letting it rot is the first honest compost in ten years. To the
Wanderer: "You're carrying a loss you can't name yet. When you find its name, don't bury it in a jar. Death isn't the end of them. Let it
be the start of something in you." (It echoes Agnes, who stays before she moves on.) **Freed:** the overgrowth recedes, the spores fade,
the Dump smells like honest compost, Compostella is mortified about the barn, the raccoons are finally put on trial.

## 13. Zone buffs and debuffs

Every zone and its dungeon carries a buff for its own Path's cards and a debuff for its rival's, on both sides of the table (`ZoneEffects`).
Freeing a zone does not remove them: the rivalry is the world's physics, not the ruler's.

| Zone | Buff (own Path) | Debuff (rival Path) |
|---|---|---|
| Gainlands | **Pump It Up**: Beefcake units +1 attack | **Processing Time**: the first Necrocrat unit each turn enters exhausted ("your request is being processed"; softened Oct 19) |
| D.N.A. | **Approved Procedure**: Necrocrat units +1 defense | **Unauthorized Activity**: Beefcake cards cost 1 more (permit fee) |
| Endless Buffet | **Well Fed**: Gourmand units +1/+1 | **Dress Code Violation**: Refusemancer units -1 attack |
| Verdant Dump | **Overgrowth**: Refusemancer units +0/+2 | **Spoilage**: Gourmand units -1 defense |

## 14. The Capital: Primm's Perfection (Pathordia)

**Core idea:** the kingdom's heart, where the cost of perfection is visible everywhere, and where the Wanderer's story and the kingdom's
story become the same story. Zone id `final`, walkable, reachable from the start up the imperial road. Primm renamed it after himself; it
becomes **Pathordia** after his fall.

**Getting in.** Beat **Captain Spotless** at the Approved Gate (absurd entry rules: "State your height. No: do not state it."; the Entry
Examination is a hard card battle) or slip past: Kestrel's quest leads to the resistance's hideout, the **Old Joint Works** hatch in the
Rift Fields drops into the Crease, and a hidden hole in the west wall comes out behind the Reek. All of it is part of the **Old Service
Tunnels**, built by all four Paths together: the old harmony, literally underneath Primm's city. At 0 HP you wake in the Crease once you
know it (else outside the gate) and pay the 20-gold Correction fee.

**Regions** [built, after the Oct 16-17 layout passes]:

| Outside the wall | Inside the wall |
|---|---|
| **The Gate Road**: the Approved Gate, Captain Spotless, the height and queue guards | **The Gate Plaza**: exit-control guards, the Exit Interview booth, the Anonymous Complaint Box, manholes |
| **The Resistance Camp**: Kestrel, a fire, patched tents | **The Palace Approach**: the grand avenue through **the Showcase Quarter** (sixteen identical houses, painted doors, regulation lawns, loudspeakers, portraits, nine Perfectly Happy Citizens) up to the castle stair |
| **The Rift Fields**: rifts, the Old Joint Works shaft by a toppled statue | **The Reek** (Refusemancer district): Old Fern, the Sick Patch, banished compost heaps |
| **The Ruined Outpost**: the broken watchtower, abandoned checkpoints | **Grave Row** (Necrocrat): identical headstones, the permit office, Widow Pell's parlour |
| **The Old Service Tunnels mouth**: the S-CAP door | **The Transit Yards** (Beefcake): the tram shed, three energy wheels, Rollo Spokes, the main power cable |
| | **The Hungry Quarter** (Gourmand): the identical row, Chef Marlo, the paste dispenser |
| | **The Correction Ward**: where citizens who "smiled incorrectly" are corrected (Citizen 4471: eleven degrees, not the approved eight) |
| **The Crease** (underground hideout of the Wrinkles, "the people Primm could not iron out"): Wren, Fig Sly's black market, Nurse Hesper Dray's Tea of Dissent, the Rift Express, the service shafts | **Primm's Castle** on its hill to the north |

**The facade.** Up close the Showcase Quarter is hollow: doors that do not open, storefronts that are painted, citizens who say an
approved phrase, then a slightly-off one, then a frightened whisper ("Everything is perfect! ...help."). Decrees: Approved Hat Sizes: 1,
Spontaneity by Permit Only, Smiling Is Mandatory. Beyond the facade the city is grey, cracked and coming apart.

**Rifts.** Glowing tears in reality that hurt on contact, warp the light and empower nearby enemies (Rift Wretches, Shard Swarms). They exist
because Primm's forced connection to the Paths has been failing since the prince escaped ("It began the night the boy got out, they say," -
Nurse Hesper). Five can be sealed; the big ones stay open until Primm falls.

**The broken services** (the Capital's debuffs while a Path's zone is not free; each freed zone lifts one and visibly restores something):

| Path | Debuff while unfreed | Restored look |
|---|---|---|
| Beefcake | **Blackout**: darkness, slower movement, no shaft travel; your units enter exhausted | the lights come back, the tunnels open |
| Gourmand | **Famine**: -5 max HP; healing items do nothing | food stalls reopen with lanterns and steam |
| Necrocrat | **Restless Dead**: enemy units sometimes return from the Refuse Pile (35%) | the cemetery is calm |
| Refusemancer | **Clutter**: three Heaps of Rubbish shuffled into your deck | the heaps shrink, flowers grow in the Reek |

**The hunt.** Enforcers search for an "escaped Royal Asset". Lost-property posters: "HAVE YOU SEEN THIS IMPROVEMENT OPPORTUNITY? ... Last
seen leaving a Ministry facility, ten years ago, in the company of a traitor." After the reveal: "Height: yours. Face: yours. Last seen:
reading this poster." Defaceable for a little gold, like every portrait.

**The resistance.** **Wren** (once Royal Archivist, keeper of the true records) leads the Wrinkles from the Crease, with **Fig Sly**
(black market; not to be changed) and **Nurse Hesper Dray** (the Tea of Dissent). **Elder Maren** is the resistance's contact in Crosspath.
**Kestrel** scouts the outskirts and knows every secret way in.

**The four Path quests** (each a serious beat, funny on the surface; each pays gold, XP, a card, an item and a story insight into Primm,
flag `capital_insight_<path>`, which Wren writes into the true record):

| Path | Quest (id) | Giver | The weight under the joke | Insight | Lieutenant finale [canon, not built] |
|---|---|---|---|---|---|
| Necrocrat | Form 27-B/6: A Burial Permit (`cap_burial`) | Widow Pell | Her husband has sat dead in his parlour chair for three years; the permit loops. Find the Stamp of Final Approval, lay Mr. Pell to rest. | He scheduled grief for Thursdays | (Plume is fought in the castle instead) |
| Beefcake | The Wheel Never Stops (`cap_wheels`) | Rollo Spokes | Crews run endless wheels to light the facade ("we were told it was cardio"). Free the crews, cut the power cable. | He made lateness illegal | Vivienne Quota, Transit Yards |
| Gourmand | The Recipe Box (`cap_recipes`) | Chef Marlo | Everyone eats Primm's Perfect Nutrient Paste. Find the hidden recipe cards, spoil the dispenser. | He cannot taste food; he never could | Colonel Crumb, the Paste Works (S-PASTE) |
| Refusemancer | Untidy (`cap_untidy`) | Old Fern | Composting is outlawed as "untidy". Rescue the banished heaps, plant the old seed in the Sick Patch. | He fears anything that grows without asking him | Hortensia Clipwell, the regulation lawn |

Wren on the insights: "He is not a monster. He is a man who made a list of everything he could not control, and made it illegal."

**Isla** [canon, not built]: Brannoch's daughter went up the Capital road eight years ago and never wrote; she was stuck on the Showcase
Quarter's facade crews. When the Capital is freed she walks home through her father's unlocked gate. "Hi, Dad. I know. I should have
written." Played straight.

## 15. Primm's Castle and the final fight

**Primm's Castle** (D-PC, the final dungeon, 22 nodes by the sheet; the game uses the sheet's layout). A gleaming, perfectly symmetrical
palace of white stone, gold and mirrors, every surface reflecting Primm, with cracks and rifts seeping through behind the polish. Main path:
Castle Gate, Courtyard of Perfect Hedges, Grand Foyer, Portrait Gallery, Hall of Mirrors (elite), Ministry of Correction, Resistance Safe
Room (heal), **Archive of Good Intentions** (Primm's journals), Royal Stair (elite), **the Model Room** (boss). Dead-end side branches
return to where they came from: Gilded Pantry; the four Path wings (Gourmand: the Doppelganger's Lab Notes; Beefcake: Coup Orders
Barracks; Necrocrat: Notarized Archives; Refusemancer: the Corrupted Seed Vault); Correction Ward Cells (free prisoners for a boon; the
Path-ologists' records); Mirror Maze; Royal Kitchens; **Primm's Private Gallery**; Clocktower Balcony and the Royal Vault; Garden of
Uniform Flowers. Rules: the broken services, Perfect Order (no unit counts more than 2 keywords), Mirrors (each player's first card is
copied for the opponent). Hook (the resistance): "It ends where it began. The castle."

**Story beats:**
- **The four wings**: each Path's takeover in its own clipboard voice ("Subject A (the Grand Chef) proved resistant to persuasion.
  Resolved by substitution."; "COUP ORDERS: Remove Grandmaster Flex... NOTE: do not underestimate him. He does a lot of stretching.";
  "FORM 1-A (NOTARIZED)... I did not need to force anyone. I needed only to be correct."; "THE SEED: Nature disagrees with itself.").
  Margins in a smaller, shakier hand show the cracks.
- **Primm's Private Gallery**: the royal family portrait, the king and queen painted over in white, every brushstroke one direction. Only
  the boy's face is left: "KEPT FOR REFERENCE." The boy has his face.
- **The Path-ologists' records** (Correction Ward Cells): notes on "the Subject" reveal what was done to the prince and how the stolen
  power holds Primm on the throne. Some of the oldest notes are in Maren's handwriting, signed "M."
- **The Archive of Good Intentions**: early journals, sincere and helpful, sliding entry by entry into control.
- **Elowen is taken** [canon, not built]: when the Wanderer first enters the castle, Plume has her taken back to the Lab.

**The final boss: Primm, three phases** (separate duels on one node, HP carrying over; losing any phase sends you home):
1. **Standardization**: every unit is a 3/3 and each side plays at most two non-infrastructure cards a turn ("Two is the perfect number";
   plus a Royal Guard boss rule). Answer: strength is not control.
2. **Reflection**: his deck is a copy of yours and he draws an extra card. "Everything you can do, I can do. I have had ten years of
   practice with it." Answer: a name is not a self; no order outranks treating people with respect. He falters: "I made a list of things
   other people had already built, and I put my name on it."
3. **Unraveling**: his units get +1/+1 and he draws extra, but he loses 1 HP each turn; the rules break, the arena cracks, the selfishness
   under the sincerity shows ("I only wanted it to be nice!"). Answer: nothing grows if you refuse to let anything go.

**Boons.** Each freed leader lends one: Grandmaster Flex's Heart, the Grand Chef's Feast, Agnes's Appeal, Compostella's Roots. With none,
"Nobody stands beside you... You step into the chamber alone."

**If fewer than four zones are freed** and he does not know yet, Primm tells him (cutscene `primm_reveal`): "You have not once asked why my
portraits stop at eleven... I kept your face... It is the only face I could not improve. You are {prince_full}." Rushing the castle
becomes its own darker reveal. Defeating Primm frees every Path still unfree (their rulers answered to him); no zone rewards are paid.

**His end** (cutscene `primm_end`, still `still.primm`): "It was the mirrors. Wasn't it. I wanted a world where nothing could surprise me.
And I forgot that a world where nothing surprises you is a world with nobody else in it." "Tell the Wrinkles... I am sorry about the
hats." The still: no crown, a tired man kneeling above a very small kingdom; "the end of a long, quiet lie".

## 16. The ending

Ten beats in this order (`EndingDefs.BEATS`):
1. **The Model Falls** (1): the model cracks, the castle walls come down; a portrait lands face-up and nobody picks it up.
2. **The Pathwork Throne** (8): the castle opens; a stair of four colours winds down to the throne. The Wanderer sits and it answers;
   everything returns at once: the lullaby, the glass, the throne room, the name. All four Paths, as they were meant to be carried.
3. **The Facade Falls** (2): painted doors fall flat, hedges wilt into natural shapes, a child paints the new gate sign: PATHORDIA.
4. **The Rifts Close** (3): the Sick Patch is a flower bed; a family walks to a quiet plot in Grave Row; the wheel crews lie in the sun;
   somebody in the Hungry Quarter lights a stove.
5. **Primm Sees** (9): as balance returns he sees the kingdom as it is, not as his reflection: cracked streets, real faces, a boy he kept in
   a cell. He still has good points; he cannot be trusted with another choice.
6. **The Wrinkles** (4): up out of the Crease; Wren with the true records, Hesper with the tea, Fig Sly already selling something.
7. **The Paths Meet** (5, still `still.reunion`): Flex, the Grand Chef, Agnes and Compostella in the plaza. Beefcakes late, Necrocrats with a
   form, Gourmands overdressed, Refusemancers smelling faintly of compost. Nobody agrees on anything; the happiest sound the Capital has heard.
8. **File Complete** (10): Agnes stamps the heir clause HEIR: ALIVE. FILE COMPLETE. Maren pushes through the crowd: "Tessar. Welcome home."
9. **Together** (6): the point was never to be the same; the point was the argument.
10. **The New Decree** (7): DIFFERENT PATHS MAY MIX AGAIN ("MAY" crossed out for SHOULD, then WILL, IF THEY FEEL LIKE IT).

Then **The Paths Unbound**: decks may use 3+ Paths, tri-Path crafting opens, Pathordia is open to everyone, Primm works under guard on wells
and pipes. The reunion still ends on "a hooded traveler... with leaves still in their hair. There is always another path."

**The royal funeral** [canon, not built]: Old Hob has been digging the king and queen's graves for ten years; at the royal funeral he walks
them, and Agnes, home. (When it happens, ending or postgame, is open.)

## 17. Side dungeons and secrets

Every dungeon is node-based (locked Oct 15 rule): you enter from an entrance spot in a walkable area and play a node map; no dungeon is
walkable. Side dungeons have three battles and a unique first-clear card.

| ID | Side dungeon | Where / hook | Boss | Rule | First-clear reward | Status |
|---|---|---|---|---|---|---|
| S-TOWN | **The Forgotten Vault** (quest "The Door Under the Well", `side_s_town`, Elder Maren) | Under Crosspath's Old Well, through the iron hatch. Maren: "There is a door under the old well that has been locked since before I was born." The key is in a hidden chest in town. Nodes: the Rusty Gate, the Hall of Four Banners, the Vault Core. | The Old Kingdom Automaton, the Vault Guardian (`NPC-AUTOMATON`): built by all four Paths together, waiting for someone worthy of the old banner. "Identify. The Old Kingdom's banner is not for just anyone." After: "Four Paths. One kingdom. Carry it well." | Old Kingdom: colorless units +1/+1 | Old Kingdom Banner (C-21) | built |
| S-BEEF | **The Ascent of Mount Swolympus** ("Water for the Hermit", Old Man Mountain) | The Barbell of the Ancients atop the mountain, liftable only by the worthy. "Only the worthy reach the top. Also bring water." | The Ancient Spotter, a stone colossus spotting the barbell for 1,000 years ("one more rep") | Thin Air: Hustle units +1/+0 | Barbell of the Ancients (B-30) | sealed until the postgame ("coming soon") |
| S-IRON | **The Iron Cave** (game only; not on the sheet) | In the Gainlands, open from the start: "the Beefcakes who never skip leg day" | Baron Quadzilla, the Leg Press Lord, who has not stood up in years | (dungeon rule in `DungeonRules`) | (see `postgame_dungeons.json`) | built |
| S-GOUR | **Omakase** ("The Golden Reservation", Basil) | A golden reservation card hidden in the Buffet: "Seating: 1. Courses: 3. Survival: optional." No menu; you leave your fate to the chef. | The Itamae Supreme (silent; one perfect word per fight) and his masterpiece, a bull made of toro | Fresh Fish: tokens +1/+1 | Toro Toro (G-27) | built |
| S-NECRO | **The Waiting Room of Eternity** ("Number 4,000,212", Gerald) | "Number 4,000,212? They're on 3. Can you help?" | Betty Bones, Surly Secretary ("forms A through F") | Please Wait: units enter exhausted | Betty Bones (N-30) | built |
| S-REF | **The Trash Panda Throne** ("Who Ate the Compost?", Brother Bramble) | "Little paw prints. A tiny crown." A raccoon kingdom under a giant dumpster. | His Majesty the Raccoon, sweating profusely ("WE DID NOT EAT THE COMPOST. We... sampled it.") | Midnight Snack: eating garbage heals 1 | Raccoon (R-27) | built |
| S-CAP | **The Old Service Tunnels** ("The Older Way", Kestrel) | "There's an older way into the city. Nobody remembers it. That's the point." Four-faction murals; ends at the Grate Beneath the Plaza. | Enforcer Captain Spotless | Forgotten Harmony: multi-Path cards cost 1 less | The Wanderer (C-29) | built |
| S-PASTE | **The Paste Works** (Chef Marlo's quest) | In the Capital | Colonel Cornelius Crumb | - | - | canon, not built |

**The Forgotten Cave and the dry spring.** See sections 4 and 7.

**Other secrets** (details and locations in `docs/design/secrets.md`):
- **Shiro Swindle, Master of the Oldest Trick** (`NPC-NINJA`, quest `oldest_trick`): hides in suspiciously giant chests (one in town, one in
  each Path zone), mocks the player for "the oldest trick in the book", steals 50 gold, vanishes ("SMOKE BOMB!!!"). After the fifth he
  challenges the player at the first chest; beating him pays 3 Gilded Packs. Secretly lonely; wants a worthy rival.
- **The Four Seals** (`four_seals`): a hidden lever in each Path zone; the Four-Seal Vault in Crosspath's north hills opens on the
  **Warden of the Four Seals** (`NPC-VAULTWARDEN`, a towering stone-and-gold sentinel with four glowing seals), the hardest duel in the
  game. Reward: the Four-Seal Signet and the Cloak of the Four Seals.
- **The Sealed Vault** near the Old Well (opened by a lever hidden elsewhere in town; reward B-27). Not the Forgotten Vault.
- **The Secret Dealer** in the square's alley (Epic and Legendary goods, "{villain}'s tax collectors don't know this stall exists").
- **The Restless Cairn** in the graveyard (a scripted challenge that keeps count of its turns).
- Hidden chests in every area; three special cosmetics hinted by Pip Threadwell (a crown of living leaves, a cloak on a muscly island, the
  Capital's mantle).

## 18. Postgame: the Path-ology Lab, Siphon and Elowen

**Unlock.** Primm's defeat sets `postgame_unlocked` (3+ Path decks, tri-Path crafting hook, Prismatic packs). Rip Tearson tells the
Wanderer he went exploring "that forest where you all started out" and saw "very interesting things. A hatch in the clearing that was NOT
there before. Little glowing roots. A smell like a hospital." He rips a forest station onto the Rift Express (`rift_station_forest`) and the
hatch appears in the clearing (`lab_revealed`). "Whatever is under that hatch, it is yours, I think."

**The Path-ology Lab** (D-LAB; the sheet says "to be designed", so the game uses a 14-node placeholder in `postgame_dungeons.json`, see
`docs/design/pathology_lab.md`). White, sterile and wrong: tiled corridors cracked by roots, glass tanks glowing in the four Path colours,
draining rigs, cells, desks with mugs and notes. The horror is how ordinary it is. It answers "what was done to the Wanderer". Beats: the
Break Room (notes on the Subject; a "cooperative?" column filled in with "asks for his mother"); **the Prince's Old Cell** (ten years of
tally marks; a child's four-colour drawing of his family); the Draining Chamber (the Drain Warden); **the Rescuer's Cell**; **the Chief
Path-ologist's Laboratory**. Entering and losing carry the party back to the forest. First clear: Siphon's Lens, gold, XP, `lab_cleared`.

**Dr. Ambrose Siphon, Chief Path-ologist** (`NPC-SIPHON`, the boss; the sheet marks the name a placeholder). Maren's former protege and the
prince's Royal Pathguide, who taught the boy to walk the Paths. At the coup he stepped aside and let Primm's guards through, then took over
Maren's research and spent ten years draining his former student. Cold, curious, proud; calls the prince "my finest work". Still running
experiments after Primm's fall. Believes Elowen is "just confused" and will come home. Clinical, precise, faintly delighted; paternal in a
way that is worse. Canon fight: a four-Path monster with one-sided Protocols and auto-generated Failed Experiment tokens. **In game now:** a
50-HP Necrocrat control deck with each Path's legendary.

**Elowen Vey, the Rescuer** (`NPC-ELOWEN`, was NPC-RESCUER). Siphon's daughter; she goes by her late mother's name, Vey. She grew up beside
the prince and has had a crush on him since they were children. She worked in her father's lab, saw what was done to "the Subject" and
knowingly defected over the injustice. She smuggled the prince out through the royal tunnel. She believes he is the lost prince but is not
sure: he does not remember her and can walk only one Path; she grows sure as he keeps risking himself for others. She is mostly in the dark
about her father's past and does not know whom to trust; she and Maren clash constantly (Maren distrusts Siphon's daughter and calls her
"a dreamer chasing a ghost"). Quick, wry, guarded; hope she tries to hide.
- Canon arc [canon, not built unless marked]: the prologue and the Path choice [built]; a Cave Mouth scene outside Crosspath after each
  freed zone; taken back to the Lab by Percival Plume when the Wanderer first enters the castle; in the postgame an optional rescue node,
  after which she joins the Siphon fight as an ally token (T-24) and confronts her father.
- **In game now:** she is "The Rescuer" (`{rescuer}`); the rescue node gives the boon "The Rescuer Fights Beside You" (+1/+1, +3 max HP);
  freed (`rescuer_freed`) she stands in the forest with her hood down and still withholds her name: "I will tell you my name when the dust
  has settled, I promise." / "My name is still the one thing I have not given anyone."

**Other postgame:** Mount Swolympus opens; Pathordia's freed lines; the reformed Escoffina; Primm at work; Prismatic packs.

## 19. The cast: every named NPC

Ids and names match `data/npcs/npcs.json` (71 entries) and the sheet. Species are the sheet's "Species / Type (final)" column; where that
column is blank the sheet's Notes column is used (see the inbox about the lieutenants). Voices in one line each; longer samples in
`voice_bible.md`. "Off-sheet" characters exist only in game text.

### Starting area and Crosspath

| Id | Name | Role | Species | Personality and voice | Relationships and arc |
|---|---|---|---|---|---|
| NPC-PLAYER | The Wanderer (Prince Tessar Wayweaver) | Player | Human | Curious, resilient, quietly funny; short wry monologue, earnest when it counts | Section 5 |
| NPC-ELOWEN | Elowen Vey ("The Rescuer") | The rescuer; childhood friend, love interest | Human | Quick, wry, guarded; hides her hope | Siphon's daughter; clashes with Maren; section 18 |
| NPC-ELDER | Elder Maren | Town elder, resistance contact, founder of Path-ology | Tortoise (female, she/her) | Grumbly, slow, cryptic; calls everyone "dearie" (not always a compliment); bakes too many pies; a grumpus to the young with a kind heart | Distrusts Elowen and Siphon (her protege); refuses to believe the prince is the prince ("That's no prince. That's a damp young man."); warms memory by memory; at the fourth admits she knew; gives the Door Under the Well |
| NPC-GATEKEEPER | Gatekeeper Brannoch | Guard; gives Free the Four Zones | Bear | Gruff, enormous, secretly soft; short grunts, then a tender sentence; keeps a notebook of every traveller's name | His gate has no lock; daughter Isla; reunion when the Capital is freed [canon, not built] |
| NPC-ISLA | Isla Brannoch | Brannoch's daughter | Human per sheet notes (game data: bear; inbox) | Tired, warm, a little embarrassed ("Dad says hi. Dad says a lot, actually.") | Stuck on the facade crews eight years; walks home [canon, not built] |
| V-SABLE | Sable | Card vendor (singles, General Packs) | Fox | Sly, glamorous, theatrical; "darling"; never reveals her sources; loves misprints | First vendor ("You start with plain neutral cards") |
| V-TONIC | Tilly Tonic | Item vendor | Frog (skin changes colour like her potions) | Overenthusiastic apothecary who tests everything on herself; fast, bubbly, exclamation points | - |
| V-BEETSWORTH | Bertram Beetsworth, Assistant to the Regional Merchant | Equipment vendor; armory quest at level 5 | Human | Intense, rule-obsessed beet farmer; Security Protocols; clipped facts about beets and bears; must stay an original character | Will one day supervise Percival Plume |
| V-THREADWELL | Pip Threadwell | Clothing (hats, cloaks) | Mouse | Tiny, flamboyant haberdasher; grand, dramatic; measures without asking | Hints at the three secret cosmetics |
| V-FENWICK | Foil Fenwick | Path Pack vendor | Magpie | Twitchy pack-sniffing enthusiast; breathless, whispers "foil" | Stocks a Path's pack when its dungeon falls |
| V-ALEMBIC | Auntie Alembic | The Alchemist (crafting) | Otherworldly being (four arms, four-coloured skin) | Calm, eccentric, talks to her flasks; soft, mystical, unexpectedly blunt | Believes the kingdom was healthiest mixed; opens after two zones |
| NPC-BELLOWS | Announcer Grand Bellows | Arena master (the Undercroft) | Walrus (the moustache is real); he/him | Booming showman who narrates everything, including his own lunch; LOUD | Fights as "The Marshal" in Gold Sand |
| NPC-HOB | Old Hob the Gravedigger (secretly Death) | Gravedigger | Ghoul | Creaky, polite, cheerful about death; ends on a chuckle; checks his appointment book ("Hm. Not for a good long while."; Primm: "Penciled in."; Plume: "Oh, I've got you in pen.") | Canon: starts the Restless Cairn; appears at 0 life ("Not on my list. Off you pop."; lost gold is his handling fee); a cameo in every zone, "just measuring"; the royal funeral [mostly canon, not built] |
| NPC-BRONSON | Brick Bronson | Beefcake gatekeeper | Human | Corrupted: barked slogans; freed: sweet, sheepish, loves stretching | Corrupted by Quota |
| NPC-PALLOR | Prudence Pallor | Necrocrat gatekeeper; later deputy head of the D.N.A. | Skeleton | Corrupted: monotone policy; freed: dry humour | Corrupted by Plume; Agnes's deputy |
| NPC-GRAVOIS | Chef Fennel Gravois | Gourmand gatekeeper | Human (changed from ogre) | Corrupted: manic, pushy; freed: dramatic, warm, emotional | Corrupted by Crumb |
| NPC-MULLIGAN | Moss Mulligan | Refusemancer gatekeeper | Faun (she/her) | Corrupted: whispery, overlapping; freed: soft, nervous, loves raccoons | Corrupted by Clipwell |
| NPC-VILLAGER | Brindle the Baker (npcs.json: "Bun the Baker"; inbox) | Strolling baker | Badger | Puns ("I knead a vacation.") | - |
| NPC-TOWNSFOLK | Crosspath townsfolk | Strollers | Human | Passing lines only | - |
| NPC-AUTOMATON | The Vault Guardian (the Old Kingdom Automaton) | Boss, the Forgotten Vault | Construct | Ticking, formal, ancient | Built by all four Paths together |
| NPC-VAULTWARDEN | The Warden of the Four Seals | Boss, the Four-Seal Vault | Construct (golem) | Calm, then angry | - |
| NPC-WARDEN | The Hollow Warden | Tutorial boss | Stone guardian | Rumbling, few words, approving at the end | Lets only the bloodline pass |
| NPC-NINJA | Shiro Swindle, Master of the Oldest Trick | Prankster, secret boss | Human (ninja) | Smug, theatrical, terrible ninja puns; secretly lonely | Section 17 |

### The Gainlands

| Id | Name | Role | Species | Personality and voice | Relationships and arc |
|---|---|---|---|---|---|
| NPC-FLEX | Grandmaster Flex, the Unbroken | Beefcake leader (ally token) | Human | Serene, slow, kind; perfect timing; sincere when freed | Clench's old master; lends Grandmaster Flex's Heart |
| NPC-CLENCH | Chancellor Clench, Iron Regent | Boss, House of Gains | Human | Barked orders in reps and regulations; strength means control | Flex's star pupil; Quota's figurehead; offered a fresh start from zero |
| NPC-QUOTA | Vivienne Quota, Minister of Efficiency | Beefcake lieutenant | Human per sheet notes (game data: ferret; inbox) | Crisp, percentages and seconds | Section 6 [canon, not built] |
| V-BENCHLEY | Coach Brutus Benchley | Zone card vendor; Clear the Lanes | Minotaur | Retired champion selling cards like supplements; whistle, clipboard, no inside voice; "LET'S GO!" | Hid the old cards under a loose floorboard |
| NPC-HURL | Big Hurl | Thrower | Stone troll | Gentle giant; counts down before every throw; "never once missed (he says)" | Represents all Throwers |
| NPC-RIP | Rip Tearson | Portal ripper; runs the Beefcake Rift Express | Human | Rips portals and his shirt every time (400 identical shirts); a grunt, then calm customer service | Every station is a cousin named Rip (#2 to #8); finds the Lab hatch |
| NPC-PUMP | Professor Pump | Quiz master | Rhinoceros | Buff academic in tweed; "brain-ceps"; grades on a bicep curve | - |
| NPC-THUNDERABS | Chet Thunderabs | Minigame host (Rep Counter) | Human | 80s-90s infomercial host; "But WAIT, there's MORE!" | The regime banned his show |
| NPC-MOUNTAIN | Old Man Mountain | Hermit; Spot Me!, Water for the Hermit | Yeti | Wheezy, nostalgic, trails off; once climbed Swolympus | Remembers the king and the boy at the Lifting Festival |
| off-sheet | Foreman Gus | Wheel foreman; Juice the Station | - | Tired foreman with a heart of iron | Not the retired Capital "Gus" (now Rollo Spokes) |
| off-sheet | Gary | Under a barbell, again | - | "Little help? No rush. Bit of a rush." | Lifts with a spotter once freed |
| off-sheet | Rhonda (a Gainlands ripper) | Opens the Calf Cove portal | - | - | Name clash with Recycle Rhonda (inbox) |

### The D.N.A.

| Id | Name | Role | Species | Personality and voice | Relationships and arc |
|---|---|---|---|---|---|
| NPC-AGNES | Agnes Overdue | Front desk; quest giver; guide in the Hall; later head of the D.N.A. | Ghost | Sweet, exasperated, motherly; steely when it matters; "Deceased since 1987, employee of the month since 1987" | Section 11; lends Agnes's Appeal; stamps FILE COMPLETE; walked home by Hob at the royal funeral |
| NPC-GERALD | Gerald, Number 4,000,212 | Quest giver (Mandatory Onboarding, Number 4,000,212); breakroom barista in game | Ghost | Patient, endlessly polite, slightly unravelling; tired, hopeful | Waiting centuries; his number is called when the zone is freed; Mortimer waits behind him |
| V-LEDGERBONE | Clerk Ledgerbone | Zone card vendor; Compliance Audit | Skeleton | Meticulous; a form for every purchase; flat, procedural, tiny flashes of joy | His stamp stops haunting when freed |
| NPC-ECTOMUND | Director Ectomund | Quiz master (Compliance Examiner) | Ghost | Officious, droning; 300 years of the same quiz; delighted by correct answers | The ethics questions were removed by management |
| NPC-KYLE | Kyle (Deceased Since '09) | Minigame host (memory matching) | Ghost (human) | Millennial ghost: away messages, dial-up, top 8, a virtual pet that keeps dying; "brb" | Filed the transfer paperwork without reading it |
| NPC-MORTIMER | Mortimer Grimsby, CE-No | Boss, Office of Final Approval | Skeleton | Formal, dry, rare deadpan; immovable, not evil | Removed; number 4,000,214 behind Gerald |
| NPC-VELLUM | Undersecretary Vellum | Elite, the Appeals Court | Undead | Monotone, polite, devastating ("Noted. The authorization remains valid.") | Mortimer's deputy |
| NPC-PLUME | Percival Plume, Deputy Minister of Good News | Necrocrat lieutenant; the loudspeaker voice | Human per sheet notes (game data: peacock; inbox) | Oily, upbeat PR-speak; never wrong, always taking credit | Section 6 [canon, not built] |
| NPC-BETTY | Betty Bones, Surly Secretary | Boss, Waiting Room of Eternity | Skeleton | Cat-eye glasses, never impressed; dry, nasal, sighing | - |

### The Endless Buffet

| Id | Name | Role | Species | Personality and voice | Relationships and arc |
|---|---|---|---|---|---|
| NPC-ESCOFFINA | The Grand Chef (formerly Grand Chef Escoffina) | Gourmand leader | Human | Warm, commanding, maternal; feeding people is the highest form of protection | Ten years in the freezer; gives her name away; lends the Grand Chef's Feast; will teach Crumb to cook |
| NPC-DOPPEL | The Doppelganger, later Escoffina | Boss, Test Kitchen; postgame apprentice | Shapeshifter | Escoffina's words with no warmth; later hesitant, earnest | Section 10 |
| NPC-CRUMB | Colonel Cornelius Crumb, Director of Culinary Defense | Gourmand lieutenant | Human per sheet notes (game data: badger; inbox) | Barked military orders in food metaphors | Section 6 [canon, not built] |
| NPC-BASIL | Basil | Line cook; Test Kitchen hook; Mend the Meatloaf, The Golden Reservation | Rabbit | Nervous, whispered, jittery, loyal; brave when it matters | Noticed the Chef never tastes; remembers the prince's cake; terrified of Crumb |
| V-MIREPOIX | Madame Mirepoix | Zone card vendor; Bake Me a Pie | Persian cat | Elegant, snooty, presents cards like courses; secretly adores scrappy customers | Has been faking the Special Sauce for months |
| NPC-PATE | Professor Pate | Quiz master | Human (changed from otter) | Plump scholar who answers with recipes; tastes his chalk | Never found the recipe for the Special Sauce |
| NPC-FLAMBE | Chef Flambe Fontaine | Minigame host (Dinner in a Dash) | Human | Over-the-top cooking-show host; "Order UP!"; feuds with everyone | Rival Chef Savannah Souffle took a Test Kitchen job |
| off-sheet | Sous-Chef Tarragon | Fetcher of things; Pantry Run | - | Harried, hungry, a bit scared | - |
| off-sheet | Old Meatloaf | A broken food golem | Golem | - | Repaired in Mend the Meatloaf |

### The Verdant Dump

| Id | Name | Role | Species | Personality and voice | Relationships and arc |
|---|---|---|---|---|---|
| NPC-COMPOSTELLA | Archdruid Compostella | Refusemancer leader | Human (druid) | Grandmotherly, wise, mischievous; gentle, earthy, playful; cured: grateful, fierce | Planted eleven royal birthday trees; plants a twelfth; lends Compostella's Roots |
| NPC-ROTHEART | Compostella, the Rotheart | Boss, the Rotheart | Human (corrupted druid) | Layered whispers, sorrowful menace | Section 12 |
| NPC-CLIPWELL | Hortensia Clipwell, Royal Groundskeeper | Refusemancer lieutenant | Human per sheet notes (game data: hare; inbox) | Prim, polite, quietly menacing; "removing weeds" | Section 6 [canon, not built] |
| NPC-BRAMBLE | Brother Bramble | Rotheart hook; Who Ate the Compost?, Unblock the Stream | Hedgehog | Worried, kind, soft-spoken, then suddenly indignant ("SOMEBODY ate the compost AGAIN") | Noticed the corruption first; standoffs with Clipwell |
| V-GRISTLE | Granny Gristle | Zone card vendor (the Compost Grange); Fertilizer Run | Opossum | Cheerful toothless junk-trader; "found, not stolen"; raccoon on her shoulder; folksy, cackling | Will supervise Clipwell's compost duty |
| NPC-THISTLEWICK | Druid Thistlewick | Quiz master | Stag-headed druid | Very serious about recycling; sorts his thoughts into bins | His dishwasher talks back |
| NPC-RHONDA | Recycle Rhonda | Minigame host (Sort It Out) | Human | Peppy 90s-PSA eco-crusader; blue-ribbon obsession; once the voice of Captain Compost Badger | - |
| NPC-RACCOONKING | His Majesty the Raccoon | Boss, Trash Panda Throne | Raccoon | Grandiose, nervous, sweating, deeply guilty | Ate all the compost; the raccoons stand trial |
| off-sheet | Wren Muckfoot | Animal handler; Round Up the Herd | - | Sunny, muddy, unflappable; speaks fluent goat | Name clash with Wren (inbox) |

### The Capital

| Id | Name | Role | Species | Personality and voice | Relationships and arc |
|---|---|---|---|---|---|
| NPC-PRIMM | Primm, "His Perfection" | Final boss; postgame prisoner-engineer | Human | Section 6 | Section 6 |
| NPC-WREN | Wren | Resistance leader; once Royal Archivist | Birdfolk (wren) | Calm, scarred, protective; low, steady, few words, sharp jokes | Remembers the old harmony; records the insights |
| V-FIGSLY | Fig Sly | Black market (Gilded Packs, rare cards) | Weasel | Smooth, whispery, winking; everything "off the books"; surprisingly loyal | Do not change the black market |
| NPC-KESTREL | Kestrel | Resistance scout; The Older Way | Human | Quick, cocky, playful; cryptic chalk marks | Knows every secret way in |
| NPC-SPOTLESS | Captain Spotless | Gate boss; S-CAP boss | Human | Primm's most devoted enforcer; polishes his armour between sentences; a smudge is treason | Freed: "A man came yesterday who was exactly the approved height and I wept." |
| NPC-PELL | Widow Pell | Necrocrat Path quest | Human, with her husband's ghost | Tired humour, quiet grief | Lays Mr. Pell to rest |
| NPC-ROLLO | Rollo Spokes | Beefcake Path quest (renamed from Gus) | Human | Breathless jokes between pedal strokes | Once a Beefcake foreman |
| NPC-MARLO | Chef Marlo | Gourmand Path quest | Mole (hides recipes underground) | Hushed, passionate | Once of the Market of Four Paths |
| NPC-FERN | Old Fern | Refusemancer Path quest | Gnome | Grumbly, defiant, lovable; smuggles worms in her hat | A composter made a criminal |
| NPC-CITIZEN | A Perfectly Happy Citizen | Facade citizens | Human (deliberately identical) | "Everything is perfect!" ... "help" | - |
| off-sheet | Nurse Hesper Dray | The Tea of Dissent (heal) in the Crease | - | "Sit. Drink." Unapproved tea heals faster | - |
| off-sheet | Citizen 4471 | The corrected citizen in the Correction Ward | - | Smiled at eleven degrees at his wife's wedding | Played straight |

### Royal family, the Lab and the remaining bosses

| Id | Name | Role | Species | Personality and voice | Relationships and arc |
|---|---|---|---|---|---|
| NPC-KING | King Harmon Wayweaver | Late king (memories, the painted-over portrait) | Human | Warm, steady | Section 3 |
| NPC-QUEEN | Queen Concordia Wayweaver | Late queen | Human | Soft, musical, resolute | Her lullaby; died shielding her son |
| NPC-SIPHON | Dr. Ambrose Siphon, Chief Path-ologist | Postgame boss | Human | Clinical, precise, faintly delighted | Section 18 |
| NPC-SPOTTER | The Ancient Spotter | Boss, Mount Swolympus | Stone colossus | Booming, encouraging, "one more rep" | - |
| NPC-ITAMAE | The Itamae Supreme | Boss, Omakase | Crane | Almost silent; one perfect word per fight | - |

## 20. Main quest beat list

Quest ids are the game's (`QuestDefinitions`, `ZoneQuestDefinitions`). Zones may be done in any order; the Capital is open from the start.
Quest Log rule (Oct 20): steps are revealed one at a time (done + current, the rest "???"), and no quest title, summary or step names a
twist before it happens (Flex's imprisonment, the Doppelganger, Compostella, the memories' names): see docs/design/quests.md.

1. **New game**: the awakening (`still.wake`, flag `wake_still_seen`) and the hat and cloak choice.
2. **The Rescuer** (prologue) and **Choose your Path**: the starting deck.
3. **The Forgotten Cave** (D-TUT): three battles with card picks, the Hollow Well, the Hollow Warden. Flag `trial_cleared`.
4. **Maren's welcome** and her first greeting: Crosspath, the four Paths, Primm, the gatekeepers.
5. **Maren's errands** (Oct 20, the early-game chain; each is handed back to her and she gives the next): **Meet the Merchants**
   (`meet_the_merchants`: Sable, a card bought, Tilly, Pip; the only quest on arrival) -> **Make It Yours** (`first_deck_edit`: the Deck
   Station) -> **Something in the Store Room** (`storeroom_ghosts`: three petty ghosts in Tilly's store room, who died waiting to return a
   faulty lantern without a receipt; a duel at the door) -> level 5 -> **Some Assembly Required** (`some_assembly_required`: Bertram
   Beetsworth, one fight, the Starter Blade). Only then do the story's main quests appear: the four zone lines and **Fragments**
   (`fragments`), Brannoch's **Free the Four Zones** (`free_the_kingdom`), Maren's **The Door Under the Well** (`side_s_town`). The
   roads are open all along; only the quest log waits.
6. **Each zone line** (MAIN, four steps): beat the gatekeeper (pays the Path Pack), cross in, finish any one favour (pays the midpoint gear),
   clear the main dungeon and free the leader (zone complete: lights, freed NPCs, new lines, signs restored).
   - Raise the Bar (`main_beefcake`): Brick Bronson, the Gainlands, the House of Gains, Grandmaster Flex.
   - Take a Number (`main_necrocrat`): Prudence Pallor, the D.N.A., the Hall of Final Approvals, Agnes.
   - Key Ingredients (`main_gourmand`): Chef Fennel Gravois, the Endless Buffet, the Test Kitchen, the Grand Chef.
   - Root Cause (`main_refusemancer`): Moss Mulligan, the Verdant Dump, the Rotheart, Archdruid Compostella.
7. **After each freed zone**: talk to Maren for the next fragment (memory 1 opens the second Path). [Canon, not built: Elowen's Cave Mouth
   scene; the lieutenant flees to the Capital; Plume's ribbon-cutting.]
8. **First zone**: the Undercroft opens. **Second zone**: Auntie Alembic's opens.
9. **The Capital** (any time; much easier with services restored): the gate (Captain Spotless) or the tunnels (The Older Way,
   `side_s_cap`); the Crease and Wren; the four Path quests (`cap_burial`, `cap_wheels`, `cap_recipes`, `cap_untidy`) and their insights;
   rifts. [Canon, not built: the lieutenant fights; S-PASTE.]
10. **Primm's Castle** (D-PC): the wings, the Private Gallery, the records, the Archive; [canon: Elowen taken by Plume]; the reveal if
    needed; the three-phase duel with the leaders' boons. Flag `primm_defeated`.
11. **The ending** (ten beats), **The Paths Unbound** (`postgame_unlocked`). [Canon, not built: the royal funeral; Isla comes home.]
12. **Postgame**: Rip's forest tip, the Path-ology Lab (D-LAB), the Rescuer freed (`rescuer_freed`), Dr. Siphon (`lab_cleared`); Mount
    Swolympus; the changed Pathordia.

Side quests and secrets that run alongside: every zone favour, the side dungeons, The Oldest Trick in the Book (`oldest_trick`), The Four
Seals (`four_seals`), the Undercroft tiers, and the Old Well secret quest, The Water Under the Well (`secret_old_well`, section 4).

## 21. Running jokes and callbacks

**Callbacks that carry the story** (keep them consistent):
- **Four colours.** The glow fading from his hand at the wake; the boy with "four colours in his hands" (Old Man Mountain); the glowing young
  man in the woods (Bramble); the four-layer cake (Basil); the light in memory 1; the four-colour drawing in his cell; the throne's stair.
- **Eleven.** He was eleven: eleven royal birthday trees (Bramble), portraits that "stop at eleven" (Primm), Compostella's twelfth tree.
- **The face.** "You smell familiar" (Warden); "you made the same face he did" (Old Man Mountain); "I kept your face" (Primm); the posters.
- **The unfiled form.** The prince's funeral form Agnes never filed -> the heir clause "Remains: not on file" -> "Irregular." -> HEIR: ALIVE.
  FILE COMPLETE.
- **"Whatever they took from you, it was not the part that matters."** (Flex) and "a blank page" (the Grand Chef) and "Never let anyone file
  you under 'subject' again" (Agnes) and "don't bury it in a jar" (Compostella): each leader's closing line to him.
- **The lullaby** (memory 1) returns on the throne; the queen's motif in the music.
- **Pie.** Maren starts with the pie and works up from there; the pie is for you, the watching is free.
- **Wells.** Primm's clean wells; the Old Well that "knows you"; Primm in the postgame missing the wells (section 4).
- **The Subject / "again."** The cells; the Lab notes; Agnes's line.

**Running gags:**
- "The authorization is valid." (every Necrocrat, ending with Mortimer's "It was always valid") and "Take a number."
- Gerald's number, 4,000,212; "They're on 3."
- 1987 (Agnes died and became employee of the month; Maren was wrong about someone "once. In 1987.").
- Forms: 27-B needs 27-C needs 27-B; 13-B needs 13-A; forms A through F.
- "Yes, Chef!" and the golems; the Special Sauce; Grand Chef "never tastes".
- Spotting, leg day, hydration, "never lift alone"; Gary under a barbell.
- Rip Tearson's cousins (all named Rip, numbered, "rarely speak"); the sky is heavy; do not look at the seam; shirt number 212.
- The raccoons (very good boys; they see everything; they ate the compost; they stand trial); goats eating the signs.
- Bertram's Security Protocols and "Assistant TO the Regional Merchant"; beets and bears.
- Fig Sly: everything is off the books, even the bags.
- Primm's precision: seventeen people polishing the floor; "two is the perfect number"; regulation hats; approved height.
- Shiro Swindle: the oldest trick in the book, SMOKE BOMB!!!
- Old Hob's appointment book ("Penciled in." / "in pen.") [canon, not built].

## 22. Open questions

Still open (do not decide in text; check with the user):
- **Elowen's name in game**: the sheet names her Elowen Vey, the `{rescuer}` token still reads "The Rescuer", and her postgame lines withhold
  her name. When is it spoken, and by whom? (Inbox.)
- **Elowen's and the lieutenants' scenes** (Cave Mouth scenes, Plume's abduction, the four lieutenant fights, S-PASTE, ribbon-cuttings): sheet
  canon with no build plan yet.
- **When Agnes passes on**: the sheet puts it at the royal funeral; whether that is in the ending or the postgame is open.
- **Leader cards**: N-33 is still "Mortimer Grimsby, CE-No" (now the boss, not the freed leader) and G-33 is still "Grand Chef Escoffina"
  (she gave the name away). The card list is frozen; do not rename cards.
- **The Pathwork Throne vs the Patchwork Throne**: the kingdom became Patchwork; the throne kept the sheet's "Pathwork Throne" (archived inbox
  Oct 17 item 3, unanswered).
- **Dr. Siphon's name** is marked "Placeholder name" in the sheet.
- **The Path-ology Lab's final layout, rules and unique card** (the sheet says "to be designed"; placeholder built).
- **The Wellspring** (section 4): everything beyond what is listed as canon there.
- **Old Hob in game**: his 0-life wake, cameos and the royal funeral are sheet canon; the game wakes the player at the hub with a fee.

## 23. Contradictions resolved (Oct 19)

Each line: the conflict, then the winner and the source that decided it. Items marked (inbox) also need the user; the safest choice was taken.

1. **Kingdom name**: Pathwork (story_source_v2, BL-2), Pathavia (an older sheet, AI-1) vs Patchwork. **Patchwork**: the user's brief and the
   current sheet (ON17-6). The throne stays "the Pathwork Throne" (sheet). Game text: two loading tips still say "Pathwork" (inbox, item 7).
2. **The rescuer's name**: "undecided, use The Rescuer" (v2) vs **Elowen Vey** (sheet). Sheet wins. Game token still "The Rescuer" (inbox).
3. **Who turned the rescuer**: v2 says Maren turned her and told her about the tunnel; the sheet says she knowingly defected on her own and
   that Maren distrusts her. **Sheet**: Elowen acted on her own conscience; Maren is the resistance's contact, not Elowen's recruiter. No
   game text says otherwise.
4. **When the rescuer was recaptured**: "caught after the escape" (v2, pathology_lab.md) vs taken back by Plume when the Wanderer first
   enters the castle (sheet). **Sheet**. The game has no scene either way; its Lab text fits both (inbox, with item 2).
5. **The Arena's name**: the Grand Clashatorium, a colosseum (v2, old bible) vs **the Undercroft** under the abandoned cottage. The
   Undercroft: the user's Oct 16 hub brief (ON-27/29). One stale prompt string remains (`world/town_scene.gd:962`).
6. **Where Maren meets him**: at the cave mouth (v2, sheet D-TUT) vs at her door in Crosspath (game since Playtest v0.4.0). **Sheet as
   canon** (she waits at the far end; the cave's far end leads into Crosspath); the game's staging is kept and noted under section 7.
7. **Maren and the reveal**: v2 has her "finally recognise" the boy at memory 4; the sheet says she knew all along and refused to believe it.
   **Sheet**; memory 4's current text is compatible (an admission can be added in the dialogue pass).
8. **The Path-ologists' head and the coup**: v2 "Siphon, Maren's former protege" vs the sheet adding Royal Pathguide, Elowen's father and the
   one who let the guards through. **Sheet** (additive; no conflict with game text).
9. **The seed's giver**: Primm (v2, D-ROT sheet row, game cutscene "Primm's gift") vs Hortensia Clipwell (NPC sheet). **Both**: Clipwell
   delivered Primm's gift. No text change.
10. **The Necrocrat transfer's author**: Primm writes "I needed only to be correct" in the castle wing (game) vs Plume drafted and filed it
    (sheet). **Both**: Primm ordered it, Plume drafted and filed it. No text change.
11. **The rulers vs the lieutenants**: v2 and the game show only the four rulers; the sheet adds a mastermind behind each. **Sheet** (additive);
    the lieutenants are canon, not built.
12. **Why Agnes and Gerald wait**: Agnes dead since 1987 and Gerald queued for centuries (game, sheet) vs the afterlife's intake freezing ten
    years ago (sheet, Old Hob). **Both**: the queue was always slow; the freeze stopped it entirely.
13. **When Agnes passes on**: open in v2 vs at the royal funeral, walked home by Hob (sheet). **Sheet**; the timing stays open.
14. **The lieutenants' and Isla's species**: the sheet's Notes say "Human." for Quota, Crumb, Plume, Clipwell and Isla, while game data
    (`npcs.json`, `tools/npc_truth_input.json`, Oct 17) made them ferret, badger, peacock, hare and bear. **Sheet** in this bible (inbox).
15. **The baker's name**: "Bun the Baker" (`npcs.json`) vs "Brindle the Baker" (in-game spot and dialogue, Oct 17 inbox). **Brindle**, the
    name the player sees (inbox, data fix).
16. **Two Wrens**: Wren the resistance leader (sheet) and Wren Muckfoot (game-only Dump NPC) break v2's rule "no two characters may share a
    name". Kept as is for now (inbox).
17. **Two Rhondas**: Recycle Rhonda (sheet) and a Gainlands ripper called Rhonda (game text). Same rule; kept for now (inbox).
18. **Grand Bellows's pronoun**: "She has not lost a bout in eleven years" (game, `arena.arena_marshal.blurb`) vs a mustachioed walrus,
    "his own lunch" (sheet). **He** (the old female Marshal, Vesna Tuskmore, was renamed to Bellows; the pronoun was left behind).
19. **The Grand Chef's pronoun**: Basil says "for a man who does not eat" (game) vs the Grand Chef and her double are "she" (sheet). **She**
    (a leftover of the old male chef Aurelio).
20. **Moss Mulligan's pronoun**: the Root Cause summary says "a voice that isn't his" (game) vs a young female faun (sheet). **Hers**.
21. **The Alchemist's signature**: her locked-door note is signed "Z.V." (Zinnia Vex, a retired name). **Retired**; she is Auntie Alembic.
22. **Kyle's year**: "Deceased Since '09" (sheet name) vs "Last employee of the month of 2003" (game text). **'09 (sheet)**; the dialogue
    pass can move his lines to 2009.
23. **Bramble's "a few months back"**: the glowing young man carried through the woods "a few months back" vs a prologue that starts just after
    the escape. **Prologue (sheet)**: read it as "not long ago"; the dialogue pass can soften the time.
24. **The Wellspring**: "four Wellsprings, one per element" (placeholder lore, early title "Wellspring") vs **one Wellspring that fed all four
    Paths** (the user's Oct 19 brief). The user's brief wins; the town well is the Old Well (BL-3).
25. **Castle size**: "25+ nodes" (old bible), 30 nodes (N16) vs **22 nodes** (sheet, and `dungeons.json` today). Sheet.
26. **The facade's name**: the old build called the facade "Primm's Perfection" (the sheet's citizen row still says so) vs **the Showcase
    Quarter** (v2, `{showcase}`); "Primm's Perfection" is the whole city.
27. **The Capital's names**: Neatropolis / Concordia Prime / "the Capital" (Brief 10) vs **Primm's Perfection, then Pathordia** (v2).
28. **Primm in the open**: the user's rule (only in person in the castle) vs any loudspeaker voice: **the broadcasts are Plume** (sheet),
    so the rule holds.
29. **Brannoch's quest**: "Clear the Paths quest beats" (sheet) vs the game retiring Clear the Paths (ON-4) and giving him Free the Four Zones.
    The same job under the new quest; no conflict in text.
30. **Mount Swolympus**: Old Man Mountain gives it (sheet) vs sealed until the postgame ("coming soon", the Gainlands corrective pass brief,
    GC-11). The user's brief wins: postgame.
31. **The Iron Cave (S-IRON)**: exists in game data only, not on the sheet. Kept as game content; the sheet needs a row.
32. **Gourmand colour**: yellow (pathology_lab.md) vs **blue** (the game's `UIStyle.AFFINITY_COLORS`). Game data over an old doc.
33. **The tutorial's choice word**: "after choosing your element" (sheet D-TUT hook) vs "Choose your Path" (game, Oct 19). **Path**: the
    user's terminology; "element" is retired in player text.
34. **Gatekeepers vs envoys**: "corrupted envoys at the gates" (old bible) vs **gatekeepers at road obstacles** (Oct 16 hub brief).
35. **The Grand Chef's name**: "Grand Chef Escoffina" (old) vs **the Grand Chef** (she gave the name to the Doppelganger, now Escoffina);
    card G-33 keeps the old name (frozen card list, open).
36. **The Necrocrat leader**: Mortimer as the freed leader (old build) vs **Agnes** as leader and Mortimer as the boss (v2, sheet); card N-33
    keeps Mortimer's name (open).
