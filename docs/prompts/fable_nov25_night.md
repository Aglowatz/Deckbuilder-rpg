# Nov 25 night: finish the Nov 25 brief, then the owner's new list (encounters, postgame difficulty, health for every Path)

Repo: C:\Dev\Deckbuilder-rpg. This **adds to** `docs/prompts/fable_nov25_castle_shufflehouse.md`. It doesn't replace it. The owner is asleep: work without stopping to ask, log questions under "Nov 25 night" in `docs/overnight_inbox.md`, and take the safest choice. Same house rules as the Nov 25 brief (STOP_OVERNIGHT, one Godot at a time, `--min-free=1200`, batched sims with a 20-minute limit, commit and push after each part, no public upload, the owner constraints, the dialogue CSV `docs/dialogue/nov25_night_lines.csv` + `_ids.txt`, a test for every rule, card or quest change). Shots go in `docs/overnight_shots/nov25n/`. The owner's screenshot is `docs/overnight_shots/nov25/ref_before_fight_panel.png`.

**If this run is restarted on a different model** (for example after a usage limit), read this file and the Nov 25 brief, check `git log` and the report, and carry on from the first part that isn't done.

## Order for tonight
1. **Finish the Nov 25 brief's Part 8 checks, but not the export yet:**
   - rerun the 6 failing tests alone;
   - run the draft smoke, the walk smokes, the probes, the story bots and the five play scripts.
   Fix what fails and commit.
2. Do Parts A to H below, in order. Commit and push after each.
3. **One final check pass:** all test shards in small groups, the smokes, the probes, the four story bots one after another, and the new playthroughs below.
4. **Export 1.0.0 once, at the very end:** `EXPORT_LOW_MEMORY_OK=1 bash tools/export_windows.sh 1.0.0`, then the exported smoke and the three `play_exported.sh` checks.
5. **The report:** one combined report covering "Fable Nov 25" and "Nov 25 night".

If time or usage runs short, finish the part in hand, commit, export whatever is green and write the report. Parts G and H can be partly done; say exactly what's left.

## Part A — Quick fixes
1. **The "Before the fight" panel** (the screenshot):
   - delete the line "The same icons stay on screen during the fight.";
   - replace it with **"These rules are in play:"**, centred;
   - apply this to every panel that uses the line.
2. **Leaving the Shuffle House** puts the player in front of the Shuffle House's door, facing out (today it's in front of Crosspath's fountain). Check every way out (the menu, a draft finishing, the Shuffled Halls, a loss).
3. **Cards:**
   - **Membership Cancellation:** costs 1 less, and now reads "Destroy target tool or wonder."
   - **Resting in Peace Clause:** shuffles **5** Clause tokens into the opponent's deck.
   - **Counterweight:** deals **5** damage.
   Update the text, glossary and tests for all three.

## Part B — The Cracked Mirror: a new place and a new look
- **Move it** to a spot in the Capital that nothing uses after the game is beaten (not in a path, a crowd or another quest's space). Pick the spot, log it, and take before/after shots.
- **Give it a new visual** from the game's existing assets: a better prop, a glow, cracks and a shimmer. Add a painted art row to `docs/art/batch22.csv` (`CAP-PROP-CRACKED-MIRROR`, with what it should look like and where it stands) so the owner can make the real art.
- **Rewrite the quest text** and any dialogue that names the old place.

## Part C — Postgame and draft opponents: bigger hands, no crippled starts
1. **Opponents in the postgame dungeons** (the Path-ology Lab, Mount Swolympus, the Shattered Gallery, the vault and any other postgame dungeon) **and in drafts** hold **at least 8 cards when their first turn begins, after any opening discard.** Today many start with 5 and discard 2, which leaves them unable to act. Bosses can have more.
2. **Make them less likely to be short of resources or flooded:**
   - starting hands guaranteed a sensible mix of Infrastructure and plays;
   - or a mulligan rule for the AI;
   - or starting Infrastructure in play.
3. **Mount Swolympus first:** its boss starts with 5 cards today. Fix it, and every Path-ology Lab enemy with a hand of 5.
4. Add a test that every postgame and draft opponent meets the minimum.

## Part D — The Shattered Gallery: real mechanics and a better Silver Reserve
1. **Bring each echoed fight's special rules over** from the main-game fight it echoes: its curses, scripted turns, extra resources and phases, so the player really has to prepare. Use a postgame version, harder rather than softer. List each fight, the rules it now has, and its win rate.
2. **The Silver Reserve no longer gives +40 health.** At the first node (or after the first encounter), the player picks **1 of 3 random boons** from a pool such as:
   - +30 health;
   - your units get +2 defence;
   - your units get +1/+1;
   - draw an extra card each turn;
   - start each fight with one of each resource;
   - start each fight with a basic Infrastructure in play;
   - and a few more of your own design.
   Show it as a clear choice pop-up. Each boon lasts for the run. Balance the boons against each other in the sims.

## Part E — Postgame dungeons: hard, varied and fair
The owner's direction: postgame can be **unfair**, needing one of a few strong strategies to win. The player has 5 pieces of equipment and 4 items and is encouraged to draft for more cards. Give the postgame encounters real teeth and variety, for example:
- extra draws;
- unit buffs;
- starting Infrastructure in play;
- automatic troops each turn;
- specific spells, wonders or tools arriving on set turns;
- phases.

Every fight should feel different. Each one gets a clear "Before the fight" panel with its rules. Sim each postgame dungeon with strong, well-equipped decks across the Paths and with drafted decks. Aim for hard but beatable with a plan. Report win rates per fight and for whole runs.

## Part F — Health for every Path
- **Each Path should have some way to restore the player's health:**
  - units with Nourish;
  - spells with Nourish;
  - giving up resources or units for health;
  - heal spells, tools or wonders.
  Pathless cards can do it too. This isn't a hard rule, but every Path's player should be able to get through a dungeon.
- **First, rework the weakest and least-used cards** of a few archetypes (use the sim and pick-rate data) toward the player's health.
- **Then add a few new cards** (4 to 8, spread across the Paths plus 1 or 2 Pathless), each fitting its Path's identity. They use temporary art from existing assets and get art rows in `docs/art/batch22.csv`. Make them available in drafts and in the main game's card sources.
- List every changed and new card with its old and new text. Sim them (batched).

## Part G — Dungeon encounters: less repetitive, and challenging how decks are built
Audit every dungeon's encounters (zone dungeons, mini dungeons, postgame) for repetition and balance. Write `docs/design/encounter_upgrades.md`. Then build a new library of encounter types and spread them through the dungeons, postgame first, then zone dungeons. The owner's examples:

- **Harsh curses that can be played around,** specific to a dungeon:
  - no tools, no spells or no traps;
  - only one card per turn;
  - "all your troops get -2 defence" (a postgame puzzle).
- **Deck-building checks:**
  - a Gourmand chef: if your deck has enough Gourmand units you get a boon for the rest of the dungeon; otherwise he attacks for 5 HP;
  - a dinosaur challenge: reveal a random unit from your deck. If its power is high enough you pass and get a small boon; otherwise every copy of that unit is shredded from your deck **for this run only**.
- **Boon NPCs:** a wizard prisoner who copies the first trap you cast each turn.
- **Patrols:** Necrocrat patrols that shred all your wonders (for the run).

Add more of your own: a few for each Path, each zone's flavour, some with choices. Every event says clearly what it checks and what's at stake before the player commits. Run-only changes are undone when the run ends, and the save always restores the real deck. Each new type gets a test, and the event panels get shots. Family friendly.

## Part H — Report additions (in the combined report)
- **Parts A to G:** each done or not, with shots.
- **The postgame and Shattered Gallery win rates.**
- **The Silver Reserve boons.**
- **Health:** each Path's health options after this pass.
- **Encounters:** the new encounter library and where each type is used.
- **What's left.**
- **The owner's decisions needed:** at most 6, each with a recommendation.
