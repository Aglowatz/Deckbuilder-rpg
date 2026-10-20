# Rules for helper agents tonight (overnight Oct 19-20)

- Project: C:\Dev\Deckbuilder-rpg (Godot 4.7.2, GDScript, static typing required, see CLAUDE.md). Use `cd /c/Dev/Deckbuilder-rpg`.
- The user is asleep: never ask, take the safest reasonable choice, note open questions in your final report (the main session puts them in the inbox).
- Do NOT run Godot (this low-memory PC runs one Godot process at a time; the main session runs every GUT test, smoke and screenshot and will
  report errors back to you). Do NOT git commit or push. Do NOT touch files outside your assignment (other agents are editing other files).
- Bash heredocs containing apostrophes fail in this environment, and backslashes in heredocs/perl get mangled: write files with the Write/Edit
  tools; for scripted edits write a node script with the Write tool, then run it with node.
- New `class_name` scripts are fine (the main session re-imports). Every file starts with `extends`; type every variable/param/return.
- Keep old saves loading: never rename or remove existing quest ids, flags, save keys, dialogue keys or triggers.
- Never: show enemy intent; touch the black market vendors (Fig Sly, the Secret Dealer); add chapters, explorable sub-areas or walkable dungeons;
  put readable text in the 3D world; make monetization decisions; generate or download art/music; touch the Drive "Pending Review" folder.
- Write GUT tests (tests/**/test_*.gd, extends GutTest) for what you build. Pure logic in core/, presentation in ui/ / world/.
- Final reply: files changed, what to run to verify (the GUT test files, any smoke/screenshot), known risks, open questions.
