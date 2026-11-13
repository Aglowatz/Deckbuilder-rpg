# Critic report - Nov 12d (build 1.0.0-rc6 source, dev build, time-boxed first look)

Written by a no-context critic (brief: `docs/review/critic_nov12d_brief.md`; it read nothing else). Its own write to this file was refused,
so this is its final message, filed by the session that launched it, with a "What was done" column added at the end.
**It is a partial report: 9 of 12 runs, about 22 of 30 minutes.** Three runs went to the New Game flow (slot chooser, second confirm, the
Path choice) and two to its own mistimed cave scripts. Scripts: `docs/review/play_scripts/n12d_01.txt` to `n12d_09.txt`. Shots and logs:
`_screenshots/play/n12d_01` to `n12d_09`.

## 1. How it played

| Run | What happened |
|---|---|
| n12d_01 | Title, New Game. Stopped at the slot chooser; the script did not expect it. |
| n12d_02 | Clicked "Start over here"; a second confirm ("Start Over" / "Cancel") appeared and the script did not answer it. |
| n12d_03 | Opening lines read. Stopped at "Choose your Path", which opens mid-conversation. |
| n12d_04 | Picked Beefcake, walked north in the forest. **Jump:** `dev travel dungeon D-TUT`, then `D-TUT -2`, to read the cave map. Saved `n12d_a`. |
| n12d_05 | `dev load n12d_a`, **jump** `dev travel dungeon D-TUT`. First fight (Cave Scavenger): pilot for 28 s, then `dev win`. Card reward taken. Later room clicks mistimed. |
| n12d_06 | Same jumps, with `dev autowin on`. Again only the first room was cleared. |
| n12d_07 | `dev load c13cap`. Quest log, map, **jump** `dev goto manhole`, E into the Crease, walked around it. Saved `n12d_c`. |
| n12d_08 | `c13cap`: walked the outer wall west and east, **jump** `dev goto manhole`, walked inside west, south and east, then into the Crease. |
| n12d_09 | `c13cap`, **jump** `dev goto manhole`, into the Crease to open the Black Market. It did not open (the hero stood past the stall). |

**Not reached.** Session 1: the shrine, the Hollow Well and its offer, any "Before the fight" panel, the Cave Warden and his closing
words, Crosspath, Elder Maren. Session 2: the Black Market screen and Fig Sly's lines (only the "[E] Browse the black market" prompt),
the Transit Yards, and the quest's first two steps (already ticked in the snapshot).

## 2. Scores

One score each for everything seen. Session 1 looks finished, Session 2 rougher.

- **Clarity 6/10.** In play the game explains itself well (the dungeon-map tip, the opening-hand panel, the quest tracker with ticks, the
  "Where to go" line). Getting into a new game is the weak part: slot chooser, a second confirm, then a Path choice mid-conversation.
- **Fun 6/10.** Rests on one piloted fight and some walking. The four Paths have a real voice; the first card reward explains its keywords.
- **Polish 6/10.** Session 1 about 7 (portraits, cave map and battle board look like one game). Session 2 about 5 (flat pale walls, a
  blocky map, a huge blank cave wall, a wrong-sounding toast).

## 3. Top 10 problems

1. **"Back out into the wastes." shows on arrival in the Crease** (`n12d_07/play.log` 49.0, `n12d_08` 126.3, `n12d_09` 59.3). **S**
2. **The Black Market is easy to miss and to overshoot**: no name over the stall, an identical second stall beside it, a small use radius
   (`n12d_07/r7_crease_e.png`, `n12d_09/r9_market.png`). **S**
3. **The Crease's east wall is a huge flat near-black sheet** filling the right 45 % of the frame with a hard vertical blue seam; flat
   cream rectangles hang in the air round the stalls (`n12d_09/r9_market.png`, `n12d_07/r7_crease_e.png`). **M**
4. **Starting a new game takes three decisions before any story**: New Game, a slot grid where every slot says "Start over here", then a
   delete warning (`n12d_02/play.log` 9.7). **M**
5. **Tidy-Bots knock you flat with no visible warning** (`n12d_07/play.log` 46.6, `n12d_08` 69.5); both times followed a `dev goto`, so the
   first hit may be unfair to count. **M**
6. **The Capital map is hard to read**: coarse blocks, the Crease as a box in the corner of the surface map, piled labels, no district
   names (`n12d_07/r7_map.png`). **M**
7. **The minimap is a blurry pixel blob inside an ornate frame** (`n12d_03/r3_open2.png`, `n12d_04/r4_f2.png`, `n12d_08/r8_in_w2.png`). **M**
8. **The wall's inner face and the outer wall are plain slabs next to detailed painted buildings** (`n12d_08/r8_in_w2.png`,
   `r8_out_e2.png`). Nothing floating or void was seen along the stretches walked (x 46 to 115 outside, x 4 to 30 inside). **L**
9. **The enemy name crowds its plate in battle** ("CAVE SCAVENGER" on two lines against the frame edge, `n12d_05/r5_battle.png`). **S**
10. **The Path choice interrupts the Rescuer's conversation, and the Wanderer's portrait has a hard cut edge** at about x = 950
    (`n12d_03/r3_open2.png`). **S**

## 4. Smaller notes

- **SCRIPT ERROR lines: none** (0 in `stdout.log` for all nine runs).
- After a key E the delete warning was gone from the dump and no game had started (`n12d_02/play.log` 20.2 to 21.5); not tested further.
- No "Before the fight" panel on the first room (Scavenger's Den went straight to the opening hand, `n12d_05/play.log` 42.7).
- The dungeon tip box sits over the Hollow Well node until dismissed (`n12d_04/r4_cave_map.png`).
- Rooms you cannot reach yet say "Unknown. Step on it to find out what waits there." (`n12d_06/r6_shrine.png`).
- "AT CAP: becomes essence" appears on a card in the first reward ever, before essence or caps are explained (`n12d_05/play.log` 87.7).
- The built-in player took 28 s to reach turn 3 of the first fight.
- The Quest Log's description and "Where to go" lines end in "..." in the dump (`n12d_07/play.log` 37.9); the screen was not checked.
- "25 unopened packs" sits under the Menu button and is hard to read over bright scenes (`n12d_08/r8_in_w2.png`).

## 5. What worked - keep as is

1. The painted look of the first hour (the Rescuer's portrait, the cave map, the battle board).
2. The writing voice ("The trees are packed too tight to get through. The cave it is, then.").
3. The quest tracker and Quest Log (ticked steps, a highlighted current step, "Where to go", "Point me to...").

---

## What was done with it (Fable Nov 12d, the session that ran the critic)

| # | Size | Done? |
|---|---|---|
| 1 | S | **Fixed.** The Crease lies south of the wall, so climbing down counted as leaving the city. It has its own line now. |
| 2 | S | **Fixed.** A "Fig Sly - Black Market" label over the stall; the use radius 1.8 m -> 2.6 m. |
| 3 | M | **Half.** The cream rectangles were lantern glass (a plain box glowing at 2.2): now a small tapered amber glass with a cap and foot. The east wall filling the frame when the hero hugs it is not changed. |
| 4 | M | Not changed (a menu's layout; logged for the owner). On a real first run the slots are empty; the critic's driver profile had old test saves in every slot. |
| 5 | M | Not changed. A real arrival has the zone's spawn grace; the hits followed debug jumps. Logged. |
| 6, 7 | M | Not changed (logged). |
| 8 | L | Not changed (no new art). |
| 9 | S | **Fixed.** The name starts 6 px further from the portrait ring. Two lines for a two-word name is the plate's design. |
| 10 | S | Not changed: the portrait edge is art (no new art this pass); the Path choice's place in the talk is as designed. Logged. |
| Note | S | **Fixed.** A room that cannot be reached yet now says "You can't reach it yet: clear a room that leads to it." |
