# Overnight Nov 12-13 (Fable): the dialogue rewrite, one cohesive emotional story

Repo: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, "The Wayward Path", the kingdom of Patchwork). The owner is asleep, and this is the last long Fable
run, so leave the game in a finished, consistent state at every commit. Log questions in docs/overnight_inbox.md under "Dialogue Nov 13".
Tag `pre-dialogue-nov13` at the start.

**First:** run `git status`. If an earlier run left uncommitted work, run the tests, then commit and push it before you start.

## Why this pass exists (the owner's words, summarised)
The current dialogue is generally weak:
- **It's short and choppy:** clipped statement sentences, one after another.
- **It doesn't sound natural.**
- **It's too clever:** quips and wordplay instead of people talking.
- **Too many characters share that one voice.** That terse style is fine for one or two characters, not most of them.
- **The story doesn't hang together:** the zones' stories don't build into one cohesive, emotional arc.

**The goal:**
- a story that builds and pays off from the first minute to the credits;
- a large cast with clearly different personalities and ways of speaking;
- natural, warm, flowing dialogue;
- the main quest earnest and emotional; humour mostly in side content, and coming from character, not from quips;
- dad jokes, puns and the odd millennial reference are welcome where a character would really say them (the owner wants the game fun), but they're seasoning, not every line.

## House rules
- STOP_OVERNIGHT check before each part.
- **Memory:**
  - ONE Godot at a time;
  - text work needs no Godot, so sub-agents are allowed for drafting while no Godot runs: at most 3 at once, and none while a test or smoke runs.
- **Commit and push after each tier.** The game must be fully consistent after each one: a tier is applied whole or not at all.
- **Text only:** no gameplay, layout or art changes, no difficulty setting. Primm's fight is unchanged. No public upload.
- **Canonical names:**
  - the names in the game's current data (NPC ids, display names, places, cards) are canonical;
  - docs/story_bible.md is outdated where it disagrees with them;
  - never rename a character, place, item or card.

## Hard rules for every line
- **Keep every `{token}` and `[tag]` from the current line.** Speaker ids, portrait or expression tags and the conversation structure stay valid.
- **Lengths:** 240 characters a line, 90 for barks.
  - When a beat needs more room, **split it into more lines** if the conversation format allows adding lines. Check how conversations are stored; `tools/apply_dialogue_pass.js` may need a small extension for new IDs. Test it.
  - Don't cram a line to fit, and don't truncate.
- **Keep every gameplay fact exactly as it is:** where to go, what to bring, item, card, NPC and place names, numbers, and the wayfinding hints added Nov 10-12 (gates, the Magic Bean, the stables, "Under the Capital", the manhole, and so on). A rewrite may phrase them more naturally but never change, drop or blur them.
- **Nothing may contradict the rules as they now stand:**
  - no defeat penalty (you respawn in the zone);
  - leaving or losing a dungeon restarts it;
  - up to 3 copies of a card, depending on level;
  - max hand size 10;
  - a turn means both players' turns;
  - Primm: "Fight Primm again" or leave.
- **Family friendly.** No real people. No cruelty played as a joke.

## Part 0 — Read everything and export (about 45 min)
1. Export every line fresh to `docs/dialogue/rewrite_nov13_base.csv`, in the same format as `edit_nov9.csv`, with the current text. That count supersedes the 4,357 lines from Nov 9.
2. Read, in story order:
   - every conversation, cutscene, story still caption, quest text (summaries, steps, "Where to go"), and the ending and credits text;
   - the quest definitions;
   - the zone, boss and NPC data;
   - docs/story_bible.md, the zone docs and docs/design/*.
3. Read the playtesters' workbook's Voice Guide tab (`docs/dialogue/playtesters_nov9.xlsx`). It's the last voice brief.

## Part 1 — Story bible v2 (about 1 h; the main agent writes this itself)
Write **docs/writing/story_bible_v2.md** from what the game already contains. Strengthen it without changing what the game does:
1. **The through-line:**
   - who the hero is;
   - what they lost (the memory fragments);
   - what they want;
   - what Primm's "perfection" costs the kingdom;
   - what Patchwork means as a theme (imperfect pieces stitched together are stronger and more beautiful);
   - how the hero changes by the end.
2. **The four Path zones as chapters.** For each: a self-contained mini story with its own emotional beat, and **what it adds to the big story** (a clue, a memory, a loss, an ally, a turn of the theme). Show how each points to the Capital and Primm.
3. **The Capital, Primm and the ending:**
   - Primm as a person, not a cardboard villain: why he wants perfection and what he's afraid of;
   - the reveal schedule (what the player learns when);
   - the emotional peak;
   - the resolution;
   - the epilogue;
   - the postgame hook (the Lab, Elowen's rescue, the Gallery).
4. **Plants and payoffs:** at least 12 pairs (an early line or object paid off later), each with its line IDs.
5. **Recurring relationships:** the hero and Elder Maren (an old tortoise), Pip, the Path leaders, Kestrel and the resistance, Fig Sly, the funeral and Old Hob. Show how each develops across visits.

## Part 2 — Voice sheets (about 1 h)
Write **docs/writing/voices.md**, with one entry for every speaker with more than ~5 lines, and short group entries for townsfolk types. Each entry has:
- who they are and what they want;
- what they're afraid of or hiding;
- how they feel about the hero;
- **how they talk:**
  - sentence length and rhythm;
  - vocabulary and register;
  - verbal habits;
  - what they never say;
  - humour type, or "none";
- 3 example lines in that voice.

Deliberately spread the cast across very different voices: rambling and warm, formal and precise, nervous, blustering, gentle, salty, poetic, plain-spoken, child-like, bureaucratic, theatrical, and so on. **At most two characters may be terse.**

Then a short **style guide** at the top of voices.md:
- **Natural speech:** contractions, varied sentence length, people answering each other rather than delivering monologues.
- **Show feeling through what people do and avoid saying;** no characters explaining their own emotions in neat summaries.
- **No string of clipped one-clause sentences.**
- **No "clever" lines that don't sound like this person.**
- **No winking at the player.**
- **Quest info:** delivered inside a real exchange, but still crystal clear.
- **The main quest:** sincere, with room for quiet moments.
- **Side quests:** where most of the comedy lives, built on the character's personality and situation.

## Part 3 — Rewrite, in tiers (most of the night)
Rewrite **whole conversations as scenes**, not line by line. For each conversation:
1. write a one-line purpose (what it must achieve in the story and in gameplay);
2. rewrite it in each speaker's voice;
3. read it back as a scene;
4. check the hard rules.

The main agent writes Tier 1 itself. Sub-agents may draft Tiers 2-4 from the bible, the voice sheets and an assigned set of characters. The main agent edits every sub-agent batch for voice drift, continuity and the hard rules before it's applied.

| Tier | What | Notes |
|---|---|---|
| **1 — The main story** | The prologue and the tutorial cave (the Cave Warden included), Elder Maren's questline, every Fragments and memory scene, each zone's main quest with its boss before and after, the gatekeepers, the Capital's main line ("Under the Capital" included), the castle, Primm (every phase line and the defeat/retry text), the ending, the epilogue stills, the credits thanks card | Apply, test and commit as soon as it's done. |
| **2 — The core cast** | The Path leaders, each zone's quest-givers and their side arcs (each zone's mini story must connect to the main arc as the bible says), Pip, Kestrel and the resistance, the funeral and Old Hob | Apply and commit per zone. |
| **3 — Side content** | The remaining side quests, vendors and shopkeepers (Fig Sly, Tilly, Mirepoix, Fenwick, Sable, Dex...), the minigame hosts, the trainers, the postgame (the Lab, Elowen, the Gallery) | Apply and commit per group. |
| **4 — The world** | Barks, townsfolk, signs and plaques, loading tips, tutorial hints | Barks stay under 90 characters, varied by character type, and not all jokes. |

**Applying each tier:**
- write it to `docs/dialogue/rewrite_nov13_t<N>.csv` in the format `apply_dialogue_pass.js` expects;
- do a dry run, then `--apply`;
- save the tier's IDs to `docs/dialogue/rewrite_nov13_t<N>_ids.txt` (for `--revert=`);
- run the dialogue, quest and UI test shards, the prologue smoke and the full GUT;
- commit and push.

**If the night runs short:** a finished Tier 1 and 2 beats a half-done Tier 4. Stop at a tier boundary.

## Part 4 — Check it in the game (about 45 min, after Tier 1 and again at the end)
1. **Play-script runs** through the prologue, the cave, Maren's first scenes, one zone's main quest, the Capital's arrival and the Primm fight with its ending. Take screenshots at 1280x720 and 1920x1080, with Large text:
   - no overflow, no cut-off text and no broken tokens;
   - portraits and expressions still match the lines.
2. **A no-context reader critic** gets 40 conversations' old and new text, without being told which is which or what was asked (10 from Tier 1, 10 from Tier 2, 10 from Tier 3, 10 barks). It scores each version 1-10 on:
   - naturalness;
   - voice distinctness;
   - emotional impact;
   - clarity of quest information;
   - humour that lands.

   It lists the 10 worst new lines. Fix them. Report the averages.

## Part 5 — Keep the playtesters' work usable
Some playtesters are rewriting lines in `playtesters_nov9.xlsx` against the **old** text.
- Extend `tools/import_playtester_dialogue.py`: when a returned row's ID was rewritten tonight, don't apply it. List it in the report as "base changed tonight", with the old base, tonight's line and the tester's line side by side for the owner.
- Export a fresh workbook, `docs/dialogue/playtesters_nov13.xlsx` (same tabs and columns), with tonight's text and an updated Voice Guide tab built from voices.md. Copy it to `G:/My Drive/Card Game Art/Playtester Dialogue/`.

## Finish
- All test shards green.
- **docs/overnight_report.md**, with at the top:
  - the tiers done, with line counts per tier and per character;
  - **before/after of 15 key scenes**: the opening, Maren's first talk, a memory scene, each zone's emotional beat, the Capital arrival, Primm before the fight and at the end, the epilogue;
  - the critic's scores, old against new;
  - the plants-and-payoffs list;
  - any name, lore or story decision you had to make;
  - what was not reached;
  - **how to revert:** a whole tier with `node tools/apply_dialogue_pass.js --revert=docs/dialogue/rewrite_nov13_t<N>_ids.txt`, or everything with the tag.
- Commit and push. No public upload, no export.
