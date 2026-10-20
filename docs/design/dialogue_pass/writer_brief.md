# Dialogue pass Oct 19 - writer brief (shared by every writer agent)

You are one of four writers rewriting the game's dialogue to AAA quality tonight. The user is asleep: never ask, take the safest choice.
Project: C:\Dev\Deckbuilder-rpg (Godot 4.7). Use `cd /c/Dev/Deckbuilder-rpg` in Bash. Bash heredocs with apostrophes fail: use Write/Edit.

## Read first
- docs/design/voice_bible.md (THE voice reference: global rules + one entry per speaker + which keys hold their lines)
- docs/design/dialogue_beats.md (beats/foreshadowing/callbacks per area, where dialogue lives, weakest lines, box limits)
- docs/design/story_bible.md (story truth) and docs/design/canon.md (names, banned old names, tokens)
- tests/test_dialogue_fit.gd (how lines are measured)

## Hard rules
- Only edit the files assigned to you. Do NOT run Godot (one Godot process at a time on this PC; the main session runs it). Do NOT commit.
- Keep EVERY key, array length/order, `[tag]` expression prefix, `%s`/`%d` placeholder, `{token}` and the .tres file syntax exactly
  (zone story .tres dictionaries need a trailing comma before the closing brace; strings use double quotes - escape inner double quotes as \" or
  use single quotes / typographic quotes inside lines). Change text, never ids. Never add or remove keys unless the beat map says a key is missing
  AND the code would read it (do not invent keys the code never reads).
- Use tokens instead of literal names where a token exists ({villain} for Primm, {prince}, {town}, {capital}, {kingdom}, {rescuer}...).
  Never write any banned old name from canon.md. Never say "Elowen". Kingdom: Patchwork.
- Lines short: one or two sentences per box, target <= 160 characters, never over 240 (the box holds ~330 at most). Split long boxes only where the
  structure is an array/list of lines you can extend safely (check how the code reads it first); otherwise tighten.
- Quest instructions and mechanics info must stay clear and correct (what to do next, where, how). Never show enemy intent.
- Every NPC distinct (follow their voice entry). Humor serves character: puns, dad jokes, millennial references as PARODY (no real brands),
  never edgy or mean-spirited. Primm is sincere-and-wrong, never cartoonish. Jokes get quieter the closer the story gets to Primm.
- Land the beats, foreshadowing and callbacks the beat map assigns to your area (royal crest, the Wellspring, Maren's knowledge, the prince
  reveal...). Fix the contradictions and weak lines the beat map lists for your files (pronouns, numbers, dates, retired names).
- Do not touch the black market vendors (Fig Sly, the Secret Dealer). Do not touch the Old Well lines (another part adds a quest there).
- Do not change card numbers, rewards or quest logic.

## Deliverable
Write docs/design/dialogue_pass/<your_area>.md with: files and key groups rewritten (counts), notable fixes (contradictions, pronouns, tokens),
callbacks planted (line A key -> line B key), anything you could not do (needs code) and your 10 best "before -> after" examples (key, old text,
new text) for the user to judge. Reply with a short summary (what you rewrote, how many keys, the examples file path).
