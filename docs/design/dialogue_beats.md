# Dialogue beats (Oct 19 2026)

The map for the dialogue rewrite. For each area: which story beats, foreshadowing and mini-stories must land, in which conversation (file +
key), which callbacks link the zones, what is weak or missing today, and the order to rewrite in. Story facts: `story_bible.md` (wins).
Voices: `voice_bible.md`. Names and the banned list: `canon.md`.

Status marks: **OK** (lands today, polish only), **WEAK** (exists, needs a rewrite; the weak line is quoted), **MISSING** (no line carries it
yet; write it into the named existing key if possible), **CODE** (needs a new key or code hook; do not invent keys, list it for the inbox).
Writers change values only: never a key, id, flag, `.speaker` value, `%s`/`%d`, `[tag]` prefix, or the order of an indexed array.

---

## 1. The box limit

Measured from `ui/town/dialogue_box.gd` and `tests/test_dialogue_fit.gd`:

- Box width `PLAIN_WIDTH` 1100 px, minus the dialogue panel's content margins (44 + 44, `UiSkin.dialogue_panel`) = **1012 px of text**.
- Font: Alegreya Sans Regular at **27 px** (default) and 27 x 1.4 = **38 px** (largest text setting).
- Test budget: at most **4 wrapped lines at default** and **6 at the largest size** (`MAX_LINES_DEFAULT`, `MAX_LINES_LARGE`). Keys ending
  `.name .title .prompt .button .label .hint .blurb .machines .wheel_names .pairs .shouts`, `ui.*` and `pack.hint.*` are not checked.
- In characters (estimated from the font's average advance, about 0.43 em): **about 85 characters per line at default** (4 lines = about
  340 characters) and about 60 at the largest size (6 lines = about 370). The default size binds: **hard ceiling about 330 characters per
  box**. The test is the authority; `DialogueBox.wrapped_lines(line, scale)` is what it calls.
- **Writing target**: one or two sentences, **160 characters or fewer** (two rendered lines), never more than **240**. Long sincere beats
  are split across boxes, not crammed. The current text has boxes up to about 300 characters (`cutscene.wonder.5`, `ending.beat.*`,
  `dungeon.hg_boss.before`); split those.
- A line may start with an expression tag `[tag]` (letters and `_` only: `[smug]`, `[angry]`, `[calm]`, `[revealed]`); it is stripped
  before measuring and drives the portrait. Keep existing tags.

## 2. Where dialogue lives

### 2a. Files

| File | Key prefixes (dialogue) | Speakers | Lines (approx.) |
|---|---|---|---|
| `data/story/intro_story.tres` (`StoryText`, `texts` + arrays) | `still.*` (stills), `start.*`, `prologue.rescuer/.wanderer/.self_talk`, `tutorial.warden.*`, `cave_mouth.*`, `memory.1..4.*`, `town.elder.*`, `town.guard.*`, `gate.<path>.blocked/.cleared`, `town.vendor/.item_vendor/.equipment_vendor/.hidden_vendor/.pack_vendor/.tailor/.alchemist/.arena.*`, `quest.armory.*`, `zone.complete.*`, `town.objective*`, `pack.*`, `tailor.*`, `arena.*`, `travel.*`, `postgame.rescuer.*`, `capital.castle.warning`; arrays `awakening_lines`, `<path>_npc_intro/_victory/_defeat_lines`, `equipment_vendor_intro/_return_lines`, `graveyard_*_lines` | narration, Wanderer, Rescuer, Warden, Maren, Brannoch, the four gatekeepers, Sable, Tilly, Bertram, Fenwick, Pip, Alembic, Bellows, Secret Dealer, Rip and cousins | 256 keys / 409 lines + 55 array lines |
| `data/story/gainlands_story.tres` (`ZoneStoryText`, `lines`) | `npc.brenda/.gus/.tony/.quiz/.minigame/.gary.*` (+ `.freed`), `quest.gain_*`, `freed_npc.heartlift`, `cutscene.rescue.*`, `cutscene.flex.*`, `dungeon.hg_*`, `event.hg_*`, `travel.thrower_*/.ripper_*`, `reps.*`, `wheel.*`, `fx.*`, `sign.*`, `ruler.*`, `enemy.*` | Old Man Mountain, Foreman Gus, Benchley, Pump, Chet, Gary, throwers/rippers, Flex, Clench, narration | 247 keys / 445 lines |
| `data/story/gourmand_story.tres` | `npc.odalys/.tarragon/.dolcetta/.quiz/.minigame/.old_meatloaf.*` (+ `.freed`), `quest.buf_*`, `freed_npc.grandchef/.escoffina`, `cutscene.reveal.*`, `cutscene.wonder.*`, `dungeon.tk_*`, `event.tk_*`, `gate.ingredient/.quest/.battle.*`, `order.*`, `recipe.*`, `fortune.*`, `sign.*`, `fx.*` | Basil, Tarragon, Mirepoix, Pate, Flambe, Old Meatloaf, golem guards, the Grand Chef, the Doppelganger/Escoffina, narration | 254 keys / 472 lines |
| `data/story/dna_story.tres` | `npc.dolores/.barnaby/.pip/.matching/.quiz.*` (+ `.freed`), `quest.dna_*`, `freed_npc.agnes/.prudence/.mortimer`, `dungeon.ha_*`, `event.ha_*`, `cutscene.vacancy.*`, `memo.*`, `poster.*`, `puzzle.*`, `match.*`, `sign.*`, `fx.*` | Agnes, Gerald, Ledgerbone, Kyle, Ectomund, Vellum, Mortimer, Prudence, clerks, narration | 230 keys / 432 lines |
| `data/story/refusemancer_story.tres` | `npc.marigold/.hob/.wren/.quiz/.minigame.*` (+ `.freed`), `quest.heap_*`, `freed_npc.compostella`, `bark.worker_1..3`, `dungeon.rh_*`, `event.rh_*`, `cutscene.sever.*`, `sort.*`, `grow*`, `sign.*`, `fx.*` | Bramble, Granny Gristle, Wren Muckfoot, Thistlewick, Rhonda, workers, the Rotheart/Compostella, narration | 235 keys / 431 lines |
| `data/story/capital_story.tres` | `npc.wren/.fig/.hesper/.fern/.pell/.rollo/.marlo/.spotless/.guard_*/.exit_clerk/.patient.*` (+ `.freed`), `npc.wren.insight.1..4`, `quest.cap_*`, `facade.citizen.N.*`, `facade.door.*`, `facade.speaker.*`, `dungeon.pc_*`, `event.pc_*`, `challenge.pc_*`, `cutscene.primm_intro/_p1/_p2/_reveal/_end.*`, `boss.phase.*`, `boon.*`, `ending.beat.1..10`, `ending.credits.*`, `ending.postgame.*`, `ending.return`, `freed_npc.*` (leaders, Primm, guard), `debuff.*`, `prop.*`, `sign.*`, `fx.*` | Wren, Fig Sly, Hesper, Old Fern, Widow Pell, Rollo, Marlo, Spotless, guards, Citizens, Citizen 4471, loudspeaker (Plume), the four leaders, Primm, the Chief Corrector, narration | 582 keys / 880 lines |
| `data/dungeons/dungeon_content.json` `"text"` (read by `DungeonCatalog`) | `quest.side_s_*` (side-dungeon givers), `npc.kestrel.*`, `fx.old_tunnels_way_in`, `dungeon.dg_s_*_boss.before/.after`, `dungeon.dg_lab_*` | Maren (S-TOWN), Old Man Mountain (S-BEEF), Basil (S-GOUR), Gerald (S-NECRO), Bramble (S-REF), Kestrel (S-CAP), side bosses, the Rescuer (Lab), Siphon | 49 keys / about 80 lines |
| `data/dungeons/dungeons.json` `"hook"` | one hook quote per dungeon (CSV import; designer sheet text) | hook NPCs (`hook_speakers` in dungeon_content.json) | 13 lines; sheet canon, edit with care |
| `data/npcs/npcs.json` `"barks"` (via `NpcBarks`, speech bubbles) | per NPC id | every listed NPC with barks | 104 lines |
| `world/town_scene.gd` | `BAKER_LINES` (const, cycled by visit count); Old Well toast `"The %s spring hums. It knows you."` (line ~1463); arena prompt string (still "Grand Clashatorium", line ~962) | Brindle, narration | 6 + 1 |
| `core/dungeon/trial_of_the_hollow.gd` | Forgotten Cave node blurbs (string literals) | narration | 5 |
| `core/dungeon/ninja_boss.gd`, `world/ninja/giant_chest_event.gd` | Shiro Swindle per-chest lines, final duel | Shiro | about 25 |
| `core/dungeon/vault_guardian.gd` | Four Seals lever texts, Warden of the Four Seals | Warden, narration | about 12 |
| `core/dungeon/element_choice.gd`, `core/dungeon/campaign_start.gd` | Path descriptions on the choice screen | UI voice | 12 |
| `core/quests/quest_definitions.gd`, `core/quests/zone_quest_definitions.gd` | quest titles, summaries, objective and location text (the quest log) | quest-log voice | about 90 |
| `ui/battle/tutorial_layer.gd` | first-battle tips | tutorial voice | 16 |
| `world/capital/capital_scene.gd` | west-wall hole line (~401), Capital arrival line (~857) | narration | 2 |
| `world/starting_area_scene.gd` | Lab gate prompt (~687), "My deck is not ready" | narration, Wanderer | 2 |
| `core/arena/arena_content.gd` | Undercroft gear flavour | narration | 8 |
| `data/loading/loading_tips.txt` | loading tips | tips voice | (see file) |

Code files are being edited by another agent tonight; a writer touching them must change only the string literals.

### 2b. Precedence and variants

- **`.freed`**: in a zone story, `<key>.freed` replaces `<key>` once that zone is freed (`ZoneStoryText.get_lines`). The Capital's `.freed`
  variants follow Primm's fall. This is the one safe kind of new key: a `.freed` twin of a key the zone already reads (for example
  `npc.<id>.intro/.return`) works with no code, because the lookup is generic. Any other new key is CODE.
- **`DungeonCatalog` wins**: a key in `dungeon_content.json` `"text"` overrides the same key in a zone story file.
- **Gatekeepers have no post-zone variant**: `town_scene.gd:1269` replays `<path>_npc_victory_lines` forever, even after the zone is freed
  (so Brick still says "Chancellor Clench runs the Gainlands now" after Clench falls). CODE (inbox): a freed-zone array per gatekeeper.
- **`.speaker` keys** set the name plate in cutscenes; "You" is the Wanderer (shown as "The Wanderer" until `prince_revealed`).
- Maren's lines are assembled in `town_scene.gd` (`_elder_lines`): `first` once, then `progress.N` (once per new zone), then `stage.N`
  (by memories recovered), then `return`. Write each so any order reads well.

### 2c. Legacy key names (the key is NOT the speaker)

| Key | Speaker | | Key | Speaker |
|---|---|---|---|---|
| gainlands `npc.brenda.*` | Old Man Mountain | | dna `npc.dolores.*` | Agnes Overdue |
| gainlands `npc.tony.*` | Coach Brutus Benchley | | dna `npc.barnaby.*` | Gerald |
| gainlands `npc.gus.*` | Foreman Gus | | dna `npc.pip.*` | Clerk Ledgerbone (not Pip Threadwell) |
| gainlands `freed_npc.heartlift` | Grandmaster Flex | | dna `npc.matching.*` | Kyle |
| gourmand `npc.odalys.*` | Basil | | refusemancer `npc.marigold.*` | Brother Bramble |
| gourmand `npc.dolcetta.*` | Madame Mirepoix | | refusemancer `npc.hob.*` | Granny Gristle (not Old Hob) |
| `npc.quiz.*` (every zone) | that zone's quiz master | | refusemancer `npc.wren.*` | Wren Muckfoot (capital `npc.wren.*` is Wren) |
| `npc.minigame.*` (every zone) | that zone's host | | capital `npc.patient.*` | Citizen 4471 / Aldous |

---

## 3. The main story spine

| # | Beat | Where it lands (file: key) | Status |
|---|---|---|---|
| 1 | Waking: no name, four-colour glow fading | intro `still.wake` | OK |
| 2 | The Rescuer: a friend, "can you still pull from the Paths?", feels all four faintly | intro `prologue.rescuer.1..3`, `prologue.wanderer.1..2` | OK |
| 3 | The Path choice; sent through the cave; "expecting a stranger" | intro `prologue.rescuer.4`, `prologue.wanderer.3` | OK |
| 4 | The Warden: royal tunnel, only the bloodline passes, "you smell familiar" | intro `tutorial.warden.before/.after` | OK; add the dry spring (section 5.1) |
| 5 | Maren's welcome, guarded; pie | intro `cave_mouth.maren`, `cave_mouth.maren_end` | OK |
| 6 | The four Paths, Primm, the gatekeepers | intro `town.elder.first` (six boxes) | WEAK: an exposition wall |
| 7 | Brannoch: the four broken services, Isla | intro `town.guard.capital_offer` | OK |
| 8 | Each zone: gatekeeper -> favour -> dungeon -> leader | zone files (sections 5.3-5.6) | mostly OK |
| 9 | Second Path after the first freed zone | intro `memory.1.after` box 3, `memory.1.announce_*` | OK |
| 10 | Memories 1-4 and Maren's admissions | intro `memory.N.*` | memory 4 WEAK (no "I knew") |
| 11 | Leaders' closing lines to him (the four lessons) | gainlands `dungeon.hg_boss.after*`; gourmand `freed_npc.grandchef`; dna `freed_npc.agnes`; refusemancer `freed_npc.compostella` | OK |
| 12 | The Capital: Wren, the four insights | capital `npc.wren.*`, `quest.cap_*.ready` | OK |
| 13 | The castle: wings, gallery, ward notes "M.", journals | capital `dungeon.pc_*`, `event.pc_*` | OK |
| 14 | The reveal (memory 4 or Primm) | intro `memory.4.*`; capital `cutscene.primm_reveal.*` | OK |
| 15 | Primm's three phases; his answers to the four lessons | capital `cutscene.primm_intro/_p1/_p2/_end` | WEAK: the Wanderer lectures |
| 16 | Ending, File Complete, "Welcome home" | capital `ending.beat.1..10` | OK; token fix |
| 17 | Postgame: Rip's tip, the Lab, the Rescuer, Siphon | intro `travel.forest_tip`, `postgame.rescuer.*`; dungeon_content `dungeon.dg_lab_*` | OK |

**Spine fixes:**
- `town.elder.first` (6 boxes) is a lecture. Keep the facts, cut to four boxes of one or two sentences, and give Maren her voice (pie, "dearie",
  suspicion). Never lose: the four Paths and services, Primm and his rulers, the four gatekeepers, Sable and the Deck Station.
- `cutscene.primm_p1.2`, `primm_p2.2`, `primm_end.3`: the Wanderer recites the lessons ("Because they are not the same, Primm. People are not
  the same, and strength is not control. It comes from the heart and the mind, not from ordering the world into rows."). Rewrite each as a
  short line that quotes the leader who taught it (callbacks C1-C4 below). Keep the order: phase 1 strength (Flex), phase 2 name and respect
  (the Grand Chef and Agnes), the end letting go (Compostella).
- `cutscene.primm_intro.3` "You have to stop, Primm. The Paths are breaking." is generic: make it his own small, specific line.

## 4. Foreshadowing threads

### 4.1 The royal crest (four Path symbols in a ring)
Canon placements: Maren's walking stick, the Crosspath fountain, the Forgotten Vault banner, the Vault Guardian's four-coloured core, the
crest "on every door" in memory 4. No line explains it before memory 4.
- intro `memory.4.fragment` "The Wayweaver crest on every door" - OK (the only use of "crest" in text).
- dungeon_content `dungeon.dg_s_town_boss.before` (four-coloured core) and `.after` (the banner) - OK.
- MISSING: Maren's walking stick is never mentioned. Land it unexplained in one Maren line (`town.elder.stage.0` or `stage.1`: she taps the
  stick, four little carvings in a ring), then pay it off in `memory.4.after` ("the same ring as on my stick").
- MISSING/CODE: the fountain has no "E to read" text. Townsfolk barks (npcs.json `NPC-TOWNSFOLK`) can mention the old ring of plinths.

### 4.2 The Wellspring and the Old Well
Canon: ONE Wellspring once fed all four Paths; "Wellspring" is a lore word only; the town well is the Old Well; the Forgotten Cave ends at a
dried-up ancient spring; the Rotheart's ninth node is the Last Clean Spring; Primm built clean wells and misses them. Do NOT state where the
Wellspring is, why it dried, or that the Old Well drew from it (not canon; Part 6 decides).
- `world/town_scene.gd` Old Well toast "The <Path> spring hums. It knows you." - OK (code string).
- npcs.json townsfolk bark "Did you hear the well talks now? It doesn't. But imagine." - OK.
- capital `event.pc_early_journals.body` ("Year 1: Wells") and `freed_npc.primm` ("I find that I miss the wells") - OK, strong pair.
- MISSING: the cave's dry spring. `core/dungeon/trial_of_the_hollow.gd` "Five cards fall into the well. Will it answer?" never says the well
  is dry or old. One narration line in the Warden's `.after` or the shrine blurb: "a spring that ran once".
- MISSING: no line uses the word "Wellspring" at all. One lore mention is enough before Part 6: Auntie Alembic (`town.alchemist.intro`
  or `.return`) or Maren (`memory.3.after`) "there was one spring once that fed all four Paths", stated as legend.
- The Rotheart's clean spring node: refusemancer `dungeon.rh_soil.*` ("A Patch of Clean Soil") is the game's heal node; the bible's "Last
  Clean Spring" name is not in text. Leave the title; a `.after` line may mention clean water.
- PLACEHOLDER: the Old Well secret quest (Part 6) will add its own keys; leave room, do not pre-write it.

### 4.3 Maren's knowledge (founder of Path-ology, the lab, she knew)
- intro `memory.2.after` (she is the resistance contact) - OK. `memory.3.after` ("I helped to blow it") - OK.
- capital `dungeon.pc_ward.before`: the oldest notes signed "M." and "You have seen that handwriting on a pie recipe." - strong payoff, but
  MISSING its setup: no earlier line shows Maren's handwriting. Set it up in `town.elder.stage.1` or `memory.1.after` (she hands him a
  recipe card, or a note on the pie in her careful rounded hand).
- intro `memory.4.after`: WEAK. Sheet canon says she knew all along (the Warden let him through, which only royal blood can do) and now helps
  with everything. Today she only says "I met a boy once at court". Add the admission ("I knew the moment the Warden let you out. I was too
  frightened to say it.") without breaking `memory.4.reply`/`after2`.
- MISSING: "That's no prince. That's a damp young man." (her signature denial) is in no line. Natural home: `town.elder.stage.2` or `.3`.
- MISSING: Siphon as her protege. One unnamed hint in `memory.3.after` ("my best student kept the lab") pays off in `dungeon.dg_lab_boss.after`
  ("Maren said so, and I called it sentimentality").
- MISSING: her distrust of the Rescuer. One line, `{rescuer}` unnamed: "Whoever got you out of that tunnel is reckless, and I don't like
  reckless." Never say the name Elowen or that she is Siphon's daughter.

### 4.4 The prince reveal (the face, eleven, four colours, the unfiled form)
All built and mostly OK; see the callback table. Weak points: Bramble's "A few months back" (time is wrong: say "not long ago"), and
`memory.4.fragment` / `memory.4.after` / `ending.beat.10` writing "Tessar" literally instead of `{prince}` (the fragment's shouted name may stay
`{prince}` through the token).

### 4.5 The Rescuer (Elowen, as far as built)
Built: prologue, the Lab rescue (`dungeon.dg_lab_rescue.*`), freed lines (`postgame.rescuer.freed/.cleared`). Not built: Cave Mouth scenes,
Plume's abduction, her name. Write only into the built keys; keep her unnamed (`{rescuer}`, "they" in narration as today).
- OK: "I am sorry I could not carry you farther" (she carried him: pays off Bramble's "somebody carried a sleeping young man").
- MISSING in text: hints that she knew him before (canon: childhood friend). One guarded slip in `prologue.rescuer.2` or `.4` ("You used to...
  never mind") pays off in `dungeon.dg_lab_rescue.before` ("I told them nobody could be that stubborn").
- MISSING: Siphon's view of her (canon: "just confused", will come home). `dungeon.dg_lab_boss.before` could add one line about "my
  assistant who left" without naming or saying daughter.
- CODE: Cave Mouth scenes after each zone; the castle abduction.

### 4.6 The lieutenants [canon, not built]
No scenes exist. Safe mentions inside existing keys only, never a fight or a reveal: Quota's stopwatch at the Regime Checkpoint
(gainlands `dungeon.hg_checkpoint.blurb`), Crumb's seal on war-effort posters (gourmand `sign.*`), Plume as the loudspeaker voice (capital
`facade.speaker.*` may sign off "This has been your Deputy Minister of Good News"), Clipwell's tidy decrees (refusemancer `sign.*`). Never
name them in a way that contradicts the bible (they flee to the Capital later).

## 5. Callback pairs (A sets up, B pays off)

| # | A: set-up (file: key) | B: pay-off (file: key) | Status |
|---|---|---|---|
| C1 | Flex: "They took my weights. They forgot to take me." / "it was not the part that matters" (gainlands `cutscene.flex.3`, `dungeon.hg_boss.after`) | Wanderer, phase 1 (capital `cutscene.primm_p1.2`) | WEAK: B paraphrases instead of quoting |
| C2 | Grand Chef: "not a flaw, it is a blank page" (gourmand `freed_npc.grandchef`) | Wanderer, phase 2 (capital `cutscene.primm_p2.2`) | WEAK |
| C3 | Agnes: "Never let anyone file you under 'subject' again" (dna `freed_npc.agnes`) | Wanderer, phase 2 (capital `cutscene.primm_p2.2`) and Siphon's "Subject 1" (dungeon_content `dungeon.dg_lab_boss.*`) | WEAK in p2.2; OK vs Siphon ("You are not a Subject") |
| C4 | Compostella: "do not bury it in a jar" (refusemancer `freed_npc.compostella`) | Wanderer, end (capital `cutscene.primm_end.3`) | WEAK |
| C5 | Agnes stamped the funeral forms; the third never filed (dna `npc.dolores.return`) | "Remains: not on file. Irregular." (dna `dungeon.ha_records.before`) -> kept in her drawer (dna `npc.dolores.intro.freed`) -> HEIR: ALIVE. FILE COMPLETE. (capital `ending.beat.10`) | OK, the strongest chain |
| C6 | Old Man Mountain: the boy with "four colours in his hands" (gainlands `npc.brenda.return`) | "you made the same face he did" (gainlands `npc.brenda.intro.freed`) -> "I kept your face" (capital `cutscene.primm_reveal.3`) | OK |
| C7 | Basil: the four-layer cake, the fake Chef forgot it (gourmand `npc.odalys.return`) | "Is the boy all right?" (gourmand `npc.odalys.intro.freed`) | OK |
| C8 | Bramble: eleven royal birthday trees (refusemancer `npc.marigold.return`) | Compostella plants a twelfth (refusemancer `npc.marigold.intro.freed`) -> portraits that "stop at eleven" (capital `cutscene.primm_reveal.1`) | OK |
| C9 | Bramble: somebody carried a glowing young man through the woods (refusemancer `npc.marigold.return`) | the Rescuer: "I am sorry I could not carry you farther" (intro `postgame.rescuer.freed`) | OK; fix "A few months back" |
| C10 | The Warden: "a house I used to keep" / "Someone is waiting there with a kettle on" (intro `tutorial.warden.*`) | Maren at the door (intro `cave_mouth.maren`) | WEAK: Maren has pie, no kettle. Give her the kettle (one clause) |
| C11 | memory 1: a woman humming a wordless tune (intro `memory.1.fragment`) | the throne: "the lullaby" returns (capital `ending.beat.8`) | OK |
| C12 | memory 2: "the Subject", "again" (intro `memory.2.fragment`) | ward notes "SUBJECT 1" (capital `dungeon.pc_ward.before`); Lab "Subject 1 is not to leave the chair" (dungeon_content `dungeon.dg_lab_drain.before`) | OK |
| C13 | Maren: "I helped to blow that glass" (intro `memory.3.after`) | the ward's oldest notes signed "M." (capital `dungeon.pc_ward.before`) -> Siphon: "Maren said so" (dungeon_content `dungeon.dg_lab_boss.after`) | OK |
| C14 | Maren's handwriting on a pie recipe (MISSING; add to `town.elder.stage.1` or `memory.1.after`) | "You have seen that handwriting on a pie recipe." (capital `dungeon.pc_ward.before`) | MISSING set-up |
| C15 | Primm's journals: Year 1, wells (capital `event.pc_early_journals.body`) | "I find that I miss the wells." (capital `freed_npc.primm`) | OK |
| C16 | Brannoch: "My girl Isla went up that road eight years ago" (intro `town.guard.capital_offer`) | Isla comes home | CODE (no Isla, no key). Interim: `town.guard.capital_done` can say he is still watching the road |
| C17 | Gerald 4,000,212; Agnes greets the player as 4,000,213 (dna `dungeon.ha_number.before`) | Mortimer is 4,000,214, "right behind Gerald" (dna `cutscene.vacancy.6`, `freed_npc.mortimer`) | WEAK: the lobby ticket says 40,001 (`dungeon.ha_lobby.before`, `dungeon.ha_number.blurb`, `event.ha_take_a_number.body`). Make the player 4,000,213 everywhere so 212-213-214 lands |
| C18 | Rollo's crews: "we were told it was cardio" (capital `npc.rollo.intro`) | Gus's Gainlands wheels at 110 percent (gainlands `npc.gus.intro`) | MISSING link: Rollo can say he trained under the Gainlands wheel crews; Gus can mention "the city wheels" |
| C19 | The Special Sauce in every pot (gourmand) | Primm cannot taste (capital `quest.cap_recipes.ready`) and the paste | OK; the Grand Chef boon can nod to it |
| C20 | The D.N.A. transfer, "valid" (dna) | Primm's "FORM 1-A... I needed only to be correct" (capital `dungeon.pc_wing_necrocrat.before`) -> "It was never right." (`.after`) | OK |
| C21 | The seed tag "PROPERTY OF THE PATH-OLOGISTS" (refusemancer `dungeon.rh_roots.before`) | the castle greenhouse seed (capital `dungeon.pc_wing_refusemancer.before`) -> the Lab (postgame) | OK |
| C22 | Hesper: "It began the night the boy got out" (capital `npc.hesper.intro`) | the lost-property poster (capital `prop.lost_poster` / `.known`) | OK |
| C23 | Wren: "Maren... sent word that someone might come" (capital `npc.wren.intro`) | Maren: "Wren leads it, from a hideout in the Capital" (intro `memory.2.after`) | OK (works in either order) |
| C24 | Brick: "rumours of the old man who never broke" (canon) | Flex freed | MISSING in Brick's text (and CODE for his freed lines) |
| C25 | Rip: "you know that forest where you all started out?" (intro `travel.forest_tip`) | the Lab hatch (dungeon_content `dungeon.dg_lab_hatch.before`) | OK |
| C26 | Primm's floor "polished by seventeen people" (capital `cutscene.primm_intro.1`) | "tell the Wrinkles... I am sorry about the hats" (`cutscene.primm_end.8`) | OK; keep both |
| C27 | Shiro: "come and meet me where it all began" (`ninja_boss.gd`) | the first chest duel | OK |

---

## 6. Per area

### 6.1 The opening: forest, prologue, the Forgotten Cave, the arrival

Beats: the wake (`still.wake`); the Rescuer and the Path choice (`prologue.*`); self-talk at the treeline (`prologue.self_talk`); the cave
gate (`start.gate_prompt`); the cave's node text (`trial_of_the_hollow.gd`); the Warden (`tutorial.warden.*`); the first battle tips
(`tutorial_layer.gd`); Maren at her door (`cave_mouth.*`).

Must land: he has no name and feels all four Paths faintly; the Rescuer is a friend who cannot stay; the cave is an old royal tunnel; the
Warden knows him without saying so; Maren expected "a stranger", not who.

Weak / missing:
- `awakening_lines` ("Where am I?", "My head... I remember a kingdom. Four Paths.", "...There. Light, through the rocks. That must be the
  way out.") is still shown (`starting_area_scene.gd` `_play_awakening_lines`, right after `still.wake` and before the Rescuer). It is written
  for the old cave wake: he is in an open clearing, the still has just shown the hooded Rescuer kneeling beside him, and he should remember
  nothing. Rewrite as two or three short self-talk lines that lead into `prologue.rescuer.1` (keep the array; five entries is fine).
- `prologue.rescuer.1` "lighter than a sack of feathers" is a cliché; the beat (she knows how starved he is) should feel like a medic, not a joke.
- `start.gate_prompt` "The stranger said the town is on the other side" - fine, but he never learned the Rescuer's name: keep "the stranger".
- C10: the Warden's kettle has no pay-off at Maren's door.
- 4.2: the cave's dry spring is never mentioned (`trial_of_the_hollow.gd` node 3 and 5).

Priority: 1 `awakening_lines` (the first words of the game, and wrong today); 2 `cave_mouth.maren` + `town.elder.first` (first impression
of the lead NPC); 3 `prologue.rescuer.*` (add one guarded slip, 4.5); 4 `tutorial.warden.*`; 5 cave node text.

### 6.2 Crosspath

Beats: Maren's stages and progress lines (`town.elder.*`), the memories (`memory.N.*`), Brannoch (`town.guard.*`), the vendors, the four
gatekeepers (arrays + `gate.*`), the Undercroft (`town.arena.*`, `arena.*`), the Alchemist (`town.alchemist.*`), the armory quest
(`quest.armory.*`), Rip (`travel.*`), Shiro, the Four Seals, the Restless Cairn (`graveyard_*`), Brindle (`BAKER_LINES`), the Door Under the
Well (dungeon_content `quest.side_s_town.*`), the Secret Dealer (hands off).

Mini-stories: Maren's slow thaw (stage 0 -> 4); Brannoch and Isla; Bertram's protocols and the armory; the cellar that cheers; the Alchemist
in the sink.

Weak / missing:
- `memory.4.after` lacks the "I knew" admission (4.3).
- No Maren line carries the stick (4.1), her handwriting (C14), "That's no prince" (4.3), Siphon (4.3), or her distrust of the Rescuer.
- `town.alchemist.locked`: "THE USURPER CONFISCATED MY CAULDRON... - Z.V." - banned signature Z.V.; use `{villain}` or keep "THE USURPER" as
  the one allowed in-character use, and sign it "- A." (Auntie Alembic).
- `arena.arena_marshal.blurb` "She has not lost a bout in eleven years" - Bellows is he.
- `world/town_scene.gd` arena prompt "Enter the Grand Clashatorium" - banned name (code string).
- Gatekeeper victory arrays replay after the zone is freed: "Chancellor Clench runs the Gainlands now" (beefcake), "Archdruid Compostella
  was taken first" (refusemancer). Rewrite them to be true before and after where possible (CODE for real freed variants).
- `BAKER_LINES[2]` "Heard the bridge to the Capital creaks at night" - the Capital road has an arch, not a bridge.
- npcs.json barks: Agnes "That book was due in 1847... This is a library" (she is not a librarian); townsfolk "My cousin's a dragon" (no
  dragons in Patchwork); Primm postgame "I am sweeping the square" (he is in a locked workshop under guard).
- `town.guard.capital_done` does not mention Isla (C16).
- `town.elder.return` "Everybody here is counting on you, no pressure." fine; `progress.3` "I will say it is a lot of feelings." fine.

Priority: 1 `town.elder.*` and `memory.N.*` (the emotional spine); 2 `town.guard.*`; 3 gatekeeper arrays (make them survive the freed
state); 4 vendors' `first` lines (distinct voices: Sable, Tilly, Bertram, Pip, Fenwick, Alembic); 5 Undercroft; 6 Rip; 7 barks; 8 Brindle.

### 6.3 The Gainlands (Beefcakes)

Lesson: strength comes from the heart and the mind. Mini-story: the Lifting Festival boy (C6). Beats: Brick at the bridge; Old Man
Mountain's welcome (`npc.brenda.intro`); the three favours (`quest.gain_*`); the House of Gains (`dungeon.hg_*`); the rescue
(`event.hg_rescue.*`, `cutscene.rescue.*`, where the Wanderer feels the cell is familiar); Flex vs Clench (`cutscene.flex.*`,
`dungeon.hg_boss.*`); Flex's closing line; the freed zone (`*.freed`, `zone.complete.beefcake.*`).

Weak / missing:
- `still.flex` "Ten years of prison food had taken his meals. They had not taken his muscles." - contradicts the lesson (he is frail; the
  strength is heart and mind). Rewrite to stillness and breath.
- `quest.gain_power.offer` "A protein shake from Tony's stand" - stale name (Benchley).
- `quest.gain_power.done` "Gus would hug you, but Gus is allergic to humility" - Gus speaking of himself in third person; reads like another speaker.
- `npc.tony.intro` "I'm Coach Brutus Benchley. Yes, I know. Everything's relative." - leftover of the retired "Tiny Tony" joke; no set-up left.
- `travel.ripper_calf.locked` "Finish her 'Spot Me!' quest" - Old Man Mountain is he.
- `dungeon.hg_checkpoint.blurb` - a chance for Quota's stopwatch (4.6), optional.
- C24: no Brick line about the old man who never broke.
- C18: no link from Gus's wheels to the Capital's wheel crews.
- `dungeon.hg_boss.before` box 3 is about 230 characters with two quotes; split.

Priority: 1 `cutscene.rescue.*`, `cutscene.flex.*`, `dungeon.hg_boss.*` (the leader reveal, played straight); 2 `npc.brenda.*` (the
mini-story); 3 `still.flex`; 4 quest offers (clear instructions); 5 Gus, Benchley, Gary; 6 Pump, Chet; 7 throwers.

### 6.4 The Endless Buffet (Gourmands)

Lesson: what you are called does not matter; what you do does. Mini-story: the four-layer cake (C7). Beats: Gravois at the pantry door;
Basil's welcome (`npc.odalys.intro`); the favours; the Test Kitchen (`dungeon.tk_*`, the whistleblower and the canteen cook carry "she never
tastes"); the reveal (`cutscene.reveal.*`); dinner proves who she is (`cutscene.wonder.*`); she gives her name away; Escoffina's
apprenticeship (`freed_npc.escoffina`); the Grand Chef's closing line.

Weak / missing:
- `npc.odalys.return` "The Grand Chef has very good hearing, for a man who does not eat." - the Chef (and the double) is she.
- `event.tk_whistleblower.body` "He does not taste the soup... He never tastes the soup." - she.
- `cutscene.reveal.5` "Behold the true dish of {villain}: the Doppelgänger." and `npc.odalys.intro.freed` "It was a doppelgänger!" - no
  umlaut; and "the true dish of {villain}" is cartoonish. The reveal should be colder and sadder (it forgot its own face).
- `cutscene.reveal.3` "Soup is for the weak. {villain}'s orders are for the strong." - villain-speak; make it the Chef's words with no warmth.
- `cutscene.wonder.5` is about 300 characters in one box; split into two or three.
- `dungeon.tk_boss.before` "Do you know what the future tastes like? Obedience." - a little cackly; acceptable, could be quieter.
- Crumb mentions (4.6) optional.

Priority: 1 `cutscene.reveal.*` and `cutscene.wonder.*`; 2 `npc.odalys.*` (the mini-story and pronouns); 3 `freed_npc.grandchef/.escoffina`;
4 `dungeon.tk_*` / `event.tk_*` pronoun fixes; 5 quests and vendors; 6 golems, Flambe, Pate.

### 6.5 The D.N.A. (Necrocrats)

Lesson: everyone deserves humanity, even the dead; no order outranks respect. Mini-story: the unfiled form (C5). Beats: Prudence at the
barrier; Agnes at the front desk (`npc.dolores.*`); the favours; the Hall (`dungeon.ha_*`, Agnes guiding at `ha_number`, `ha_forms`,
`ha_records`); Vellum; Mortimer; the vacancy (`cutscene.vacancy.*`); Agnes's closing line; Gerald's number called.

Weak / missing:
- C17: ticket 40,001 vs Agnes's "Number 4,000,213" vs "NOW SERVING: 3". Pick 4,000,213 for the player; keep "serving 3".
- `npc.dolores.intro` "We're serving number one. Have been for seven hundred years." - clashes with the running gag "They're on 3". Make it 3.
- `npc.matching.intro` "Last employee of the month of 2003... That was my snack. In 2003... returned in 2001" - Kyle is Deceased Since '09;
  move his years to 2009.
- `dungeon.ha_records.before` "the Necrocrat Path, signed over to Primm" - literal name; use `{villain}`.
- `dungeon.ha_boss.before` box 1 is long (about 210 characters); split.
- `freed_npc.agnes` is seven boxes; tighten, keep the four sincere sentences exactly ("Even the dead deserve humanity...").

Priority: 1 `dungeon.ha_records.before`, `cutscene.vacancy.*`, `freed_npc.agnes` (the heart); 2 `npc.dolores.*` (the form, the numbers);
3 the number fix across `ha_lobby/ha_number/event.ha_take_a_number`; 4 Gerald; 5 Mortimer and Vellum; 6 Kyle (years), Ledgerbone, Ectomund;
7 memos and posters.

### 6.6 The Verdant Dump (Refusemancers)

Lesson: to grow, you have to let things go. Mini-stories: eleven birthday trees and the twelfth (C8); the carried young man (C9). Beats:
Moss Mulligan at the thorns; Bramble's welcome (`npc.marigold.intro`); the favours; the Rotheart (`dungeon.rh_*`, the pool with Bramble's
notes, the seed tag at `rh_roots`); the boss (`dungeon.rh_boss.*`); the sever (`cutscene.sever.*`); Compostella's closing line.

Weak / missing:
- `npc.marigold.return` "A few months back, somebody carried a sleeping young man..." - say "not long ago".
- `cutscene.sever.1` "It is the seed. Primm's gift: life that never dies." - literal name; use `{villain}`'s gift.
- `cutscene.sever.4` "Thank you. {villain}'s grip on the living world is broken." - flat exposition at the emotional peak; end on her, not
  on the plot.
- `quest.heap_herd.done` "Druid Sorrel at the stream owes you a bridge, by the way." - Sorrel exists nowhere; cut or name a real NPC.
- Quest-log summary for `heap_dam` (`zone_quest_definitions.gd`) "she will reward you" - Bramble is he; Root Cause summary
  (`quest_definitions.gd`) "a voice that isn't his" - Moss is she (code strings).
- `npc.marigold.intro` is nine boxes; the exposition (what Refusemancers do) can be two.
- Clipwell mentions (4.6) optional.

Priority: 1 `cutscene.sever.*` and `dungeon.rh_boss.*`; 2 `npc.marigold.*` (both mini-stories); 3 `freed_npc.compostella`; 4 quests;
5 Gristle, Wren Muckfoot; 6 Thistlewick, Rhonda, workers.

### 6.7 The Capital (Primm's Perfection, then Pathordia)

Beats: the gate (Spotless) or the tunnels (Kestrel, S-CAP); the Crease (Wren, Hesper, Fig); the facade (citizens, doors, loudspeakers);
the four Path quests and Wren's four insights; the posters; the rifts; Citizen 4471; Brannoch's Isla (canon, not built).

Must land: jokes quieter than in the zones; every citizen line is approved -> off -> whisper; each quest's `.ready` gives one true insight
into Primm, which Wren turns into "a man who made a list of everything he could not control, and made it illegal".

Weak / missing:
- Literal "Primm" about 65 times in `capital_story.tres` (quest `.ready/.done`, `debuff.*.flavor`, `npc.wren.intro`, ward notes, ending,
  cutscenes, `npc.marlo.intro` "Primm's Perfect Nutrient Paste"). Replace with `{villain}` where it is the name; keep "Primm's Castle"
  titles only if they are `.title` keys (still better as tokens). Product names like "Perfect Nutrient Paste" can be "{villain}'s".
- `npc.kestrel.intro` (dungeon_content) "Quiet. Primm's enforcers walk this road on the hour." and `.return` "The road is clear. For now." -
  flat; Kestrel is quick and playful; also a literal name.
- `facade.speaker.*` never identifies the voice; optional Plume sign-off (4.6).
- `freed_npc.heartlift` (capital) "I once taught a mill to run backwards. You are better than the mill." - random; give Flex a callback
  (the heart and the mind, the wheels slowed).
- `boon.refusemancer.line` "'To grow, you have to let things go,' she says, 'and then let it grow.'" - clumsy repeat of "grow".
- `npc.wren.intro` is six boxes; tighten to four.
- C16 Isla, C18 the wheel crews.

Priority: 1 `npc.wren.*` (and insights); 2 `quest.cap_*` (four serious beats; tokens); 3 `facade.citizen.*`; 4 Spotless; 5 Pell, Rollo,
Marlo, Fern; 6 guards and clerks; 7 Kestrel (dungeon_content); 8 Hesper; Fig Sly hands off.

### 6.8 Primm's Castle and the ending

Beats: the four wings' clipboard notes with the shaky margins (`dungeon.pc_wing_*`); the Private Gallery, "KEPT FOR REFERENCE"
(`dungeon.pc_gallery.*`); the ward records and "M." (`dungeon.pc_ward.before`); the portraits (`event.pc_improved_portraits.*`); the honest
mirror; the Archive and journals (`event.pc_early_journals.*`, `event.pc_last_journal.*`); the Model Room (`dungeon.pc_boss.*`); the reveal
(`cutscene.primm_reveal.*`); the three phases; the boons (`boon.*`); his end (`cutscene.primm_end.*`); the ten ending beats.

Tone: nearly no jokes from the castle gate on. Primm's polish is the only humour, and it stops at phase 2.

Weak / missing:
- C1-C4: the Wanderer's phase answers lecture (section 3).
- `cutscene.primm_intro.3` generic (section 3); `cutscene.primm_end.6` "It is not too late to say sorry." - flat; make it smaller and
  harder (he is choosing not to kill him).
- `cutscene.primm_p2.5` "I only wanted it to be nice!" - keep (bible line).
- `cutscene.primm_reveal.5` "Come. Let me show you the one thing in this kingdom that is truly mine, and truly yours: your power." -
  slightly villain-speak; keep the meaning (his power was never his), make it sincere-and-wrong.
- `ending.beat.10` "'Tessar,' she says." - use `{prince}`.
- `ending.beat.6` and `.9` are long, explaining the theme; trim to images.
- `ending.credits.6` names real asset sources (Kenney, KayKit, game-icons.net): credits, not dialogue; leave (they are attributions, not
  brand jokes).
- Elowen's abduction (canon) is CODE.

Priority: 1 `cutscene.primm_*` (all); 2 `ending.beat.*`; 3 `dungeon.pc_gallery.*`, `dungeon.pc_ward.before`; 4 the wings; 5 journals and
portraits; 6 boons; 7 the remaining node blurbs.

### 6.9 Side dungeons, secrets and postgame (brief)

- **S-TOWN** (Maren, the Automaton): `quest.side_s_town.*`, `dungeon.dg_s_town_boss.*`. OK. Land the crest (4.1) lightly.
- **S-BEEF / S-IRON / S-GOUR / S-NECRO / S-REF / S-CAP**: `quest.side_s_*`, `dungeon.dg_s_*_boss.*` in dungeon_content. Mostly OK;
  `quest.side_s_necro.offer` "There is a ghost in the Waiting Room... clutching a very old ticket" is Gerald talking about himself in third
  person: let him own it ("My number is 4,000,212").
- **Shiro** (`ninja_boss.gd`): OK; keep "SMOKE BOMB!!!" and "the oldest trick in the book".
- **The Four Seals** (`vault_guardian.gd`): OK.
- **Postgame**: Rip's tip (`travel.forest_tip`) OK; the Lab (`dungeon.dg_lab_*`) OK and strong ("familiar in the way a bruise is
  familiar"); `dungeon.dg_lab_boss.before` "Primm's rule was always a bit crude" - literal name; the Rescuer's lines keep the `[revealed]`
  tag and withhold the name; postgame Primm (`freed_npc.primm`, `freed_npc.primm_guard`) OK.

Priority: Lab and Rescuer first (they close the prince's arc), then side bosses, then side givers.

## 7. Top weak lines (summary)

0. intro `awakening_lines`: the game's first spoken words describe the old cave wake ("Light, through the rocks. That must be the way out.")
   and a remembered "great, bright city", right after the forest still: wrong place, and it breaks the amnesia.
1. capital `cutscene.primm_p1.2` / `primm_p2.2` / `primm_end.3`: the Wanderer lectures the four lessons instead of quoting the leaders.
2. intro `memory.4.after`: no "I knew all along" admission from Maren (sheet canon).
3. intro `town.elder.first`: a six-box exposition wall as the lead NPC's first real talk.
4. gainlands `still.flex`: "They had not taken his muscles." contradicts the zone's lesson.
5. gourmand `npc.odalys.return` "for a man who does not eat" and `event.tk_whistleblower.body` "He does not taste the soup": wrong pronoun.
6. gourmand `cutscene.reveal.3/.5`: "Soup is for the weak" / "Behold the true dish of {villain}: the Doppelgänger" (cartoon villain, umlaut).
7. dna `dungeon.ha_lobby.before` ticket "40,001" vs `dungeon.ha_number.before` "4,000,213" vs `npc.dolores.intro` "serving number one".
8. dna `npc.matching.intro`: Kyle's years are 2003/2001, not '09.
9. refusemancer `npc.marigold.return`: "A few months back" (timeline).
10. refusemancer `cutscene.sever.4`: "{villain}'s grip on the living world is broken." (exposition at the peak).
11. intro gatekeeper victory arrays: replayed after the zone is freed ("Chancellor Clench runs the Gainlands now").
12. capital: about 65 literal "Primm" in story text (tokens), plus `ending.beat.10` "Tessar", `cutscene.sever.1`, `dungeon.ha_records.before`,
    `npc.kestrel.intro`, `dungeon.dg_lab_boss.before`.
13. gainlands `npc.tony.intro` "Yes, I know. Everything's relative." and `quest.gain_power.offer` "Tony's stand" (retired Tiny Tony leftovers).
14. intro `town.alchemist.locked` signed "- Z.V." (banned) and `arena.arena_marshal.blurb` "She has not lost a bout" (Bellows is he).
15. dungeon_content `npc.kestrel.intro/.return`: flat guard-speak for the most playful character in the Capital.

Also: `travel.ripper_calf.locked` "her 'Spot Me!' quest"; `quest.gain_power.done` third-person Gus; `quest.heap_herd.done` "Druid Sorrel";
`boon.refusemancer.line` "and then let it grow"; capital `freed_npc.heartlift` "taught a mill to run backwards"; barks: Agnes's library,
the townsfolk dragon, Primm "sweeping the square"; `BAKER_LINES[2]` "the bridge to the Capital"; C10 kettle; C14 handwriting; C17 numbers.

## 8. Needs beyond text (for the inbox, not for writers)

- Freed-zone variants for the four gatekeepers' town lines (`town_scene.gd:1269`).
- Isla's homecoming (no NPC or key); Brannoch's reunion.
- Elowen's Cave Mouth scenes and the castle abduction; her name (open question).
- The lieutenants' cameos and fights; Plume's ribbon-cuttings.
- Old Hob (no NPC in game; `npc.hob` is Granny Gristle).
- A fountain "E to read" text (the crest).
- The Old Well secret quest (Part 6) keys.
- `npcs.json` still names the baker "Bun the Baker" (players see Brindle).
