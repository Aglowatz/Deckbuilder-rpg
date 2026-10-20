# Dialogue pass Oct 19: capital_main, editor review

Editor pass over the writer's work (`capital_main.md`). Files: `data/story/capital_story.tres` and the `"text"` block of
`data/dungeons/dungeon_content.json` (only `text` string values changed; the rest of the JSON is byte-identical, git hunks start inside the
`text` block). OLD = `pre-overnight-oct19`, NEW = the writer's commit `93cb6207`, FINAL = the working tree after this pass. Godot was not run;
nothing committed. Fig Sly is untouched. Keys, array lengths, `.speaker` values, tags, placeholders and tokens are unchanged (582 = 582 keys,
49 = 49 text keys; every edited array keeps its length).

Scores are 1-5 per axis: **C** in character, **F** funny (fit to the place: quiet in the castle and the ending is a 5 there), **B** story
beat landed, **Br** brevity, **Cl** clarity of what to do next (5 when there is nothing to do and nothing is unclear). A conversation's score
is the minimum of the five. Rows marked **edited** are the ones changed in this pass.

## Averages (81 conversations)

| | Old | New (writer, before edit) | Final |
|---|---|---|---|
| Average minimum | 3.41 | 3.98 | 4.11 |
| Conversations under 4 | 41 | 10 | 0 |

Conversations rewritten in this pass: **10** below 4 (all now 4+), plus 1 polish at 4 (the Honest Mirror). 14 values changed: 10 in
`capital_story.tres`, 4 in `dungeon_content.json`.

## The Capital streets (`capital_story.tres`)

| Conversation (keys) | Old | New | Final | C F B Br Cl | Change in this pass |
|---|---|---|---|---|---|
| Wren (`npc.wren.intro/.freed/.return/.return.freed`) | 3 | 4 | 4 | 5 4 5 4 4 | none (writer cut 6 boxes to 4; "tea and grudges" lands) |
| Wren's insights (`npc.wren.insight.1..4`) | 4 | 4 | 4 | 5 4 5 5 4 | none |
| Hesper (`npc.hesper.*`, `fx.wake*`, `fx.heal_*`) | 3 | 4 | 4 | 5 4 4 5 4 | none |
| Fig Sly (`npc.fig.*`) - hands off | 4 | 4 | 4 | 4 4 4 4 4 | none (black market rule) |
| Old Fern (`npc.fern.*`) | 3 | 4 | 4 | 5 4 4 4 4 | none |
| Untidy quest (`quest.cap_untidy.*`, `fx.pickup_compost/seed`, `fx.patch*`) | 3 | 4 | 4 | 4 4 5 4 5 | none |
| Widow Pell (`npc.pell.*`) | 3 | 4 | 4 | 5 4 4 5 4 | none |
| Burial quest (`quest.cap_burial.*`, `fx.plot*`, `fx.permit_*`) | 3 | 3 | 4 | 5 4 5 4 5 | **edited** `quest.cap_burial.offer` box 2: the stamp was hidden "where a real clerk might find it" while `.return/.active` say "among papers nobody reads" (Cl 3). Now the same clue in all three. |
| Rollo (`npc.rollo.*`) | 3 | 3 | 4 | 5 4 5 4 5 | **edited** `npc.rollo.return` box 1: the cable was "by the big wheel", the offer says "by the east wall" (Cl 3). Now "by the east wall". |
| Wheels quest (`quest.cap_wheels.*`, `fx.wheel_*`, `fx.cable*`) | 3 | 2 | 4 | 4 4 5 4 5 | **edited** `fx.cable`: 312 characters (Br 2). Cut to 222, same facts (cut cable, lamps flicker, his private generator). |
| Chef Marlo (`npc.marlo.*`) | 3 | 4 | 4 | 5 4 4 4 4 | none |
| Recipes quest (`quest.cap_recipes.*`, `fx.pickup_recipe`, `fx.paste*`) | 3 | 4 | 4 | 5 4 5 4 5 | none |
| Captain Spotless at the gate (`npc.spotless.*`, `ui.gate.*`) | 3 | 3 | 4 | 5 4 4 4 5 | **edited** `ui.gate.body`: 260 characters (Br 3). Cut to 216; all mechanics kept (hard card battle, HP carries in, nothing heals, lose and wake outside poorer). |
| Height guard (`npc.guard_height.*`) | 4 | 4 | 4 | 4 4 4 5 4 | none |
| Queue guard (`npc.guard_queue.*`) | 4 | 4 | 4 | 4 4 4 5 4 | none |
| Exit control (`npc.guard_in_1/2.*`) | 4 | 4 | 4 | 4 4 4 5 4 | none |
| Exit clerk (`npc.exit_clerk.*`) | 4 | 4 | 4 | 4 4 4 5 4 | none |
| Citizen 4471 / Aldous (`npc.patient.*`) | 4 | 5 | 5 | 5 5 5 5 5 | none (played straight) |
| Citizen 1 (`facade.citizen.1.*`) | 4 | 4 | 4 | 4 4 4 5 5 | none |
| Citizen 2 (Berta) | 4 | 4 | 4 | 5 4 4 5 5 | none |
| Citizen 3 | 4 | 4 | 4 | 4 4 4 5 5 | none |
| Citizen 4 (the smile quota, the funeral) | 3 | 5 | 5 | 5 5 5 5 5 | none ("He does not remember her laugh now" is the writer's best citizen line) |
| Citizen 5 | 4 | 4 | 4 | 4 4 4 5 5 | none |
| Citizen 6 (the bird) | 3 | 3 | 4 | 4 4 4 5 5 | **edited** `facade.citizen.6.slip` box 2: "The bird was fine." was a punchline on the slip line (voice bible: never). Now "(a whisper) I still think about that bird.", which also sets up the freed "I have named the bird Thursday". |
| Citizen 7 (the green hat) | 4 | 4 | 4 | 5 4 5 5 5 | none |
| Citizen 8 (the back door) | 4 | 4 | 4 | 4 4 4 5 5 | none |
| Citizen 9 (the portraits) | 4 | 4 | 4 | 5 4 4 5 5 | none |
| The four doors (`facade.door.*`) | 4 | 4 | 4 | 5 4 5 4 5 | none (door 3 plants Isla, unnamed) |
| Loudspeakers (`facade.speaker.*`) | 4 | 4 | 4 | 4 4 5 5 5 | none (Plume sign-offs) |
| Street signs (gate, facade, Reek, Grave Row, Transit Yards, Hungry Quarter, castle, Outskirts, plaza) | 4 | 4 | 4 | 4 5 4 5 4 | none |
| Crease signs (`sign.crease_*`) | 3 | 3 | 4 | 4 4 4 5 5 | **edited** `sign.crease_rules`: the list was split mid-item ("1. Say what you think. 2." / "Eat what you like..."), and signs join lines with a newline. Now "1." / "2. ... 3. ..." / "4. ...", 4 entries kept. |
| Street fx (inside, tunnels, manhole, defacing, complaints, rifts, travel, poster) | 4 | 4 | 4 | 4 4 4 4 5 | none |
| HUD, exit popup, debuffs (`hud.*`, `ui.exit.*`, `debuff.*`) | 4 | 4 | 4 | 4 4 4 4 5 | none |

## Primm's Castle (`capital_story.tres`)

| Conversation (keys) | Old | New | Final | C F B Br Cl | Change in this pass |
|---|---|---|---|---|---|
| The entrance (`ui.main.*`, `fx.main_dungeon*`, `dungeon.pc_gate/pc_hall`) | 3 | 3 | 4 | 5 4 4 4 5 | **edited** `ui.main.body`: 337 characters (Br 3). Cut to 225; mechanics kept (HP carries in, shrines only, broken-service debuffs on every duel). |
| The portraits (`dungeon.pc_portraits.*`, `event.pc_improved_portraits.*`) | 3 | 4 | 4 | 5 4 5 4 4 | none |
| Curator and the Forgotten Alcove | 4 | 4 | 4 | 4 4 4 4 5 | none |
| Mirrors (Mirror Knight, Hall of Mirrors, the Honest Mirror, the Quiet Room) | 4 | 4 | 4 | 5 4 5 4 4 | polish: `event.pc_honest_mirror.body` was split inside the note's quote; the note is now one box and "you see yourself" its own (2 entries kept). |
| The Ministry (desk, clerk, Chief Corrector) | 4 | 4 | 4 | 5 4 5 4 4 | none |
| The Corrected (`event.pc_corrected_citizens.*`) | 3 | 4 | 4 | 5 5 5 4 4 | none |
| Hall of the Four Wings (`dungeon.pc_junction.*`, `event.pc_four_wings.*`) | 4 | 4 | 4 | 4 4 4 4 5 | none |
| Gourmand wing | 4 | 4 | 4 | 5 4 4 4 4 | none |
| Beefcake wing | 4 | 4 | 4 | 5 4 5 4 4 | none |
| Necrocrat wing | 4 | 4 | 4 | 5 4 5 4 4 | none |
| Refusemancer wing (new margin "She was grieving": canon, story bible) | 4 | 4 | 4 | 5 4 5 4 4 | none |
| Grand Staircase (`dungeon.pc_servants/pc_staircase`, `event.pc_grand_staircase.*`) | 4 | 4 | 4 | 4 4 4 4 5 | none |
| The Archive (archive door, early journals, reading room, blueprints, Escalation Shelf, automaton) | 3 | 3 | 4 | 4 4 5 4 4 | **edited** `event.pc_early_journals.body`: the boxes broke across the two journal quotes ("It was wonderful.' 'Year 3..."); now one box per thought, 5 entries kept, "Year 1: Wells" wording kept. `challenge.pc_escalation_shelf.text`: 273 characters cut to 222; the rule (five cards, two infrastructure) unchanged. |
| The Last Journal (`event.pc_last_journal.*`) | 3 | 4 | 4 | 5 5 5 4 4 | none |
| The Private Gallery (`dungeon.pc_gallery.*`) | 3 | 5 | 5 | 5 5 5 5 5 | none |
| The Correction Ward (`dungeon.pc_ward.*`, "M.") | 4 | 4 | 4 | 5 5 5 4 4 | none |
| Model Warden and the Model Chamber (`dungeon.pc_model_warden.*`, `dungeon.pc_boss.*`) | 3 | 4 | 4 | 5 5 4 4 5 | none |
| `cutscene.primm_intro` | 2 | 4 | 4 | 5 4 5 4 5 | none ("That's forest mud") |
| `cutscene.primm_reveal` | 3 | 4 | 4 | 5 5 5 4 5 | none |
| `cutscene.primm_p1` | 2 | 4 | 4 | 4 5 5 4 5 | none (Flex callback) |
| `cutscene.primm_p2` | 2 | 4 | 4 | 4 5 5 4 5 | none (Grand Chef + Agnes callbacks) |
| `cutscene.primm_end` | 2 | 4 | 4 | 5 5 5 4 5 | none (Compostella callback; "Say sorry to one person") |
| Boons and phase rules (`boon.*`, `boss.phase.*`) | 3 | 4 | 4 | 5 4 5 4 5 | none |
| Ending beats 1-5 | 3 | 4 | 4 | 5 4 5 4 5 | none |
| Ending beats 6-7 | 3 | 4 | 4 | 4 4 5 4 5 | none |
| Ending beats 8-10 (Throne, Primm Sees, File Complete) | 3 | 4 | 4 | 5 5 5 4 5 | none |
| Credits, postgame card, return (`ending.credits.*`, `ending.postgame.*`, `ending.return`) | 4 | 4 | 4 | 4 4 4 4 5 | none |
| Flex in the Crease (`freed_npc.heartlift`) | 2 | 5 | 5 | 5 5 5 5 5 | none |
| The Grand Chef in the Crease | 3 | 4 | 4 | 5 4 5 4 5 | none |
| Agnes in the Crease | 4 | 4 | 4 | 5 4 4 5 5 | none |
| Compostella in the Crease | 4 | 4 | 4 | 5 4 4 5 5 | none |
| Primm postgame and his guard (`freed_npc.primm`, `.primm_guard`) | 4 | 4 | 4 | 5 4 5 4 5 | none |

## Side dungeons and the Lab (`dungeon_content.json` text)

| Conversation (keys) | Old | New | Final | C F B Br Cl | Change in this pass |
|---|---|---|---|---|---|
| Maren, the vault key (`quest.side_s_town.*`) | 3 | 4 | 4 | 5 4 5 4 5 | none (the crest lands) |
| The Automaton (`dungeon.dg_s_town_boss.*`) | 4 | 5 | 5 | 5 5 5 5 5 | none |
| Old Man Mountain (`quest.side_s_beef.*`) | 3 | 4 | 4 | 5 4 4 4 5 | none |
| The Ancient Spotter | 4 | 5 | 5 | 5 5 5 5 5 | none |
| Baron Quadzilla (S-IRON) | 4 | 4 | 4 | 5 4 4 5 5 | none |
| Basil, the reservation card (`quest.side_s_gour.*`) | 3 | 3 | 4 | 4 4 4 4 5 | **edited** `quest.side_s_gour.offer` box 1 opened "Psst. Over here.", word for word Fig Sly's opening (C 3: every NPC distinct). Now "Over here. Quietly. ... ...I'm brave. I'm brave." (Basil whispers). |
| The Itamae Supreme | 3 | 5 | 5 | 5 5 5 5 5 | none |
| Gerald, the queue (`quest.side_s_necro.*`) | 2 | 4 | 4 | 5 4 5 4 5 | none |
| Betty Bones | 4 | 5 | 5 | 5 5 5 5 5 | none |
| Brother Bramble, the compost thief (`quest.side_s_ref.*`) | 3 | 4 | 4 | 5 4 4 4 5 | none |
| His Majesty the Raccoon | 4 | 5 | 5 | 5 5 5 5 5 | none |
| Kestrel and the older way (`npc.kestrel.*`, `quest.side_s_cap.*`, `fx.old_tunnels_way_in`) | 2 | 3 | 4 | 5 4 4 4 5 | **edited** `quest.side_s_cap.active`: "Find the hideout in the Crease... knock three times on the manhole" never said which manhole (Cl 3); now "find the Crease: the manhole near the gate" (as `hud.objective.inside`). `npc.kestrel.return`: "That's the fun part" was used twice in a row (also in `.ready`); now "Chalk's still fresh." `quest.side_s_cap.done`: "the east end of the Outskirts" now "the north-east of the Outskirts, under the wall" (the tunnels' mouth in `capital_layout.gd`). |
| Captain Spotless in the tunnels (`dungeon.dg_s_cap_boss.*`) | 3 | 4 | 4 | 5 4 4 4 5 | none |
| The Lab hatch and the Drain (`dungeon.dg_lab_hatch/drain.*`) | 4 | 4 | 4 | 5 5 5 4 5 | none |
| The Rescuer's cell (`dungeon.dg_lab_rescue.*`) | 4 | 4 | 4 | 5 4 5 4 5 | none |
| Dr. Siphon (`dungeon.dg_lab_boss.*`) | 3 | 4 | 4 | 5 5 5 4 5 | none |

## Scan results (final)

- Boxes over 240 characters (tokens expanded to their longest names): none. Before this pass: `fx.cable` 312, `ui.main.body` 337,
  `challenge.pc_escalation_shelf.text` 273, `ui.gate.body` 260.
- Literal "Primm" in text: none (the 21 left are `.speaker` values, allowed). "Elowen", "Tessar", banned old names: none. "Pathwork" only
  in "the Pathwork Throne".
- Real brands: only `ending.credits.6` (Kenney, KayKit, game-icons.net). These are asset credits, not jokes, so left as they are (the beat map
  says the same).
- Mean-spirited jokes: none found. The one sincere-beat punchline (citizen 6's slip) is fixed.

## Needs code or the user

1. **Phase lines when a leader is not freed (CODE).** The castle can be entered with fewer than four zones freed, but `primm_p1.2`,
   `primm_p2.2` and `primm_end.3` always play the same text. The leader quotes still read as the Wanderer's own words, so nothing breaks, but
   naming the leader would need per-zone variant keys read by `CutsceneScreen` (the writer's note, confirmed).
2. **`primm_p1.2` "You took ten years from me" and `primm_end.3` "You took my mother and father"** fit both routes: either memory 4 or
   `primm_reveal` (played when not all four zones are freed) tells him who he is before phase 1. Both match the story bible (Primm killed the
   king and queen). Flagged only so that any change to the reveal order is checked against these lines.
3. **The callbacks depend on other writers keeping these phrases:** Flex "it was not the part that matters", the Grand Chef "blank page" /
   "something worth signing", Agnes "file you under 'subject'", Compostella "do not bury it in a jar".
4. **`ui.*` popups:** they are not checked by the fit test. Two were over 240 and are now trimmed, but they are not dialogue boxes.
   A popup-length check would be a test change (user's call).
5. Still open from the writer, all outside text: Wren / Wren Muckfoot name clash (inbox), Isla's homecoming, Plume as a named character,
   Elowen's abduction.

## Five best final before -> after (old -> final)

1. `cutscene.primm_p1.2` (You)
   - Old: "Because they are not the same, Primm. People are not the same, and strength is not control. It comes from the heart and the mind, not from ordering the world into rows."
   - Final: "Because some things are five. Some people are." / "You took ten years from me. Whatever you took, it was not the part that matters. Strength is not control."
2. `cutscene.primm_end.6` (You)
   - Old: "It is not too late to say sorry."
   - Final: "I'm not going to correct you. That was your way. Start smaller. Say sorry to one person." (Primm: "One? I corrected eleven thousand...")
3. `facade.citizen.4.slip`
   - Old: "The man next door smiled at a funeral and he was corrected. He had to. It was his wife. She was not a regulation death."
   - Final: "The man next door smiled at his wife's funeral. He was remembering her laugh." / "(a whisper) They corrected him for a month. He does not remember her laugh now."
4. `freed_npc.heartlift` (Flex in the Crease)
   - Old: "Grandmaster Flex: \"Heart and mind, little one. And you have both. I once taught a mill to run backwards. You are better than the mill.\""
   - Final: "Breathe in. Hold. ...Feel that? That is a city with nowhere it has to be." / "Rollo's crews are lying in the sun. I told them rest is a rep. They believed me. Heart and mind, son. You used both."
5. `quest.side_s_cap.active` (Kestrel; edited in this pass)
   - Old: "Find the resistance hideout. Ask Wren about the tunnels."
   - Final: "Get inside and find the Crease: the manhole near the gate. Knock three times. Not two. Two is rude. Then ask Wren about the tunnels."
