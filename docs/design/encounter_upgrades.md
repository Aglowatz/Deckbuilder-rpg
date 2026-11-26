# Dungeon encounters: audit and upgrades (Nov 25 night, Part G)

The owner: dungeon encounters are repetitive and seldom challenge how a deck is built. This is the audit of every dungeon's encounters
(`python tools/nov25n_encounter_audit.py`, before tonight's changes to the postgame foes), what repeats, and what was built.

## The audit

| Dungeon | Type | Fights | Fights with own rules | Fights with scripts | Decks used (fights) | Events | Default (filler) events |
|---|---|---:|---:|---:|---|---:|---:|
| D-HOG The House of Gains | Main | 6 | 3 | 3 | beefcake_bruisers 3, mixed 2, named 1 | 2 | 0 |
| D-TTK The Test Kitchen | Main | 7 | 3 | 3 | mixed 4, gourmand_golems 1, gourmand_beefcake_bulk 1, named 1 | 2 | 0 |
| D-HFA The Hall of Final Approvals | Main | 7 | 3 | 3 | mixed 3, necro_control 2, necrocrat_beefcake 1, named 1 | 3 | 0 |
| D-ROT The Rotheart | Main | 7 | 3 | 3 | mixed 3, refuse_garbage 1, gourmand_refusemancer_farm 1, beefcake_refusemancer_gym 1, named 1 | 2 | 0 |
| D-PC Primm's Castle | Final | 11 | 7 | 6 | colorless_regime 4, necrocrat_beefcake 3, others 4 | 4 | 0 |
| S-BEEF Mount Swolympus | Side (postgame) | 3 | 1 | 1 | mixed 2, named 1 | 0 | 0 |
| S-GOUR / S-NECRO / S-REF | Side | 3 each | 1 each | 1 each | one archetype or mixed | 0 | 0 |
| S-CAP / S-PASTE / S-TOWN / S-IRON | Side | 3 each | 1 each | 1 each | colorless_regime / militia / rush | 0 | 0 |
| D-LAB The Path-ology Lab | Postgame | 8 | 3 | 3 | necro_control 2, beefcake_bruisers 2, gourmand_control 2, refuse_garbage 1, named 1 | 3 | 0 |
| S-GALLERY The Shattered Gallery | Postgame | 8 | 8 | 1 | beefcake_bruisers 2, refuse_garbage 2, others 4 | 4 | 0 |
| D-SHUFFLE The Shuffled Halls | Draft | 10 | 10 | 10 | hand-made (Nov 24) | 8 | 0 |

**What repeats.**
- **Ordinary fights are plain.** In every zone dungeon only the elites and the boss have rules of their own: about half the fights are a
  deck and nothing else. In the postgame the Lab had five plain fights of eight, Swolympus two of three.
- **The same archetypes come back.** `beefcake_bruisers` is the deck of three House of Gains fights, two Lab fights and two Gallery
  Echoes; `colorless_regime` is four castle fights and two Service Tunnels fights; `necro_control` four fights across the Hall, the Lab
  and the Gallery.
- **Events test HP, not decks.** Every event choice before tonight traded HP, gold, a card or a numbers boon or curse. None asked what
  was in the deck, so no deck was ever rewarded or punished for how it was built.
- **The side dungeons have no events at all** (three fights each), so the library could not reach them without new rooms on their maps.

**Balance.** The Halls (Nov 24) and the castle (Nov 21-23) were tuned recently and are left alone. The postgame was the softest place:
plain fights, opponents starting on 5 cards (Part C), the Gallery's Echoes without their originals' rules (Part D).

## What was built

1. **Every postgame fight has rules of its own** (Part E): 10 foes got new rules or one more scripted beat; each set is different
   (`docs/design/sim/nov25n/postgame_rules.md`), the Echoes carry their originals' rules (`gallery_echo_rules.md`), and every postgame
   and draft foe opens with a full hand (Part C).
2. **The encounter library** (`docs/design/encounter_library.md`): four new kinds of thing an event can do, and fourteen placements.
   - **Curses that can be played around**, built from new rule pieces: no spells / no traps / no tools / no wonders (`ban_spell=1` ...),
     one card a turn (`one_card=1`), brittle troops (`def=-2`). Each sits on a choice that pays for it.
   - **Deck-building checks**: a Path roll-call (`check_units`: enough units of the Path, a boon for the dungeon; too few, an HP cost)
     and the Specimen Trial (`reveal_unit`: a random unit of the deck is shown; attack high enough, a boon; too weak, every copy of it
     is shredded for this run).
   - **A boon NPC**: the hedge-wizard in the Lab's Draining Chamber (`trap_copy=1`: the first Trap you set each turn is set twice).
   - **Patrols**: every Wonder (the Gallery's reflected clerks) or every Tool (the Hall's night patrol, for gold) shredded for the run.
   - Every choice says in brackets what it checks and what is at stake before the player commits; the result shows what was found.
     A shredded card is back after the run (`DungeonRun.deck_after_run`); the save never loses it.
3. **Where**: postgame first (the Gallery's rooms 3, 6 and 12; the Lab's 4 and 7), then each zone dungeon (one Path roll-call in each
   of the four, the Gourmand one the head chef of the Test Kitchen; a patrol in the Hall; two curses in the castle). The zone heal rooms keep
   their Nov 21 template (heal 5 for a cost, or nothing) and no event room has more than four choices.

## What is left

- **The side dungeons** have no event room to carry the library; giving them one is a map change (a new node on seven painted maps).
- **Repeated archetypes in the zone dungeons**: the plain fights of the four zone dungeons still share decks. The next step is the same
  as the postgame's: a rule set each, starting with the House of Gains' three `beefcake_bruisers` fights.
- **A curse as a dungeon rule** (a whole dungeon under "no spells") is possible with the same pieces (`ban_type` in a dungeon's rules);
  none was imposed tonight without the owner's word (inbox).
