# Brief for one dialogue chunk (Nov 13 rewrite)

You are rewriting one chunk of the dialogue of "The Wayward Path", a deckbuilder RPG set in the kingdom of Patchwork (repo
`C:\Dev\Deckbuilder-rpg`). The lead writer has already rewritten the main story (Tier 1). Your chunk is named in your task.

## Why this pass exists (the owner's words, summarised)
The current dialogue is weak: short and choppy (clipped statement sentences one after another), not natural, too clever (quips and wordplay
instead of people talking), and too many characters share that one terse voice. The goal: a large cast with clearly different
personalities and ways of speaking; natural, warm, flowing dialogue; the main quest earnest and emotional; humour mostly in side content and
coming from character, not from quips. Dad jokes, puns and the odd millennial reference are welcome where a character would really say
them (the owner wants the game fun), but they are seasoning, not every line.

## Read first, in this order
1. `docs/writing/voices.md`: the style guide at the top, then the entries for every speaker in your chunk. This is the authority on how
   each person talks. Note the one-endearment-each rule and that only Brannoch and Nurse Hesper Dray may be terse.
2. `docs/writing/story_bible_v2.md`: the through-line, your zone's chapter (section 2), the plants and payoffs (section 4) and the
   relationships (section 5). Your zone's mini story must connect to the main arc the way the bible says.
3. Your chunk file `docs/dialogue/rewrite_nov13/chunks/<chunk>.txt`. Read ALL of it before writing anything.
4. For any "go here, do this" line, the quest data: `core/quests/quest_definitions.gd` and `core/quests/zone_quest_definitions.gd`.

## What to write
Copy `docs/dialogue/rewrite_nov13/chunks/<chunk>.txt` to `docs/dialogue/rewrite_nov13/<chunk>.txt` and edit THE COPY in place.

The file is a list of conversations. `@alias::key` starts one key (one speaker's turn); the `#   [Speaker] when it is heard` comment under
it tells you who is talking and when; each `idx| text` line is one dialogue box. Lines starting `#= ` were rewritten in Tier 1: read them
for continuity and leave them alone.

Rewrite **whole conversations as scenes**, not line by line. A conversation is usually several keys in a row (a quest's offer / active /
ready / done; an NPC's intro / return / freed; a scene's steps). For each conversation:
1. add a line `## purpose: ...` above its first `@` header: one sentence on what it must achieve in the story and in gameplay;
2. rewrite its lines in each speaker's voice, by replacing the text after `idx| `;
3. read it back as a scene: does each person sound like themselves and nobody else? do they answer each other?
4. check the hard rules below.

A line that is already right (natural, in voice, not a clipped quip) can stay exactly as it is: leave it untouched and it counts as kept.
But most lines have the fault this pass exists to fix. Expect to change well over half of the lines in dialogue, and few of the lines in
plain UI text. Do not add or delete `idx|` lines, and do not change `@` headers or indexes.

## Hard rules for every line (a checker enforces most of them)
- **Keep every `{token}` and leading `[tag]`** from the current line, spelled exactly. Keep `%s` and `%d`.
- **Lengths:** at most 220 characters for a dialogue box (the checker's limit; aim for 120-200), under 90 for barks (ids starting `npc::`).
  Never cram and never truncate: if a thought will not fit, say less.
- **One line per box,** no line breaks. **Plain ASCII only:** straight quotes ' and ", three dots "...", " - " for a dash. No curly quotes,
  no long dashes, no accented letters.
- **Keep every gameplay fact exactly:** where to go, what to bring, how many, item / card / NPC / place names, numbers, key names
  ("press C"), compass directions, and the wayfinding hints (gates, the Magic Bean, the stables, the manhole, "Under the Capital", and so
  on). You may phrase them more naturally. You may never change, drop or blur them. Rule text in parentheses stays word for word.
- **Nothing may contradict the game's rules:** no defeat penalty (you respawn in the zone); leaving or losing a dungeon restarts it; up to
  3 copies of a card, depending on level; max hand size 10; a turn means both players' turns; after Primm you may "Fight Primm again" or leave.
- **Never rename** a character, place, item, card, quest or dungeon. Names in the current lines are canonical.
- **Tokens for names in story files.** In files with the aliases `intro`, `capital`, `gainlands`, `gourmand`, `dna`, `refusemancer`, never
  write Primm, His Perfection, Tessar, Wayweaver, Crosspath, Pathordia or Showcase Quarter literally unless the current line already does:
  use the tokens the current line uses. Never write the name Elowen unless the current line has it.
- **No spoilers before their time.** A line may only refer to people, places and events the player has met by then. Quest titles,
  summaries and steps never name a twist (Flex's imprisonment, the Doppelganger, Compostella being the Rotheart, Elowen, the Lab, who the
  hero is). Nobody outside the Fragments scenes and the ending knows the hero is the prince; the four "little prince" memories (the
  dumbbell, the frosting, the third form, the twelfth tree) stay as half-noticed moments.
- **Tested phrases.** Some lines contain a phrase a test looks for; the checker will tell you ("lost tested phrase ..."). Keep the phrase.
  If a tested phrase is an ordinary word that fits badly (for example "Well" or "Keep"), keep it anyway.
- **Family friendly.** No real people, brands, songs or places. No cruelty played as a joke. No winking at the player.
- **Do not change Fig Sly's lines** (they are not in your file) or any `#= ` line.

## Before you finish
From the repo root, run both and fix until both are clean:

    node tools/dialogue_scene_build.js --base=docs/dialogue/rewrite_nov13_base.csv --out=_logs/<chunk>.csv --check=_logs/<chunk>_check.csv docs/dialogue/rewrite_nov13/<chunk>.txt
    node tools/dialogue_critic_check.js --check=_logs/<chunk>_check.csv --csv=docs/dialogue/rewrite_nov13_base.csv

The first prints "N rows changed, 0 problems"; the second "N of N pass".

Do not edit any game file, test, tool, the base CSV or another chunk. Do not run Godot, GUT or any smoke. Do not commit.

## Report back
- how many lines you changed and how many you kept;
- per speaker, the number of lines changed;
- your five best before/after pairs;
- any line where a gameplay fact was unclear to you, or a tested phrase forced an awkward sentence;
- anything in the chunk that contradicts the story bible.
