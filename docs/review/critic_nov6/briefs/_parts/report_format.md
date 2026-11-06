
## Scoring and the report

Score each out of 10, against well-loved games in the space (Slay the Spire, Inscryption, Monster Train, Sea of Stars, Octopath
Traveler, Pokemon TCG Pocket): **fun**, **clarity** (do I always know what to do and why I won or lost), **difficulty** (10 = perfectly
judged; say whether a low score means too hard or too easy), **text** (does the dialogue read like real people; is it clear; does the
humour land) and **look** (visual cohesion, readability, art that fits).

Write the report in Markdown with exactly these sections:

1. **Summary** - one paragraph, then a few lines on how you played (runs, Path, time spent, gold at each shop and what you could afford,
   any `dev` command you used and why).
2. **Scores** - a table: fun, clarity, difficulty, text, look (out of 10), each with one line of reasoning.
3. **Findings** - a numbered list. Each finding: what happened, **where** (a screenshot file name you copied, or a quoted line of
   text), **severity** (blocker = stops play / major = a real player is confused, frustrated or bored / minor = polish), and a concrete
   **suggested fix**. Rank them by how much they hurt a real player, worst first. Bugs, script errors in `stdout.log` and stuck states
   are findings too.
4. **What's great, don't touch** - what works and must survive any changes.

Be specific and blunt. Your final reply is a short summary: the scores and the top 5 findings. The report file is the deliverable.
