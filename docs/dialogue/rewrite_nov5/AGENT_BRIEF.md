# Brief for a dialogue rewrite chunk (Overnight Nov 4-5, Part 4)

You are rewriting one chunk of the game's dialogue for "The Wayward Path", a deckbuilder RPG (repo `C:\Dev\Deckbuilder-rpg`). The owner's verdict:
a lot of the dialogue doesn't make sense or isn't good. Short clipped statement sentences in a row read badly, and the humour attempts mostly
don't land. Your job is to make every line in your chunk read like real people talking, with clear main-quest storytelling and warm,
character-driven humour in side content.

## Read first (in this order)
1. `docs/dialogue/story_voice_nov5.md` - the story spine, voice cards and banned patterns. This is the style authority.
2. `docs/dialogue/voice_bible.md` sections 2 (hard rules), 4 (speakers) and 5 (running jokes).
3. `docs/design/canon.md` - names and the token table.
4. Your chunk file (named in your task). Columns: ID, Zone/Area, Speaker, When it's heard, Current line, Must keep.
5. For quest text and any "go here, do this" line, check the real quest data: `core/quests/quest_definitions.gd` and
   `core/quests/zone_quest_definitions.gd` (objectives and where-to-go hints), so instructions match the game.

## What to write
Write `docs/dialogue/rewrite_nov5/chunk_<name>_done.csv` (UTF-8, every field in double quotes, `""` for a quote inside a field) with the header
`"ID","Effective line","Suggested line"` and ONE ROW PER LINE YOU CHANGE (skip lines you keep as they are). "Effective line" is the chunk's
"Current line", copied exactly. "Suggested line" is your rewrite.

Priorities inside your chunk:
1. **Main-quest lines** (zone story NPCs, gatekeepers, leaders, lieutenants, memories, Maren, Wren, Primm, story scenes, quest summaries and
   steps): rewrite most of them. Clear about what to do and why; real feeling; the kingdom's story woven through. At most one joke per
   conversation, never on a sincere beat.
2. **Primary characters' other lines** (the voice cards in the guide): each must sound like that person and nobody else.
3. **Side quests**: this is where the humour lives - situational, character-driven, warm dad-joke and pun energy, not a punchline every line.
4. **Barks** (`data/npcs/npcs.json`): short, natural, under 90 characters.
UI text (quest steps, rule text, buttons, titles, event choices): change only for clarity or accuracy; keep every number and condition.

A line that is already good can stay: do not change for the sake of changing. But most lines in the current game have at least one banned
pattern; fix them.

## Hard rules (a rewrite that breaks one is rejected by the checker)
- Keep every `{token}` (same set and count), `%s`/`%d`, and a leading `[tag]` such as `[smug]` exactly.
- Keep every "Must keep" phrase word for word (tests assert them). Several phrases are separated by ` || `.
- Story `.tres` lines never spell Primm, Crosspath, Tessar, Wayweaver, Pathordia, Showcase Quarter or Elowen literally: use the tokens
  (`{villain}`, `{town}`, `{prince}`, `{royal_house}`, `{capital}`, `{showcase}`, `{rescuer}`) exactly as the current line does. Files that
  already spell names literally (npcs.json barks, boss intros, encounter scripts, dungeon event screens) stay literal.
- One line per box: no line breaks. Plain ASCII punctuation (straight quotes, "...", " - " for a dash). At most 240 characters (aim for 200);
  barks under 90; titles, buttons, choice labels and name cards about as short as now.
- No spoilers before their time: quest titles, summaries and steps never name a twist (Flex's imprisonment, the Doppelganger, Compostella
  being the Rotheart, Elowen, the Path-ology Lab, the memories' contents). A line only refers to people, places and events the player has
  met or heard of at that point ("When it's heard" tells you when).
- Fig Sly and the Secret Dealer lines: leave them unchanged.
- Do not rename anything: cards, places, NPCs, quests, dungeons, nodes, items.
- PG; no real brands, songs, films, places or people; no modern slang ("vibe", "literally", "lowkey", "awesome", "epic", "okay" as an opener).

## Style rules (the point of the exercise)
- Natural rhythm with varied sentence length. Use contractions. No strings of three short sentences. No narrator-style fragments in spoken
  lines ("I search. I find nothing." -> "I've been trying to remember my name, and there's just nothing there.").
- Narration (Speaker "Narration" or blank, second person) may be descriptive but still flows: one clear image, not three clipped ones.
- No meta jokes, no explaining a joke, no filler openers ("Great!", "Anyway").
- Each speaker sounds like their voice card. A reader should tell who is talking without the name plate.
- Keep the running jokes listed in the voice bible for their owners, but don't lean on them in every line.

## Before you finish
Run `node tools/dialogue_critic_check.js --check=docs/dialogue/rewrite_nov5/chunk_<name>_done.csv --csv=docs/dialogue/edit_nov5_before/before_nov5.csv`
and fix every FAIL it prints (it checks tokens, protected phrases, banned names and lengths). Repeat until it reports all pass.

Do not edit any game file, test or other chunk. Do not run Godot. Report back: how many lines you changed, how many you kept, and 3 of your
best before/after pairs.
