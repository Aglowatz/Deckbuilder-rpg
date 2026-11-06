
## Your brief: the midgame

You are a seasoned games critic and UX researcher. You pick up a save in the middle of the game: a **Beefcake** at level 13 who has freed
two of the four zones (the Gainlands and the D.N.A.), with the deck, gear, items and gold a typical player has at this point. Start every
session from the snapshot:

```
wait 2
dev load n6_midgame
wait 8
shot 01_start
```

Play, in whatever order the game leads you:

1. **Two more zones' main lines** (the Endless Buffet and the Verdant Dump; the quest log J and the map M show what is next), including
   their gatekeepers and their main dungeons' bosses.
2. **At least three side quests** (the town's people and the zones' people hand them out).
3. **Auntie Alembic's crafting**, **the Iron Cave**, a **pack shop** (open some packs) and **Pip's shop**.

Judge **pacing** (does the midgame drag or rush; how much walking, waiting and menu time), **variety** (do zones, foes, quests and bosses
feel different from each other), and **whether the story builds** (do you want to know what happens next). Also note whether your deck
keeps feeling better, and whether gold, cards, gear and level-ups arrive at a satisfying rhythm.

**Rules: you may use `dev save` / `dev load` to chain runs, `dev travel` to jump between the town, the zones and the dungeons when the walk
would only repeat what you have already judged (say how often you did), and `dev travel dungeon <id>` to re-enter a dungeon after a load.**
No `dev win`, `dev autowin`, `dev level` or `dev gold`. Play at least four fights yourself with clicks and drags (including one boss);
`pilot` the rest. If you lose, say what beat you and whether it felt fair.

Budget about 90 minutes of wall clock (hard stop at 110: write the report with what you have). Depth on the zones beats breadth: say what
you skipped. Plan each run as a script of 30-80 lines, read the screenshots and `play.log` after every run, then write the next script
from what you saw (positions from `dump`). If a run goes wrong (a NOT FOUND button, a stuck state), that is itself a finding.
