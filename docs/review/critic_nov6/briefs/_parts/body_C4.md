
## Your brief: the endgame

You are a seasoned games critic and UX researcher. You pick up a save near the end: a **Beefcake** at level 20 who has freed all four
zones, with the deck, gear, items and gold a typical player has at this point. Start every session from the snapshot:

```
wait 2
dev load n6_lategame
wait 8
shot 01_start
```

Play by hand:

1. **The way to the Capital** (follow the quest log J / the map M - the road leads under the town first), then **the Capital** itself.
2. **The Crease** (a hidden part of the Capital the story leads you to) and **the castle**, Primm's Castle, as a dungeon to its end.
3. **Primm's real fight**, the final boss, including its staging in **the Model Room** - play this fight yourself with clicks and drags,
   all the way, and judge whether it feels like a finale.
4. **The ending and the credits** - read them; judge whether the ending pays off the story.

Judge whether the endgame feels like a climax (stakes, set pieces, a boss worth the build-up), whether the Capital is worth exploring,
and whether the story's threads come together.

**Rules: the only `dev` commands you may use are `dev save` and `dev load`** (to chain runs), `dev travel dungeon D-PC` to re-enter the castle
after a load, and `dev travel` once to recover from a truly stuck state (say so in the report - a stuck state in the finale is a key
finding). No `dev win`, `dev autowin`, `dev level` or `dev gold`. If you lose Primm, try again at least once with a changed deck or plan,
and say what beat you.

Budget about 90 minutes of wall clock (hard stop at 110: write the report with what you have). Plan each run as a script of 30-80 lines,
read the screenshots and `play.log` after every run, then write the next script from what you saw (positions from `dump`). If a run goes
wrong (a NOT FOUND button, a stuck state), that is itself a finding; recover and say so.
