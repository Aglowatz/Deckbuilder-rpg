# Enemy roster review, Oct 28 (overnight Oct 27-28)

Every enemy that walks a zone as a 3D model becomes a painted 2.5D sprite like the NPCs (the code side is in place tonight: a roamer
takes a sprite set by ID the moment it is imported and keeps its model until then; `docs/art/art_direction_oct28.md` section 13). On the
way, each zone's roster was re-read against its theme and its ruler: who would really be walking these roads under this regime? Names are
kept where they already serve the zone (and everywhere a frozen dialogue file mentions them); a few generic ones are renamed. Dungeon
node foes keep their names (they live in `dungeon_content.json`, frozen tonight) and are only re-described for their Bestiary pictures.

Rules applied: humanoid animals and living objects in the game's humour (voice bible: gym-bro sincerity, cooking-show drama, office comedy
for the afterlife, folksy compost, approved cheer over misery); IP-safe parody only; every foe carries a mark of the regime it serves (the
crossed-out barbell, Crumb's rosette, a DENIED stamp, Clipwell's shears, Primm's mirror); roamers that do not fight (the DAMAGE-2 hazards)
stay creatures, not people. Sizes are relative to the Wanderer (1.0); the sprite importer scales to them.

Renames are applied in code and data (`core/zone/*_enemies.gd`, `data/bestiary/bestiary.json`, `core/data/bestiary.gd` aliases so old
saves keep their Collection Book counts and the old Bestiary picture keeps showing until the new one arrives, tests, smoke tools). No
frozen dialogue file names a renamed foe, so `docs/dialogue/lines_to_update_oct28.csv` has no rows for them.

## Crosspath (level 1; the first enemies anyone meets)

The town is "quiet and watched": its three roamers are strays from three Paths that wandered in from the roads, not a garrison. Each is a
taste of one Path's deck before the player has seen a zone.

| Old -> new | Look (shared by sprite + Bestiary square) | Size | Behaviour | Why |
|---|---|---|---|---|
| Stray Gym Hound -> **Pantry Hound** | A floppy-eared spaniel on two legs in a stained apron, a ladle in its mouth, eyes swirling a little from the Special Sauce it got into; a Gourmand rosette on the collar. | 0.75 | Defensive; the gourmand_control deck it already plays | The old name said Beefcake while the deck and the zombie model said nothing; now it is the Buffet's sauce reaching Crosspath. |
| Lost Junior Clerk (kept) | A small, translucent ghost clerk in a too-big tie and visitor lanyard, hugging a stack of forms taller than itself, a DENIED stamp hanging from its belt. | 0.6 | Defensive; necro_control | Already on theme (the D.N.A. has misplaced an employee). The KayKit rogue it uses today looks like a bandit. |
| Bin Raccoon (kept) | A round raccoon in a dented tin-can helmet with a bottle-cap shield, a bin lid on its back, very pleased with itself. | 0.62 | Defensive; refuse_rats | Already on theme; today a grey-tinted graveyard keeper model. |

Also in town, no sprite needed: the four corrupted gatekeepers (painted sprites exist), the Store Room Ghosts (a scripted fight at a door),
the Restless Dead (a cairn), Shiro Swindle (painted NINJA sprite), the Warden of the Four Seals (a vault door), the Wellspring's Echo.

## The Gainlands (level 5): Quota's regime of muscle

Clench runs the zone "like a bureaucracy of muscle" for Vivienne Quota: every weight confiscated, every rep counted, Beefcakes on wheels.
The roamers are the people who count.

| Old -> new | Look | Size | Behaviour | Why |
|---|---|---|---|---|
| Flexing Brute -> **Quota Spotter** | A massive billy goat in a regime singlet (the crossed-out barbell on the chest) and a too-small officer's cap, a stopwatch on a chain, a clipboard tucked under one arm; chalk on the hooves. The regime's spotter: he spots you, then writes you up. | 1.05 (was 0.62 model x1.36) | Balanced; beefcake_rush; the two road guards get two escorts each as today | "Brute" said nothing about the regime; the goat is the gym mascot Hammer Thrower's card already scared. Spotting is the zone's running gag. |
| Protein Shake Golem (kept) | A walking protein tub with a shaker-lid head, two scoop arms, chocolate shake sloshing out of the seams, a Quota efficiency notice slapped on its belly (no letters: a stopwatch pictogram). | 1.35 | Aggressive; its own recipe | Already a living object on theme. |
| Sprinting Energy Sprite (kept, hazard) | A crackling spark with legs, the shape of a tiny hamster mid-sprint, trailing wheel-light; it ran off a hamster wheel and has not stopped. | 0.8 | Hazard (2 damage), no battle | Keeps the "energy and transport" service visible on the road. |

## The D.N.A. (level 9): the Compliance Department

Mortimer enforces every rule because the authorization is valid; the staff are not evil, they are busy. The roamers are the office at 4:59.

| Old -> new | Look | Size | Behaviour | Why |
|---|---|---|---|---|
| Shambling Middle Manager (kept) | A broad grey-green zombie in a crooked tie and rolled sleeves, a mug in one hand (steam that is slightly ghostly), a clipboard in the other, name badge blank; walks like a man late for a meeting he is chairing. | 1.15 | Balanced; necro_zombies | Already the zone in one figure. |
| Zombie Intern -> **Unpaid Intern** | A thin, eager zombie in a visitor lanyard carrying a wobbling tower of forms that hides its face, one eye peeking round the stack, a coffee cup balanced on top; a DENIED stamp on the back of its shirt. | 0.9 | Aggressive; necro_control | "Unpaid" is the office joke the Hazmat Intern card now shares; the stack of forms is the silhouette. |
| Speedy Ghost Courier (kept, hazard) | A streak of a ghost in a courier's satchel, envelopes trailing behind it, cap flying off; it has somewhere to be, forever. | 0.95 | Hazard | Fine as is. |

## The Endless Buffet (level 12): Crumb's Culinary Defense

A thriving kitchen that is a weapons factory. The golems that once guarded pantries are rebuilt for war and still say "Yes, Chef!".

| Old -> new | Look | Size | Behaviour | Why |
|---|---|---|---|---|
| Meatloaf Golem (kept: it is also the name of the Meatloaf Mold's token) | A loaf-shaped golem with a ketchup-glaze stripe down its back, two drumstick arms, a tiny chef's toque, Crumb's rosette (a fork-and-saber badge, no letters) pinned to its chest; it salutes before it charges. | 1.35 | Aggressive; gourmand_golems | On theme; the card token and the roamer should be the same creature. |
| Gelatin Sentinel (kept) | A tall dome of wobbling red jelly with a maraschino cherry for an eye, a fruit cocktail suspended inside like armour plates, a saucer helmet; it jiggles when alarmed. | 1.35 | Defensive; gourmand_control | A living dessert standing guard: the zone's "protection" service made silly. |
| Runaway Meatball (kept, hazard) | A meatball the size of a hay bale with a face, rolling, trailing a spaghetti strand, panicking cheerfully. | 1.0 | Hazard (rolls) | Fine. |
| Colonel Casserole (kept; frozen in story files) | The gate golem: a casserole-dish golem with a cracked lid helmet and oven-mitt gauntlets. | 1.3 | Gate elite; gourmand_golems | Already a named character. |

## The Verdant Dump (level 15): the Hungry Green and Clipwell's tidiness

Nothing rots, so everything chokes; and the Royal Groundskeeper trims what she can reach into topiaries of Primm.

| Old -> new | Look | Size | Behaviour | Why |
|---|---|---|---|---|
| Mossy Trash Golem (kept) | A walking compost heap with a rusted watering can for a head (the spout is its nose), tyres for shoulders, wildflowers and a sprouting fork growing out of it, one goat horn stuck in its side. | 1.3 | Aggressive; refuse_rats | On theme; the Hungry Green's body. |
| Possessed Scarecrow Druid -> **Overgrown Scarecrow** is a dungeon foe already, so the roamer is renamed **Hungry Scarecrow** | A druid's scarecrow in a patched robe that has started to grow: vines for arms, a pumpkin head with too many sprouting eyes, a sign (a picture of a goat, no letters) nailed to its chest that something has been chewing. | 1.3 | Defensive; refuse_garbage | "Possessed" said horror; "hungry" says the zone's wrongness (growth that never stops). |
| Junk Gull Flock (kept, hazard) | Three gulls wearing bottle-cap crowns and a six-pack ring, circling a stolen sandwich. | 1.1 | Hazard (flock) | Fine. |

## The Capital (level 18): the Ministry of Correction

Relentless approved cheer over obvious misery. The roamers are the officials who keep the facade standing.

| Old -> new | Look | Size | Behaviour | Why |
|---|---|---|---|---|
| Compliance Officer -> **Correction Officer** | A tall enforcer in white-and-gold livery with a mirrored visor (you see yourself, improved), a ruler on the belt, a clipboard, boots that have never touched mud; a fixed approved smile painted on the visor's chin guard. | 1.2 | Balanced; mixed regime deck | "Compliance" is the D.N.A.'s word; the Capital has a Ministry of Correction and a Correction Ward. |
| Perfection Inspector (kept; named in capital_story.tres) | A short, round official in a powdered wig and white gloves holding a brass protractor to eye level (smiles are measured at eight degrees), a lens on a chain, a sash with Primm's profile. | 1.0 | Defensive | Already the facade's joke. |
| Tidy-Bot (kept; named in capital_story.tres; hazard) | A brass-and-porcelain sweeper automaton with a feather-duster arm, a dustpan jaw and a painted smile; it tidies citizens. | 0.9 | Hazard | Fine. |
| Rift Wretch (kept) | A citizen half-unmade by a rift: one side an approved pastel coat, the other side purple seams and floating shards, the smile still on. | 1.2 | Aggressive; necrocrat_refusemancer | On theme (the rifts began the night the boy got out). |
| Shard Swarm (kept, hazard) | A drifting cloud of purple mirror shards, each reflecting a different approved face. | 1.0 | Hazard | Fine. |

## Dungeon foes: Bestiary pictures only

Node foes keep their names (frozen) and their pictures mostly exist (75 of 96 Bestiary squares). The 21 missing are all speaking bosses,
elites and lieutenants, which the intro change covers with cut-outs (`art_batch_oct28.csv`, category Cut-out), and the Bestiary square for
each is derived from the same cut-out description so the Collection Book matches the entrance. Three approved pictures on disk belong to
retired names and are kept for reuse: BST-OBSERVATION-WARD-ORDERLY, BST-REGIME-CHECKPOINT-CAPTAIN, BST-ROOTBOUND-MILLER.

Not in the Bestiary at all today (the Collection Book never counts them): the three town roamers, the Store Room Ghosts, Brisket and Sir
Loin (gate golems that do not fight) and the eight Undercroft arena foes. The three town roamers are added to the Bestiary tonight (they are
the first three enemies a player meets in the open world); the rest are logged for the designer (inbox).

## Roaming roster, one line each (for the batch)

| Zone | Foe (sprite key) | Set | Size |
|---|---|---|---|
| Crosspath | Pantry Hound (FOE-PANTRY-HOUND), Lost Junior Clerk (FOE-LOST-JUNIOR-CLERK), Bin Raccoon (FOE-BIN-RACCOON) | walk sets | 0.75 / 0.6 / 0.62 |
| Gainlands | Quota Spotter (FOE-QUOTA-SPOTTER), Protein Shake Golem (FOE-PROTEIN-SHAKE-GOLEM), Sprinting Energy Sprite (FOE-SPRINTING-ENERGY-SPRITE) | walk / walk / idle | 1.05 / 1.35 / 0.8 |
| D.N.A. | Shambling Middle Manager (FOE-SHAMBLING-MIDDLE-MANAGER), Unpaid Intern (FOE-UNPAID-INTERN), Speedy Ghost Courier (FOE-SPEEDY-GHOST-COURIER) | walk / walk / idle | 1.15 / 0.9 / 0.95 |
| Endless Buffet | Meatloaf Golem (FOE-MEATLOAF-GOLEM), Gelatin Sentinel (FOE-GELATIN-SENTINEL), Runaway Meatball (FOE-RUNAWAY-MEATBALL), Colonel Casserole (FOE-COLONEL-CASSEROLE) | walk / walk / idle / idle | 1.35 / 1.35 / 1.0 / 1.3 |
| Verdant Dump | Mossy Trash Golem (FOE-MOSSY-TRASH-GOLEM), Hungry Scarecrow (FOE-HUNGRY-SCARECROW), Junk Gull Flock (FOE-JUNK-GULL-FLOCK) | walk / walk / idle | 1.3 / 1.3 / 1.1 |
| Capital | Correction Officer (FOE-CORRECTION-OFFICER), Perfection Inspector (FOE-PERFECTION-INSPECTOR), Tidy-Bot (FOE-TIDY-BOT), Rift Wretch (FOE-RIFT-WRETCH), Shard Swarm (FOE-SHARD-SWARM) | walk / walk / idle / walk / idle | 1.2 / 1.0 / 0.9 / 1.2 / 1.0 |

A "walk set" is the Wanderer-style set (five directions, idle + four walk frames); an "idle set" is the stationary set (hover and roll
hazards animate in code). The sprite key is `FOE-` + the Bestiary id without `BST-`, so a renamed foe's files are named after the new name.
