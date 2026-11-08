# Minigame graphics plan (Overnight Nov 7-8, Part 6.2)

Goal: every zone minigame should look and feel exciting with as little new image generation as possible. The levers, cheapest first:
reused card and portrait art, code-drawn stand-ins, shaders, particles, screen shake and pops, the existing music stings, and score
flourishes. One painted image per game at most, and only where it lifts the game the most.

## Shared tonight (code only): `ui/zone/minigame_fx.gd`

Hooked into all eight minigame and puzzle screens at their existing sound cues:
- **Scoring:** a spark burst where the player clicked (`sparkle_at_mouse`) on a perfect rep, a finished order, a matched pair, a correct tube.
- **Missing:** a quick shake of the play area on every error cue (`shake(body)`).
- **Finishing:** a gold flash and a five-column confetti shower on a win, a red pulse on a loss (`finish`), on top of the STG-MINI stings.

## Per game

| Game (zone, host) | Today | Code-only improvements (tonight: done / later: listed) | The one image that would lift it most |
|---|---|---|---|
| **Trivia** (every zone; Ectomund, Professor Pate, the others) | dark page, title, four wooden buttons | **Done:** classroom stand-in (wood wall, windows, desks, sunbeam), the question chalked on a green board, the zone's quiz-giver as the teacher (portrait) with a speech bubble, desk-card answers that flash green/red, the right answer lit after a miss, streak counter with a pop, sparkles, teacher hop, per-zone quiz names (it said "Compliance Re-Certification" in every zone) | **MG-BG-CLASSROOM** (art list): an anime classroom, desks in rows, an empty green chalkboard, warm window light |
| **Rep Counter** (Gainlands, Studio 3 AM) | a timing bar and counts | **Done:** sparks on heavy hits, shake on misses, confetti on a win. **Later:** the bar pulses to the beat; "PERFECT!" pops scale in; the Beefcake card art (e.g. Gym Bro) as the lifter on a plate behind the bar | MG-BG-GYM: a 3 a.m. neon gym with a lifting platform (optional) |
| **Order Up!** (Buffet, Chef Flambe Fontaine) | ingredient buttons, order tickets | **Done:** sparks on a finished order, shake on a wrong ingredient, confetti. **Later:** tickets slide in from the rail; a steam particle puff on each plate; the host's portrait cheering at streaks; Gourmand card art on the tickets | none needed; the card art carries it |
| **Sort It Out!** (Dump, Recycle Rhonda) | sorting buttons | **Done:** shake on a wrong bin, confetti. **Later:** items arc into the bins (tween on a curve); a green leaf burst on a correct sort; Refusemancer card art (Garbage tokens) as the items | none needed |
| **Rec Room: Match the Memories** (D.N.A.) | a 4 x 4 table of icon cards | **Done:** sparks on a pair, confetti. **Later:** cards flip with a scale tween (as Dex's table does) | none needed |
| **Dex's Table** (every Path zone, new) | - | **Done:** real Path card art face up, flip tween, pair pulse and sparks, miss shake, moves meter turning red past Dex's score, stars popping in | ICON-EQ-LUCKY-SPATS for the prize (art list); Dex reuses the townsfolk sprite and portrait |
| **Puzzles** (Wheel, Tube, Recipe, Seed Shrine) | panels of buttons | **Done:** sparks / shake / confetti at their cues. **Later:** the wheel puzzle's wheels spin (rotation tween) when powered; tubes light along the route; the stew pot bubbles (particles) | none |

## Images for the art list (Part 9)

| Id | Priority | Note |
|---|---|---|
| MG-BG-CLASSROOM | High | the trivia classroom (every zone's quiz uses it); the coded stand-in is in place until it arrives |
| ICON-EQ-LUCKY-SPATS | Medium | the Cardsharp's prize icon (ICON style) |
| MG-BG-GYM | Low | optional backdrop for Rep Counter |
