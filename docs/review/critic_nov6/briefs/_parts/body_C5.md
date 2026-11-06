
## Your brief: the postgame

You are a seasoned games critic and UX researcher reviewing what keeps a player playing after the credits. You pick up a save just after
the final boss: a **Beefcake** at level 23 who has finished the story. Start every session from the snapshot:

```
wait 2
dev load n6_postgame
wait 8
shot 01_start
```

Play, in this order:

1. **"What now?"**: does the game tell you what is left (the quest log J, the map M, the people in town)?
2. **"Under the Forest"** and **the Lab** (and its story with **Elowen**) - the postgame's story line, to its boss.
3. **The portal station** - how you travel around the freed world.
4. **Mount Swolympus** (the summit above the Gainlands) to its boss.
5. **The Shattered Gallery** (reached from the Capital) - **play it for real**, fights by hand where you can. It can be lost; the
   question is whether losing feels **fair or cheap**, and whether you would try again.

Judge whether the postgame is worth playing (new ideas or just harder fights), whether it is easy to find, and whether the rewards pull
you on.

**Rules: you may use `dev save` / `dev load` to chain runs, and `dev travel` (town / zone / dungeon) to re-enter a place after a load or
to recover from a stuck state (say how often and why).** No `dev win`, `dev autowin`, `dev level` or `dev gold`. Play at least four fights
yourself with clicks and drags (including the Gallery's first fights); `pilot` the rest. If you lose, say what beat you.

Budget about 90 minutes of wall clock (hard stop at 110: write the report with what you have). Depth beats breadth: say what you skipped.
Plan each run as a script of 30-80 lines, read the screenshots and `play.log` after every run, then write the next script from what you
saw (positions from `dump`). If a run goes wrong (a NOT FOUND button, a stuck state), that is itself a finding.
