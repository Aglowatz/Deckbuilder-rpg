# Overnight Oct 17 - loop log

One line per Phase 2 cycle: cycle, category, change, score before -> after, commit.

| Cycle | Category | Change | Score | Commit |
|---|---|---|---|---|
| 1 | Performance | Card art thumbnails (256x384, tools/card_thumbs.js, 7 MB) for every grid of small cards (Collection Book, Deck Station, vendors, Deck Box, reward boxes); one shared rules-panel gradient instead of one per card; the rules font fit cached per text and found by binary search, the rules text cached. Tried spreading grid building over frames: it made more 35-45 ms frames, so it is off. Bot: frames over 33 ms town 29 -> 18, Gainlands 5 -> 1, D.N.A. 5 -> 1, Buffet 7 -> 3, Dump 4 -> 3; re-opening a screen 25-30 % faster (vendor 493 -> 360 ms, deck station 175 -> 129 ms of build time headless). The single worst frame when a big screen opens (~130-145 ms) is still there: a full card view costs ~10 ms to build. | 6 -> 6.5 | (cycle 1 commit) |
| 2 | NPC life & dialogue | Two townsfolk now stroll their own small loops away from the square (the Old Well's yard and Elder Maren's lane) in the shared townsfolk sprite set with their own tints and rhythm (SpriteWanderer seed / ring radius / tint), and say passing lines like everyone else (NPC-TOWNSFOLK in the NPC source of truth, four lines). The baker's NPC data now uses his in-game name, Brindle the Baker. Test: both strollers walk and stay on walkable ground; town 60 fps on Medium. | 6 -> 7 | (cycle 2 commit) |
