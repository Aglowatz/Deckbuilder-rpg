# Story Bible

Organized from `story_source_v2.md` (the designer-approved source of truth; where it conflicts with
`story_source.md` or older content, v2 wins). Canonical names, roles and dungeon node layouts also
live in `data/source/npc_list.csv.csv` and `data/source/dungeon_list.csv.csv`.

All dialogue, signs and story text live in the story data files (`data/story/*.tres`,
`core/data/story_text.gd` / `zone_story_text.gd` defaults), never in scene scripts. Names that may
still change live in ONE data location each and appear in text as tokens:

| Data file | Tokens |
|---|---|
| `data/story/villain.tres` | `{villain}` (Primm), `{villain_title}` (His Perfection) |
| `data/story/royal_family.tres` | `{prince}` (Tessar), `{prince_full}`, `{royal_house}` (Wayweaver), `{king}`, `{queen}`, `{rescuer}` (placeholder "The Rescuer"), `{kingdom}` (Pathavia), `{town}` (Crosspath), `{capital}` (Primm's Perfection, then Pathordia), `{showcase}` |

`Villain.fill` swaps every token in when text is read. The prince's name only shows in dialogue after
the reveal (see the memory fragments below).

## Theme and tone

One way for everyone breaks a kingdom; many ways, held together, make it whole. Primm demands
sameness; the royal bloodline's gift is wielding all four Paths at once, as they are. The tone is
comedic on the surface and serious underneath: every joke has a cost the player can see, and the jokes
get quieter the closer the player gets to Primm.

## The Kingdom of Pathavia (before)

**Pathavia** ran on four **Paths**, each providing a vital service. They argued constantly and needed
each other anyway.

| Path (faction) | Vital service | Home zone | Rival |
|---|---|---|---|
| **Beefcakes** | **Energy and transportation**: mills, giant hamster wheels, throwing people, ripping open portals | The Gainlands | Necrocrats (chaos vs. by-the-book) |
| **Gourmands** | **Food and protection**: feeding the kingdom, food golems to guard it ("Yes, Chef!") | The Endless Buffet | Refusemancers (snooty vs. "garbage eaters") |
| **Necrocrats** | **Death administration**: the dead, the afterlife and its labour, all properly filed | The Department of Necrotic Affairs (D.N.A.) | Beefcakes |
| **Refusemancers** | **Waste removal and agriculture**: animals that eat the garbage, fertilizer, magic that grows crops | The Verdant Dump | Gourmands |

The hub where the four Paths met, traded and argued is the town of **Crosspath**.

**The Pathwork Throne** sits in the Capital, where the four Paths meet. Whoever sits on it is
connected to all four, and the ruler's character flows out through them into the land.

**The royal bloodline** can wield all four Paths at once; that is why the throne worked under them.
**House Wayweaver** weaves the four Paths together without forcing them into one. **King Harmon
Wayweaver** was gentle and patient and let each Path be itself. **Queen Concordia Wayweaver** was
clever, musical and fierce; hers is the lullaby the prince remembers first, and she died shielding him.
Their son is **Prince Tessar Wayweaver**, named for the tesserae of a mosaic.

**The royal crest** (the four Path symbols in a ring) appears without explanation: Elder Maren's
walking stick, the Forgotten Vault's Old Kingdom banner, the Vault Guardian's four-coloured core, the
fountain in the middle of Crosspath. Each is a quiet clue.

## Ten years ago: Primm

**Primm, "His Perfection"**, was the Royal Minister of Improvements: arrogant, selfish, extremely
bright and sincere. He believed the kingdom would be better under his rule and saw it as his duty to
improve it by any means. He **killed King Harmon and Queen Concordia** and took the Pathwork Throne. He
spared their son because he wanted the power in the royal bloodline for himself.

Sitting on the throne connected Primm to all four Paths, and his darker traits poured through them.
Each faction's corruption is one of his flaws turned into policy:

| Path | What happened | Primm's flaw behind it | The ruler now |
|---|---|---|---|
| Beefcakes | A coup; the leader imprisoned; a regime | Strength means control | **Chancellor Clench, Iron Regent**; the true leader is **Grandmaster Flex, the Unbroken** |
| Gourmands | A doppelganger replaced the leader; corrupted food; kitchens turned into a weapons factory | Appearance over substance | **The Doppelganger** wearing Grand Chef Escoffina's face |
| Necrocrats | Authority transferred by perfectly valid paperwork, enforced by the CE-No | Legal means right | **Mortimer Grimsby, CE-No** ("Yes, but the authorization is valid.") |
| Refusemancers | The leader corrupted through nature itself; growth that will not stop | Fear of anything he cannot control | **Compostella, the Rotheart** |

**The Path-ologists** are the kingdom's scientists of the Paths. **Elder Maren** founded the field and
led it before the coup. Under Primm, and under a new Chief Path-ologist (**Dr. Ambrose Siphon**, her
former protege), they spent ten years in a hidden lab in the forest (the **Path-ology Lab**), running
the prince through grueling tests to extract his innate power.

**The stolen power.** Primm has no royal blood, so his hold on the throne depends on power drained from
the prince. When the prince escaped, the hold started to slip: that is why the zones can be freed now,
why rifts tear open in the Capital, and why his "Reflection" phase can only copy.

**Why he is tragic.** He was always sincere and truly brilliant. His early reforms really helped (clean
wells, standard measures, school lunches) and some of his complaints about the old kingdom were valid.
He cannot see that every improvement made the kingdom more like him.

## The Wanderer: the lost prince

The Wanderer is **Prince Tessar Wayweaver**, eleven at the coup and twenty-one now, presumed dead.
Ten years in the Path-ology Lab plus the corruption flowing from the throne left him weak and amnesiac.
A Path-ologist who defected (**the Rescuer**, placeholder name, `NPC-RESCUER`) smuggled him out. In game
he is "The Wanderer" until his identity is revealed; afterwards the speaker plate and dialogue use
`{prince}`.

**Power returns as the land heals** (this IS the deck-building progression):

| Point in the story | Paths he can wield |
|---|---|
| Start of game | One (the starting deck he chooses) |
| After his first freed zone | Two at once |
| After defeating Primm and taking the throne | All of them (3+ Path decks) |

**Memory returns zone by zone** (by the NUMBER of zones freed, not which zone), in a talk with Elder Maren:

1. **Warmth.** Four-coloured light, a woman humming, a hand on his head. Maren goes quiet: it is a lullaby from the old days. The second Path unlocks.
2. **The cells.** White rooms, glass, people in coats who call him "the Subject." He realizes he was a prisoner. Maren admits the resistance.
3. **The coup.** A throne room at night, a man in white and gold kneeling to the king, then standing. He knows the face: Primm. Maren admits she founded the study of the Paths and helped build that lab.
4. **His name.** He is the royal prince. Maren recognizes the boy she once met at court and understands what her lab was used for. If he fights Primm first, Primm tells him instead.
5. **On the Pathwork Throne: everything.** Full memory and full power.

**What each zone teaches him:** Gainlands: strength comes from the heart and mind. Endless Buffet: what you are called does not matter, what you do does. D.N.A.: everyone deserves humanity, even the dead. Verdant Dump: death is not the end; to grow, you have to let things go.

**Elder Maren** is a female tortoise (she/her): the town elder, the resistance's contact in Crosspath,
founder of Path-ology. Guarded and kind, cryptic, full of pie, slow to trust at first. Her default
dialogue changes by stage: guarded at first; admits the resistance at memory 2; admits her Path-ologist
past at memory 3; recognizes the prince at memory 4.

## Prologue: the forest and the Forgotten Cave

1. **Waking.** The Wanderer wakes in a small forest outside Crosspath. A hooded stranger, the Rescuer (NOT Elder Maren), kneels beside him.
2. **"Can you still fight?"** The Rescuer notes how weak he is and asks which Path he walked the most. **The starting deck is chosen here.**
3. **Sent on.** The Rescuer points him to the Forgotten Cave ("the town is on the other side") and slips back into the trees. Wandering off gets a self-talk line and a gentle turn back.
4. **The Forgotten Cave** (was Trial of the Hollow; a passage, not a trial): the tutorial dungeon, ending with the Hollow Warden. No Beefcake or Necrocrat infrastructure or Resources appear in it.
5. **Elder Maren** waits at the cave mouth, slow to trust ("he could be a spy"), kind and cryptic.

**The cave's secret.** It is an old royal escape tunnel and the Hollow Warden is an Old Kingdom guardian
that only lets the royal bloodline pass; at the start it just grumbles that he "smells familiar." The
**Path-ology Lab's hidden entrance** is in the same forest (inaccessible until the postgame).

## Factions in detail

### Gourmands - The Endless Buffet / The Test Kitchen
- **The situation.** The Buffet looks like a thriving centre of culinary invention and is really a military-industrial complex. A doppelganger wearing Grand Chef Escoffina's face uses enchanted, corrupted food to bend the chefs; the food golems that once protected the kingdom are rebuilt as war machines.
- **Beats.** Chef Fennel Gravois (town gate, force-feeding for "the war effort"); cheerful "innovation" signage and golem guards; Basil's suspicion ("Chef ALWAYS tastes her sauces. This one never does."); the Test Kitchen and the R&D Archives (proof of the swap); the Grand Kitchen, where the Doppelganger fights in Escoffina's face until the disguise peels into a faceless, shifting shape.
- **After the boss.** The true chef is found in the deep freezer ("on ice" for ten years) and returns to her kitchen. She bakes a wonder-filled dish that breaks the enchantment (corrupted signage and NPCs visibly restore). Then she gives her name to the Doppelganger: "What you're called doesn't matter. It's what you do that matters." She is **The Grand Chef** in UI; the former Doppelganger is **Escoffina**, an apprentice who stays in the kitchen learning to cook honestly.
- **Freed state.** War machines melted into ovens, golems back to guarding pantries.

### Beefcakes - The Gainlands / The House of Gains
- **The situation.** Chancellor Clench, Iron Regent, runs the Gainlands for Primm like a bureaucracy of muscle: Beefcakes on endless wheels, transport only where the regime approves. Grandmaster Flex rots in the Iron-less Prison beneath the House of Gains.
- **Beats.** Brick Bronson (town gate, "only iron matters"); regime posters and wheels that never stop; the House of Gains; the **Iron-less Prison** (node 9, optional branch via Stairs Down, node 7): Flex looks frail and ancient, meditating. He spent ten years with nothing but calisthenics, yoga and breath. At the Throne of Gains he throws off his robes: "They took my weights. They forgot to take me." Afterwards: "Whatever they took from you, son, it wasn't the part that matters."
- **Clench** was Flex's star pupil, who never believed he was strong without the iron. Primm offered him control. Flex beats him by refusing to hate him, and offers to train him again from zero. If Flex was not rescued, he walks out of the prison on his own after the boss ("I was going to leave eventually. Lovely day for it.").
- **Freed state.** Wheels at a healthy pace, transport runs, Flex opens the gym to everyone.

### Necrocrats - The D.N.A. / The Hall of Final Approvals
- **The situation.** Authority over the Necrocrats was transferred to Primm through a process that was submitted, reviewed, approved, notarized and filed. It is valid, so they obey. **Mortimer Grimsby, CE-No** runs the Department for Primm.
- **Beats.** Prudence Pallor (town gate, stamping DENIED); permits to stand, forms for forms; Gerald, Number 4,000,212; **Agnes Overdue**, a sweet, exasperated ghost whose every appeal is denied, guides the player into the Hall with her stack and turns up at several nodes. The Records Labyrinth holds the original transfer document (flawless; the royal heir is listed "Deceased (presumed). Remains: not on file." and Agnes frowns: "Irregular."). **Undersecretary Vellum**, Mortimer's deputy, defends it as the Appeals Court elite. **Mortimer** is the boss at the Office of Final Approval.
- **The vacancy.** With the CE-No removed, policy passes the office to the senior-most applicant on file: Agnes, who has filed more appeals than anyone alive or dead. She stays to fix the system first: "Even the dead deserve humanity. Our job is to help the lost souls. Following orders be damned. We treat everyone with respect."
- **Freed state.** Queue machines stop, Gerald's number is finally called, Agnes reorganizes the Department around one rule (help people), Prudence Pallor is her deputy, and Mortimer takes a number in the Waiting Room of Eternity right behind Gerald.

### Refusemancers - The Verdant Dump / The Rotheart
- **The situation.** Archdruid Compostella was corrupted through her own bond with nature. The Dump is unnaturally alive: plants that never stop growing, mutated fungi, roots splitting machinery. Nothing rots, so nothing feeds the soil, so everything chokes.
- **Beats.** Moss Mulligan (town gate); junkyard-farm comedy (smug raccoons, goats that eat the signs) turning into overgrowth that is wrong; Brother Bramble notices first; at the Heart Roots the player severs the tendrils feeding the corruption; **Compostella, the Rotheart** speaks in the many voices of the hungry green.
- **Why her bond turned.** After a great loss (the ancient tree she grew up beneath), Primm brought her a seed engineered by the Path-ologists: life that never dies. In her grief she planted it (the Corrupted Seed whose records sit in the Castle's Refusemancer wing). The cure is to let it finally die: "Everything I ever loved, I gave back to the soil. Except this one. I couldn't."
- **To the Wanderer:** "You're carrying a loss you can't name yet. When you find its name, don't bury it in a jar. Death isn't the end of them. Let it be the start of something in you."
- **Freed state.** Overgrowth recedes, the Dump smells like honest compost, the raccoons are put on trial.

## Zone buffs and debuffs (Part C)

Every zone **and its dungeon** carries one zone-wide **buff** for its own Path's cards and one
**debuff** for its rival Path's cards, applied to *both the player's and the enemy's* cards of
that Path through the Modifier pipeline (`ZoneEffects`). The Test Kitchen counts as the Endless
Buffet, and so on. Zone completion does not remove the effect (the rivalry is the world's
physics, not the ruler's); it is shown in the HUD and in battle.

| Zone | Buff (own Path) | Debuff (rival Path) |
|---|---|---|
| Gainlands (Beefcake) | **Pump It Up** - Beefcake creatures +1 power. | **Processing Time** - Necrocrat creatures enter exhausted ("your request is being processed"). |
| D.N.A. (Necrocrat) | **Approved Procedure** - Necrocrat creatures +1 toughness. | **Unauthorized Activity** - Beefcake cards cost 1 more (permit fee). |
| Endless Buffet (Gourmand) | **Well Fed** - Gourmand creatures +1/+1. | **Dress Code Violation** - Refusemancer creatures -1 power. |
| Verdant Dump (Refusemancer) | **Overgrowth** - Refusemancer creatures +0/+2. | **Spoilage** - Gourmand creatures -1 toughness. |

## The main town: Crosspath

The hub. A central plaza with the royal-crest fountain, shop-lined market streets (Sable, Tilly Tonic,
Bertram Beetsworth, Pip Threadwell, Foil Fenwick, Auntie Alembic, the deck station, Elder Maren's home
and the notice board), **The Grand Clashatorium** (the Arena, a colosseum landmark at the edge of the
centre) and roads out to the four **Path gates** (each guarded by a corrupted envoy who must be beaten
once), the Capital and the tutorial cave exit. The Arena opens after **1 completed zone**, the Alchemist
after **2**. As zones are freed, the town fills with cheering and returning citizens.

## The Alchemist: Auntie Alembic

A crafting vendor for **multi-Path** cards. Extra copies (beyond 4) of any card turn into Path
**essence**; trade ALL essence of two Paths plus gold for a random dual-Path card of those two
Paths. Tri-Path crafting unlocks after the main boss (`postgame_unlocked`) - hook only, no tri/quad cards yet.

## The Arena: The Grand Clashatorium

A big colosseum-like building in Crosspath. Fight challenging and puzzling encounters to earn exclusive
equipment and other prizes.

## Beats in order (player's journey)

1. Wake in the forest -> the Rescuer and the starting deck choice -> the Forgotten Cave -> Elder Maren at the cave mouth -> Crosspath.
2. Beat the four envoys to open the four Path gates; each envoy hints at their faction's plight.
3. Explore a zone, learn what the ruler has done to it, clear side dungeons and quests.
4. Enter the zone's final dungeon, beat the ruler, and **complete the zone**: lighting, freed NPCs, new dialogue, signage changed. Talk to Maren for the next memory.
5. First zone complete: the Arena opens, the second Path unlocks. Second: the Alchemist opens.
6. The Capital (reachable from the start), Primm's Castle and Primm himself.
7. Postgame: Rip's forest portal and the Path-ology Lab.

---

# Part 10: Primm, the Capital and the Castle (the final act)

**Primm's name and title live in `data/story/villain.tres`.** Place and royal names live in
`data/story/royal_family.tres` (tokens in the table at the top).

## The villain: Primm, "His Perfection"

**What he believes.** If everyone just did things *his* way, the world would be perfect. A difference is
a *defect*, an inefficiency, a smudge. He is **tragic**, not cackling: he sincerely believes he is working
for the people, and every decree he writes begins with *"for their own good."* He is also deeply
**narcissistic and controlling**: his "perfect" world is the world as *he* finds comfortable (mirrors that
reflect only him, portraits that "improve" him, a facade district that exists to be admired).

**His title.** He insists on **"His Perfection"** (and gets visibly upset, in a very small way, when it is forgotten).

## The Capital: Primm's Perfection (Pathordia after his fall)

Primm renamed the Capital after himself. After his fall it is **Pathordia** (`RoyalFamily.capital_name()`).
Reached from the start of the game through the town's **final-area entrance** (`ZonePortals` id `final`).
Zone id `final`. Same shared zone framework as the four path zones, larger than any of them, with minimap
and fog of war. At 0 life you wake at the hideout (or, if you never got past the gate, at the camp
outside) and pay the "Correction fee" (20 gold).

| Area | What it is |
|---|---|
| **The Outskirts** (south) | The approach to the city: cracked road, abandoned checkpoints, dead lamps, early **rifts**, "approved queue" markers. The only place with the road back to town. A hidden **secret entrance** (forgotten service tunnels the four Paths once built together) is found only by exploring here. |
| **The Approved Gate** | The only way in: a checkpoint run by **Primm's gate guards**. Entry needs a **challenging card battle** against **Captain Spotless**, after absurd entry requirements ("visitors must be of approved height"). |
| **The Showcase Quarter** (centre) | A small, **eerily perfect facade district**: identical spotless houses, regulation lawns, citizens in matching clothes with fixed smiles, loudspeakers, portraits and statues of Primm, decree signs. Up close it is **hollow**: painted storefronts, doors that do not open, citizens who repeat approved phrases and then slip up with a whispered "help." |
| **The four broken districts** | Outside the facade the city is **corrupted and coming apart**, torn by rifts that exist because Primm's forced connection to the Paths has been failing since the prince escaped. One district per Path: **the Transit Yards** (Beefcake), **the Hungry Quarter** (Gourmand), **Grave Row** (Necrocrat) and **the Reek** (Refusemancer). |
| **The Correction Ward** (north-east) | Where citizens who "smiled incorrectly" are sent to be improved. |
| **The Crease** (hub) | A hidden **resistance hideout** in the old service tunnels: safe, a heal spot (*Tea of Dissent*), **Fig Sly's** black market and the resistance NPCs. |
| **The Castle Approach** (north) | The Avenue of Portraits and the doors of **Primm's Castle**. |

**The hunt.** Enforcers search for an "escaped Royal Asset"; posters read like lost-property notices
("Have you seen this Improvement Opportunity?"). Funny at first, chilling after the fourth memory. They
are defaceable like the other propaganda.

**The resistance.** **Wren** leads it from the Crease (once Royal Archivist, keeper of the true records),
with **Fig Sly** (black market), **Nurse Hesper Dray** (the Tea of Dissent) and the four quest givers.
**Elder Maren** is its contact in Crosspath and has been quietly turning Path-ologists inside the lab;
the Rescuer is one of them.

**The secret entrance.** *The Old Service Tunnels* (found through **Kestrel's** quest): service tunnels
the four Paths built together (Beefcake-dug bore, Gourmand ventilation, Necrocrat signage, Refusemancer
drainage). The old harmony, literally underneath Primm's city. Leads straight into the Crease, sneaking
the player **past the gate**. Listed in `docs/design/secrets.md`.

### Rifts

Dangerous magical **rifts** tear through the zone: glowing tears in reality that **damage the player on
contact**, distort the area around them and **spawn or empower corrupted enemies** (*Rift Wretches*,
*Shard Swarms*). Some can be **sealed** for rewards; the big rifts stay open until Primm falls. Rift
dialogue explains Primm's failing hold.

### The four broken services (zone debuffs)

While a Path's zone is **not yet completed**, the Capital suffers that Path's *broken service* as a
debuff. Each completed zone **removes its debuff** and shows a visible change.

| Path | Broken service | Debuff while its zone is not free | Visible change when freed |
|---|---|---|---|
| Beefcakes | Energy and transport | **Blackout:** darkness, slower movement, **no travel**; your creatures enter exhausted | the lights come back on, the tunnel network opens |
| Gourmands | Food and protection | **Famine:** reduced max life (-5), healing food **does not work** | food stalls reopen with lanterns and steam |
| Necrocrats | Death administration | **Restless Dead:** enemy creatures sometimes return from the graveyard (35%) | the cemetery is calm, the paperwork loop ends |
| Refusemancers | Waste removal and agriculture | **Clutter:** 3 *Heap of Rubbish* shuffled into your deck per duel | the heaps shrink, flowers grow in the Reek |

### Primm's enforcers and corrupted creatures

*Slow battle-starters:* **Compliance Officer**, **Perfection Inspector**. *Fast damage type:* **Tidy-Bot**.
*Rift-spawned:* **Rift Wretch** and **Shard Swarm**. The gate has **Gate Guards** and **Captain Spotless**.

### Interactables (real effects)

*Deface propaganda* (small gold reward, once per poster); *seal a rift*; *the Anonymous Complaint Box*;
the *Exit Interview* booth; the tunnel *Service Network* (fast travel between districts, down while the
Beefcake service is broken).

### The four Path quests (serious story beats, funny on the surface)

One per Path, given by a citizen who shows what Primm's rule cost that Path's people. Each pays gold,
XP, a card or item, and a **story insight** into Primm.

| Path | Quest | Giver | The weight under the joke |
|---|---|---|---|
| Necrocrats | **Form 27-B/6: A Burial Permit** | **Widow Pell** | Her husband has sat in the parlor for three years. The permit office loops forever. You find the stamp, then lay him to rest. *Insight: he scheduled grief for Thursdays.* |
| Beefcakes | **The Wheel Never Stops** | **Rollo Spokes** | Workers run endless energy wheels to power the facade's lights ("cardio"). Free the wheel crews. *Insight: he made lateness illegal.* |
| Gourmands | **The Recipe Box** | **Chef Marlo** | Everyone is fed *Primm's Perfect Nutrient Paste*. Recover three recipe cards and spoil the dispenser. *Insight: he cannot taste food; he never could.* |
| Refusemancers | **Untidy** | **Old Fern** | Composting is outlawed as "untidy." Rescue three banished compost heaps and plant the old seed. *Insight: he fears anything that grows without asking him.* |

## Primm's Castle (the final dungeon)

On the node-map system (`DungeonMap`): **25+ nodes**, heavy branching, dead-end side branches that double
back (`MapNode.return_to`). Sections: the **Portrait Gallery**, the **Ministry of Correction**, the **Hall
of Mirrors**, a wing for each Path (the *Doppelganger's Lab Notes*, the *Coup Orders*, the *Notarized
Paperwork*, the *Corrupted Seed*), the **Correction Ward**, the **Archive of Good Intentions** and the
**Model Room**. Story beats:

- **Primm's Private Gallery:** the royal family portrait, the king and queen painted over in white. Only the boy's face is left, "kept for reference."
- **The Path-ologists' records:** notes on "the Subject" reveal what was done to the prince and how the stolen power holds Primm on the throne. Some of the oldest notes are in Maren's handwriting.
- **The Archive of Good Intentions:** Primm's early journals, sincere and helpful, sliding entry by entry into control.

## The final boss: Primm (three phases)

An **extremely challenging** multi-phase duel (balance out of scope): separate duels back to back on the
same boss node, life carrying over, dialogue between phases.

1. **Standardization** - everyone forced into the same shape: every creature has the **same stats (3/3)** and at most **two non-infrastructure cards per turn**.
2. **Reflection** - he **copies the player's cards**. "Everything you can do, I can do. I've had ten years of practice with it." His power is literally the prince's.
3. **Unraveling** - his rules break, the arena cracks, the selfishness under the sincerity shows.

**Freed leaders lend a boon** for every completed zone: Grandmaster Flex, the Grand Chef, Agnes Overdue and
Archdruid Compostella (`PrimmBoss.boons`).

**If fewer than four zones are completed,** the Wanderer does not know who he is yet, so Primm tells him:
"You don't even know, do you? I kept your face." (sets a flag; Maren's memory 4 scene adapts).

His answer to Primm draws on the four lessons: strength is not control, a name is not a self, no order
outranks treating people with respect, and nothing grows if you refuse to let anything go.

## Victory, ending and postgame

1. **The Pathwork Throne.** Primm falls; the prince takes his place and the throne answers to the true bloodline. His memory and power return in full.
2. **The kingdom heals.** The facade crumbles, the rifts close, the Paths reconnect. Primm's Perfection is renamed **Pathordia**.
3. **Primm sees it.** As balance returns he finally sees the kingdom as it is rather than as his reflection and understands how much damage he caused.
4. **The reunion.** The freed leaders gather. Agnes stamps the transfer file "HEIR: ALIVE. FILE COMPLETE." Maren calls him Tessar.
5. **The unlock.** He can wield every Path at once: 3+ Path decks (`postgame_unlocked`), plus the tri-Path crafting hook at the Alchemist.
6. **Return to the world.** Pathordia is changed, citizens are free, and the postgame continues.

**Primm's fate.** The prince does not kill him: Primm made one choice for everyone and the prince makes a
different one. Primm serves the kingdom on infrastructure and technology, under permanent arrest in a
locked workshop, kept away from all Path workings. Brilliant, sincere and never again in charge.

**Postgame: the Path-ology Lab.** After Primm's defeat Rip Tearson mentions he was exploring the forest
where it all started and has opened a portal station there. Near where the Wanderer woke is the hidden
lab entrance. The Lab is a 12-16 node postgame dungeon of extremely challenging encounters (failed
experiments, Path-ologist guards, the draining chamber), with the prince's old cell (ten years of tally
marks, a child's drawing of four colours), the captured **Rescuer** (the dungeon's heart) and the boss,
**Dr. Ambrose Siphon, Chief Path-ologist**.

## Still open

The rescuer's name; leader cards (Mortimer's legendary card, the Grand Chef's card name); when Agnes
finally passes on; the Lab's final layout and effects. See `open_questions.md` "Story v2".
