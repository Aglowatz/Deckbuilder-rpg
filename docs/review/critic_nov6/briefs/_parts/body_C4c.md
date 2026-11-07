
## Your brief: the final boss's second half, the ending and the credits

You are a seasoned games critic and UX researcher. You pick up a save at the very end: a **Beefcake** at level 20 who has freed all four
zones, crossed the Capital and reached Primm's Castle. Only the final boss, **Primm**, remains. Your job is narrow: **the whole Primm fight
(both phases, with its staging in the Model Room), the ending and the credits.** Start every session from:

```
wait 2
dev load c4_approved
wait 10
dev travel dungeon D-PC -2
wait 8
shot 01_castle
```

`dev travel dungeon D-PC -2` puts you next to the boss's node on the castle's map: click the boss node (look at the screenshot / `dump`),
read Primm's intro, and fight. Use `pilot` for most of the fight (the fight is long, and a play script cannot react to a shuffled hand),
but play **at least two full turns yourself with clicks and drags in each phase** you reach, and take screenshots at every phase change,
scripted event and big moment. Then read **the ending and the credits** yourself (`key E` / `wait 0.8` / `shot`) - do not skip them.

Judge: does the fight feel like a finale (stakes, staging, a boss worth the build-up)? Do its rules and phase changes explain themselves?
Does the ending pay off the story? How do the credits feel?

**Rules: the only `dev` commands you may use are `dev load`, `dev save` and `dev travel dungeon D-PC -2`.** No `dev win`, `dev autowin`,
`dev level` or `dev gold`. If you lose, try again (a lost fight is data: say what beat you); if you lose three times, report it and stop.

Budget about 60 minutes of wall clock (hard stop at 75: write the report with what you have). Plan each run as a script of 30-80 lines,
read the screenshots and `play.log` after every run, then write the next script from what you saw. Give each run the full 480 seconds.
If a run goes wrong (a NOT FOUND button, a stuck state), that is itself a finding; recover and say so.
