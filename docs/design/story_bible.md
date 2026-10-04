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

## Ten years ago: the big bad

Ten years ago **Malvane the Usurper** (placeholder name; "the big bad") took over, and somehow
took over or corrupted each of the four factions. Each Path now lives under an oppressive ruler
who answers to Malvane, and the people of each zone suffer. The player - who wakes up in a cave
with no memory in the Trial of the Hollow - must **free each zone** by beating its dungeon boss.
Malvane's methods differ per faction:

| Faction | How Malvane got them | The ruler now |
|---|---|---|
| Gourmands | A **doppelgänger** replaced the leader. Corrupted, magically tainted food steers the Gourmands' love of food, invention and feeding others against them. | **The False Aurelio** (the impostor wearing Grand Chef Aurelio Saucier's face) |
| Beefcakes | The leader was **violently overthrown** and imprisoned; the regime holds the zone. | **Commander Gristle**, regime commander; the true leader is **Grand Champion Thaddeus "Heartlift" Brawn** |
| Necrocrats | **Paperwork.** Authority was transferred to Malvane by a fully valid, notarized, filed process. The Necrocrats are not evil, just obligated: "Yes, but the authorization is valid." | **The Registrar of Final Approvals** |
| Refusemancers | The leader was **corrupted through nature itself**; the infection spread through the magical ecosystem. | **Archdruid Fernwick Loam, the Rotheart Archdruid** |

## Factions in detail

### Gourmands - The Endless Buffet / The Test Kitchen
- **The corruption.** The leader has been secretly replaced by a doppelgänger who keeps the original's
  appearance and authority, and has gradually turned the Endless Buffet into a massive R&D
  operation. Magically corrupted food (the "Special Sauce") bends the Gourmands' natural love of
  food, invention and feeding others. Beneath the surface they are forced to build enormous
  food-powered war machines and magical technology for Malvane.
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
- **The corruption.** The original leader, Thaddeus "Heartlift" Brawn, was violently overthrown by Malvane's forces and
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
  administered according to policy. Malvane exploited that rather than corrupting them: through a
  completely legitimate process the paperwork was submitted, reviewed, approved, notarized and
  filed, transferring authority over the Necrocrat government. The paperwork is valid, so they are
  legally obligated to obey. Even when the heroes point out the big bad is clearly evil and causing
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
  agriculture and transformation. Malvane discovered the connection could be turned against them.
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
  Archdruid**; defeating them **severs the big bad's influence over the natural world**.
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
6. All four free: Malvane (postgame) - not yet implemented.
