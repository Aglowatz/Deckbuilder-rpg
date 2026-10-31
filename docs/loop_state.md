# Loop state - Dialogue critic pass (Oct 31 2026)

Brief: pasted "DIALOGUE CRITIC PASS" (suggest rewrites only; DIALOGUE FREEZE: no game dialogue file is edited). Questions: `docs/overnight_inbox.md`
("Dialogue critic pass"). Rules: one Godot process at a time; at most 3 agents at once; commit per part.
Previous loop state (Music Pass 3, all parts done) is in git history (commit 048e8233).

Source: `docs/dialogue/edit_oct27.csv` (4203 rows). The sheet's Dialogue Edit tab (design sheet 1GRfPvgp9I4TWVRO4T7p4bOJMwJ9kaVKt2q-0ybdXfYw) has
NO designer "New line" filled on Oct 31 (checked F:H), only 4 earlier review suggestions in G/H (same as lines_to_update_oct28/oct30).

| Part | What | State |
|---|---|---|
| 1 | `docs/dialogue/voice_bible.md` (done); `docs/dialogue/critic_report_oct31.md` (assembled from the agents' notes after Part 2) | voice bible done |
| 2 | 8 chunk agents (`docs/dialogue/critic_oct31/chunks/NN_*.csv` -> `suggestions_NN.csv` + `notes_NN.md`), 3 at a time | running |
| 3 | apply_dialogue_pass.js: "Critic suggestion" + "Accept (Y)" columns, test, workflow doc | todo |
| 4 | validate (`node tools/dialogue_critic_check.js --check=...`), dry run with all accepted on a temp copy | todo |

Tools: `node tools/dialogue_critic_check.js --protect` (tested phrases per line -> `docs/dialogue/critic_oct31/protected_phrases.json`),
`--check=<csv> [--out=report.md]`.
