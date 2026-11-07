
## Your brief: the finale

You are a seasoned games critic and UX researcher. You pick up a save at the very end: a **Beefcake** at level 20 who has freed all four
zones, reached **the Capital** and passed its gate exam. Primm's Castle, the final dungeon, is ahead. Start every session from:

```
wait 2
dev load c4_approved
wait 10
shot 01_start
```

Play by hand:

1. **Primm's Castle** (walk in if you can find it; otherwise `dev travel dungeon D-PC`), node by node, to its end. Look for **the Crease**
   (a hidden part of the Capital the story leads you to) and say whether anything pointed you to it.
2. **Primm's real fight**, the final boss, including its staging in **the Model Room** - play this fight yourself with clicks and drags,
   all the way, and judge whether it feels like a finale.
3. **The ending and the credits** - read them; judge whether the ending pays off the story.

**Rules: the only `dev` commands you may use are `dev save` and `dev load`** (to chain runs; a snapshot does not keep a dungeon in progress,
so after a load re-enter with `dev travel dungeon D-PC`, and add a node number - `dev travel dungeon D-PC <n>` - to resume near the node you
had reached; `-2` puts you next to the boss. Say in the report how often you did this). No `dev win`, `dev autowin`, `dev level` or `dev
gold`. Use `pilot` for the castle's ordinary fights if time is short, but **play Primm yourself**. If you lose Primm, try again at least
once with a changed deck or plan, and say what beat you.

Budget about 90 minutes of wall clock (hard stop at 110: write the report with what you have). **Reach Primm within the first 45 minutes**
(use the node jump if the castle eats your time) - the finale matters most. Plan each run as a script of 30-80 lines, read the screenshots
and `play.log` after every run, then write the next script from what you saw (positions from `dump`). If a run goes wrong (a NOT FOUND
button, a stuck state), that is itself a finding; recover and say so.
