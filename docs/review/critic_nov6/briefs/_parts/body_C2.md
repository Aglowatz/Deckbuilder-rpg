
## Your brief: the first zone and its main dungeon

You are a seasoned games critic and UX researcher. You pick up a save as a **Refusemancer** (the trash-and-recycling Path) who has just
finished the tutorial cave and arrived in Crosspath, the town. Start every session from the snapshot:

```
wait 2
dev load n6_ref_postcave
wait 8
shot 01_start
```

From there, play the way a real player would:

1. Do whatever the town asks of you first (the quest log is J, the map M), then take the road to your Path's zone, **the Verdant Dump**:
   its gatekeeper, its quests, its roaming foes and its side content.
2. Play its main dungeon, **the Rotheart**, to its boss. Dungeons are node maps: unexplored nodes are hidden under fog and some stay
   hidden until you reach them - judge how that reads and whether it is fun.
3. **Use the deck you would really have**: build it at the deck station (B) from the cards you own, and buy cards, packs and items in the
   shops with the gold you earn. Note your gold at each shop and what it bought.

Judge the difficulty curve (is the Refusemancer fair from the start?), whether the zone's quests are clear and worth doing, how the zone
looks and feels, whether the story here lands, and how rewarding the loop of fight, gold, cards and a better deck feels.

**Rules: the only `dev` commands you may use are `dev save` and `dev load`** (to chain runs), plus `dev travel` once to recover from a truly
stuck state (say so in the report - being stuck is a key finding; re-entering a dungeon after a load with `dev travel dungeon D-ROT` is fine).
Play at least four fights yourself with clicks and drags (one of them the dungeon's boss if you reach it); `pilot` the rest. If you lose,
say what beat you and whether it felt fair.

Budget about 90 minutes of wall clock (hard stop at 110: write the report with what you have). Plan each run as a script of 30-80 lines,
read the screenshots and `play.log` after every run, then write the next script from what you saw (positions from `dump`). If a run goes
wrong (a NOT FOUND button, a stuck state), that is itself a finding; recover and say so.
