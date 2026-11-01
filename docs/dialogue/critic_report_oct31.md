# Dialogue critic report (Oct 31 2026)

A fresh-eyes critique of all 4,203 player-facing lines in `docs/dialogue/edit_oct27.csv`, read in story order. Eight readers each took one
part of the game (chunks in `docs/dialogue/critic_oct31/chunks/`), then the lead read every suggestion. Per-area notes with row numbers:
`docs/dialogue/critic_oct31/notes_01.md` to `notes_08.md`. The suggestions: `docs/dialogue/critic_suggestions_oct31.csv` (210 rows).
The voice and register brief: `docs/dialogue/voice_bible.md`.

Source note: the critique judges every line as it stands in the game. The designer's 37 rewrites (typed over "Current line" in the
sheet, found after this report; all in the prologue, the cave and Maren's first talks) are not in the scores; they set the voice now
(`voice_bible.md` section 1). Answers to this report's questions and what was changed: `docs/dialogue/fixes_oct31/README.md`.

## The short version

**The dialogue is already good, and in places excellent.** That is the main finding. Most areas score 7-9 for writing. Nearly every
recurring NPC passes the "cover the name plate" test. The zone signs are the best comedy in the game. The sincere beats (the memories, the
royal funeral, Cell 4, Citizen 4471, the sever scene, Gerald's number) are judged well and should not be touched. That is why only 5% of
lines got a suggestion (210 of 4,203). About a third of all rows are UI, rule text, titles and Quest Log steps, and those are already clear.

The real weaknesses are not spread evenly. They are concentrated in four places:

1. **The Oct 21 outside pass flattened the ending and the castle.** Almost 60 of the 210 suggestions undo it. Stills, boons, node blurbs and
   the ending beats were rewritten into "You see... / You watch..." camera narration. Primm's intro and the Wanderer's answers lost their
   callbacks. The freed Capital lost its giddiness. `docs/dialogue/chatgpt_pass_oct21/review_flags.md` already lists most of these, and
   none of those flags has been reverted. The suggestions restore the specific image, tightened where a rule now requires it (present
   tense, tokens, tested phrases). Examples: "all in the wrong places, and somehow they look better"; "This will not hurt. It will,
   however, be Standard."; the four Paths arriving late, with a form, overdressed, smelling of compost.
2. **The world is under-explained in the zones, even though the facts exist.** The two Path rivalries (Beefcakes vs Necrocrats, Gourmands
   vs Refusemancers) appear almost only in debuff tooltips; no NPC voices them. Primm's genuinely good early reforms, which make him tragic
   (clean wells, standard measures, school lunches), are named nowhere before the castle. "Death froze when the D.N.A. was seized" lives
   only in Old Hob's scene. Clipwell's composting ban arrives cold. The suggestions place each fact once, in an idle line or a sign, from a
   speaker who has a reason to say it.
3. **Exposition dumps at the start of each zone.** The first NPC in each zone opens with a textbook sentence about what their Path does:
   Old Man Mountain's "brochure", Basil's "Every plate is a promise", Bramble's "druids of waste removal and agriculture". Maren and
   Brannoch also tell the same four-Paths history in nearly the same words. Each is rewritten to keep the facts and add a turn.
4. **Repeats and borrowed tics.** Some characters repeat themselves: Betty Bones says one line twice, Clipwell's mid-fight line repeats her
   intro, Quadzilla's payoff repeats his bark, Pate repeats his own roux bark, and the soup joke and the lettuce pun are each used twice.
   Some lines borrow from the wrong owner: Crumb shouts Spotless's "HALT", Gus uses Benchley's caps, Betty uses Mortimer's "irrelevant",
   and the Dump uses the Buffet's "cool head" and Benchley's "footing". Each is small, but together they blur voices that are otherwise
   sharp.

Smaller patterns:
- **Tutorial boxes drop the voice.** Sable's, Alembic's and Tilly's rule explanations could be any shopkeeper.
- **"Eleven" is spent on throwaway numbers.** It is a story clue (the prince was eleven), but it also appears as Spotless's "eleven
  thousand visitors", Quota's "four hours and eleven minutes" and Primm's "eleven feet tall" portrait.
- **A few canon contradictions in light lines.** Kyle's freed number is still "four hundred years" away after Agnes called every number.
  Agnes "stopped counting" appeals she counts elsewhere. A Capital sign says nobody has run the wheels, in the district where the wheels
  never stop.

## What works (keep it)

- **Maren** is the game's best recurring voice: pie as deflection, "1987", "dependable at a speed you can barely measure", "My knees have
  voted against it." Very few of her lines needed anything.
- **The signs**, in every zone: "The soup of the day is soup.", "Having a height is, on balance, a violation.", "Every patch is fertilized
  by the same goat.", "Civilization rests on the hamsters not finding out what a salary is."
- **The sincere spine:** the memory fragments ("I wasn't lost. I was kept."), the royal funeral, Isla, Cell 4 ("Took you long enough,
  Tess."), Siphon's chilling cheer, Clipwell's "if nothing ever ends, then nobody ever has to cry again", Gerald's "CALLED".
- **Setups and payoffs:** Gerald 212 / the Wanderer 213 / Mortimer 214; Benchley's floorboard; Brick's "Maintenance is how I say sorry";
  the Perfectly Happy Citizens' approved, then slightly off, then whispered slips; the "Improvement Opportunity" posters.
- **Quest Log and battle UI:** clear, names places and things, and keeps every number. Nothing needed.

## Area by area

Scores are for the current lines, 1-10. Each comes from that area's reader and was checked by the lead. Humour is scored against what the
beat should have: a sincere scene is not marked down for having no jokes. Sub-area scores are in the notes files.

| Area | Writing | Humour | Worldbuilding | In one line |
|---|---:|---:|---:|---|
| Prologue (forest, cave, cave mouth) | 8 | 6 | 7 | Tight, physical, good clues; the treeline stops never say where the cave is |
| Crosspath, first visit | 7 | 7 | 6 | Maren and the vendors are memorable; tutorial boxes lose the voice; the history is told twice; little lore beyond the four Paths |
| Gainlands (incl. gatekeeper, S-IRON, House of Gains, after freeing) | 7 | 7 | 6 | Great signs and side NPCs; corrupted Brick is generic shouting; Mountain's intro is a brochure; no rivalry and no Primm nuance |
| Endless Buffet (incl. Omakase, Test Kitchen, after freeing) | 8 | 7 | 7 | Excellent signs, a strong Test Kitchen; the "weapon" flinch and the rivalry are missing; a few repeats |
| D.N.A. (incl. Waiting Room, Hall, after freeing) | 8 | 8 | 7 | The tightest zone: deadpan holds, the queue thread and the vacancy land; "Death froze" carried by Hob alone; Betty is thin |
| Verdant Dump (incl. Trash Panda Throne, Rotheart, after freeing) | 8 | 7 | 7 | Bramble and the sever scene are superb; the compost ban and the rivalry are never set up; owned puns borrowed |
| Crosspath between zones (memories, Old Well, Vault) | 8 | 7 | 8 | The memories are the best sincere writing in the game; the earlier pass sanded off Maren's and the Well's jokes |
| The Capital (gate, facade, Crease, four quests, Paste Works, tunnels) | 9 | 8 | 7 | The strongest comic writing in the game; the hunt and Primm's reforms barely appear; small contradictions |
| Primm's Castle | 7 | 6 | 8 | The records, gallery and last journal are finished; blurbs, stills, boons and the fight intro were flattened by the earlier pass |
| The Capital after freeing | 7 | 6 | 7 | Good bones; the freed payoffs were flattened into reasonable cheer instead of giddy, crooked joy |
| Ending | 7 | 6 | 7 | The throne, funeral and Isla are superb; seven beats flattened into "You see" narration |
| Postgame (incl. Swolympus, the Path-ology Lab) | 9 | 8 | 8 | The Lab's ordinary horror and the Spotter's "That was the one" are the high points; one dev note shows to players |

**Whole game: writing 8, humour 7, worldbuilding 7.** The fastest way to raise humour and worldbuilding is the restoration rows and the
"seed" rows (rivalries, reforms, Death froze). The fastest way to raise writing is to accept the restorations in the castle and the ending.

## Characters who sound the same, or lose their voice

- Tutorial/rule boxes: Sable (`town.vendor.first`), Alembic (essence rule), Tilly (return line). Rewritten in voice.
- Gus's quest hand-in uses Benchley's caps and pep-talk energy; Chet's loss line is quiet, which his entry forbids.
- Betty Bones uses Mortimer's "irrelevant"; Colonel Crumb opens with Spotless's "HALT!".
- Rita and Ripley (rippers) both say "no tools... just lats"; Shredna repeats Old Man Mountain's "Nobody's been out there in months".
- The Wanderer's answers to Primm had turned into theses ("People are different. You know that."). They are restored to his own short,
  plain voice with the leaders' callbacks.

## Places with no story or direction

- The treeline stops in the prologue (the one place the game can name the way to the cave). Suggested, High.
- The Rescuer's farewell, which said "someone" will be waiting. It now names Elder Maren. Suggested, High.
- The Gravy Bank sign, where the three Buffet gates begin, never says how they open. Suggested.
- The Gainlands generic lock pop-up ("Not yet. Come back when you've done a few more reps.") gives no reason; per-spot lock lines exist
  (design note below).
- The Sauna of Truth deck test ("how hard do you lead?") does not say what it checks (design note).
- The Dump's HUD says the Rotheart is "to the north"; the Quest Log says "at the bottom of the Dump" (design note).

## Not line edits: design notes and bugs found

Bugs and data issues (no dialogue change needed, or the importer can't do it):
1. **Speaker labels in the export are wrong in places** (`tools/export_dialogue.js`):
   - The Paste Works quest lines (`dungeon_content.json::quest.cap_paste_works.*`) are credited to Elder Maren but belong to Chef Marlo.
     The exporter defaults every `quest.*` key to Maren (lines 141 and 229).
   - `fx.wake_outside` is a gate guard, not Nurse Hesper Dray.
   - The `.rushed` variants of `primm_p1.2`, `primm_p2.2` and `primm_end.3` are labelled Primm but are the Wanderer's lines. Check that
     the `.speaker` in `capital_story.tres` is right in game.
   - The Crosspath gatekeeper barks are labelled "(corrupted)", but they read as freed voices (see the inbox question).
   - Billie Muckfoot's rows are labelled with the retired name "Wren Muckfoot". The label comes from data; no player text says it.
2. **Literal names in story files** that should be tokens:
   - `story_scenes.json::scenes/lab_study/steps/3::1` says "Elowen...".
   - `dungeon_content.json::event.lab_cell4.body` says "Elowen". The importer cannot swap these, because `{rescuer}` has no fixed fill.
   - "THE SHOWCASE QUARTER" in sign headings (`prop.facade_arch`, `sign.facade_welcome::0`). A token would print it in lower case.
   - The two literal "Crosspath" lines in the Lab epilogue are now `{town}` suggestions (Fix, Low).
3. **A dev note shown to players:** `ending.postgame.line.2` says "(no tri-Path recipes exist yet)".
4. **Unit name mismatch:** the Trophy Hall Honor Guard's rule text says "a 1/1 Militia joins" but its banner says "A 1/1 Reserve Guard".
5. **Shared names:** two Gainlands hamster wheels are named "Gerald" and "The Colonel". This may be a deliberate wink; flagged against
   the no-shared-names rule.
6. **Credits** are still placeholders ("PLACEHOLDER CREDITS", "Design and direction: you").
7. **Spelling:** "parlor" (two lines) vs "parlour" (everywhere else); "four colors" (a tested phrase) vs "colour" everywhere else.

Continuity questions (also in the inbox):
- The Lab, alone path: "Her father held the door." Does the Wanderer know by then that Siphon is her father?
- Elowen's "You came for me. Twice, if you count the woods." In the woods, she rescued him.
- The Grand Chef's "You have been my prisoner for five minutes": a role-reversal joke, or a slip?
- Gerald's number is approved in the Waiting Room side dungeon and called again after freeing. Can the two beats double up?
- Mortimer is a skeleton, but his narration describes his "face".
- Druid Sorrel is narrated at the Dump's centre bridge. The voice bible says "no unseen Druid Sorrel".
- Rip's bark says shirt number 213, but the story bible's gag is 212 (213 is the Wanderer's D.N.A. number). Deliberate?
- The boss room has three names: "The Scale Model Chamber", "the Chamber of the Model" and "the Model Room".
- Who reads the freed Capital broadcasts? They are labelled Plume, but one says "Nobody is on the other end".

Content gaps that new lines (not rewrites) would fill:
- Only four Crosspath townsfolk barks carry the whole "watched town" mood. Add a rivalry line, a "Royal Asset" lost-property gossip
  line and a cousin who went up the Capital road.
- Fennel Gravois has no freed barks. A biscuits/plain-bread pair would keep him present after the gate.
- Old Hob's repeat scene in Crosspath plays the same answer every time. Rotate two or three.
- A decree sign in the Dump's Grange would set up Clipwell's composting ban ("DECREE: COMPOSTING IS UNTIDY. BY ORDER OF THE ROYAL
  GROUNDSKEEPER.").

## Suggestions at a glance

210 suggestions, all passing every check (Part 4 below): High 42, Medium 95, Low 73. By category: Humor 59, Voice 38, Natural 32, Story 29,
Worldbuilding 25, Clarity 14, Fix 13. By area: The Capital (castle and after freeing included) 70, Gainlands 31, Endless Buffet 26, Verdant
Dump 20, Crosspath first visit 18, D.N.A. 16, Ending 16, Crosspath between zones 8, Prologue 3, Postgame 2.

The lead dropped three agent rows and changed one; four rows are the lead's own (`docs/dialogue/critic_oct31/lead_edits.md`). The six
earlier review suggestions are all accounted for there: four are folded in, and two were already done (the awakening lines are down to
three; the defeat recap shipped).

## Validation (Part 4)

- `node tools/dialogue_critic_check.js --check=docs/dialogue/critic_suggestions_oct31.csv`: 210 of 210 pass. It checks: the ID exists and
  the effective line matches; tokens, `%s`/`%d` and `[tag]` are unchanged (a literal "Crosspath" may become `{town}`, as in the importer);
  every phrase a GUT test asserts is kept (multi-word test literals found in `tests/`, listed per line in
  `critic_oct31/protected_phrases.json`); no banned old name; no literal name where a token belongs; and the length caps (220 per box, or
  the current length if longer; barks under 90; Quest Log and event screens +25%). Report: `critic_oct31/check_report.md`. Dropped: none
  (`critic_oct31/dropped.md`).
- Dry run of the real importer on a temp copy with every suggestion accepted
  (`node tools/apply_dialogue_pass.js --csv=docs/dialogue/critic_oct31/dry_run/edit_all_accepted.csv`, including Godot's box-fit
  measure): **210 would apply, 3,993 blank, 0 conflicts, 0 failed validation, 0 held, 0 locked.** Report:
  `critic_oct31/dry_run/edit_all_accepted/apply_report_dry_run.md`. Nothing was applied.
- Caveat: the tested-phrase check is static. It catches a lost phrase that a test asserts, but not a test that, say, counts boxes in a key.
  After a real `--apply`, run the story GUT groups (`tests/core/dungeon`, `tests/core/data`, `tests/core/zone`, `tests/core/quests`,
  `tests/test_dialogue_*.gd`). Any failure goes in `held_ids.txt` and gets reverted with `--revert=`.
