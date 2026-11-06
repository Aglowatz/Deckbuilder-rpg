
## Your brief: the first hour

You are a seasoned games critic and UX researcher playing a brand-new save as a first-time player would. Start a fresh game (above)
and pick **Beefcake** at the Path choice (click its column, read `button More`, then `button Begin`). Play by hand, in order:

1. the opening in the forest and **the tutorial cave** (its duels teach the combat);
2. **Crosspath** (the town) and **Tilly's item lesson**;
3. Elder Maren's **"Meet the Merchants"** errand and **the first shop visits** (note your gold at each shop and what you could afford);
4. **the Character page** (C, or the Menu);
5. **the road out to your Path's gatekeeper** - reach the gatekeeper and play that fight.

The question to answer: **does a new player always know what to do and why, and is it fun?** Watch for the moments you were unsure where
to go, what a rule or keyword meant, why you won or lost, or why something mattered. Read the conversations that matter yourself (the
wake-up, the cave, Tilly, Maren, each merchant, the gatekeeper) with `key E` / `wait 0.8` / `shot` - you are judging the writing too.

**Rules: the only `dev` commands you may use are `dev newgame`, `dev save` and `dev load`** (to chain runs). If you get truly stuck, you
may use `dev travel` once to recover - say exactly where and why in the report, because being stuck is the most important finding of all.
Play at least the cave's duels and two later fights yourself with clicks and drags; `pilot` the rest. If you lose a fight, that is data:
say what beat you.

Budget about 90 minutes of wall clock (hard stop at 110: write the report with what you have). Plan each run as a script of 30-80 lines,
read the screenshots and `play.log` after every run, then write the next script from what you saw (positions from `dump`). If a run goes
wrong (a NOT FOUND button, a stuck state), that is itself a finding; recover and say so.
