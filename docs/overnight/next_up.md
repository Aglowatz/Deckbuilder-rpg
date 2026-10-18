# Overnight Oct 17 - next up (ranked)

Kept by the Phase 2 loop: the change that would raise the lowest category the most comes first.

1. **Performance: first opens** still ~200 ms for the Deck Station and ~130 ms for vendors and the Character screen (cycle 20 took the town to 31-39 frames over 33 ms). Next: profile the first Deck Station frame with HITCH_LOG=1; consider building its deck list over frames.
2. **UI consistency (cycle 4 did Character, Alchemist, Quest Log): one button look** - screens that hand-build their own button styles; settle on the theme variations; check focus order on the busiest screens (deck station, character).
3. **NPC life: a second and third strolling townsperson** on other routes (lanes, the lakeshore) with the existing sprite sets, not crowding the square.
4. ~~Visuals - starting forest: the open floor~~ done in cycle 3 (a fade bug). Left: the purple cave stalactites read against the sky at the top of high shots.
5. **Onboarding: time the first 30 minutes** with a bot from a new game (forest -> cave -> town -> first deck edit) and cut waits.
6. ~~Combat feel: card-play arc (cycle 8), attack wind-up and scaled damage numbers (cycle 19)~~. Next: a listen/feel pass in a real duel on the arena board.
7. **Collection / bestiary: enemy pictures** (zone roamers could show a rendered thumbnail of their 3D model instead of an icon).
8. ~~Audio mix: the 26 very dynamic tracks~~ done in cycle 10 (Music bus leveller). Next: listen-test the leveller on the arena and credits tracks; MUS-SHOP-GRISTLE still steps -7.2 dB at its loop wrap.
11. ~~Stale smoke check~~ fixed in cycle 13 (the dungeons smoke checks the Swolympus gate).
12. **Bestiary / battle enemy art**: the game is ready (cycle 15); make the 90 pictures from docs/art/bestiary_image_requests.md.
13. **World map content**: the map draws walkable ground as one flat parchment shade; buildings, roads and water could be drawn from the layout (TownBounds / zone layouts) so the map reads like a map.
14. **Pause menu icons**: Send Feedback, Open feedback folder and Quit to Title have no icons (the UI kit has none that fit); add three ICON-UI-* images to the next art request.
