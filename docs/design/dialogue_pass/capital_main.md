# Dialogue pass Oct 19: capital_main

Writer area: the Capital and the main story's climax. Files edited: `data/story/capital_story.tres`, `data/dungeons/dungeon_content.json`
(`"text"` values only). `data/story/villain.tres` holds no lines (name and title only) and was not touched. Godot was not run; nothing committed.

## What changed (counts)

| File | Keys changed | Notes |
|---|---|---|
| `capital_story.tres` | 138 of 582 | 118 rewritten, 20 token-only. Key set identical (582 = 582), every `.speaker`, `[tag]`, placeholder and key kept. |
| `dungeon_content.json` `text` | 47 of 49 | Key set and order identical; the rest of the file is byte-identical (only the `text` block was re-serialized). |

Rewritten groups in `capital_story.tres`:
- Wren: `npc.wren.intro` (6 boxes cut to 4), `.intro.freed`, `.return`, `.return.freed`, `npc.wren.insight.1..4`.
- Hesper, Old Fern, Widow Pell, Rollo Spokes, Chef Marlo, Captain Spotless (all `intro/return/(.freed)`, `open`, `defeated`), height guard,
  Citizen 4471 / Aldous. Fig Sly untouched (hands off). Other guards and the exit clerk already fit their voice; left as they were.
- `quest.cap_burial/wheels/recipes/untidy.*` (16 keys): the insights are now told in the giver's own voice ("And something about the man in the
  castle...") instead of a bracketed "(the records say Primm...)" aside; instructions and locations unchanged.
- `facade.*`: citizen 4 (approved2, slip), citizen 6 freed, citizen 9, door 3 (+ freed), loudspeakers 1.0, 2.0, 2.1, 3.2 (Plume sign-off).
- Castle: `dungeon.pc_corrector.after`, the three wing `.after` margins, `pc_boss.blurb/.before/.after`, `pc_gallery.*`, `pc_ward.before`,
  `pc_junction.before`, `pc_model_warden.after`; `event.pc_improved_portraits.*`, `pc_early_journals.result.*`, `pc_last_journal.*`,
  `pc_corrected_citizens.result.1`, `pc_grand_staircase.body/.result.0`.
- `cutscene.primm_intro.2/.3/.5`, `primm_p1.2/.3/.4`, `primm_p2.2`, `primm_end.3/.6/.7`, `primm_reveal.2/.4/.5`.
- `boon.*.line` (all five), `ending.beat.1-6, 8, 9 (+ title), 10`, `freed_npc.*` (leaders, Primm, the guard).

`dungeon_content.json`: all six side-quest givers (Maren, Old Man Mountain, Basil, Gerald, Bramble, Kestrel) now speak in their voice, Kestrel
rewritten as the playful scout, all seven side bosses, the Lab (Siphon, the Drain chamber, the Rescuer's cell lines split to fit).

## Notable fixes

- **Tokens:** every literal "Primm" in text is now `{villain}` (31 uses), "His Perfection" in speech is `{villain_title}`, and "Primm's
  Perfection" is `{capital}` (so it reads "Pathordia" after the fall). The 21 "Primm" left in the file are all `.speaker` values, kept by rule.
  `ending.beat.10` uses `{prince}`; Siphon's "Primm's rule" uses the token too.
- **The Wanderer stops lecturing.** `primm_p1.2`, `primm_p2.2`, `primm_end.3` are now short lines that echo the leaders' own words (see the
  callbacks below). `primm_intro.3` is his own small line (forest mud on the polished floor) and still sets up Primm's "Afraid? Of what?".
  `primm_end.6` is the choice not to punish him ("I'm not going to correct you. That was your way."), and `primm_end.7` answers it.
- **Primm sincere-and-wrong:** `primm_reveal.5` no longer gloats about "your power"; he believes he has been looking after it. His bible lines
  (seventeen people, ten years of practice, "I only wanted it to be nice!", the mirrors, the hats) are kept word for word.
- **Narration rules:** the ending is in second person ("You sit, and the Throne answers", "stops in front of you") instead of "the Wanderer /
  him"; lines that told the player what to feel (the journals, the last journal) now show it instead. `ending.beat.6` and `.9` trimmed to
  images; every long ending, gallery, ward and boss box split to one or two sentences.
- **Name clash avoided:** the freed citizen's bird was "called Gerald now" (Gerald is the D.N.A. ghost): it is "Thursday" now.
- **Clunky lines from the beat map:** `boon.refusemancer.line` ("and then let it grow") rewritten; capital `freed_npc.heartlift` ("taught a
  mill to run backwards") replaced by a Flex callback; the redundant "Grandmaster Flex: \"...\"" prefixes in the leaders' Crease lines removed
  (the name plate already shows the speaker).
- **Kestrel** (`npc.kestrel.*`, `quest.side_s_cap.*`): no more "Quiet. Primm's enforcers walk this road on the hour." She is quick and
  teasing, follows the chalk, "that's the fun part"; the quest steps stay plain (get inside, find Wren in the Crease, knock three times; the
  hatch at the east end of the Outskirts).
- **Gerald owns his side quest** (`quest.side_s_necro.offer`: "Number 4,000,212? That's me.") instead of talking about "a ghost" in third person.
- **Length:** no rewritten box is over 210 characters; most are under 160. Untouched `fx.*`, `debuff.*`, `challenge.*` lines that were already
  long were left as they were (outside the assignment; only tokenized).
- **Test-locked phrases kept:** "You do not even know, do you?", "I kept your face", "ten years of practice", "strength is not control",
  "treating people with respect", "nothing grows", "Pathwork Throne", "how much he broke", "HEIR: ALIVE. FILE COMPLETE.", "'Tessar,' she says"
  (via `{prince}`), "PATHORDIA", "one way for everyone", "Different Paths, working together", "Paths come home", "water main", "not
  permitted", "Primm works under guard" (via `{villain}`), "painted over in white", "KEPT FOR REFERENCE", "SUBJECT", "M.", "Maren" in Wren's
  intro, "mending" in Wren's freed line, "Nobody stands beside you", the six castle needles, "This is where it was done".

## Callbacks planted (A -> B)

- C1 Flex: "Whatever they took from you, son, it was not the part that matters." (gainlands `dungeon.hg_boss.after`, `freed_npc.heartlift`)
  -> "You took ten years from me. Whatever you took, it was not the part that matters. Strength is not control." (capital `primm_p1.2`)
- C2 Grand Chef: "That is not a flaw, it is a blank page. Go and do something worth signing." (gourmand `freed_npc.grandchef`) -> "A name is a
  blank page until you sign it." (`primm_p2.2`) -> "You did something worth signing, you know." (capital `freed_npc.grandchef`)
- C3 Agnes: "Never let anyone file you under 'subject' again." (dna `freed_npc.agnes`) -> "And nobody files me under 'subject' again. No
  order outranks treating people with respect." (`primm_p2.2`); Siphon's "Subject 1" lines kept against it.
- C4 Compostella: "do not bury it in a jar" (refusemancer `freed_npc.compostella`) -> "You took my mother and father. I can't even remember
  their faces. I'm not burying that in a jar. I'm letting it go." (`primm_end.3`) -> her boon: "To grow, you have to let things go, child.
  Even him. Especially him." (`boon.refusemancer.line`) -> the choice to spare him (`primm_end.6`).
- Agnes's "technicality" boon line -> the Necrocrat wing: the form "can be revoked, you suspect, on a technicality" (`pc_wing_necrocrat.after`).
- C5 chain ends in `ending.beat.10` (unchanged in substance) with Maren "tortoise-slow", flour on her sleeve (her pie), "{prince}... Welcome home."
- C11 the lullaby and the Lab glass return on the throne (`ending.beat.8`); the forest: `primm_intro.3` ("That's forest mud").
- C14 the ward's "M." note and "You have seen that handwriting on a pie recipe." kept (`pc_ward.before`); needs the intro writer's set-up.
- C16 Isla (foreshadow only, unnamed): `facade.door.3` "a young woman painting the same window for the thousandth time... the face of someone
  who has meant to write home for years" -> `facade.door.3.freed` "The paintbrush has been left on the ladder, for good."
- C18 the wheels: Rollo "Learned the wheels... in the Gainlands. Back then, a wheel stopped at night." (`npc.rollo.intro`); Flex in the Crease:
  "Rollo's crews are lying in the sun. I told them rest is a rep." (capital `freed_npc.heartlift`).
- C19 the sauce: the Grand Chef's boon "Ten years of sauce that tasted of nothing" next to Marlo's "He cannot taste" (`quest.cap_recipes.ready`).
- C26 kept: "seventeen people" (`primm_intro.1`) -> "sorry about the hats" (`primm_end.8`). The "eleven thousand" motif now links Spotless,
  the Chief Corrector and Primm's own "I corrected eleven thousand" (`primm_end.7`).
- Crest (4.1, unexplained): Maren on the vault key, "four little carvings, in a ring. Hm. Never mind." (`quest.side_s_town.ready`) -> the
  Automaton's core "four marks set in a ring" (`dungeon.dg_s_town_boss.before`) and its "Tick. ...Recognised." (`.after`).
- 4.5 the Rescuer: Siphon "My assistant left us too, you know. Confused, poor thing. Assistants come home." (`dungeon.dg_lab_boss.before`),
  no name, no pronoun, no "daughter".
- 4.6 Plume: two loudspeakers sign off "This has been your Deputy Minister of Good News!" and open with his "Great news, citizens!"
  (`facade.speaker.1.0`, `2.0`, `3.2`).

## Could not do (needs code or another writer)

- **Phase lines when a leader is not freed (CODE).** The castle can be rushed with fewer than four zones freed, but `primm_p1/p2/end` play
  the same text. So the Wanderer echoes the leaders' words without naming them: a player who met Flex hears the quote, one who did not hears
  his own line. Named versions ("A man who spent ten years in a cell told me: whatever they took, it was not the part that matters") would
  need zone-conditional variants (for example `cutscene.primm_p1.2.<zone>_freed` read by `CutsceneScreen`).
- The callbacks need the other writers to keep these leader phrases (tests lock most of them): Flex "it was not the part that matters",
  the Grand Chef "blank page" / "something worth signing", Agnes "file you under 'subject'", Compostella "do not bury it in a jar".
- Isla's homecoming, Plume as a named character, the lieutenants' fights, Elowen's abduction: not built, so they are only hinted.
- Kestrel's hatch: the text keeps "the east end of the Outskirts" (the Old Service Tunnels mouth is north-east in `capital_layout.gd`).
  Not changed, since it is a location claim.
- Wren / Wren Muckfoot name clash: still open (inbox).
- Untouched long lines outside the assignment: `fx.cable` (316 characters), `challenge.pc_escalation_shelf.text` (273). They were already
  that long; `fx.cable` is shown as a toast from `lines[0]` in places, so I did not split it.

## The 10 best before -> after

1. `cutscene.primm_p1.2` (You)
   - Before: "Because they are not the same, Primm. People are not the same, and strength is not control. It comes from the heart and the mind, not from ordering the world into rows."
   - After: "Because some things are five. Some people are." / "You took ten years from me. Whatever you took, it was not the part that matters. Strength is not control."
2. `cutscene.primm_p2.2` (You)
   - Before: "You can only copy, Primm. A name is not a self, and a face is not either: what you do is what you are. And no order, however valid, outranks treating people with respect."
   - After: "You copied my cards. You can't copy what I do with them. A name is a blank page until you sign it." / "And nobody files me under 'subject' again. No order outranks treating people with respect."
3. `cutscene.primm_end.3` (You)
   - Before: "Nobody was ever afraid of being wrong, Primm. They were afraid of you. And nothing grows if you refuse to let anything go." / "You held on to everything, and it rotted in your hands."
   - After: "You kept everything. Every face, every rule, every house on that table. Nothing grows if you refuse to let anything go." / "You took my mother and father. I can't even remember their faces. I'm not burying that in a jar. I'm letting it go."
4. `cutscene.primm_end.6` (You)
   - Before: "It is not too late to say sorry."
   - After: "I'm not going to correct you. That was your way. Start smaller. Say sorry to one person."
5. `cutscene.primm_intro.3` (You)
   - Before: "You have to stop, Primm. The Paths are breaking. The people are afraid of you."
   - After: "Sorry. That's forest mud. I've walked a long way, and everyone I met on the way here was afraid of you."
6. `boon.refusemancer.line`
   - Before: "...'To grow, you have to let things go,' she says, 'and then let it grow.'"
   - After: "Archdruid Compostella kneels and presses a palm to the marble. A small green shoot pushes up through the polish." / "'To grow, you have to let things go, child. Even him. Especially him.' (...)"
7. `npc.kestrel.intro` (dungeon_content)
   - Before: "Quiet. Primm's enforcers walk this road on the hour." / "I am Kestrel, scout for the resistance. If you are going into the city, there is an older way in than the gate."
   - After: "Psst. Down. The enforcers walk this road on the hour, and they hate surprises. I'm a surprise." / "Kestrel. I scout for the Wrinkles. Going into the city? There's an older way in than the gate. Follow the chalk, not the guards. The guards are worse at drawing."
8. `quest.cap_wheels.ready` (Rollo), last boxes
   - Before: "(Primm, the records say, cannot bear a late arrival." / "He made lateness illegal. A man who cannot wait for anyone. Remember that when you meet him: he is always, always in a hurry to be loved.)"
   - After: "And something about him. He made lateness illegal. A man who cannot wait for anyone." / "Remember that when you meet him. He's always in a hurry... to be loved."
9. `facade.door.3`
   - Before: "...Behind the facade there is a space just big enough for a ladder and a very bored person with a paintbrush." / "He looks at you. He looks away. Something in the Showcase is very tired."
   - After: "...Behind the facade there is just room for a ladder and a young woman painting the same window for the thousandth time." / "She looks at you. She looks away. She has the face of someone who has meant to write home for years."
10. `freed_npc.heartlift` (capital)
    - Before: "Grandmaster Flex: \"Heart and mind, little one. And you have both. I once taught a mill to run backwards. You are better than the mill.\""
    - After: "Breathe in. Hold. ...Feel that? That is a city with nowhere it has to be." / "Rollo's crews are lying in the sun. I told them rest is a rep. They believed me. Heart and mind, son. You used both."

Runner-up: `cutscene.primm_reveal.5`: "Everything is possible when it is filed correctly. Come. Let me show you the one thing in this kingdom that is
truly mine, and truly yours: your power." -> "Everything is possible when it is filed correctly. Your power has kept this kingdom lit for ten years. I have
only been looking after it." / "Come. You may as well see it used properly."
