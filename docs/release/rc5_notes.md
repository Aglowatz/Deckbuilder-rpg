# The Wayward Path 1.0.0-rc5 (2026-11-12) - release candidate 5 for playtesters

Windows build: `builds/TheWaywardPath-v1.0.0-rc5-windows.zip`, next to the RC4 zip (size and checks: the report's Part 6,
`docs/overnight_report.md`). Unzip the whole folder somewhere you can write to (Desktop or Documents, not Program Files) and run
`TheWaywardPath.exe`. If Windows says "Windows protected your PC", click "More info", then "Run anyway". `README_PLAYTEST.txt` in the
folder explains the start files. **Saves carry over** from RC4 and every earlier build.

RC5 is a pass on how the game looks and moves, and on the last hour. Nothing on the battle board or in any menu moved.

## What changed since RC4

**The world**
- **The D.N.A.** no longer looks like black boxes: its ten-metre walls are lit green wallpaper and marble with a brass rail, the light
  comes from the side, and the wall between you and the camera cuts away wherever you stand (it used to fill the screen by the giant chest).
- **The Gainlands'** cliffs and rocks are smooth, layered sandstone instead of hard orange triangles; the colours and the sea are calmer.
- **The Endless Buffet** has a cooler fill light (less of one orange wash), glazing bars in its lit windows, grates in its oven mouths and a
  real oven-brick double door in the Test Kitchen's archway.
- **The House of Gains** has a studded door behind its portcullis.
- **The Capital's outer wall** has dust at its foot and rain streaks under the cornice; its street lamps are rounder.
- **Buildings that hide you fade out completely.** They used to stay 3 % visible, which read as ghost buildings (the Dump's glasshouse, the
  Capital's yards). The glasshouse's glass fades with it.
- **No flat untextured surfaces:** any surface with a single flat colour gets a painted wash, and nothing is pure white or pure black.
- **The Low camera angle** no longer sinks into the hills south of the Resistance Camp.

**After Primm**
- **The Capital celebrates.** A warm afternoon light with real shadows (it was washed out to white), the fountains running again, a crowd of
  townsfolk in the Gate Plaza and on the avenue with new things to say, bunting from the fountain and across the avenue, confetti on the
  paving, and five banners in the Paths' colours hung over Primm's face on the palace.
- **The ending:** each picture drifts slowly while you read, the credits fade in over it, and a "Thank you for playing" card names what is
  still out there (the Path-ology Lab, the Shattered Gallery) before the postgame announcement.
- **The cracked mirror** at the castle door is a mirror of dark shards now, not a white panel.

**Primm**
- **Whose cards are whose in Phase 2:** his copies of your cards shine silver all the time; yours are plain. The phase rule says so.
- **The castle closes in:** fights in Primm's Castle have a violet vignette at the screen edges that deepens with every room you clear; his
  three phases each have their own (gold, cold silver, pulsing violet with cracks of light). Still under "Reduce motion".
- **The turn panel** follows what you see on the table: it no longer says "Your turn" while Primm is still attacking.

**Battles and screens**
- A band of light crosses a card when its numbers go up; VICTORY and DEFEAT stand on a band with an outline; scene changes fade through
  the zone's own colour instead of black.

**Rules**
- **Max hand size is 10, always.** Levels 14 and 28 no longer add a card (level 28 gives a Path pack instead); the Soul Courier's Lanyard
  gives +2 max HP and Quota's Stopwatch +3 max HP instead of a bigger hand; the Weighing Scale's boon is an extra first-turn card.

**Fixes**
- The foe that waits by a zone's entrance stays beaten once you beat it (the other roamers still return with each visit).
- Old Hob's portrait no longer stands alone on screen for a moment after a defeat.

## Known issues
- The D.N.A. is still the darkest zone by design (4:59 PM overcast); it is meant to be gloomy, not unreadable - say so if it is.
- With the hand capped at ten at the end of a turn, a hand only passes ten cards in the middle of a turn (after a big draw); the two-row
  hand can still show then.
- Everything in RC4's known issues that is not listed above still stands (`docs/release/post_1_0_backlog.md`).
