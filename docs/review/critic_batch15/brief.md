# Critic brief - 21 screens nobody has checked (read only this file and the pictures)

You are looking at an indie deckbuilder RPG called **The Wayward Path** with fresh eyes. You know nothing else about it, and that is
the point. **Judge only what the pictures show.**

- Read ONLY this file and the 21 pictures in `C:\Dev\Deckbuilder-rpg\docs\review\critic_batch15\shots\` (open each with the Read tool).
- Do NOT read anything else in the project: no other docs, no code, no data, no earlier reviews. Do not run the game, git or any
  program. Do not edit anything except your report.
- Each picture is one moment of the game at 1600x900, named by where it was taken:

| Pictures | What the player is doing |
|---|---|
| `p4_01_shrine` | A room of the first (tutorial) dungeon: a shrine pop-up |
| `p4_02_well_offer`, `p4_03_well_accepted` | Another room of that dungeon, the Hollow Well: its offer, and what it shows once the offer is taken |
| `p4_04_before_the_fight`, `p4_05_before_the_boss` | The panel shown before a fight, and before the dungeon's boss |
| `p4_06_warden_closing` | The boss (the Cave Warden) has been beaten: his closing words |
| `p4_07_crosspath_first_exit` | The first step out of the dungeon into the town of Crosspath |
| `p4_08_crosspath_beside_maren`, `p4_09_maren_talk` | A little later, beside the town's elder, and talking to her |
| `p4_10_figsly_talk`, `p4_11_black_market` | Late in the game, a hideout under the last city: a black-market dealer, and his shop screen |
| `p4_12_transit_yards`, `p4_13_transit_yards_low` | A district of the last city (two camera settings) |
| `p4_14` to `p4_16` `intro_rescuer_walks_away` | The end of the opening scene: the woman who rescued the hero walks away into the trees. `_frames` are six frames in a row, cropped (two camera settings); `_full` is one whole frame |
| `p4_17` to `p4_19` `capital_after_the_ending` | The last city after the final boss has fallen: the people celebrate |
| `p4_20_credits`, `p4_21_after_credits` | The end credits, and the card after them |

## What to write

Write your report to `C:\Dev\Deckbuilder-rpg\docs\review\critic_batch15\report.md` (if the write is refused, put the whole report in your
final message). Keep it under 900 words.

1. **Two scores out of 10** for the set as a whole: **clarity** (does a new player know what they are looking at and what to do next?)
   and **polish** (does it look finished and of one piece?). One sentence each on why.
2. **Your top 10 problems, most important first.** For each: the picture's name, where in the picture (left / right / top / bottom, or
   the words on screen), what is wrong, and a size: **S** (a small, safe fix: a word, a position, a size, a colour, a missing prompt),
   **M** (a contained change to one screen or one place), **L** (a redesign or new art). Look for anything **broken** (cut off,
   overlapping, floating, a void, a visible seam), **confusing** (unclear words, no hint what to press, something unexplained),
   **ugly**, or **obviously unfinished** (flat stand-in shapes beside painted art, placeholder-looking pieces, text that overflows its box).
3. **Three things that work well**, one line each.

Be specific and honest. If a picture looks fine, do not invent a problem for it. Do not guess at causes or suggest code: describe what a
player would see.
