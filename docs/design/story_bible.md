# Story Bible

Organized from `story_source.md` (the designer-authored source of truth; where it conflicts with
older docs or content, it wins). Every **placeholder name** here is logged in
`open_questions.md` (section M) so it can be renamed later in one place.

All dialogue, signs and story text live in the story data files (`data/story/*.tres`,
`core/data/story_text.gd` / `zone_story_text.gd` defaults), never in scene scripts.

## The Kingdom of Concordia (before)

The Kingdom of **Concordia** (placeholder name) lived in harmony. Four powerful factions - the
**Paths** - each provided a vital service and together kept the kingdom running:

| Path (faction) | Vital service | Home zone |
|---|---|---|
| **Beefcakes** | **Energy and transportation** - pushing mills, running giant hamster wheels, throwing people across distances, physically ripping open portals | The Gainlands |
| **Gourmands** | **Food and protection** - feeding the kingdom, and cooking food golems to guard it ("Yes, Chef!") | The Endless Buffet |
| **Necrocrats** | **Death administration** - the dead, the afterlife and its labour, all properly filed | The Department of Necrotic Affairs (D.N.A.) |
| **Refusemancers** | **Waste removal and agriculture** - animals that eat the garbage, fertilizer, magic that grows crops | The Verdant Dump |

They worked together to build a thriving world. The hub where the four Paths met, traded and
argued is the town of **Concord Crossing** (placeholder name).

Rivalries (they still need each other; they just don't like it):
- **Beefcakes vs. Necrocrats.** Chaotic, "there-ish, on-time-ish" muscle versus orderly, by-the-book
  paperwork.
- **Gourmands vs. Refusemancers.** Snooty and proper versus "garbage eaters" (and the Refusemancers
  think the Gourmands are far too fancy about food that ends up in their heap anyway).

## Ten years ago: Primm

Ten years ago **Primm**, who insists on the title **"His Perfection"** (name and title live in `data/story/villain.tres`; story text uses the tokens `{villain}` and `{villain_title}`), took over, and somehow
took over or corrupted each of the four factions. Each Path now lives under an oppressive ruler
who answers to Primm, and the people of each zone suffer. The player - who wakes up in a cave
with no memory in the Trial of the Hollow - must **free each zone** by beating its dungeon boss.
Primm's methods differ per faction:

| Faction | How Primm got them | The ruler now |
|---|---|---|
| Gourmands | A **doppelgänger** replaced the leader. Corrupted, magically tainted food steers the Gourmands' love of food, invention and feeding others against them. | **The False Aurelio** (the impostor wearing Grand Chef Aurelio Saucier's face) |
| Beefcakes | The leader was **violently overthrown** and imprisoned; the regime holds the zone. | **Commander Gristle**, regime commander; the true leader is **Grand Champion Thaddeus "Grandmaster Flex" Brawn** |
| Necrocrats | **Paperwork.** Authority was transferred to Primm by a fully valid, notarized, filed process. The Necrocrats are not evil, just obligated: "Yes, but the authorization is valid." | **The Registrar of Final Approvals** |
| Refusemancers | The leader was **corrupted through nature itself**; the infection spread through the magical ecosystem. | **Archdruid Fernwick Loam, the Rotheart Archdruid** |

## Factions in detail

### Gourmands - The Endless Buffet / The Test Kitchen
- **The corruption.** The leader has been secretly replaced by a doppelgänger who keeps the original's
  appearance and authority, and has gradually turned the Endless Buffet into a massive R&D
  operation. Magically corrupted food (the "Special Sauce") bends the Gourmands' natural love of
  food, invention and feeding others. Beneath the surface they are forced to build enormous
  food-powered war machines and magical technology for Primm.
- **Zone state (oppressed).** It looks like a thriving centre of culinary innovation: signs for
  "Innovation Seasons", prototype tastings, ever-present "taste testers" (guards). Underneath, it is a
  military-industrial complex: golem gates, "Sample Collection" notices, chefs exhausted and afraid
  to say the word "weapon". Freed: the golems relax ("Yes, Chef!" again, about food), signage returns to menus.
- **Dungeon: The Test Kitchen.** Experimental kitchen + food laboratory + ridiculous weapons-development
  centre. Increasingly dangerous prototypes, corrupted ingredients, experimental food constructs,
  enormous unfinished war machines. **Boss: The False Aurelio**, with a **reveal moment** (the leader's face
  slides off).
- **Leader.** Real: Grand Chef Aurelio Saucier (freed in the zone's completed state). Impostor: the doppelgänger.
- **Corrupted path NPC (town):** Maris the Over-Seasoned, a Gourmand envoy force-fed the Special Sauce.

### Beefcakes - The Gainlands / The House of Gains
- **The corruption.** The original leader, Thaddeus "Grandmaster Flex" Brawn, was violently overthrown by Primm's forces and
  imprisoned beneath the House of Gains. His captors deprived him of everything they believed
  made a Beefcake strong - weights, protein, gym equipment, conventional training - assuming he
  would grow weak and broken. Instead he turned to **calisthenics, yoga, stretching, meditation and mental
  discipline**, and became stronger.
- **Zone state (oppressed).** A regime controls the zone: "Mandatory Cardio Compliance", confiscated
  weights, wheels that never stop turning, propaganda posters of Commander Gristle. Freed: weights come
  back, posters are replaced by the rightful leader's poster, the wheels turn at a healthy pace.
- **Dungeon: The House of Gains.** The stronghold of the regime. A major section is the **Iron-less
  Prison**: the player descends, finds the leader *emaciated and decrepit*, rescues him, and he
  **joins the party as a dungeon-wide boon** for the rest of the run. At the final confrontation he throws off his
  outer clothing to reveal he is **still incredibly muscular**, and explains: *true strength comes
  from the heart and the mind* - the villain took away everything he thought created strength and
  left him the chance to find a deeper kind. **Boss: Commander Gristle**, the current ruler.
- **Corrupted path NPC (town):** Torvin the Over-Pumped, a Beefcake envoy stuck on the regime's mandatory pre-workout.

### Necrocrats - The Department of Necrotic Affairs / The Hall of Final Approvals
- **The corruption.** They are not inherently good or evil; they simply believe death should be
  administered according to policy. Primm exploited that rather than corrupting them: through a
  completely legitimate process the paperwork was submitted, reviewed, approved, notarized and
  filed, transferring authority over the Necrocrat government. The paperwork is valid, so they are
  legally obligated to obey. Even when the heroes point out Primm is clearly evil and causing
  immense suffering: **"Yes, but the authorization is valid."**
- **Zone state (oppressed).** Absurdly bureaucratic oppression: permits to stand, forms for forms,
  queue-numbers for the queue, citizens trapped under endless rules that the Necrocrats dutifully
  enforce because policy says so. Freed (the authorization is *revoked on a technicality*): the
  queue-number machines stop, the "Under Review" banners come down.
- **Dungeon: The Hall of Final Approvals.** The ultimate bureaucratic nightmare - a massive
  government complex where every aspect of life, death, resurrection and the afterlife requires
  authorization. Absurd departments, paperwork, waiting rooms, regulations and undead bureaucrats;
  nodes include "take a number" waits and forms that require other forms. **Boss: The Registrar of
  Final Approvals**, the authority that now controls the Necrocrats.
- **Corrupted path NPC (town):** Corwyn the Filed-Away, a clerk stuck "Pending" in the new regime's backlog.

### Refusemancers - The Verdant Dump / The Rotheart
- **The corruption.** Refusemancers have an extraordinarily powerful magical connection to nature
  and the living world; their civilization is built on decay, regeneration, recycling,
  agriculture and transformation. Primm discovered the connection could be turned against them.
  Their leader became corrupted **through nature itself**, and the corruption spread through the magical
  ecosystem.
- **Zone state (oppressed).** The natural world is not simply dying; it is **unnaturally alive and
  twisted**: plants grow uncontrollably, fungi mutate, roots invade structures, the cycles of
  life, death and regeneration are distorted. The ecosystem the residents depend on has turned
  hostile and diseased. Freed: the overgrowth recedes, the glowing spores fade, the heap
  smells like honest compost again.
- **Dungeon: The Rotheart.** Deep in the corrupted ecosystem, at the source of the infection. The
  deeper the heroes go, the more warped the Verdant Dump's usually vibrant nature becomes. At the
  core, the **Rotheart** links the leader to the larger ecosystem. **Boss: Archdruid Fernwick Loam, the Rotheart
  Archdruid**; defeating them **severs Primm's influence over the natural world**.
- **Corrupted path NPC (town):** Old Thistlebark the Over-Composted, a druid who stopped fighting the compost.

## Zone buffs and debuffs (Part C)

Every zone **and its dungeon** carries one zone-wide **buff** for its own Path's cards and one
**debuff** for its rival Path's cards, applied to *both the player's and the enemy's* cards of
that Path through the Modifier pipeline (`ZoneEffects`). The Test Kitchen counts as the Endless
Buffet, and so on. Zone completion (Part D) does not remove the effect (the rivalry is the world's
physics, not the ruler's); it is shown in the HUD and in battle.

| Zone | Buff (own Path) | Debuff (rival Path) |
|---|---|---|
| Gainlands (Beefcake) | **Pump It Up** - Beefcake creatures +1 power. | **Processing Time** - Necrocrat creatures enter exhausted ("your request is being processed"). |
| D.N.A. (Necrocrat) | **Approved Procedure** - Necrocrat creatures +1 toughness. | **Unauthorized Activity** - Beefcake cards cost 1 more (permit fee). |
| Endless Buffet (Gourmand) | **Well Fed** - Gourmand creatures +1/+1. | **Dress Code Violation** - Refusemancer creatures -1 power. |
| Verdant Dump (Refusemancer) | **Overgrowth** - Refusemancer creatures +0/+2. | **Spoilage** - Gourmand creatures -1 toughness. |

## The main town: Concord Crossing

The hub. Contains the four **Path gates** (each guarded by a corrupted envoy who must be beaten
once to open the road), the vendors, the deck builder, the Codex, **The Alchemist** (unlocked
after **2 zones are completed**), and **The Grand Clashatorium** (the Arena, a colosseum-like
building, unlocked after **1 zone is completed**). As zones are freed, the town fills with
cheering and returning citizens.

## The Alchemist: Zinnia Vex, Crucible & Co.

A crafting vendor for **multi-Path** cards. Extra copies (beyond 4) of any card turn into Path
**essence**; trade ALL essence of two Paths plus gold for a random dual-Path card of those two
Paths. Tri-Path crafting unlocks after the main boss (`postgame_unlocked`) - hook only, no tri/quad cards yet.

## The Arena: The Grand Clashatorium

A big colosseum-like building in Concord Crossing. Fight challenging and puzzling encounters to
earn exclusive equipment and other prizes.

## Beats in order (player's journey)

1. Wake in a cave (no memory) -> the Trial of the Hollow (tutorial) -> Concord Crossing.
2. Beat the four envoys to open the four Path gates; each envoy hints at their faction's plight.
3. Explore a zone, learn what the ruler has done to it, clear mini dungeons and quests.
4. Enter the zone's final dungeon, beat the ruler, and **complete the zone**: lighting, freed NPCs,
   new dialogue, signage changed, the ruler's presence gone.
5. First zone complete: the Arena opens. Second: the Alchemist opens.
6. All four free (or not - the Capital is reachable from the start, see below): the Capital, Primm's Castle and Primm himself.

---

# Part 10: Primm, the Capital and the Castle (the final act)

All names below are placeholders in the same spirit as the rest of the bible and are logged in
`open_questions.md` (section N). **Primm's name and title live in `data/story/villain.tres`** and appear in
story text as the tokens `{villain}` / `{villain_title}`; renaming him is a one-line edit.

## The villain: Primm, "His Perfection"

**Who he is.** Primm was the Royal Minister of Improvements of Concordia: a tidy, brilliant, restless
planner who really did make things better at first (see the Archive of Good Intentions: standard weights
and measures, clean wells, signposts, free school lunches). He was also always driven by something he never
looked at: he needed to be *right*, and he needed to be *admired*. Ten years ago he "accepted the burden of
the throne" (the old monarch retired, into an excellent portrait) and began perfecting the kingdom.

**What he believes.** If everyone just did things *his* way, the world would be perfect. He does not
account for, or appreciate, different people, values or thoughts: a difference is a *defect*, an
inefficiency, a smudge. He is **tragic**, not cackling: he sincerely believes he is working for the people,
and every decree he writes begins with *"for their own good"*. He is also deeply **narcissistic and
controlling**: his "perfect" world is simply the world as *he* finds comfortable. The kingdom's corruption
reflects his selfish desires (mirrors that reflect only him, portraits that "improve" him, a facade town that
exists to be admired). Ten years of rule make it plain he must be removed.

**How he took the Paths** (each exploited a *difference* he could not stand):
- Beefcakes: too loud, too late ("there-ish, on-time-ish") -> overthrown and put on wheels.
- Gourmands: too excessive, too individual -> a doppelganger and the Special Sauce; *Perfect Nutrient Paste*.
- Necrocrats: too obedient to rules -> a valid, notarized authorization; permits for everything.
- Refusemancers: too messy -> the Rot; composting outlawed as "untidy".

**Tone.** The game's comedy stays (absurd decrees, propaganda, petty rules) but every joke has a cost the
player can see: a family that cannot bury its dead, workers on wheels, a chef hiding real recipes, a land
sickening under hidden garbage. The jokes get less funny the closer you get; the last laugh is on him.

**His title.** He insists on **"His Perfection"** (and gets visibly upset, in a very small way, when it is forgotten).

## The Capital: Neatropolis

Reached from the start of the game through the town's **final-area entrance** (`ZonePortals` id `final`,
renamed "The Capital"). Zone id `final`. Same shared zone framework as the four path zones (`ZoneDef`,
`ZoneMap`, `ZoneScene`), larger than any of them, with minimap and fog of war. A visit has zone life like
every zone; at 0 life you wake at the hideout (or, if you never got past the gate, at the camp outside) and
pay the "Correction fee" (20 gold).

| Area | What it is |
|---|---|
| **The Outskirts** (south) | The approach to the city: cracked road, abandoned checkpoints, dead lamps, early **rifts**, "approved queue" markers. The only place with the road back to town. A hidden **secret entrance** (forgotten service tunnels the four Paths once built together) is found only by exploring here. |
| **The Approved Gate** | The only way in: a checkpoint run by **Primm's gate guards**. Entry needs a **challenging card battle** (the Gate Captain) after absurd entry requirements ("visitors must be of approved height", "no unapproved expressions"). Exits are controlled too: the *Exit Interview* booth and signs. |
| **Primm's Perfection** (centre) | A small, **eerily perfect facade town**: a propaganda showcase village of identical spotless houses, regulation lawns, citizens in matching clothes with fixed smiles, loudspeaker announcements, portraits and statues of Primm everywhere, decree signs ("Approved Hat Sizes: 1", "Spontaneity by Permit Only", "Smiling Is Mandatory"). Up close it is **hollow**: painted storefronts, doors that do not open, citizens who repeat approved phrases and then slip up, with hints of fear. |
| **The four broken districts** | Outside the facade the city is **corrupted and coming apart at the seams**: cracked streets, crumbling buildings, gray blocks, warped light, broken infrastructure from all four Paths, abandoned checkpoints. One district per Path: **the Transit Yards** (Beefcake, wheels and dead lines), **the Hungry Quarter** (Gourmand, shuttered stalls), **Grave Row** (Necrocrat, the permit-locked cemetery) and **the Reek** (Refusemancer, garbage hidden behind the facade). |
| **The Correction Ward** (north-east) | Where citizens who "smiled incorrectly" are sent to be improved. Grim beds, a "Spontaneity Permit" window, a re-education loudspeaker. |
| **The Crease** (hub) | A hidden **resistance hideout** in the old service tunnels under the Guild Hall: safe (no enemies), a heal spot (*Tea of Dissent*), a black market vendor (**Fig Sly's Contraband & Curiosities**, rare cards and items) and resistance NPCs (**the Wrinkles**: people Primm could not iron out). |
| **The Castle Approach** (north) | The Avenue of Portraits and the doors of **Primm's Castle** (the final dungeon). |

**The Wrinkles** (resistance): **Mabbit Quill** (retired royal archivist, leads; kept a copy of the true
records), **Fig Sly** (black market), **Nurse Hesper Dray** (the Tea of Dissent heal spot), and the four
quest givers below.

**The secret entrance.** *The Old Joint Works*: service tunnels the four Paths built together when they
cooperated (a Beefcake-dug bore, Gourmand ventilation, Necrocrat signage, Refusemancer drainage). Found by
exploring the Outskirts (no marker, no map icon: only an up-close prompt, same rules as hidden chests) and it
leads straight into the Crease, sneaking the player **past the gate** (no battle). Listed in
`docs/design/secrets.md`.

### Rifts

Dangerous magical **rifts** tear through the zone: glowing tears in reality that **damage the player on
contact**, **distort the area around them** (warped light, camera wobble, drifting debris) and **spawn or empower
corrupted enemies** (rift-spawned *Rift Wretches* and *Shard Swarms*; roaming enemies near an unsealed rift are
empowered). Some can be **sealed** for rewards (beat the rift's guardian, then seal it at the rift-stone); the big
rifts stay open until Primm falls. It should be visibly clear the kingdom is coming apart.

### The four broken services (zone debuffs)

While a Path's zone is **not yet completed**, the Capital suffers that Path's *broken service* as a debuff
(and the castle too: it is the same kingdom). Each completed zone **removes its debuff** and shows a visible
change in the Capital. Debuffs are shown in the HUD with tooltips and are implemented through the Modifier
pipeline (`ModifierSource` + new modifier kinds) plus a few world rules.

| Path | Broken service | Debuff while its zone is not free | Visible change when freed |
|---|---|---|---|
| Beefcakes | Energy and transport | **Blackout:** darkness (dim, short sight), slower movement, **no travel** (the tunnel network is down); in duels your creatures enter exhausted | the lights come back on (district lamps, brighter light), the tunnel network opens |
| Gourmands | Food and protection | **Famine:** reduced max life (-5) and food (healing items) **does not work** | food stalls reopen with lanterns, steam and signs |
| Necrocrats | Death administration | **Restless Dead:** **enemy creatures sometimes return from the graveyard** in duels (35% chance each time one dies) | the cemetery is calm, graves tidy, the paperwork loop ends |
| Refusemancers | Waste removal and agriculture | **Clutter:** **junk cards are shuffled into your deck** (3 *Heap of Rubbish* per duel) | the heaps shrink and green returns, flowers grow in the Reek |

### Primm's enforcers and corrupted creatures

*Slow battle-starters:* **Compliance Officer** (clipboard, "this is a courtesy citation"), **Perfection
Inspector** (white gloves, measures your smile). *Fast damage type:* **Tidy-Bot** (a spotless little cleaning
automaton that scrubs you out of the way: 2 damage, knockback). *Rift-spawned:* **Rift Wretch** (slow, a
person-shaped tear in reality, empowered by the rift) and **Shard Swarm** (fast, glass-bright, 2 damage).
The gate has **Gate Guards** and the **Gate Captain** (the entry battle).

### Interactables (real effects)

*Deface propaganda* (a small gold reward, once per portrait, and a sketch of a moustache); *seal a rift*
(reward after beating its guardian); *the Anonymous Complaint Box* (a random reply: compensation, a heal,
a "noted" that costs you life when an Inspector is dispatched); the *Exit Interview* booth; the tunnel *Service
Network* (fast travel between districts, down while the Beefcake service is broken).

### The four Path quests (serious story beats, funny on the surface)

One per Path, given in the Capital by a citizen who shows what Primm's perfection did to that Path's people.
Each pays gold, XP, a card or item, and a **story insight** into Primm (a journal line; the four insights are
tracked in the quest log and referenced in the Castle and the final scenes).

| Path | Quest | Giver | The weight under the joke |
|---|---|---|---|
| Necrocrats | **Form 27-B/6: A Burial Permit** | **Tilda Marrow** | Her grandfather has lain in the parlor for three years. The permit office loops forever: Form 27-B needs Form 27-C needs Form 27-B. You find the stamp, then lay him to rest. *Insight: he scheduled grief for Thursdays.* |
| Beefcakes | **The Wheel Never Stops** | **Bram "Heft" Haulsworth** | Workers run endless energy wheels to power the facade's lights (and are told it is "cardio"). Free the wheel crews. *Insight: he cannot bear a late arrival; he made lateness illegal.* |
| Gourmands | **The Recipe Box** | **Odile Bisque** | Everyone is fed only *Primm's Perfect Nutrient Paste*. A chef hides real recipes. Recover three recipe cards and spoil the paste dispenser. *Insight: he cannot taste food; he never could.* |
| Refusemancers | **Untidy** | **Gus Peelings** | Composting is outlawed as "untidy"; garbage is hidden behind the facade and the land is sickening. Rescue three banished compost heaps and plant the old seed. *Insight: he is afraid of anything that grows without asking him.* |

## Primm's Castle (the final dungeon)

The main palace, entered from the **Castle Approach** at the heart of the Capital. On the node-map system
(`DungeonMap`): **25+ nodes** and heavy branching. Side branches do not have to lead forward: some **dead-end into
treasure, an event, an encounter or lore, then double back** to the branch point (`MapNode.return_to`). Mixes
battles, elites, deck challenges, events, shrines and treasure, plus story nodes. Zone life rules apply (nothing
heals except shrines; the zone's debuffs apply to every duel).

**Sections:** the **Portrait Gallery** (endless "improved" portraits of Primm), the **Ministry of Correction**,
the **Hall of Mirrors** (mirrored halls reflecting only him), **a wing for each Path** (the *Doppelganger's
Lab Notes* (Gourmand), the *Coup Orders* (Beefcake), the *Notarized Paperwork* (Necrocrat), the *Corrupted Seed*
(Refusemancer)), the **Archive of Good Intentions** (his early journals and blueprints: reforms that really did
help at first, then escalated) and the **Scale Model Chamber**: a giant model of the whole kingdom that he
rearranges by hand. Serious beats at key nodes: the archive journals, the citizens he "corrected", and the moment
the player sees he truly believes he is the hero.

## The final boss: Primm (three phases)

An **extremely challenging** multi-phase duel (balance is out of scope): the phases are separate duels back to back
on the same boss node, with life carrying over and dialogue between phases.

1. **Standardization** - he forces conformity: every creature (yours and his) has the **same stats (3/3)** and you
   may cast at most **two non-infrastructure cards per turn** ("Two Is the Perfect Number").
2. **Reflection** - he **copies the player's cards**: his deck is a copy of the player's deck. He can only imitate,
   never create.
3. **Unraveling** - as he loses, his perfect rules break down: the arena cracks, his own creatures enter exhausted and
   he loses life each turn as the rules he wrote stop working, and his true selfishness shows.

**Freed leaders lend a boon.** For every completed zone, that zone's freed leader (Grandmaster Flex, Aurelio, Vellum,
Fernwick) appears in the final scene and lends a boon for the fight (`PrimmBoss.boons`): +1/+0 to that Path's creatures
and extra max life. Dialogue before, between phases and after: comedic self-importance first, then real tragedy. He
insists he did it all for the people; the player's victory shows him (and the player) that his perfection was really
about himself.

## Victory, ending and postgame

Defeating Primm triggers the **ending sequence**: the facade crumbles, the rifts close and the four factions
reunite. The scene's theme: Primm demanded **one way for everyone**, and his fall frees the Paths to **mix again**;
different Paths working together is what made the kingdom strong. Placeholder credits follow, then the player is
returned to the world.

**Postgame.** Defeating Primm sets `postgame_unlocked`: decks may now combine cards from **all Paths** (3+ Path
decks; a thematic popup announces it; the deck builder and validator are updated), and the **tri-Path crafting hook**
at the Alchemist becomes available (no tri/quad cards yet). The **Capital is changed**: the facade is down, the rifts
are sealed, the citizens are free, and there is new dialogue everywhere, so the postgame continues.
