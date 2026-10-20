# Dialogue pass Oct 19 - editor brief (the review pass)

You are an EDITOR who did not write this text. Project: C:\Dev\Deckbuilder-rpg. Use `cd /c/Dev/Deckbuilder-rpg`. Do not run Godot, do not
commit, edit only your assigned files. Bash heredocs with apostrophes fail: write files with Write/Edit, scripted edits as node scripts.

## Read first
docs/design/dialogue_pass/writer_brief.md (the rules the writers followed - they bind you too), docs/design/voice_bible.md,
docs/design/dialogue_beats.md, docs/design/canon.md, the writer's report docs/design/dialogue_pass/<area>.md.

## Score
For every CONVERSATION (a key group shown together: an NPC's intro/return/quest offer/done, a cutscene, a dungeon event, a quest's lines)
in your files, score 1-5 on each of:
1. In character (matches the voice bible entry)
2. Funny (puns, dad jokes, millennial references as parody - never real brands; quiet near Primm is fine: score fit, not volume)
3. Story beat landed (the beat map's beats/foreshadowing/callbacks for that conversation)
4. Brevity (no info-dumps; one or two sentences per box; fits the box)
5. Clarity of what to do next (quest steps, where to go)
Score the OLD version (git: `git show pre-overnight-oct19:<path>`) and the NEW version (the working tree) of each conversation. You may
score in batches (e.g. per NPC), but every conversation gets both scores. A conversation's score = the minimum of the five (also keep the
five numbers).

## Fix
Rewrite every NEW conversation whose minimum is under 4 (keep keys, arrays, tags, placeholders, tokens - the writer brief rules), then
re-score it. Repeat until it is 4+ or you can explain why it can't be (needs code / a decision) - list those.
Also scan your files for: boxes over 240 characters, banned old names (canon.md), literal "Primm" in text (use {villain}; `.speaker`
values may stay), "Elowen", real brand names, mean-spirited jokes. Fix any you find.

## Deliverable
docs/design/dialogue_pass/<area>_editor.md: a table per conversation (key group, old min, new min, final min, the five final numbers, what you
changed), area averages (old / new-before-edit / final), the list of things that need code or the user. Reply with the averages and the count
of conversations you rewrote, and the 5 best final before -> after examples (key, old, new).
